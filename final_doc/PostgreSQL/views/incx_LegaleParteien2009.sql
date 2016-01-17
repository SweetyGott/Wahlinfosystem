﻿CREATE OR REPLACE VIEW db.legaleparteien2009 AS 
 WITH zweitstimmen AS (
         SELECT p_1.id,
            sum(ez.stimmen) AS total
           FROM db.parteien p_1
             JOIN db.ergebnissezweit ez ON p_1.id = ez.fkpartei
          WHERE ez.jahr = 2009
          GROUP BY p_1.id
        ), numdirektmandatebundesweit2009 AS (
         SELECT dm.idpartei,
            count(dm.idpartei) AS direktmandate
           FROM db.direktmandate2009 dm
          GROUP BY dm.idpartei
        )
 SELECT p.id,
    zs.total,
    COALESCE(d.direktmandate, 0::bigint) AS direktmandate
   FROM numdirektmandatebundesweit2009 d
     RIGHT JOIN db.parteien p ON d.idpartei = p.id
     JOIN zweitstimmen zs ON p.id = zs.id
  WHERE (zs.total::numeric / (( SELECT sum(a.total) AS sum
           FROM zweitstimmen a))) >= 0.05 OR d.direktmandate >= 3;
