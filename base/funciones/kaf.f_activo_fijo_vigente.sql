CREATE OR REPLACE FUNCTION kaf.f_activo_fijo_vigente (
  p_fecha date = now()::date,
  p_solo_finalizados varchar = 'si'::character varying
)
RETURNS SETOF record AS
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
	v_result  record;
BEGIN

	for v_result in (WITH activo_fijo_valor as (
                        select * from kaf.f_activo_fijo_valor(p_fecha,p_solo_finalizados) AS(
                            id_usuario_reg integer,
                            id_usuario_mod integer,
                            fecha_reg date,
                            fecha_mod date,
                            estado_reg varchar,
                            id_usuario_ai integer,
                            usuario_ai varchar,
                            id_activo_fijo_valor integer,
                            id_activo_fijo integer,
                            monto_vigente_orig numeric,
                            vida_util_orig integer,
                            fecha_ini_dep date,
                            depreciacion_mes numeric,
                            depreciacion_per numeric ,
                            depreciacion_acum numeric,
                            monto_vigente numeric,
                            vida_util integer,
                            fecha_ult_dep date,
                            tipo_cambio_ini numeric,
                            tipo_cambio_fin numeric,
                            tipo varchar,
                            estado varchar,
                            principal varchar,
                            monto_rescate numeric,
                            id_movimiento_af integer,
                            codigo varchar,
                            monto_vigente_real numeric,
                            vida_util_real integer,
                            fecha_ult_dep_real date,
                            depreciacion_acum_real numeric,
                            depreciacion_per_real numeric,
                            depreciacion_acum_ant_real numeric,
                            monto_actualiz_real numeric,
                            id_moneda integer,
                            id_moneda_dep integer,
                            tipo_cambio_anterior numeric,
                            estado_mov_dep varchar,
                            estado_mov varchar)
                    )
                    SELECT afd.id_activo_fijo,
                           sum(afd.monto_vigente_real) AS monto_vigente_real_af,
                           max(afd.vida_util_real) AS vida_util_real_af,
                           max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
                           sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
                           sum(afd.depreciacion_per_real) AS depreciacion_per_real_af,
                           afd.id_moneda,
                           afd.id_moneda_dep
                    FROM activo_fijo_valor afd
                    GROUP BY afd.id_activo_fijo,
                             afd.id_moneda,
                             afd.id_moneda_dep) loop

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