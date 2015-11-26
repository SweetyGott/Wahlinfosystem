-- View: public.zweitstimmenproland2013

-- DROP VIEW public.zweitstimmenproland2013;

CREATE OR REPLACE VIEW zweitstimmenproland2013 AS 
 SELECT bl.id AS bl_id,
    ez.fkpartei AS partei_id,
    sum(ez.stimmen) AS stimmen
   FROM ergebnissezweit ez,
    "bundesländer" bl,
    wahlkreise wk,
    legaleparteien2013 lp
  WHERE ez.jahr = 2013 AND ez.fkwahlkreis = wk.id AND wk.fkbundesland = bl.id AND ez.fkpartei = lp.id
  GROUP BY ez.fkpartei, bl.id;

ALTER TABLE zweitstimmenproland2013
  OWNER TO postgres;
