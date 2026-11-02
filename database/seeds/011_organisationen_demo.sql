-- Fiktive Zuordnungen; setzt Basisdemo und erweiterte Demo 008 voraus.
BEGIN;
DO $$
BEGIN
    IF (SELECT count(*) FROM tierheim WHERE name IN ('Demo-Tierheim Paws','Demo Paws Nord','Demo Paws Sued','Demo Paws West')) <> 4 THEN
        RAISE EXCEPTION 'Genau vier erwartete Demo-Standorte erforderlich';
    END IF;
    IF EXISTS (SELECT 1 FROM traegerorganisation WHERE kuerzel IN ('DEMO-VERBUND','DEMO-EINZEL')) THEN
        RAISE EXCEPTION 'Organisationsdemo bereits vorhanden oder Kuerzel belegt';
    END IF;
    IF EXISTS (SELECT 1 FROM tierheim WHERE name IN ('Demo-Tierheim Paws','Demo Paws Nord','Demo Paws Sued','Demo Paws West') AND (organisation_id IS NOT NULL OR strasse IS NOT NULL OR hausnummer IS NOT NULL OR plz IS NOT NULL OR email IS NOT NULL OR telefon IS NOT NULL)) THEN
        RAISE EXCEPTION 'Vorhandene Organisations- oder Kontaktdaten werden nicht ueberschrieben';
    END IF;
END $$;
INSERT INTO traegerorganisation(kuerzel, name)
VALUES ('DEMO-VERBUND','Fiktiver Paws-Tierheimverbund'), ('DEMO-EINZEL','Fiktiver Paws-Einzeltraeger');
UPDATE tierheim h
SET organisation_id=o.organisation_id,
    strasse='Fiktive Beispielstrasse', hausnummer=d.hausnummer,
    plz=d.plz, email=d.email
FROM (VALUES
    ('Demo-Tierheim Paws','DEMO-EINZEL','1','10115','basis@example.invalid'),
    ('Demo Paws Nord','DEMO-VERBUND','2','13187','nord@example.invalid'),
    ('Demo Paws Sued','DEMO-VERBUND','3','14467','sued@example.invalid'),
    ('Demo Paws West','DEMO-VERBUND','4','14770','west@example.invalid')
) AS d(standort,kuerzel,hausnummer,plz,email)
JOIN traegerorganisation o ON o.kuerzel=d.kuerzel
WHERE h.name=d.standort;
COMMIT;
