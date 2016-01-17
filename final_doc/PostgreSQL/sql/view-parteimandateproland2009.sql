-- View: public.parteimandateproland2009

-- DROP VIEW public.parteimandateproland2009;

CREATE OR REPLACE VIEW parteimandateproland2009 AS 
 SELECT mandateproland2009.bl_id,
    mandateproland2009.partei_id,
    mandateproland2009.sitze
   FROM mandateproland2009() mandateproland2009(bl_id, partei_id, sitze);

ALTER TABLE parteimandateproland2009
  OWNER TO postgres;
