BEGIN;
ALTER TABLE bewerbung ADD CONSTRAINT uq_bewerbung_id_tier UNIQUE(bewerbung_id,tier_id);
CREATE TABLE reservierung (
    reservierung_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bewerbung_id INTEGER NOT NULL,
    tier_id INTEGER NOT NULL REFERENCES tier(tier_id),
    erstellt_am TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    endet_am TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aktiv' CHECK(status IN ('aktiv','aufgehoben','abgelaufen')),
    beendet_am TIMESTAMPTZ,
    FOREIGN KEY(bewerbung_id,tier_id) REFERENCES bewerbung(bewerbung_id,tier_id),
    CHECK(endet_am > erstellt_am),
    CHECK((status='aktiv' AND beendet_am IS NULL) OR (status<>'aktiv' AND beendet_am IS NOT NULL))
);
CREATE UNIQUE INDEX uq_reservierung_aktiv_tier ON reservierung(tier_id) WHERE status='aktiv';
CREATE INDEX idx_reservierung_bewerbung ON reservierung(bewerbung_id);
CREATE INDEX idx_reservierung_ablauf ON reservierung(endet_am) WHERE status='aktiv';

CREATE FUNCTION pruefe_reservierung() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_tierstatus TEXT; v_bewerbungsstatus TEXT;
BEGIN
    IF TG_OP='DELETE' THEN RAISE EXCEPTION 'Reservierungen beenden statt loeschen' USING ERRCODE='23514'; END IF;
    SELECT status INTO STRICT v_tierstatus FROM tier WHERE tier_id=NEW.tier_id FOR UPDATE;
    IF TG_OP='INSERT' THEN
        SELECT status INTO STRICT v_bewerbungsstatus FROM bewerbung
        WHERE bewerbung_id=NEW.bewerbung_id AND tier_id=NEW.tier_id FOR UPDATE;
        IF v_tierstatus<>'verfuegbar' THEN RAISE EXCEPTION 'RESERVATION_CONFLICT: Tier nicht verfuegbar' USING ERRCODE='23514'; END IF;
        IF v_bewerbungsstatus NOT IN ('in_pruefung','angenommen') THEN RAISE EXCEPTION 'Bewerbung muss geprueft werden' USING ERRCODE='23514'; END IF;
        NEW.erstellt_am:=clock_timestamp();
        NEW.beendet_am:=NULL;
        IF NEW.status<>'aktiv' OR NEW.endet_am<=NEW.erstellt_am THEN RAISE EXCEPTION 'Neue Reservierung benoetigt aktiven Status und zukuenftiges Ende' USING ERRCODE='23514'; END IF;
    ELSE
        IF NEW.reservierung_id IS DISTINCT FROM OLD.reservierung_id OR NEW.bewerbung_id IS DISTINCT FROM OLD.bewerbung_id
           OR NEW.tier_id IS DISTINCT FROM OLD.tier_id OR NEW.erstellt_am IS DISTINCT FROM OLD.erstellt_am
           OR NEW.endet_am IS DISTINCT FROM OLD.endet_am THEN
            RAISE EXCEPTION 'Reservierungszuordnung und Laufzeit sind unveraenderlich' USING ERRCODE='23514';
        END IF;
        IF OLD.status<>'aktiv' OR NEW.status NOT IN ('aufgehoben','abgelaufen') THEN
            RAISE EXCEPTION 'Nur aktive Reservierungen duerfen beendet werden' USING ERRCODE='23514';
        END IF;
        IF NEW.status='abgelaufen' AND OLD.endet_am>clock_timestamp() THEN
            RAISE EXCEPTION 'Ablaufzeitpunkt noch nicht erreicht' USING ERRCODE='23514';
        END IF;
        NEW.beendet_am:=clock_timestamp();
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_pruefe_reservierung BEFORE INSERT OR UPDATE OR DELETE ON reservierung
FOR EACH ROW EXECUTE FUNCTION pruefe_reservierung();

CREATE FUNCTION synchronisiere_reservierung() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE tier SET status=CASE WHEN NEW.status='aktiv' THEN 'reserviert' ELSE 'verfuegbar' END
    WHERE tier_id=NEW.tier_id;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_sync_reservierung AFTER INSERT OR UPDATE ON reservierung
FOR EACH ROW EXECUTE FUNCTION synchronisiere_reservierung();

CREATE FUNCTION schuetze_reserviertes_tier() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.status<>'reserviert' AND EXISTS(SELECT 1 FROM reservierung WHERE tier_id=OLD.tier_id AND status='aktiv') THEN
        RAISE EXCEPTION 'Aktive Reservierung zuerst beenden' USING ERRCODE='23514';
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_schuetze_reserviertes_tier BEFORE UPDATE OF status ON tier
FOR EACH ROW EXECUTE FUNCTION schuetze_reserviertes_tier();

CREATE FUNCTION schuetze_reservierte_bewerbung() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    PERFORM 1 FROM tier WHERE tier_id=OLD.tier_id FOR UPDATE;
    IF NEW.status NOT IN ('in_pruefung','angenommen') AND EXISTS(SELECT 1 FROM reservierung WHERE bewerbung_id=OLD.bewerbung_id AND status='aktiv') THEN
        RAISE EXCEPTION 'Reservierung vor Bewerbungsabschluss beenden' USING ERRCODE='23514';
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_schuetze_reservierte_bewerbung BEFORE UPDATE OF status ON bewerbung
FOR EACH ROW EXECUTE FUNCTION schuetze_reservierte_bewerbung();

CREATE FUNCTION reserviere_tier(p_bewerbung_id INTEGER,p_endet_am TIMESTAMPTZ) RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_tier INTEGER; v_id INTEGER;
BEGIN
    SELECT tier_id INTO STRICT v_tier FROM bewerbung WHERE bewerbung_id=p_bewerbung_id;
    INSERT INTO reservierung(bewerbung_id,tier_id,endet_am) VALUES(p_bewerbung_id,v_tier,p_endet_am) RETURNING reservierung_id INTO v_id;
    RETURN v_id;
END $$;
CREATE FUNCTION beende_reservierung(p_reservierung_id INTEGER) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    UPDATE reservierung SET status='aufgehoben' WHERE reservierung_id=p_reservierung_id AND status='aktiv';
    IF NOT FOUND THEN RAISE EXCEPTION 'Keine aktive Reservierung mit dieser ID' USING ERRCODE='23514'; END IF;
END $$;
CREATE FUNCTION verarbeite_abgelaufene_reservierungen() RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_id INTEGER; v_anzahl INTEGER:=0;
BEGIN
    FOR v_id IN SELECT reservierung_id FROM reservierung WHERE status='aktiv' AND endet_am<=clock_timestamp()
                ORDER BY tier_id FOR UPDATE SKIP LOCKED LOOP
        UPDATE reservierung SET status='abgelaufen' WHERE reservierung_id=v_id;
        v_anzahl:=v_anzahl+1;
    END LOOP;
    RETURN v_anzahl;
END $$;
COMMIT;
