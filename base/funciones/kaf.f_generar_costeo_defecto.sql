--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_generar_costeo_defecto (
  p_id_usuario integer,
  p_id_movimiento integer,
  p_fecha_mov date,
  p_id_gestion_mov integer,
  p_id_centro_costo_depto integer
)
RETURNS varchar AS
$body$
/*
Autor: RAC
Fecha: 06/10/2017
Descripción: genera costeo por defecto
*/
DECLARE

    v_resp                  		varchar;
    v_salida 						varchar;
    v_nombre_funcion        		varchar;   
    v_registros						record;
    
    
    va_cc_aux						numeric[];
    v_tam			      			integer;
    v_indice			      		integer;
    v_id_centro_costo 				integer;
    v_id_ot 						integer;
    v_factor 						numeric;
    v_importe_prorrateado 	 		numeric;
    v_total_prorrateado 			numeric;
    v_importe_prorrateado_act 	 	numeric;
    v_total_prorrateado_act 		numeric;
    v_reg_det						record;
    v_id_moneda_dep					integer;
   
  
    v_depreciacion_per_final			numeric;
    v_aitb_activo						numeric;
    v_depreciacion						numeric;
    v_aitb_depreciacion_acumulada		numeric;
    v_id_cuenta_dep			      		integer;
    v_id_partida_dep			      	integer;
    v_id_auxiliar_dep			      	integer;
   
    v_actualizacion			      		integer;
    v_id_cuenta_dep_acum			    integer;
    v_id_partida_dep_acum			    integer;
    v_id_auxiliar_dep_aucm			    integer;
    v_id_cuenta_act_activo			    integer;
    v_id_partida_act_activo			    integer;
    v_id_auxiliar_act_activo			integer;
    v_id_cuenta_act_dep			      	integer;
    v_id_partida_act_dep			    integer;
    v_id_auxiliar_act_dep			    integer;
    
     v_depreciacion_acum numeric;
     v_aitb_dep_acum numeric;
    
   
    

BEGIN
    
    v_nombre_funcion = 'kaf.f_generar_costeo_defecto';
    v_salida = 'Costeado';
   
    
    --  elimina todo el prorrateo que exista
    
    delete  
    from kaf.tprorrateo_af paf
    where 
    paf.id_movimiento_af in (select mov.id_movimiento_af
                              from kaf.tmovimiento_af mov
                              where mov.id_movimiento = p_id_movimiento);
    
    
    -- recuepra moneda de contabilidacion
    
    select
       md.id_moneda_dep
    into
      v_id_moneda_dep
    from kaf.tmoneda_dep md
    where md.contabilizar = 'si';
    
   
    
    --FOR genera listado de depreciacion por activos fijos en moneda de depreciacion
    
    
     FOR v_registros in (
   						SELECT 	
                             afv.id_activo_fijo,
                             afv.id_movimiento_af,
                             afv.deducible,
                             afv.monto_vigente_final,
                             afv.tipo,
                             afv.depreciacion_per_final,
                             afv.aitb_depreciacion_acumulada,
                             afv.aitb_activo,                 
                             afv.id_clasificacion,
                             c.nombre as nombre_clasificacion,
                             afv.id_activo_fijo_valor
   						FROM kaf.vdetalle_depreciacion_activo afv
                        inner join kaf.tclasificacion c on c.id_clasificacion = afv.id_clasificacion
                         where 
                               afv.id_moneda_dep = v_id_moneda_dep
                          and  afv.id_movimiento = p_id_movimiento) LOOP
                          
          v_depreciacion_per_final = COALESCE( v_registros.depreciacion_per_final,0);  --este monto vamos a prorratear (Depreciacion y depreciacion acumulada)
          v_aitb_activo = COALESCE(v_registros.aitb_activo,0);  --este monto vamos a prorratear (Actualizacion) 
          v_aitb_depreciacion_acumulada = COALESCE(v_registros.aitb_depreciacion_acumulada,0);--este monto vamos a prorratear (Actualizacion) 
          
          
          --------------------------------------------------------  
          --  determina array de centros de costo
          --  recorre array de centros de costo v
          ---------------------------------------------------------
          
          v_total_prorrateado = 0;          
          v_importe_prorrateado = 0;
          
          
               
          FOR v_reg_det in (select  * 
                            from kaf.f_get_af_cc(v_registros.id_activo_fijo ,p_id_gestion_mov,p_fecha_mov) 
                            as (id_cc integer, id_ot integer, factor numeric, row_number BIGINT)
                            order by  row_number desc )LOOP
                 
          
                 
                  v_id_centro_costo = v_reg_det.id_cc;
                  v_id_ot = v_reg_det.id_ot;
                  v_factor =v_reg_det.factor;
                 
                  --recupera  cuenta cotable de activo fijos                  
                  v_importe_prorrateado = v_depreciacion_per_final * v_factor;
                  v_total_prorrateado = v_total_prorrateado + v_importe_prorrateado;
                  
                  v_importe_prorrateado_act = v_aitb_depreciacion_acumulada * v_factor;
                  v_total_prorrateado_act = v_total_prorrateado_act + v_importe_prorrateado_act;
                  
                  v_depreciacion = 0;
                  v_depreciacion_acum = 0;                  
                  v_aitb_dep_acum = 0;
                                   
                  IF v_reg_det.row_number != 1 THEN                    
                     v_depreciacion = v_depreciacion_per_final * v_factor;
                     v_total_prorrateado = v_total_prorrateado + v_importe_prorrateado;
                                       
                  ELSE
                    -- si el el ultimo se calcula por diferencia
                    
                     v_depreciacion = v_depreciacion_per_final - v_importe_prorrateado_act;
                     v_depreciacion_acum = v_depreciacion_per_final;
                     v_aitb_dep_acum = v_aitb_depreciacion_acumulada;
                    
                     
                  END IF;
                  
                   
                  
                 --  v_depreciacion_per_final prorrrateado DEPCLAS
                 --  recuperar la relacion contable para la depreciacion (gasto_depreciacion)
                 
                 IF  v_registros.deducible = 'si' THEN
                 
                         SELECT 
                            ps_id_partida ,
                            ps_id_cuenta,
                            ps_id_auxiliar
                          into 
                            v_id_partida_dep,
                            v_id_cuenta_dep, 
                            v_id_auxiliar_dep
                         FROM conta.f_get_config_relacion_contable('DEPCLAS',   --  Gasto por depreciación  v_depreciacion_per_final
                                                                    p_id_gestion_mov, 
                                                                    v_registros.id_clasificacion, 
                                                                    v_id_centro_costo,  
                                                                   'No se encontro relación contable para el activo fijo ID: '||v_registros.nombre_clasificacion::varchar||'. <br> Mensaje: ');
                
                 ELSE
                         --  si no es deducible la cuenta de gasto cambia
                         --  para el caso de revalorizaciones  , este gasto no es deducible del impuesto a las utilidaddes
                         --  y debe ser diferenciado en otra cuenta de gasto
                 
                         SELECT 
                                ps_id_partida ,
                                ps_id_cuenta,
                                ps_id_auxiliar
                              into 
                                v_id_partida_dep,
                                v_id_cuenta_dep, 
                                v_id_auxiliar_dep
                             FROM conta.f_get_config_relacion_contable('DEPCLASNOD',   --  Gasto por depreciación  v_depreciacion_per_final
                                                                        p_id_gestion_mov, 
                                                                        v_registros.id_clasificacion, 
                                                                        v_id_centro_costo,  
                                                                        'No se encontro relación contable para el activo fijo ID: '||v_registros.nombre_clasificacion::varchar||'. <br> Mensaje: ');
                 END IF;
                 
                 
                 IF v_reg_det.row_number = 1 THEN  
                 
                           -- depreciacion_per_final  DEPACCLAS
                           --  recueprar la relacion contable para actualizacion   -- depreciacion_per_final  
                           -- (recuepra centro de costo del depto de conta)
                           
                           SELECT 
                              ps_id_partida ,
                              ps_id_cuenta,
                              ps_id_auxiliar
                            into 
                              v_id_partida_dep_acum,
                              v_id_cuenta_dep_acum, 
                              v_id_auxiliar_dep_aucm
                           FROM conta.f_get_config_relacion_contable('DEPACCLAS',   --  v_depreciacion_per_final
                                                                      p_id_gestion_mov, 
                                                                      v_registros.id_clasificacion, 
                                                                      p_id_centro_costo_depto,  
                                                                      'No se encontro relación contable para el activo fijo: '||v_registros.nombre_clasificacion::varchar||'. <br> Mensaje: ');
                          
                            
                           
                           
                           --aitb_activo   ALTAAF
                           --  recuperar la relacion contable para la depreciacion (gasto_depreciacion)
                           
                           SELECT 
                              ps_id_partida ,
                              ps_id_cuenta,
                              ps_id_auxiliar
                            into 
                              v_id_partida_act_activo,
                              v_id_cuenta_act_activo, 
                              v_id_auxiliar_act_activo
                           FROM conta.f_get_config_relacion_contable('ALTAAF',     -- v_aitb_activo  actualización de activo fijo
                                                                      p_id_gestion_mov, 
                                                                      v_registros.id_clasificacion, 
                                                                      p_id_centro_costo_depto,  
                                                                      'No se encontro relación contable para el activo fijo ID: '||v_registros.nombre_clasificacion::varchar||'. <br> Mensaje: ');
                          
                           
                           --aitb_depreciacion_acumulada   DEPACCLAS  (la prametriacion es la misma utilizada para la dpreciacon acumulada)  
                            
                           v_id_partida_act_dep = v_id_partida_dep_acum;
                           v_id_cuenta_act_dep = v_id_cuenta_dep_acum;
                           v_id_auxiliar_act_dep = v_id_auxiliar_dep_aucm;
                           
                           
                   
                   ELSE       
                        v_id_partida_act_dep = NULL;
                        v_id_cuenta_act_dep = NULL; 
                        v_id_auxiliar_act_dep = NULL;
                        v_id_partida_act_activo = NULL;
                   		v_id_cuenta_act_activo = NULL;
                        v_id_auxiliar_act_activo = NULL;
                        v_id_partida_dep_acum = NULL;
                        v_id_cuenta_dep_acum = NULL;
                        v_id_auxiliar_dep_aucm = NULL;
                              
                                      
                   END IF;        
                  
                 --  inserta el detalle en la tabla de prorrateo segun el factor por centro de costo
                 
                 
                  INSERT INTO   kaf.tprorrateo_af
                    (
                     
                      id_movimiento_af,
                      id_activo_fijo_valor,
                      id_centro_costo,
                      id_ot,
                      id_cuenta_dep,
                      id_partida_dep,
                      id_auxiliar_dep,                      
                      id_cuenta_dep_acum,
                      id_partida_dep_acum,
                      id_auxiliar_dep_aucm,
                      id_cuenta_act_activo,
                      id_partida_act_activo,
                      id_auxiliar_act_activo,
                      id_cuenta_act_dep,
                      id_partida_act_dep,
                      id_auxiliar_act_dep,
                      depreciacion,
                      depreciacion_acum,
                      aitb_activo,
                      aitb_dep_acum
                    )
                    VALUES (
                     
                      v_registros.id_movimiento_af,
                   	  v_registros.id_activo_fijo_valor,
                      v_id_centro_costo,
                      v_id_ot,
                      v_id_cuenta_dep,
                      v_id_partida_dep,
                      v_id_auxiliar_dep,
                      
                      v_id_cuenta_dep_acum,
                      v_id_partida_dep_acum,
                      v_id_auxiliar_dep_aucm,
                      v_id_cuenta_act_activo,
                      v_id_partida_act_activo,
                      v_id_auxiliar_act_activo,
                      v_id_cuenta_act_dep,
                      v_id_partida_act_dep,
                      v_id_auxiliar_act_dep,
                      v_depreciacion,
                      v_depreciacion_acum,
                      v_aitb_activo,
                      v_aitb_dep_acum
                    );
                    
                    
                   
                  
          END LOOP;
               
                  
     END LOOP;           
                
           
           
    return v_salida;

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