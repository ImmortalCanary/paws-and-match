BEGIN;
CREATE TABLE traegerorganisation (
    organisation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kuerzel VARCHAR(40) NOT NULL UNIQUE CHECK (btrim(kuerzel) <> ''),
    name VARCHAR(150) NOT NULL CHECK (btrim(name) <> '')
);
ALTER TABLE tierheim
    ADD COLUMN organisation_id INTEGER REFERENCES traegerorganisation(organisation_id),
    ADD COLUMN strasse VARCHAR(150),
    ADD COLUMN hausnummer VARCHAR(20),
    ADD COLUMN plz VARCHAR(5) CHECK (plz ~ '^[0-9]{5}$'),
    ADD COLUMN telefon VARCHAR(40),
    ADD COLUMN email VARCHAR(254);
CREATE INDEX idx_tierheim_organisation ON tierheim(organisation_id);
CREATE VIEW standort_uebersicht AS
SELECT h.tierheim_id, h.name AS standort, h.ort, h.strasse, h.hausnummer,
       h.plz, h.telefon, h.email, o.organisation_id, o.name AS traeger,
       count(t.tier_id) AS tiere_gesamt,
       count(t.tier_id) FILTER (WHERE t.status='verfuegbar') AS verfuegbar
FROM tierheim h
LEFT JOIN traegerorganisation o ON o.organisation_id=h.organisation_id
LEFT JOIN tier t ON t.tierheim_id=h.tierheim_id
GROUP BY h.tierheim_id, o.organisation_id;
COMMIT;
