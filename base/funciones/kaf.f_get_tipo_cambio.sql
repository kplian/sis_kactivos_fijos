CREATE OR REPLACE FUNCTION kaf.f_get_tipo_cambio (
  p_id_moneda_act integer,
  p_id_moneda integer,
  p_tipo_cambio_inicial numeric,
  p_fecha_mes date,
  p_tipo_cambio_final NUMERIC, --#ETR-2170
  p_fecha_ini_dep DATE, --#ETR-2170
  out o_tc_inicial numeric,
  out o_tc_final numeric,
  out o_tc_factor numeric,
  out o_fecha_ini date,
  out o_fecha_fin date
)
RETURNS record AS
$body$
/*
Autor: RCM
Fecha: 21/09/2015
Descripción: Devuelve el tipo de cambio del primer día y del último del mes,
			de la id_moneda1 en función de la id_moneda2. También devuelve el factor (tcfin/tcini)
            y las fechas
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2170  KAF       ETR           18/12/2020  RCM         Adición de TC final como parámetro
***************************************************************************/
declare

	v_resp varchar;
    v_nombre_funcion varchar;
    v_fecha_ini date;
    v_fecha_fin date;
    v_tc_inicial numeric;
    v_tc_final numeric;
    v_factor numeric;
    v_act_baja_ufv VARCHAR; --#ETR-2170
    v_fecha_baja_ufv DATE; --#ETR-2170

begin

	--Nombre de la función
	v_nombre_funcion = 'kaf.f_get_tipo_cambio';

    --Obtención de las fechas de inicio y fin de mes
    -- RAC, 28/04/2017,  comentado para que se respete  la fecha de inicio de depreciacion
    -- v_fecha_ini = ('01/'||to_char(p_fecha_mes,'mm')||'/'||to_char(p_fecha_mes,'yyyy'))::date;

    v_fecha_ini = p_fecha_mes;
    v_fecha_fin = ('01/'||to_char(p_fecha_mes + interval '1' month,'mm')||'/'||to_char(p_fecha_mes + interval '1' month,'yyyy'))::date - interval '1' day;

    --Obtención de los tipos de cambio
    IF  p_tipo_cambio_inicial is null  THEN
       v_tc_inicial =  param.f_get_tipo_cambio_v2(p_id_moneda_act, p_id_moneda, v_fecha_ini, 'O');
    ELSE
       v_tc_inicial =  p_tipo_cambio_inicial;
    END IF;

    --Inicio #ETR-2170
    --Si se recibe el tipo de cambio final entonces devuelve ese mismo, salvo cuando la moneda act y moneda son iguales que devuelve 1
    IF p_tipo_cambio_final IS NULL  THEN
       v_tc_final = param.f_get_tipo_cambio_v2(p_id_moneda_act, p_id_moneda, v_fecha_fin, 'O');
    ELSE
        v_tc_final = p_tipo_cambio_final;
        IF p_id_moneda_act = p_id_moneda THEN
            v_tc_final = 1.00;
       END IF;
    END IF;

    --Por la Baja en la cotización de UFV ETR define que sólo se actualice hasta el 10/12/2020. Todos los activos fijos comprados después de esa fecha no debe actualizar nada.
    --Y desde enero 2021 no debe actualizarse ningún activo fijo, mientras el UFV continúe de baja
    v_act_baja_ufv = pxp.f_get_variable_global('kaf_actualizar_baja_ufv');

    IF COALESCE(TRIM(v_act_baja_ufv), '') <> '' THEN
        v_fecha_baja_ufv = v_act_baja_ufv::DATE;

        IF DATE_TRUNC('MONTH', p_fecha_mes) = DATE_TRUNC('MONTH', v_fecha_baja_ufv) THEN
            IF p_fecha_ini_dep > v_fecha_baja_ufv THEN
                --v_tc_inicial = 1.00;
                --v_tc_final = 1.00;
                --v_factor = 1.00;
                v_tc_final = v_tc_inicial;
                v_factor = v_tc_final / v_tc_inicial;
            END IF;
        ELSIF DATE_TRUNC('MONTH', p_fecha_mes) < DATE_TRUNC('MONTH', v_fecha_baja_ufv) THEN
            --Nada que hacer
        ELSE
            --v_tc_inicial = 1.00;
            --v_tc_final = 1.00;
            --v_factor = 1.00;
            v_tc_final = v_tc_inicial;
            v_factor = v_tc_final / v_tc_inicial;
        END IF;
    END IF;
    --Fin #ETR-2170

    --Cálculo del factor de actualización
    v_factor = v_tc_final / v_tc_inicial;

    --Asignación de valores
    o_fecha_ini = v_fecha_ini;
    o_fecha_fin = v_fecha_fin;
    o_tc_inicial = v_tc_inicial;
    o_tc_final = v_tc_final;
    o_tc_factor = v_factor;

    --Respuesta

exception

  when others then
      v_resp='';
      v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
      v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
      v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
      raise exception '%',v_resp;
end
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;