CREATE OR REPLACE FUNCTION kaf.f_afv_finalizar (
  p_id_usuario integer,
  p_id_activo_fijo integer,
  p_fecha date
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:   Sistema de Activos Fijos
 FUNCION:     kaf.f_afv_finalizar
 DESCRIPCION:   Finaliza los activos fijos valor AFV de un activo fijo, generado por  un movimiento de Revalorización, Mejora , etc.
 AUTOR:     RCM
 FECHA:         14/06/2017
 COMENTARIOS: 
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION: 
 AUTOR:     
 FECHA:   
***************************************************************************/
DECLARE
  
  v_resp varchar;
    v_nombre_funcion text;

BEGIN

    v_nombre_funcion = 'kaf.f_afv_finalizar';

    --Finalizar AFV actual colocando fecha_fin
    update kaf.tactivo_fijo_valores set
    fecha_fin = pxp.f_last_day(date_trunc('month', p_fecha - interval '1' month)::date),
    fecha_mod = now(),
    id_usuario_mod = p_id_usuario
    where id_activo_fijo = p_id_activo_fijo
    and fecha_fin is null;
    
     --Definicion de la respuesta
    v_resp = pxp.f_agrega_clave(v_resp,'mensaje','AFV finalizado satisfactoriamente (id_activo_fijo'||p_id_activo_fijo||')'); 
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