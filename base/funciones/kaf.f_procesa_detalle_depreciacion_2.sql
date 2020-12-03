CREATE OR REPLACE FUNCTION kaf.f_procesa_detalle_depreciacion_2 (
  p_id_usuario integer,
  p_fecha date,
  p_id_moneda integer
)
RETURNS varchar AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_procesa_detalle_depreciacion_2
 DESCRIPCION:    Preprocesa el detalle de depreciación en función formato 2020
 AUTOR:          RCM
 FECHA:          07/08/2020
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-10 KAF       ETR           07/08/2020  RCM         Creación
***************************************************************************/
DECLARE

    v_nombre_funcion    VARCHAR;
    v_respuesta         VARCHAR;
    v_fecha_ini         DATE;
    v_fecha_fin         DATE;
    v_fecha_fin_ant     DATE;
    v_fecha_ini_ant     DATE;
    v_id_movimiento     INTEGER;
    v_consulta          TEXT;
    v_fecha             DATE;

BEGIN

    v_nombre_funcion = 'kaf.f_procesa_detalle_depreciacion_2';

    --Obtención del id de la depreciación del mes solicitado
    SELECT mov.id_movimiento
    INTO v_id_movimiento
    FROM kaf.tmovimiento mov
    INNER JOIN param.tcatalogo cat
    ON cat.id_catalogo = mov.id_cat_movimiento
    WHERE DATE_TRUNC('month', mov.fecha_mov) = DATE_TRUNC('month', p_fecha::date)
    AND cat.codigo = 'deprec';

    --Verifica que la depreciación no esté finalizada
    IF EXISTS(SELECT 1
            FROM kaf.tmovimiento
            WHERE id_movimiento = v_id_movimiento
            AND estado = 'finalizado') THEN
        RAISE EXCEPTION 'No puede se puede procesar nuevamente porque la Depreciación ya fue Finalizada'; --#AF-10
    END IF;

    --Elimina los datos del movimiento en la moneda especificada
    DELETE FROM kaf.treporte_detalle_dep2
    WHERE id_movimiento = v_id_movimiento
    AND id_moneda = p_id_moneda;

    --Inicialización de variables
    v_fecha_ini = DATE_TRUNC('month', p_fecha);
    v_fecha_fin = DATE_TRUNC('month', p_fecha + '1 month'::INTERVAL) - '1 day'::INTERVAL;
    v_fecha_fin_ant = DATE_TRUNC('year', p_fecha) - '1 day'::INTERVAL;
    v_fecha_ini_ant = DATE_TRUNC('month', v_fecha_fin_ant);

    v_fecha = DATE_TRUNC('month', p_fecha);

    v_consulta = '
            INSERT INTO kaf.treporte_detalle_dep2 (
                id_usuario_reg,
                fecha_reg,
                estado_reg,
                id_movimiento,
                id_moneda,
                fecha,
                id_activo_fijo,
                id_activo_fijo_valor,
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
                valor_compra,
                valor_inicial,
                valor_mes_ant,
                altas,
                bajas,
                traspasos,
                inc_actualiz,
                valor_actualiz,
                vida_util_orig,
                vida_util_transc,
                vida_util,
                depreciacion_acum_gest_ant,
                depreciacion_acum_mes_ant,
                inc_actualiz_dep_acum,
                depreciacion,
                dep_acum_bajas,
                dep_acum_tras,
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
            )
            WITH tdata AS (
                WITH tant_gestion AS (
                    --tant_gestion: Depreciación a diciembre de la gestión pasada a la fecha hasta (Columnas: valor_inicial)
                    SELECT
                    afv.id_activo_fijo, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.monto_vigente, mdep.fecha,
                    mdep.id_movimiento_af_dep
                    FROM kaf.tmovimiento_af_dep mdep
                    INNER JOIN kaf.tactivo_fijo_valores afv
                    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                    WHERE mdep.fecha >= ''' || v_fecha_ini_ant ||''' and mdep.fecha <= ''' || v_fecha_fin_ant || '''
                    AND mdep.id_moneda = ' || p_id_moneda || '
                ), tant_mes AS (
                    --tant_mes: Depreciación al mes anterior a la fecha hasta (Columnas: valor_mes_ant)
                    SELECT
                    afv.id_activo_fijo, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.monto_vigente
                    FROM kaf.tmovimiento_af_dep mdep
                    INNER JOIN kaf.tactivo_fijo_valores afv
                    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                    WHERE mdep.fecha >= ''' || DATE_TRUNC('month', v_fecha_ini - '1 day'::INTERVAL) || ''' AND mdep.fecha <= ''' || v_fecha_ini - '1 day'::INTERVAL || '''
                    AND mdep.id_moneda = ' || p_id_moneda || '
                ), tdval_orig AS (
                    SELECT
                    maf.id_movimiento_af, maf.id_activo_fijo
                    FROM kaf.tmovimiento_af maf
                    INNER JOIN kaf.tmovimiento mov
                    ON mov.id_movimiento = maf.id_movimiento
                    INNER JOIN param.tcatalogo cat
                    ON cat.id_catalogo = mov.id_cat_movimiento
                    AND cat.codigo = ''dval''
                ), taitb_dep AS (
                    SELECT
                    id_activo_fijo, aitb_dep_ene, aitb_dep_feb, aitb_dep_mar, aitb_dep_abr, aitb_dep_may, aitb_dep_jun,
                    aitb_dep_jul, aitb_dep_ago, aitb_dep_sep, aitb_dep_oct, aitb_dep_nov, aitb_dep_dic
                    FROM crosstab(
                    $$WITH tdepaf AS (
                        SELECT
                        afv.id_activo_fijo, afv.id_activo_fijo_valor, afv.id_moneda,
                        mdep.id_movimiento_af_dep, mdep.fecha, mdep.depreciacion_per, mdep.depreciacion_acum, mdep.monto_actualiz
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        WHERE mdep.id_moneda = ' || p_id_moneda || '
                        AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                        AND mdep.fecha <= ''' || v_fecha_fin || '''

                    )
                    SELECT
                    afv.id_activo_fijo, DATE_PART(''month'', mdep.fecha), (dp.depreciacion_per * mdep.factor) - dp.depreciacion_per as aitb_dep
                    FROM kaf.tmovimiento_af_dep mdep
                    INNER JOIN kaf.tactivo_fijo_valores afv
                    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                    LEFT JOIN tdepaf dp
                    ON dp.id_activo_fijo = afv.id_activo_fijo
                    AND dp.id_moneda = afv.id_moneda
                    AND DATE_TRUNC(''month'', dp.fecha) = DATE_TRUNC(''month'', mdep.fecha - ''1 month''::interval)
                    WHERE mdep.id_moneda = ' || p_id_moneda || '
                    AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                    AND mdep.fecha <= ''' || v_fecha_fin || '''
                    ORDER BY 1
                    $$,
                    $$ SELECT m FROM generate_series(1,12) m $$
                    ) AS (
                      id_activo_fijo integer, aitb_dep_ene numeric, aitb_dep_feb numeric, aitb_dep_mar numeric, aitb_dep_abr numeric, aitb_dep_may numeric, aitb_dep_jun numeric, aitb_dep_jul numeric, aitb_dep_ago numeric, aitb_dep_sep numeric, aitb_dep_oct numeric, aitb_dep_nov numeric, aitb_dep_dic numeric
                    )
                ), tdep AS (
                    SELECT
                    id_activo_fijo, dep_ene, dep_feb, dep_mar, dep_abr, dep_may, dep_jun, dep_jul, dep_ago, dep_sep, dep_oct,
                    dep_nov, dep_dic
                    FROM crosstab(
                        $$
                        SELECT
                        afv.id_activo_fijo, DATE_PART(''month'', mdep.fecha)::INTEGER AS mes,

                        CASE
                            WHEN DATE_TRUNC(''MONTH'', afv.fecha_ini_dep) = DATE_TRUNC(''MONTH'', mdep.fecha) THEN
                                mdep.depreciacion + COALESCE(afv.aux_depmes_tot_del_inc, 0)
                            ELSE
                                mdep.depreciacion
                        END AS depreciacion

                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        WHERE mdep.id_moneda = ' || p_id_moneda || '
                        AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                        AND mdep.fecha <= ''' || v_fecha_fin || '''
                        ORDER BY 1
                        $$,
                        $$ SELECT m FROM generate_series(1, 12) m $$
                    ) AS (
                      id_activo_fijo INT, dep_ene NUMERIC, dep_feb NUMERIC, dep_mar NUMERIC, dep_abr NUMERIC, dep_may NUMERIC, dep_jun NUMERIC, dep_jul NUMERIC, dep_ago NUMERIC, dep_sep NUMERIC, dep_oct NUMERIC, dep_nov NUMERIC, dep_dic NUMERIC
                    )
                ), taitb_af AS (
                    SELECT
                    id_activo_fijo, aitb_af_ene, aitb_af_feb, aitb_af_mar, aitb_af_abr, aitb_af_may, aitb_af_jun, aitb_af_jul,
                    aitb_af_ago, aitb_af_sep, aitb_af_oct, aitb_af_nov, aitb_af_dic
                    FROM crosstab(
                        $$
                        SELECT
                        afv.id_activo_fijo,
                        DATE_PART(''month'', mdep.fecha)::INTEGER AS mes,
                        CASE
                            WHEN afv.fecha_ini_dep = mdep.fecha THEN
                                mdep.monto_actualiz - mdep.monto_actualiz_ant + COALESCE((afv.importe_modif - afv.importe_modif / ( param.f_get_tipo_cambio(3, (DATE_TRUNC(''month'', afv.fecha_ini_dep) - interval ''1 day'')::date, ''O'') /
                                param.f_get_tipo_cambio(3, COALESCE((DATE_TRUNC(''month'', py.fecha_rev_aitb) - interval ''1 day'')::date, DATE_TRUNC(''year'', afv.fecha_ini_dep)::date), ''O''))),0)
                            ELSE
                                mdep.monto_actualiz - mdep.monto_actualiz_ant
                        END AS aitb_af
                        --mdep.monto_actualiz - mdep.monto_actualiz_ant + COALESCE((afv.importe_modif - afv.importe_modif / ( param.f_get_tipo_cambio(3, (DATE_TRUNC(''month'', afv.fecha_ini_dep) - interval ''1 day'')::date, ''O'') /
                        --                param.f_get_tipo_cambio(3, COALESCE((DATE_TRUNC(''month'', py.fecha_rev_aitb) - interval ''1 day'')::date, DATE_TRUNC(''year'', afv.fecha_ini_dep)::date), ''O''))),0) as aitb_af
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        LEFT JOIN pro.tproyecto_activo pa
                        ON pa.id_proyecto_activo = afv.id_proyecto_activo
                        LEFT JOIN pro.tproyecto py
                        ON py.id_proyecto = pa.id_proyecto
                        WHERE mdep.id_moneda = ' || p_id_moneda || '
                        AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                        AND mdep.fecha <= ''' || v_fecha_fin || '''
                        ORDER BY 1
                        $$,
                        $$ SELECT m FROM generate_series(1, 12) m $$
                    ) AS (
                      id_activo_fijo INT, aitb_af_ene NUMERIC, aitb_af_feb NUMERIC, aitb_af_mar NUMERIC, aitb_af_abr NUMERIC, aitb_af_may NUMERIC, aitb_af_jun NUMERIC, aitb_af_jul NUMERIC, aitb_af_ago NUMERIC, aitb_af_sep NUMERIC, aitb_af_oct NUMERIC, aitb_af_nov NUMERIC, aitb_af_dic NUMERIC
                    )
                ), taitb_dep_acum AS (
                    SELECT
                    id_activo_fijo, aitb_dep_acum_ene, aitb_dep_acum_feb, aitb_dep_acum_mar, aitb_dep_acum_abr, aitb_dep_acum_may,
                    aitb_dep_acum_jun, aitb_dep_acum_jul, aitb_dep_acum_ago, aitb_dep_acum_sep, aitb_dep_acum_oct, aitb_dep_acum_nov, aitb_dep_acum_dic
                    FROM crosstab(
                        $$
                        WITH tdepaf AS (
                            SELECT
                            afv.id_activo_fijo, afv.id_activo_fijo_valor, afv.id_moneda,
                            mdep.id_movimiento_af_dep, mdep.fecha, mdep.depreciacion_per, mdep.depreciacion_acum, mdep.monto_actualiz
                            FROM kaf.tmovimiento_af_dep mdep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                            WHERE mdep.id_moneda = ' || p_id_moneda || '
                            AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                            AND mdep.fecha <= ''' || v_fecha_fin || '''
                        )
                        SELECT
                        afv.id_activo_fijo,
                        DATE_PART(''month'', mdep.fecha)::integer as mes,
                        /*CASE
                            WHEN DATE_TRUNC(''MONTH'', afv.fecha_ini_dep) = DATE_TRUNC(''MONTH'', mdep.fecha) THEN
                                mdep.depreciacion_acum_actualiz - COALESCE(dp.depreciacion_acum, mdep.depreciacion_acum_ant) - COALESCE(afv.aux_depmes_tot_del_inc, 0)
                            ELSE
                                mdep.depreciacion_acum_actualiz - COALESCE(dp.depreciacion_acum, mdep.depreciacion_acum_ant)
                        END AS aitb_dep_acum*/
                        CASE mdep.meses_acum
                            WHEN ''si'' THEN
                                mdep.tmp_inc_actualiz_dep_acum + COALESCE(mdep.aux_inc_dep_acum_del_inc, 0) --#33
                            ELSE
                                mdep.depreciacion_acum_actualiz - mdep.depreciacion_acum_ant + COALESCE(mdep.aux_inc_dep_acum_del_inc, 0)
                        END AS aitb_dep_acum
                        FROM kaf.tmovimiento_af_dep mdep
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        LEFT JOIN tdepaf dp
                        ON dp.id_activo_fijo = afv.id_activo_fijo
                        AND dp.id_moneda = afv.id_moneda
                        AND DATE_TRUNC(''month'', dp.fecha) = DATE_TRUNC(''month'', mdep.fecha - ''1 month''::interval)
                        WHERE mdep.id_moneda = ' || p_id_moneda || '
                        AND mdep.fecha >= ''' || DATE_TRUNC('year', v_fecha_fin) || '''
                        AND mdep.fecha <= ''' || v_fecha_fin || '''
                        ORDER BY 1
                        $$,
                        $$ SELECT m FROM generate_series(1,12) m $$
                    ) AS (
                      id_activo_fijo INT, aitb_dep_acum_ene NUMERIC, aitb_dep_acum_feb NUMERIC, aitb_dep_acum_mar NUMERIC, aitb_dep_acum_abr NUMERIC, aitb_dep_acum_may NUMERIC, aitb_dep_acum_jun NUMERIC, aitb_dep_acum_jul NUMERIC, aitb_dep_acum_ago NUMERIC, aitb_dep_acum_sep NUMERIC, aitb_dep_acum_oct NUMERIC, aitb_dep_acum_nov NUMERIC, aitb_dep_acum_dic NUMERIC
                    )
                ), trelcon AS (
                    --trecol: para obtener cuentas contables y partidas de las relaciones contables de activos fijos
                    SELECT
                    DISTINCT rc.id_tabla AS id_clasificacion,
                    ((''{'' || kaf.f_get_id_clasificaciones(rc.id_tabla, ''hijos'')::text) || ''}''::text)::integer [ ] AS nodos,
                    rc.id_gestion, rc.id_cuenta, trc.codigo_tipo_relacion, (cu.nro_cuenta || ''-'' || cu.nombre_cuenta)::VARCHAR as cuenta
                    FROM conta.ttabla_relacion_contable tb
                    JOIN conta.ttipo_relacion_contable trc
                    ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                    JOIN conta.trelacion_contable rc
                    ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                    INNER JOIN param.tgestion ges
                    ON ges.id_gestion = rc.id_gestion
                    AND DATE_TRUNC(''year'', ges.fecha_ini) = DATE_TRUNC(''year'', ''' || v_fecha_fin || '''    ::DATE)
                    INNER JOIN conta.tcuenta cu
                    ON cu.id_cuenta = rc.id_cuenta
                    WHERE tb.esquema = ''KAF''
                    AND tb.tabla = ''tclasificacion''
                    AND trc.codigo_tipo_relacion IN (''ALTAAF'', ''DEPACCLAS'', ''DEPCLAS'')
                ), tpri_dep AS (
                    --tpri_dep: para obtener la fecha del movimiento de su primera depreciación. (hay casos que la fecha_ini_dep es ene pero se lo hace
                    --depreciar en marzo, y para este reporte se valida con la fecha de la primera depreciación no la fecha ini. dep. para las columnas
                    -- altas, traspasos)
                    WITH tproyaf AS (
                      SELECT
                      pa.id_activo_fijo, MAX(py.id_proyecto) as id_proyecto
                      FROM pro.tproyecto_activo pa
                      INNER JOIN pro.tproyecto py
                      ON py.id_proyecto = pa.id_proyecto
                      GROUP BY pa.id_activo_fijo
                    )
                    SELECT
                    pa.id_activo_fijo, cb.fecha
                    FROM tproyaf pa
                    INNER JOIN pro.tproyecto py
                    ON py.id_proyecto = pa.id_proyecto
                    INNER JOIN conta.tint_comprobante cb
                    ON cb.id_int_comprobante = py.id_int_comprobante_1
                )
                SELECT DISTINCT
                af.codigo, af.codigo_ant as codigo_sap, af.denominacion, af.fecha_ini_dep, af.cantidad_af, --#58 cambio de afv.fecha_ini_dep por af.fecha_ini_dep
                umed.descripcion as unidad_medida, tcc.codigo as cc, af.nro_serie, ub.codigo as lugar,
                fun.desc_funcionario2 as responsable,
                COALESCE(afvo.monto_vigente_orig_100, afv.monto_vigente_orig_100) as valor_compra,
                COALESCE(age.monto_actualiz, 0) AS valor_inicial,
                COALESCE(ame.monto_actualiz, 0) AS valor_mes_ant,
                CASE kaf.f_define_origen (afv.id_proyecto_activo, afv.id_preingreso_det, afv.id_movimiento_af_especial, afv.id_movimiento_af, afv.mov_esp, afv.tipo)
                    WHEN ''proy'' THEN
                        CASE
                            WHEN DATE_TRUNC(''month'', pd.fecha) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                CASE
                                    WHEN COALESCE(afv.importe_modif) > 0 THEN
                                        afv.importe_modif / ( param.f_get_tipo_cambio(3, (DATE_TRUNC(''month'', afv.fecha_ini_dep) - interval ''1 day'')::date, ''O'') /
                                                    param.f_get_tipo_cambio(3, COALESCE((DATE_TRUNC(''month'', py.fecha_rev_aitb) - interval ''1 day'')::date, DATE_TRUNC(''year'', afv.fecha_ini_dep)::date), ''O''))
                                    ELSE
                                        COALESCE(age.monto_actualiz, afv.monto_vigente_orig)
                                END

                            ELSE
                                0
                        END
                    WHEN ''dval'' THEN
                        0
                    WHEN ''dval-bolsa'' THEN
                        0
                    ELSE
                        CASE
                            WHEN DATE_TRUNC(''month'', afv.fecha_ini_dep) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                COALESCE(age.monto_actualiz, afv.monto_vigente_orig)
                            ELSE
                                0
                        END
                END AS altas,

                CASE
                    WHEN af.fecha_baja IS NOT NULL AND DATE_TRUNC(''month'', af.fecha_baja) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                        mdep.monto_actualiz
                    ELSE 0
                END AS bajas,

                CASE kaf.f_define_origen (afv.id_proyecto_activo, afv.id_preingreso_det, afv.id_movimiento_af_especial, afv.id_movimiento_af, afv.mov_esp, afv.tipo)
                    WHEN ''proy'' THEN 0
                    WHEN ''dval'' THEN
                        CASE
                            WHEN DATE_TRUNC(''month'', afv.fecha_ini_dep) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                afv.monto_vigente_orig
                            ELSE
                                0
                        END
                    WHEN ''dval-bolsa'' THEN
                        CASE
                            WHEN DATE_TRUNC(''month'', afv.fecha_ini_dep) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                -1 *
                                (
                                    SELECT
                                    SUM(mesp.porcentaje)
                                    FROM kaf.tmovimiento_af_especial mesp
                                    WHERE mesp.id_movimiento_af = afv.id_movimiento_af
                                ) *
                                (
                                    SELECT _mdep1.monto_actualiz
                                    FROM kaf.tmovimiento_af_dep _mdep
                                    INNER JOIN kaf.tactivo_fijo_valores _afv
                                    ON _afv.id_activo_fijo_valor = _mdep.id_activo_fijo_valor
                                    INNER JOIN kaf.tactivo_fijo_valores _afv1
                                    ON _afv1.id_activo_fijo = _afv.id_activo_fijo
                                    INNER JOIN kaf.tmovimiento_af_dep _mdep1
                                    ON _mdep1.id_activo_fijo_valor = _afv1.id_activo_fijo_valor
                                    AND _mdep1.id_moneda = ' || p_id_moneda || '
                                    AND DATE_TRUNC(''month'', _mdep1.fecha) = DATE_TRUNC(''month'', ''' || v_fecha_ini - '1 day'::INTERVAL || '''::DATE)
                                    WHERE _mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                                ) / 100
                            ELSE
                                0
                        END
                    ELSE 0
                END AS traspasos,

                /*CASE kaf.f_define_origen (afv.id_proyecto_activo, afv.id_preingreso_det, afv.id_movimiento_af_especial, afv.id_movimiento_af, afv.mov_esp, afv.tipo)
                    WHEN ''dval-bolsa'' THEN
                        mdep.monto_actualiz - COALESCE(age.monto_actualiz, afv.monto_vigente_orig) -
                        (-1 *
                        COALESCE(( --#70
                            SELECT
                            SUM(mesp.porcentaje)
                            FROM kaf.tmovimiento_af_especial mesp
                            WHERE mesp.id_movimiento_af = afv.id_movimiento_af
                        ), 0) * --#70
                        COALESCE(( --#70
                            SELECT _mdep1.monto_vigente
                            FROM kaf.tmovimiento_af_dep _mdep
                            INNER JOIN kaf.tactivo_fijo_valores _afv
                            ON _afv.id_activo_fijo_valor = _mdep.id_activo_fijo_valor
                            INNER JOIN kaf.tactivo_fijo_valores _afv1
                            ON _afv1.id_activo_fijo = _afv.id_activo_fijo
                            INNER JOIN kaf.tmovimiento_af_dep _mdep1
                            ON _mdep1.id_activo_fijo_valor = _afv1.id_activo_fijo_valor
                            AND _mdep1.id_moneda = ' || p_id_moneda || '
                            AND DATE_TRUNC(''month'', _mdep1.fecha) = DATE_TRUNC(''month'', ''' || v_fecha_ini - '1 day'::INTERVAL || '''::DATE)
                            WHERE _mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                        ), 0) / 100) --#70
                    ELSE
                        mdep.monto_actualiz - COALESCE(age.monto_actualiz, afv.monto_vigente_orig)
                END AS inc_actualiz,*/
                /*CASE
                    WHEN mdep.monto_actualiz - COALESCE(age.monto_actualiz, afv.monto_vigente_orig) >= 0 THEN
                        mdep.monto_actualiz - COALESCE(age.monto_actualiz, afv.monto_vigente_orig)
                    ELSE
                        mdep.monto_actualiz - mdep.monto_actualiz_ant
                END AS inc_actualiz,
                mdep.monto_actualiz - mdep.monto_actualiz_ant AS inc_actualiz,*/
                CASE mdep.meses_acum
                    WHEN ''si'' THEN
                        mdep.tmp_inc_actualiz_dep_acum + COALESCE(mdep.aux_inc_dep_acum_del_inc, 0)
                    ELSE
                        mdep.depreciacion_acum_actualiz - mdep.depreciacion_acum_ant + COALESCE(mdep.aux_inc_dep_acum_del_inc, 0)
                END AS aitb_dep_acum,
                mdep.monto_actualiz as valor_actualiz,
                COALESCE(afvo.vida_util_orig, COALESCE(afv.vida_util_orig, 0)) AS vida_util_orig,
                COALESCE(afvo.vida_util_orig, COALESCE(afv.vida_util_orig, 0)) - COALESCE(mdep.vida_util, 0) as vida_util_transc,
                mdep.vida_util,
                COALESCE(age.depreciacion_acum, 0) as depreciacion_acum_gest_ant,
                COALESCE(ame.depreciacion_acum, 0) AS depreciacion_acum_mes_ant,
                mdep.depreciacion_acum - COALESCE(age.depreciacion_acum, 0) - mdep.depreciacion as inc_actualiz_dep_acum,
                --mdep.depreciacion,
                mdep.depreciacion + COALESCE(mdep.aux_depmes_tot_del_inc, 0) as depreciacion,
                CASE
                    WHEN af.fecha_baja IS NOT NULL AND DATE_TRUNC(''year'', af.fecha_baja) = DATE_TRUNC(''year'', ''' || v_fecha_fin || '''::DATE) THEN
                        mdep.depreciacion_acum
                    ELSE 0
                END as dep_acum_bajas,
                CASE kaf.f_define_origen (afv.id_proyecto_activo, afv.id_preingreso_det, afv.id_movimiento_af_especial, afv.id_movimiento_af, afv.mov_esp, afv.tipo)
                    WHEN ''proy'' THEN 0
                    WHEN ''dval'' THEN
                        CASE
                            WHEN DATE_TRUNC(''month'', afv.fecha_ini_dep) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                afv.depreciacion_acum_inicial
                            ELSE
                                0
                        END
                    WHEN ''dval-bolsa'' THEN --#AF-10
                        CASE
                            WHEN DATE_TRUNC(''month'', afv.fecha_ini_dep) = DATE_TRUNC(''month'', ''' || v_fecha_fin || '''::DATE) THEN
                                -1 *
                                (
                                    SELECT
                                    SUM(mesp.porcentaje)
                                    FROM kaf.tmovimiento_af_especial mesp
                                    WHERE mesp.id_movimiento_af = afv.id_movimiento_af
                                ) *
                                (
                                    SELECT _mdep1.depreciacion_acum
                                    FROM kaf.tmovimiento_af_dep _mdep
                                    INNER JOIN kaf.tactivo_fijo_valores _afv
                                    ON _afv.id_activo_fijo_valor = _mdep.id_activo_fijo_valor
                                    INNER JOIN kaf.tactivo_fijo_valores _afv1
                                    ON _afv1.id_activo_fijo = _afv.id_activo_fijo
                                    INNER JOIN kaf.tmovimiento_af_dep _mdep1
                                    ON _mdep1.id_activo_fijo_valor = _afv1.id_activo_fijo_valor
                                    AND _mdep1.id_moneda = ' || p_id_moneda || '
                                    AND DATE_TRUNC(''month'', _mdep1.fecha) = DATE_TRUNC(''month'', ''' || v_fecha_ini - '1 day'::INTERVAL || '''::DATE)
                                    WHERE _mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                                ) / 100
                            ELSE
                                0
                        END
                    ELSE 0
                END as dep_acum_tras,
                mdep.depreciacion_acum,
                mdep.depreciacion_per,
                mdep.monto_actualiz - COALESCE(mdep.depreciacion_acum, 0) AS monto_vigente, --mdep.monto_vigente, #70


                ROUND(COALESCE(aia.aitb_af_ene, 0), 2) AS aitb_af_ene,
                ROUND(COALESCE(aia.aitb_af_feb, 0), 2) AS aitb_af_feb,
                ROUND(COALESCE(aia.aitb_af_mar, 0), 2) AS aitb_af_mar,
                ROUND(COALESCE(aia.aitb_af_abr, 0), 2) AS aitb_af_abr,
                ROUND(COALESCE(aia.aitb_af_may, 0), 2) AS aitb_af_may,
                ROUND(COALESCE(aia.aitb_af_jun, 0), 2) AS aitb_af_jun,
                ROUND(COALESCE(aia.aitb_af_jul, 0), 2) AS aitb_af_jul,
                ROUND(COALESCE(aia.aitb_af_ago, 0), 2) AS aitb_af_ago,
                ROUND(COALESCE(aia.aitb_af_sep, 0), 2) AS aitb_af_sep,
                ROUND(COALESCE(aia.aitb_af_oct, 0), 2) AS aitb_af_oct,
                ROUND(COALESCE(aia.aitb_af_nov, 0), 2) AS aitb_af_nov,
                ROUND(COALESCE(aia.aitb_af_dic, 0), 2) AS aitb_af_dic,
                0::NUMERIC AS total_aitb_af,
                ROUND(COALESCE(aitb_dep_acum_ene, 0), 2) AS aitb_dep_acum_ene,
                ROUND(COALESCE(aitb_dep_acum_feb, 0), 2) AS aitb_dep_acum_feb,
                ROUND(COALESCE(aitb_dep_acum_mar, 0), 2) AS aitb_dep_acum_mar,
                ROUND(COALESCE(aitb_dep_acum_abr, 0), 2) AS aitb_dep_acum_abr,
                ROUND(COALESCE(aitb_dep_acum_may, 0), 2) AS aitb_dep_acum_may,
                ROUND(COALESCE(aitb_dep_acum_jun, 0), 2) AS aitb_dep_acum_jun,
                ROUND(COALESCE(aitb_dep_acum_jul, 0), 2) AS aitb_dep_acum_jul,
                ROUND(COALESCE(aitb_dep_acum_ago, 0), 2) AS aitb_dep_acum_ago,
                ROUND(COALESCE(aitb_dep_acum_sep, 0), 2) AS aitb_dep_acum_sep,
                ROUND(COALESCE(aitb_dep_acum_oct, 0), 2) AS aitb_dep_acum_oct,
                ROUND(COALESCE(aitb_dep_acum_nov, 0), 2) AS aitb_dep_acum_nov,
                ROUND(COALESCE(aitb_dep_acum_dic, 0), 2) AS aitb_dep_acum_dic,
                0::NUMERIC AS total_aitb_dep_acum,
                ROUND(COALESCE(dep.dep_ene, 0), 2) AS dep_ene,
                ROUND(COALESCE(dep.dep_feb, 0), 2) AS dep_feb,
                ROUND(COALESCE(dep.dep_mar, 0), 2) AS dep_mar,
                ROUND(COALESCE(dep.dep_abr, 0), 2) AS dep_abr,
                ROUND(COALESCE(dep.dep_may, 0), 2) AS dep_may,
                ROUND(COALESCE(dep.dep_jun, 0), 2) AS dep_jun,
                ROUND(COALESCE(dep.dep_jul, 0), 2) AS dep_jul,
                ROUND(COALESCE(dep.dep_ago, 0), 2) AS dep_ago,
                ROUND(COALESCE(dep.dep_sep, 0), 2) AS dep_sep,
                ROUND(COALESCE(dep.dep_oct, 0), 2) AS dep_oct,
                ROUND(COALESCE(dep.dep_nov, 0), 2) AS dep_nov,
                ROUND(COALESCE(dep.dep_dic, 0), 2) AS dep_dic,
                0::NUMERIC AS total_dep,
                ROUND(COALESCE(ad.aitb_dep_ene, 0), 2) AS aitb_dep_ene,
                ROUND(COALESCE(ad.aitb_dep_feb, 0), 2) AS aitb_dep_feb,
                ROUND(COALESCE(ad.aitb_dep_mar, 0), 2) AS aitb_dep_mar,
                ROUND(COALESCE(ad.aitb_dep_abr, 0), 2) AS aitb_dep_abr,
                ROUND(COALESCE(ad.aitb_dep_may, 0), 2) AS aitb_dep_may,
                ROUND(COALESCE(ad.aitb_dep_jun, 0), 2) AS aitb_dep_jun,
                ROUND(COALESCE(ad.aitb_dep_jul, 0), 2) AS aitb_dep_jul,
                ROUND(COALESCE(ad.aitb_dep_ago, 0), 2) AS aitb_dep_ago,
                ROUND(COALESCE(ad.aitb_dep_sep, 0), 2) AS aitb_dep_sep,
                ROUND(COALESCE(ad.aitb_dep_oct, 0), 2) AS aitb_dep_oct,
                ROUND(COALESCE(ad.aitb_dep_nov, 0), 2) AS aitb_dep_nov,
                ROUND(COALESCE(ad.aitb_dep_dic, 0), 2) AS aitb_dep_dic,
                0::NUMERIC AS total_aitb_dep,
                rc.cuenta AS cuenta_activo,
                rc1.cuenta AS cuenta_dep_acum,
                rc2.cuenta AS cuenta_deprec,
                gr.nombre AS desc_grupo,
                gr1.nombre AS desc_grupo_clasif,
                --Inicio #70
                cta.nro_cuenta || ''-'' || cta.nombre_cuenta AS cuenta_dep_acum_dos,
                af.bk_codigo,
                CASE
                    WHEN extract(month from mdep.fecha) = 1 THEN
                        0
                    ELSE
                        (mdep.depreciacion_per_ant * mdep.factor) - mdep.depreciacion_per_ant
                END AS aitb_dep_mes,
                --Fin #70
                kaf.f_define_origen(afv.id_proyecto_activo, afv.id_preingreso_det, afv.id_movimiento_af_especial, afv.id_movimiento_af, afv.mov_esp, afv.tipo) AS tipo,
                COALESCE(afv.aux_depmes_tot_del_inc, 0) AS aux_depmes_tot_del_inc,
                afv.id_activo_fijo, afv.id_activo_fijo_valor
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                LEFT JOIN kaf.tmovimiento_af maf
                ON maf.id_movimiento_af = afv.id_movimiento_af
                LEFT JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                LEFT JOIN kaf.tactivo_fijo af
                ON af.id_activo_fijo = afv.id_activo_fijo
                LEFT JOIN orga.vfuncionario fun
                ON fun.id_funcionario = af.id_funcionario
                LEFT JOIN param.tunidad_medida umed
                ON umed.id_unidad_medida = af.id_unidad_medida
                LEFT JOIN param.tcentro_costo cc
                ON cc.id_centro_costo = af.id_centro_costo
                LEFT JOIN param.ttipo_cc tcc
                ON tcc.id_tipo_cc = cc.id_tipo_cc
                LEFT JOIN kaf.tubicacion ub
                ON ub.id_ubicacion = af.id_ubicacion
                LEFT JOIN tant_gestion age
                ON age.id_activo_fijo = afv.id_activo_fijo
                LEFT JOIN tdval_orig tvo
                ON tvo.id_activo_fijo = af.id_activo_fijo
                LEFT JOIN kaf.tactivo_fijo_valores afvo
                ON afvo.id_activo_fijo_valor = afv.id_activo_fijo_valor_original
                INNER JOIN taitb_dep ad
                ON ad.id_activo_fijo = afv.id_activo_fijo
                INNER JOIN tdep dep
                ON dep.id_activo_fijo = afv.id_activo_fijo
                INNER JOIN taitb_af aia
                ON aia.id_activo_fijo = afv.id_activo_fijo
                INNER JOIN taitb_dep_acum ada
                ON ada.id_activo_fijo = afv.id_activo_fijo
                LEFT JOIN trelcon rc
                ON af.id_clasificacion = ANY (rc.nodos)
                AND rc.codigo_tipo_relacion = ''ALTAAF''
                LEFT JOIN trelcon rc1
                ON af.id_clasificacion = ANY (rc1.nodos)
                AND rc1.codigo_tipo_relacion = ''DEPACCLAS''
                LEFT JOIN trelcon rc2
                ON af.id_clasificacion = ANY (rc2.nodos)
                AND rc2.codigo_tipo_relacion = ''DEPCLAS''
                LEFT JOIN kaf.tgrupo gr
                ON gr.id_grupo = af.id_grupo
                LEFT JOIN kaf.tgrupo gr1
                ON gr1.id_grupo = af.id_grupo_clasif
                LEFT JOIN tant_mes ame
                ON ame.id_activo_fijo = afv.id_activo_fijo
                LEFT JOIN tpri_dep pd
                ON pd.id_activo_fijo = afv.id_activo_fijo
                --Inicio #70
                LEFT JOIN kaf.tactivo_fijo_cta_tmp act
                ON act.id_activo_fijo = af.id_activo_fijo
                LEFT JOIN conta.tcuenta cta
                ON cta.nro_cuenta = act.nro_cuenta
                AND cta.id_gestion = (SELECT id_gestion
                                    FROM param.tgestion
                                    WHERE DATE_TRUNC(''year'', fecha_ini) = DATE_TRUNC(''year'', ''' || p_fecha || '''::date))
                LEFT JOIN pro.tproyecto_activo pa
                ON pa.id_proyecto_activo = afv.id_proyecto_activo
                LEFT JOIN pro.tproyecto py
                ON py.id_proyecto = pa.id_proyecto
                --Fin #70

                WHERE mdep.fecha >= ''' || v_fecha_ini ||''' and mdep.fecha <= ''' || v_fecha_fin || '''
                AND mdep.id_moneda = ' || p_id_moneda || '
                --AND af.id_activo_fijo = 59427
                )
                SELECT
                ' || p_id_usuario || ',
                NOW(),
                ''activo'',
                ' || v_id_movimiento || ',
                ' || p_id_moneda || ',
                ''' || v_fecha || ''',
                id_activo_fijo,
                id_activo_fijo_valor,
                ROW_NUMBER() OVER(ORDER BY codigo) as numero,
                codigo, codigo_sap, denominacion, fecha_ini_dep, cantidad_af, unidad_medida,
                cc, nro_serie, lugar, responsable, valor_compra, valor_inicial, valor_mes_ant, altas, bajas, traspasos,
                (valor_actualiz - valor_mes_ant - altas - bajas - traspasos) as inc_actualiz,
                valor_actualiz, vida_util_orig, vida_util_transc, vida_util, depreciacion_acum_gest_ant,
                depreciacion_acum_mes_ant,
                (depreciacion_acum - depreciacion_acum_mes_ant - depreciacion - dep_acum_bajas - dep_acum_tras) as inc_actualiz_dep_acum, --##### considerar solo para primer mes
                depreciacion, -- + aux_depmes_tot_del_inc,  --##### considerar solo para primer mes
                dep_acum_bajas, dep_acum_tras, depreciacion_acum,
                --depreciacion_per, --#70
                monto_vigente,
                aitb_dep_mes, --#70
                aitb_af_ene, aitb_af_feb, aitb_af_mar, aitb_af_abr, aitb_af_may, aitb_af_jun, aitb_af_jul,
                aitb_af_ago, aitb_af_sep, aitb_af_oct, aitb_af_nov, aitb_af_dic,
                (aitb_af_ene + aitb_af_feb + aitb_af_mar + aitb_af_abr + aitb_af_may + aitb_af_jun + aitb_af_jul +
                aitb_af_ago + aitb_af_sep + aitb_af_oct + aitb_af_nov + aitb_af_dic) AS total_aitb_af,
                aitb_dep_acum_ene, aitb_dep_acum_feb, aitb_dep_acum_mar, aitb_dep_acum_abr, aitb_dep_acum_may, aitb_dep_acum_jun, aitb_dep_acum_jul,
                aitb_dep_acum_ago, aitb_dep_acum_sep, aitb_dep_acum_oct, aitb_dep_acum_nov, aitb_dep_acum_dic,
                (aitb_dep_acum_ene + aitb_dep_acum_feb + aitb_dep_acum_mar + aitb_dep_acum_abr + aitb_dep_acum_may + aitb_dep_acum_jun + aitb_dep_acum_jul + aitb_dep_acum_ago + aitb_dep_acum_sep + aitb_dep_acum_oct + aitb_dep_acum_nov + aitb_dep_acum_dic) AS total_aitb_dep_acum,
                dep_ene, dep_feb, dep_mar, dep_abr, dep_may, dep_jun, dep_jul, dep_ago, dep_sep, dep_oct, dep_nov, dep_dic,
                (dep_ene + dep_feb + dep_mar + dep_abr + dep_may + dep_jun + dep_jul + dep_ago + dep_sep + dep_oct + dep_nov + dep_dic) AS total_dep,
                aitb_dep_ene, aitb_dep_feb, aitb_dep_mar, aitb_dep_abr, aitb_dep_may, aitb_dep_jun, aitb_dep_jul, aitb_dep_ago, aitb_dep_sep, aitb_dep_oct, aitb_dep_nov, aitb_dep_dic,
                (aitb_dep_ene + aitb_dep_feb + aitb_dep_mar + aitb_dep_abr + aitb_dep_may + aitb_dep_jun + aitb_dep_jul + aitb_dep_ago + aitb_dep_sep + aitb_dep_oct + aitb_dep_nov + aitb_dep_dic) AS total_aitb_dep,
                cuenta_activo, cuenta_dep_acum, cuenta_deprec, desc_grupo, desc_grupo_clasif,
                cuenta_dep_acum_dos, bk_codigo, --#70
                tipo
                FROM tdata
                ORDER BY codigo';

    EXECUTE(v_consulta);


    ------------
    --RESPUESTA
    ------------

    RETURN 'hecho';

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
PARALLEL UNSAFE
COST 100;

ALTER FUNCTION kaf.f_procesa_detalle_depreciacion_2 (p_id_usuario integer, p_fecha date, p_id_moneda integer)
  OWNER TO postgres;
