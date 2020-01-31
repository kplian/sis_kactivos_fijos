CREATE OR REPLACE FUNCTION kaf.f_depreciacion_lineal_af (
    p_fecha date,
    p_monto_actualiz_inicial numeric,
    p_id_moneda integer,
    p_vida_util numeric,
    p_fecha_act_ini date,
    p_fecha_act_fin date,
    p_importe_rescate numeric,
    p_tipo_cambio_inicial numeric,
    p_deprec_acum_inicial numeric = 0,
    p_deprec_per_inicial numeric = 0,
    p_deprecia varchar = 'si'::character varying,
    out po_fecha date,
    out po_tc_ini numeric,
    out po_tc_fin numeric,
    out po_factor numeric,
    out po_monto_actualiz_inicial numeric,
    out po_inc_monto_actualiz_inicial numeric,
    out po_monto_actualiz numeric,
    out po_vida_util_ant numeric,
    out po_deprec_acum_inicial numeric,
    out po_inc_deprec_acum_inicial numeric,
    out po_deprec_acum_inicial_actualiz numeric,
    out po_depreciacion numeric,
    out po_depreciacion_per numeric,
    out po_depreciacion_acum numeric,
    out po_valor_neto numeric
)
RETURNS record AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_depreciacion_lineal_af
 DESCRIPCION:   Función que deprecia un registro con el método de depreciación lineal. Parte de la refactorización del proceso de depreciación
 AUTOR:         RCM
 FECHA:         15/01/2020
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #44    KAF       ETR           15/01/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

    v_resp                          VARCHAR;
    v_nombre_funcion                TEXT;
    v_factor_act 					NUMERIC;
    v_id_moneda_act 				INTEGER;
    v_id_moneda_dep 				INTEGER;
    v_actualizar 					VARCHAR;
    v_rec_tc 						RECORD;
    v_tc_ini						NUMERIC;
    v_tc_fin						NUMERIC;
    v_monto_actualiz                NUMERIC;
    v_deprec_acum_inicial_actualiz  NUMERIC;
    v_deprec_per_inicial_actualiz 	NUMERIC;
    v_deprec 						NUMERIC;
    v_deprec_per 					NUMERIC;
    v_deprec_acum 					NUMERIC;
    v_valor_neto 					NUMERIC;

BEGIN

    v_nombre_funcion = 'kaf.f_depreciacion_lineal_af';

	-------------------
	-- A Actualización
    -------------------
    --1 Verificación si la moneda requiere de actualización
    SELECT
    id_moneda_dep, id_moneda_act, actualizar
    INTO
    v_id_moneda_dep, v_id_moneda_act, v_actualizar
    FROM kaf.tmoneda_dep
    WHERE id_moneda = p_id_moneda;

    --2 Obtención del factor de actualización
    v_factor_act = 1;

    IF v_actualizar = 'si' THEN
        --Obtención de los tipos de cambio
        v_tc_ini = p_tipo_cambio_inicial;

        IF p_tipo_cambio_inicial IS NULL  THEN
           v_tc_ini = param.f_get_tipo_cambio_v2(v_id_moneda_act, p_id_moneda, p_fecha_act_ini, 'O');
        END IF;

        v_tc_fin =  param.f_get_tipo_cambio_v2(v_id_moneda_act, p_id_moneda, p_fecha_act_fin, 'O');

        --Cálculo del factor de actualización
        v_factor_act = v_tc_fin / v_tc_ini;
    END IF;

    --3 Actualización de los importes
	v_monto_actualiz = p_monto_actualiz_inicial * v_factor_act;
    v_deprec_acum_inicial_actualiz = p_deprec_acum_inicial * v_factor_act;
    v_deprec_per_inicial_actualiz = p_deprec_per_inicial * v_factor_act;

    ------------------
    -- B Depreciación
    ------------------
    IF p_deprecia = 'si' THEN
        --Cálculo depreciación del mes
        v_deprec = 0;
        IF p_vida_util > 0 THEN
            v_deprec = (v_monto_actualiz - v_deprec_acum_inicial_actualiz - p_importe_rescate) / p_vida_util;
        END IF;

        --Depreciación del periodo, si es del mes de enero empieza desde cero
        v_deprec_per = v_deprec_per_inicial_actualiz + v_deprec;

        IF date_part('month', p_fecha) = 1 THEN
        	v_deprec_per = v_deprec;
        END IF;

        --Depreciación acumulada
    	v_deprec_acum = v_deprec_acum_inicial_actualiz + v_deprec;
    END IF;

    --Valor neto
    v_valor_neto = v_monto_actualiz - COALESCE(v_deprec_acum, 0);

    ------------
    -- C SALIDA
    ------------
    po_fecha = p_fecha;
    po_tc_ini = v_tc_ini;
    po_tc_fin = v_tc_fin;
    po_factor = v_factor_act;
    po_monto_actualiz_inicial = p_monto_actualiz_inicial;
    po_inc_monto_actualiz_inicial = v_monto_actualiz - p_monto_actualiz_inicial;
    po_monto_actualiz = v_monto_actualiz;
    po_vida_util_ant = p_vida_util;
    po_deprec_acum_inicial = p_deprec_acum_inicial;
    po_inc_deprec_acum_inicial = v_deprec_acum_inicial_actualiz - p_deprec_acum_inicial;
    po_deprec_acum_inicial_actualiz = v_deprec_acum_inicial_actualiz;
    po_depreciacion = v_deprec;
    po_depreciacion_per = v_deprec_per;
    po_depreciacion_acum = v_deprec_acum;
    po_valor_neto = v_valor_neto;

    RETURN;

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