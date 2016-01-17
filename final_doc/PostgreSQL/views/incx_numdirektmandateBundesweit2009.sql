CREATE OR REPLACE VIEW db.numdirektmandatebundesweit2009 as (
SELECT p.id, count(p.id) as direktmandate, ez.jahr
FROM db.parteien p JOIN db.ergebnissezweit ez ON p.id = ez.fkpartei
WHERE ez.jahr = 2009 and ez.stimmen = (
					SELECT max(sub.stimmen)
					FROM db.ergebnissezweit sub
					WHERE 	ez.fkwahlkreis = sub.fkwahlkreis and 
						ez.jahr = sub.jahr
					)
GROUP BY p.id, ez.jahr
)


