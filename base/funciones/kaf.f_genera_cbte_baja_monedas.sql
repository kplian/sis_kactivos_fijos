CREATE OR REPLACE FUNCTION kaf.f_genera_cbte_baja_monedas (
  p_id_usuario INTEGER,
  p_id_movimiento INTEGER,
  p_id_int_comprobante INTEGER,
  p_codigo_plantilla VARCHAR
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:     Sistema de Activos Fijos
 FUNCION:     kaf.f_genera_cbte_baja_monedas
 DESCRIPCION: Generación del comprobante de bajas en las 3 monedas independientemente
 AUTOR:       RCM
 FECHA:       03/12/2020
 COMENTARIOS:
 ***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2045  KAF       ETR           03/12/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

    v_resp                  VARCHAR;
    v_nombre_funcion        TEXT;
    v_mensaje_error         TEXT;
    v_cod_relacion_cont_af  VARCHAR;
    v_cod_relacion_cont_da  VARCHAR;
    v_cod_relacion_cont     VARCHAR;
    v_func                  VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.f_genera_cbte_baja_monedas';
    --------------------------------
    --(1) Configuraciones iniciales
    --------------------------------
    v_cod_relacion_cont_af = 'AF-BAJA-VACT';
    v_cod_relacion_cont_da = 'AF-BAJA-DACUM';

    --Identificar la Relación contable a utilizar en base a la plantilla de comprobante
    IF p_codigo_plantilla = 'KAF-BAJA' THEN
        v_cod_relacion_cont = 'KAF-BAJA';
    ELSIF p_codigo_plantilla = 'KAF-BAJA-GESANT' THEN
        v_cod_relacion_cont = 'KAF-BAJA-GESANT';
    ELSIF p_codigo_plantilla = 'KAF-BAJA-VEN' THEN
        v_cod_relacion_cont = 'AF-BAJA-VEN';
    ELSIF p_codigo_plantilla = 'KAF-BAJA-SIN' THEN
        v_cod_relacion_cont = 'KAF-BAJA-SIN';
    ELSE
        RAISE EXCEPTION 'La plantilla % no está definida. Contáctese con el administrador', p_codigo_plantilla;
    END IF;

    ----------------------------
    --(2) Transacciones al Debe
    ----------------------------
    v_func = kaf.f_genera_cbte_baja_monedas_transacciones(p_id_usuario, p_id_movimiento, p_id_int_comprobante, v_cod_relacion_cont_da); --depreciacion_acumulada
    v_func = kaf.f_genera_cbte_baja_monedas_transacciones(p_id_usuario, p_id_movimiento, p_id_int_comprobante, v_cod_relacion_cont); --valor neto

    -----------------------------
    --(3) Transacciones al Haber
    -----------------------------
    v_func = kaf.f_genera_cbte_baja_monedas_transacciones(p_id_usuario, p_id_movimiento, p_id_int_comprobante, v_cod_relacion_cont_af); --valor actualizado

    ----------------
    --(4) Respuesta
    ----------------
    RETURN 'hecho';

EXCEPTION

    WHEN OTHERS THEN

        v_resp = '';
        v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);

        RAISE EXCEPTION '%', v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;