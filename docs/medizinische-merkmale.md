# Medizinische Besonderheiten

Entwicklungsstand im Branch feature/matching-v2. Die Tabellen ergaenzen den Prototyp; sie ersetzen keine tiermedizinische Dokumentation oder fachliche Beurteilung.

## Datenmodell

medizinisches_merkmal ist ein Katalog mit eindeutiger Bezeichnung und optionaler Beschreibung. tier_medizinisches_merkmal verbindet Tiere und Merkmale als m:n-Beziehung. Jede Zuordnung gehoert genau einem Tier und einem Merkmal. Ein Tier oder Merkmal kann null bis viele Zuordnungen haben. Erfassungsdatum und individueller Hinweis gehoeren zur Zuordnung.

Pro Tier und Merkmal gibt es genau eine Zuordnung. Wiederkehrende Diagnosen, Behandlungen, Medikamente, Untersuchungstermine und eine Aenderungshistorie sind noch nicht abgebildet. Das Erfassungsdatum ist kein Diagnosedatum. Merkmalsnamen sind als gepflegter Katalog zu verstehen; Gross-/Kleinschreibungsvarianten und Synonyme werden noch nicht automatisch zusammengefuehrt.

Das vorhandene Freitextfeld tier.medizinische_hinweise bleibt unveraendert. Es wird nicht automatisch in strukturierte Merkmale umgewandelt. Keine Zuordnung bedeutet lediglich keine strukturierte Angabe, nicht gesund. Die neue View zeigt nur Tiere mit zugeordneten Merkmalen, unabhaengig vom Vermittlungsstatus.

Merkmale beeinflussen das Matching nicht automatisch. Insbesondere werden aus einer Bezeichnung keine Anforderungen an Wohnsituation oder Interessenten abgeleitet. Bestehende Matching-Angaben muessen weiterhin gesondert gepflegt werden.

## Migration lokal

Nach dem Wechsel in den Entwicklungsbranch und nach Migration 006 genau einmal ausfuehren:

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/migrations/007_medizinische_merkmale.sql
```

Die Migration loescht keine vorhandenen Daten und wird nicht automatisch durch Docker Compose gestartet. Sie ist nicht fuer wiederholte Ausfuehrung ausgelegt. Referenzierte Tiere oder Merkmale koennen nicht ohne vorheriges Entfernen der Zuordnungen geloescht werden.

Uebersicht im SQL-Client:

```sql
SELECT * FROM tier_medizin_uebersicht ORDER BY tier_id, merkmal_id;
```

Ohne erfasste Zuordnungen ist das Ergebnis leer. Es werden keine echten Gesundheitsangaben und keine medizinischen Demobehauptungen angelegt.

## Tests

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/tests/003_medizinische_merkmale.sql
```

Die Tests verwenden fiktive Merkmale und rollen ihre Datenaenderungen zurueck. ID-Sequenzen koennen weiterzaehlen. Der Workflow Medical data tests prueft Aufbau, Zuordnungen, doppelte Zuordnungen, Fremdschluessel, leere Bezeichnungen und Loeschschutz sowie bisherige Tests als Regression. Ein erfolgreicher Lauf ist noch nachzuweisen; nicht alle moeglichen Faelle sind abgedeckt.
