BEGIN;
CREATE TABLE medizinisches_merkmal (
    merkmal_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bezeichnung VARCHAR(150) NOT NULL UNIQUE CHECK (btrim(bezeichnung) <> ''),
    beschreibung TEXT
);
CREATE TABLE tier_medizinisches_merkmal (
    tier_id INTEGER NOT NULL REFERENCES tier(tier_id),
    merkmal_id INTEGER NOT NULL REFERENCES medizinisches_merkmal(merkmal_id),
    erfasst_am DATE NOT NULL DEFAULT CURRENT_DATE,
    hinweis TEXT,
    PRIMARY KEY (tier_id, merkmal_id)
);
CREATE INDEX idx_tier_medizin_merkmal ON tier_medizinisches_merkmal(merkmal_id);
CREATE VIEW tier_medizin_uebersicht AS
SELECT t.tier_id, t.name AS tiername, h.name AS tierheim,
       m.merkmal_id, m.bezeichnung, z.erfasst_am, z.hinweis
FROM tier t
JOIN tierheim h ON h.tierheim_id=t.tierheim_id
JOIN tier_medizinisches_merkmal z ON z.tier_id=t.tier_id
JOIN medizinisches_merkmal m ON m.merkmal_id=z.merkmal_id;
COMMIT;
