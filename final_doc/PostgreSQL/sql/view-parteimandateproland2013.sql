-- View: public.parteimandateproland2013

-- DROP VIEW public.parteimandateproland2013;

CREATE OR REPLACE VIEW parteimandateproland2013 AS 
 SELECT mandateproland2013.bl_id,
    mandateproland2013.partei_id,
    mandateproland2013.sitze
   FROM mandateproland2013() mandateproland2013(bl_id, partei_id, sitze);

ALTER TABLE parteimandateproland2013
  OWNER TO postgres;
