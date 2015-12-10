
CREATE OR REPLACE FUNCTION public.generateTokens () RETURNS void AS
$$

	DECLARE 
		anz_wahlber integer;
		i integer;

	BEGIN

	BEGIN
        FOR i IN 1..299
        LOOP

        SELECT wähler13 INTO anz_wahlber FROM wahlkreise WHERE id = i;

        INSERT INTO token (wk_id, token_id, used) SELECT i, generate_series, False FROM generate_series(1, anz_wahlber) series;
	
	END LOOP;
	COMMIT;
   	END;
   	
$$
LANGUAGE plpgsql VOLATILE
