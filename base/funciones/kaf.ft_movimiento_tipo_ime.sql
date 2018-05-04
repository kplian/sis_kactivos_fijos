CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_tipo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_tipo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_tipo'
 AUTOR: 		 (admin)
 FECHA:	        23-03-2016 05:18:37
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
	v_id_movimiento_tipo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_tipo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOVTIP_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-03-2016 05:18:37
	***********************************/

	if(p_transaccion='SKA_MOVTIP_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tmovimiento_tipo(
			id_cat_movimiento,
			estado_reg,
			id_proceso_macro,
			fecha_reg,
			usuario_ai,
			id_usuario_reg,
			id_usuario_ai,
			fecha_mod,
			id_usuario_mod,
			plantilla_cbte_uno,
			plantilla_cbte_dos,
			plantilla_cbte_tres
          	) values(
			v_parametros.id_cat_movimiento,
			'activo',
			v_parametros.id_proceso_macro,
			now(),
			v_parametros._nombre_usuario_ai,
			p_id_usuario,
			v_parametros._id_usuario_ai,
			null,
			null,
			v_parametros.plantilla_cbte_uno,
			v_parametros.plantilla_cbte_dos,
			v_parametros.plantilla_cbte_tres
			)RETURNING id_movimiento_tipo into v_id_movimiento_tipo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Movimiento almacenado(a) con exito (id_movimiento_tipo'||v_id_movimiento_tipo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_tipo',v_id_movimiento_tipo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVTIP_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-03-2016 05:18:37
	***********************************/

	elsif(p_transaccion='SKA_MOVTIP_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tmovimiento_tipo set
			id_cat_movimiento = v_parametros.id_cat_movimiento,
			id_proceso_macro = v_parametros.id_proceso_macro,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			plantilla_cbte_uno = v_parametros.plantilla_cbte_uno,
			plantilla_cbte_dos = v_parametros.plantilla_cbte_dos,
			plantilla_cbte_tres = v_parametros.plantilla_cbte_tres
			where id_movimiento_tipo=v_parametros.id_movimiento_tipo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Movimiento modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_tipo',v_parametros.id_movimiento_tipo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVTIP_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-03-2016 05:18:37
	***********************************/

	elsif(p_transaccion='SKA_MOVTIP_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_tipo
            where id_movimiento_tipo=v_parametros.id_movimiento_tipo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Movimiento eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_tipo',v_parametros.id_movimiento_tipo::varchar);
              
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
ALTER FUNCTION "kaf"."ft_movimiento_tipo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
