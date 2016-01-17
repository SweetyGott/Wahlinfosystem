-- View: public.sitzeproland2013

-- DROP VIEW public.sitzeproland2013;

CREATE OR REPLACE VIEW sitzeproland2013 AS 
 SELECT bl.id,
    round(bl."bevölkerung13"::numeric * 1.0 / (( SELECT getdivisor13() AS getdivisor))::numeric) AS sitze
   FROM "bundesländer" bl;

ALTER TABLE sitzeproland2013
  OWNER TO postgres;
