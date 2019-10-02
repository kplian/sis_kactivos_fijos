CREATE OR REPLACE FUNCTION kaf.f_procesa_detalle_depreciacion (
  p_id_usuario integer,
  p_fecha date,
  p_id_moneda_dep integer
)
RETURNS varchar AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_procesa_detalle_depreciacion
 DESCRIPCION:    Preprocesa el detalle de depreciación
 AUTOR:          RCM
 FECHA:          22/10/2018
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #0     KAF       ETR           22/10/2018  RCM         Creación
 #32    KAF       ETR           24/09/2019  RCM         Actualización función
 #33    KAF       ETR           30/09/2019  RCM         Inclusión de total depreciación mensual del incremento y total inc. dep. acum. que suman a la depreciación del mes y al incremento
***************************************************************************/
DECLARE

    v_nombre_funcion  varchar;
    v_respuesta       varchar;
    v_id_moneda_base  integer;
    v_id_movimiento   integer;
    v_id_moneda       integer;
    v_id_movimientos  text;

BEGIN

    v_nombre_funcion = 'kaf.f_procesa_detalle_depreciacion';
    v_id_moneda_base = param.f_get_moneda_base();

    --Obtención de la moneda de la moneda_dep
    SELECT id_moneda
    INTO v_id_moneda
    FROM kaf.tmoneda_dep
    WHERE id_moneda_dep = p_id_moneda_dep;

    --Obtención del id de la depreciación del mes solicitado
    SELECT mov.id_movimiento
    INTO v_id_movimiento
    FROM kaf.tmovimiento mov
    INNER JOIN param.tcatalogo cat
    ON cat.id_catalogo = mov.id_cat_movimiento
    WHERE DATE_TRUNC('month', mov.fecha_mov) = DATE_TRUNC('month', p_fecha::date)
    AND cat.codigo = 'deprec';

    --Verifica si ya tiene datos procesados en esa fecha
    DELETE FROM kaf.treporte_detalle_depreciacion
    WHERE DATE_TRUNC('month', fecha_deprec) = DATE_TRUNC('month', p_fecha);

    --Creacion de tabla temporal de los actios fijos a filtrar
    CREATE TEMP TABLE tt_af_filtro (
        id_activo_fijo integer
    ) ON COMMIT DROP;

    --Creación de la tabla con los datos de la depreciación
    CREATE TEMP TABLE tt_detalle_depreciacion (
        id_activo_fijo_valor integer,
        codigo varchar(50),
        denominacion varchar(500),
        fecha_ini_dep date,
        monto_vigente_orig_100 numeric(18,2),
        monto_vigente_orig numeric(18,2),
        inc_actualiz numeric(18,2),
        monto_actualiz numeric(18,2),
        vida_util_orig integer,
        vida_util integer,
        depreciacion_acum_gest_ant numeric(18,2),
        depreciacion_acum_actualiz_gest_ant numeric(18,2),
        depreciacion_per numeric(18,2),
        depreciacion_acum numeric(18,2),
        monto_vigente numeric(18,2),
        codigo_padre varchar(15),
        denominacion_padre varchar(100),
        tipo varchar(50),
        tipo_cambio_fin numeric,
        id_moneda_act integer,
        id_activo_fijo_valor_original integer,
        codigo_ant varchar(50),
        id_moneda integer,
        id_centro_costo integer,
        id_activo_fijo integer,
        codigo_activo varchar,
        afecta_concesion varchar,
        id_activo_fijo_valor_padre integer,
        depreciacion numeric(18,2),
        depreciacion_per_ant numeric,
        importe_modif numeric,
        incremento_otra_gestion varchar(2) DEFAULT 'no',
        aux_depmes_tot_del_inc numeric, --#33
        aux_inc_dep_acum_del_inc numeric --#33
    ) ON COMMIT DROP;

    -------------------------
    --OBTENCIÓN DE DATOS
    -------------------------
    --Carga los datos en la tabla temporal
    INSERT INTO tt_detalle_depreciacion(
    id_activo_fijo_valor, codigo, denominacion, fecha_ini_dep, monto_vigente_orig_100 ,monto_vigente_orig, inc_actualiz,
    monto_actualiz, vida_util_orig, vida_util,
    depreciacion_per, depreciacion_acum, monto_vigente, codigo_padre, denominacion_padre, tipo, tipo_cambio_fin, id_moneda_act,
    id_activo_fijo_valor_original, codigo_ant,id_moneda, id_centro_costo, id_activo_fijo, codigo_activo, afecta_concesion,
    depreciacion, depreciacion_per_ant, importe_modif,
    aux_depmes_tot_del_inc, aux_inc_dep_acum_del_inc --#33
    )
    SELECT
    afv.id_activo_fijo_valor,
    afv.codigo,
    af.denominacion,
    --afv.fecha_ini_dep,
    CASE COALESCE(afv.id_activo_fijo_valor_original, 0)
        WHEN 0 THEN afv.fecha_ini_dep
        ELSE
            CASE COALESCE(afv.importe_modif, 0)
                WHEN 0 THEN
                    (SELECT fecha_ini_dep FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
                ELSE
                    afv.fecha_ini_dep
            END
    END AS fecha_ini_dep,
    --COALESCE(afv.monto_vigente_orig_100,afv.monto_vigente_orig),
    CASE COALESCE(afv.id_activo_fijo_valor_original, 0)
        WHEN 0 THEN afv.monto_vigente_orig_100
        ELSE (SELECT monto_vigente_orig_100 FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original/*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
    END AS monto_vigente_orig_100,
--            afv.monto_vigente_orig,
    CASE COALESCE(afv.id_activo_fijo_valor_original ,0)
        WHEN 0 THEN afv.monto_vigente_orig
        ELSE (SELECT monto_vigente_orig FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
    END AS monto_vigente_orig,
    --(COALESCE(mdep.monto_actualiz,0) - COALESCE(afv.monto_vigente_orig,0)) AS inc_actualiz,
    CASE
        WHEN (COALESCE(mdep.monto_actualiz, 0) - COALESCE(afv.monto_vigente_orig, 0)) < 0 THEN 0
        ELSE (COALESCE(mdep.monto_actualiz, 0) - COALESCE(afv.monto_vigente_orig, 0))
    END AS inc_actualiz,
    mdep.monto_actualiz,
    /*case COALESCE(afv.id_activo_fijo_valor_original,0)
        when 0 then afv.monto_vigente_orig * mdep.factor
        else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original) * mdep.factor
    end AS monto_actualiz,*/
    afv.vida_util_orig,
    mdep.vida_util,
    mdep.depreciacion_per,
    mdep.depreciacion_acum,
    mdep.monto_vigente,
    SUBSTR(afv.codigo,1, POSITION('.' IN afv.codigo) - 1) AS codigo_padre,
    (SELECT nombre FROM kaf.tclasificacion WHERE codigo_completo_tmp = SUBSTR(afv.codigo, 1, position('.' IN afv.codigo) - 1)) AS denominacion_padre,
    afv.tipo,
    mdep.tipo_cambio_fin,
    mon.id_moneda_act,
    afv.id_activo_fijo_valor_original,
    af.codigo_ant,
    mon.id_moneda,
    af.id_centro_costo,
    af.id_activo_fijo,
    af.codigo,
    af.afecta_concesion,
    mdep.depreciacion,
    mdep.depreciacion_per_ant,
    afv.importe_modif,
    --Inicio #33
    mdep.aux_depmes_tot_del_inc,
    mdep.aux_inc_dep_acum_del_inc
    --Fin #33
    FROM kaf.tmovimiento_af_dep mdep
    INNER JOIN kaf.tactivo_fijo_valores afv
    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
    INNER JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = afv.id_activo_fijo
    INNER JOIN kaf.tmoneda_dep mon
    ON mon.id_moneda =  afv.id_moneda
    WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', p_fecha::date)
    AND mdep.id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
    --and afv.id_activo_fijo_valor = 276602
    AND af.estado <> 'eliminado'
    AND DATE_TRUNC('year', COALESCE(af.fecha_baja, '01-01-1900'::date)) <> DATE_TRUNC('year', p_fecha::date);


    INSERT INTO tt_detalle_depreciacion(
    id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
    monto_actualiz,vida_util_orig,vida_util,
    depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
    id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
    depreciacion,depreciacion_per_ant,importe_modif,
    aux_depmes_tot_del_inc, aux_inc_dep_acum_del_inc --#33
    )
    SELECT
    afv.id_activo_fijo_valor,
    afv.codigo,
    af.denominacion,
    --afv.fecha_ini_dep,
    CASE COALESCE(afv.id_activo_fijo_valor_original,0)
        WHEN 0 THEN afv.fecha_ini_dep
        ELSE
            CASE COALESCE(afv.importe_modif,0)
                WHEN 0 THEN
                    (SELECT fecha_ini_dep FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
                ELSE
                     afv.fecha_ini_dep
            END
    END AS fecha_ini_dep,
    --afv.monto_vigente_orig_100,
    --afv.monto_vigente_orig,
    CASE COALESCE(afv.id_activo_fijo_valor_original,0)
        WHEN 0 THEN afv.monto_vigente_orig_100
        ELSE (SELECT monto_vigente_orig_100 FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original/*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
    END AS monto_vigente_orig_100,
--            afv.monto_vigente_orig,
    CASE COALESCE(afv.id_activo_fijo_valor_original,0)
        WHEN 0 THEN afv.monto_vigente_orig
        ELSE (SELECT monto_vigente_orig FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
    END AS monto_vigente_orig,
    --(COALESCE(mdep.monto_actualiz,0) - COALESCE(afv.monto_vigente_orig,0)) AS inc_actualiz,
    CASE
          WHEN (COALESCE(mdep.monto_actualiz,0) - COALESCE(afv.monto_vigente_orig,0)) < 0 THEN 0
          ELSE (COALESCE(mdep.monto_actualiz,0) - COALESCE(afv.monto_vigente_orig,0))
    END AS inc_actualiz,
    mdep.monto_actualiz,
    /*case COALESCE(afv.id_activo_fijo_valor_original,0)
        when 0 then afv.monto_vigente_orig * mdep.factor
        else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original) * mdep.factor
    end AS monto_actualiz,*/
    afv.vida_util_orig, mdep.vida_util,
    mdep.depreciacion_per,
    mdep.depreciacion_acum,
    mdep.monto_vigente,
    SUBSTR(afv.codigo, 1, POSITION('.' IN afv.codigo) - 1) AS codigo_padre,
    (SELECT nombre FROM kaf.tclasificacion WHERE codigo_completo_tmp = substr(afv.codigo, 1, position('.' IN afv.codigo) - 1)) AS denominacion_padre,
    afv.tipo,
    mdep.tipo_cambio_fin,
    mon.id_moneda_act,
    afv.id_activo_fijo_valor_original,
    af.codigo_ant,
    mon.id_moneda,
    af.id_centro_costo,
    af.id_activo_fijo,
    af.codigo,
    af.afecta_concesion,
    mdep.depreciacion,
    mdep.depreciacion_per_ant,
    afv.importe_modif,
    --Inicio #33
    mdep.aux_depmes_tot_del_inc,
    mdep.aux_inc_dep_acum_del_inc
    --Fin #33
    FROM kaf.tmovimiento_af_dep mdep
    INNER JOIN kaf.tactivo_fijo_valores afv
    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
    INNER JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = afv.id_activo_fijo
    INNER JOIN kaf.tmoneda_dep mon
    ON mon.id_moneda =  afv.id_moneda
    WHERE afv.fecha_fin IS NOT NULL
    AND af.estado IN ('retiro','baja')
    AND NOT EXISTS (SELECT FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor_original = afv.id_activo_fijo_valor AND tipo <> 'alta')
    AND afv.codigo NOT IN (SELECT codigo
                            FROM tt_detalle_depreciacion)
    --and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor /*and tipo = 'alta'*/ )
    --and DATE_TRUNC('month',mdep.fecha) <> DATE_TRUNC('month',p_fecha::date)
    --and DATE_TRUNC('month',mdep.fecha) < DATE_TRUNC('month',p_fecha::date) --between DATE_TRUNC('month',('01-01-'||EXTRACT(year from p_fecha::date)::varchar)::date) and DATE_TRUNC('month',p_fecha::date)
    AND DATE_TRUNC('month',mdep.fecha) = (SELECT max(fecha)
                                            FROM kaf.tmovimiento_af_dep
                                            WHERE id_activo_fijo_valor = afv.id_activo_fijo_valor
                                            AND id_moneda_dep = mdep.id_moneda_dep
                                            --and DATE_TRUNC('month',fecha) <> DATE_TRUNC('month',p_fecha::date)
                                            AND DATE_TRUNC('month', fecha) <= DATE_TRUNC('month', p_fecha::date) --between DATE_TRUNC('month',('01-01-'||EXTRACT(year from p_fecha)::varchar)::date) and DATE_TRUNC('month',p_fecha)
                                        )
    AND mdep.id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
    AND afv.id_activo_fijo_valor not IN (SELECT id_activo_fijo_valor
                                        FROM tt_detalle_depreciacion)
    AND af.estado <> 'eliminado'
    --and af.fecha_baja >= p_fecha::date
    --and afv.id_activo_fijo_valor = 276602
    AND DATE_TRUNC('year', af.fecha_baja) = DATE_TRUNC('year', p_fecha::date)
    AND DATE_TRUNC('month', af.fecha_baja) = DATE_TRUNC('month', afv.fecha_fin + '1 month'::interval);

    --------------------------
    --ACTUALIZACIÓN DE DATOS
    ---------------------------
    UPDATE tt_detalle_depreciacion SET
    id_activo_fijo_valor_padre = kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor);

    UPDATE tt_detalle_depreciacion SET
    --fecha_ini_dep = (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
    monto_vigente_orig_100 = (SELECT monto_vigente_orig_100 FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
    monto_vigente_orig = (SELECT monto_vigente_orig FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
    vida_util_orig = (SELECT vida_util_orig FROM kaf.tactivo_fijo_valores WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre)
    WHERE COALESCE(id_activo_fijo_valor_original,0) <> 0;

    --09/09/2019: Para los incremento por cierre de proyectos, cuya depreciación del padre es de diferente gestión que del nuevo
    UPDATE tt_detalle_depreciacion DEST SET
    monto_vigente_orig = ORIG.monto_actualiz_ant,
    incremento_otra_gestion = 'si'
    FROM (
      WITH tdeprec AS (
          SELECT id_activo_fijo_valor, id_moneda,
          CASE MIN(fecha)
              WHEN '01-12-2017' THEN '01-01-2018'
              ELSE MIN(fecha)
          END AS fecha_min
          FROM kaf.tmovimiento_af_dep
          GROUP BY id_activo_fijo_valor, id_moneda
      )
      SELECT
      afv.id_activo_fijo_valor, mdep.monto_actualiz_ant
      FROM kaf.tactivo_fijo_valores afv
      INNER JOIN kaf.tactivo_fijo_valores afv1
      ON afv1.id_activo_fijo_valor = afv.id_activo_fijo_valor_original
      INNER JOIN tdeprec dep
      ON dep.id_activo_fijo_valor = afv1.id_activo_fijo_valor
      AND dep.id_moneda = afv1.id_moneda
      INNER JOIN kaf.tmovimiento_af_dep mdep
      ON mdep.id_activo_fijo_valor = dep.id_activo_fijo_valor
      AND mdep.id_moneda = dep.id_moneda
      AND DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('year', afv.fecha_ini_dep)
      WHERE afv.id_activo_fijo_valor_original IS NOT NULL
      AND COALESCE(afv.importe_modif, 0) <> 0
      AND DATE_TRUNC('year', afv.fecha_ini_dep) > DATE_TRUNC('year', dep.fecha_min)
    ) ORIG
    WHERE DEST.id_activo_fijo_valor = ORIG.id_activo_fijo_valor;

    --------------------------------------------------
    --------------------------------------------------
    --Obtiene los datos de gestion anterior
    UPDATE tt_detalle_depreciacion SET
    depreciacion_acum_gest_ant = COALESCE((
        SELECT depreciacion_acum
        FROM kaf.tmovimiento_af_dep
        WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
        AND id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
        AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', ('01-12-' || EXTRACT(year FROM p_fecha::date)::integer - 1)::date)
    ),0),
    depreciacion_acum_actualiz_gest_ant = (((tt_detalle_depreciacion.tipo_cambio_fin/(param.f_get_tipo_cambio_v2(tt_detalle_depreciacion.id_moneda_act,tt_detalle_depreciacion.id_moneda /*v_parametros.id_moneda*/, ('31/12/'||EXTRACT(year from p_fecha::date)::integer -1)::date, 'O')))) - 1)
                * (COALESCE((
                    SELECT depreciacion_acum
                    FROM kaf.tmovimiento_af_dep
                    WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                    AND id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
                    AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', ('01-12-' || EXTRACT(year FROM p_fecha)::integer -1 )::date)
                ),0)),
    monto_vigente_orig = COALESCE((
        SELECT monto_actualiz
        FROM kaf.tmovimiento_af_dep
        WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
        AND id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
        AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', ('01-12-' || EXTRACT(year FROM p_fecha::date)::integer - 1)::date)
    ), monto_vigente_orig);

    --Si la depreciación anterior es cero, busca la depreciación de su activo fijo valor original si es que tuviese
    UPDATE tt_detalle_depreciacion SET
    depreciacion_acum_gest_ant = COALESCE((
        SELECT depreciacion_acum
        FROM kaf.tmovimiento_af_dep
        WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre/*tt_detalle_depreciacion.id_activo_fijo_valor_original*/ /*kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor)*/
        AND tipo = tt_detalle_depreciacion.tipo
        AND id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
        AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', ('01-12-' || EXTRACT(year FROM p_fecha::date)::integer - 1)::date)
    ),0),
    depreciacion_acum_actualiz_gest_ant = (((tt_detalle_depreciacion.tipo_cambio_fin / (param.f_get_tipo_cambio_v2(tt_detalle_depreciacion.id_moneda_act, tt_detalle_depreciacion.id_moneda/*v_parametros.id_moneda*/, ('31/12/' || EXTRACT(year FROM p_fecha::date)::integer -1)::date, 'O')))) - 1) * (COALESCE((
                    SELECT depreciacion_acum
                    FROM kaf.tmovimiento_af_dep
                    WHERE id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre/*tt_detalle_depreciacion.id_activo_fijo_valor_original*/  /*kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor)*/
                    AND tipo = tt_detalle_depreciacion.tipo
                    AND id_moneda_dep = p_id_moneda_dep --#25 cambio de v_parametros.id_moneda por p_id_moneda_dep
                    AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month',('01-12-' || EXTRACT(year FROM p_fecha::date)::integer - 1)::date)
                ),0))
    WHERE COALESCE(depreciacion_acum_gest_ant, 0) = 0
    AND id_activo_fijo_valor_original IS NOT NULL;

    ------------------------------
    --INSERCIÓN DE DATOS EN TABLA
    ------------------------------
    --Creación de la tabla con la agrupación y totales
    CREATE TEMP TABLE tt_detalle_depreciacion_totales (
        codigo varchar(50),
        denominacion varchar(500),
        fecha_ini_dep date,
        monto_vigente_orig_100 numeric(24,2),
        monto_vigente_orig numeric(24,2),
        inc_actualiz numeric(24,2),
        monto_actualiz numeric(24,2),
        vida_util_orig integer,
        vida_util integer,
        depreciacion_acum_gest_ant numeric(24,2),
        depreciacion_acum_actualiz_gest_ant numeric(24,2),
        depreciacion_per numeric(24,2),
        depreciacion_acum numeric(24,2),
        monto_vigente numeric(24,2),
        nivel integer,
        orden bigint,
        tipo varchar(10),
        codigo_ant varchar(50),
        id_centro_costo integer,
        id_activo_fijo integer,
        codigo_activo varchar,
        afecta_concesion varchar,
        depreciacion numeric(24,2),
        depreciacion_per_ant numeric,
        importe_modif numeric(24,2),
        --Inicio #9: Inclusión de nuevas columnas
        cc1 varchar(50),
        cc2 varchar(50),
        cc3 varchar(50),
        cc4 varchar(50),
        cc5 varchar(50),
        cc6 varchar(50),
        cc7 varchar(50),
        cc8 varchar(50),
        cc9 varchar(50),
        cc10 varchar(50),
        dep_mes_cc1 numeric(24,2),
        dep_mes_cc2 numeric(24,2),
        dep_mes_cc3 numeric(24,2),
        dep_mes_cc4 numeric(24,2),
        dep_mes_cc5 numeric(24,2),
        dep_mes_cc6 numeric(24,2),
        dep_mes_cc7 numeric(24,2),
        dep_mes_cc8 numeric(24,2),
        dep_mes_cc9 numeric(24,2),
        dep_mes_cc10 numeric(24,2),
        --Fin #9
        incremento_otra_gestion varchar(2) default 'no',
        --Inicio #31
        aitb_dep_acum       numeric(24, 2),
        aitb_dep            numeric(24, 2),
        aitb_dep_acum_anual numeric(24, 2),
        aitb_dep_anual      numeric(24, 2)
        --Fin #31
    ) ON COMMIT DROP;

    INSERT INTO tt_detalle_depreciacion_totales
    SELECT
    codigo,
    denominacion,
    fecha_ini_dep,
    monto_vigente_orig_100,
    monto_vigente_orig,
    inc_actualiz,
    monto_actualiz,
    vida_util_orig,
    vida_util,
    depreciacion_acum_gest_ant,
    depreciacion_acum_actualiz_gest_ant,
    depreciacion_per,
    depreciacion_acum,
    monto_vigente,
    1,--codigo_padre::integer,
    1,--replace(replace(replace(replace(replace(replace(codigo,'A0',''),'AJ',''),'G',''),'RE',''),'.',''),'-','')::bigint,
    'detalle',
    codigo_ant,
    id_centro_costo,
    id_activo_fijo,
    codigo,
    afecta_concesion,
    depreciacion + COALESCE(aux_depmes_tot_del_inc, 0), --#33 se suma la dep total del mes del inc
    depreciacion_per_ant,
    importe_modif,
    --Inicio #9: Inclusión de nuevas columnas
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    --Fin #9
    incremento_otra_gestion,
    --Inicio #31
    NULL,
    NULL
    --Fin #31
    FROM tt_detalle_depreciacion;

    -------------------------
    --PROCESAMIENTO DE DATOS
    -------------------------
    --Creación de tabla temporal con el prorrateo del mes
    CREATE TEMP TABLE tt_prorrateo_af (
        id_activo_fijo  integer,
        id_centro_costo integer,
        cantidad_horas  numeric(18,2),
        total_hrs_af    numeric(18,2),
        cc              varchar(150),
        dep_mes         numeric(24,2),
        nro_columna     integer
    ) ON COMMIT DROP;

    --Inserta los datos en la tabla temporal
    INSERT INTO tt_prorrateo_af
    WITH taf_horas AS (
        SELECT
        acc.id_activo_fijo, SUM(acc.cantidad_horas) AS total_hrs_af
        FROM kaf.tactivo_fijo_cc acc
        WHERE DATE_TRUNC('month',mes) = DATE_TRUNC('month', p_fecha)
        GROUP BY acc.id_activo_fijo
      )
    SELECT
    acc.id_activo_fijo, acc.id_centro_costo, acc.cantidad_horas, ah.total_hrs_af, tcc.codigo AS cc,
    SUM(acc.cantidad_horas / ah.total_hrs_af) OVER (PARTITION BY acc.id_activo_fijo, acc.id_centro_costo) * t.depreciacion AS dep_mes,
    row_number() OVER(PARTITION BY acc.id_activo_fijo) AS nro_columna
    FROM kaf.tactivo_fijo_cc acc
    INNER JOIN taf_horas ah
    ON ah.id_activo_fijo = acc.id_activo_fijo
    INNER JOIN param.tcentro_costo cc
    ON cc.id_centro_costo = acc.id_centro_costo
    INNER JOIN param.ttipo_cc tcc
    ON tcc.id_tipo_cc = cc.id_tipo_cc
    INNER JOIN tt_detalle_depreciacion_totales t
    ON t.id_activo_fijo = acc.id_activo_fijo
    WHERE DATE_TRUNC('month', mes) = DATE_TRUNC('month', p_fecha);

    --Actualización de los datos
    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc1 = CASE WHEN DAT.nro_columna = 1 THEN DAT.cc ELSE cc1 END,
    dep_mes_cc1 = CASE WHEN DAT.nro_columna = 1 THEN DAT.dep_mes ELSE dep_mes_cc1 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 1;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc2 = CASE WHEN DAT.nro_columna = 2 THEN DAT.cc ELSE DEP.cc2 END,
    dep_mes_cc2 = CASE WHEN DAT.nro_columna = 2 THEN DAT.dep_mes ELSE dep_mes_cc2 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 2;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc3 = CASE WHEN DAT.nro_columna = 3 THEN DAT.cc ELSE DEP.cc3 END,
    dep_mes_cc3 = CASE WHEN DAT.nro_columna = 3 THEN DAT.dep_mes ELSE dep_mes_cc3 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 3;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc4 = CASE WHEN DAT.nro_columna = 4 THEN DAT.cc ELSE DEP.cc4 END,
    dep_mes_cc4 = CASE WHEN DAT.nro_columna = 4 THEN DAT.dep_mes ELSE dep_mes_cc4 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 4;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc5 = CASE WHEN DAT.nro_columna = 5 THEN DAT.cc ELSE DEP.cc5 END,
    dep_mes_cc5 = CASE WHEN DAT.nro_columna = 5 THEN DAT.dep_mes ELSE dep_mes_cc5 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 5;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc6 = CASE WHEN DAT.nro_columna = 6 THEN DAT.cc ELSE DEP.cc6 END,
    dep_mes_cc6 = CASE WHEN DAT.nro_columna = 6 THEN DAT.dep_mes ELSE dep_mes_cc6 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 6;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc7 = CASE WHEN DAT.nro_columna = 7 THEN DAT.cc ELSE DEP.cc7 END,
    dep_mes_cc7 = CASE WHEN DAT.nro_columna = 7 THEN DAT.dep_mes ELSE dep_mes_cc7 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 7;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc8 = CASE WHEN DAT.nro_columna = 8 THEN DAT.cc ELSE DEP.cc8 END,
    dep_mes_cc8 = CASE WHEN DAT.nro_columna = 8 THEN DAT.dep_mes ELSE dep_mes_cc8 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 8;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc9 = CASE WHEN DAT.nro_columna = 9 THEN DAT.cc ELSE DEP.cc9 END,
    dep_mes_cc9 = CASE WHEN DAT.nro_columna = 9 THEN DAT.dep_mes ELSE dep_mes_cc9 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 9;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    cc10 = CASE WHEN DAT.nro_columna = 10 THEN DAT.cc ELSE DEP.cc10 END,
    dep_mes_cc10 = CASE WHEN DAT.nro_columna = 10 THEN DAT.dep_mes ELSE dep_mes_cc10 END
    FROM (
        SELECT * FROM tt_prorrateo_af
    ) DAT
    WHERE DEP.id_activo_fijo = DAT.id_activo_fijo
    AND DAT.nro_columna = 10;
    --Fin #9

    --Inicio #31
    --Actualización depreciación acumulada
    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep_acum = ANX.dep_acum_actualiz
    FROM kaf.v_cbte_deprec_actualiz_dep_acum_detalle ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo
    AND ANX.id_movimiento = v_id_movimiento;

    --Actualización depreciación
    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep = ANX.dep_per_actualiz
    FROM kaf.v_cbte_deprec_actualiz_dep_per__cta_detalle ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo
    AND ANX.id_movimiento = v_id_movimiento;

    --Obtención de los movimientos de todo el año
    SELECT pxp.list(mov.id_movimiento::varchar)
    INTO v_id_movimientos
    FROM kaf.tmovimiento mov
    INNER JOIN param.tcatalogo cat
    ON cat.id_catalogo = mov.id_cat_movimiento
    WHERE DATE_TRUNC('month', mov.fecha_mov) BETWEEN DATE_TRUNC('year', p_fecha) AND DATE_TRUNC('month', p_fecha)
    AND cat.codigo = 'deprec';


    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep_acum_anual = ANX.dep_acum_actualiz
    FROM (
        SELECT id_activo_fijo, SUM(dep_acum_actualiz) AS dep_acum_actualiz
        FROM kaf.v_cbte_deprec_actualiz_dep_acum_detalle
        WHERE id_movimiento::text = ANY (string_to_array(v_id_movimientos, ','))
        GROUP BY id_activo_fijo
    ) ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo;

    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep_anual = ANX.dep_per_actualiz
    FROM (
        SELECT id_activo_fijo, SUM(dep_per_actualiz) AS dep_per_actualiz
        FROM kaf.v_cbte_deprec_actualiz_dep_per__cta_detalle
        WHERE id_movimiento::text = ANY (string_to_array(v_id_movimientos, ','))
        GROUP BY id_activo_fijo
    ) ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo;

    --Actualización depreciación acumulada anual
    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep_acum_anual = ANX.dep_acum_actualiz
    FROM (
        SELECT id_activo_fijo, SUM(dep_acum_actualiz) AS dep_acum_actualiz
        FROM kaf.v_cbte_deprec_actualiz_dep_acum_detalle
        WHERE id_movimiento IN (
            SELECT mov.id_movimiento
            FROM kaf.tmovimiento mov
            INNER JOIN param.tcatalogo cat
            ON cat.id_catalogo = mov.id_cat_movimiento
            WHERE DATE_TRUNC('month', mov.fecha_mov) BETWEEN DATE_TRUNC('year', p_fecha) AND DATE_TRUNC('month', p_fecha)
            AND cat.codigo = 'deprec'
        )
        GROUP BY id_activo_fijo
    ) ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo;

    --Actualización depreciación anual
    UPDATE tt_detalle_depreciacion_totales DEP SET
    aitb_dep_anual = ANX.dep_per_actualiz
    FROM (
        SELECT id_activo_fijo, SUM(dep_per_actualiz) AS dep_per_actualiz
        FROM kaf.v_cbte_deprec_actualiz_dep_per__cta_detalle
        WHERE id_movimiento IN (
            SELECT mov.id_movimiento
            FROM kaf.tmovimiento mov
            INNER JOIN param.tcatalogo cat
            ON cat.id_catalogo = mov.id_cat_movimiento
            WHERE DATE_TRUNC('month', mov.fecha_mov) BETWEEN DATE_TRUNC('year', p_fecha) AND DATE_TRUNC('month', p_fecha)
            AND cat.codigo = 'deprec'
        )
        GROUP BY id_activo_fijo
    ) ANX
    WHERE DEP.id_activo_fijo = ANX.id_activo_fijo;
    --Fin #31


    --------------
    --QUERY FINAL
    --------------
    DELETE FROM kaf.treporte_detalle_dep
    WHERE fecha = p_fecha;

    INSERT INTO kaf.treporte_detalle_dep
    WITH tta AS (
        SELECT DISTINCT
        rc_1.id_tabla AS id_clasificacion,
        (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer [ ] AS nodos
        FROM conta.ttabla_relacion_contable tb
        JOIN conta.ttipo_relacion_contable trc
        ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
        JOIN conta.trelacion_contable rc_1
        ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
        WHERE tb.esquema = 'KAF'
        AND tb.tabla = 'tclasificacion'
        AND trc.codigo_tipo_relacion IN ('ALTAAF', 'DEPACCLAS', 'DEPCLAS')
    )
    SELECT
    v_id_movimiento,
    v_id_moneda,
    now(),
    p_fecha,
    row_number() OVER(ORDER BY tt.codigo) AS numero, --#22 Se quita el -1
    tt.codigo,
    tt.codigo_ant,
    tt.denominacion,
    tt.fecha_ini_dep,
    af.cantidad_af,
    um.descripcion AS desc_unidad_medida,
    cc.codigo_tcc, --10
    af.nro_serie,
    ubi.codigo AS desc_ubicacion,
    fun.desc_funcionario2 AS responsable,
    tt.monto_vigente_orig_100, --monto de la compra
    --Se aumenta lógica para el caso de ajustes que incementen el monto
    CASE
        --Si el año de la fecha de generación del reporte es diferente al año de la fecha de inicio depreciación, muestra el valor, eoc. muestra 0
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM tt.fecha_ini_dep) THEN
            CASE
                WHEN COALESCE(tt.importe_modif,0) = 0 THEN 0--se pone cero porque el importe irá en Altas
                ELSE tt.monto_vigente_orig
            END
        ELSE
            tt.monto_vigente_orig
    END AS monto_vigente_orig,
    --Se aumenta lógica para el caso de ajustes que incementen el monto. Si se genera en la misma gestion y es ajuste de incremento, solo muestra el incremento
    CASE
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM tt.fecha_ini_dep) THEN
            CASE COALESCE(tt.importe_modif,0)
              WHEN 0 THEN tt.monto_vigente_orig
              ELSE
                    CASE incremento_otra_gestion
                        --Cuando es incremente y es de otra gestión, muestra el importe modificado sin actualización por lo que aplica X = importe modif / factor
                        WHEN 'si' THEN tt.importe_modif / ( param.f_get_tipo_cambio(3, (DATE_TRUNC('month', tt.fecha_ini_dep) - interval '1 day')::date, 'O') /
                                        param.f_get_tipo_cambio(3, DATE_TRUNC('year', tt.fecha_ini_dep)::date, 'O'))
                        ELSE tt.importe_modif
                    END
            END
        ELSE 0
    END AS af_altas,
    CASE
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM COALESCE(af.fecha_baja, '01-01-1900'))
            AND DATE_TRUNC('month', COALESCE(af.fecha_baja, '01-01-1900')) <= DATE_TRUNC('month', p_fecha) THEN
            tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18, 2)
        ELSE 0
    END AS af_bajas,
    0::numeric AS af_traspasos,
    --(tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2) AS inc_actualiz,
    CASE COALESCE(tt.importe_modif,0)
        WHEN 0 THEN (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18, 2)
        ELSE
            CASE incremento_otra_gestion
                --Cuando es incremente y es de otra gestión, resta además el importe modificado sin actualización por lo que aplica X = importe modif / factor
                WHEN 'si' THEN (tt.monto_actualiz - tt.monto_vigente_orig - (tt.importe_modif / ( param.f_get_tipo_cambio(3, (DATE_TRUNC('month', tt.fecha_ini_dep) - interval '1 day')::date, 'O') /
                    param.f_get_tipo_cambio(3, DATE_TRUNC('year', tt.fecha_ini_dep)::date, 'O'))))::numeric(18, 2)
                ELSE (tt.monto_actualiz - tt.monto_vigente_orig /*- tt.importe_modif*/)::numeric(18, 2)
            END
    END AS inc_actualiz,
    --Se aumenta lógica para el caso de ajustes que incementen el monto
    CASE COALESCE(tt.importe_modif, 0)
        WHEN 0 THEN tt.monto_actualiz - (CASE
                                            WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM COALESCE(af.fecha_baja, '01-01-1900'))
                                                AND DATE_TRUNC('month',COALESCE(af.fecha_baja, '01-01-1900')) <= DATE_TRUNC('month', p_fecha) THEN
                                                tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18, 2)
                                            ELSE 0
                                        END)
        ELSE tt.monto_actualiz -- + tt.importe_modif
    END AS monto_actualiz, --20
    tt.vida_util_orig,
    tt.vida_util_orig - tt.vida_util AS vida_util_usada,
    tt.vida_util,
    tt.depreciacion_acum_gest_ant,
    --tt.depreciacion_acum-tt.depreciacion_acum_gest_ant-tt.depreciacion,--tt.depreciacion_acum_actualiz_gest_ant,
     CASE v_id_moneda
        WHEN v_id_moneda_base THEN tt.depreciacion_acum - tt.depreciacion_acum_gest_ant - tt.depreciacion
        ELSE 0
    END AS inc_act_dep_acum,
    tt.depreciacion,--tt.depreciacion_per, --tt.depreciacion_acum - COALESCE(tt.depreciacion_acum_gest_ant,0) - COALESCE(tt.depreciacion_acum_actualiz_gest_ant,0),
    CASE
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM COALESCE(af.fecha_baja, '01-01-1900'))
            AND DATE_TRUNC('month', p_fecha) >= DATE_TRUNC('month', COALESCE(af.fecha_baja, '01-01-1900'))  THEN
            tt.depreciacion_acum
        ELSE 0
    END AS depreciacion_acum_bajas,
    0::numeric AS depreciacion_acum_traspasos,
    CASE
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM COALESCE(af.fecha_baja, '01-01-1900'))
            AND DATE_TRUNC('month', p_fecha) >= DATE_TRUNC('month', COALESCE(af.fecha_baja, '01-01-1900'))  THEN
            0
        ELSE tt.depreciacion_acum
    END AS depreciacion_acum,
    tt.depreciacion_per,--tt.depreciacion, *********** --30
    CASE
        WHEN EXTRACT(year FROM p_fecha) = EXTRACT(year FROM COALESCE(af.fecha_baja, '01-01-1900'))
            AND DATE_TRUNC('month', COALESCE(af.fecha_baja, '01-01-1900')) <= DATE_TRUNC('month', p_fecha) THEN
            0
        ELSE tt.monto_actualiz - tt.depreciacion_acum
    END AS monto_vigente,

    --Inicio #31
    tt.aitb_dep_acum,
    tt.aitb_dep,
    tt.aitb_dep_acum_anual,
    tt.aitb_dep_anual,
    --Fin #31

    --tt.afecta_concesion,
    (SELECT c.nro_cuenta || '-' ||c.nombre_cuenta
            FROM conta.tcuenta c
            WHERE c.id_cuenta IN (SELECT id_cuenta
                                FROM conta.trelacion_contable rc
                                INNER JOIN conta.ttipo_relacion_contable trc
                                ON trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                WHERE trc.codigo_tipo_relacion = 'ALTAAF'
                                AND rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion(p_fecha))
                                AND rc.estado_reg = 'activo'
                                AND rc.id_tabla = tta.id_clasificacion
                                )
            )
    AS cuenta_activo,
    (SELECT c.nro_cuenta || '-' ||c.nombre_cuenta
    FROM conta.tcuenta c
    WHERE c.id_cuenta IN (SELECT id_cuenta
                        FROM conta.trelacion_contable rc
                        INNER JOIN conta.ttipo_relacion_contable trc
                        ON trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                        WHERE trc.codigo_tipo_relacion = 'DEPACCLAS'
                        AND rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion(p_fecha))
                        AND rc.estado_reg = 'activo'
                        AND rc.id_tabla = tta.id_clasificacion
                        )
    ) AS cuenta_dep_acum,
    (SELECT c.nro_cuenta || '-' ||c.nombre_cuenta
            FROM conta.tcuenta c
            WHERE c.id_cuenta IN (SELECT id_cuenta
                                FROM conta.trelacion_contable rc
                                INNER JOIN conta.ttipo_relacion_contable trc
                                ON trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                WHERE trc.codigo_tipo_relacion = 'DEPCLAS'
                                AND rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion(p_fecha))
                                AND rc.estado_reg = 'activo'
                                AND rc.id_tabla = tta.id_clasificacion
                                )
            )
    AS cuenta_deprec,

    gr.nombre AS desc_grupo,
    gr1.nombre AS desc_grupo_clasif, --40
    cta.nro_cuenta || '-' ||cta.nombre_cuenta AS cuenta_dep_acum_dos,
    af.bk_codigo,
    tt.cc1,
    tt.dep_mes_cc1,
    tt.cc2,
    tt.dep_mes_cc2,
    tt.cc3,
    tt.dep_mes_cc3,
    tt.cc4,
    tt.dep_mes_cc4, --50
    tt.cc5,
    tt.dep_mes_cc5,
    tt.cc6,
    tt.dep_mes_cc6,
    tt.cc7,
    tt.dep_mes_cc7,
    tt.cc8,
    tt.dep_mes_cc8,
    tt.cc9,
    tt.dep_mes_cc9, --60
    tt.cc10,
    tt.dep_mes_cc10,
    tt.id_activo_fijo,
    tt.nivel,
    tt.orden,
    tt.tipo --66
    FROM tt_detalle_depreciacion_totales tt
    LEFT JOIN param.vcentro_costo cc
    ON cc.id_centro_costo = tt.id_centro_costo
    LEFT JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = tt.id_activo_fijo
    LEFT JOIN tta
    ON af.id_clasificacion = ANY (tta.nodos)
    LEFT JOIN orga.vfuncionario fun
    ON fun.id_funcionario = af.id_funcionario
    LEFT JOIN kaf.tubicacion ubi
    ON ubi.id_ubicacion = af.id_ubicacion
    LEFT JOIN kaf.tgrupo gr
    ON gr.id_grupo = af.id_grupo
    LEFT JOIN kaf.tgrupo gr1
    ON gr1.id_grupo = af.id_grupo_clasif
    LEFT JOIN param.tunidad_medida um
    ON um.id_unidad_medida = af.id_unidad_medida
    LEFT JOIN kaf.tactivo_fijo_cta_tmp act
    ON act.id_activo_fijo = tt.id_activo_fijo
    LEFT JOIN conta.tcuenta cta
    ON cta.nro_cuenta = act.nro_cuenta
    AND cta.id_gestion = (SELECT id_gestion FROM param.tgestion WHERE DATE_TRUNC('year', fecha_ini) = DATE_TRUNC('year', p_fecha))
    ORDER BY tt.codigo;

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
COST 100;
