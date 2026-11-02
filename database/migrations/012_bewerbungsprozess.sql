BEGIN;
ALTER TABLE bewerbung DROP CONSTRAINT bewerbung_tier_id_interessent_id_key;
CREATE UNIQUE INDEX uq_bewerbung_aktiv_paar ON bewerbung(tier_id, interessent_id)
WHERE status IN ('offen','in_pruefung','angenommen');

CREATE TABLE bewerbung_statushistorie (
    historie_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bewerbung_id INTEGER NOT NULL REFERENCES bewerbung(bewerbung_id),
    alter_status VARCHAR(20),
    neuer_status VARCHAR(20) NOT NULL,
    protokolliert_am TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    datenbank_benutzer TEXT NOT NULL DEFAULT session_user,
    ereignis VARCHAR(30) NOT NULL CHECK (ereignis IN ('bestandsuebernahme','angelegt','statuswechsel'))
);
CREATE INDEX idx_bewerbung_historie ON bewerbung_statushistorie(bewerbung_id,historie_id);
INSERT INTO bewerbung_statushistorie(bewerbung_id,neuer_status,ereignis)
SELECT bewerbung_id,status,'bestandsuebernahme' FROM bewerbung;

CREATE FUNCTION pruefe_bewerbungsprozess() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP='INSERT' THEN
        IF NEW.status IS DISTINCT FROM 'offen' THEN
            RAISE EXCEPTION 'Neue Bewerbung muss offen beginnen' USING ERRCODE='23514';
        END IF;
    ELSE
        IF NEW.tier_id IS DISTINCT FROM OLD.tier_id
           OR NEW.interessent_id IS DISTINCT FROM OLD.interessent_id
           OR NEW.bewerbung_id IS DISTINCT FROM OLD.bewerbung_id
           OR NEW.erstellt_am IS DISTINCT FROM OLD.erstellt_am THEN
            RAISE EXCEPTION 'Identitaet und Erstellungszeit einer Bewerbung sind unveraenderlich' USING ERRCODE='23514';
        END IF;
        IF NEW.status IS DISTINCT FROM OLD.status THEN
            IF NOT (
                (OLD.status='offen' AND NEW.status IN ('in_pruefung','abgelehnt','zurueckgezogen'))
                OR (OLD.status='in_pruefung' AND NEW.status IN ('angenommen','abgelehnt','zurueckgezogen'))
            ) THEN
                RAISE EXCEPTION 'Unerlaubter Statuswechsel: % -> %', OLD.status, NEW.status USING ERRCODE='23514';
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_pruefe_bewerbungsprozess BEFORE INSERT OR UPDATE ON bewerbung
FOR EACH ROW EXECUTE FUNCTION pruefe_bewerbungsprozess();

CREATE FUNCTION protokolliere_bewerbungsstatus() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP='INSERT' THEN
        INSERT INTO bewerbung_statushistorie(bewerbung_id,neuer_status,ereignis)
        VALUES (NEW.bewerbung_id,NEW.status,'angelegt');
    ELSIF NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO bewerbung_statushistorie(bewerbung_id,alter_status,neuer_status,ereignis)
        VALUES (NEW.bewerbung_id,OLD.status,NEW.status,'statuswechsel');
    END IF;
    RETURN NEW;
END $$;
CREATE TRIGGER trg_protokolliere_bewerbungsstatus AFTER INSERT OR UPDATE ON bewerbung
FOR EACH ROW EXECUTE FUNCTION protokolliere_bewerbungsstatus();
COMMIT;
