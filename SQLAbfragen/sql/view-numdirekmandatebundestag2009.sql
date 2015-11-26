-- View: public.numdirektmandatebundesweit2009

-- DROP VIEW public.numdirektmandatebundesweit2009;

CREATE OR REPLACE VIEW numdirektmandatebundesweit2009 AS 
 SELECT p.id,
    count(p.id) AS direktmandate,
    ez.jahr
   FROM parteien p
     JOIN ergebnissezweit ez ON p.id = ez.fkpartei
  WHERE ez.jahr = 2009 AND ez.stimmen = (( SELECT max(sub.stimmen) AS max
           FROM ergebnissezweit sub
          WHERE ez.fkwahlkreis = sub.fkwahlkreis AND ez.jahr = sub.jahr))
  GROUP BY p.id, ez.jahr;

ALTER TABLE numdirektmandatebundesweit2009
  OWNER TO postgres;