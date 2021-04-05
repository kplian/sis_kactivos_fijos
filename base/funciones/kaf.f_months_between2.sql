CREATE OR REPLACE FUNCTION kaf.f_months_between2 (t_start timestamp, t_end timestamp)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_months_between2
 DESCRIPCION:   Calcula la diferencia de meses entre dos fechas
 AUTOR:         RCM
 FECHA:         14/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE  	SIS     EMPRESA  FECHA        AUTOR       DESCRIPCION
 #AF-10 	KAF     ETR      14/08/2020   RCM         Creación del archivo
 #ETR-3360 	KAF     ETR      01/04/2021   RCM         Modificacion de logica
***************************************************************************/

DECLARE
	v_dias integer;
BEGIN
    /*SELECT
        (
            12 * extract('years' from a.i) + extract('months' from a.i)
        )::integer
    from (
        values (justify_interval($2 - $1))
    ) as a (i)*/
   v_dias = (((extract( year FROM t_end ) - extract( year FROM t_start )) *12) + extract(MONTH FROM t_end ) - extract(MONTH FROM t_start ))::integer;
  
   RETURN v_dias + 1;
END;
$function$
;