-- Function: public.utilmpl(integer[], integer[], integer)

-- DROP FUNCTION public.utilmpl(integer[], integer[], integer);

CREATE OR REPLACE FUNCTION utilmpl(
    direktproland integer[],
    parteistimmenproland integer[],
    a integer)
  RETURNS integer AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION utilmpl(integer[], integer[], integer)
  OWNER TO postgres;
