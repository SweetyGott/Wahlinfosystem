-- View: public.numdirektmandatebundesweit2013

-- DROP VIEW public.numdirektmandatebundesweit2013;

CREATE OR REPLACE VIEW numdirektmandatebundesweit2013 AS 
 SELECT p.id,
    count(p.id) AS direktmandate,
    ez.jahr
   FROM parteien p
     JOIN ergebnissezweit ez ON p.id = ez.fkpartei
  WHERE ez.jahr = 2013 AND ez.stimmen = (( SELECT max(sub.stimmen) AS max
           FROM ergebnissezweit sub
          WHERE ez.fkwahlkreis = sub.fkwahlkreis AND ez.jahr = sub.jahr))
  GROUP BY p.id, ez.jahr;

ALTER TABLE numdirektmandatebundesweit2013
  OWNER TO postgres;
