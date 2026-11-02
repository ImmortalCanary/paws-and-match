-- Nach Schema und Demodaten ausfuehren. Keine automatische Adoptionsentscheidung.
-- Vereinfachte Projektregeln, keine allgemeingueltigen Tierhaltungsregeln.
-- Bewertet nur Kinder, Katzen, Treppenzugang und Alleinbleibedauer.
WITH pruefung AS (
    SELECT i.interessent_id, i.vorname, t.tier_id, t.name AS tiername,
        CASE WHEN i.kinder_im_haushalt IS FALSE OR t.kinder_vertraeglich IS TRUE THEN TRUE
             WHEN i.kinder_im_haushalt IS TRUE AND t.kinder_vertraeglich IS FALSE THEN FALSE
             ELSE NULL END AS kinder_ok,
        CASE WHEN i.katzen_im_haushalt IS FALSE OR t.katzen_vertraeglich IS TRUE THEN TRUE
             WHEN i.katzen_im_haushalt IS TRUE AND t.katzen_vertraeglich IS FALSE THEN FALSE
             ELSE NULL END AS katzen_ok,
        CASE WHEN t.braucht_treppenfrei IS FALSE OR i.zugang_treppenfrei IS TRUE THEN TRUE
             WHEN t.braucht_treppenfrei IS TRUE AND i.zugang_treppenfrei IS FALSE THEN FALSE
             ELSE NULL END AS treppen_ok,
        i.allein_stunden <= t.max_allein_stunden AS allein_ok
    FROM interessent i CROSS JOIN tier t
    WHERE t.status = 'verfuegbar'
)
SELECT interessent_id, vorname, tier_id, tiername,
    CASE WHEN kinder_ok IS FALSE OR katzen_ok IS FALSE OR treppen_ok IS FALSE OR allein_ok IS FALSE
         THEN 'ausgeschlossen'
         WHEN kinder_ok IS TRUE AND katzen_ok IS TRUE AND treppen_ok IS TRUE AND allein_ok IS TRUE
         THEN 'grundsaetzlich passend'
         ELSE 'manuell pruefen' END AS ergebnis,
    kinder_ok, katzen_ok, treppen_ok, allein_ok
FROM pruefung
ORDER BY interessent_id, tier_id;
