BEGIN;
DO $$
DECLARE
    v_org INTEGER;
    v_standort INTEGER;
BEGIN
    IF (SELECT count(*) FROM traegerorganisation) <> 2 THEN RAISE EXCEPTION 'Zwei Demo-Traeger erwartet'; END IF;
    SELECT organisation_id INTO STRICT v_org FROM traegerorganisation WHERE kuerzel='DEMO-VERBUND';
    IF (SELECT count(*) FROM tierheim WHERE organisation_id=v_org) <> 3 THEN RAISE EXCEPTION 'Drei Standorte im Verbund erwartet'; END IF;
    IF (SELECT sum(tiere_gesamt) FROM standort_uebersicht) <> 15 THEN RAISE EXCEPTION '15 Tiere in Standortuebersicht erwartet'; END IF;
    IF (SELECT count(*) FROM matching_v2) <> 65 THEN RAISE EXCEPTION 'Matching-Menge veraendert'; END IF;
    SELECT tierheim_id INTO STRICT v_standort FROM tierheim WHERE name='Demo Paws Nord';
    BEGIN
        UPDATE tierheim SET organisation_id=-1 WHERE tierheim_id=v_standort;
        RAISE EXCEPTION 'Ungueltige Organisation akzeptiert';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        UPDATE tierheim SET plz='1234' WHERE tierheim_id=v_standort;
        RAISE EXCEPTION 'Ungueltige PLZ akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        DELETE FROM traegerorganisation WHERE organisation_id=v_org;
        RAISE EXCEPTION 'Verwendeter Traeger geloescht';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    INSERT INTO tierheim(name,ort) VALUES ('Leerer Teststandort','Testort') RETURNING tierheim_id INTO v_standort;
    IF NOT EXISTS (SELECT 1 FROM standort_uebersicht WHERE tierheim_id=v_standort AND organisation_id IS NULL AND tiere_gesamt=0) THEN
        RAISE EXCEPTION 'Leerer Standort ohne bekannten Traeger fehlt';
    END IF;
END $$;
ROLLBACK;
