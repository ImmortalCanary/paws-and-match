-- Nur lesende Abfragen. Nach Schema und Demodaten ausfuehren.

-- 1. Verfuegbare Tiere mit zustaendigem Tierheim.
SELECT t.tier_id, t.name AS tiername, t.tierart,
       h.name AS tierheim, h.ort
FROM tier t
JOIN tierheim h ON h.tierheim_id = t.tierheim_id
WHERE t.status = 'verfuegbar'
ORDER BY h.tierheim_id, t.tier_id;

-- 2. Tierzahlen je Tierheim, einschliesslich leerer Standorte.
SELECT h.tierheim_id, h.name, COUNT(t.tier_id) AS tiere_gesamt,
       COUNT(t.tier_id) FILTER (WHERE t.status = 'verfuegbar') AS verfuegbar,
       COUNT(t.tier_id) FILTER (WHERE t.status = 'reserviert') AS reserviert,
       COUNT(t.tier_id) FILTER (WHERE t.status = 'vermittelt') AS vermittelt
FROM tierheim h
LEFT JOIN tier t ON t.tierheim_id = h.tierheim_id
GROUP BY h.tierheim_id, h.name
ORDER BY h.tierheim_id;

-- 3. Bewerbungen mit Tier, Interessent und Tierheim.
SELECT b.bewerbung_id, b.erstellt_am, b.status,
       t.name AS tiername, h.name AS tierheim,
       i.vorname, i.nachname
FROM bewerbung b
JOIN tier t ON t.tier_id = b.tier_id
JOIN tierheim h ON h.tierheim_id = t.tierheim_id
JOIN interessent i ON i.interessent_id = b.interessent_id
ORDER BY b.erstellt_am, b.bewerbung_id;

-- 4. Verfuegbare Tiere ohne offene oder laufend gepruefte Bewerbung.
SELECT t.tier_id, t.name, t.tierart
FROM tier t
WHERE t.status = 'verfuegbar'
  AND NOT EXISTS (
      SELECT 1 FROM bewerbung b
      WHERE b.tier_id = t.tier_id
        AND b.status IN ('offen', 'in_pruefung')
  )
ORDER BY t.tier_id;
