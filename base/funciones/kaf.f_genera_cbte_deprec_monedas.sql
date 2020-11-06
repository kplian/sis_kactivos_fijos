CREATE OR REPLACE FUNCTION kaf.f_genera_cbte_deprec_monedas (
  p_id_movimiento INTEGER
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

BEGIN

    ---------------------------------------------
    --(1) Generación comprobante 3/4 de depreciación
    ---------------------------------------------
    --Obtención del código de plantilla para depreciación
    v_kaf_cbte = kaf.f_obtener_plantilla_cbte(p_id_movimiento, 3); --'KAF-DEP-DEPREC3';

    v_id_int_comprobante = conta.f_gen_comprobante (v_movimiento.id_movimiento,
                                                    v_kaf_cbte ,
                                                    v_id_estado_actual,
                                                    p_id_usuario,
                                                    v_parametros._id_usuario_ai,
                                                    v_parametros._nombre_usuario_ai);

    ----------------------------------------------------
    --(2) Generación de las transacciones Debe
    ----------------------------------------------------
    --(2.1) En Bolivianos
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_gasto,
        importe_gasto_mb,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    cd.id_partida,
    cd.id_centro_costo,
    'activo',
    cd.id_cuenta,
    v_id_int_comprobante,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    p_id_usuario,
    cd.id_clasificacion::varchar
    FROM kaf.v_cbte_deprec_3_v3 cd
    WHERE cd.id_movimiento = p_id_movimiento
    AND cd.id_moneda = param.f_get_moneda_base();

    --(2.2) En Dólares
    UPDATE conta.tint_transaccion AA SET
    importe_debe_mt = DD.monto_depreciacion,
    importe_gasto_mt = DD.monto_depreciacion
    FROM (
        SELECT
        cd.monto_depreciacion,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_triangulacion()
    ) DD
    WHERE AA.id_int_comprobante = v_id_int_comprobante
    AND AA.glosa = DD.id_clasificacion::varchar;

    --(2.3) En UFV
    UPDATE conta.tint_transaccion AA SET
    importe_debe_ma = DD.monto_depreciacion,
    importe_gasto_ma = DD.monto_depreciacion
    FROM (
        SELECT
        cd.monto_depreciacion,
        cd.id_clasificacion
        FROM kaf.v_cbte_deprec_3_v3 cd
        WHERE cd.id_movimiento = p_id_movimiento
        AND cd.id_moneda = param.f_get_moneda_actualizacion()
    ) DD
    WHERE AA.id_int_comprobante = v_id_int_comprobante
    AND AA.glosa = DD.id_clasificacion::varchar;

    --Vacía el campo auxiliar usado en la glosa
    UPDATE conta.tint_transaccion SET
    glosa = NULL
    WHERE id_int_comprobante = v_id_int_comprobante;

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
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    cd.id_partida,
    cd.id_centro_costo,
    'activo',
    cd.id_cuenta,
    v_id_int_comprobante,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    cd.monto_depreciacion,
    p_id_usuario,
    cd.id_clasificacion::varchar
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