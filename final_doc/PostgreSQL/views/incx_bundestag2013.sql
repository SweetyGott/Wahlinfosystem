CREATE OR REPLACE FUNCTION db.getzweitbt2013 () 
RETURNS TABLE (id integer) AS $$

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

	create temporary table pml as (SELECT * FROM db.parteimandateproland2013 pm WHERE pm.sitze != 0);
	create temporary table dirm as (SELECT * FROM db.direktmandate2013);

	create temporary table listerest AS (SELECT bl_id , partei_id, (sitze-
	(SELECT count(*) FROM dirm JOIN db.wahlkreise wk ON dirm.idwahlkreis = wk.id 
	WHERE bl_id = wk.fkbundesland AND partei_id = dirm.idpartei)) as anzliste FROM pml);

	create temporary table direkt as (SELECT b.id, b.vorname, b.nachname, p.name FROM dirm 
	LEFT JOIN db.bewerber b ON b.id = dirm.idbewerber
	LEFT JOIN db.parteien p ON p.id = b.fkpartei);

        create temporary table res (id integer);
        
        -- START OF LOGIC

        FOREACH listeid IN ARRAY array(SELECT lp.id FROM db.landeslisten lp JOIN db.legaleparteien2013 l ON lp.fkpartei = l.id)
        LOOP

        fill = (SELECT anzliste 
        FROM listerest lr 
        JOIN db.landeslisten ll ON ll.fkbundesland = lr.bl_id AND ll.fkpartei = lr.partei_id AND ll.jahr = 2013
        WHERE ll.id = listeid);

        i = 1;
        j = 1;
        while i <= fill AND j < (SELECT max(lp.rang) FROM db.listenplätze lp WHERE lp.fkliste = listeid)
        LOOP

        bewid = (SELECT lp.fkbewerber FROM db.listenplätze lp WHERE lp.fkliste = listeid AND lp.rang = j
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
        $$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW db.bundestag2013 AS(SELECT * FROM (

(SELECT b.id, b.nachname, b.vorname,p.name, 'ZWEIT' FROM db.getzweitbt2013() dz 
JOIN db.bewerber b ON dz.id = b.id
JOIN db.parteien p on p.id = b.fkpartei)

UNION 

(SELECT b.id, b.nachname, b.vorname,p.name, 'ERST'
FROM db.direktmandate2013 dirma
JOIN db.bewerber b ON dirma.idbewerber = b.id
JOIN db.parteien p on p.id = b.fkpartei)

) a ORDER BY nachname
);

