# Matching v2

Entwicklungsstand im Branch feature/matching-v2. Noch nicht nach main uebernommen. Die neue Migration ergaenzt Spalten und zwei Views; bestehende Daten werden nicht geloescht. Die alte Abfrage 003_matching.sql bleibt unveraendert.

## Regeln

Zusatzkriterien: Hundevertraeglichkeit gegen Hunde im Haushalt; erforderliche Erfahrung gegen vorhandene Tiererfahrung; verfuegbare Betreuungsminuten pro Tag gegen geschaetzten Bedarf; monatliches Tierbudget in Euro gegen geschaetzte Monatskosten. Gleichheit bei Zeit und Budget reicht aus. Betreuungszeit bedeutet aktive Betreuung, nicht lediglich Anwesenheit. Alleinbleibedauer bleibt ein separates Kriterium.

Alle acht Kriterien sind im Prototyp Pflichtpruefungen. Ein bekanntes Nein fuehrt zu ausgeschlossen. Ohne Nein, aber mit unbekannten Pruefergebnissen: manuell pruefen. Nur acht erfuellte Pruefungen ergeben grundsaetzlich passend. Nicht relevante Bedingungen koennen trotz fehlender anderer Angaben entschieden werden: Ohne Hunde im Haushalt ist Hundevertraeglichkeit kein Ausschlussgrund. Neue Spalten sind NULL, bis Angaben erfasst wurden; es gibt keine pauschale positive Vorbelegung.

Die Zahlen sind Eingaben des Tierheims beziehungsweise Interessenten, keine allgemeingueltigen Vorgaben. Budget ist eine vereinfachte Planungshilfe, kein Nachweis finanzieller Eignung. Ergebnisse ersetzen keine fachliche Vermittlungsentscheidung.

## Lokal aktualisieren

Zuerst im Repository den Branch auschecken und Docker wie in lokaler-start.md starten. Danach die Migration genau einmal auf die bereits initialisierte Datenbank anwenden:

```bash
git switch feature/matching-v2
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/migrations/006_matching_v2.sql
```

Die Migration wird nicht automatisch von Compose ausgefuehrt. Sie ist nicht fuer wiederholte Ausfuehrung ausgelegt. Kein Reset und kein Loeschen des Volumes sind erforderlich. Auch eine frisch initialisierte Datenbank braucht diese Migration zusaetzlich.

Abfragen:

```sql
SELECT * FROM matching_v2 ORDER BY interessent_id, tier_id;
SELECT * FROM matching_v2_details ORDER BY interessent_id, tier_id, kriterium;
```

Die bisherigen Demodaten enthalten keine Werte fuer die neuen Felder. Daher darf insbesondere Luna nicht ohne weitere Angaben als vollstaendig passend erscheinen. Die Tests erzeugen eigene vollstaendige Datensaetze und rollen diese danach zurueck.

## Tests

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/tests/002_matching_v2.sql
```

Ein eigener Workflow Matching v2 tests prueft die Migration, acht Kriterien, Gleichheitsgrenzen, Budgetausschluss, unbekanntes Budget, Ausschlussprioritaet, Erfahrung, Betreuungszeit, reservierte Tiere und ausgewaehlte Wertepruefungen. Noch nicht jede Kombination ist getestet. Erfolgreiche Ausfuehrung ist erst nach einem nachgewiesenen Testlauf bestaetigt. Der bisherige Workflow testet weiterhin Version 1.
