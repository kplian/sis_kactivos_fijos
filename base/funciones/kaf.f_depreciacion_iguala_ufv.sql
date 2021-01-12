CREATE OR REPLACE FUNCTION kaf.f_depreciacion_iguala_ufv (
  p_id_usuario integer,
  p_id_movimiento integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_depreciacion_iguala_ufv
 DESCRIPCION:   Ajuste de los cálculos de depreciación realizados en bolivianos contra UFVs
 AUTOR:         RCM
 FECHA:         21/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-10     KAF       ETR           21/08/2020  RCM         Creación del archivo
 #ETR-2170  KAF       ETR           10/01/2021  RCM         Adición de condición para no igualar los posteriores a 10/12/2020 debido a la baja de UFV
***************************************************************************/
DECLARE

    v_nombre_funcion VARCHAR;
    v_fecha DATE;
    v_resp VARCHAR;
    v_id_moneda_base INTEGER;
    v_id_moneda_ufv INTEGER;
    v_fecha_act_ufv DATE; --#ETR-2170

BEGIN

    v_nombre_funcion = 'kaf.f_depreciacion_iguala_ufv';

    --Obtención de la fecha hasta de depreciación
    SELECT fecha_hasta
    INTO v_fecha
    FROM kaf.tmovimiento
    WHERE id_movimiento = p_id_movimiento;

    --Obtención de la moneda base
    v_id_moneda_base = param.f_get_moneda_base();

    --Obtención de moneda UFV
    SELECT id_moneda
    INTO v_id_moneda_ufv
    FROM param.tmoneda
    WHERE codigo = 'UFV';

    --Inicio #ETR-2170
    --Verificación de bandera para la actualización/igualación
    IF pxp.f_get_variable_global('kaf_actualizar_baja_ufv') = 'NULL' THEN
        v_fecha_act_ufv = NULL;
    ELSE
        v_fecha_act_ufv = pxp.f_get_variable_global('kaf_actualizar_baja_ufv')::DATE;
    END IF;
    --Fin #ETR-2170

    --Ajuste de Monto actualizado (1)
    UPDATE kaf.tmovimiento_af_dep AA SET
    monto_actualiz = AA.monto_actualiz + DD.monto_actualiz_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.monto_actualiz
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
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
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.monto_actualiz * mdep.tipo_cambio_fin) - mdep.monto_actualiz <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

    --Ajuste Depreciación del mes (2)
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion = AA.depreciacion + DD.depreciacion_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
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
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.depreciacion * mdep.tipo_cambio_fin) - mdep.depreciacion <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

    --Ajuste Depreciación acumulada(3)
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion_acum = AA.depreciacion_acum + DD.dep_acum_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion_acum
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
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
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.depreciacion_acum * mdep.tipo_cambio_fin) - mdep.depreciacion_acum <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

    --Ajuste Depreciación del período (4)
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion_per = AA.depreciacion_per + DD.dep_per_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion_per
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.depreciacion_per,
        ufv.depreciacion_per * mdep.tipo_cambio_fin as dep_per_convertido,
        (ufv.depreciacion_per * mdep.tipo_cambio_fin) - mdep.depreciacion_per as dep_per_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.depreciacion_per * mdep.tipo_cambio_fin) - mdep.depreciacion_per <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

    --Ajuste Valor neto (5)
    UPDATE kaf.tmovimiento_af_dep AA SET
    monto_vigente = AA.monto_vigente + DD.monto_vigente_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.monto_vigente
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
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
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.monto_vigente * mdep.tipo_cambio_fin) - mdep.monto_vigente <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

    --Ajuste Depreciación acumulada anterior actualizada (6)
    UPDATE kaf.tmovimiento_af_dep AA SET
    depreciacion_acum_actualiz = AA.depreciacion_acum_actualiz + DD.depreciacion_acum_actualiz_dif
    FROM (
        WITH tdep_ufv AS (
            SELECT
            afv.id_activo_fijo, mdep.depreciacion_acum_actualiz
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
            AND mdep.id_moneda = v_id_moneda_ufv
        )
        SELECT mdep.id_movimiento_af_dep,
        afv.id_activo_fijo, mdep.depreciacion_acum_actualiz,
        ufv.depreciacion_acum_actualiz * mdep.tipo_cambio_fin as depreciacion_acum_actualiz_convertido,
        (ufv.depreciacion_acum_actualiz * mdep.tipo_cambio_fin) - mdep.depreciacion_acum_actualiz as depreciacion_acum_actualiz_dif
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        INNER JOIN tdep_ufv ufv
        ON ufv.id_activo_fijo = afv.id_activo_fijo
        WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', v_fecha)
        AND mdep.id_moneda = v_id_moneda_base
        AND (ufv.depreciacion_acum_actualiz * mdep.tipo_cambio_fin) - mdep.depreciacion_acum_actualiz <> 0
        --Inicio #ETR-2170
        AND CASE v_fecha_act_ufv
                WHEN NULL THEN 0 = 0
                ELSE afv.fecha_ini_dep <= v_fecha_act_ufv
            END
        --Fin #ETR-2170
    ) DD
    WHERE DD.id_movimiento_af_dep = AA.id_movimiento_af_dep;

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