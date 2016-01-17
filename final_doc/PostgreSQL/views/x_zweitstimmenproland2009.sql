CREATE OR REPLACE VIEW db.zweitstimmenProLand2009 as (

select bl.id as bl_id, ez.fkpartei as partei_id, sum(ez.stimmen) as stimmen
from db.ergebnissezweit ez, db.bundesländer bl, db.wahlkreise wk, db.legaleparteien2009 lp
where ez.jahr = 2009 and ez.fkwahlkreis = wk.id and wk.fkbundesland = bl.id and ez.fkpartei = lp.id
group by ez.fkpartei, bl.id 

);
