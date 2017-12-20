CREATE OR REPLACE FUNCTION kaf.f_afv_replicar (
  p_id_usuario integer,
  p_id_activo_fijo integer,
  p_id_movimiento_af integer,
  p_vida_util integer,
  p_fecha date
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_afv_replicar
 DESCRIPCION:   Replica los activos fijos valor AFV de un activo fijo, generado por  un movimiento de Revalorización, Mejora , etc.
 AUTOR:         RCM
 FECHA:         14/06/2017
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   Se aumenta join con vista para obtener el monto real a la fecha
 AUTOR:         RCM
 FECHA:         13/12/2017
***************************************************************************/
DECLARE

    v_resp varchar;
    v_nombre_funcion text;

BEGIN

    v_nombre_funcion = 'kaf.f_afv_replicar';
    
    --Replicar AFV con nueva vida útil
    insert into kaf.tactivo_fijo_valores(
    id_usuario_reg, fecha_reg, estado_reg, id_activo_fijo,
    monto_vigente_orig, vida_util_orig, fecha_ini_dep, depreciacion_mes,
    depreciacion_per, depreciacion_acum, monto_vigente, vida_util ,
    tipo, estado, principal, monto_rescate,
    id_movimiento_af, codigo, id_moneda_dep, id_moneda,
    fecha_inicio, deducible, id_activo_fijo_valor_original,
    monto_vigente_orig_100
    )
    select
    p_id_usuario,
    now(),
    'activo',
    afv.id_activo_fijo,
    av.monto_vigente_real_af,
    p_vida_util,
    p_fecha,
    0,
    0,
    0,
    av.monto_vigente_real_af,
    p_vida_util,
    afv.tipo,
    afv.estado,
    afv.principal,
    afv.monto_rescate,
    p_id_movimiento_af,
    afv.codigo,
    afv.id_moneda_dep,
    afv.id_moneda,
    p_fecha,
    afv.deducible,
    afv.id_activo_fijo_valor,
    av.monto_vigente_real_af
    from kaf.tactivo_fijo_valores afv 
    inner join kaf.vactivo_fijo_vigente av 
    on av.id_activo_fijo = afv.id_activo_fijo
    and afv.id_moneda_dep = av.id_moneda_dep
    where afv.id_activo_fijo = p_id_activo_fijo;
    
    --Definicion de la respuesta
    v_resp = pxp.f_agrega_clave(v_resp,'mensaje','AFV replicado satisfactoriamente (id_activo_fijo'||p_id_activo_fijo||')'); 
    v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',p_id_activo_fijo::varchar);

    --Devuelve la respuesta
    return v_resp;

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