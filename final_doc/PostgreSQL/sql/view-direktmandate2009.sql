-- View: public.direktmandate2009

-- DROP VIEW public.direktmandate2009;

CREATE OR REPLACE VIEW direktmandate2009 AS 
 SELECT ee.fkwahlkreis AS idwahlkreis,
    b.id AS idbewerber,
    p.id AS idpartei
   FROM ergebnisseerst ee
     JOIN bewerber b ON b.id = ee.fkbewerber
     LEFT JOIN parteien p ON p.id = b.fkpartei
  WHERE ee.jahr = 2009
  GROUP BY ee.fkwahlkreis, b.id, p.id, ee.stimmen
 HAVING ee.stimmen = (( SELECT max(sub.stimmen) AS max
           FROM ergebnisseerst sub
          WHERE ee.fkwahlkreis = sub.fkwahlkreis AND sub.jahr = 2009));

ALTER TABLE direktmandate2009
  OWNER TO postgres;
