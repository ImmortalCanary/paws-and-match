#!/usr/bin/env bash
set -euo pipefail
# Nur in einer separaten kurzlebigen CI-Datenbank ausfuehren.
fixture=$(psql -X -At -v ON_ERROR_STOP=1 <<'SQL'
WITH h AS (INSERT INTO tierheim(name,ort) VALUES('Race-Test','Testort') RETURNING tierheim_id),
t AS (INSERT INTO tier(tierheim_id,name,tierart) SELECT tierheim_id,'Race-Tier','Hund' FROM h RETURNING tier_id),
i AS (INSERT INTO interessent(vorname,nachname) VALUES('Race-A','Test'),('Race-B','Test') RETURNING interessent_id),
b AS (INSERT INTO bewerbung(tier_id,interessent_id) SELECT t.tier_id,i.interessent_id FROM t CROSS JOIN i RETURNING bewerbung_id,tier_id)
SELECT min(bewerbung_id)||','||max(bewerbung_id)||','||min(tier_id) FROM b;
SQL
)
IFS=, read -r first second animal <<< "$fixture"
psql -X -v ON_ERROR_STOP=1 -c "UPDATE bewerbung SET status='in_pruefung' WHERE bewerbung_id IN ($first,$second);"
PGAPPNAME=reservation-racer-a psql -X -v ON_ERROR_STOP=1 > "$RUNNER_TEMP/race-a.log" 2>&1 <<SQL &
BEGIN;
SELECT reserviere_tier($first,clock_timestamp()+interval '1 day');
SELECT pg_sleep(3);
COMMIT;
SQL
pid=$!
ready=false
for attempt in $(seq 1 100); do
  if [ "$(psql -X -At -c "SELECT count(*) FROM pg_stat_activity WHERE application_name='reservation-racer-a' AND wait_event='PgSleep';")" = "1" ]; then
    ready=true
    break
  fi
  sleep 0.05
done
if [ "$ready" != true ]; then
  wait "$pid" || true
  cat "$RUNNER_TEMP/race-a.log"
  exit 1
fi
set +e
PGOPTIONS='-c lock_timeout=10s -c statement_timeout=15s' psql -X -v ON_ERROR_STOP=1 -c "SELECT reserviere_tier($second,clock_timestamp()+interval '1 day');" > "$RUNNER_TEMP/race-b.log" 2>&1
result=$?
set -e
wait "$pid"
cat "$RUNNER_TEMP/race-a.log" "$RUNNER_TEMP/race-b.log"
test "$result" -ne 0
grep -q 'RESERVATION_CONFLICT' "$RUNNER_TEMP/race-b.log"
test "$(psql -X -At -c "SELECT count(*) FROM reservierung WHERE tier_id=$animal AND status='aktiv';")" = "1"
test "$(psql -X -At -c "SELECT status FROM tier WHERE tier_id=$animal;")" = "reserviert"
