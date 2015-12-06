CREATE OR REPLACE VIEW wahlkreissieger2009 as (
With reszweit as (select p.name, fkwahlkreis
from ergebnissezweit ez, parteien p
where 	ez.jahr = 2009 and
	ez.fkpartei = p.id and ez.stimmen = (
					select max(sub.stimmen)
					from ergebnissezweit sub
					where ez.fkwahlkreis = sub.fkwahlkreis and ez.jahr = sub.jahr
					)
group by p.name, fkwahlkreis )
select wk.id, wk.name, p.name as erst, res.name  as zweit, b.name as bname
from direktmandate2009 dm, parteien p, wahlkreise wk, reszweit res, bundesländer b
where dm.idpartei = p.id and dm.idwahlkreis = wk.id and res.fkwahlkreis = wk.id and wk.fkbundesland = b.id
)