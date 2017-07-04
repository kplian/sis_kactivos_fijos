CREATE OR REPLACE FUNCTION kaf.f_get_codigo_clasificacion_rec (
  p_id_clasificacion integer
)
RETURNS varchar AS
$body$
DECLARE

    v_ids varchar;
    v_rec record;
    v_loc varchar;

BEGIN

    --Obtencion de los IDS
    v_ids = kaf.f_get_id_clasificaciones (p_id_clasificacion,'padres');
    v_loc='';
    if v_ids is not null then
        for v_rec in execute('select *
                            from kaf.tclasificacion
                            where id_clasificacion in ('||v_ids||')
                            order by id_clasificacion') loop
            v_loc = v_loc || '.'|| coalesce(v_rec.codigo,'S/C');
        
        end loop;
        
        v_loc = substr(v_loc,2,length(v_loc));
    end if;
    
    
    return v_loc;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;