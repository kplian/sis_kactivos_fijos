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

BEGIN

    --1. Validaciones
    if not exists(select 1 from kaf.tactivo_fijo
                where id_activo_fijo = p_id_activo_fijo) then
        raise exception 'Activo fijo inexistente';
    end if;
    --Estado debe ser Registrado
    if not exists(select 1 from kaf.tactivo_fijo
                where id_activo_fijo = p_id_activo_fijo
                and estado = 'registrado') then
        raise exception 'El activo fijo debería estar en estado Registrado';
    end if;
    if exists(select 1 from kaf.tactivo_fijo
            where id_activo_fijo = p_id_activo_fijo
            and estado = 'registrado'
            and codigo is not null) then
        raise exception 'El Activo Fijo ya tiene un código asignado';
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
    
    --4.Obtiene longitud del código
    v_longitud = coalesce(cast(pxp.f_get_variable_global('kaf_codigo_longitud') as integer),0);
    
    --5. Arma el código
    v_codigo = v_codigo || '.' || pxp.f_rellena_cero_din(v_correl,v_longitud);
    
    --6. Actualización de correlativo siguiente y el activo fijo
    update kaf.tclasificacion set
    correlativo_act = v_correl
    where id_clasificacion = v_id_clasificacion;
    
    update kaf.tactivo_fijo set
    codigo = v_codigo
    where id_activo_fijo = p_id_activo_fijo;
    
    --7. Salida
    return v_codigo;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;