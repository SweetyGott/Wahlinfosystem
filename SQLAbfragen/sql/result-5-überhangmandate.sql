SELECT * FROM
(SELECT s.partei_id, sum(m.greatest-s.sitze) AS Überhangmandate 
FROM minsitzeproland2013 m
JOIN generaterealSitzeProland2013() s ON s.bl_id = m.bl_id AND m.partei_id = s.partei_id
GROUP BY s.partei_id) a
WHERE a.Überhangmandate > 0