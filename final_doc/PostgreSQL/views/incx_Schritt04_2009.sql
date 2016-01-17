CREATE OR REPLACE FUNCTION db.utilmpl (
        direktproland integer[],
        parteistimmenproland integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE 
		ret integer;
		i integer;
	
	BEGIN

	ret = 0;
	
                FOR i IN 1..array_length(direktproland, 1)
                LOOP

/*
        RAISE NOTICE 'i (%)', i;
        RAISE NOTICE 'dir (%)', direktproland[i];
        RAISE NOTICE 'zw (%)', parteistimmenproland[i];
        RAISE NOTICE 'r (%)', round(parteistimmenproland[i] * 1.0/ a);
*/

                IF parteistimmenproland[i] > 0 THEN
                ret = ret + GREATEST (direktproland[i], round(parteistimmenproland[i] * 1.0/ a));
                END IF;
                END LOOP;

      --  RAISE NOTICE 'ret is (%)', ret;

	return ret;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.mandateproland2009 () 
RETURNS TABLE(bl_id integer, partei_id integer, sitze integer) 
AS $$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;
		loopid integer;
		gesmandate integer;

                parteiids integer[] := 
                array(SELECT * FROM (select DISTINCT z.partei_id
                from db.zweitstimmenproland2009 z
                ORDER BY partei_id) a);

                --
                
                direktproland integer[];
                parteistimmenproland integer[];
                länderids integer[] := array(SELECT * FROM generate_series(1,16));

	BEGIN
		drop table dm;
		drop table bt;
		drop table ps;
		
               create temporary table dm as (select * from db.direktmandate2009);
               create temporary table bt as (select * from db.btmandatepartei2009);
               create temporary table ps as (select * from db.zweitstimmenproland2009);

               create temporary table mandateproland (bl_id integer, partei_id integer, sitze integer) on commit drop;

               FOREACH loopid IN ARRAY parteiids
               LOOP


		gesmandate = (SELECT bt.round from bt where bt.partei_id = loopid);
                div = (SELECT sum(ps.stimmen) FROM ps WHERE ps.partei_id = loopid GROUP BY ps.partei_id)*1.0/gesmandate;

                direktproland = array(SELECT coalesce(count,0) FROM generate_series(1,16) k LEFT JOIN 
                (SELECT wk.fkbundesland, count(*) FROM dm JOIN db.wahlkreise wk ON dm.idwahlkreis = wk.id WHERE idpartei = loopid
                GROUP BY wk.fkbundesland ORDER BY wk.fkbundesland) l ON k.k = l.fkbundesland);

		parteistimmenproland = array(SELECT coalesce(stimmen,0) FROM generate_series(1,16) k
		LEFT JOIN (SELECT ps.bl_id, stimmen FROM ps WHERE ps.partei_id = loopid) l ON k.k = l.bl_id );
		                
               IF (db.utilmpl(direktproland,parteistimmenproland,div) > gesmandate) THEN
			direction = 1;
		ELSE 
			direction = -1;
		END IF;

                while db.utilmpl(direktproland,parteistimmenproland,div) != gesmandate 
                LOOP
			div = div + direction;
		END LOOP;
		
               FOR i IN 1..array_length(direktproland,1)
               LOOP

               INSERT INTO mandateproland VALUES
               (länderids[i], loopid, (SELECT GREATEST (direktproland[i],round(parteistimmenproland[i] * 1.0/ div))));
               END LOOP;

		
               END LOOP;

	       RETURN QUERY SELECT * FROM mandateproland;
   	END;
$$ LANGUAGE plpgsql;

CREATE VIEW db.parteimandateproland2009 AS (SELECT * FROM db.mandateproland2009());

