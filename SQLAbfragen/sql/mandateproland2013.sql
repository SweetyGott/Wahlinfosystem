-- Function: public.mandateproland2013()

-- DROP FUNCTION public.mandateproland2013();

CREATE OR REPLACE FUNCTION mandateproland2013()
  RETURNS TABLE(bl_id integer, partei_id integer, sitze integer) AS
$BODY$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;
		loopid integer;
		gesmandate integer;

                parteiids integer[] := 
                array(SELECT * FROM (select DISTINCT z.partei_id
                from zweitstimmenproland2013 z
                ORDER BY partei_id) a);

                --
                
                direktproland integer[];
                parteistimmenproland integer[];
                länderids integer[] := array(SELECT * FROM generate_series(1,16));

	BEGIN
		drop table if exists dm;
		drop table if exists bt;
		drop table if exists ps;
		
               create temporary table dm as (select * from direktmandate2013);
               create temporary table bt as (select * from btmandatepartei2013);
               create temporary table ps as (select * from zweitstimmenproland2013);

               create temporary table mandateproland (bl_id integer, partei_id integer, sitze integer) on commit drop;

               FOREACH loopid IN ARRAY parteiids
               LOOP


		gesmandate = (SELECT bt.round from bt where bt.partei_id = loopid);
                div = (SELECT sum(ps.stimmen) FROM ps WHERE ps.partei_id = loopid GROUP BY ps.partei_id)*1.0/gesmandate;

                direktproland = array(SELECT coalesce(count,0) FROM generate_series(1,16) k LEFT JOIN 
                (SELECT wk.fkbundesland, count(*) FROM dm JOIN wahlkreise wk ON dm.idwahlkreis = wk.id WHERE idpartei = loopid
                GROUP BY wk.fkbundesland ORDER BY wk.fkbundesland) l ON k.k = l.fkbundesland);

		parteistimmenproland = array(SELECT coalesce(stimmen,0) FROM generate_series(1,16) k
		LEFT JOIN (SELECT ps.bl_id, stimmen FROM ps WHERE ps.partei_id = loopid) l ON k.k = l.bl_id );
		                
               IF (utilmpl(direktproland,parteistimmenproland,div) > gesmandate) THEN
			direction = 1;
		ELSE 
			direction = -1;
		END IF;

                while utilmpl(direktproland,parteistimmenproland,div) != gesmandate 
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION mandateproland2013()
  OWNER TO postgres;
