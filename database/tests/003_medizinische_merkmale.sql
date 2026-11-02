BEGIN;
DO $$
DECLARE
    h INTEGER;
    t INTEGER;
    m INTEGER;
    m2 INTEGER;
BEGIN
    INSERT INTO tierheim(name, ort) VALUES ('Medizin-Testheim', 'Testort') RETURNING tierheim_id INTO h;
    INSERT INTO tier(tierheim_id, name, tierart) VALUES (h, 'Medizin-Testtier', 'Hund') RETURNING tier_id INTO t;
    INSERT INTO medizinisches_merkmal(bezeichnung) VALUES ('Testmerkmal A') RETURNING merkmal_id INTO m;
    INSERT INTO medizinisches_merkmal(bezeichnung) VALUES ('Testmerkmal B') RETURNING merkmal_id INTO m2;
    INSERT INTO tier_medizinisches_merkmal(tier_id, merkmal_id, hinweis) VALUES (t, m, 'Fiktive Testangabe'), (t, m2, 'Weitere Testangabe');
    IF (SELECT count(*) FROM tier_medizin_uebersicht WHERE tier_id=t) <> 2 THEN
        RAISE EXCEPTION 'Zwei Merkmale fuer ein Tier erwartet';
    END IF;
    BEGIN
        INSERT INTO tier_medizinisches_merkmal(tier_id, merkmal_id) VALUES (t, m);
        RAISE EXCEPTION 'Doppelte Zuordnung akzeptiert';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO tier_medizinisches_merkmal(tier_id, merkmal_id) VALUES (-1, m);
        RAISE EXCEPTION 'Ungueltiges Tier akzeptiert';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO tier_medizinisches_merkmal(tier_id, merkmal_id) VALUES (t, -1);
        RAISE EXCEPTION 'Ungueltiges Merkmal akzeptiert';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO medizinisches_merkmal(bezeichnung) VALUES ('   ');
        RAISE EXCEPTION 'Leere Bezeichnung akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        DELETE FROM medizinisches_merkmal WHERE merkmal_id=m;
        RAISE EXCEPTION 'Verwendetes Merkmal geloescht';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
END $$;
ROLLBACK;
