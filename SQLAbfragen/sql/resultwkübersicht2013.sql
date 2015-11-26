--Wahlkreisubersicht ¨
--Stellt fur einen ausgew ¨ ¨ahlten Wahlkreis folgende Informationen dar:
--1. die Wahlbeteiligung
--2. den gew¨ahlten Direktkandidaten
--3. die prozentuale und absolute Anzahl an Stimmen fur jede Partei
--4. die Entwicklung der Stimmen im Vergleich zum Vorjahr (soweit moglich)

-- 1) SELECT id, gewählt13*1.0/wähler13 AS Wahlbeteiligung FROM wahlkreise WHERE id = ??

-- 2) SELECT idbewerber as BewerberErst, idpartei as ParteiErst FROM direktmandate2009 WHERE idwahlkreis = ??

-- 3)
-- SELECT  p.Name, stimmen AS StimmenAbs, stimmen*1.0/gewählt13 AS StimmenRel
-- FROM ergebnissezweit ez JOIN parteien p ON p.id = fkpartei JOIN wahlkreise wk ON wk.id = ez.fkwahlkreis
-- WHERE jahr = 2013 AND ez.fkwahlkreis = ??

-- 4)
-- SELECT ez1.fkpartei, ez1.fkwahlkreis, ez1.stimmen-coalesce(ez2.stimmen, 0) AS veränderungAbs FROM ergebnissezweit ez1
-- LEFT JOIN ergebnissezweit ez2 ON ez1.fkwahlkreis = ez2.fkwahlkreis AND ez1.fkpartei = ez2.fkpartei
-- WHERE ez1.jahr = 2013 AND ez2.jahr = 2009 AND ez1.fkwahlkreis = ??