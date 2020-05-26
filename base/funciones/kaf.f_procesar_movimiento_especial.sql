CREATE OR REPLACE FUNCTION kaf.f_procesar_movimiento_especial (
    p_id_usuario integer,
    p_id_movimiento integer,
    p_id_tipo_estado integer --#39
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_procesar_movimiento_especial
 DESCRIPCION:   Lógica para procesar la Distribución de Valores
 AUTOR:         RCM
 FECHA:         30/05/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           30/05/2019  RCM         Creación del archivo
 #39    KAF       ETR           26/11/2019  RCM         Importación masiva Distribución de valores: se aumenta parámetro id_tipo_estado
 #48    KAF       ETR           11/02/2020  RCM         Modificación de la finalización y creación de nuevos AFV de activos fijos originales
 #57    KAF       ETR           25/03/2020  RCM         Adición de id_movimiento_af_especial en kaf.tactivo_fijo y kaf.tactivo_fijo_valores
 #58    KAF       ETR           14/04/2020  RCM         Cambio de tipo en AFVs para las bolsas a dval-b
 #60    KAF       ETR           28/04/2020  RCM         Inclusión de fecha para TC inicial predefinido para la primera depreciación del AF enla creación de AFVs
 #61    KAF       ETR           30/04/2020  RCM         Al generar el AF falta incluir marca y nro de serie
 #67    KAF       ETR           20/05/2020  RCM         Codificar los AFVs al procesar la disgregación
 #68    KAF       ETR           22/05/2020  RCM         Considerar disgregación con monto parcial del AF origen
***************************************************************************
*/
DECLARE

    v_nombre_funcion        varchar;
    v_resp                  varchar;
    v_id_moneda             integer;
    v_rec                   record;
    v_rec_af                record;
    v_monto_act             numeric;
    v_dep_acum              numeric;
    v_dep_per               numeric;
    v_monto_rescate_gral    numeric;
    v_cod_afv               varchar;
    v_tc_ini                numeric;
    v_tc_fin                numeric;
    --Inicio #39
    v_fecha_mov             DATE; --07/11/2019
    v_monto_act_inicial     NUMERIC; --07/11/2019
    v_cod_estado            VARCHAR;
    --Fin #39

    --Inicio #48
    v_vida_util             NUMERIC;
    v_fecha_ini_dep         DATE;
    v_monto_actualiz        NUMERIC;
    v_depreciacion_acum     NUMERIC;
    v_depreciacion_per      NUMERIC;
    v_monto_vigente         NUMERIC;
    v_monto_rescate         NUMERIC;
    v_id_moneda_base        INTEGER;
    --Fin #48
    --Inicio #68
    v_monto_vigente_actualiz_inicial NUMERIC;
    v_depreciacion_acum_inicial      NUMERIC;
    --Fin #68

BEGIN

    --Nombre de la función
    v_nombre_funcion = 'kaf.f_procesar_movimiento_especial';
    v_monto_rescate_gral = 1;
    v_cod_afv = 'dval';

    --Obtención del código del estado siguiente
    SELECT codigo
    INTO v_cod_estado
    FROM wf.ttipo_estado
    WHERE id_tipo_estado = p_id_tipo_estado;

    ------------------
    --1. VALIDACIONES
    ------------------
    IF NOT EXISTS (SELECT 1
                    FROM kaf.tmovimiento
                    WHERE id_movimiento = p_id_movimiento) THEN
        RAISE EXCEPTION 'Movimiento inexistente';
    END IF;

    IF NOT EXISTS(SELECT 1
                    FROM kaf.tmovimiento MOV
                    INNER JOIN param.tcatalogo CAT
                    ON CAT.id_catalogo = MOV.id_cat_movimiento
                    WHERE MOV.id_movimiento = p_id_movimiento
                    AND CAT.codigo = v_cod_afv) THEN
        RETURN 'No es un Movimiento de Distribución de Valores. Nada que Hacer';
    END IF;

    /*IF EXISTS (SELECT 1
                FROM kaf.tmovimiento
                WHERE id_movimiento = p_id_movimiento
                AND estado = 'borrador') THEN
        RAISE EXCEPTION 'No puede procesarse porque el Movimiento está en Borrador';
    END IF;*/

    -------------------
    --2. PROCESAMIENTO
    -------------------
    --Obtención de ID moneda parametrizada
    SELECT id_moneda
    INTO v_id_moneda
    FROM param.tmoneda
    WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

    IF COALESCE(v_id_moneda, 0) = 0 THEN
        RAISE EXCEPTION 'Falta la parametrización de la Moneda para movimientos (kaf_mov_especial_moneda)';
    END IF;

    --------------------------------------------------------------------
    --2.1 Finalización AFV de activos fijos originales kaf.tmovimiento_af en todas las monedas (verificado ..ok)
    --------------------------------------------------------------------
    UPDATE kaf.tactivo_fijo_valores DEST SET
    fecha_fin = ORIG.fecha_mov,
    fecha_mod = now(),
    id_usuario_mod = p_id_usuario,
    mov_esp = 'mafv-' || p_id_movimiento::varchar
    FROM (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        mov.fecha_mov, mdep.id_activo_fijo_valor
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        WHERE maf.id_movimiento = p_id_movimiento
    ) ORIG
    WHERE DEST.id_activo_fijo_valor = ORIG.id_activo_fijo_valor;

    --------------------------------------------------------------
    --2.2 Creación de nuevos AFVs de los activos fijos originales
    --------------------------------------------------------------
    --Inicio RCM 07/11/2019
    --Obtención de la fecha
    SELECT
    fecha_mov
    INTO
    v_fecha_mov
    FROM kaf.tmovimiento
    WHERE id_movimiento = p_id_movimiento;
    --Fin RCM 07/11/2019

    v_id_moneda_base = param.f_get_moneda_base();--#48 Obtención de la moneda base

    FOR v_rec IN --consulta verificada --#48
    (
        WITH tult_dep AS (
            --Fecha de la última depreciación para obtener información de los activos fijos originales
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_activo_fijo = afv.id_activo_fijo
            WHERE maf.id_movimiento = p_id_movimiento
            GROUP BY afv.id_activo_fijo
        ), tmonto_orig AS (
            --Monto actualizado total por activo fijo original para calcular saldo si hubiera
            WITH tult_dep AS (
              SELECT
              afv.id_activo_fijo,
              MAX(mdep.fecha) AS fecha_max
              FROM kaf.tmovimiento_af_dep mdep
              INNER JOIN kaf.tactivo_fijo_valores afv
              ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
              INNER JOIN kaf.tmovimiento_af maf
              ON maf.id_activo_fijo = afv.id_activo_fijo
              WHERE maf.id_movimiento = p_id_movimiento
              GROUP BY afv.id_activo_fijo
            )
            SELECT
            maf.id_movimiento, maf.id_activo_fijo, SUM(mdep.monto_actualiz) as valor_actualiz
            FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            INNER JOIN tult_dep udep
            ON udep.id_activo_fijo = afv.id_activo_fijo
            AND udep.fecha_max = mdep.fecha
            WHERE maf.id_movimiento = p_id_movimiento
            AND afv.id_moneda = v_id_moneda
            GROUP BY maf.id_movimiento, maf.id_activo_fijo
        ), tdistribucion AS (
            --Importe total (monto actualizado) registrado para la distribución, para posterior cálculo de saldo
            SELECT
            maf.id_movimiento, maf.id_activo_fijo, SUM(mesp.costo_orig) as costo_af
            FROM kaf.tmovimiento_af_especial mesp
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento_af = mesp.id_movimiento_af
            WHERE maf.id_movimiento =  p_id_movimiento
            GROUP BY maf.id_movimiento, maf.id_activo_fijo
        )
        SELECT
        mdep.id_moneda, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.depreciacion_per,
        afv.id_activo_fijo, afv.id_activo_fijo_valor,
        mdep.vida_util, mov.fecha_mov, mod.id_moneda_dep, mod.id_moneda_act,
        vn.valor_actualiz - td.costo_af as saldo,
        td.costo_af / vn.valor_actualiz as factor, --#68
        maf.id_movimiento_af, --#57
        af.codigo --#67
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento mov
        ON mov.id_movimiento = maf.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep udep
        ON udep.id_activo_fijo = afv.id_activo_fijo
        AND udep.fecha_max = mdep.fecha
        INNER JOIN kaf.tmoneda_dep mod
        ON mod.id_moneda = mdep.id_moneda
        INNER JOIN tmonto_orig vn
        ON vn.id_movimiento = maf.id_movimiento
        AND vn.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN tdistribucion td
        ON td.id_movimiento = maf.id_movimiento
        AND td.id_activo_fijo = maf.id_activo_fijo
        --Inicio #67
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = afv.id_activo_fijo
        --Fin #67
        WHERE maf.id_movimiento = p_id_movimiento
    ) LOOP

        --Verifica si el activo fijo original aun tiene saldo para definir como crear los nuevos AFVs
        IF v_rec.saldo > 1 THEN
            --Existe saldo pendiente
            v_vida_util = v_rec.vida_util; --#68
            v_monto_actualiz = v_rec.monto_actualiz - (v_rec.monto_actualiz * v_rec.factor); --#68
            v_depreciacion_acum = v_rec.depreciacion_acum - (v_rec.depreciacion_acum * v_rec.factor); --#68
            v_depreciacion_per = v_rec.depreciacion_per - (v_rec.depreciacion_per * v_rec.factor); --#68

            IF v_rec.id_moneda = v_id_moneda THEN
                v_monto_actualiz = v_rec.saldo;
            END IF;

            v_monto_vigente = v_monto_actualiz; --#68
            v_monto_vigente_actualiz_inicial = v_monto_actualiz; --#68
            v_depreciacion_acum_inicial = v_depreciacion_acum; --#68

        ELSE
            --Saldo cero
            v_vida_util = 0;
            v_fecha_ini_dep = v_rec.fecha_mov;
            v_monto_actualiz = v_rec.depreciacion_acum;
            v_depreciacion_acum = v_rec.depreciacion_acum;
            v_depreciacion_per = 0;--v_rec.depreciacion_per; --#48
            v_monto_vigente = v_rec.monto_actualiz; --#48

            v_monto_vigente_actualiz_inicial = v_depreciacion_acum; --#68
            v_depreciacion_acum_inicial = v_depreciacion_acum; --#68

        END IF;

        --Parámetros generales que no dependen del saldo
        v_fecha_ini_dep = DATE_TRUNC('MONTH', v_rec.fecha_mov); --#60
        v_monto_rescate = 1 * param.f_get_tipo_cambio_v2(v_id_moneda_base, v_rec.id_moneda, v_fecha_mov, 'O');

        --Inserción del activo fijo valor
        INSERT INTO kaf.tactivo_fijo_valores (
        id_usuario_reg          , fecha_reg                             , estado_reg                        , id_activo_fijo,
        monto_vigente_orig      , vida_util_orig                        , fecha_ini_dep                     , depreciacion_per,
        depreciacion_acum       , monto_vigente                         , vida_util                         , estado,
        monto_rescate           , tipo                                  , fecha_inicio                      , id_moneda_dep,
        id_moneda               , monto_vigente_orig_100                , monto_vigente_actualiz_inicial    , depreciacion_acum_inicial,
        depreciacion_per_inicial, mov_esp                               , id_movimiento_af                  , fecha_tc_ini_dep, --#60
        codigo --#67
        ) VALUES (
        --Inicio #48
        p_id_usuario            , now()                                 , 'activo'                          , v_rec.id_activo_fijo,
        v_monto_vigente         , v_vida_util                           , v_fecha_ini_dep                   , v_depreciacion_per,
        v_depreciacion_acum     , v_monto_vigente                       , v_vida_util                       , 'activo',
        v_monto_rescate         , v_cod_afv || '-b'                     , v_rec.fecha_mov                   , v_rec.id_moneda_dep, --#58
        v_rec.id_moneda         , v_monto_vigente                       , v_monto_vigente_actualiz_inicial  , v_depreciacion_acum_inicial, --#68
        v_depreciacion_per      , 'cafv-' || p_id_movimiento::VARCHAR, --cafv: creación activo fijo valor
        v_rec.id_movimiento_af  , v_fecha_ini_dep - '1 day'::INTERVAL, --#60
        v_rec.codigo --#67
        --Fin #48
        );

    END LOOP;

    -------------------------------------------------
    --CASO 2.3: CREACIÓN DE LOS ACTIVOS FIJOS NUEVOS
    -------------------------------------------------
    FOR v_rec IN INSERT INTO kaf.tactivo_fijo( --consulta verificada ..ok --#48
                    estado_reg,
                    fecha_compra,
                    id_cat_estado_fun,
                    id_cat_estado_compra,
                    observaciones,
                    monto_rescate,
                    denominacion,
                    id_funcionario,
                    id_deposito,
                    monto_compra_orig,
                    monto_compra,
                    id_moneda,
                    descripcion,
                    id_moneda_orig,
                    fecha_ini_dep,
                    vida_util_original,
                    estado,
                    id_clasificacion,
                    id_centro_costo,
                    id_depto,
                    id_usuario_reg,
                    fecha_reg,
                    cantidad_af,
                    monto_compra_orig_100,
                    id_activo_fijo_padre,
                    id_oficina,
                    id_proyecto,
                    codigo_ant,
                    bk_codigo,
                    --Inicio #48
                    id_unidad_medida,
                    id_ubicacion,
                    id_grupo,
                    id_grupo_clasif,
                    ubicacion,
                    en_deposito,
                    --Fin #48
                    id_movimiento_af_especial, --#57
                    marca, --#61
                    nro_serie --#61
                )
                SELECT
                'activo',
                mafe.fecha_compra, --#48
                af.id_cat_estado_fun,
                af.id_cat_estado_compra,
                'Creado desde Distribución de Valores',
                af.monto_rescate,
                mafe.denominacion,
                mafe.id_funcionario, --#48
                af.id_deposito,
                --Inicio #48
                mafe.costo_orig,
                mafe.costo_orig,
                v_id_moneda,
                --Fin #48
                mafe.denominacion,
                maf.id_moneda,--id_moneda_orig,
                mafe.fecha_ini_dep,
                mafe.vida_util,
                'registrado',
                mafe.id_clasificacion,
                mafe.id_centro_costo,
                af.id_depto,
                p_id_usuario,--id_usuario_reg,
                now(),
                1,--cantidad_af
                mafe.costo_orig,--#48
                maf.id_activo_fijo,
                af.id_oficina,
                mafe.id_movimiento_af_especial,
                af.codigo,
                'caf-'||p_id_movimiento::varchar, --caf: creación de activo fijo
                --Inicio #48
                mafe.id_unidad_medida,
                mafe.id_ubicacion,
                mafe.id_grupo,
                mafe.id_grupo_clasif,
                mafe.ubicacion,
                'si',
                --Fin #48
                mafe.id_movimiento_af_especial, --#57
                mafe.marca, --#61
                mafe.nro_serie --#61
                FROM kaf.tmovimiento_af_especial mafe
                INNER JOIN kaf.tmovimiento_af maf
                ON maf.id_movimiento_af = mafe.id_movimiento_af
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                INNER JOIN kaf.tactivo_fijo af
                ON af.id_activo_fijo = maf.id_activo_fijo
                WHERE maf.id_movimiento = p_id_movimiento
                AND mafe.tipo = 'af_nuevo'
                RETURNING * LOOP

        --Obtención de datos para la creación del nuevo activo fijo
        SELECT mafe.porcentaje, mafe.vida_util, mafe.fecha_ini_dep, mafe.importe,
        mafe.costo_orig, --#48
        mafe.id_movimiento_af_especial --#57
        INTO v_rec_af
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        WHERE maf.id_movimiento = p_id_movimiento
        AND mafe.id_movimiento_af_especial = v_rec.id_proyecto
        AND mafe.tipo = 'af_nuevo';

        --Creación de los AFV
        INSERT INTO kaf.tactivo_fijo_valores(
            id_usuario_reg,
            fecha_reg,
            estado_reg,
            id_activo_fijo,
            monto_vigente_orig,
            vida_util_orig,
            fecha_ini_dep,
            depreciacion_acum,
            monto_vigente,
            vida_util,
            estado,
            monto_rescate,
            tipo,
            fecha_inicio,
            id_moneda_dep,
            id_moneda,
            monto_vigente_orig_100,
            monto_vigente_actualiz_inicial,
            depreciacion_acum_inicial,
            depreciacion_per_inicial,
            mov_esp,
            id_movimiento_af_especial, --#57
            fecha_tc_ini_dep --#60
        )
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        p_id_usuario,
        now(),
        'activo',
        v_rec.id_activo_fijo,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN ROUND(v_rec_af.importe, 2) --#48
            ELSE ROUND(mdep.monto_vigente * v_rec_af.porcentaje / 100, 2) --#48
        END AS monto_vigente_orig,
        v_rec_af.vida_util - (afv.vida_util_orig - mdep.vida_util), --#48
        v_rec_af.fecha_ini_dep,
        mdep.depreciacion_acum * v_rec_af.porcentaje / 100 AS depreciacion_acum,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN ROUND(v_rec_af.importe, 2)
            ELSE ROUND(mdep.monto_vigente * v_rec_af.porcentaje / 100, 2) --#48
        END AS monto_vigente,
        v_rec_af.vida_util - (afv.vida_util_orig - mdep.vida_util), --#48
        'activo',
        v_monto_rescate_gral,
        v_cod_afv,
        DATE_TRUNC('month', v_rec_af.fecha_ini_dep) AS fecha_ini_dep, --#60
        mod.id_moneda_dep,
        mdep.id_moneda,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN ROUND(v_rec_af.costo_orig, 2) --#48
            ELSE ROUND(mdep.monto_actualiz * v_rec_af.porcentaje / 100, 2) --#48
        END AS monto_vigente_orig_100,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN ROUND(v_rec_af.importe, 2) --#48
            ELSE ROUND(mdep.monto_vigente * v_rec_af.porcentaje / 100, 2) --#48
        END AS monto_vigente_actualiz_inicial,
        0, --RCM
        0, --RCM
        'cafv-' || p_id_movimiento::varchar, --cafv creación de activo fijo valor
        v_rec_af.id_movimiento_af_especial, --#57
        DATE_TRUNC('month', v_rec_af.fecha_ini_dep) - '1 day'::INTERVAL --#60
        FROM kaf.tactivo_fijo_valores  afv
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        AND mdep.fecha = dult.fecha_max
        INNER JOIN kaf.tmoneda_dep mod
        ON mod.id_moneda = mdep.id_moneda
        WHERE afv.id_activo_fijo = v_rec.id_activo_fijo_padre;

        --Guarda el id_activo_fijo del nuevo activo fijo
        UPDATE kaf.tmovimiento_af_especial SET
        id_activo_fijo = v_rec.id_activo_fijo
        WHERE id_movimiento_af_especial = v_rec.id_proyecto;

    END LOOP;

    -----------------------------------
    --CASO 2: ACTIVOS FIJOS EXISTENTES
    -----------------------------------

    --Finalizar los AFVs vigentes de kaf.tmovimiento_af_especial para los AF existentes
    UPDATE kaf.tactivo_fijo_valores DEST SET
    fecha_fin = ORIG.fecha_mov,
    fecha_mod = now(),
    id_usuario_mod = p_id_usuario,
    mov_esp = 'mafv-'||p_id_movimiento
    FROM (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        mov.fecha_mov, mdep.id_activo_fijo_valor
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = mafe.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        WHERE maf.id_movimiento = p_id_movimiento
    ) ORIG
    WHERE DEST.id_activo_fijo_valor = ORIG.id_activo_fijo_valor;

    --Creación de los nuevos AFvs
    insert into kaf.tactivo_fijo_valores(
        id_usuario_reg,
        fecha_reg,
        estado_reg,
        id_activo_fijo,
        monto_vigente_orig,
        vida_util_orig,
        fecha_ini_dep,
        depreciacion_acum,
        monto_vigente,
        vida_util,
        estado,
        monto_rescate,
        tipo,
        fecha_inicio,
        id_moneda_dep,
        id_moneda,
        monto_vigente_orig_100,
        monto_vigente_actualiz_inicial,
        depreciacion_acum_inicial,
        depreciacion_per_inicial,
        mov_esp,
        id_movimiento_af_especial, --#57
        fecha_tc_ini_dep --#60
    )
    WITH tactivo_origen AS (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        mov.fecha_mov, mdep.id_activo_fijo_valor, mdep.monto_actualiz, mdep.depreciacion_acum,
        mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mov.id_movimiento
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        WHERE mov.id_movimiento = p_id_movimiento
    ), tactivo_destino AS (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        mdep.id_activo_fijo_valor, mafe.id_movimiento_af_especial, mafe.importe, mafe.porcentaje,
        mdep.monto_actualiz, mdep.depreciacion_acum,
        mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mafe.id_activo_fijo,
        mov.fecha_mov, mod.id_moneda_dep, mdep.vida_util, mov.id_movimiento
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_exist'
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = mafe.id_activo_fijo
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        AND mdep.fecha = dult.fecha_max
        INNER JOIN kaf.tmoneda_dep mod
        ON mod.id_moneda = mdep.id_moneda
        WHERE mov.id_movimiento = p_id_movimiento
    )
    SELECT
    p_id_usuario AS id_usuario,
    now() AS fecha_reg,
    'activo' AS estado_reg,
    tad.id_activo_fijo,
    CASE tad.id_moneda
        WHEN v_id_moneda THEN tad.monto_actualiz + tad.importe
        ELSE tad.monto_actualiz + (tao.monto_actualiz * tad.porcentaje / 100)
    END AS monto_vigente_orig,
    tad.vida_util,
    DATE_TRUNC('month', tad.fecha_mov), --#60
    tad.depreciacion_acum + (tao.depreciacion_acum * tad.porcentaje / 100)  AS depreciacion_acum,
    CASE tad.id_moneda
        WHEN v_id_moneda THEN tad.monto_actualiz + tad.importe
        ELSE tad.monto_actualiz + (tao.monto_actualiz * tad.porcentaje / 100)
    END AS monto_vigente,
    tad.vida_util,
    'activo' AS estado,
    v_monto_rescate_gral AS monto_rescate,
    v_cod_afv AS tipo,
    tad.fecha_mov,
    tad.id_moneda_dep,
    tad.id_moneda,
    CASE tad.id_moneda
        WHEN v_id_moneda THEN tad.monto_actualiz + tad.importe
        ELSE tad.monto_actualiz + (tao.monto_actualiz * tad.porcentaje / 100)
    END AS monto_vigente_orig_100,
    CASE tad.id_moneda
        WHEN v_id_moneda THEN tad.monto_actualiz + tad.importe
        ELSE tad.monto_actualiz + (tao.monto_actualiz * tad.porcentaje / 100)
    END AS monto_vigente_actualiz_inicial,
    tad.depreciacion_acum + (tao.depreciacion_acum * tad.porcentaje / 100) AS depreciacion_acum_inicial,
    tad.depreciacion_per + (tao.depreciacion_per * tad.porcentaje / 100) AS depreciacion_per_inicial,
    'cafv-' || p_id_movimiento::varchar AS mov_esp,
    tad.id_movimiento_af_especial, --#57
    DATE_TRUNC('month', tad.fecha_mov) - '1 day'::INTERVAL --#60
    FROM tactivo_origen tao
    INNER JOIN tactivo_destino tad
    ON tad.id_movimiento_af = tao.id_movimiento_af
    AND tad.id_moneda = tao.id_moneda;

    ----------------------------------------
    --3. GENERACIÓN DE COMPROBANTE CONTABLE
    ----------------------------------------
    --Inicio #39: Sólo genera comprobante cuando el siguiente estado sea: cbte
    IF v_cod_estado = 'cbte' THEN
        v_resp = kaf.f_generar_cbte_movimiento_especial(p_id_usuario, p_id_movimiento);
    END IF;
    --Fin #39

    -------------------
    --4. RESPUESTA
    -------------------
    RETURN 'hecho';

EXCEPTION

    WHEN OTHERS THEN
        v_resp = '';
        v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);
        raise exception '%', v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;