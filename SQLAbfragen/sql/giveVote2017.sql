CREATE OR REPLACE FUNCTION public.insertstimme( wk_ integer, token_id_ integer, voteerst_ integer, votezweit_ integer)
	RETURNS boolean AS $$
BEGIN
	IF 
		(select t1.used from token t1 where wk_id = wk_ and token_id = token_id_) = false 
	THEN
		INSERT INTO stimmzettel(erststimme, zweitstimme, jahr, fkwahlkreis)
		VALUES ( voteerst_, votezweit_, 2017, wk_);
		
		UPDATE token
		set used = true
		where wk_id = wk_ and token_id = token_id_;
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END;
$$ LANGUAGE plpgsql;


--SELECT insertstimme(215, 2, 7200, 64);
--select * from stimmzettel s where s.jahr = 2017
--select * from token t where t.wk_id = 215