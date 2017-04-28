--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_get_tipo_cambio (
  p_id_moneda_act integer,
  p_id_moneda integer,
  p_tipo_cambio_inicial numeric,
  p_fecha_mes date,
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
*/
declare

	v_resp varchar;
    v_nombre_funcion varchar;
    v_fecha_ini date;
    v_fecha_fin date;
    v_tc_inicial numeric;
    v_tc_final numeric;
    v_factor numeric;

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
    
    
    
    v_tc_final =  param.f_get_tipo_cambio_v2(p_id_moneda_act, p_id_moneda, v_fecha_fin, 'O');
    
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