CREATE OR REPLACE FUNCTION kaf.f_get_fecha_gestion_ant (
  p_fecha date
)
RETURNS date AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_get_fecha_gestion_ant
 DESCRIPCION:    Devuelve la fecha del último día de la gestión anterior a la fecha recibida
 AUTOR:          RCM
 FECHA:          16/08/2017
 COMENTARIOS:   
***************************************************************************/
DECLARE

	v_gestion integer;
    v_mes_dia varchar = '31/12/'; 

BEGIN
	--Obtención del año de la fecha recibida
	select extract(year from p_fecha) - 1 into v_gestion;
    return (v_mes_dia||v_gestion)::date;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;