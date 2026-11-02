-- Erwartet frische Basisdemo plus Erweiterung 008, keine weiteren Daten.
DO $$
BEGIN
    IF (SELECT count(*) FROM tierheim) <> 4 OR (SELECT count(*) FROM tier) <> 15
       OR (SELECT count(*) FROM interessent) <> 5 THEN
        RAISE EXCEPTION 'Erwartet: vier Standorte, 15 Tiere, fuenf Interessenten';
    END IF;
    IF EXISTS (
        SELECT h.tierheim_id FROM tierheim h LEFT JOIN tier t ON t.tierheim_id=h.tierheim_id
        WHERE h.name IN ('Demo Paws Nord','Demo Paws Sued','Demo Paws West')
        GROUP BY h.tierheim_id HAVING count(t.tier_id) <> 4
    ) THEN RAISE EXCEPTION 'Je neuem Standort vier Tiere erwartet'; END IF;
    IF (SELECT count(*) FROM matching_v2) <> 65 THEN
        RAISE EXCEPTION '13 verfuegbare Tiere mal fuenf Interessenten erwartet';
    END IF;
    IF EXISTS (SELECT 1 FROM matching_v2 m JOIN tier t ON t.tier_id=m.tier_id WHERE t.status <> 'verfuegbar') THEN
        RAISE EXCEPTION 'Nicht verfuegbares Tier im Matching';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM matching_v2 m JOIN interessent i ON i.interessent_id=m.interessent_id
        WHERE i.vorname='Mara' AND i.nachname='Demo-Nord' AND m.tiername='Bella' AND m.ergebnis='grundsaetzlich passend'
    ) THEN RAISE EXCEPTION 'Mara und Bella sollten passen'; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM matching_v2 m JOIN interessent i ON i.interessent_id=m.interessent_id
        WHERE i.vorname='Jonas' AND i.nachname='Demo-Sued' AND m.tiername='Rocky' AND m.ergebnis='ausgeschlossen'
    ) THEN RAISE EXCEPTION 'Jonas und Rocky sollten ausgeschlossen sein'; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM matching_v2 m JOIN interessent i ON i.interessent_id=m.interessent_id
        WHERE i.vorname='David' AND i.nachname='Demo-Offen' AND m.tiername='Bella' AND m.ergebnis='manuell pruefen'
    ) THEN RAISE EXCEPTION 'David und Bella sollten manuell geprueft werden'; END IF;
END $$;
