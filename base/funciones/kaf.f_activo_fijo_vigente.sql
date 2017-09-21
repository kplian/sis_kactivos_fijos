CREATE OR REPLACE FUNCTION kaf.f_activo_fijo_vigente (
  p_fecha date = now()::date,
  p_solo_finalizados varchar = 'si'::character varying
)
RETURNS SETOF kaf.vactivo_fijo_vigente AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_activo_fijo_vigente
 DESCRIPCION:   Recupera el valor consolidado de los activos fijos, pudiendo considerar sólo movimientos finalizados o no
 AUTOR: 		(RCM)
 FECHA:	        12/06/2017
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/
DECLARE
	v_result  kaf.vactivo_fijo_vigente;
BEGIN

	for v_result in SELECT afd.id_activo_fijo,
                           sum(afd.monto_vigente_real) AS monto_vigente_real_af,
                           max(afd.vida_util_real) AS vida_util_real_af,
                           max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
                           sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
                           sum(afd.depreciacion_per_real) AS depreciacion_per_real_af,
                           afd.id_moneda,
                           afd.id_moneda_dep
                    FROM kaf.f_activo_fijo_valor(p_fecha,p_solo_finalizados) afd
                    GROUP BY afd.id_activo_fijo,
                             afd.id_moneda,
                             afd.id_moneda_dep loop
           
  		return next v_result;
  	end loop;
    
    return;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;