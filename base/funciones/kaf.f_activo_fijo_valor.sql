CREATE OR REPLACE FUNCTION kaf.f_activo_fijo_valor (
  p_fecha date = now()::date,
  p_solo_finalizados varchar = 'si'::character varying
)
RETURNS SETOF kaf.vactivo_fijo_valor_estado AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_activo_fijo_valor
 DESCRIPCION:   Recupera el valor real de los activo_fijo_valor, pudiendo ser sólo con movimientos finalizados o no
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
    v_rec record;
    v_result kaf.vactivo_fijo_valor_estado;
BEGIN

    
    
        for v_rec in select 
                        afv.id_usuario_reg,
                        afv.id_usuario_mod,
                        afv.fecha_reg,
                        afv.fecha_mod,
                        afv.estado_reg,
                        afv.id_usuario_ai,
                        afv.usuario_ai,
                        afv.id_activo_fijo_valor,
                        afv.id_activo_fijo,
                        afv.monto_vigente_orig,
                        afv.vida_util_orig,
                        afv.fecha_ini_dep,
                        afv.depreciacion_mes,
                        afv.depreciacion_per,
                        afv.depreciacion_acum,
                        afv.monto_vigente,
                        afv.vida_util,
                        afv.fecha_ult_dep,
                        afv.tipo_cambio_ini,
                        afv.tipo_cambio_fin,
                        afv.tipo,
                        afv.estado,
                        afv.principal,
                        afv.monto_rescate,
                        afv.id_movimiento_af,
                        afv.codigo,
                        afv.id_moneda_dep,
                        afv.id_moneda,
                        afv.fecha_inicio,
                        afv.fecha_fin,
                        afv.deducible,
                        afv.id_activo_fijo_valor_original,
                        mov.estado as estado_mov,
                        min.monto_vigente as min_monto_vigente,
                        min.vida_util as min_vida_util,
                        min.fecha as min_fecha,
                        min.depreciacion_acum as min_depreciacion_acum,
                        min.depreciacion_per as min_depreciacion_per,
                        min.depreciacion_acum_ant as min_depreciacion_acum_ant,
                        min.monto_actualiz as min_monto_actualiz,
                        min.tipo_cambio_fin as min_tipo_cambio_fin,
                        min.estado as min_estado_dep
                        from kaf.tactivo_fijo_valores afv
                        inner join kaf.tmovimiento_af maf 
                        on maf.id_movimiento_af = afv.id_movimiento_af
                        inner join kaf.tmovimiento mov
                        on mov.id_movimiento = maf.id_movimiento
                        left join kaf.f_activo_fijo_dep_x_fecha(p_fecha,p_solo_finalizados) min --kaf.vminimo_movimiento_af_dep_estado min
                        on min.id_activo_fijo_valor = afv.id_activo_fijo_valor
                        where (afv.fecha_fin is null or afv.fecha_fin > p_fecha)
                        and afv.fecha_inicio <= p_fecha loop
                        
            --Inicialización de variables
            v_result.id_usuario_reg = v_rec.id_usuario_reg;
            v_result.id_usuario_mod = v_rec.id_usuario_mod;
            v_result.fecha_reg = v_rec.fecha_reg;
            v_result.fecha_mod = v_rec.fecha_mod;
            v_result.estado_reg = v_rec.estado_reg;
            v_result.id_usuario_ai = v_rec.id_usuario_ai;
            v_result.usuario_ai = v_rec.usuario_ai;
            v_result.id_activo_fijo_valor = v_rec.id_activo_fijo_valor;
            v_result.id_activo_fijo = v_rec.id_activo_fijo;
            v_result.monto_vigente_orig = v_rec.monto_vigente_orig;
            v_result.vida_util_orig = v_rec.vida_util_orig;
            v_result.fecha_ini_dep = v_rec.fecha_ini_dep;
            v_result.depreciacion_mes = v_rec.depreciacion_mes;
            v_result.depreciacion_per = v_rec.depreciacion_per;
            v_result.depreciacion_acum = v_rec.depreciacion_acum;
            v_result.monto_vigente = v_rec.monto_vigente;
            v_result.vida_util = v_rec.vida_util;
            v_result.fecha_ult_dep = v_rec.fecha_ult_dep;
            v_result.tipo_cambio_ini = v_rec.tipo_cambio_ini;
            v_result.tipo_cambio_fin = v_rec.tipo_cambio_fin;
            v_result.tipo = v_rec.tipo;
            v_result.estado = v_rec.estado;
            v_result.principal = v_rec.principal;
            v_result.monto_rescate = v_rec.monto_rescate;
            v_result.id_movimiento_af = v_rec.id_movimiento_af;
            v_result.codigo = v_rec.codigo;
            v_result.id_moneda = v_rec.id_moneda;
            v_result.id_moneda_dep = v_rec.id_moneda_dep;
            v_result.estado_mov_dep = v_rec.min_estado_dep;
            v_result.estado_mov = v_rec.estado_mov;
            
            v_result.monto_vigente_real = 0;
            v_result.vida_util_real = 0;
            v_result.fecha_ult_dep_real = NULL;
            v_result.depreciacion_acum_real = 0;
            v_result.depreciacion_per_real = 0;
            v_result.depreciacion_acum_ant_real = 0;
            v_result.monto_actualiz_real = 0;
            v_result.tipo_cambio_anterior = 0;
            
            if p_solo_finalizados = 'si' then
                if v_rec.min_estado_dep = 'finalizado' then
                    v_result.monto_vigente_real = v_rec.min_monto_vigente;
                    v_result.vida_util_real = v_rec.min_vida_util;
                    v_result.fecha_ult_dep_real = v_rec.min_fecha;
                    v_result.depreciacion_acum_real = COALESCE(v_rec.min_depreciacion_acum, 0::numeric);
                    v_result.depreciacion_per_real = COALESCE(v_rec.min_depreciacion_per, 0::numeric);
                    v_result.depreciacion_acum_ant_real = COALESCE(v_rec.min_depreciacion_acum_ant, 0::numeric);
                    v_result.monto_actualiz_real = v_rec.min_monto_actualiz;
                    v_result.tipo_cambio_anterior = COALESCE(v_rec.min_tipo_cambio_fin, NULL::numeric);
                elsif v_rec.estado_mov = 'finalizado' then
                    v_result.monto_vigente_real = v_rec.monto_vigente_orig;
                    v_result.vida_util_real = COALESCE(v_rec.min_vida_util, v_rec.vida_util_orig);
                    v_result.fecha_ult_dep_real = v_rec.fecha_ini_dep;
                    v_result.depreciacion_acum_real = COALESCE(v_rec.min_depreciacion_acum, 0::numeric);
                    v_result.depreciacion_per_real = COALESCE(v_rec.min_depreciacion_per, 0::numeric);
                    v_result.depreciacion_acum_ant_real = COALESCE(v_rec.min_depreciacion_acum_ant, 0::numeric);
                    v_result.monto_actualiz_real = v_rec.monto_vigente_orig;
                    v_result.tipo_cambio_anterior = COALESCE(v_rec.min_tipo_cambio_fin, NULL::numeric);
                end if;
            else
                v_result.monto_vigente_real = COALESCE(v_rec.min_monto_vigente, v_rec.monto_vigente_orig);
                v_result.vida_util_real = COALESCE(v_rec.min_vida_util, v_rec.vida_util_orig);
                v_result.fecha_ult_dep_real = COALESCE(v_rec.min_fecha, v_rec.fecha_ini_dep);
                v_result.depreciacion_acum_real = COALESCE(v_rec.min_depreciacion_acum, 0::numeric);
                v_result.depreciacion_per_real = COALESCE(v_rec.min_depreciacion_per, 0::numeric);
                v_result.depreciacion_acum_ant_real = COALESCE(v_rec.min_depreciacion_acum_ant, 0::numeric);
                v_result.monto_actualiz_real = COALESCE(v_rec.min_monto_actualiz, v_rec.monto_vigente_orig);
                v_result.tipo_cambio_anterior = COALESCE(v_rec.min_tipo_cambio_fin, NULL::numeric);
            end if;

            return next v_result;
        
        end loop;

    
    
    return ;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100 ROWS 1000;