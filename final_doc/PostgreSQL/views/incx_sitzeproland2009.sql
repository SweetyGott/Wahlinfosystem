CREATE OR REPLACE VIEW db.sitzeproland2009 AS 
 SELECT bl.id,
    round(bl.bevölkerung09::numeric * 1.0 / (( SELECT db.getdivisor09() AS getdivisor))::numeric) AS sitze
   FROM db.bundesländer bl;
