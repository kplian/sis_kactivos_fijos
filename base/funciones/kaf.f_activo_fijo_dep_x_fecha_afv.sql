CREATE OR REPLACE FUNCTION kaf.f_activo_fijo_dep_x_fecha_afv (
  p_fecha date = now()::date,
  p_solo_finalizados varchar = 'si'::character varying
)
RETURNS TABLE (
  id_activo_fijo_valor integer,
  id_activo_fijo integer,
  id_movimiento_af integer,
  id_moneda_dep integer,
  id_moneda integer,
  codigo varchar,
  tipo varchar,
  deducible varchar,
  fecha_ini_dep date,
  fecha_inicio date,
  fecha_fin date,
  fecha_ult_dep date,
  monto_rescate numeric,
  monto_vigente_orig numeric,
  vida_util_orig integer,
  depreciacion_acum_ant numeric,
  depreciacion_per_ant numeric,
  monto_vigente_ant numeric,
  vida_util_ant integer,
  depreciacion_acum_actualiz numeric,
  depreciacion_per_actualiz numeric,
  monto_actualiz numeric,
  depreciacion numeric,
  depreciacion_acum numeric,
  depreciacion_per numeric,
  monto_vigente numeric,
  vida_util integer,
  monto_vigente_orig_100 numeric
) AS
$body$
/**************************************************************************
 SISTEMA:   Sistema de Activos Fijos
 FUNCION:     kaf.f_activo_fijo_dep_x_fecha_afv
 DESCRIPCION:   Recupera el valor real (con las depreciaciones) haciendo join con activo fijo valor
 AUTOR:     (RCM)
 FECHA:         14/08/2017
 COMENTARIOS: 
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION: 
 AUTOR:     
 FECHA:   
***************************************************************************/

DECLARE

BEGIN

  return query
    select
    afv.id_activo_fijo_valor,
    afv.id_activo_fijo,
    afv.id_movimiento_af,
    afv.id_moneda_dep,
    afv.id_moneda,
    afv.codigo,
    afv.tipo,
    afv.deducible,
    afv.fecha_ini_dep,
    afv.fecha_inicio,
    afv.fecha_fin,
    afv.fecha_ult_dep,
    afv.monto_rescate,
    afv.monto_vigente_orig,
    afv.vida_util_orig,
    coalesce(adep.depreciacion_acum_ant,0) as depreciacion_acum_ant,
    coalesce(adep.depreciacion_per_ant,0) as depreciacion_per_ant,
    coalesce(adep.monto_vigente_ant,afv.monto_vigente_orig) as monto_vigente_ant,
    coalesce(adep.vida_util_ant,afv.vida_util_orig) as vida_util_ant,
    coalesce(adep.depreciacion_acum_actualiz,0) as depreciacion_acum_actualiz,
    coalesce(adep.depreciacion_per_actualiz,0) as depreciacion_per_actualiz,
    coalesce(adep.monto_actualiz,afv.monto_vigente_orig) as monto_actualiz,
    coalesce(adep.depreciacion,0) as depreciacion,
    coalesce(adep.depreciacion_acum,0) as depreciacion_acum,
    coalesce(adep.depreciacion_per,0) as depreciacion_per,
    coalesce(adep.monto_vigente,afv.monto_vigente_orig) as monto_vigente,
    coalesce(adep.vida_util,afv.vida_util_orig) as vida_util,
    afv.monto_vigente_orig_100
    from kaf.tactivo_fijo_valores afv
    left join kaf.f_activo_fijo_dep_x_fecha(p_fecha,p_solo_finalizados) adep
    on adep.id_activo_fijo_valor = afv.id_activo_fijo_valor
  where (afv.fecha_fin is null or afv.fecha_fin > p_fecha)
  and afv.fecha_inicio <= p_fecha;


END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;