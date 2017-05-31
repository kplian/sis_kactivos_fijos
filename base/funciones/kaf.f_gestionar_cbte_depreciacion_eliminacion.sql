--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_gestionar_cbte_depreciacion_eliminacion (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/*
Autor: RAC KPLIAN
Fecha:   03 Mayo de 2017
Descripcion  gestion la eliminacion de comprobantes de depreciacion

  

*/


DECLARE
  
	v_nombre_funcion   		text;
	v_resp					varchar;
    v_registros 			record;
    v_id_estado_actual  	integer;
    va_id_tipo_estado 		integer[];
    va_codigo_estado 		varchar[];
    va_disparador    		varchar[];
    va_regla         		varchar[]; 
    va_prioridad     		integer[];
    v_tipo_sol   			varchar;
    v_nro_cuota 			numeric;
    v_id_proceso_wf 		integer;
    v_id_estado_wf 			integer;
    v_id_plan_pago 			integer;
    v_verficacion  			boolean;
    v_verficacion2  		varchar[];
    v_id_tipo_estado 		integer;
    v_id_funcionario  		integer;
    v_id_usuario_reg 		integer;
    v_id_depto 				integer;
    v_codigo_estado 		varchar;
    v_id_estado_wf_ant  	integer;
    v_rec_cbte_trans   		record;
    v_reg_cbte   			record;
    
BEGIN

	v_nombre_funcion = 'kaf.f_gestionar_cbte_depreciacion_eliminacion';
    
    
    
    -- 1) con el id_int_comprobante identificar el proceso de caja
   
      select 
          mov.id_movimiento,
          mov.id_estado_wf,
          mov.id_proceso_wf,
          mov.estado,
          mov.num_tramite,
          c.id_int_comprobante,         
          c.estado_reg as estadato_cbte,
          mov.id_int_comprobante,
          mov.id_int_comprobante_aitb
      into
          v_registros
      from  kaf.tmovimiento  mov
      inner join conta.tint_comprobante  c on c.id_int_comprobante = mov.id_int_comprobante 
      where  mov.id_int_comprobante = p_id_int_comprobante; 
    
    
    IF v_registros.id_int_comprobante_aitb is NULL THEN
    
   
          --2) Validar que tenga una cuenta documentada
          
           IF  v_registros.id_movimiento is NULL  THEN     
              raise exception 'El comprobante no esta relacionado a ningún movimiento de depreciación';
           END IF;
           
           
           
          select
            ic.estado_reg
          INTO
           v_reg_cbte
          from conta.tint_comprobante ic
          where ic.id_int_comprobante = p_id_int_comprobante;
           
          IF v_reg_cbte.estado_reg = 'validado' THEN
             raise exception 'no puede eliminar comprobantes validados';
          END IF;
           
         --  recupera estado anterior segun Log del WF
              SELECT  
                 ps_id_tipo_estado,
                 ps_id_funcionario,
                 ps_id_usuario_reg,
                 ps_id_depto,
                 ps_codigo_estado,
                 ps_id_estado_wf_ant
              into
                 v_id_tipo_estado,
                 v_id_funcionario,
                 v_id_usuario_reg,
                 v_id_depto,
                 v_codigo_estado,
                 v_id_estado_wf_ant 
              FROM wf.f_obtener_estado_ant_log_wf(v_registros.id_estado_wf);
              
               --
               
                select 
                     ew.id_proceso_wf 
                  into 
                     v_id_proceso_wf
                from wf.testado_wf ew
                where ew.id_estado_wf= v_id_estado_wf_ant;
                            
                -- registra nuevo estado
                            
                v_id_estado_actual = wf.f_registra_estado_wf(
                    v_id_tipo_estado, 
                    v_id_funcionario, 
                    v_registros.id_estado_wf, 
                    v_id_proceso_wf, 
                    p_id_usuario,
                    p_id_usuario_ai,
                    p_usuario_ai,
                    v_id_depto,
                    'Eliminación de comprobante de cuenta documentada:'|| COALESCE(v_registros.id_int_comprobante::varchar,'NaN'));
                            
               
                            
                  -- actualiza estado en la solicitud
                 update kaf.tmovimiento mov set 
                       id_estado_wf =  v_id_estado_actual,
                       estado = v_codigo_estado,
                       id_usuario_mod=p_id_usuario,
                       fecha_mod=now(),
                       id_int_comprobante = NULL,
                       id_usuario_ai = p_id_usuario_ai,
                       usuario_ai = p_usuario_ai
                  where mov.id_movimiento = v_registros.id_movimiento;
          
         ELSE
             -- si el otro comprobante no fue eliminado solo borramso la relacion del comprobante
              update kaf.tmovimiento mov set
                 id_usuario_mod=p_id_usuario,
                 fecha_mod=now(),
                 id_int_comprobante = NULL,
                 id_usuario_ai = p_id_usuario_ai,
                 usuario_ai = p_usuario_ai
               where mov.id_movimiento = v_registros.id_movimiento;
         
         END IF;    
     
    
  
RETURN  TRUE;



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