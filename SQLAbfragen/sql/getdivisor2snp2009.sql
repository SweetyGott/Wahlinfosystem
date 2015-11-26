-- Function: public.getdivisor2snp2009(integer)

-- DROP FUNCTION public.getdivisor2snp2009(integer);

CREATE OR REPLACE FUNCTION getdivisor2snp2009(bl_idparam integer)
  RETURNS integer AS
$BODY$
	DECLARE 
		direction integer;
		div integer;

		sitzefuerLand integer := 
		(select spl.sitze
	        from sitzeProLand2009 spl
	        where spl.id = bl_idparam);	 
		
                -- array mit zweitstimmen für gegebenes bundesland
                stimmenarr integer[] := 
                array(
                select zpl.stimmen
		from zweitstimmenproland2009 zpl
		where zpl.bl_id = bl_idparam
                );
                		
	BEGIN

                -- startdivisor aus sum(stimmen)/stize
                div = utilsnp(stimmenarr,1)/sitzefuerLand;
                		
		IF (utilsnp(stimmenarr,div) > sitzefuerLand ) THEN
			direction = 50;
		ELSE 
			direction = -50;
		END IF;
		
		while utilsnp(stimmenarr,div) != sitzefuerLand LOOP

			div = div + direction;
			
		END LOOP;

		RETURN div;
   	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getdivisor2snp2009(integer)
  OWNER TO postgres;