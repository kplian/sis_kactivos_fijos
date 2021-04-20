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
                        valor_compra,
                        valor_inicial,
                        valor_mes_ant,
                        altas,
                        bajas,
                        traspasos,
                        inc_actualiz,
                        valor_actualiz,
                        depreciacion_acum_gest_ant,
                        depreciacion_acum_mes_ant,
                        dep_acum_bajas,
                        dep_acum_tras,
                        inc_actualiz_dep_acum,
                        depreciacion,
                        depreciacion_acum,
                        monto_vigente,
                        aitb_dep_mes,
                        aitb_af_ene,
                        aitb_af_feb,
                        aitb_af_mar,
                        aitb_af_abr,
                        aitb_af_may,
                        aitb_af_jun,
                        aitb_af_jul,
                        aitb_af_ago,
                        aitb_af_sep,
                        aitb_af_oct,
                        aitb_af_nov,
                        aitb_af_dic,
                        total_aitb_af,
                        aitb_dep_acum_ene,
                        aitb_dep_acum_feb,
                        aitb_dep_acum_mar,
                        aitb_dep_acum_abr,
                        aitb_dep_acum_may,
                        aitb_dep_acum_jun,
                        aitb_dep_acum_jul,
                        aitb_dep_acum_ago,
                        aitb_dep_acum_sep,
                        aitb_dep_acum_oct,
                        aitb_dep_acum_nov,
                        aitb_dep_acum_dic,
                        total_aitb_dep_acum,
                        dep_ene,
                        dep_feb,
                        dep_mar,
                        dep_abr,
                        dep_may,
                        dep_jun,
                        dep_jul,
                        dep_ago,
                        dep_sep,
                        dep_oct,
                        dep_nov,
                        dep_dic,
                        total_dep,
                        aitb_dep_ene,
                        aitb_dep_feb,
                        aitb_dep_mar,
                        aitb_dep_abr,
                        aitb_dep_may,
                        aitb_dep_jun,
                        aitb_dep_jul,
                        aitb_dep_ago,
                        aitb_dep_sep,
                        aitb_dep_oct,
                        aitb_dep_nov,
                        aitb_dep_dic,
                        total_aitb_dep,
                        cuenta_activo,
                        cuenta_dep_acum,
                        cuenta_deprec,
                        desc_grupo,
                        desc_grupo_clasif,
                        cuenta_dep_acum_dos,
                        bk_codigo,
                        tipo
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