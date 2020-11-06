CREATE OR REPLACE FUNCTION kaf.f_depreciacion_iguala_ufv_x_afv (
  p_id_usuario integer,
  p_id_afvs varchar,
  p_fecha_hasta date
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_depreciacion_iguala_ufv_x_afv
 DESCRIPCION:   Función para usarla directo desde la BD basasa en la original f_depreciacion_iguala_ufv pero recibiendo IDs AFV
 AUTOR:         RCM
 FECHA:         31/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-10 KAF       ETR           31/08/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

    v_nombre_funcion VARCHAR;
    v_fecha DATE;
    v_resp VARCHAR;
    v_id_moneda_base INTEGER;
    v_id_moneda_ufv INTEGER;
    v_sql TEXT;

BEGIN

    v_nombre_funcion = 'kaf.f_depreciacion_iguala_ufv_x_afv';

    --Obtención de la fecha hasta de depreciación
	v_fecha = p_fecha_hasta;

    --Obtención de la moneda base
    v_id_moneda_base = param.f_get_moneda_base();

    --Obtención de moneda UFV
    SELECT id_moneda
    INTO v_id_moneda_ufv
    FROM param.tmoneda
    WHERE codigo = 'UFV';

    --Monto actualizado
	v_sql = '
    UPDATE kaf.tmovimiento_af_dep AA SET
    monto_actualiz = AA.monto_actualiz + DD.monto_actualiz_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.monto_actualiz
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
            AND mdep.id_moneda = ' || v_id_moneda_ufv ||'
        )
        SELECT
        mdep.id_movimiento_af_dep, afv.id_activo_fijo, mdep.monto_actualiz,
        ufv.monto_actualiz * mdep.tipo_cambio_fin AS monto_actualiz_convertido,
        (ufv.monto_actualiz * mdep.tipo_cambio_fin) - mdep.monto_actualiz AS monto_actualiz_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
        AND mdep.id_moneda = ' || v_id_moneda_base || '
        AND afv.id_activo_fijo_valor IN (' || p_id_afvs ||')
        AND (ufv.monto_actualiz * mdep.tipo_cambio_fin) - mdep.monto_actualiz <> 0
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep';

    EXECUTE(v_sql);

    --Depreciación del mes
    v_sql = '
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion = AA.depreciacion + DD.depreciacion_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
            AND mdep.id_moneda = ' || v_id_moneda_ufv || '
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.depreciacion,
        ufv.depreciacion * mdep.tipo_cambio_fin AS depreciacion_convertido,
        (ufv.depreciacion * mdep.tipo_cambio_fin) - mdep.depreciacion AS depreciacion_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
        AND mdep.id_moneda = ' || v_id_moneda_base || '
        AND afv.id_activo_fijo_valor IN (' || p_id_afvs ||')
        AND (ufv.depreciacion * mdep.tipo_cambio_fin) - mdep.depreciacion <> 0
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep';

    EXECUTE (v_sql);

    --Depreciación acumulada
    v_sql = '
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion_acum = AA.depreciacion_acum + DD.dep_acum_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion_acum
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
            AND mdep.id_moneda = ' || v_id_moneda_ufv ||'
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.depreciacion_acum,
        ufv.depreciacion_acum * mdep.tipo_cambio_fin as dep_acum_convertido,
        (ufv.depreciacion_acum * mdep.tipo_cambio_fin) -  mdep.depreciacion_acum as dep_acum_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
        AND mdep.id_moneda = ' || v_id_moneda_base || '
        AND afv.id_activo_fijo_valor IN (' || p_id_afvs ||')
        AND (ufv.depreciacion_acum * mdep.tipo_cambio_fin) -  mdep.depreciacion_acum <> 0
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep';

    EXECUTE(v_sql);

    --Depreciación del período
    v_sql = '
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion_per = AA.depreciacion_per + DD.dep_per_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion_per
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
            AND mdep.id_moneda = ' || v_id_moneda_ufv ||'
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.depreciacion_per,
        ufv.depreciacion_per * mdep.tipo_cambio_fin as dep_per_convertido,
        (ufv.depreciacion_per * mdep.tipo_cambio_fin) -  mdep.depreciacion_per as dep_per_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
        AND mdep.id_moneda = ' || v_id_moneda_base || '
        AND afv.id_activo_fijo_valor IN (' || p_id_afvs ||')
        AND (ufv.depreciacion_per * mdep.tipo_cambio_fin) -  mdep.depreciacion_per <> 0
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep';

    EXECUTE(v_sql);

    --Valor Neto
    v_sql = '
    UPDATE kaf.tmovimiento_af_dep AA SET
    monto_vigente = AA.monto_vigente + DD.monto_vigente_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.monto_vigente
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
            AND mdep.id_moneda = ' || v_id_moneda_ufv ||'
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.monto_vigente,
        ufv.monto_vigente * mdep.tipo_cambio_fin as monto_vigente_convertido,
        (ufv.monto_vigente * mdep.tipo_cambio_fin) - mdep.monto_vigente as monto_vigente_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || v_fecha || '''::date)
        AND mdep.id_moneda = ' || v_id_moneda_base || '
        AND afv.id_activo_fijo_valor IN (' || p_id_afvs ||')
        AND (ufv.monto_vigente * mdep.tipo_cambio_fin) -  mdep.monto_vigente <> 0
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep';

    EXECUTE(v_sql);

    --Salida
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
PARALLEL UNSAFE
COST 100;