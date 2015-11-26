-- View: public.direktmandate2013

-- DROP VIEW public.direktmandate2013;

CREATE OR REPLACE VIEW direktmandate2013 AS 
 SELECT ee.fkwahlkreis AS idwahlkreis,
    b.id AS idbewerber,
    p.id AS idpartei
   FROM ergebnisseerst ee
     JOIN bewerber b ON b.id = ee.fkbewerber
     LEFT JOIN parteien p ON p.id = b.fkpartei
  WHERE ee.jahr = 2013
  GROUP BY ee.fkwahlkreis, b.id, p.id, ee.stimmen
 HAVING ee.stimmen = (( SELECT max(sub.stimmen) AS max
           FROM ergebnisseerst sub
          WHERE ee.fkwahlkreis = sub.fkwahlkreis AND sub.jahr = 2013));

ALTER TABLE direktmandate2013
  OWNER TO postgres;