-- Nach erweiterter Demo ausfuehren. Nur lesende Abfragen.
SELECT h.tierheim_id, h.name AS standort, h.ort,
       count(t.tier_id) AS tiere_gesamt,
       count(t.tier_id) FILTER (WHERE t.status='verfuegbar') AS verfuegbar
FROM tierheim h LEFT JOIN tier t ON t.tierheim_id=h.tierheim_id
GROUP BY h.tierheim_id, h.name, h.ort
ORDER BY h.tierheim_id;

SELECT i.interessent_id, i.vorname, h.name AS standort, h.ort,
       m.tier_id, m.tiername, m.ergebnis, m.ausschlussgruende, m.ungeklaerte_kriterien
FROM matching_v2 m
JOIN tier t ON t.tier_id=m.tier_id
JOIN tierheim h ON h.tierheim_id=t.tierheim_id
JOIN interessent i ON i.interessent_id=m.interessent_id
ORDER BY i.interessent_id, h.tierheim_id, m.tier_id;

-- Nur grundsaetzlich passende Kombinationen, standortuebergreifend.
SELECT i.vorname, i.nachname, m.tiername, h.name AS standort, h.ort
FROM matching_v2 m
JOIN interessent i ON i.interessent_id=m.interessent_id
JOIN tier t ON t.tier_id=m.tier_id
JOIN tierheim h ON h.tierheim_id=t.tierheim_id
WHERE m.ergebnis='grundsaetzlich passend'
ORDER BY i.interessent_id, h.tierheim_id, m.tier_id;
