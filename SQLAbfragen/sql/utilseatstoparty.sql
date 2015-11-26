-- Function: public.utilseatstoparty(integer[], integer)

-- DROP FUNCTION public.utilseatstoparty(integer[], integer);

CREATE OR REPLACE FUNCTION utilseatstoparty(
    stimmarr integer[],
    a integer)
  RETURNS integer AS
$BODY$
	DECLARE 
		ret integer := 0;
		i integer;
	BEGIN	
                FOREACH i IN ARRAY stimmarr
                LOOP ret = ret + round(i * 1.0/ a); END LOOP;
	return ret;
   	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION utilseatstoparty(integer[], integer)
  OWNER TO postgres;
