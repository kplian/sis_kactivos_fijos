CREATE OR REPLACE FUNCTION kaf.f_get_codigo_nuevo_afv (
  p_id_activo_fijo integer,
  p_cod_movimiento varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_get_codigo_nuevo_afv
 DESCRIPCION:   Devuelve nuevo código para el activo fijo valor
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
    v_numero                integer;
    v_codigo                varchar;
    v_codigo_af             varchar;

BEGIN

    v_nombre_funcion = 'kaf.f_get_codigo_nuevo_afv';

    --Conteo de la cantidad de registros del movimiento definido
    select count(1) + 1
    into v_numero
    from kaf.tactivo_fijo_valores
    where id_activo_fijo = p_id_activo_fijo
    and tipo = p_cod_movimiento;

    --Obtención del código del activo fijo
    select codigo
    into v_codigo_af
    from kaf.tactivo_fijo
    where id_activo_fijo = p_id_activo_fijo;

    v_codigo = v_codigo_af+'-';

    --Personalización del código por tipo de movimiento
    if p_cod_movimiento = 'alta' then
        v_codigo = v_codigo||'AL';
    elsif p_cod_movimiento 'reval' then
        v_codigo = v_codigo||'RE'||v_numero::varchar;
    elsif p_cod_movimiento 'mejora' then
        v_codigo = v_codigo||'ME'||v_numero::varchar;
    elsif p_cod_movimiento 'ajuste' then
        v_codigo = v_codigo||'AJ'||v_numero::varchar;
    elsif p_cod_movimiento 'divis' then
        v_codigo = v_codigo||'DI'||v_numero::varchar;
    elsif p_cod_movimiento 'desgl' then
        v_codigo = v_codigo||'DES'||v_numero::varchar;
    elsif p_cod_movimiento 'intpar' then
        v_codigo = v_codigo||'PAR'||v_numero::varchar;
    end if;
    
    --Respuesta
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