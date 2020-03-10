CREATE FUNCTION kaf.f_mov_esp_verificacion_saldo_activo (
  p_id_movimiento INTEGER,
  p_id_activo_fijo INTEGER
)
RETURNS numeric AS
$body$
DECLARE

	v_rec record;
    v_result record;
    v_id_moneda integer;
    v_nombre_variable varchar;
    v_saldo numeric;

BEGIN

	v_nombre_variable = 'kaf_mov_especial_moneda';

	--Obtención de ID moneda parametrizada
    SELECT id_moneda
    INTO v_id_moneda
    FROM param.tmoneda
    WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global(v_nombre_variable));

	--Obtencion de los totales para verificacion de saldos
	WITH tdata AS (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            WHERE afv.id_activo_fijo = p_id_activo_fijo
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        afv.id_activo_fijo, SUM(mdep.monto_actualiz) as total_original
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
        GROUP BY afv.id_activo_fijo_valor
    ), tmovesp AS (
        SELECT
        maf.id_activo_fijo, SUM(mesp.costo_orig) as total
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento_af_especial mesp
        ON mesp.id_movimiento_af = maf.id_movimiento_af
        WHERE maf.id_movimiento = p_id_movimiento
        AND maf.id_activo_fijo = p_id_activo_fijo
        GROUP BY maf.id_activo_fijo
    )
    SELECT
    t.id_activo_fijo, COALESCE(t.total_original, 0) AS total_original, COALESCE(tm.total, 0) AS total
    INTO v_result
    FROM tdata t
    INNER JOIN tmovesp tm
    ON tm.id_activo_fijo = t.id_activo_fijo;

    --Verificacion de saldo
    v_saldo = v_result.total_original - v_result.total;

    RETURN v_saldo;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;