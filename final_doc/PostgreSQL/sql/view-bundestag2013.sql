-- View: public.bundestag2013

-- DROP VIEW public.bundestag2013;

CREATE OR REPLACE VIEW bundestag2013 AS 
 SELECT a.id,
    a.nachname,
    a.vorname,
    a.name,
    a.text
   FROM ( SELECT b.id,
            b.nachname,
            b.vorname,
            p.name,
            'ZWEIT'::text AS text
           FROM getzweitbt2013() dz(id)
             JOIN bewerber b ON dz.id = b.id
             JOIN parteien p ON p.id = b.fkpartei
        UNION
         SELECT b.id,
            b.nachname,
            b.vorname,
            p.name,
            'ERST'::text AS text
           FROM direktmandate2013 dirma
             JOIN bewerber b ON dirma.idbewerber = b.id
             JOIN parteien p ON p.id = b.fkpartei) a
  ORDER BY a.nachname;

ALTER TABLE bundestag2013
  OWNER TO postgres;
