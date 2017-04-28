--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_months_between (
  p_fecha_ini date,
  p_fecha_fin date
)
RETURNS integer AS
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
    
    v_age	interval;
    v_aux	integer;
    v_gestion_aux  integer;
    v_mes_aux  integer;

begin

	--Nombre de la función
	v_nombre_funcion = 'kaf.f_months_between';
    
    
    v_gestion_aux = date_part('year'::text, p_fecha_ini);
    v_mes_aux = date_part('month'::text, p_fecha_ini);                 
    v_fecha_ini = ('01/'||v_mes_aux::varchar||'/'||v_gestion_aux::varchar)::Date;
    
    v_fecha_fin =  (p_fecha_fin) + interval '1' day;
    
    v_age = age(v_fecha_ini, v_fecha_fin);
    
  
    v_aux =  extract(years from v_age)::int * 12 + extract(month from v_age)::int;
    
    return   abs(v_aux);
    
    
    
   
    
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
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 100;