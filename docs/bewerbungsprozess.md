# Bewerbungsprozess - erster Ausbauschritt

Entwicklungsbranch feature/vermittlungsprozess. Diese Erweiterung ist noch nicht nach main uebernommen.

## Regeln

Neue Bewerbungen starten mit offen. Erlaubt sind offen -> in_pruefung, abgelehnt oder zurueckgezogen sowie in_pruefung -> angenommen, abgelehnt oder zurueckgezogen. Gleicher Status ist erlaubt und erzeugt keinen zusaetzlichen Historieneintrag. Abgelehnt, zurueckgezogen und angenommen sind in dieser Version Endzustaende. Jede erneute Bewerbung nach Ablehnung oder Rueckzug erhaelt eine neue ID. Solange eine offene, gepruefte oder angenommene Bewerbung desselben Paars existiert, verhindert ein eindeutiger partieller Index eine weitere aktive Bewerbung dieses Paars.

Die bisherige globale Paar-Eindeutigkeit wird ersetzt; vorhandene Bewerbungen bleiben erhalten. Tier, Interessent, Bewerbungs-ID und Erstellungszeit einer Bewerbung duerfen nicht nachtraeglich umgebunden werden.

## Historie

Anlage und Statuswechsel werden ueber Trigger in derselben Transaktion protokolliert. Bestehende Bewerbungen erhalten einen expliziten Bestandsuebernahme-Eintrag mit dem Migrationszeitpunkt; unbekannte fruehere Wechsel werden nicht erfunden. datenbank_benutzer bezeichnet session_user und ist kein zuverlaessiger Nachweis des tatsaechlichen Mitarbeiters hinter einem gemeinsamen Anwendungskonto.

Die Historie ist noch kein manipulationssicheres Audit-System. Datenbankeigner und Superuser besitzen weiterhin weitreichende Rechte. Berechtigungen und Mitarbeiterzuordnung folgen spaeter. Die Historien-Fremdschluessel verhindern einfaches Loeschen bereits protokollierter Bewerbungen; ein fachliches Loesch-/Anonymisierungskonzept ist noch erforderlich.

## Migration und Tests

Migration 012 genau einmal auf dem bisherigen Schema anwenden. Sie wird weder von Compose noch vom bestehenden build_demo.sql automatisch geladen. Der eigene Workflow Application process tests baut den bisherigen Stand auf, wendet die Migration an und fuehrt die neuen Tests aus. Erfolgreiche Ausfuehrung muss nach dem Commit verifiziert werden.

## Bewusste Grenzen

Angenommen ist noch keine dokumentierte Adoption und veraendert den Tierstatus nicht. Mehrere Interessenten koennen daher noch angenommene Bewerbungen fuer dasselbe Tier besitzen. Exklusive Reservierungen, Vermittlung, Rueckgabe und der spaetere Abschluss angenommener Bewerbungen folgen in eigenen Migrationen. Insbesondere sind gleichzeitige Vermittlungsversuche noch nicht abgesichert. Der eindeutige Index schuetzt nur aktive Doppelbewerbungen desselben Paars; ein echter Mehrsitzungs-Konkurrenztest ist noch nicht Bestandteil dieses Schritts.
