-- Nur fiktive Projektdaten. Nach Basisschema und Migrationen 006/007 einmalig ausfuehren.
BEGIN;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM tierheim WHERE name IN ('Demo Paws Nord', 'Demo Paws Sued', 'Demo Paws West')) THEN
        RAISE EXCEPTION 'Erweiterte Demo bereits vorhanden oder Namenskonflikt; keine Daten eingefuegt';
    END IF;
END $$;

WITH standorte AS (
    INSERT INTO tierheim(name, ort)
    VALUES ('Demo Paws Nord', 'Berlin'), ('Demo Paws Sued', 'Potsdam'), ('Demo Paws West', 'Brandenburg an der Havel')
    RETURNING tierheim_id, name
)
INSERT INTO tier(tierheim_id, name, tierart, geburtsdatum, geburtsdatum_geschaetzt, status,
                 kinder_vertraeglich, katzen_vertraeglich, braucht_treppenfrei, max_allein_stunden,
                 hunde_vertraeglich, braucht_erfahrung, betreuungsbedarf_min, monatskosten_eur)
SELECT s.tierheim_id, d.tiername, d.art, d.geburt::date, TRUE, d.status,
       d.kinder, d.katzen, d.treppenfrei, d.allein, d.hunde, d.erfahrung, d.minuten, d.kosten
FROM standorte s
JOIN (VALUES
    ('Demo Paws Nord','Bella','Hund','2021-04-12','verfuegbar',TRUE,TRUE,FALSE,4,TRUE,FALSE,120,150),
    ('Demo Paws Nord','Rocky','Hund','2019-09-02','verfuegbar',FALSE,FALSE,FALSE,3,FALSE,TRUE,180,200),
    ('Demo Paws Nord','Mimi','Katze','2022-02-18','verfuegbar',TRUE,TRUE,FALSE,8,TRUE,FALSE,60,90),
    ('Demo Paws Nord','Oscar','Katze','2020-06-03','reserviert',TRUE,FALSE,FALSE,6,FALSE,FALSE,60,100),
    ('Demo Paws Sued','Nala','Hund','2017-01-20','verfuegbar',TRUE,TRUE,TRUE,4,TRUE,TRUE,90,220),
    ('Demo Paws Sued','Leo','Katze','2023-05-10','verfuegbar',NULL,TRUE,FALSE,6,NULL,FALSE,90,110),
    ('Demo Paws Sued','Frieda','Hund','2020-10-08','verfuegbar',TRUE,FALSE,FALSE,5,TRUE,FALSE,150,160),
    ('Demo Paws Sued','Coco','Katze','2021-08-15','vermittelt',TRUE,TRUE,FALSE,8,TRUE,FALSE,60,80),
    ('Demo Paws West','Sam','Hund','2022-03-24','verfuegbar',TRUE,TRUE,FALSE,4,TRUE,FALSE,120,140),
    ('Demo Paws West','Lilly','Katze','2018-11-09','verfuegbar',FALSE,FALSE,TRUE,6,FALSE,TRUE,90,180),
    ('Demo Paws West','Bruno','Hund','2016-07-07','verfuegbar',TRUE,TRUE,TRUE,3,TRUE,TRUE,120,250),
    ('Demo Paws West','Pepe','Katze','2024-01-30','verfuegbar',TRUE,TRUE,FALSE,5,TRUE,FALSE,90,100)
) AS d(standort,tiername,art,geburt,status,kinder,katzen,treppenfrei,allein,hunde,erfahrung,minuten,kosten)
ON d.standort=s.name;

INSERT INTO interessent(vorname,nachname,kinder_im_haushalt,katzen_im_haushalt,zugang_treppenfrei,allein_stunden,
                       hunde_im_haushalt,tiererfahrung,betreuungszeit_min,monatsbudget_eur)
VALUES
('Mara','Demo-Nord',FALSE,FALSE,TRUE,2,FALSE,TRUE,240,300),
('Jonas','Demo-Sued',TRUE,TRUE,FALSE,5,FALSE,FALSE,90,120),
('Elena','Demo-West',FALSE,FALSE,FALSE,3,TRUE,TRUE,180,200),
('David','Demo-Offen',NULL,FALSE,TRUE,4,FALSE,NULL,NULL,180);
COMMIT;
