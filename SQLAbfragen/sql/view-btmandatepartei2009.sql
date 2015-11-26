-- View: public.btmandatepartei2009

-- DROP VIEW public.btmandatepartei2009;

CREATE OR REPLACE VIEW btmandatepartei2009 AS 
 WITH div AS (
         SELECT getdivisormaxbt2009.getdivisormaxbt2009
           FROM getdivisormaxbt2009() getdivisormaxbt2009(getdivisormaxbt2009)
        )
 SELECT zpl.partei_id,
    round(sum(zpl.stimmen) * 1.0 / (( SELECT div.getdivisormaxbt2009
           FROM div))::numeric) AS round
   FROM zweitstimmenproland2009 zpl
  GROUP BY zpl.partei_id;

ALTER TABLE btmandatepartei2009
  OWNER TO postgres;
