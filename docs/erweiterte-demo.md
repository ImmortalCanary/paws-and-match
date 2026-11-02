# Mehrere Standorte und Tiere

Alle Angaben sind fiktive Projektdaten. Der Erweiterungsstand liegt im Branch feature/matching-v2 und ergaenzt damit auch Pull Request 1. main wird nicht veraendert.

Nach Basisschema, urspruenglicher Demo und Migrationen 006/007 wird 008 einmalig ausgefuehrt. Auf einer frischen Basisdemo entstehen insgesamt vier Tierheimstandorte, 15 Tiere und fuenf Interessenten. Jeder neue Standort erhaelt vier Tiere. Zwei der zwoelf neuen Tiere sind reserviert beziehungsweise vermittelt. Das Matching liefert 65 Kombinationen: 13 verfuegbare Tiere mal fuenf Interessenten.

## Standorte

- Bestehend: Demo-Tierheim Paws, Berlin, drei Tiere.
- Neu: Demo Paws Nord, Berlin, vier Tiere.
- Neu: Demo Paws Sued, Potsdam, vier Tiere.
- Neu: Demo Paws West, Brandenburg an der Havel, vier Tiere.

Ein tierheim-Datensatz steht derzeit fuer einen eigenstaendigen Standort. Eine uebergeordnete Traegerorganisation mit mehreren Niederlassungen, Standortwechsel-Historie, Adressen und Mitarbeiterzuordnungen sind noch nicht modelliert. Diese Erweiterung ist ein groesserer Demo-Datenbestand, keine komplette produktionsreife Plattform.

Zeitbedarf und Monatskosten sind ausschliesslich erfundene Testwerte, keine Empfehlungen zur Tierhaltung. Alle neuen Geburtsdaten sind als geschaetzt markiert. Medizinische Angaben werden nicht erfunden. Vorhandene Datensaetze werden nicht ueberschrieben; die alten Tiere und Anna behalten unbekannte neue Matching-Angaben.

## Lokal laden

Im aktuellen Entwicklungsbranch bei laufendem Docker und bereits angewendeten Migrationen:

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/seeds/008_erweiterte_demo.sql
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/009_standort_matching.sql
```

Die Erweiterung ist optional und wird nicht automatisch durch Compose geladen. Nicht wiederholt laden. Existiert bereits ein neuer Standortname, bricht sie vor dem Einfuegen ab. Andere bestehende Daten koennen dazu fuehren, dass die festen Testanzahlen nicht stimmen. Fuer Produktionsdaten ist dieses Seed-Skript nicht gedacht.

## Tests

Extended demo tests baut eine eigene frische Datenbank auf und prueft Standort-/Tier-/Interessentenzahlen, Tierverteilung, Matching-Menge und drei konkrete Kombinationen. Die Standortabfragen werden zusaetzlich auf fehlerfreie Ausfuehrung geprueft. Erfolgreiche Ausfuehrung ist noch nicht nachgewiesen.

Die bisherigen Tests 001_tests.sql und expected_matching.csv erwarten die kleine Basisdemo. Sie sind nach dauerhaftem Laden von 008 lokal nicht mehr unveraendert anwendbar. Die bisherigen Workflows bleiben deshalb bei ihren getrennten frischen Basisdatenbanken. Die neue Testdatei ist database/tests/004_erweiterte_demo.sql.
