-- DROP VIEW public.sitzeproland2013;

CREATE OR REPLACE VIEW public.sitzeproland2009 AS 
SELECT id, mandat::numeric as sitze FROM schritt01_2009();