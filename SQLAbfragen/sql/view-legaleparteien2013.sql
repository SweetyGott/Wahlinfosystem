-- View: public.legaleparteien2013

-- DROP VIEW public.legaleparteien2013;

CREATE OR REPLACE VIEW public.legaleparteien2013 AS 
WITH zweitstimmen AS (
         SELECT ez.fkpartei AS id,
            sum(ez.stimmen) AS total
             FROM ergebnissezweit ez
          WHERE ez.jahr = 2013
          GROUP BY ez.fkpartei
        ), numdirektmandatebundesweit2013 AS (
         SELECT dm.idpartei,
            count(dm.idpartei) AS direktmandate
           FROM direktmandate2013 dm
          GROUP BY dm.idpartei
        )

 SELECT 
    d.idpartei AS id,
    zs.total,
    COALESCE(d.direktmandate, 0::bigint) AS direktmandate
FROM zweitstimmen zs
JOIN numdirektmandatebundesweit2013 d ON d.idpartei = zs.id
  WHERE (zs.total::numeric / (( SELECT sum(a.total) AS sum
           FROM zweitstimmen a))) >= 0.05 OR d.direktmandate >= 3;