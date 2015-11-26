-- Function: public.getdivisor13()

-- DROP FUNCTION public.getdivisor13();

CREATE OR REPLACE FUNCTION getdivisor13()
  RETURNS integer AS
$BODY$
	DECLARE 
		div integer; 
		direction integer;

		bevarr integer[] :=
		array(select bevölkerung13 from bundesländer);
		
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
ALTER FUNCTION getdivisor13()
  OWNER TO postgres;