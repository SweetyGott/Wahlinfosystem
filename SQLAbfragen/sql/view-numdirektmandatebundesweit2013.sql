CREATE OR REPLACE VIEW public.numdirektmandatebundesweit2013 AS 
(SELECT idpartei as id, count(idpartei) as direktmandate, 2013 as jahr
FROM direktmandate2013 dm 
GROUP BY idpartei);