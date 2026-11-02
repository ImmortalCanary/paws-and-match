# Traeger und Tierheimstandorte

Die neue Tabelle traegerorganisation trennt den Betreiber von seinen Standorten. tierheim bleibt aus Kompatibilitaetsgruenden der technische Tabellenname fuer einen Standort. Bestehende IDs, Tierzuordnungen und Matching-Views bleiben erhalten.

## Beziehungen

Eine Organisation kann null bis viele Standorte haben. Ein Standort gehoert zu hoechstens einer Organisation; organisation_id darf waehrend der Datenerfassung unbekannt bleiben. Die Demo ordnet Nord, Sued und West einem gemeinsamen Verbund zu; der Basisstandort gehoert einem zweiten fiktiven Traeger. Diese Zuordnung ist eine Projektannahme, keine Aussage ueber echte Einrichtungen.

Strasse, Hausnummer, PLZ und Ort beschreiben den Standort. Telefon und E-Mail sind optional. Die PLZ-Pruefung kontrolliert nur fuenf Ziffern, nicht die Existenz oder Zuordnung zu einem Ort. Das aktuelle Format ist auf deutsche PLZ ausgerichtet. E-Mail und Telefonnummer werden noch nicht umfassend validiert. Die Demo verwendet ausdruecklich fiktive Strassen und E-Mail-Adressen und keine Telefonnummern.

## Reihenfolge

Nach 001, 002 und Migrationen 006/007 sowie optionalem Demo-Skript 008:

1. Migration database/migrations/010_organisationen.sql genau einmal ausfuehren. Sie ergaenzt nur das Schema und kann auch ohne erweiterte Demo angewendet werden.
2. Optional database/seeds/011_organisationen_demo.sql genau einmal laden. Dieses Skript erwartet alle vier Demo-Standorte aus Basisdemo und 008 und verweigert das Ueberschreiben bestehender Organisations-/Kontaktdaten.

Nummer 009 ist eine lesende Abfragedatei, keine Migration. Seeds sind keine automatisch angewendeten Schemaaenderungen. Docker Compose wendet die neuen Dateien nicht automatisch an. Es ist kein Loeschen des Datenvolumes erforderlich.

## Abfragen

```sql
SELECT * FROM standort_uebersicht ORDER BY organisation_id, tierheim_id;
SELECT o.name, count(h.tierheim_id) AS standorte
FROM traegerorganisation o
LEFT JOIN tierheim h ON h.organisation_id=o.organisation_id
GROUP BY o.organisation_id, o.name;
```

Die Standortview zeigt auch Standorte ohne Tiere oder bekannten Traeger. Eine referenzierte Organisation kann nicht einfach geloescht werden; zuvor muessen ihre Standorte bewusst neu zugeordnet oder die Zuordnungen entfernt werden.

## Tests und Grenzen

Organisation tests baut eine frische Datenbank mit allen benoetigten Erweiterungen auf. Geprueft werden zwei Traeger, drei Verbundstandorte, Tieranzahlen, unveraenderte Matching-Menge, ungueltige Fremdschluessel, PLZ-Format, Loeschschutz und leere Standorte. Erfolgreiche Ausfuehrung muss nach dem Commit anhand der Checks verifiziert werden.

Dieser Stand ergaenzt beziehungsweise ersetzt die fruehere Dokumentationsaussage, dass Traegerorganisationen noch nicht modelliert seien. Standortwechsel-Historie, Mitarbeiter und Zugriffsrechte sind weiterhin offen. Der Entwicklungsstand liegt auf feature/matching-v2 und wird nicht automatisch nach main uebernommen.
