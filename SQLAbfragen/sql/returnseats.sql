-- Function: public.returnseats(integer[], integer)

-- DROP FUNCTION public.returnseats(integer[], integer);

CREATE OR REPLACE FUNCTION returnseats(
    bevarr integer[],
    a integer)
  RETURNS integer AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION returnseats(integer[], integer)
  OWNER TO postgres;
