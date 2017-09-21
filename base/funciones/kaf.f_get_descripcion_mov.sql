CREATE OR REPLACE FUNCTION kaf.f_get_descripcion_mov (
  p_cod_movimiento integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_get_descripcion_mov
 DESCRIPCION:   Devuelve la descripción de los movimientos a partir de su código
 AUTOR:         RCM
 FECHA:         28/06/2017
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/
DECLARE

    v_nombre_funcion        text;
    v_resp                  varchar;

BEGIN

    v_nombre_funcion = 'kaf.f_get_descripcion_mov';
    v_resp = '';

    if p_cod_movimiento = 'alta' then
        v_resp = 'Alta';
    elsif p_cod_movimiento = 'baja' then
        v_resp = 'Baja';
    elsif p_cod_movimiento = 'reval' then
        v_resp = 'Revalorización';
    elsif p_cod_movimiento = 'mejora' then
        v_resp = 'Mejora';
    elsif p_cod_movimiento = 'deprec' then
        v_resp = 'Depreciación';
    elsif p_cod_movimiento = 'asig' then
        v_resp = 'Asignación';
    elsif p_cod_movimiento = 'devol' then
        v_resp = 'Devolución';
    elsif p_cod_movimiento = 'transf' then
        v_resp = 'Transferencia';
    elsif p_cod_movimiento = 'ajuste' then
        v_resp = 'Ajuste';
    elsif p_cod_movimiento = 'retiro' then
        v_resp = 'Retiro';
    elsif p_cod_movimiento = 'tranfdep' then
        v_resp = 'Transferencia de Depósito';
    elsif p_cod_movimiento = 'actua' then
        v_resp = 'Actualización';
    elsif p_cod_movimiento = 'divis' then
        v_resp = 'División de Valores';
    elsif p_cod_movimiento = 'desgl' then
        v_resp = 'Desglose de Activos Fijos';
    elsif p_cod_movimiento = 'intpar' then
        v_resp = 'Intercambio de Partes';
    end if;
    
    --Respuesta
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