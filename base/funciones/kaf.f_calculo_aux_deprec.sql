CREATE OR REPLACE FUNCTION kaf.f_calculo_aux_deprec (
  p_fecha_ini date,
  p_fecha_fin date,
  p_vida_util integer,
  p_importe numeric,
  p_id_moneda integer,
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
 FUNCION:       kaf.f_calculo_aux_deprec
 DESCRIPCION:   Calcula la depreciación con actualización de un monto, y da como respuesta el total de la depreciación
                acumulada y el incremento del activo
 AUTOR:         RCM
 FECHA:         28/09/2018
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS     EMPRESA  FECHA        AUTOR       DESCRIPCION
        KAF     ETR      09/09/2019   RCM         Creación del archivo
 #33    RCM     ETR      30/09/2019   RCM         Adición de variables de salida: depreciación mes total
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

BEGIN

    --Obtiene ID moneda UFV
    SELECT id_moneda_act
    INTO v_id_moneda
    FROM kaf.tmoneda_dep
    WHERE id_moneda = p_id_moneda;

    --Obtención de la moneda base
    v_id_moneda_base = param.f_get_moneda_base();

    --Inicialización de variables
    v_meses = EXTRACT(year FROM age(p_fecha_fin, p_fecha_ini))*12 + EXTRACT(month FROM age(p_fecha_fin,p_fecha_ini))::integer;
    v_fecha_inf = p_fecha_ini;
    v_fecha_sup = date_trunc('month', v_fecha_inf + interval '1 month') - interval '1 day';
    v_importe = p_importe;
    v_vida_util = p_vida_util;
    v_tc_ini = 0;
    v_tc_fin = 0;
    v_inc_val_acum = 0;
    v_inc_val_dep_acum = 0;

    --Loop por la cantidad de meses
    FOR i IN 1..v_meses + 1 LOOP
        --Cálculo del factor de actualización
        v_tc_ini = v_tc_fin;

        IF v_tc_fin = 0 THEN
            v_tc_ini = COALESCE(param.f_get_tipo_cambio(v_id_moneda, v_fecha_inf, 'O'), 1);
        END IF;

        v_tc_fin = COALESCE(param.f_get_tipo_cambio(v_id_moneda, v_fecha_sup, 'O'), 1);
        v_factor = v_tc_fin / v_tc_ini;

        --Cálculo del incremento por actualizaciones
        v_inc_val = (v_importe * v_factor) - v_importe;
        v_inc_dep = (v_deprec_acum * v_factor) - v_deprec_acum;

        --Actualización y depreciación
        v_importe = v_importe * v_factor;
        v_deprec = (v_importe - v_deprec_acum) / v_vida_util;
        v_deprec_acum = v_deprec_acum + v_deprec + v_inc_dep;

        --raise notice 'fecha inf: %, fecha sup: %, t/c ini: %, t/c fin: %, factor: %, importe: %, deprec: %, vida util: %, dep acum: %, inc dep: %, inc val: %',
        --v_fecha_inf, v_fecha_sup,v_tc_ini, v_tc_fin, round(v_factor,6), round(v_importe,2), round(v_deprec,2), v_vida_util, round(v_deprec_acum,2), round(v_inc_dep,2), round(v_inc_val,2);

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