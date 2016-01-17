CREATE OR REPLACE FUNCTION db.utilbtg (
        stimmarr integer[],
        mandatarr integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE 
		ret integer;
		i integer;
		diff integer;
		mand integer;
	
	BEGIN

	ret = 0;
	
                FOR i IN 1..array_length(stimmarr, 1)
                LOOP 

                mand = round(stimmarr[i] * 1.0/ a);

                IF mand < mandatarr[i] THEN
                ret = ret - (mandatarr[i] - mand);
                END IF;
                
                END LOOP;
                
	return ret;
   	END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION db.getdivisormaxbt2009 () 
RETURNS integer AS $$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;

		mindestsitze integer := 
		(select sum(m.greatest)
	        from db.minsitzeproland2009 m);	 
		
                -- array mit zweitstimmen für partei
                stimmenarr integer[] :=
                array(
                select sum(zpl.stimmen) as sumstimm
		from db.zweitstimmenproland2009 zpl
		group by zpl.partei_id
		ORDER BY zpl.partei_id
                );

                mandatarr integer[] :=
                array(
                select sum(m.greatest) as summand
		from db.minsitzeproland2009 m
		group by m.partei_id
		ORDER BY m.partei_id
                );
                		
	BEGIN

               FOREACH i IN ARRAY stimmenarr
               LOOP
               div = div + (i*1.0/mindestsitze);
               END LOOP;
               

		IF (db.utilbtg(stimmenarr,mandatarr,div) > 0) THEN
			direction = 100;
		ELSE 
			direction = -100;
		END IF;
		
		while db.utilbtg(stimmenarr,mandatarr,div) != 0 LOOP

			div = div + direction;
			
		END LOOP;

		RETURN div;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW db.btmandatepartei2009 AS (

WITH div as (SELECT * FROM db.getdivisormaxbt2009())

 select zpl.partei_id, round(sum(zpl.stimmen)*1.0/(Select * FROM div))
		from db.zweitstimmenproland2009 zpl
		group by zpl.partei_id);
