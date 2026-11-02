-- Ausschliesslich fiktive Beispieldaten. Nach 001_schema.sql einmalig ausfuehren.
BEGIN;
INSERT INTO tierheim (name, ort) VALUES ('Demo-Tierheim Paws', 'Berlin');
INSERT INTO tier (tierheim_id, name, tierart, kinder_vertraeglich, katzen_vertraeglich, braucht_treppenfrei, max_allein_stunden)
SELECT tierheim_id, 'Balu', 'Hund', TRUE, FALSE, TRUE, 4 FROM tierheim WHERE name = 'Demo-Tierheim Paws';
INSERT INTO tier (tierheim_id, name, tierart, kinder_vertraeglich, katzen_vertraeglich, braucht_treppenfrei, max_allein_stunden)
SELECT tierheim_id, 'Luna', 'Katze', TRUE, TRUE, FALSE, 8 FROM tierheim WHERE name = 'Demo-Tierheim Paws';
INSERT INTO tier (tierheim_id, name, tierart, kinder_vertraeglich, katzen_vertraeglich, braucht_treppenfrei, max_allein_stunden)
SELECT tierheim_id, 'Milo', 'Hund', NULL, TRUE, FALSE, 6 FROM tierheim WHERE name = 'Demo-Tierheim Paws';
INSERT INTO interessent (vorname, nachname, kinder_im_haushalt, katzen_im_haushalt, zugang_treppenfrei, allein_stunden)
VALUES ('Anna', 'Demoperson', TRUE, TRUE, FALSE, 5);
-- Erwartung fuer Anna: Balu ausgeschlossen, Luna grundsaetzlich passend, Milo manuell pruefen.
COMMIT;
