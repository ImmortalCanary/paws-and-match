# Uebung 1: Datenbankzugriff mit Java und JDBC

Die Loesung verwendet die vorhandenen Tabellen tier und tierheim aus Paws & Match. Sie legt keine zweite fachliche Datenbankstruktur an. Verbindung, SQL-Abfrage, ResultSet-Verarbeitung, Schreiben und Transaktionen sind in src/main/java/de/pawsmatch/JdbcUebung.java implementiert.

## Aufgabe und Loesung

1. Daten via JDBC abrufen: DriverManager.getConnection verbindet Java mit einer laufenden PostgreSQL-Datenbank. Ein PreparedStatement liest Tiere mit zugehoerigem Tierheim; der Status ist ein gebundener Parameter.
2. ResultSet verarbeiten: next() geht durch die Zeilen. getInt/getString lesen Werte, die als Tier-Objekte in einer List<Tier> gesammelt und ausgegeben werden. Die Liste kann nach dem Schliessen des ResultSets weiterverarbeitet werden.
3. Daten zurueckschreiben: INSERT ... RETURNING legt einen fiktiven Teststandort an und liefert seine ID. UPDATE mit executeUpdate aendert den Ort und liefert die Zahl betroffener Zeilen. Ein SELECT liest die Aenderung innerhalb derselben Transaktion zurueck.
4. Transaktion: Die Schreibdemo verwendet setAutoCommit(false) und immer rollback(). Danach prueft sie, dass der Teststandort nicht mehr vorhanden ist. Bestehende Zeilen werden nicht veraendert. Identity-Sequenzen koennen dennoch weiterzaehlen; die Demo ist kein vollstaendig nebenwirkungsfreier Lesezugriff. Dauerhaftes Speichern wuerde eine bewusst getrennte Implementierung mit commit() erfordern.
5. Ressourcen: Connection, PreparedStatement und ResultSet werden mit try-with-resources geschlossen. Fehler fuehren zu einem Fehlerexit statt einer Erfolgsmeldung.

## Direkt ueber GitHub ausfuehren

Der Workflow JDBC exercise startet bei Push/PR oder manuell. Er baut eine temporaere PostgreSQL-Datenbank mit dem bestehenden database/build_demo.sql auf, kompiliert Java, fuehrt einen echten JDBC-Integrationstest und die gepackte Anwendung aus. Danach prueft er den erhaltenen Demodatenbestand.

Erst ein erfolgreicher Workflow bestaetigt die Ausfuehrung. Die Ausgabe steht im Schritt Run packaged exercise against PostgreSQL. Nach erfolgreichem Lauf ist fuer sieben Tage das Artefakt paws-match-jdbc mit der ausfuehrbaren JAR verfuegbar. Diese braucht zum lokalen Start Java ab Version 17 und eine erreichbare PostgreSQL-Datenbank. Das Artefakt ist keine eigenstaendige Datenbank und enthaelt keine Zugangsdaten.

Die CI-Verbindung nutzt eine frische Instanz eures vorhandenen Schemas mit fiktiven Demodaten, nicht euren privaten lokalen Datenbankserver. GitHub kann nicht ueber localhost auf deinen Laptop zugreifen. Die Anwendung kann lokal denselben bestehenden Datenbestand verwenden, sobald sie dort mit dessen Verbindungsdaten gestartet wird.

## Lokal starten

Voraussetzungen: JDK ab 17, fuer den Eigenbau Maven, laufendes PostgreSQL und vorhandenes Schema. Das Java-Programm selbst spielt keine SQL-Migrationen ein. Fuer den Basisabruf genuegen tier und tierheim; der volle Gesamtdemoaufbau ist nur fuer den CI-Test erforderlich.

IntelliJ: jdbc-uebung/pom.xml als Maven-Projekt oeffnen, Abhaengigkeiten laden und die Main-Klasse de.pawsmatch.JdbcUebung starten. In der Run-Konfiguration DB_URL, DB_USER und DB_PASSWORD als Umgebungsvariablen setzen. Eine .env-Datei wird vom Java-Programm NICHT automatisch gelesen.

Beispiel fuer direkt installiertes PostgreSQL unter Windows PowerShell, Datenbankname und Port bei Bedarf anpassen:

```powershell
$env:DB_URL = 'jdbc:postgresql://localhost:5432/paws_match'
$env:DB_USER = 'postgres'
# Passwort lokal eingeben; nicht in Chat, Git oder Screenshots teilen.
$env:DB_PASSWORD = Read-Host 'Lokales Datenbankpasswort' -MaskInput
mvn -f jdbc-uebung/pom.xml clean package
java -jar jdbc-uebung/target/paws-match-jdbc.jar
```

Read-Host -MaskInput benoetigt PowerShell 7.1 oder neuer. Unter Windows PowerShell 5.1 stattdessen die Umgebungsvariablen in der IntelliJ-Run-Konfiguration eintragen. Bei unserer Compose-Konfiguration ist die URL jdbc:postgresql://localhost:5433/paws_match, Benutzer paws_user und Passwort aus eurer lokalen .env.

Lokale Integrationstests werden standardmaessig uebersprungen. Nur auf einer separaten frischen Gesamtdemo JDBC_INTEGRATION_TEST=true setzen und mvn -f jdbc-uebung/pom.xml verify ausfuehren. Der Integrationstest erwartet 13 verfuegbare Tiere, nicht beliebige Echtdaten. Die normale Anwendung funktioniert auch mit anderen Datenmengen und zeigt bei leerem Ergebnis null Tiere an.

## Sicherheit und Umfang

Keine echten Zugangsdaten committen. Das CI-Passwort gilt nur fuer den temporaeren Testdienst. Lokaler Benutzer braucht SELECT auf tier/tierheim sowie fuer die Schreibdemo INSERT/UPDATE auf tierheim und benoetigte Sequenzrechte. Keine Superuser-Rechte fuer spaetere Anwendungen vorsehen. Auf echten Produktivsystemen die Schreibdemo nicht ohne ausdrueckliche Freigabe ausfuehren.

Dies ergaenzt ausschliesslich die JDBC-Uebung. Bestehende SQL-Dateien und Datenbankfunktionen werden nicht ersetzt. Eine erfolgreiche lokale Verbindung ist erst nach Ausfuehrung auf eurem Rechner nachgewiesen; der GitHub-Test beweist die Anbindung an eine temporaere Instanz desselben Schemas.
