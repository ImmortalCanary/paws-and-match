# Paws & Match

PostgreSQL-Studienprototyp fuer standortuebergreifendes Tierheim-Matching. Alle Beispieldaten sind fiktiv. Vorlesungsunterlagen werden nicht veroeffentlicht.

## Umfang

- Sieben Tabellen fuer Traegerorganisationen, Standorte, Tiere, Interessenten, Bewerbungen und medizinische Merkmale samt Zuordnung.
- Vier Views fuer erklaerbares Matching, Einzelkriterien, medizinische Zuordnungen und Standortuebersicht.
- Acht Matching-Kriterien: Kinder, Katzen, Hunde, Treppenzugang, Alleinbleibedauer, Erfahrung, Betreuungszeit und Budget.
- Gesamtdemo mit zwei Traegern, vier Standorten, 15 Tieren und fuenf Interessenten. 13 verfuegbare Tiere ergeben 65 bewertete Kombinationen.
- Bewerbungsbeispiel, SQL-Auswertungen, Constraint-Tests und GitHub-Actions-Workflows.

Die grosse Demo enthaelt keine dauerhaft gespeicherten Bewerbungen oder medizinischen Zuordnungen; diese werden mit isolierten zurueckgerollten Testdaten geprueft. Neue Matching-Angaben der urspruenglichen kleinen Demo bleiben bewusst unbekannt.

## Direkt auf GitHub pruefen

Full database tests baut den gesamten Stand in einer frischen PostgreSQL-17-Datenbank auf und fuehrt die Tests in passender Reihenfolge aus. Anschliessend exportiert er die Datenbank, stellt sie in einer zweiten Datenbank wieder her und vergleicht Matching und Standortuebersicht mit dem Original. SQL-Fehler und abweichende Vergleiche lassen den Lauf fehlschlagen.

Die Workflows laufen bei Push und Pull Request. Ein erfolgreicher Lauf muss fuer den jeweiligen aktuellen Commit anhand der Checks bestaetigt werden. Fruehere gruene Laeufe bestaetigen keine spaeteren Aenderungen. Ein gruener Lauf ist keine umfassende Produktionsfreigabe.

Diese Umgebung ist temporaer und kein dauerhaft erreichbarer Datenbankserver. Fuer Entwicklung und Pruefung auf GitHub ist keine lokale Installation erforderlich. CI-Zugangsdaten gelten nur fuer diese kurzlebigen Testdienste.

## Ein zentraler Aufbau

Mit vorhandenem PostgreSQL und psql auf einer separaten leeren Datenbank:

```bash
psql -X -v ON_ERROR_STOP=1 -d paws_match -f database/build_demo.sql
```

Das Skript erstellt keine Datenbank. Es verweigert den Start, wenn public bereits Tabellen, Views oder Sequenzen enthaelt. Es darf NICHT auf der bereits initialisierten Docker-Datenbank ausgefuehrt werden. Der Aufbau ist nicht als Ganzes atomar: Bei einem spaeteren Fehler koennen fruehere Schritte bereits committed sein. In CI wird die kurzlebige Datenbank verworfen; bei lokaler Nutzung Fehler gezielt beheben oder eine neue separate leere Testdatenbank verwenden. Keine vorhandenen Daten loeschen.

## Bestehende lokale Docker-Datenbank aktualisieren

Compose initialisiert weiterhin nur das Basisschema und die kleine Demo. Bereits angewendete Dateien nicht erneut ausfuehren. Fuer den erweiterten Stand fehlende Schritte in dieser Reihenfolge anwenden:

1. database/migrations/006_matching_v2.sql
2. database/migrations/007_medizinische_merkmale.sql
3. Optional database/seeds/008_erweiterte_demo.sql
4. database/migrations/010_organisationen.sql
5. Optional database/seeds/011_organisationen_demo.sql; benoetigt Basisdemo und 008.

Alle Migrationen und Seeds sind einmalig, nicht idempotent. Die Nummern spiegeln Projektentwicklung wider; 009 ist eine lesende Abfrage und kein Schema-Update. Keine Dateien blind nach Nummer automatisch ausfuehren. Docker Compose wendet die Erweiterungen nicht automatisch an. Siehe docs/lokaler-start.md und die jeweilige Moduldokumentation.

## Ergebnisse ansehen

```sql
SELECT * FROM matching_v2 ORDER BY interessent_id, tier_id;
SELECT * FROM matching_v2_details ORDER BY interessent_id, tier_id, kriterium;
SELECT * FROM standort_uebersicht ORDER BY organisation_id, tierheim_id;
SELECT * FROM tier_medizin_uebersicht ORDER BY tier_id, merkmal_id;
```

## Testdaten beachten

Die Basistests 001_tests.sql und expected_matching.csv erwarten nur die kleine Demo. build_demo.sql fuehrt diese deshalb VOR den groesseren Seeds aus. Danach pruefen 004_erweiterte_demo.sql und 005_organisationen.sql die Gesamtdemo. Die Tests fuer Matching und medizinische Merkmale erzeugen eigene Daten und rollen sie zurueck; ID-Sequenzen koennen weiterzaehlen.

## Dokumentation und Grenzen

- docs/datenmodell.md: Tabellen, Beziehungen und Grenzen.
- docs/matching-v2.md: Matching-Regeln und Migration.
- docs/medizinische-merkmale.md: strukturierte medizinische Angaben.
- docs/erweiterte-demo.md: mehrere Standorte und Tiere.
- docs/organisationen.md: Traeger und Standortdaten.

Diese README und das Datenmodell beschreiben den aktuellen Entwicklungsumfang und gehen aelteren Hinweisen vor, die Traegerorganisationen noch als offen beschreiben. Entwicklungsstand: feature/matching-v2, Uebernahme nach main nur durch gesondert freigegebenes Merge.

Abgeschlossen wird der bisher vereinbarte Datenbank-Prototyp, nicht eine produktionsreife Vermittlungsplattform. Adoptionsvertraege, Rueckgaben, verbindliche Bewerbungsstatusuebergaenge, Mitarbeiter, Zugriffsschutz, Anwendung und dauerhafter Betrieb sind noch nicht implementiert. Fachliche Regeln, insbesondere Budget- und Zeitgrenzen, sind vereinfachte Projektannahmen und keine allgemeingueltigen Tierhaltungsvorgaben. Keine echten Personen- oder Zugangsdaten committen.
