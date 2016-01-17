CREATE OR REPLACE FUNCTION db.getDirectSeats(year_e integer) 
RETURNS TABLE(wahlkreis_id integer, bewerber_id integer, partei_id integer, year_elec integer) 
AS $$
BEGIN
RETURN QUERY (SELECT ee.fkwahlkreis AS wahlkreis_id,
    b.id AS bewerber_id,
    p.id AS partei_id,
    year_e
	FROM db.ergebnisseerst ee
	JOIN db.bewerber b ON b.id = ee.fkbewerber
	LEFT JOIN db.parteien p ON p.id = b.fkpartei
	WHERE ee.jahr = year_e
	GROUP BY ee.fkwahlkreis, b.id, p.id, ee.stimmen
	HAVING ee.stimmen = (( SELECT max(sub.stimmen) AS max
				FROM db.ergebnisseerst sub
				WHERE ee.fkwahlkreis = sub.fkwahlkreis AND sub.jahr = year_e)));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.getDirectSeatsPerParty() 
RETURNS TABLE(partei_id integer, direktmandate integer, year_elec integer) 
AS $$
BEGIN
RETURN QUERY (SELECT d.partei_id, cast(count(d.partei_id) as int) as direktmandate, d.year_elec
FROM direktmandate d
GROUP BY d.partei_id, d.year_elec);
END;
$$ LANGUAGE plpgsql;

-- helper function to get first step divisor (seats per federal state)
CREATE OR REPLACE FUNCTION db.returnseats (
        bevarr integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE
		ret integer := 0;
		i integer;
	BEGIN

        FOREACH i IN ARRAY bevarr
        LOOP
        ret = ret + round(i * 1.0/ a);
        END LOOP;

	return ret;
   	END;
$$ LANGUAGE plpgsql;

-- get first step divisor (seats per federal state)
CREATE OR REPLACE FUNCTION db.getFederalDivisor(year_elec integer
	) RETURNS integer AS $$
	DECLARE 
		div integer; 
		direction integer;
		bevarr integer[];		
	BEGIN
                IF year_elec = 2013 THEN bevarr = array(select bevölkerung13 from db.bundesländer); 
                ELSE bevarr = array(select bevölkerung09 from db.bundesländer); END IF;
	
		div = db.returnseats(bevarr, 1) / 598;
			
		IF (db.returnseats(bevarr, div) > 598) THEN direction = 1; ELSE direction = -1; END IF;
		
		while db.returnseats(bevarr, div) != 598 LOOP
			div = div + direction;
		END LOOP;

		RETURN div;
   	END;
$$ LANGUAGE plpgsql;

-- get first step divisor (seats per federal state)
CREATE OR REPLACE FUNCTION db.getLegalParties(year_e integer
	) RETURNS TABLE(partei_id integer, total integer, direktmandate integer, year_elec integer) 
 

	AS $$
	BEGIN

	CREATE temp table IF NOT EXISTS direktmandate AS (SELECT * FROM db.getDirectSeats(2009) UNION SELECT * FROM db.getDirectSeats(2013));

	
	RETURN QUERY (SELECT p.id, cast(zs.total AS int), cast(COALESCE(d.direktmandate, 0) AS int) AS direktmandate, year_e AS year_elec
	
	FROM (SELECT dm.partei_id,
		count(dm.partei_id) AS direktmandate
		FROM direktmandate dm
		WHERE dm.year_elec = year_e
		GROUP BY dm.partei_id) d
		
	RIGHT JOIN db.parteien p ON d.partei_id = p.id
	JOIN zweitstimmen zs ON p.id = zs.id
          
	WHERE (zs.total::numeric / (( SELECT sum(a.total) AS sum
					FROM zweitstimmen a))) >= 0.05 OR d.direktmandate >= 3);
	
	END;
$$ LANGUAGE plpgsql;

-- util to map seats to party 
CREATE OR REPLACE FUNCTION db.utilSeatsToParty (
        stimmarr integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE 
		ret integer := 0;
		i integer;
	BEGIN	
                FOREACH i IN ARRAY stimmarr
                LOOP ret = ret + round(i * 1.0/ a); END LOOP;
	return ret;
   	END;
$$ LANGUAGE plpgsql;

-- real party seats per federal state
CREATE OR REPLACE FUNCTION db.generateREALSitzeProLand (year_e integer) 
RETURNS TABLE(bl_id integer, partei_id integer, sitze integer, year_elec integer) AS
$$
	DECLARE 
		direction integer;
		i integer;
		div integer;
		sitzefuerLand integer;
		stimmenarr integer[];
	BEGIN

        create temp table IF NOT EXISTS res (bl_id integer, partei_id integer, sitze integer, year_elec integer);

        -- zweitstimmen pro bundesland
        create temp table IF NOT EXISTS zweitstimmenProLand AS 
	(SELECT bl.id AS bl_id, ez.fkpartei AS partei_id, sum(ez.stimmen) AS stimmen, ez.jahr AS year_elec
	FROM db.ergebnissezweit ez 
	JOIN db.legalParties lp ON ez.fkpartei = lp.partei_id AND ez.jahr = lp.year_elec
	JOIN db.wahlkreise wk ON ez.fkwahlkreis = wk.id
	JOIN db.bundesländer bl ON wk.fkbundesland = bl.id
	GROUP BY ez.fkpartei, bl.id, ez.jahr);

	create temp table IF NOT EXISTS sitzeProLand AS (
	(SELECT bl.id, 
	round(bl.bevölkerung13::numeric * 1.0 / (( SELECT db.getFederalDivisor(2013) AS getdivisor))::numeric) AS sitze,
	2013 AS year_elec
	FROM db.bundesländer bl)
	UNION
	(SELECT bl.id, 
	round(bl.bevölkerung09::numeric * 1.0 / (( SELECT db.getFederalDivisor(2009) AS getdivisor))::numeric) AS sitze,
	2009 AS year_elec
	FROM db.bundesländer bl));

        FOR i IN 1..16
        LOOP 
	stimmenarr = array(
		select zpl.stimmen from zweitstimmenProLand zpl where zpl.bl_id = i AND zpl.year_elec = year_e);
	sitzefuerLand = 
		(select spl.sitze from sitzeProLand spl where spl.id = i AND spl.year_elec = year_e);

        div = db.utilSeatsToParty(stimmenarr,1)/sitzefuerLand;	
	IF (db.utilSeatsToParty(stimmenarr,div) > sitzefuerLand ) THEN direction = 100; ELSE direction = -100; END IF;
		
	while db.utilSeatsToParty(stimmenarr,div) != sitzefuerLand LOOP
		div = div + direction;
	END LOOP;
		        
        INSERT INTO res (bl_id, partei_id, sitze, year_elec) 
        (select z.bl_id, z.partei_id, round(z.stimmen * 1.0/div) as sitze, year_e from zweitstimmenProLand z 
        WHERE z.year_elec = year_e AND z.bl_id = i);        
	END LOOP;
	
	RETURN QUERY SELECT * FROM res;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.utilbtg (stimmarr integer[], mandatarr integer[], a integer) RETURNS integer AS $$
	DECLARE 
		ret integer := 0;
		i integer;
		diff integer;
		mand integer;
	BEGIN
                FOR i IN 1..array_length(stimmarr, 1)
                LOOP 
                mand = round(stimmarr[i] * 1.0/ a);
                IF mand < mandatarr[i] THEN ret = ret - (mandatarr[i] - mand); END IF;
                END LOOP;
	return ret;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.getDivisorMaxBt (year_e integer) 
RETURNS integer AS $$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;
		mindestsitze integer;	 
		
                -- array mit zweitstimmen für partei
                stimmenarr integer[];
                mandatarr integer[];
	BEGIN
	        -- minimale Sitzanzahl pro land
		CREATE temp table if not exists minSitzeProLand AS 
		((SELECT spl.bl_id, spl.partei_id, GREATEST(spl.sitze, count(dm.partei_id)), 2013 AS year_elec FROM db.generateREALSitzeProLand(2013) spl
		JOIN db.wahlkreise wk ON wk.fkbundesland = spl.bl_id
		left JOIN direktmandate dm ON spl.partei_id = dm.partei_id AND wk.id = dm.wahlkreis_id AND dm.year_elec = 2013
		GROUP BY spl.bl_id, spl.partei_id, spl.sitze) UNION
		(SELECT spl.bl_id, spl.partei_id, GREATEST(spl.sitze, count(dm.partei_id)), 2009 AS year_elec 
		FROM db.generateREALSitzeProLand(2009) spl JOIN db.wahlkreise wk ON wk.fkbundesland = spl.bl_id left 
		JOIN direktmandate dm ON spl.partei_id = dm.partei_id AND wk.id = dm.wahlkreis_id AND dm.year_elec = 2009 
		GROUP BY spl.bl_id, spl.partei_id, spl.sitze));

		mindestsitze  =
		(select sum(m.greatest)
	        from minSitzeProLand m WHERE m.year_elec = year_e);	

		stimmenarr =array(
                select sum(zpl.stimmen) as sumstimm
		from zweitstimmenproland zpl
		where zpl.year_elec = year_e
		group by zpl.partei_id
		ORDER BY zpl.partei_id);
		
		mandatarr = array(
                select sum(m.greatest) as summand
		from minSitzeProLand m
		WHERE m.year_elec = year_e
		group by m.partei_id
		ORDER BY m.partei_id);


               FOREACH i IN ARRAY stimmenarr LOOP div = div + (i*1.0/mindestsitze); END LOOP;
		IF (db.utilbtg(stimmenarr,mandatarr,div) > 0) THEN direction = 100; ELSE direction = -100; END IF;
		
		while db.utilbtg(stimmenarr,mandatarr,div) != 0 LOOP
			div = div + direction;
		END LOOP;
		RETURN div;
   	END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION db.utilmpl (
        direktproland integer[],
        parteistimmenproland integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE 
		ret integer := 0;
		i integer;
	BEGIN
                FOR i IN 1..array_length(direktproland, 1)
                LOOP
                IF parteistimmenproland[i] > 0 THEN
                ret = ret + GREATEST (direktproland[i], round(parteistimmenproland[i] * 1.0/ a));
                END IF;
                END LOOP;
	return ret;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.mandateproland (year_e integer) 
RETURNS TABLE(bl_id integer, partei_id integer, sitze integer, year_elec integer) 
AS $$
	DECLARE 
		direction integer;
		div integer := 0;
		i integer;
		loopid integer;
		gesmandate integer;

                parteiids integer[] := 
                array(SELECT * FROM (select DISTINCT z.partei_id
                from zweitstimmenproland z WHERE z.year_elec = year_e
                ORDER BY partei_id) a);

                direktproland integer[];
                parteistimmenproland integer[];
                länderids integer[] := array(SELECT * FROM generate_series(1,16));

	BEGIN


		create temp table if not exists divBTM09 as (SELECT * FROM db.getdivisormaxbt(2009));
		create temp table if not exists divBTM13 as (SELECT * FROM db.getdivisormaxbt(2013));

		create temp table if not exists btMandatePartei AS (
		(select zpl.partei_id, round(sum(zpl.stimmen)*1.0/(Select * FROM divBTM13)), 2013 AS year_elec
		from zweitstimmenproland zpl
		WHERE zpl.year_elec = 2013
		group by zpl.partei_id)
		UNION
		(select zpl.partei_id, round(sum(zpl.stimmen)*1.0/(Select * FROM divBTM09)), 2009 AS year_elec
		from zweitstimmenproland zpl
		WHERE zpl.year_elec = 2009
		group by zpl.partei_id));

               create temp table if not exists mandateproland (bl_id integer, partei_id integer, sitze integer) on commit drop;

               FOREACH loopid IN ARRAY parteiids
               LOOP

		gesmandate = (SELECT bt.round from btmandatepartei bt where bt.partei_id = loopid AND bt.year_elec = year_e);
                div = (SELECT sum(ps.stimmen) FROM zweitstimmenproland ps WHERE ps.partei_id = loopid AND ps.year_elec = year_e
                GROUP BY ps.partei_id)*1.0/gesmandate;

                direktproland = array(SELECT coalesce(count,0) FROM generate_series(1,16) k LEFT JOIN 
                (SELECT wk.fkbundesland, count(*) FROM direktmandate dm JOIN db.wahlkreise wk ON dm.wahlkreis_id = wk.id WHERE dm.partei_id = loopid
                AND dm.year_elec = year_e
                GROUP BY wk.fkbundesland ORDER BY wk.fkbundesland) l ON k.k = l.fkbundesland);

		parteistimmenproland = array(SELECT coalesce(stimmen,0) FROM generate_series(1,16) k
		LEFT JOIN (SELECT ps.bl_id, stimmen FROM zweitstimmenproland ps WHERE ps.partei_id = loopid AND ps.year_elec = year_e) l ON k.k = l.bl_id );
		                
               IF (db.utilmpl(direktproland,parteistimmenproland,div) > gesmandate) THEN direction = 1; ELSE direction = -1;END IF;

               while db.utilmpl(direktproland,parteistimmenproland,div) != gesmandate 
               LOOP div = div + direction; RAISE NOTICE 'Value of a : %', div; END LOOP;
		
               FOR i IN 1..array_length(direktproland,1)
               LOOP

               INSERT INTO mandateproland VALUES
               (länderids[i], loopid, (SELECT GREATEST (direktproland[i],round(parteistimmenproland[i] * 1.0/ div))));
               END LOOP;

		
               END LOOP;

	       RETURN QUERY SELECT *, year_e AS year_elec FROM mandateproland;
    	END;
$$ LANGUAGE plpgsql;

   	
$$ LANGUAGE plpgsql;








WITH 

-- currently not used
zweitstimmen AS (SELECT p.id, sum(ez.stimmen), ez.jahr AS total
	FROM db.parteien p
	JOIN db.ergebnissezweit ez ON p.id = ez.fkpartei
	GROUP BY p.id, ez.jahr),


-- create view direct mandates per party
-- currently not used
numDirektmandate AS (SELECT * FROM db.getDirectSeatsPerParty()),

-- currently not used
legalParties AS (SELECT * FROM db.getLegalParties(2013) UNION SELECT * FROM db.getLegalParties(2009))


 

SELECT * FROM db.mandateproland(2013);
SELECT * FROM btMandatePartei ORDER BY partei_id