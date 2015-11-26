-- wahlkreissieger
WITH relWK AS (SELECT * FROM ergebnissezweit ez 
JOIN parteien p ON ez.fkpartei = p.id
WHERE ez.fkwahlkreis = ?? and ez.jahr = 2013 )


SELECT p.name as ParteiErst, relWK.name as ParteiZweit FROM relWK

LEFT JOIN direktmandate2013 dm ON relWK.fkwahlkreis = dm.idwahlkreis
JOIN parteien p ON dm.idpartei = p.id

WHERE relWK.stimmen = (SELECT max(sub.stimmen) FROM relWK sub)