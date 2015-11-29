--DROP FUNCTION schritt01();
--DROP table if exists bundessitze;

CREATE OR REPLACE FUNCTION schritt01 (
	) RETURNS TABLE (id integer, mandat integer) AS $$
	BEGIN
	
	if to_regclass('bundessitze') is null then
		create temp table bundessitze as ( select bl.id, bl.name, bl.bevölkerung13, round( bl.bevölkerung13*1.0/
											((select sum(bl2.bevölkerung13)
											from bundesländer bl2)
											/
											598.0))::integer as mandate
					from bundesländer bl);
		
		WHILE ( select sum(bs.mandate) from bundessitze bs ) < 598 LOOP
			UPDATE bundessitze
			SET mandate = mandate + 1
			WHERE bevölkerung13/(mandate+0.5) = ( 	select max(bs.bevölkerung13/(mandate+0.5))
								from bundessitze bs) ;
		END LOOP;

		WHILE ( select sum(bs.mandate) from bundessitze bs ) > 598 LOOP
			UPDATE bundessitze
			SET mandate = mandate - 1
			WHERE floor(bevölkerung13/(mandate-0.5)) = floor( ( 	select min(bs.bevölkerung13/(mandate+0.5))
										from bundessitze bs));
		END LOOP;

	END IF;
	

	return query select ret.id, ret.mandate from bundessitze ret;
	END;
$$ LANGUAGE plpgsql;

select *
from schritt01();


