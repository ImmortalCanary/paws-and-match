-- PostgreSQL. Einmalig in einer leeren Projektdatenbank ausfuehren.
BEGIN;
CREATE TABLE tierheim (
    tierheim_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    ort VARCHAR(100) NOT NULL
);
CREATE TABLE tier (
    tier_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tierheim_id INTEGER NOT NULL REFERENCES tierheim(tierheim_id),
    name VARCHAR(100) NOT NULL,
    tierart VARCHAR(20) NOT NULL CHECK (tierart IN ('Hund', 'Katze')),
    geburtsdatum DATE,
    geburtsdatum_geschaetzt BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'verfuegbar' CHECK (status IN ('verfuegbar', 'reserviert', 'vermittelt')),
    kinder_vertraeglich BOOLEAN,
    katzen_vertraeglich BOOLEAN,
    braucht_treppenfrei BOOLEAN,
    max_allein_stunden NUMERIC(4,2) CHECK (max_allein_stunden BETWEEN 0 AND 24),
    medizinische_hinweise TEXT
);
CREATE TABLE interessent (
    interessent_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vorname VARCHAR(100) NOT NULL,
    nachname VARCHAR(100) NOT NULL,
    kinder_im_haushalt BOOLEAN,
    katzen_im_haushalt BOOLEAN,
    zugang_treppenfrei BOOLEAN,
    allein_stunden NUMERIC(4,2) CHECK (allein_stunden BETWEEN 0 AND 24)
);
CREATE TABLE bewerbung (
    bewerbung_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tier_id INTEGER NOT NULL REFERENCES tier(tier_id),
    interessent_id INTEGER NOT NULL REFERENCES interessent(interessent_id),
    erstellt_am TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'offen' CHECK (status IN ('offen', 'in_pruefung', 'abgelehnt', 'zurueckgezogen', 'angenommen')),
    UNIQUE (tier_id, interessent_id)
);
-- Pro Tier und Interessent wird im Prototyp genau ein Bewerbungsvorgang gefuehrt.
-- NULL bei Matching-Merkmalen bedeutet unbekannt, nicht nein.
COMMIT;
