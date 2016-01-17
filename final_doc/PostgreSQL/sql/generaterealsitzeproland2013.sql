-- Function: public.generaterealsitzeproland2013()

-- DROP FUNCTION public.generaterealsitzeproland2013();

CREATE OR REPLACE FUNCTION public.generaterealsitzeproland2013()
  RETURNS TABLE(bl_id integer, partei_id integer, sitze integer) AS
$BODY$
	DECLARE 
		i integer;
		div integer;
	BEGIN

        create temporary table res (bl_id integer, partei_id integer, sitze integer) on commit drop;

        FOR i IN 1..16
        LOOP

        div = getdivisor2snp2013(i);
        
        INSERT INTO res (bl_id,partei_id,sitze) 
        select z.bl_id,z.partei_id, round(z.stimmen*1.0/div) as sitze from zweitstimmenproland2013 z 
        where z.bl_id = i;
        
	END LOOP;

	RETURN QUERY SELECT * FROM res;

	drop table res;
   	END;
   	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.generaterealsitzeproland2013()
  OWNER TO postgres;
