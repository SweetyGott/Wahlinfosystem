
CREATE OR REPLACE VIEW public.direktmandate2013 AS 
(SELECT ee.fkwahlkreis AS idwahlkreis, b.id AS idbewerber, p.id AS idpartei

FROM 
(SELECT DISTINCT s.fkwahlkreis, 
first_value (fkbewerber) OVER (PARTITION BY s.fkwahlkreis ORDER BY s.stimmen DESC) as fkbewerber 
FROM ergebnisseerst s WHERE s.jahr = 2013) ee
LEFT JOIN bewerber b ON b.id = ee.fkbewerber
LEFT JOIN parteien p ON p.id = b.fkpartei)