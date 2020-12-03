CREATE OR REPLACE FUNCTION kaf.f_genera_cbte_deprec_monedas (
  p_id_usuario INTEGER,
  p_id_movimiento INTEGER,
  p_id_estado_actual INTEGER
)
RETURNS INTEGER AS
$body$
/**************************************************************************
 SISTEMA:     Sistema de Activos Fijos
 FUNCION:     kaf.f_genera_cbte_deprec_monedas
 DESCRIPCION: Generación del comprobante de depreciación (3) en las 3 monedas independientemente
 AUTOR:       RCM
 FECHA:       26/10/2020
 COMENTARIOS:
 ***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-1443  KAF       ETR           26/10/2020  RCM         Creación del archivo
 ***************************************************************************/
DECLARE

    v_resp                  VARCHAR;
    v_nombre_funcion        TEXT;
    v_mensaje_error         TEXT;
    v_kaf_cbte              VARCHAR;
    v_id_int_comprobante    INTEGER;
    v_id_centro_costo       INTEGER;
    v_tc_usd                NUMERIC;
    v_tc_ufv                NUMERIC;
    v_fecha_mov             DATE;

BEGIN

    --Obtención de fecha del movimiento
    SELECT fecha_mov
    INTO v_fecha_mov
    FROM kaf.tmovimiento mov
    WHERE mov.id_movimiento = p_id_movimiento;

    ---------------------------------------------
    --(1) Generación comprobante 3/4 de depreciación
    ---------------------------------------------
    --Obtención del código de plantilla para depreciación
    v_kaf_cbte = kaf.f_obtener_plantilla_cbte(p_id_movimiento, 3); --'KAF-DEP-DEPREC3';

    v_id_int_comprobante = conta.f_gen_comprobante (p_id_movimiento,
                                                    v_kaf_cbte ,
                                                    p_id_estado_actual,
                                                    p_id_usuario,
                                                    NULL,
                                                    NULL);

    SELECT ps_id_centro_costo
    INTO v_id_centro_costo
    FROM conta.f_get_config_relacion_contable(
    'CCDEPCON',
    (SELECT id_gestion FROM param.tgestion WHERE DATE_TRUNC('year', fecha_ini) = DATE_TRUNC('YEAR', now())),
    3,
    NULL);

    ----------------------------------------------------
    --(2) Generación de las transacciones Debe
    ----------------------------------------------------
    --Obtención de tipo de cambio
    v_tc_usd = param.f_get_tipo_cambio_v2(param.f_get_moneda_base(), param.f_get_moneda_triangulacion(), v_fecha_mov, 'O');
    v_tc_ufv = param.f_get_tipo_cambio_v2(param.f_get_moneda_base(), param.f_get_moneda_actualizacion(), v_fecha_mov, 'O');


    WITH tbs AS (
        SELECT
        cd.id_partida,
        cd.id_centro_costo,
        cd.id_cuenta,
        cd.monto_depreciacion,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_base()
        AND cd.id_centro_costo IS NOT NULL
    ), tusd AS (
        SELECT
        cd.id_partida,
        cd.id_centro_costo,
        cd.id_cuenta,
        cd.monto_depreciacion,,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_triangulacion()
        AND cd.id_centro_costo IS NOT NULL
    ), tufv AS (
        SELECT
        cd.id_partida,
        cd.id_centro_costo,
        cd.id_cuenta,
        cd.monto_depreciacion,,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_actualizacion()
        AND cd.id_centro_costo IS NOT NULL
    )
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        tipo_cambio,
        tipo_cambio_2,
        tipo_cambio_3
    )
    SELECT
    tbs.id_partida,
    tbs.id_centro_costo,
    'activo',
    tbs.id_cuenta,
    v_id_int_comprobante,
    tbs.monto_depreciacion,
    tbs.monto_depreciacion,
    tusd.monto_depreciacion,
    tufv.monto_depreciacion,
    tbs.monto_depreciacion,
    tbs.monto_depreciacion,
    tusd.monto_depreciacion,
    tufv.monto_depreciacion,
    0, 0, 0, 0, 0, 0, 0, 0,
    p_id_usuario,
    now(),
    1,
    v_tc_usd,
    v_tc_ufv
    FROM tbs
    JOIN tusd
    ON tusd.id_clasificacion = tbs.id_clasificacion
    AND tusd.id_centro_costo = tbs.id_centro_costo
    AND tusd.id_cuenta = tbs.id_cuenta
    AND tusd.id_partida = tbs.id_partida
    JOIN tufv
    ON tufv.id_clasificacion = tbs.id_clasificacion
    AND tufv.id_centro_costo = tbs.id_centro_costo
    AND tufv.id_cuenta = tbs.id_cuenta
    AND tufv.id_partida = tbs.id_partida;

    -------------------------------------------------
    --(3) Generación de las transacciones Haber
    -------------------------------------------------
    --(3.1) En Bs
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_haber,
        importe_haber_mb,
        importe_recurso,
        importe_recurso_mb,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        id_usuario_reg,
        fecha_reg,
        glosa,
        tipo_cambio,
        tipo_cambio_2,
        tipo_cambio_3
    )
    SELECT
    cd.id_partida,
    v_id_centro_costo,
    'activo',
    cd.id_cuenta,
    v_id_int_comprobante,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    0, 0, 0, 0, 0, 0, 0, 0,
    p_id_usuario,
    now(),
    cd.id_clasificacion::varchar,
    1,
    v_tc_usd,
    v_tc_ufv
    FROM kaf.v_cbte_deprec_3_haber_v3 cd
    WHERE cd.id_movimiento = p_id_movimiento
    AND cd.id_moneda = param.f_get_moneda_base();

    --(3.2) En USD
    UPDATE conta.tint_transaccion AA SET
    importe_haber_mt = DD.monto_depreciacion,
    importe_recurso_mt = DD.monto_depreciacion
    FROM (
        SELECT
        cd.monto_depreciacion,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_haber_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_triangulacion()
    ) DD
    WHERE AA.id_int_comprobante = v_id_int_comprobante
    AND AA.glosa = DD.id_clasificacion::varchar;

    --(3.3) En UFV
    UPDATE conta.tint_transaccion AA SET
    importe_haber_ma = DD.monto_depreciacion,
    importe_recurso_ma = DD.monto_depreciacion
    FROM (
        SELECT
        cd.monto_depreciacion,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_haber_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_actualizacion()
    ) DD
    WHERE AA.id_int_comprobante = v_id_int_comprobante
    AND AA.glosa = DD.id_clasificacion::varchar;

    --Vacía el campo auxiliar usado en la glosa
    UPDATE conta.tint_transaccion SET
    glosa = NULL
    WHERE id_int_comprobante = v_id_int_comprobante;

    ----------------
    --(4) Respuesta
    ----------------
    RETURN v_id_int_comprobante;

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