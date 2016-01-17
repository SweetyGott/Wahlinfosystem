-- View: public.btmandatepartei2013

-- DROP VIEW public.btmandatepartei2013;

CREATE OR REPLACE VIEW btmandatepartei2013 AS 
 WITH div AS (
         SELECT getdivisormaxbt2013.getdivisormaxbt2013
           FROM getdivisormaxbt2013() getdivisormaxbt2013(getdivisormaxbt2013)
        )
 SELECT zpl.partei_id,
    round(sum(zpl.stimmen) * 1.0 / (( SELECT div.getdivisormaxbt2013
           FROM div))::numeric) AS round
   FROM zweitstimmenproland2013 zpl
  GROUP BY zpl.partei_id;

ALTER TABLE btmandatepartei2013
  OWNER TO postgres;
