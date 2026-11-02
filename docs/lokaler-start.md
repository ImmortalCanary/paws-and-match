# Datenbank lokal starten

## Voraussetzungen

Git und Docker mit Docker Compose muessen installiert sein. Docker muss laufen. Diese Umgebung ist fuer lokale Entwicklung mit fiktiven Daten gedacht, nicht fuer einen Produktivbetrieb.

## 1. Projekt holen

```bash
git clone https://github.com/ImmortalCanary/paws-and-match.git
cd paws-and-match
```

Wenn das Repository bereits lokal vorhanden ist, stattdessen im Projektordner `git pull` ausfuehren.

## 2. Passwort konfigurieren

Die Datei `.env.example` im Projektordner als `.env` kopieren. In `.env` hinter `POSTGRES_PASSWORD=` ein eigenes Passwort eintragen. Die Datei nicht committen oder teilen.

## 3. Starten

```bash
docker compose up -d --wait
```

Beim ersten Start mit leerem Datenvolume werden Schema und Demodaten automatisch geladen. Bei weiteren Starts bleiben die Daten erhalten. Aenderungen an den Initialisierungsskripten werden NICHT automatisch auf eine bestehende Datenbank angewendet.

## 4. Matching ausfuehren

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/003_matching.sql
```

Mit unveraenderten Demodaten erwartet: Balu ausgeschlossen, Luna grundsaetzlich passend, Milo manuell pruefen.

## 5. SQL selbst ausprobieren

```bash
docker compose exec db psql -U paws_user -d paws_match
```

Beispielabfragen:

```sql
SELECT * FROM tierheim;
SELECT tier_id, name, tierart, status FROM tier;
SELECT * FROM interessent;
```

Mit `\q` die SQL-Konsole verlassen. Alternativ in einem SQL-Client verbinden: Host `localhost`, Port `5433`, Datenbank `paws_match`, Benutzer `paws_user`, Passwort aus `.env`. Die Portfreigabe ist auf den lokalen Rechner begrenzt.

## 6. Constraint-Tests ausfuehren

```bash
docker compose exec db psql -X -v ON_ERROR_STOP=1 -U paws_user -d paws_match -f /workspace/database/tests/001_tests.sql
```

Diese Tests setzen die unveraenderten Demodaten voraus. Sie pruefen Datenanzahlen und ausgewaehlte Constraints. Testaenderungen werden zurueckgerollt; automatisch erzeugte ID-Sequenzen koennen trotzdem weiterzaehlen. Der exakte CSV-Matchingvergleich erfolgt im GitHub-Actions-Workflow.

## Stoppen und spaeter weiterarbeiten

```bash
docker compose down
docker compose up -d --wait
```

`docker compose down` behaelt das Datenvolume. Fuer diesen normalen Neustart ist kein erneutes Einspielen des Schemas erforderlich.

## Vollstaendiger Reset - nur bewusst ausfuehren

WARNUNG: Der folgende Befehl loescht das Datenvolume dieser Compose-Umgebung und damit alle darin gespeicherten Daten unwiderruflich. Vorher benoetigte Daten sichern.

```bash
docker compose down --volumes
docker compose up -d --wait
```

Danach werden Schema und Demodaten neu geladen. Diese Anleitung und Konfiguration wurden vorbereitet; ein erfolgreicher lokaler Docker-Test ist noch nicht nachgewiesen.
