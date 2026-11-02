BEGIN;
DO $$
DECLARE
    v_h INTEGER;
    v_t INTEGER;
    v_i INTEGER;
    v_b INTEGER;
    v_neu INTEGER;
BEGIN
    INSERT INTO tierheim(name,ort) VALUES ('Prozesstest','Testort') RETURNING tierheim_id INTO v_h;
    INSERT INTO tier(tierheim_id,name,tierart) VALUES (v_h,'Prozesstier','Hund') RETURNING tier_id INTO v_t;
    INSERT INTO interessent(vorname,nachname) VALUES ('Test','Bewerbung') RETURNING interessent_id INTO v_i;
    INSERT INTO bewerbung(tier_id,interessent_id) VALUES (v_t,v_i) RETURNING bewerbung_id INTO v_b;
    BEGIN
        INSERT INTO bewerbung(tier_id,interessent_id) VALUES (v_t,v_i);
        RAISE EXCEPTION 'Zweite aktive Bewerbung akzeptiert';
    EXCEPTION WHEN unique_violation THEN NULL;
    END;
    BEGIN
        UPDATE bewerbung SET status='angenommen' WHERE bewerbung_id=v_b;
        RAISE EXCEPTION 'Direkte Annahme aus offen akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE bewerbung SET status='in_pruefung' WHERE bewerbung_id=v_b;
    UPDATE bewerbung SET status='abgelehnt' WHERE bewerbung_id=v_b;
    BEGIN
        UPDATE bewerbung SET status='offen' WHERE bewerbung_id=v_b;
        RAISE EXCEPTION 'Abgelehnte Bewerbung wieder geoeffnet';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    INSERT INTO bewerbung(tier_id,interessent_id) VALUES (v_t,v_i) RETURNING bewerbung_id INTO v_neu;
    IF v_neu=v_b THEN RAISE EXCEPTION 'Neue Bewerbung benoetigt neue ID'; END IF;
    IF (SELECT count(*) FROM bewerbung_statushistorie WHERE bewerbung_id=v_b) <> 3 THEN
        RAISE EXCEPTION 'Anlage und zwei Statuswechsel erwartet';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM bewerbung_statushistorie WHERE bewerbung_id=v_b AND alter_status='in_pruefung' AND neuer_status='abgelehnt') THEN
        RAISE EXCEPTION 'Statushistorie unvollstaendig';
    END IF;
    BEGIN
        UPDATE bewerbung SET erstellt_am=erstellt_am + interval '1 day' WHERE bewerbung_id=v_neu;
        RAISE EXCEPTION 'Erstellungszeit geaendert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    UPDATE bewerbung SET status='zurueckgezogen' WHERE bewerbung_id=v_neu;
    BEGIN
        INSERT INTO bewerbung(tier_id,interessent_id,status) VALUES (v_t,v_i,'angenommen');
        RAISE EXCEPTION 'Neue Bewerbung als angenommen angelegt';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    INSERT INTO bewerbung(tier_id,interessent_id) VALUES (v_t,v_i) RETURNING bewerbung_id INTO v_neu;
    UPDATE bewerbung SET status='in_pruefung' WHERE bewerbung_id=v_neu;
    UPDATE bewerbung SET status='angenommen' WHERE bewerbung_id=v_neu;
END $$;
ROLLBACK;
