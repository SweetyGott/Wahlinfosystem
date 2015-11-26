-- View: public.zweitstimmenproland2009

-- DROP VIEW public.zweitstimmenproland2009;

CREATE OR REPLACE VIEW zweitstimmenproland2009 AS 
 SELECT bl.id AS bl_id,
    ez.fkpartei AS partei_id,
    sum(ez.stimmen) AS stimmen
   FROM ergebnissezweit ez,
    "bundesländer" bl,
    wahlkreise wk,
    legaleparteien2009 lp
  WHERE ez.jahr = 2009 AND ez.fkwahlkreis = wk.id AND wk.fkbundesland = bl.id AND ez.fkpartei = lp.id
  GROUP BY ez.fkpartei, bl.id;

ALTER TABLE zweitstimmenproland2009
  OWNER TO postgres;
