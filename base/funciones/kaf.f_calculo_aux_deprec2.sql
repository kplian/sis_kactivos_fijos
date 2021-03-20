CREATE OR REPLACE FUNCTION kaf.f_calculo_aux_deprec2 (
  p_fecha_ini date,
  p_fecha_fin date,
  p_vida_util integer,
  p_importe numeric,
  p_id_moneda integer,
  p_fecha_ini_ufv date, --#70
  out po_valor_actualiz numeric,
  out po_inc_actualiz numeric,
  out po_depreciacion_acum numeric,
  out po_inc_depreciacion_acum numeric,
  out po_dep_mes_total numeric --#33
)
RETURNS record AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Proyectos
 FUNCION:       kaf.f_calculo_aux_deprec2
 DESCRIPCION:   Segunda versión de la función para cálculo auxiliar de depreciación, considerano fecha de inicio UFV diferente de
                la fecha de inicio del cálculo
 AUTOR:         RCM
 FECHA:         12/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS     EMPRESA  FECHA        AUTOR       DESCRIPCION
 #AF-17     KAF     ETR      12/08/2020   RCM         Creación del archivo
 #ETR-3360  PRO     ETR      20/03/2021   RCM         No actualización de importes ni en cáluclo auxiliar de depreciación (por UFV en baja)
***************************************************************************/

DECLARE

    v_tc_ini            NUMERIC;
    v_tc_fin            NUMERIC;
    v_factor            NUMERIC;
    v_meses             INTEGER;
    i                   INTEGER;
    v_fecha_inf         DATE;
    v_fecha_sup         DATE;
    v_id_moneda         INTEGER;
    v_deprec            NUMERIC;
    v_importe           NUMERIC;
    v_id_moneda_base    INTEGER;
    v_monto_rescate     NUMERIC;
    v_vida_util         INTEGER;
    v_deprec_acum       NUMERIC = 0;
    v_inc_dep           NUMERIC;
    v_inc_val           NUMERIC;
    v_inc_val_acum      NUMERIC;
    v_inc_val_dep_acum  NUMERIC;
    v_dep_mes_total     NUMERIC = 0;--#33
    v_act_x_ufv         VARCHAR; --#ETR-3360

BEGIN

    --Obtiene ID moneda UFV
    SELECT id_moneda_act
    INTO v_id_moneda
    FROM kaf.tmoneda_dep
    WHERE id_moneda = p_id_moneda;

    --Obtención de la moneda base
    v_id_moneda_base = param.f_get_moneda_base();

    --Inicialización de variables
    --v_meses = EXTRACT(year FROM age(p_fecha_fin, p_fecha_ini))*12 + EXTRACT(month FROM age(p_fecha_fin,p_fecha_ini))::integer;
    v_meses = kaf.f_months_between2 (p_fecha_ini, p_fecha_fin);
    v_fecha_inf = p_fecha_ini;
    v_fecha_sup = date_trunc('month', v_fecha_inf + interval '1 month') - interval '1 day';
    v_importe = p_importe;
    v_vida_util = p_vida_util;
    v_tc_ini = 0;
    v_tc_fin = 0;
    v_inc_val_acum = 0;
    v_inc_val_dep_acum = 0;

    --Obtención de variable global para verificar si se actualizará o no
    v_act_x_ufv = pxp.f_get_variable_global('kaf_actualizar_baja_ufv');--#ETR-3360

    --Loop por la cantidad de meses
    FOR i IN 1..v_meses LOOP
        --Cálculo del factor de actualización
        v_tc_ini = v_tc_fin;

        IF v_tc_fin = 0 THEN
            --Si la fecha AITB está en gestión diferente a la de fecha ini, entonces toma el 01-01 de la gestión de fecha ini
            v_tc_ini = COALESCE(param.f_get_tipo_cambio(v_id_moneda, p_fecha_ini_ufv, 'O'), 1);
            IF DATE_TRUNC('YEAR', p_fecha_ini_ufv) <> DATE_TRUNC('YEAR', v_fecha_inf) THEN
                --v_tc_ini = COALESCE(param.f_get_tipo_cambio(v_id_moneda, v_fecha_inf, 'O'), 1);
                --RAISE NOTICE 'XXXXX: %, TC: %',v_fecha_inf,v_tc_ini;
            END IF;
        END IF;

        v_tc_fin = COALESCE(param.f_get_tipo_cambio(v_id_moneda, v_fecha_sup, 'O'), 1);
        v_factor = v_tc_fin / v_tc_ini;
        --Inicio #ETR-3360
        IF COALAESCE(v_act_x_ufv, '') <> '' THEN
            v_factor = 1;
        END IF;
        --Fin #ETR-3360

        --Cálculo del incremento por actualizaciones
        v_inc_val = (v_importe * v_factor) - v_importe;
        v_inc_dep = (v_deprec_acum * v_factor) - v_deprec_acum;

        --Actualización y depreciación
        v_importe = v_importe * v_factor;
        v_deprec = (v_importe - v_deprec_acum) / v_vida_util;
        v_deprec_acum = v_deprec_acum + v_deprec + v_inc_dep;

        --raise notice 'fecha_aitb: %, fecha inf: %, fecha sup: %, t/c ini: %, t/c fin: %, factor: %, importe: %, deprec: %, vida util: %, dep acum: %, inc dep: %, inc val: %',
        --p_fecha_ini_ufv, v_fecha_inf, v_fecha_sup,v_tc_ini, v_tc_fin, round(v_factor,6), round(v_importe,2), round(v_deprec,2), v_vida_util, round(v_deprec_acum,2), round(v_inc_dep,2), round(v_inc_val,2);

        --Preparacion para siguiente iteracion
        v_inc_val_acum = v_inc_val_acum + v_inc_val;
        v_inc_val_dep_acum = v_inc_val_dep_acum + v_inc_dep;
        v_vida_util = v_vida_util - 1;
        v_fecha_inf = date_trunc('month', v_fecha_inf + interval '1 month');
        v_fecha_sup = date_trunc('month', v_fecha_inf + interval '1 month') - interval '1 day';

        v_dep_mes_total = v_dep_mes_total + v_deprec; --#33

        --Si es el último mes setea la fecha exacta del parámetro recibido
        IF i = v_meses THEN
            v_fecha_sup = p_fecha_fin;
        END IF;

    END LOOP;

    po_valor_actualiz = ROUND(COALESCE(v_importe, 0), 2);
    po_depreciacion_acum = ROUND(COALESCE(v_deprec_acum, 0), 2);
    po_inc_actualiz = ROUND(COALESCE(v_inc_val_acum, 0), 2);
    po_inc_depreciacion_acum = ROUND(COALESCE(v_inc_val_dep_acum, 0), 2);
    po_dep_mes_total = ROUND(COALESCE(v_dep_mes_total, 0), 2); --#33

    RETURN;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;