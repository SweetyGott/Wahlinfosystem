-- View: db.direktmandate2009

-- DROP VIEW db.direktmandate2009;

CREATE OR REPLACE VIEW db.direktmandate2009 AS 
 SELECT ee.fkwahlkreis AS idwahlkreis,
    b.id AS idbewerber,
    p.id AS idpartei
   FROM db.ergebnisseerst ee
     JOIN db.bewerber b ON b.id = ee.fkbewerber
     LEFT JOIN db.parteien p ON p.id = b.fkpartei
  WHERE ee.jahr = 2009
  GROUP BY ee.fkwahlkreis, b.id, p.id, ee.stimmen
 HAVING ee.stimmen = (( SELECT max(sub.stimmen) AS max
           FROM db.ergebnisseerst sub
          WHERE ee.fkwahlkreis = sub.fkwahlkreis AND sub.jahr = 2009));

ALTER TABLE db.direktmandate2009
  OWNER TO postgres;
