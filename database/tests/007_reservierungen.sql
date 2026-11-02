BEGIN;
DO $$
DECLARE v_h INTEGER; v_t INTEGER; v_i INTEGER; v_b INTEGER; v_r INTEGER;
BEGIN
    INSERT INTO tierheim(name,ort) VALUES('Reservierungstest','Testort') RETURNING tierheim_id INTO v_h;
    INSERT INTO tier(tierheim_id,name,tierart) VALUES(v_h,'Reservierungstier','Hund') RETURNING tier_id INTO v_t;
    INSERT INTO interessent(vorname,nachname) VALUES('Test','Reservierung') RETURNING interessent_id INTO v_i;
    INSERT INTO bewerbung(tier_id,interessent_id) VALUES(v_t,v_i) RETURNING bewerbung_id INTO v_b;
    BEGIN
        PERFORM reserviere_tier(v_b,clock_timestamp()+interval '1 day');
        RAISE EXCEPTION 'Offene Bewerbung reserviert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE bewerbung SET status='in_pruefung' WHERE bewerbung_id=v_b;
    BEGIN
        PERFORM reserviere_tier(v_b,clock_timestamp()-interval '1 day');
        RAISE EXCEPTION 'Vergangenes Ende akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    v_r:=reserviere_tier(v_b,clock_timestamp()+interval '1 day');
    IF NOT EXISTS(SELECT 1 FROM tier WHERE tier_id=v_t AND status='reserviert') THEN RAISE EXCEPTION 'Tierstatus nicht synchron'; END IF;
    IF EXISTS(SELECT 1 FROM matching_v2 WHERE tier_id=v_t) THEN RAISE EXCEPTION 'Reserviertes Tier im Matching'; END IF;
    BEGIN
        PERFORM reserviere_tier(v_b,clock_timestamp()+interval '2 days');
        RAISE EXCEPTION 'Doppelreservierung akzeptiert';
    EXCEPTION WHEN check_violation OR unique_violation THEN NULL;
    END;
    BEGIN
        UPDATE bewerbung SET status='zurueckgezogen' WHERE bewerbung_id=v_b;
        RAISE EXCEPTION 'Reservierte Bewerbung zurueckgezogen';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        UPDATE tier SET status='vermittelt' WHERE tier_id=v_t;
        RAISE EXCEPTION 'Aktive Reservierung umgangen';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        UPDATE reservierung SET status='abgelaufen' WHERE reservierung_id=v_r;
        RAISE EXCEPTION 'Vorzeitiger Ablauf akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    PERFORM beende_reservierung(v_r);
    IF NOT EXISTS(SELECT 1 FROM tier WHERE tier_id=v_t AND status='verfuegbar') THEN RAISE EXCEPTION 'Tier nicht freigegeben'; END IF;
    IF NOT EXISTS(SELECT 1 FROM reservierung WHERE reservierung_id=v_r AND status='aufgehoben' AND beendet_am IS NOT NULL) THEN RAISE EXCEPTION 'Reservierungsende fehlt'; END IF;
    v_r:=reserviere_tier(v_b,clock_timestamp()+interval '0.1 seconds');
    PERFORM pg_sleep(0.2);
    PERFORM verarbeite_abgelaufene_reservierungen();
    IF NOT EXISTS(SELECT 1 FROM reservierung WHERE reservierung_id=v_r AND status='abgelaufen') THEN RAISE EXCEPTION 'Ablaufverarbeitung fehlgeschlagen'; END IF;
    IF NOT EXISTS(SELECT 1 FROM tier WHERE tier_id=v_t AND status='verfuegbar') THEN RAISE EXCEPTION 'Abgelaufenes Tier nicht freigegeben'; END IF;
END $$;
ROLLBACK;
