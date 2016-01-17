-- Function: public.utilbtg(integer[], integer[], integer)

-- DROP FUNCTION public.utilbtg(integer[], integer[], integer);

CREATE OR REPLACE FUNCTION utilbtg(
    stimmarr integer[],
    mandatarr integer[],
    a integer)
  RETURNS integer AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION utilbtg(integer[], integer[], integer)
  OWNER TO postgres;
