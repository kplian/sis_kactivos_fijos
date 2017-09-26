CREATE OR REPLACE FUNCTION kaf.f_get_configuracion_cuenta (
  p_id_movimiento_motivo integer,
  p_id_clasificacion integer
)
RETURNS integer AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_get_configuracion_cuenta
 DESCRIPCION:   Obtiene el ID de la configuracion de la cuenta de la tabla kaf.tclasificacion_cuenta_motivo
 AUTOR: 		RCM
 FECHA:	        15-08-2017
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/
DECLARE

    v_rec                               record;
    v_id_clasificacion_cuenta_motivo    integer;
    v_desc_clasificacion                text;
    v_desc_motivo                       varchar;

BEGIN

    --Obtención de descripción de la clasificación para enviar en el mensaje de error
    select codigo_completo_tmp || ' - ' || nombre
    into v_desc_clasificacion
    from kaf.tclasificacion
    where id_clasificacion = p_id_clasificacion;

    if v_desc_clasificacion is null then
        raise exception 'Clasificación no encontrada';
    end if;

    --Obtención de descripción del motivo para enviar en el mensaje de error
    select 
    cat.descripcion || ' - ' || mm.motivo
    into v_desc_motivo
    from kaf.tmovimiento_motivo mm
    inner join param.tcatalogo cat
    on cat.id_catalogo = mm.id_cat_movimiento
    where mm.id_movimiento_motivo = p_id_movimiento_motivo;

    if v_desc_motivo is null then
        raise exception 'Proceso - Motivo no encontrado';
    end if;

    --Bucle buscando de arriba abajo la configuración a partir de la clasificación enviada
	for v_rec in (WITH RECURSIVE t(id,id_fk,n) AS (
                  SELECT l.id_clasificacion,l.id_clasificacion_fk,1
                  FROM kaf.tclasificacion l
                  WHERE l.id_clasificacion = p_id_clasificacion
                  UNION ALL
                  SELECT l.id_clasificacion,l.id_clasificacion_fk,n+1
                  FROM kaf.tclasificacion l, t
                  WHERE l.id_clasificacion = t.id_fk
                  )
                  SELECT id
                  FROM t
                  ORDER BY n) loop
    	--Busca la configuración
    	select id_clasificacion_cuenta_motivo
        into v_id_clasificacion_cuenta_motivo
        from kaf.tclasificacion_cuenta_motivo
        where id_movimiento_motivo = p_id_movimiento_motivo
        and id_clasificacion = v_rec.id;
        
        --Si encuentra registro devuelve el ID y termina el bucle
        if v_id_clasificacion_cuenta_motivo is not null then
        	return v_id_clasificacion_cuenta_motivo;
        end if;
        
    end loop;
    
    --Si llega hasta aquí significa que no encontró configuración para los parámetros enviados
    raise exception 'Configuración no encontrada para el Motivo: %, y la Clasificación: %',v_desc_motivo,v_desc_clasificacion;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;