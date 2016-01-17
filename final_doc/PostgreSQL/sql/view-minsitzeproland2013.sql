-- View: public.minsitzeproland2013

-- DROP VIEW public.minsitzeproland2013;

CREATE OR REPLACE VIEW minsitzeproland2013 AS 
 SELECT spl.bl_id,
    spl.partei_id,
    GREATEST(spl.sitze::bigint, count(dm.idpartei)) AS "greatest"
   FROM generaterealsitzeproland2013() spl(bl_id, partei_id, sitze)
     JOIN wahlkreise wk ON wk.fkbundesland = spl.bl_id
     LEFT JOIN direktmandate2013 dm ON spl.partei_id = dm.idpartei AND wk.id = dm.idwahlkreis
  GROUP BY spl.bl_id, spl.partei_id, spl.sitze;

ALTER TABLE minsitzeproland2013
  OWNER TO postgres;
