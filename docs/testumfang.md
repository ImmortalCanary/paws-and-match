# Automatischer Testumfang

Der Workflow Database tests erstellt fuer jeden Lauf eine frische PostgreSQL-17-Datenbank. Er startet bei Push, Pull Request oder manuell. Ein erfolgreicher Lauf ist im Actions-Tab zu pruefen; die Existenz dieser Dateien allein ist kein Testergebnis.

## Pruefschritte

1. Schema erstellen und fiktive Demodaten laden.
2. Demo-Datenanzahlen sowie ausgewaehlte Fremdschluessel-, Eindeutigkeits- und Wertepruefungen testen.
3. Ausgabe der tatsaechlichen Matching-Abfrage exakt mit expected_matching.csv vergleichen.
4. Alle vier Auswertungen aus 004_auswertungen.sql ausfuehren. Dies ist ein Ausfuehrungstest, kein vollstaendiger Ergebnisvergleich.
5. 005_bewerbung_demo.sql ausfuehren. Die CSV-Ausgabe muss genau eine Datenzeile fuer Luna, Anna und den Status in_pruefung enthalten. Die dynamische Bewerbungs-ID darf variieren.
6. Nach dem Demo-Rollback muss die Bewerbungstabelle leer sein.
7. Demo-Daten und Constraints erneut pruefen und Matching erneut mit den erwarteten Ergebnissen vergleichen.

SQL-Fehler und fehlgeschlagene Vergleiche brechen den jeweiligen Schritt ab. ID-Sequenzen koennen trotz zurueckgerollter Aenderungen weiterzaehlen; deshalb wird fuer die Demo keine feste Bewerbungs-ID erwartet.

## Grenzen

Noch nicht abgedeckt sind alle NULL-Kombinationen, Stunden-Grenzwerte, parallele Bewerbungen, verbindliche Statusuebergaenge sowie ein vollstaendiger Soll-Ist-Vergleich der Auswertungen. Der Workflow testet auch nicht den lokalen Docker-Compose-Start. Die Datenbank bleibt ein Lernprototyp, keine produktionsreife Vermittlungsplattform.

Diese Beschreibung ersetzt den frueheren Hinweis in docs/sql-beispiele.md, dass die Dateien 004 und 005 noch nicht im Workflow ausgefuehrt werden. Die Beispiele bleiben optional und werden weiterhin nicht beim lokalen Docker-Start automatisch geladen.
