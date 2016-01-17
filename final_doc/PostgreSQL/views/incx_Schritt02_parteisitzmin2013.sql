CREATE OR REPLACE FUNCTION db.generateREALSitzeProLand2013 () 
RETURNS TABLE(bl_id integer, partei_id integer, sitze integer) AS
$$
	DECLARE 
		i integer;
		div integer;
	BEGIN

        create temporary table res (bl_id integer, partei_id integer, sitze integer) on commit drop;

        FOR i IN 1..16
        LOOP

        div = db.getdivisor2snp2013(i);
        
        INSERT INTO res (bl_id,partei_id,sitze) 
        select z.bl_id,z.partei_id, round(z.stimmen*1.0/div) as sitze from db.zweitstimmenproland2013 z 
        where z.bl_id = i;
        
	END LOOP;

	RETURN QUERY SELECT * FROM res;
   	END;
   	
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW db.minsitzeproland2013 AS 
SELECT spl.bl_id, spl.partei_id, GREATEST(spl.sitze, count(dm.idpartei)) FROM db.generateREALSitzeProLand2013 () spl

JOIN db.wahlkreise wk ON wk.fkbundesland = spl.bl_id
left JOIN db.direktmandate2013 dm ON spl.partei_id = dm.idpartei AND wk.id = dm.idwahlkreis

GROUP BY spl.bl_id, spl.partei_id, spl.sitze;

