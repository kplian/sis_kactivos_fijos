--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_generar_costeo_defecto (
  p_id_usuario integer,
  p_id_activo_fijo integer,
  p_hasta date,
  p_id_movimiento integer,
  p_depreciar varchar = 'SI'::character varying
)
RETURNS varchar AS
$body$
/*
Autor: RAC
Fecha: 06/10/2017
Descripción: genera costeo por defecto
*/
DECLARE

    v_resp                  varchar;
    v_nombre_funcion        varchar;
    v_meses_dep             integer;
    v_id_moneda_act         integer;
    v_rec_ant               record;
    v_rec_tc                record;
    v_dep_acum_actualiz     numeric;
    v_dep_per_actualiz      numeric;
    v_monto_actualiz        numeric;
    v_ant_dep_acum          numeric;
    v_ant_dep_per           numeric;
    v_ant_monto_vigente     numeric;
    v_ant_vida_util         		integer;
    v_nuevo_dep_mes         		numeric;
    v_nuevo_dep_acum        		numeric;
    v_nuevo_dep_per         		numeric;
    v_nuevo_monto_vigente   		numeric;
    v_nuevo_vida_util       		integer;
    v_mes_dep               		date;
    v_gestion_previa		    	integer;
    v_gestion_dep			      	integer;
    v_ant_monto_actualiz  			numeric;
    v_gestion_aux			      	integer;
    v_mes_aux				        integer;
    v_registros_mod			    	record;
    v_contador 				      	integer;
    v_tipo_cambio_anterior			numeric;
    v_id_subsistema         		integer;
    v_id_periodo_subsistema 		integer;
    v_res                   		varchar;
    v_salida                		varchar;
    v_sw                    		boolean;
    v_id_movimiento_af_dep  		integer;
    v_id_moneda_dep  				integer;
    v_dep_aux						numeric;
    v_registros						record;
    v_act_aux						numeric;
    v_dep_aum_aux					numeric;

BEGIN
    
    v_nombre_funcion = 'kaf.f_generar_costeo_defecto';
    v_salida = 'Costeado';
    v_sw = false;
    
    
    --elimina todo el prorrateo que exista
    
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
    
    --FOR genera lsitado de depreciacion por activos fijos en moneda de depreciacion
    
    
   FOR v_registros in (
   						SELECT 	
                             afv.id_activo_fijo,
                             afv.deducible,
                             afv.monto_vigente_final,
                             afv.tipo,
                             afv.depreciacion_per_final,
                             afv.aitb_depreciacion_acumulada,
                             afv.aitb_activo,
                             afv.aitb_depreciacion_acumulada
   						FROM kaf.vdetalle_depreciacion_activo afv
                         where 
                               afv.id_moneda_dep = v_id_moneda_dep
                          and  afv.id_movimiento = p_id_movimiento) LOOP
                          
          v_dep_aux = v_registros.depreciacion_per_final;  --este monto vamos a prorratear (Depreciacion)
          v_act_aux = v_registros.aitb_activo;  --este monto vamos a prorratear (Actualizacion) 
          v_dep_aum_aux = v_registros.aitb_depreciacion_acumulada;--este monto vamos a prorratear (Actualizacion) 
          
          
          --determina array de centros de costo
         
               
               -- busca centro de costo especifico para el activo
       

               -- busca centro de costo del responsabl del activo fijos
               
               
               -- busca el centro de costo del proyecto
               
               
               
               -- FOR recorre array de centros de costo
               
                  --recupera  cuenta cotable de activo fijos
                  -- inserta el detalle en la tabla de prorrateo segun el factor por centor de costo
                  -- si el el ulitmo se calcula por diferencia
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