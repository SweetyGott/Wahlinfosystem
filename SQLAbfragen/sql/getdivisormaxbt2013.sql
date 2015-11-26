-- Function: public.getdivisormaxbt2013()

-- DROP FUNCTION public.getdivisormaxbt2013();

CREATE OR REPLACE FUNCTION getdivisormaxbt2013()
  RETURNS integer AS
$BODY$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;

		mindestsitze integer := 
		(select sum(m.greatest)
	        from minsitzeproland2013 m);	 
		
                -- array mit zweitstimmen für partei
                stimmenarr integer[] :=
                array(
                select sum(zpl.stimmen) as sumstimm
		from zweitstimmenproland2013 zpl
		group by zpl.partei_id
		ORDER BY zpl.partei_id
                );

                mandatarr integer[] :=
                array(
                select sum(m.greatest) as summand
		from minsitzeproland2013 m
		group by m.partei_id
		ORDER BY m.partei_id
                );
                		
	BEGIN

               FOREACH i IN ARRAY stimmenarr
               LOOP
               div = div + (i*1.0/mindestsitze);
               END LOOP;
               

		IF (utilbtg(stimmenarr,mandatarr,div) > 0) THEN
			direction = 100;
		ELSE 
			direction = -100;
		END IF;
		
		while utilbtg(stimmenarr,mandatarr,div) != 0 LOOP

			div = div + direction;
			
		END LOOP;

		RETURN div;
   	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getdivisormaxbt2013()
  OWNER TO postgres;
