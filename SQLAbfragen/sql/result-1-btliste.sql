 WITH bt AS (SELECT * FROM bundestag2013)
 
 SELECT bt.name,
    count(bt.name) AS count
   FROM bt
  GROUP BY bt.name;