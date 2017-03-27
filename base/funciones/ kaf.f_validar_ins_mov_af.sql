--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_validar_ins_mov_af (
  p_id_movimiento integer,
  p_id_activo_fijo integer,
  p_lazar_error boolean = true
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_ime
 DESCRIPCION:   funcion  que centraliza las validaciones sobre lso activos fijos relacionado con movimiento, se usa al insertar editar movimiento_af, y en la isneración automatica de movimiento
 AUTOR: 		 (RAC)
 FECHA:	        27(03/2017
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE
 v_resp	varchar;
 v_nombre_funcion	varchar;
 v_registros		record;
 v_reg_af			record;
 v_error 			varchar;
 v_registros_mov	record;


BEGIN
 
   v_nombre_funcion = 'kaf.f_validar_ins_mov_af';
   
   
    select 
          mov.estado,
          mov.codigo,
          cat.codigo as codigo_movimiento,
          mov.id_cat_movimiento
         INTO 
          v_registros
      from kaf.tmovimiento mov
      inner join  param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
      where mov.id_movimiento =  p_id_movimiento;
      
      select 
         af.id_activo_fijo,
         af.denominacion,
         af.codigo,
         af.estado
        into
          v_reg_af
      from kaf.tactivo_fijo af 
      where af.id_activo_fijo = p_id_activo_fijo;   
      
      -----------------------------
      -- validaciones genericas
      -----------------------------
           --  validar que no exista otro movimiento del mismo tipo que este en borrador o no este finalizado
        
      v_error = '';
      FOR v_registros_mov in (
      						 select
                                mov.id_movimiento,
                                mov.num_tramite
                              from kaf.tmovimiento mov
                              inner join kaf.tmovimiento_af maf on mov.id_movimiento = maf.id_movimiento and maf.id_activo_fijo = p_id_activo_fijo
                              where     mov.id_movimiento != p_id_movimiento 
                                    and  mov.id_cat_movimiento = v_registros.id_cat_movimiento
                                    and mov.estado_reg = 'activo'
                                    and mov.estado  not in ('finalizado')) LOOP
      
      v_error = v_error ||'<BR> '||v_registros_mov.num_tramite;
      END LOOP;
      
      IF v_error != '' THEN
           IF p_lazar_error THEN
               raise exception 'El activo ID =%, %  (%) se encuentra en los movimientos:  % <br> que no es tan finalizados', p_id_activo_fijo,v_reg_af.denominacion,COALESCE(v_reg_af.codigo,'s/c'),v_error ;         
           ELSE
              RETURN FALSE;
           END IF;
      END IF;
          
      --------------------------------------------      
      --validaciones segun el tipo de movimiento
      -------------------------------------------
            
        IF v_registros.codigo_movimiento = 'deprec' THEN
            --  validar que el activo este dado de alta
            IF v_reg_af.estado != 'alta' THEN
                 IF p_lazar_error THEN
                   raise exception 'solo puede depreciar activos que esten dados de alta (%)',COALESCE(v_reg_af.denominacion,'s/d'); 
                 ELSE
                    RETURN FALSE;
                 END IF;
                         
            END IF;
            
        ELSIF v_registros.codigo_movimiento = 'transf' THEN
        
           -- validar que el activo es asignado con el funcionario origen
          
            
        ELSIF v_registros.codigo_movimiento = 'baja' THEN
             --solo podemso dar de baja activos que estan dados de alta
            IF v_reg_af.estado != 'alta' THEN
               
                IF p_lazar_error THEN
                   raise exception 'solo puede dar de baja  activos que esten dados de alta (%)',COALESCE(v_reg_af.codigo,'s/c'); 
                ELSE
                    RETURN FALSE;
                END IF;           
            END IF;
             
        ELSIF v_registros.codigo_movimiento = 'asig' THEN
        
           --validar que el activo fijo este en deposito para ser asignado
           IF v_reg_af.estado != 'alta' THEN
              
                IF p_lazar_error THEN
                 raise exception 'solo puede asginar activos que esten dados de alta (%)',COALESCE(v_reg_af.codigo,'s/c');
                ELSE
                  RETURN FALSE;
                END IF;            
           END IF;
          
       
        END IF;
   
   

        RETURN TRUE;
        
        
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