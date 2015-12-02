CREATE OR REPLACE FUNCTION kaf.f_get_id_clasificaciones (
  p_id_clasificacion integer,
  p_padres_hijos varchar = 'hijos'::character varying
)
RETURNS varchar AS
$body$
/*
Autor: RCM
Fecha: 09/12/2015
Descripción: Devuelve los IDS padres o hijos de la rama de un ID clasificacion
*/
DECLARE

  v_ids varchar;

BEGIN

  if p_id_clasificacion is null then
      return '(null)';
    end if;

  if p_padres_hijos = 'padres' then
        WITH RECURSIVE t(id,id_fk,nombre,n) AS (
              SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
              FROM kaf.tclasificacion l
              WHERE l.id_clasificacion = p_id_clasificacion
              UNION ALL
              SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
              FROM kaf.tclasificacion l, t
              WHERE l.id_clasificacion = t.id_fk
          )
          SELECT (pxp.list(id::text))::varchar
          INTO v_ids
          FROM t;
          
    
    else
      WITH RECURSIVE t(id,id_fk,nombre,n) AS (
            SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
            FROM kaf.tclasificacion l
            WHERE l.id_clasificacion = p_id_clasificacion
            UNION ALL
            SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
            FROM kaf.tclasificacion l, t
            WHERE l.id_clasificacion_fk = t.id
        )
        SELECT (pxp.list(id::text))::varchar
        INTO v_ids
        FROM t;
    
    end if;
    
    return v_ids;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;