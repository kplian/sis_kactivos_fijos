--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_genera_codigo (
  p_id_activo_fijo integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_fijo_ime
 DESCRIPCION:   Generación automática de código único de activos fijos
 AUTOR:          (RCM)
 FECHA:         30/12/2015
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/
DECLARE
    
    v_codigo varchar;
    v_correl integer;
    v_id_clasificacion integer;
    v_longitud integer;
    v_resp varchar;
    v_nombre_funcion varchar;

BEGIN

    v_nombre_funcion = 'kaf.f_genera_codigo';

    --1. Validaciones
    if not exists(select 1 from kaf.tactivo_fijo
                where id_activo_fijo = p_id_activo_fijo) then
        raise exception 'Activo fijo inexistente';
    end if;
    if exists(select 1 from kaf.tactivo_fijo
            where id_activo_fijo = p_id_activo_fijo
            and (codigo is not null and codigo !='')) then
            
       -- raise exception 'El Activo Fijo ya tiene un código asignado';
    end if;
    
    --2. Obtención de datos
    select id_clasificacion
    into v_id_clasificacion
    from kaf.tactivo_fijo
    where id_activo_fijo = p_id_activo_fijo;
    
    if v_id_clasificacion is null then
        raise exception 'No es posible codificar activo: clasificación inexistente';
    end if;
    
    --3. Generación de código único en función de la clasificación de activos
    select coalesce(correlativo_act,0) + 1, codigo
    into v_correl, v_codigo
    from kaf.tclasificacion
    where id_clasificacion = v_id_clasificacion;
    --raise EXCEPTION 'sdsdsd: %',pxp.f_get_variable_global('kaf_codigo_longitud');
        IF pxp.f_get_variable_global('kaf_codigo_longitud') = 'NULL' THEN
            raise EXCEPTION 'Falta la definicion de la variable global: kaf_codigo_longitud';
        END if;

    --4.Obtiene longitud del código
    v_longitud = cast(pxp.f_get_variable_global('kaf_codigo_longitud') as integer);
    
    --5. Arma el código
    v_codigo = v_codigo || '.' || pxp.f_rellena_cero_din(v_correl,v_longitud);
    
    --6. Actualización de correlativo siguiente y el activo fijo
    update kaf.tclasificacion set
    correlativo_act = v_correl
    where id_clasificacion = v_id_clasificacion;
    
    --update kaf.tactivo_fijo set
    --codigo = v_codigo
    --where id_activo_fijo = p_id_activo_fijo;
    
    --7. Salida
    return v_codigo;
    
    
EXCEPTION
				
	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;    

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;