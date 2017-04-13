--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_depreciacion_lineal (
  p_id_usuario integer,
  p_id_activo_fijo integer,
  p_hasta date,
  p_id_movimiento_af integer,
  p_depreciar varchar = 'SI'::character varying
)
RETURNS varchar AS
$body$
/*
Autor: RCM
Fecha: 11/09/2015
Descripción: Depreciación lineal de activos fijos
*/
DECLARE

    v_resp                  varchar;
    v_nombre_funcion        varchar;
    v_meses_dep             integer;
    v_id_moneda             integer;
    v_rec_ant               record;
    v_rec_tc                record;
    v_dep_acum_actualiz     numeric;
    v_dep_per_actualiz      numeric;
    v_monto_actualiz        numeric;
    v_ant_dep_acum          numeric;
    v_ant_dep_per           numeric;
    v_ant_monto_vigente     numeric;
    v_ant_vida_util         integer;
    v_nuevo_dep_mes         numeric;
    v_nuevo_dep_acum        numeric;
    v_nuevo_dep_per         numeric;
    v_nuevo_monto_vigente   numeric;
    v_nuevo_vida_util       integer;
    v_mes_dep               date;
    v_gestion_previa		integer;
    v_gestion_dep		integer;

BEGIN
    
    v_nombre_funcion = 'kaf.f_depreciacion_lineal';
    v_id_moneda = 3;
    
    
    --RAC 03/03/2017
    --  TODO validar que no se valores dos veces dentro el mismo omvimeinto
    -- talvez  eliminar la depreciacion del movimiento antes de empesar ...
    
    delete from  
    kaf.tmovimiento_af_dep mafd
    where mafd.id_movimiento_af = p_id_movimiento_af;
    
    ---FIN RAC
    --lista los activos fijos y sus revalorizaciones a partir de la ultima depreciacion ....
    -- cuando se da de alta una activo se llena un registro en tactivo_fijo_valores con los valores de compra
    -- esto permite depreciacar por separado el valor original y las mejoras
    
    --RAC, 29/03/2017, debemos considerar que habran mejoras que no incrementaran la vida util del activo fijo ....
    for v_rec_ant in (
                       select
                        afv.id_activo_fijo_valor,
                        case 
                            when afv.fecha_ult_dep is null then 
                                afv.fecha_ini_dep
                            else 
                               afv.fecha_ult_dep + interval '1' month
                        end as fecha_inicio,
                        afv.fecha_ult_dep,
                        afv.fecha_ini_dep,
                        afv.depreciacion_acum, 
                        afv.depreciacion_per, 
                        afv.monto_vigente, 
                        afv.vida_util,
                        afv.monto_rescate,
                        afv.vida_util_real,
                        afv.monto_vigente_real,
                        afv.fecha_ult_dep_real,
                        afv.depreciacion_acum_real,
                        afv.depreciacion_per_real,
                        afv.depreciacion_acum_ant_real,
                        cla.depreciable
                      from kaf.vactivo_fijo_valor afv
                      inner join kaf.tactivo_fijo af on af.id_activo_fijo = afv.id_activo_fijo
                      inner join kaf.tclasificacion cla on cla.id_clasificacion = af.id_clasificacion
                      where afv.id_activo_fijo = p_id_activo_fijo
                      and afv.estado = 'activo'
                      and (
                            CASE WHEN p_depreciar = 'SI'  THEN vida_util_real > 0
                                ELSE
                                   0 = 0
                                END)
                      
                      ) loop   --TODO where agregar case para activos no deprecialbes

                --Inicialización mes inicio de depreciación
               -- v_mes_dep = v_rec_ant.fecha_inicio;
                 IF v_rec_ant.fecha_ult_dep_real > v_rec_ant.fecha_ini_dep THEN
                     v_mes_dep = v_rec_ant.fecha_ult_dep_real + interval '1' month;
                 ELSE
                     v_mes_dep = v_rec_ant.fecha_ult_dep_real;
                 END IF;
                 
                 
                
                --Inicialización datos última depreciación
                --raise exception 'lll : %  %   %   %',v_rec_ant.depreciacion_acum,v_rec_ant.depreciacion_per,v_rec_ant.monto_vigente,v_rec_ant.vida_util;
                
                 IF p_depreciar = 'SI' THEN
                    v_ant_dep_acum      = v_rec_ant.depreciacion_acum_real;
                    v_ant_dep_per       = v_rec_ant.depreciacion_per_real;
                    v_ant_monto_vigente = v_rec_ant.monto_vigente_real;
                    v_ant_vida_util     = v_rec_ant.vida_util_real;
                ELSE
                    v_ant_dep_acum      = 0;
                    v_ant_dep_per       = 0;
                    v_ant_monto_vigente = v_rec_ant.monto_vigente_real;
                    v_ant_vida_util     = 0;
                END IF;
                
                
                --Determinar la cantidad de meses a depreciar
                v_meses_dep =  months_between(v_mes_dep, p_hasta);
                --raise exception '%, % , %, meses = %',v_rec_ant.fecha_inicio, v_mes_dep, p_hasta, v_meses_dep;
                
                for i in 1..v_meses_dep loop
                
                        --Obtener tipo de cambio del inicio y fin de mes   
                        select
                           o_tc_inicial, o_tc_final, o_tc_factor, o_fecha_ini, o_fecha_fin
                        into v_rec_tc
                        from kaf.f_get_tipo_cambio(v_id_moneda,v_mes_dep);
                        
                        IF p_depreciar = 'SI' THEN
                        
                              --Actualización de importes
                              v_dep_acum_actualiz = v_ant_dep_acum * v_rec_tc.o_tc_factor;
                              v_dep_per_actualiz  = v_ant_dep_per * v_rec_tc.o_tc_factor;
                              v_monto_actualiz    = v_ant_monto_vigente * v_rec_tc.o_tc_factor;
                              
                                --Cálculo nuevos valores por depreciación
                              
                              --RAC 03/03/2017
                              --  agrega validacion de division por cero
                              IF  v_ant_vida_util = 0 and v_rec_ant.depreciable = 'si' THEN
                                 EXIT; --v_nuevo_dep_mes       = 0;
                              ELSE
                                 v_nuevo_dep_mes       = (v_monto_actualiz - v_rec_ant.monto_rescate) / v_ant_vida_util;
                              END IF;
                              
                              v_nuevo_dep_acum      = v_dep_acum_actualiz + v_nuevo_dep_mes;                              
                              v_nuevo_monto_vigente = v_monto_actualiz - v_nuevo_dep_mes;
                              v_nuevo_vida_util     = v_ant_vida_util - 1;
                              v_nuevo_dep_per       = v_dep_per_actualiz + v_nuevo_dep_mes;
                              
                             
                              
                        ELSE
                        
                              --Actualización de importes
                              v_dep_acum_actualiz = v_ant_dep_acum * v_rec_tc.o_tc_factor;
                              v_dep_per_actualiz  = v_ant_dep_per * v_rec_tc.o_tc_factor;
                              v_monto_actualiz    = v_ant_monto_vigente * v_rec_tc.o_tc_factor;
                              
                              v_nuevo_dep_acum      = 0;
                              v_nuevo_dep_per       = 0;
                              v_nuevo_monto_vigente = v_monto_actualiz;
                              v_nuevo_vida_util     = v_ant_vida_util ;
                          
                          
                          
                          
                        END IF;
                       
                        
                        
                        
                        --Inserción en base de datos
                        INSERT INTO kaf.tmovimiento_af_dep (
                            id_usuario_reg,
                            id_usuario_mod,
                            fecha_reg,
                            fecha_mod,
                            estado_reg,
                            id_usuario_ai,
                            usuario_ai,
                            id_movimiento_af,
                            id_moneda, 
                            depreciacion_acum_ant, --10
                            depreciacion_per_ant,
                            monto_vigente_ant,
                            vida_util_ant,
                            depreciacion_acum_actualiz,
                            depreciacion_per_actualiz,
                            monto_actualiz,
                            depreciacion,
                            depreciacion_acum,
                            depreciacion_per, --20
                            monto_vigente,
                            vida_util,
                            tipo_cambio_ini,
                            tipo_cambio_fin,
                            factor,
                            id_activo_fijo_valor, --26
                            fecha
                        ) VALUES (
                            1,
                            null,
                            now(),
                            null,
                            'activo',
                            null,
                            null,
                            p_id_movimiento_af,
                            1,
                            v_ant_dep_acum, --10
                            v_ant_dep_per,
                            v_ant_monto_vigente,
                            v_ant_vida_util,
                            v_dep_acum_actualiz,
                            v_dep_per_actualiz,
                            v_monto_actualiz,
                            v_nuevo_dep_mes,
                            v_nuevo_dep_acum,
                            v_nuevo_dep_per,
                            v_nuevo_monto_vigente, --20
                            v_nuevo_vida_util,
                            v_rec_tc.o_tc_inicial,
                            v_rec_tc.o_tc_final,
                            v_rec_tc.o_tc_factor,
                            v_rec_ant.id_activo_fijo_valor, --25
                            v_mes_dep
                        );
                        
                        v_gestion_previa =   EXTRACT(YEAR FROM v_mes_dep::date);
                        --Incrementa en uno el mes
                        v_mes_dep = v_mes_dep + interval '1' month;
                        
                        v_gestion_dep =   EXTRACT(YEAR FROM v_mes_dep::date);
                        
                        
                         --si detectamos que cambio la gestion reseteamos la depreciacion acumulado del periodo (gestion..)
                        IF v_gestion_previa != v_gestion_dep THEN
                           v_ant_dep_per = 0.00;
                        ELSE
                            v_ant_dep_per = v_nuevo_dep_per;
                        END IF;
                        
                        --Reinicialización de valores depreciación para siguiente iteración
                        v_ant_dep_acum = v_nuevo_dep_acum;
                       
                        v_ant_monto_vigente = v_nuevo_monto_vigente;
                        v_ant_vida_util = v_nuevo_vida_util;
                    
                end loop;
        
        
        
    end loop;
    
    
    
    
   
    return 'done';

EXCEPTION
  WHEN OTHERS THEN
      v_resp='';
      v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
      v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
      v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
      raise exception '%',v_resp;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;