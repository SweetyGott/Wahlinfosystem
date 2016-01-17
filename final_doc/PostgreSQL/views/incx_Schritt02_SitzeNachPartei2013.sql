-- als array function für weniger queries
CREATE OR REPLACE FUNCTION db.utilsnp (
        stimmarr integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE 
		ret integer;
		i integer;
	
	BEGIN

	ret = 0;
	
                FOREACH i IN ARRAY stimmarr
                LOOP 
                ret = ret + round(i * 1.0/ a);
                END LOOP;
                
	return ret;
   	END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION db.getDivisor2SNP2013 (
	bl_idparam integer
	) RETURNS integer AS $$
	DECLARE 
		direction integer;
		div integer;

		sitzefuerLand integer := 
		(select spl.sitze
	        from db.sitzeProLand2013 spl
	        where spl.id = bl_idparam);	 
		
                -- array mit zweitstimmen für gegebenes bundesland
                stimmenarr integer[] := 
                array(
                select zpl.stimmen
		from db.zweitstimmenproland2013 zpl
		where zpl.bl_id = bl_idparam
                );
                		
	BEGIN

                -- startdivisor aus sum(stimmen)/stize
                div = db.utilsnp(stimmenarr,1)/sitzefuerLand;
                		
		IF (db.utilsnp(stimmenarr,div) > sitzefuerLand ) THEN
			direction = 100;
		ELSE 
			direction = -100;
		END IF;
		
		while db.utilsnp(stimmenarr,div) != sitzefuerLand LOOP

			div = div + direction;
			
		END LOOP;

		RETURN div;
   	END;
$$ LANGUAGE plpgsql;

