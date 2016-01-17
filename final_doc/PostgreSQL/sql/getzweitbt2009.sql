﻿-- Function: public.getzweitbt2009()

-- DROP FUNCTION public.getzweitbt2009();

CREATE OR REPLACE FUNCTION getzweitbt2009()
  RETURNS TABLE(id integer) AS
$BODY$

	DECLARE 
        listeid integer;
        fill integer;
        i integer;
        j integer;
        bewid integer;
        
        BEGIN

	drop table if exists dm;
	drop table if exists pml;
	drop table if exists dirm;
	drop table if exists listerest;
	drop table if exists direkt;
	drop table if exists res;

	create temp table pml as (SELECT * FROM parteimandateproland2009 pm WHERE pm.sitze != 0);
	create temp table dirm as (SELECT * FROM direktmandate2009);

	create temp table listerest AS (SELECT bl_id , partei_id, (sitze-
	(SELECT count(*) FROM dirm JOIN wahlkreise wk ON dirm.idwahlkreis = wk.id 
	WHERE bl_id = wk.fkbundesland AND partei_id = dirm.idpartei)) as anzliste FROM pml);

	create temp table direkt as (SELECT b.id, b.vorname, b.nachname, p.name FROM dirm 
	LEFT JOIN bewerber b ON b.id = dirm.idbewerber
	LEFT JOIN parteien p ON p.id = b.fkpartei);

        create temp table res (id integer);
        
        -- START OF LOGIC

        FOREACH listeid IN ARRAY array(SELECT lp.id FROM landeslisten lp JOIN legaleparteien2009 l ON lp.fkpartei = l.id)
        LOOP

        fill = (SELECT anzliste 
        FROM listerest lr 
        JOIN landeslisten ll ON ll.fkbundesland = lr.bl_id AND ll.fkpartei = lr.partei_id AND ll.jahr = 2009
        WHERE ll.id = listeid);

        i = 1;
        j = 1;
        while i <= fill AND j < (SELECT max(lp.rang) FROM listenplätze lp WHERE lp.fkliste = listeid)
        LOOP

        bewid = (SELECT lp.fkbewerber FROM listenplätze lp WHERE lp.fkliste = listeid AND lp.rang = j
        AND not exists (SELECT * FROM direkt WHERE direkt.id = lp.fkbewerber));

        IF bewid IS NOT NULL THEN
        INSERT INTO res (SELECT bewid);
        i = i+1;
        END IF;
        j = j+1;

        END LOOP;

        END LOOP;

        RETURN QUERY (SELECT * FROM res);
        END;
        $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION getzweitbt2009()
  OWNER TO postgres;