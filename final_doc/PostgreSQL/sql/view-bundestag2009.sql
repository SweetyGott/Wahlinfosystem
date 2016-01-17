-- View: public.bundestag2009

-- DROP VIEW public.bundestag2009;

CREATE OR REPLACE VIEW bundestag2009 AS 
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
           FROM getzweitbt2009() dz(id)
             JOIN bewerber b ON dz.id = b.id
             JOIN parteien p ON p.id = b.fkpartei
        UNION
         SELECT b.id,
            b.nachname,
            b.vorname,
            p.name,
            'ERST'::text AS text
           FROM direktmandate2009 dirma
             JOIN bewerber b ON dirma.idbewerber = b.id
             JOIN parteien p ON p.id = b.fkpartei) a
  ORDER BY a.nachname;

ALTER TABLE bundestag2009
  OWNER TO postgres;
