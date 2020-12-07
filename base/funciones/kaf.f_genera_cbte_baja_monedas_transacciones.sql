CREATE OR REPLACE FUNCTION kaf.f_genera_cbte_baja_monedas_transacciones (
  p_id_usuario INTEGER,
  p_id_movimiento INTEGER,
  p_id_int_comprobante INTEGER,
  p_codigo_relacion_contable VARCHAR
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:     Sistema de Activos Fijos
 FUNCION:     kaf.f_genera_cbte_baja_monedas_transacciones
 DESCRIPCION: Inserta las transacciones para el movimiento de baja
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
    v_fecha_mov             DATE;
    v_tc_usd                NUMERIC;
    v_tc_ufv                NUMERIC;
    v_id_centro_costo       INTEGER;

BEGIN

    v_nombre_funcion = 'kaf.f_genera_cbte_baja_monedas_transacciones';

    --Obtención de fecha del movimiento
    SELECT fecha_mov
    INTO v_fecha_mov
    FROM kaf.tmovimiento mov
    WHERE mov.id_movimiento = p_id_movimiento;

    --Obtención del CC administrativo
    SELECT ps_id_centro_costo
    INTO v_id_centro_costo
    FROM conta.f_get_config_relacion_contable(
    'CCDEPCON',
    (SELECT id_gestion FROM param.tgestion WHERE DATE_TRUNC('year', fecha_ini) = DATE_TRUNC('YEAR', v_fecha_mov)),
    3,
    NULL);

    --Obtención de tipo de cambio
    v_tc_usd = param.f_get_tipo_cambio_v2(param.f_get_moneda_base(), param.f_get_moneda_triangulacion(), v_fecha_mov, 'O');
    v_tc_ufv = param.f_get_tipo_cambio_v2(param.f_get_moneda_base(), param.f_get_moneda_actualizacion(), v_fecha_mov, 'O');

    --
    IF p_codigo_relacion_contable = 'AF-BAJA-DACUM' THEN
        --Depreciación acumulada (DEBE)
        WITH trel_contable AS (
            SELECT rc_1.id_tabla AS id_clasificacion,
            (('{' || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos,
            rc_1.id_cuenta, rc_1.id_partida, rc_1.id_gestion
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc_1
            ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema = 'KAF'
            AND tb.tabla = 'tclasificacion'
            AND trc.codigo_tipo_relacion = p_codigo_relacion_contable
        )
        INSERT INTO conta.tint_transaccion
        (
            id_usuario_reg,
            fecha_reg,
            estado_reg,
            id_int_comprobante,
            id_cuenta,
            id_partida,
            id_centro_costo,
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
            tipo_cambio,
            tipo_cambio_2,
            tipo_cambio_3,
            glosa
        )
        SELECT
        p_id_usuario,
        now(),
        'activo',
        p_id_int_comprobante,
        rc.id_cuenta,
        rc.id_partida,
        v_id_centro_costo,
        ROUND(cb.depreciacion_acum, 2), ROUND(cb.depreciacion_acum, 2), 0, 0, ROUND(cb.depreciacion_acum, 2), ROUND(cb.depreciacion_acum, 2), 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        1,
        v_tc_usd,
        v_tc_ufv,
        cb.id_clasificacion
        FROM kaf.v_cbte_baja_v2 cb
        JOIN trel_contable rc
        ON cb.id_clasificacion = ANY (rc.nodos)
        AND rc.id_gestion IN
        (
            SELECT tgestion.id_gestion
            FROM param.tgestion
            WHERE date_trunc('year', fecha_ini) = date_trunc('year', v_fecha_mov)
        )
        WHERE cb.id_movimiento = p_id_movimiento
        AND cb.id_moneda = param.f_get_moneda_base();

        --USD
        UPDATE conta.tint_transaccion AA SET
        importe_debe_mt = ROUND(DD.depreciacion_acum, 2),
        importe_gasto_mt = ROUND(DD.depreciacion_acum, 2)
        FROM (
            SELECT
            cb.depreciacion_acum,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_triangulacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;

        --UFV
        UPDATE conta.tint_transaccion AA SET
        importe_debe_ma = ROUND(DD.depreciacion_acum, 2),
        importe_gasto_ma = ROUND(DD.depreciacion_acum, 2)
        FROM (
            SELECT
            cb.depreciacion_acum,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_actualizacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;

    ELSIF p_codigo_relacion_contable = 'AF-BAJA-VACT' THEN
        --Valor actualizado (HABER)
        WITH trel_contable AS (
            SELECT rc_1.id_tabla AS id_clasificacion,
            (('{' || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos,
            rc_1.id_cuenta, rc_1.id_partida, rc_1.id_gestion
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc_1
            ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema = 'KAF'
            AND tb.tabla = 'tclasificacion'
            AND trc.codigo_tipo_relacion = p_codigo_relacion_contable
        )
        INSERT INTO conta.tint_transaccion
        (
            id_usuario_reg,
            fecha_reg,
            estado_reg,
            id_int_comprobante,
            id_cuenta,
            id_partida,
            id_centro_costo,
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
            tipo_cambio,
            tipo_cambio_2,
            tipo_cambio_3,
            glosa
        )
        SELECT
        p_id_usuario,
        now(),
        'activo',
        p_id_int_comprobante,
        rc.id_cuenta,
        rc.id_partida,
        v_id_centro_costo,
        0, 0, 0, 0, 0, 0, 0, 0,
        ROUND(cb.monto_actualiz, 2), ROUND(cb.monto_actualiz, 2), 0, 0, ROUND(cb.monto_actualiz, 2), ROUND(cb.monto_actualiz, 2), 0, 0,
        1,
        v_tc_usd,
        v_tc_ufv,
        cb.id_clasificacion
        FROM kaf.v_cbte_baja_v2 cb
        JOIN trel_contable rc
        ON cb.id_clasificacion = ANY (rc.nodos)
        AND rc.id_gestion IN
        (
            SELECT tgestion.id_gestion
            FROM param.tgestion
            WHERE date_trunc('year', fecha_ini) = date_trunc('year', v_fecha_mov)
        )
        WHERE cb.id_movimiento = p_id_movimiento
        AND cb.id_moneda = param.f_get_moneda_base();

        --USD
        UPDATE conta.tint_transaccion AA SET
        importe_haber_mt = ROUND(DD.monto_actualiz, 2),
        importe_recurso_mt = ROUND(DD.monto_actualiz, 2)
        FROM (
            SELECT
            cb.monto_actualiz,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_triangulacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;

        --UFV
        UPDATE conta.tint_transaccion AA SET
        importe_haber_ma = ROUND(DD.monto_actualiz, 2),
        importe_recurso_ma = ROUND(DD.monto_actualiz, 2)
        FROM (
            SELECT
            cb.monto_actualiz,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_actualizacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;

    ELSE
        --Valor Neto (DEBE)
        WITH trel_contable AS (
            SELECT rc_1.id_tabla AS id_clasificacion,
            (('{' || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos,
            rc_1.id_cuenta, rc_1.id_partida, rc_1.id_gestion, rc_1.id_centro_costo
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc_1
            ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema = 'KAF'
            AND tb.tabla = 'tclasificacion'
            AND trc.codigo_tipo_relacion = p_codigo_relacion_contable
            UNION
            SELECT
            -1 AS id_clasificacion,
            ('{}')::integer [ ] AS nodos,
            rc_1.id_cuenta, rc_1.id_partida, rc_1.id_gestion, rc_1.id_centro_costo
            FROM conta.ttipo_relacion_contable trc
            JOIN conta.trelacion_contable rc_1
            ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE trc.codigo_tipo_relacion = p_codigo_relacion_contable
        )
        INSERT INTO conta.tint_transaccion
        (
            id_usuario_reg,
            fecha_reg,
            estado_reg,
            id_int_comprobante,
            id_cuenta,
            id_partida,
            id_centro_costo,
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
            tipo_cambio,
            tipo_cambio_2,
            tipo_cambio_3,
            glosa
        )
        SELECT DISTINCT
        p_id_usuario,
        now(),
        'activo',
        p_id_int_comprobante,
        rc.id_cuenta,
        rc.id_partida,
        rc.id_centro_costo,
        ROUND(cb.monto_actualiz - cb.depreciacion_acum, 2), ROUND(cb.monto_actualiz - cb.depreciacion_acum, 2), 0, 0, ROUND(cb.monto_actualiz - cb.depreciacion_acum, 2), ROUND(cb.monto_actualiz - cb.depreciacion_acum, 2), 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        1,
        v_tc_usd,
        v_tc_ufv,
        cb.id_clasificacion
        FROM kaf.v_cbte_baja_v2 cb
        JOIN trel_contable rc
        ON (cb.id_clasificacion = ANY (rc.nodos) OR rc.id_clasificacion = -1)
        AND rc.id_gestion IN
        (
            SELECT tgestion.id_gestion
            FROM param.tgestion
            WHERE date_trunc('year', fecha_ini) = date_trunc('year', v_fecha_mov)
        )
        WHERE cb.id_movimiento = p_id_movimiento
        AND cb.id_moneda = param.f_get_moneda_base();

        --USD
        UPDATE conta.tint_transaccion AA SET
        importe_debe_mt = ROUND(DD.valor_neto, 2),
        importe_gasto_mt = ROUND(DD.valor_neto, 2)
        FROM (
            SELECT
            cb.monto_actualiz - cb.depreciacion_acum AS valor_neto,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_triangulacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;

        --UFV
        UPDATE conta.tint_transaccion AA SET
        importe_debe_ma = ROUND(DD.valor_neto, 2),
        importe_gasto_ma = ROUND(DD.valor_neto, 2)
        FROM (
            SELECT
            cb.monto_actualiz - cb.depreciacion_acum AS valor_neto,
            cb.id_clasificacion
            FROM kaf.v_cbte_baja_v2 cb
            WHERE cb.id_movimiento = p_id_movimiento
            AND cb.id_moneda = param.f_get_moneda_actualizacion()
        ) DD
        WHERE AA.id_int_comprobante = p_id_int_comprobante
        AND AA.glosa = DD.id_clasificacion::varchar;
    END IF;

    UPDATE conta.tint_transaccion SET
    glosa = NULL
    WHERE id_int_comprobante = p_id_int_comprobante;

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