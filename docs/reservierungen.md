# Reservierungen - zweiter Prozessbaustein

Branch feature/vermittlungsprozess. Migration 013 setzt 012 voraus. Beide Migrationen werden noch nicht vom bisherigen Gesamtaufbau oder Compose automatisch geladen. Bestehende Datensaetze werden nicht automatisch reserviert und bestehende Tierstatuswerte bleiben erhalten.

## Regeln und Nutzung

Eine Reservierung gehoert zu genau einer Bewerbung und deren Tier. Ein zusammengesetzter Fremdschluessel verhindert abweichende Tierzuordnungen. Nur verfuegbare Tiere und Bewerbungen mit in_pruefung oder angenommen koennen reserviert werden. Ein partieller eindeutiger Index erlaubt hoechstens einen Datensatz mit Status aktiv pro Tier. Ein Trigger sperrt den Tierdatensatz und prueft die Voraussetzungen; dadurch werden konkurrierende Versuche serialisiert. Bei Erfolg wird der Tierstatus in derselben Transaktion reserviert.

```sql
-- Beispiel-IDs durch vorhandene IDs ersetzen.
SELECT reserviere_tier(42, clock_timestamp() + interval '2 days');
SELECT beende_reservierung(7);
SELECT verarbeite_abgelaufene_reservierungen();
```

42 bezeichnet eine Bewerbungs-ID, 7 eine Reservierungs-ID. Eine Laufzeit wird explizit gewaehlt, es gibt keine allgemeingueltige Standarddauer. Aufheben setzt den Status aufgehoben; die Ablaufverarbeitung setzt faellige aktive Datensaetze auf abgelaufen. Beide setzen beendet_am und geben das Tier frei. Zuordnung, Beginn und Endfrist sind unveraenderlich; fuer eine neue Frist wird die Reservierung beendet und neu angelegt. Beendete Reservierungen werden nicht wieder geoeffnet und nicht geloescht.

Die Ablaufverarbeitung muss spaeter regelmaessig durch die Anwendung oder einen geplanten Job aufgerufen werden. Ohne Aufruf bleibt ein faelliger Datensatz aktiv und das Tier reserviert. Das ist bewusst konservativ; Zeitablauf allein fuehrt keinen Datenbankbefehl aus. Parallele Ablaufverarbeiter ueberspringen bereits gesperrte Reservierungen.

Aktive Reservierungen verhindern das direkte Freigeben oder Vermitteln des Tieres und das Ablehnen beziehungsweise Zurueckziehen der betreffenden Bewerbung. Erst Reservierung beenden, dann Bewerbung abschliessen. Angenommen bleibt von einer tatsaechlichen Vermittlung getrennt.

## Tests und Grenzen

Reservation tests prueft Einzelablaeufe, ungueltige Voraussetzungen, Konsistenz, Aufhebung und Ablauf. Ein separates Bash-Skript startet zwei Datenbanksitzungen fuer unterschiedliche Bewerber desselben Tieres. Es erwartet genau einen Erfolg und einen fachlichen Konflikt, keine zweite aktive Reservierung. Das Konkurrenzskript erzeugt dauerhafte Testdatensaetze und darf nur in der kurzlebigen separaten CI-Datenbank laufen. Erfolgreiche Ausfuehrung ist erst nach einem geprueften Lauf bestaetigt.

Bei konkurrierenden Statusaenderungen und Reservierungen koennen durch unterschiedliche Sperrreihenfolgen Deadlocks auftreten. PostgreSQL bricht dann eine Transaktion ab; die Anwendung benoetigt spaeter begrenzte Wiederholungen fuer solche Transaktionsfehler. Der Test deckt nur das beschriebene Reservierungsrennen ab, nicht alle moeglichen Parallelablaeufe.

Legacy-Tiere mit Status reserviert werden nicht in Reservierungsdatensaetze umgewandelt; ohne bekannten Vorgang wird keine Bewerbung erfunden. Dieser Schritt erzwingt nicht generell, dass jeder manuell gesetzte Tierstatus reserviert einen Datensatz besitzt. Ein striktes Schreibrechte-/API-Konzept folgt spaeter. Datenbankeigner und Superuser koennen Schutzmechanismen weiterhin administrativ umgehen. Mitarbeiterzuordnung, manipulationssicheres Audit, Betriebsscheduler, Vermittlungsabschluss und Rueckgaben sind noch offen.
