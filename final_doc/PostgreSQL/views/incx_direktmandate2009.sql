-- View: db.direktmandate2009

-- DROP VIEW db.direktmandate2009;

CREATE OR REPLACE VIEW db.direktmandate2009 AS 

select ee.fkwahlkreis AS idwahlkreis, b.id AS idbewerber, p.id AS idpartei
from db.ergebnisseerst ee 
	JOIN db.bewerber b ON b.id = ee.fkbewerber 
	LEFT JOIN db.parteien p ON p.id = b.fkpartei
where ee.jahr = 2009 and ee.stimmen = ( SELECT max(sub.stimmen)
					FROM db.ergebnisseerst sub
					WHERE sub.jahr = 2009 and
						sub.fkwahlkreis = ee.fkwahlkreis
					)

