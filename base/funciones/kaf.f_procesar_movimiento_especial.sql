CREATE OR REPLACE FUNCTION kaf.f_procesar_movimiento_especial (
	p_id_usuario integer,
	p_id_movimiento integer
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
***************************************************************************
*/
DECLARE

	v_nombre_funcion		varchar;
    v_resp					varchar;
    v_id_moneda             integer;
    v_rec                   record;
    v_rec_af                record;
    v_monto_act             numeric;
    v_dep_acum              numeric;
    v_dep_per               numeric;
    v_monto_rescate_gral    numeric;
    v_cod_afv               varchar;

BEGIN

	--Nombre de la función
    v_nombre_funcion = 'kaf.f_procesar_movimiento_especial';
    v_monto_rescate_gral = 1;
    v_cod_afv = 'dval';

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
    --Finalización AFV de activos fijos originales kaf.tmovimiento_af en todas las monedas
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

    ---------------------------------------------------------
    --Creación de nuevos AFVs de los activos fijos originales
    ---------------------------------------------------------
    /*insert into kaf.tactivo_fijo_valores(
        id_usuario_reg,
        fecha_reg,
        estado_reg,
        id_activo_fijo,
        monto_vigente_orig,
        vida_util_orig,
        fecha_ini_dep,
        depreciacion_per,
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
        depreciacion_per_inicial
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
    maf.id_activo_fijo,
    CASE mdep.id_moneda
        WHEN v_id_moneda THEN mdep.monto_actualiz - mafe.importe
        ELSE mdep.monto_actualiz - (mdep.monto_actualiz * mafe.porcentaje / 100)
    END AS monto_vigente_orig,
    mdep.vida_util,
    mov.fecha_mov,
    mdep.depreciacion_per - (mdep.depreciacion_per * mafe.porcentaje / 100),
    mdep.depreciacion_acum - (mdep.depreciacion_acum * mafe.porcentaje / 100),
    CASE mdep.id_moneda
        WHEN v_id_moneda THEN mdep.monto_actualiz - mafe.importe
        ELSE mdep.monto_actualiz - (mdep.monto_actualiz * mafe.porcentaje / 100)
    END AS monto_vigente,
    mdep.vida_util,
    'activo',
    0.45,
    'dval',
    mov.fecha_mov,
    mod.id_moneda_dep,
    mdep.id_moneda,
    CASE mdep.id_moneda
        WHEN v_id_moneda THEN mdep.monto_actualiz - mafe.importe
        ELSE mdep.monto_actualiz - (mdep.monto_actualiz * mafe.porcentaje / 100)
    END AS monto_vigente_orig_100,
    CASE mdep.id_moneda
        WHEN v_id_moneda THEN mdep.monto_actualiz - mafe.importe
        ELSE mdep.monto_actualiz - (mdep.monto_actualiz * mafe.porcentaje / 100)
    END AS monto_vigente_actualiz_inicial,
    mdep.depreciacion_acum - (mdep.depreciacion_acum * mafe.porcentaje / 100),
    mdep.depreciacion_per - (mdep.depreciacion_per * mafe.porcentaje / 100)
    FROM kaf.tmovimiento mov
    INNER JOIN kaf.tmovimiento_af maf
    ON maf.id_movimiento = mov.id_movimiento
    INNER JOIN kaf.tmovimiento_af_especial mafe
    ON mafe.id_movimiento_af = maf.id_movimiento_af
    INNER JOIN kaf.tactivo_fijo_valores afv
    ON afv.id_activo_fijo = maf.id_activo_fijo
    INNER JOIN tult_dep dult
    ON dult.id_activo_fijo = afv.id_activo_fijo
    INNER JOIN kaf.tmovimiento_af_dep mdep
    ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
    AND mdep.fecha = dult.fecha_max
    INNER JOIN kaf.tmoneda_dep mod
    ON mod.id_moneda = mdep.id_moneda
    WHERE mov.id_movimiento = p_id_movimiento;*/
    FOR v_rec IN
    (
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
        mdep.id_moneda, mdep.monto_actualiz, mdep.depreciacion_acum, mdep.depreciacion_per,
        afv.id_activo_fijo, afv.id_activo_fijo_valor,
        mdep.vida_util, mov.fecha_mov, mod.id_moneda_dep
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
        WHERE maf.id_movimiento = p_id_movimiento
    ) LOOP

        --Obtener el total del detalle en cada moneda
        SELECT
        SUM(mafe.importe) as total_importe,
        SUM(mafe.porcentaje) as total_porcentaje
        INTO v_rec_af
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        WHERE maf.id_movimiento = p_id_movimiento
        AND maf.id_activo_fijo = v_rec.id_activo_fijo
        GROUP BY maf.id_movimiento, maf.id_activo_fijo, mafe.id_moneda;

        --Obtiene los valores nuevos, restando del total registrado en el detalle
        v_monto_act = v_rec.monto_actualiz - (v_rec.monto_actualiz * v_rec_af.total_porcentaje / 100);
        v_dep_acum = v_rec.depreciacion_acum - (v_rec.depreciacion_acum * v_rec_af.total_porcentaje / 100);
        v_dep_per = v_rec.depreciacion_per - (v_rec.depreciacion_per * v_rec_af.total_porcentaje / 100);

        --Inserción del activo fijo valor
        insert into kaf.tactivo_fijo_valores(
        id_usuario_reg          , fecha_reg             , estado_reg                        , id_activo_fijo,
        monto_vigente_orig      , vida_util_orig        , fecha_ini_dep                     , depreciacion_per,
        depreciacion_acum       , monto_vigente         , vida_util                         , estado,
        monto_rescate           , tipo                  , fecha_inicio                      , id_moneda_dep,
        id_moneda               , monto_vigente_orig_100, monto_vigente_actualiz_inicial    , depreciacion_acum_inicial,
        depreciacion_per_inicial, mov_esp
        )
        VALUES(
        p_id_usuario    , now()                                 , 'activo'          , v_rec.id_activo_fijo,
        v_monto_act     , v_rec.vida_util                       , v_rec.fecha_mov   , v_dep_per,
        v_dep_acum      , v_monto_act                           , v_rec.vida_util   , 'activo',
        1               , v_cod_afv                             , v_rec.fecha_mov   , v_rec.id_moneda_dep,
        v_rec.id_moneda , v_monto_act                           , v_monto_act       , v_dep_acum,
        v_dep_per       , 'cafv-'||p_id_movimiento::varchar --cafv: creación activo fijo valor
        );

    END LOOP;

    -------------------------------
    --CASO 1: ACTIVOS FIJOS NUEVOS
    -------------------------------
    FOR v_rec IN INSERT INTO kaf.tactivo_fijo(
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
                    bk_codigo
                )
                SELECT
                'activo',
                mov.fecha_mov,
                af.id_cat_estado_fun,
                af.id_cat_estado_compra,
                'Creado desde Distribución de Valores',
                af.monto_rescate,
                mafe.denominacion,
                af.id_funcionario,
                af.id_deposito,
                mafe.importe,--monto_compra_orig,
                mafe.importe,
                param.f_get_moneda_base(),
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
                mafe.importe,--monto_compra_orig_100,
                maf.id_activo_fijo,
                af.id_oficina,
                mafe.id_movimiento_af_especial,
                af.codigo,
                'caf-'||p_id_movimiento::varchar --caf: creación de activo fijo
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
        SELECT mafe.porcentaje, mafe.vida_util, mafe.fecha_ini_dep, mafe.importe
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
            mov_esp
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
            WHEN v_id_moneda THEN v_rec_af.importe
            ELSE mdep.monto_actualiz * v_rec_af.porcentaje / 100
        END AS monto_vigente_orig,
        v_rec_af.vida_util,
        v_rec_af.fecha_ini_dep,
        mdep.depreciacion_acum * v_rec_af.porcentaje / 100 AS depreciacion_acum,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN v_rec_af.importe
            ELSE mdep.monto_actualiz * v_rec_af.porcentaje / 100
        END AS monto_vigente,
        v_rec_af.vida_util,
        'activo',
        v_monto_rescate_gral,
        v_cod_afv,
        v_rec_af.fecha_ini_dep,
        mod.id_moneda_dep,
        mdep.id_moneda,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN v_rec_af.importe
            ELSE mdep.monto_actualiz * v_rec_af.porcentaje / 100
        END AS monto_vigente_orig_100,
        CASE mdep.id_moneda
            WHEN v_id_moneda THEN v_rec_af.importe
            ELSE mdep.monto_actualiz * v_rec_af.porcentaje / 100
        END AS monto_vigente_actualiz_inicial,
        mdep.depreciacion_acum * v_rec_af.porcentaje / 100,
        mdep.depreciacion_per * v_rec_af.porcentaje / 100,
        'cafv-' || p_id_movimiento::varchar --cafv creación de activo fijo valor
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
        mov_esp
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
    tad.fecha_mov,
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
    'cafv-' || p_id_movimiento::varchar AS mov_esp
    FROM tactivo_origen tao
    INNER JOIN tactivo_destino tad
    ON tad.id_movimiento_af = tao.id_movimiento_af
    AND tad.id_moneda = tao.id_moneda;

    -------------------------------------
    --3. GENERACIÓN DE COMPROBANTE CONTABLE
    -------------------------------------
    v_resp = kaf.f_generar_cbte_movimiento_especial(p_id_usuario, p_id_movimiento);

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