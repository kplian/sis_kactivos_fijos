CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_af_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_af'
 AUTOR: 		 (admin)
 FECHA:	        18-03-2016 05:34:15
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_movimiento_af	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_af_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	if(p_transaccion='SKA_MOVAF_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tmovimiento_af(
			id_movimiento,
			id_activo_fijo,
			id_cat_estado_fun,
			id_movimiento_motivo,
			estado_reg,
			importe,
			vida_util,
			fecha_reg,
			usuario_ai,
			id_usuario_reg,
			id_usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_movimiento,
			v_parametros.id_activo_fijo,
			v_parametros.id_cat_estado_fun,
			v_parametros.id_movimiento_motivo,
			'activo',
			v_parametros.importe,
			v_parametros.vida_util,
			now(),
			v_parametros._nombre_usuario_ai,
			p_id_usuario,
			v_parametros._id_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_movimiento_af into v_id_movimiento_af;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento almacenado(a) con exito (id_movimiento_af'||v_id_movimiento_af||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_id_movimiento_af::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tmovimiento_af set
			id_movimiento = v_parametros.id_movimiento,
			id_activo_fijo = v_parametros.id_activo_fijo,
			id_cat_estado_fun = v_parametros.id_cat_estado_fun,
			id_movimiento_motivo = v_parametros.id_movimiento_motivo,
			importe = v_parametros.importe,
			vida_util = v_parametros.vida_util,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_movimiento_af=v_parametros.id_movimiento_af;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af
            where id_movimiento_af=v_parametros.id_movimiento_af;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
         
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

	end if;

EXCEPTION
				
	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
		raise exception '%',v_resp;
				        
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_movimiento_af_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
