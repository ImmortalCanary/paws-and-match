-- Isolierte Testdaten; alle Datenaenderungen werden zurueckgerollt.
BEGIN;
DO $$
DECLARE
    h INTEGER;
    t INTEGER;
    i INTEGER;
    actual TEXT;
BEGIN
    INSERT INTO tierheim(name, ort) VALUES ('Test Matching v2', 'Testort') RETURNING tierheim_id INTO h;
    INSERT INTO tier(tierheim_id, name, tierart, kinder_vertraeglich, katzen_vertraeglich, braucht_treppenfrei, max_allein_stunden, hunde_vertraeglich, braucht_erfahrung, betreuungsbedarf_min, monatskosten_eur)
    VALUES (h, 'Testtier', 'Hund', TRUE, TRUE, FALSE, 4, TRUE, TRUE, 120, 100) RETURNING tier_id INTO t;
    INSERT INTO interessent(vorname, nachname, kinder_im_haushalt, katzen_im_haushalt, zugang_treppenfrei, allein_stunden, hunde_im_haushalt, tiererfahrung, betreuungszeit_min, monatsbudget_eur)
    VALUES ('Test', 'Matching v2', TRUE, TRUE, FALSE, 4, TRUE, TRUE, 120, 100) RETURNING interessent_id INTO i;

    SELECT ergebnis INTO STRICT actual FROM matching_v2 WHERE tier_id=t AND interessent_id=i;
    IF actual <> 'grundsaetzlich passend' THEN RAISE EXCEPTION 'Gleichheitsgrenzen fehlgeschlagen: %', actual; END IF;
    IF (SELECT count(*) FROM matching_v2_details WHERE tier_id=t AND interessent_id=i) <> 8 THEN RAISE EXCEPTION 'Acht Kriterien erwartet'; END IF;

    UPDATE interessent SET monatsbudget_eur=99 WHERE interessent_id=i;
    IF NOT EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t AND interessent_id=i AND ergebnis='ausgeschlossen' AND ausschlussgruende='Budget') THEN RAISE EXCEPTION 'Budgetausschluss fehlt'; END IF;

    UPDATE interessent SET monatsbudget_eur=NULL WHERE interessent_id=i;
    IF NOT EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t AND interessent_id=i AND ergebnis='manuell pruefen' AND ungeklaerte_kriterien='Budget') THEN RAISE EXCEPTION 'Unbekanntes Budget falsch bewertet'; END IF;

    UPDATE tier SET hunde_vertraeglich=FALSE WHERE tier_id=t;
    IF NOT EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t AND interessent_id=i AND ergebnis='ausgeschlossen' AND ausschlussgruende='Hunde' AND ungeklaerte_kriterien='Budget') THEN RAISE EXCEPTION 'Ausschluss muss vor unbekannten Kriterien wirken'; END IF;

    UPDATE interessent SET hunde_im_haushalt=FALSE, monatsbudget_eur=100, tiererfahrung=FALSE WHERE interessent_id=i;
    IF NOT EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t AND interessent_id=i AND ausschlussgruende='Erfahrung') THEN RAISE EXCEPTION 'Erfahrungsregel falsch'; END IF;

    UPDATE tier SET braucht_erfahrung=FALSE WHERE tier_id=t;
    UPDATE interessent SET betreuungszeit_min=119 WHERE interessent_id=i;
    IF NOT EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t AND interessent_id=i AND ausschlussgruende='Betreuungszeit') THEN RAISE EXCEPTION 'Betreuungszeit falsch'; END IF;

    UPDATE tier SET status='reserviert' WHERE tier_id=t;
    IF EXISTS (SELECT 1 FROM matching_v2 WHERE tier_id=t) THEN RAISE EXCEPTION 'Reserviertes Tier darf nicht erscheinen'; END IF;

    BEGIN
        UPDATE interessent SET monatsbudget_eur=-1 WHERE interessent_id=i;
        RAISE EXCEPTION 'Negatives Budget akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
    BEGIN
        UPDATE tier SET betreuungsbedarf_min=1441 WHERE tier_id=t;
        RAISE EXCEPTION 'Ungueltige Betreuungszeit akzeptiert';
    EXCEPTION WHEN check_violation THEN NULL;
    END;
END $$;
ROLLBACK;
