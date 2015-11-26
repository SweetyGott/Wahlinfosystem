/* question 6
Stellt die Top 10 der knappsten Sieger fur alle Parteien dar. Die knappsten Sieger ¨
sind die gew¨ahlten Erstkandidaten, welche mit dem geringsten Vorsprung gegenuber
ihren Konkurrenten gewonnen haben. Sollte eine Partei keinen Wahlkreis ¨
gewonnen haben, sollen stattdessen die Wahlkreise ausgegeben werden, in denen
sie am knappsten verloren hat.
*/

WITH 
diff AS 
(
SELECT *,
CASE rowId WHEN 1 THEN sub.stimmen - (nth_value(stimmen, 2) OVER fkw)
ELSE sub.stimmen - (first_value(stimmen) OVER fkw)
END as diff
FROM
(SELECT a.fkwahlkreis, a.stimmen, b.id as idbew, b.fkpartei, rowId
FROM
(SELECT *, 
RANK() OVER (PARTITION BY fkwahlkreis ORDER BY stimmen DESC) AS rowId
FROM ergebnisseerst WHERE jahr = 2013) a
JOIN bewerber b ON b.id = fkbewerber
ORDER BY a.fkwahlkreis, a.stimmen DESC) sub

WINDOW fkw AS (PARTITION BY fkwahlkreis)
),

closestWinners AS (SELECT a.id as partei_id, a.fkwahlkreis as wk_id, a.idbew as bew_id, diff FROM --a.id, a.fkwahlkreis, a.diff, a.closest FROM
(SELECT *, RANK() OVER (PARTITION BY p.id ORDER BY diff ASC) AS closest
FROM parteien p JOIN diff d ON p.id = d.fkpartei WHERE diff > 0
ORDER BY p.name, d.diff ASC) a
WHERE a.closest <= 10),

closestLosers AS (SELECT a.id as partei_id, a.fkwahlkreis as wk_id, a.idbew as bew_id, diff FROM --a.id, a.fkwahlkreis, a.diff, a.closest FROM
(SELECT *, RANK() OVER (PARTITION BY p.id ORDER BY diff DESC) AS closest
FROM parteien p JOIN diff d ON p.id = d.fkpartei WHERE diff < 0
ORDER BY p.name, d.diff ASC) a
WHERE a.closest <= 10)

SELECT p.name, b.vorname,b.nachname, diff FROM 
(SELECT *, RANK() OVER (PARTITION BY partei_id ORDER BY diff DESC) as n FROM
(SELECT * FROM closestWinners cw UNION ALL SELECT * FROM closestLosers cl) comb) ranked
JOIN parteien p ON partei_id = p.id
JOIN bewerber b ON bew_id = b.id
WHERE ranked.n <= 10
ORDER BY p.name


