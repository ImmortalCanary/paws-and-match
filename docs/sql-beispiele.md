# Erste SQL-Anwendungsfaelle

## Auswertungen

Nach dem lokalen Start im Projektordner ausfuehren:

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/004_auswertungen.sql
```

Die vier Abfragen zeigen verfuegbare Tiere mit Tierheim, Tierzahlen je Standort, Bewerbungen mit zugehoerigen Stammdaten und verfuegbare Tiere ohne offene oder laufend gepruefte Bewerbung.

Mit unveraenderten Demodaten erwartet: drei verfuegbare Tiere im Demo-Tierheim, keine Bewerbungen und drei Tiere ohne offene Bewerbung. Das sind Erwartungen, keine bereits nachgewiesenen Testergebnisse. Die Datei fuehrt nur SELECT-Abfragen aus.

## Bewerbung ausprobieren

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/005_bewerbung_demo.sql
```

Das Beispiel legt fuer Anna und Luna eine Bewerbung an, setzt sie auf in_pruefung und zeigt den Datensatz. Anschliessend werden die Datenaenderungen mit ROLLBACK zurueckgenommen. ID-Sequenzen koennen dennoch weiterzaehlen. Die Demo erwartet genau eine verfuegbare Katze namens Luna, genau eine Anna Demoperson und keine bestehende Bewerbung fuer dieses Paar. Bei nicht passenden Daten bricht sie absichtlich ab.

Die Bewerbung ist ein erfasster Vorgang, kein gespeichertes Matching-Ergebnis. Eine grundsaetzlich passende Kombination loest keine Bewerbung aus. Eine Bewerbung reserviert kein Tier und bestaetigt keine Adoption. Uebergaenge zwischen Bewerbungsstatus sind im bisherigen Schema noch nicht als verbindlicher Prozess abgesichert.

## Ausfuehrung und Teststatus

Diese Dateien sind optionale Beispiele und werden nicht automatisch beim Docker-Start geladen. Der bestehende GitHub-Actions-Workflow fuehrt sie bislang ebenfalls nicht aus. SQL-Dateien und Dokumentation sind vorbereitet; erfolgreiche Ausfuehrung ist noch zu pruefen. Die vorhandenen Schema-, Matching- und Testdateien bleiben unveraendert.
