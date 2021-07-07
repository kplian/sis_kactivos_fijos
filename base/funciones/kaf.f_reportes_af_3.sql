CREATE OR REPLACE FUNCTION kaf.f_reportes_af_3 (
  p_administrador INTEGER,
  p_id_usuario INTEGER,
  p_tabla VARCHAR,
  p_transaccion VARCHAR
)
RETURNS VARCHAR AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_reportes_af_3
 DESCRIPCION:    Funcion que devuelve conjunto de datos para reportes de activos fijos
 AUTOR:          RCM
 FECHA:          07/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #70        KAF       ETR           07/08/2020  RCM         Creación del archivo
 #AF-13     KAF       ETR           18/10/2020  RCM         Adición de consulta para reporte de saldos a una fecha
 #ETR-4517  KAF       ETR           07/07/2021  RCM         Redondeo del reporte de depreciacion anual
****************************************************************************/
DECLARE

    v_nombre_funcion   VARCHAR;
    v_consulta         VARCHAR;
    v_parametros       RECORD;
    v_respuesta        VARCHAR;
    v_id_movimiento    INTEGER;
    v_fecha            DATE;

BEGIN

    v_nombre_funcion = 'kaf.f_reportes_af_3';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_RDEPANUALGEN_SEL'
     #DESCRIPCION:  Reporte Formulario 605 para impuestos
     #AUTOR:        RCM
     #FECHA:        25/06/2018
    ***********************************/
    --Inicio #25
    IF (p_transaccion = 'SKA_RDEPANUALGEN_SEL') then

        BEGIN

            SELECT mov.id_movimiento
            INTO v_id_movimiento
            FROM kaf.tmovimiento mov
            INNER JOIN param.tcatalogo cat
            ON cat.id_catalogo = mov.id_cat_movimiento
            WHERE DATE_TRUNC('month', mov.fecha_mov) = DATE_TRUNC('month', v_parametros.fecha_hasta::date)
            AND cat.codigo = 'deprec';

            v_fecha = DATE_TRUNC('month', v_parametros.fecha_hasta);

            
            v_consulta = 'SELECT
                        numero,
                        codigo,
                        codigo_sap,
                        denominacion,
                        fecha_ini_dep,
                        cantidad_af,
                        unidad_medida,
                        cc,
                        nro_serie,
                        lugar,
                        responsable,
                        vida_util_orig,
                        vida_util_transc,
                        vida_util,
                        --Inicio #ETR-4517
                        ROUND(valor_compra, 6) AS valor_compra,
                        ROUND(valor_inicial, 6) AS valor_inicial,
                        ROUND(valor_mes_ant, 6) AS valor_mes_ant,
                        ROUND(altas, 6) AS altas,
                        ROUND(bajas, 6) AS bajas,
                        ROUND(traspasos, 6) AS traspasos,
                        ROUND(inc_actualiz, 6) AS inc_actualiz,
                        ROUND(valor_actualiz, 6) AS valor_actualiz,
                        ROUND(depreciacion_acum_gest_ant, 6) AS depreciacion_acum_gest_ant,
                        ROUND(depreciacion_acum_mes_ant, 6) AS depreciacion_acum_mes_ant,
                        ROUND(dep_acum_bajas, 6) AS dep_acum_bajas,
                        ROUND(dep_acum_tras, 6) AS dep_acum_tras,
                        ROUND(inc_actualiz_dep_acum, 6) AS inc_actualiz_dep_acum,
                        ROUND(depreciacion, 6) AS depreciacion,
                        ROUND(depreciacion_acum, 6) AS depreciacion_acum,
                        ROUND(monto_vigente, 6) AS monto_vigente,
                        ROUND(aitb_dep_mes, 6) AS aitb_dep_mes,
                        ROUND(aitb_af_ene, 6) AS aitb_af_ene,
                        ROUND(aitb_af_feb, 6) AS aitb_af_feb,
                        ROUND(aitb_af_mar, 6) AS aitb_af_mar,
                        ROUND(aitb_af_abr, 6) AS aitb_af_abr,
                        ROUND(aitb_af_may, 6) AS aitb_af_may,
                        ROUND(aitb_af_jun, 6) AS aitb_af_jun,
                        ROUND(aitb_af_jul, 6) AS aitb_af_jul,
                        ROUND(aitb_af_ago, 6) AS aitb_af_ago,
                        ROUND(aitb_af_sep, 6) AS aitb_af_sep,
                        ROUND(aitb_af_oct, 6) AS aitb_af_oct,
                        ROUND(aitb_af_nov, 6) AS aitb_af_nov,
                        ROUND(aitb_af_dic, 6) AS aitb_af_dic,
                        ROUND(total_aitb_af, 6) AS total_aitb_af,
                        ROUND(aitb_dep_acum_ene, 6) AS aitb_dep_acum_ene,
                        ROUND(aitb_dep_acum_feb, 6) AS aitb_dep_acum_feb,
                        ROUND(aitb_dep_acum_mar, 6) AS aitb_dep_acum_mar,
                        ROUND(aitb_dep_acum_abr, 6) AS aitb_dep_acum_abr,
                        ROUND(aitb_dep_acum_may, 6) AS aitb_dep_acum_may,
                        ROUND(aitb_dep_acum_jun, 6) AS aitb_dep_acum_jun,
                        ROUND(aitb_dep_acum_jul, 6) AS aitb_dep_acum_jul,
                        ROUND(aitb_dep_acum_ago, 6) AS aitb_dep_acum_ago,
                        ROUND(aitb_dep_acum_sep, 6) AS aitb_dep_acum_sep,
                        ROUND(aitb_dep_acum_oct, 6) AS aitb_dep_acum_oct,
                        ROUND(aitb_dep_acum_nov, 6) AS aitb_dep_acum_nov,
                        ROUND(aitb_dep_acum_dic, 6) AS aitb_dep_acum_dic,
                        ROUND(total_aitb_dep_acum, 6) AS total_aitb_dep_acum,
                        ROUND(dep_ene, 6) AS dep_ene,
                        ROUND(dep_feb, 6) AS dep_feb,
                        ROUND(dep_mar, 6) AS dep_mar,
                        ROUND(dep_abr, 6) AS dep_abr,
                        ROUND(dep_may, 6) AS dep_may,
                        ROUND(dep_jun, 6) AS dep_jun,
                        ROUND(dep_jul, 6) AS dep_jul,
                        ROUND(dep_ago, 6) AS dep_ago,
                        ROUND(dep_sep, 6) AS dep_sep,
                        ROUND(dep_oct, 6) AS dep_oct,
                        ROUND(dep_nov, 6) AS dep_nov,
                        ROUND(dep_dic, 6) AS dep_dic,
                        ROUND(total_dep, 6) AS total_dep,
                        ROUND(aitb_dep_ene, 6) AS aitb_dep_ene,
                        ROUND(aitb_dep_feb, 6) AS aitb_dep_feb,
                        ROUND(aitb_dep_mar, 6) AS aitb_dep_mar,
                        ROUND(aitb_dep_abr, 6) AS aitb_dep_abr,
                        ROUND(aitb_dep_may, 6) AS aitb_dep_may,
                        ROUND(aitb_dep_jun, 6) AS aitb_dep_jun,
                        ROUND(aitb_dep_jul, 6) AS aitb_dep_jul,
                        ROUND(aitb_dep_ago, 6) AS aitb_dep_ago,
                        ROUND(aitb_dep_sep, 6) AS aitb_dep_sep,
                        ROUND(aitb_dep_oct, 6) AS aitb_dep_oct,
                        ROUND(aitb_dep_nov, 6) AS aitb_dep_nov,
                        ROUND(aitb_dep_dic, 6) AS aitb_dep_dic,
                        ROUND(total_aitb_dep, 6) AS total_aitb_dep,
                        cuenta_activo,
                        cuenta_dep_acum,
                        cuenta_deprec,
                        desc_grupo,
                        desc_grupo_clasif,
                        cuenta_dep_acum_dos,
                        bk_codigo,
                        tipo
                        --Fin #ETR-4517
                        FROM kaf.treporte_detalle_dep2
                        WHERE id_movimiento = ' || v_id_movimiento || '
                        AND fecha = '''  || v_fecha || '''
                        AND id_moneda = ' || v_parametros.id_moneda || '
                        ORDER BY numero';

            RETURN v_consulta;

        END;

    --Inicio #AF-13
    /*********************************
     #TRANSACCION:  'SKA_RSALDAF_SEL'
     #DESCRIPCION:  Reporte de Saldos de activos fijos a una fecha
     #AUTOR:        RCM
     #FECHA:        18/10/2020
    ***********************************/
    ELSIF (p_transaccion = 'SKA_RSALDAF_SEL') THEN
        v_consulta = 'WITH tdepbs AS (
                        SELECT
                        afv.id_activo_fijo, mdep.vida_util, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.depreciacion_per,
                        mdep.monto_actualiz - mdep.depreciacion_acum as valor_neto, mdep.tipo_cambio_fin,
                        afv.monto_vigente_orig_100 as valor_compra, afv.monto_vigente_orig as valor_inicial
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || DATE_TRUNC('month', v_parametros.fecha) || '''::DATE)
                        AND mdep.id_moneda = 1
                    ), tdepusd AS (
                        SELECT
                        afv.id_activo_fijo, mdep.vida_util, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.depreciacion_per,
                        mdep.monto_actualiz - mdep.depreciacion_acum as valor_neto,
                        afv.monto_vigente_orig_100 as valor_compra, afv.monto_vigente_orig as valor_inicial
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || DATE_TRUNC('month', v_parametros.fecha) || '''::DATE)
                        AND mdep.id_moneda = 2
                    ), tdepufv AS (
                        SELECT
                        afv.id_activo_fijo, mdep.vida_util, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.depreciacion_per,
                        mdep.monto_actualiz - mdep.depreciacion_acum as valor_neto,
                        afv.monto_vigente_orig_100 as valor_compra, afv.monto_vigente_orig as valor_inicial
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        WHERE DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'', ''' || DATE_TRUNC('month', v_parametros.fecha) || '''::DATE)
                        AND mdep.id_moneda = 3
                    )
                    SELECT
                    af.codigo, af.codigo_ant as codigo_sap, af.denominacion, bs.vida_util,
                    bs.monto_actualiz AS val_actualiz_bs, bs.depreciacion_acum AS dep_acum_bs,
                    bs.depreciacion_per AS dep_per_bs, bs.valor_neto AS val_neto_bs,
                    ufv.monto_actualiz AS val_actualiz_ufv, ufv.depreciacion_acum AS dep_acum_ufv,
                    ufv.depreciacion_per AS dep_per_ufv, ufv.valor_neto AS val_neto_ufv,
                    CASE
                        WHEN COALESCE(ufv.monto_actualiz, 0) > 0 THEN (bs.monto_actualiz / ufv.monto_actualiz)
                        ELSE 0
                    END AS test_val_actualiz,
                    CASE
                        WHEN COALESCE(ufv.depreciacion_acum, 0) > 0 THEN (bs.depreciacion_acum / ufv.depreciacion_acum)
                        ELSE 0
                    END AS test_depreciacion_acum,
                    CASE
                        WHEN COALESCE(ufv.depreciacion_per, 0) > 0 THEN (bs.depreciacion_per / ufv.depreciacion_per)
                        ELSE 0
                    END AS test_depreciacion_per,
                    CASE
                        WHEN COALESCE(ufv.valor_neto, 0) > 0 THEN (bs.valor_neto / ufv.valor_neto)
                        ELSE 0
                    END AS test_val_neto
                    FROM tdepbs bs
                    INNER JOIN tdepusd usd
                    ON usd.id_activo_fijo = bs.id_activo_fijo
                    INNER JOIN tdepufv ufv
                    ON ufv.id_activo_fijo = bs.id_activo_fijo
                    INNER JOIN kaf.tactivo_fijo af
                    ON af.id_activo_fijo = bs.id_activo_fijo
                    ORDER BY 1';

        RETURN v_consulta;
    --Fin #AF-13

    ELSE
        RAISE EXCEPTION 'Transacción inexistente';
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        v_respuesta = '';
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'mensaje', SQLERRM);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'codigo_error', SQLSTATE);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'procedimiento', v_nombre_funcion);

        RAISE EXCEPTION '%', v_respuesta;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;