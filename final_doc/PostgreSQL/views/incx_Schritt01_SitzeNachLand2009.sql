CREATE OR REPLACE FUNCTION db.returnseats (
        bevarr integer[],
	a integer
	) RETURNS integer AS $$
	DECLARE
		ret integer;
		i integer;
	BEGIN

        ret = 0;
        FOREACH i IN ARRAY bevarr
        LOOP
        ret = ret + round(i * 1.0/ a);
        END LOOP;

	return ret;
   	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION db.getDivisor09 (
	) RETURNS integer AS $$
	DECLARE 
		div integer; 
		direction integer;

		bevarr integer[] :=
		array(select bevölkerung09 from db.bundesländer);
		
	BEGIN
		div = db.returnseats(bevarr, 1) / 598;
			
		IF ( db.returnseats(bevarr, div) > 598 ) THEN
			direction = 1;
		ELSE 
			direction = -1;
		END IF;
		
		while db.returnseats(bevarr, div) != 598 LOOP
			div = div + direction;
		END LOOP;

		RETURN div;
   	END;
$$ LANGUAGE plpgsql;
