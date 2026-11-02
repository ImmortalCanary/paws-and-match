BEGIN;
ALTER TABLE tier
    ADD COLUMN hunde_vertraeglich BOOLEAN,
    ADD COLUMN braucht_erfahrung BOOLEAN,
    ADD COLUMN betreuungsbedarf_min INTEGER CHECK (betreuungsbedarf_min BETWEEN 0 AND 1440),
    ADD COLUMN monatskosten_eur NUMERIC(10,2) CHECK (monatskosten_eur >= 0);
ALTER TABLE interessent
    ADD COLUMN hunde_im_haushalt BOOLEAN,
    ADD COLUMN tiererfahrung BOOLEAN,
    ADD COLUMN betreuungszeit_min INTEGER CHECK (betreuungszeit_min BETWEEN 0 AND 1440),
    ADD COLUMN monatsbudget_eur NUMERIC(10,2) CHECK (monatsbudget_eur >= 0);

CREATE VIEW matching_v2_details AS
SELECT i.interessent_id, t.tier_id, t.name AS tiername,
       r.kriterium, r.erfuellt
FROM interessent i CROSS JOIN tier t
CROSS JOIN LATERAL (VALUES
    ('Kinder', CASE WHEN i.kinder_im_haushalt IS FALSE OR t.kinder_vertraeglich IS TRUE THEN TRUE WHEN i.kinder_im_haushalt IS TRUE AND t.kinder_vertraeglich IS FALSE THEN FALSE ELSE NULL END),
    ('Katzen', CASE WHEN i.katzen_im_haushalt IS FALSE OR t.katzen_vertraeglich IS TRUE THEN TRUE WHEN i.katzen_im_haushalt IS TRUE AND t.katzen_vertraeglich IS FALSE THEN FALSE ELSE NULL END),
    ('Treppenzugang', CASE WHEN t.braucht_treppenfrei IS FALSE OR i.zugang_treppenfrei IS TRUE THEN TRUE WHEN t.braucht_treppenfrei IS TRUE AND i.zugang_treppenfrei IS FALSE THEN FALSE ELSE NULL END),
    ('Alleinbleibedauer', i.allein_stunden <= t.max_allein_stunden),
    ('Hunde', CASE WHEN i.hunde_im_haushalt IS FALSE OR t.hunde_vertraeglich IS TRUE THEN TRUE WHEN i.hunde_im_haushalt IS TRUE AND t.hunde_vertraeglich IS FALSE THEN FALSE ELSE NULL END),
    ('Erfahrung', CASE WHEN t.braucht_erfahrung IS FALSE OR i.tiererfahrung IS TRUE THEN TRUE WHEN t.braucht_erfahrung IS TRUE AND i.tiererfahrung IS FALSE THEN FALSE ELSE NULL END),
    ('Betreuungszeit', i.betreuungszeit_min >= t.betreuungsbedarf_min),
    ('Budget', i.monatsbudget_eur >= t.monatskosten_eur)
) AS r(kriterium, erfuellt)
WHERE t.status = 'verfuegbar';

CREATE VIEW matching_v2 AS
SELECT interessent_id, tier_id, tiername,
       CASE WHEN COUNT(*) FILTER (WHERE erfuellt IS FALSE) > 0 THEN 'ausgeschlossen'
            WHEN COUNT(*) FILTER (WHERE erfuellt IS NULL) > 0 THEN 'manuell pruefen'
            ELSE 'grundsaetzlich passend' END AS ergebnis,
       COALESCE(string_agg(kriterium, ', ' ORDER BY kriterium) FILTER (WHERE erfuellt IS FALSE), '') AS ausschlussgruende,
       COALESCE(string_agg(kriterium, ', ' ORDER BY kriterium) FILTER (WHERE erfuellt IS NULL), '') AS ungeklaerte_kriterien
FROM matching_v2_details
GROUP BY interessent_id, tier_id, tiername;
COMMIT;
