BEGIN;
DO $$
DECLARE
    v_tier INTEGER;
    v_interessent INTEGER;
BEGIN
    IF (SELECT count(*) FROM tierheim) <> 1
       OR (SELECT count(*) FROM tier) <> 3
       OR (SELECT count(*) FROM interessent) <> 1
       OR (SELECT count(*) FROM bewerbung) <> 0 THEN
        RAISE EXCEPTION 'Unerwartete Anzahl an Demo-Datensaetzen';
    END IF;
    SELECT tier_id INTO STRICT v_tier FROM tier WHERE name = 'Balu';
    SELECT interessent_id INTO STRICT v_interessent FROM interessent WHERE vorname = 'Anna';
    INSERT INTO bewerbung (tier_id, interessent_id) VALUES (v_tier, v_interessent);
    BEGIN
        INSERT INTO bewerbung (tier_id, interessent_id) VALUES (v_tier, v_interessent);
        RAISE EXCEPTION 'Doppelte Bewerbung wurde akzeptiert';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        INSERT INTO bewerbung (tier_id, interessent_id) VALUES (-1, v_interessent);
        RAISE EXCEPTION 'Nicht vorhandenes Tier wurde akzeptiert';
    EXCEPTION WHEN foreign_key_violation THEN NULL;
    END;
    BEGIN
        UPDATE interessent SET allein_stunden = 25 WHERE interessent_id = v_interessent;
        RAISE EXCEPTION 'Ungueltige Stundenzahl wurde akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        UPDATE tier SET status = 'ungueltig' WHERE tier_id = v_tier;
        RAISE EXCEPTION 'Ungueltiger Tierstatus wurde akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
END $$;
ROLLBACK;
