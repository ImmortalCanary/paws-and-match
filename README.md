# Paws & Match

Relationale Tierheim-Tier-Matching-Datenbank als Studienprojekt.

## Aktueller Umfang

PostgreSQL-Prototyp mit den Tabellen tierheim, tier, interessent und bewerbung. Das Matching prueft Kindervertraeglichkeit, Katzenvertraeglichkeit, Treppenzugang und Alleinbleibedauer. NULL bedeutet unbekannt. Die Regeln sind vereinfachte Projektannahmen und ersetzen keine Vermittlungsentscheidung durch das Tierheim.

## Dateien und Ausfuehrungsreihenfolge

1. database/001_schema.sql: Tabellen in einer leeren PostgreSQL-Datenbank erstellen.
2. database/002_demo_data.sql: ausschliesslich fiktive Beispieldaten laden.
3. database/003_matching.sql: Ergebnisse berechnen.

Schema und Demodaten nur einmal pro leerer Datenbank ausfuehren. Die Matching-Abfrage kann wiederholt ausgefuehrt werden. Die SQL-Dateien erzeugen nicht selbst die Datenbank.

## Automatische Tests auf GitHub

Der Workflow Database tests startet bei Push, Pull Request oder manuell ueber den Actions-Tab. Er erstellt eine temporaere PostgreSQL-17-Testdatenbank, laedt Schema und Demodaten, prueft Constraints und vergleicht die Ausgabe der tatsaechlichen Matching-Abfrage mit database/tests/expected_matching.csv. SQL-Fehler oder abweichende Ergebnisse lassen den Lauf fehlschlagen.

Geprueft werden Demo-Datensatzanzahlen, eine gueltige Bewerbung, doppelte Bewerbungen, ein ungueltiger Tierverweis, ungueltige Stundenangaben und ein ungueltiger Tierstatus. Testaenderungen werden zurueckgerollt. Erwartet: Balu ausgeschlossen, Luna grundsaetzlich passend, Milo manuell pruefen.

Der Workflow ist keine dauerhaft gehostete Datenbank. Das CI-Passwort gilt ausschliesslich fuer den kurzlebigen lokalen Testdienst und darf nicht fuer echte Systeme verwendet werden. Keine echten personenbezogenen Daten oder produktiven Zugangsdaten committen.

Status: Testautomatisierung eingerichtet, erfolgreicher Lauf muss im Actions-Tab bestaetigt werden. Die Tests decken noch nicht alle Regeln und Grenzfaelle ab.

## Lokal mit vorhandenem PostgreSQL-Client

Eine leere Datenbank paws_match lokal erstellen und Verbindungsdaten ueber die PostgreSQL-Umgebungsvariablen konfigurieren. Danach:

```bash
psql -X -v ON_ERROR_STOP=1 -d paws_match -f database/001_schema.sql
psql -X -v ON_ERROR_STOP=1 -d paws_match -f database/002_demo_data.sql
psql -X -v ON_ERROR_STOP=1 -d paws_match -f database/003_matching.sql
psql -X -v ON_ERROR_STOP=1 -d paws_match -f database/tests/001_tests.sql
```

Die Tests setzen die unveraenderten Demodaten voraus. Keine Vorlesungsunterlagen werden in diesem Repository veroeffentlicht.
