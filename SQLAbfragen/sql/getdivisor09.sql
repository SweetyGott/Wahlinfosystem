-- Function: public.getdivisor09()

-- DROP FUNCTION public.getdivisor09();

CREATE OR REPLACE FUNCTION getdivisor09()
  RETURNS integer AS
$BODY$
	DECLARE 
		div integer; 
		direction integer;

		bevarr integer[] :=
		array(select bevölkerung09 from bundesländer);
		
	BEGIN
		div = returnseats(bevarr, 1) / 598;
			
		IF ( returnseats(bevarr, div) > 598 ) THEN
			direction = 1;
		ELSE 
			direction = -1;
		END IF;
		
		while returnseats(bevarr, div) != 598 LOOP
			div = div + direction;
		END LOOP;

		RETURN div;
   	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION getdivisor09()
  OWNER TO postgres;