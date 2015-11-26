-- View: public.sitzeproland2009

-- DROP VIEW public.sitzeproland2009;

CREATE OR REPLACE VIEW sitzeproland2009 AS 
 SELECT bl.id,
    round(bl."bevölkerung09"::numeric * 1.0 / (( SELECT getdivisor09() AS getdivisor))::numeric) AS sitze
   FROM "bundesländer" bl;

ALTER TABLE sitzeproland2009
  OWNER TO postgres;
