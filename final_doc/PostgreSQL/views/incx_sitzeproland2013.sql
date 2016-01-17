CREATE OR REPLACE VIEW db.sitzeproland2013 AS 
 SELECT bl.id,
    round(bl.bevölkerung13::numeric * 1.0 / (( SELECT db.getdivisor13() AS getdivisor))::numeric) AS sitze
   FROM db.bundesländer bl;
