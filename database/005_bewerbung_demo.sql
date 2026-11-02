-- Nur fuer die unveraenderte Demo-Datenbank.
-- Ablauf demonstrieren, ohne die Bewerbung dauerhaft zu speichern.
BEGIN;
DO $$
DECLARE
    v_tier INTEGER;
    v_interessent INTEGER;
    v_bewerbung INTEGER;
BEGIN
    SELECT tier_id INTO STRICT v_tier FROM tier
    WHERE name = 'Luna' AND tierart = 'Katze' AND status = 'verfuegbar';
    SELECT interessent_id INTO STRICT v_interessent FROM interessent
    WHERE vorname = 'Anna' AND nachname = 'Demoperson';

    INSERT INTO bewerbung (tier_id, interessent_id)
    VALUES (v_tier, v_interessent)
    RETURNING bewerbung_id INTO v_bewerbung;
    RAISE NOTICE 'Demo-Bewerbung % angelegt', v_bewerbung;

    UPDATE bewerbung SET status = 'in_pruefung'
    WHERE bewerbung_id = v_bewerbung;
END $$;

SELECT b.bewerbung_id, t.name AS tiername, i.vorname, b.status
FROM bewerbung b
JOIN tier t ON t.tier_id = b.tier_id
JOIN interessent i ON i.interessent_id = b.interessent_id
WHERE t.name = 'Luna' AND i.vorname = 'Anna'
  AND i.nachname = 'Demoperson';

ROLLBACK;
-- Automatisch erzeugte ID-Sequenzen koennen trotz ROLLBACK weiterzaehlen.
-- Kein Adoptionsabschluss und keine automatische Reservierung.
