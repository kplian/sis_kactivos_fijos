CREATE OR REPLACE FUNCTION kaf.f_activo_fijo_dep_x_fecha (
  p_fecha date = now()::date,
  p_solo_finalizados varchar = 'si'::character varying
)
RETURNS TABLE (
  id_activo_fijo_valor integer,
  monto_vigente numeric,
  vida_util integer,
  fecha date,
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
  id_moneda integer,
  id_moneda_dep integer,
  tipo_cambio_fin numeric,
  tipo_cambio_ini numeric,
  estado varchar
) AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_activo_fijo_dep_x_fecha
 DESCRIPCION:   Valores del activo fijo depreciado a una fecha, pudiendo considerar sólo depreciaciones finalizadas o no
 AUTOR:         (RCM)
 FECHA:         12/06/2017
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/

DECLARE

BEGIN

    if p_solo_finalizados = 'si' then

        return query 
        select distinct on (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
        afd.monto_vigente,
        afd.vida_util,
        afd.fecha,
        afd.depreciacion_acum_ant,
        afd.depreciacion_per_ant,
        afd.monto_vigente_ant,
        afd.vida_util_ant,
        
        afd.depreciacion_acum_actualiz,
        afd.depreciacion_per_actualiz,
        afd.monto_actualiz,
        
        afd.depreciacion,
        afd.depreciacion_acum,
        afd.depreciacion_per,
        
        
        afd.id_moneda,
        afd.id_moneda_dep,
        afd.tipo_cambio_fin,
        afd.tipo_cambio_ini,
        mov.estado
        from kaf.tmovimiento_af_dep afd
        inner join kaf.tmovimiento_af maf
        on maf.id_movimiento_af = afd.id_movimiento_af
        inner join kaf.tmovimiento mov
        on mov.id_movimiento = maf.id_movimiento
        where afd.fecha <= p_fecha
        and mov.estado = 'finalizado'
        order by afd.id_activo_fijo_valor, afd.fecha desc;

    else
    
        return query 
        select distinct on (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
        afd.monto_vigente,
        afd.vida_util,
        afd.fecha,
        afd.depreciacion_acum_ant,
        afd.depreciacion_per_ant,
        afd.monto_vigente_ant,
        afd.vida_util_ant,
        
        afd.depreciacion_acum_actualiz,
        afd.depreciacion_per_actualiz,
        afd.monto_actualiz,
        
        afd.depreciacion,
        afd.depreciacion_acum,
        afd.depreciacion_per,
        
        
        afd.id_moneda,
        afd.id_moneda_dep,
        afd.tipo_cambio_fin,
        afd.tipo_cambio_ini,
        mov.estado
        from kaf.tmovimiento_af_dep afd
        inner join kaf.tmovimiento_af maf
        on maf.id_movimiento_af = afd.id_movimiento_af
        inner join kaf.tmovimiento mov
        on mov.id_movimiento = maf.id_movimiento
        where afd.fecha <= p_fecha
        order by afd.id_activo_fijo_valor, afd.fecha desc;
    
    end if;




END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;