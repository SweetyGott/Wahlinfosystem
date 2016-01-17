-- Function: public.utilsnp(integer[], integer)

-- DROP FUNCTION public.utilsnp(integer[], integer);

CREATE OR REPLACE FUNCTION utilsnp(
    stimmarr integer[],
    a integer)
  RETURNS integer AS
$BODY$
	DECLARE 
		ret integer;
		i integer;
	
	BEGIN

	ret = 0;
	
                FOREACH i IN ARRAY stimmarr
                LOOP 
                ret = ret + round(i * 1.0/ a);
                END LOOP;
                
	return ret;
   	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION utilsnp(integer[], integer)
  OWNER TO postgres;
