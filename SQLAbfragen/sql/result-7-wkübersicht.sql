/*
Stellt fur einen ausgew ¨ ¨ahlten Wahlkreis folgende Informationen dar:
1. die Wahlbeteiligung
2. den gew¨ahlten Direktkandidaten
3. die prozentuale und absolute Anzahl an Stimmen fur jede Partei ¨
4. die Entwicklung der Stimmen im Vergleich zum Vorjahr (soweit m¨oglich)
*/
WITH 

sz AS 
(SELECT * FROM stimmzettel
WHERE jahr = 2013 AND fkwahlkreis = 1),

erst AS
(SELECT erststimme, count(*) as stimmen FROM sz GROUP BY erststimme),

zweit AS
(SELECT zweitstimme, count(*) as stimmen FROM sz GROUP BY zweitstimme)

-- 1) wahlbeteiligung
/*
SELECT 
sum(zweit.count)/(SELECT wähler13 FROM wahlkreise WHERE id = 1) AS wahlbeteiligung
FROM zweit
*/

-- 2) direktkandidate
/*
SELECT erststimme, b.Nachname, p.name
FROM (SELECT erststimme FROM erst ORDER BY erst.count DESC LIMIT 1) e 
JOIN bewerber b ON b.id = e.erststimme
JOIN parteien p ON p.id = b.fkpartei
*/

-- 3)
/*
SELECT  p.Name, stimmen AS StimmenAbs, 
stimmen*1.0/(SELECT gewählt13 FROM wahlkreise wk where wk.id = 1) AS StimmenRel
FROM zweit ez 
JOIN parteien p ON p.id = zweitstimme
*/

-- 4)
/*
SELECT z1.zweitstimme,
z1.stimmen-coalesce(z2.stimmen, 0) AS veränderungAbs 
FROM zweit z1
LEFT JOIN (SELECT zweitstimme, count(*) as stimmen 
FROM (SELECT * FROM stimmzettel WHERE jahr = 2009 AND fkwahlkreis = 1) a
GROUP BY zweitstimme) z2 ON z1.zweitstimme = z2.zweitstimme
*/