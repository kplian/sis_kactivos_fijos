CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_caract_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_caract_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo_caract'
 AUTOR: 		 (admin)
 FECHA:	        17-04-2016 07:14:58
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
	v_id_activo_fijo_caract	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_caract_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_AFCARACT_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	if(p_transaccion='SKA_AFCARACT_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo_caract(
			clave,
			valor,
			id_activo_fijo,
			estado_reg,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			fecha_mod,
			id_usuario_mod,
			id_clasificacion_variable
          	) values(
			v_parametros.clave,
			v_parametros.valor,
			v_parametros.id_activo_fijo,
			'activo',
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null,
			v_parametros.id_clasificacion_variable
			)RETURNING id_activo_fijo_caract into v_id_activo_fijo_caract;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Caracteristicas almacenado(a) con exito (id_activo_fijo_caract'||v_id_activo_fijo_caract||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_caract',v_id_activo_fijo_caract::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFCARACT_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCARACT_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo_caract set
			clave = v_parametros.clave,
			valor = v_parametros.valor,
			id_activo_fijo = v_parametros.id_activo_fijo,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			id_clasificacion_variable = v_parametros.id_clasificacion_variable
			where id_activo_fijo_caract=v_parametros.id_activo_fijo_caract;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Caracteristicas modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_caract',v_parametros.id_activo_fijo_caract::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFCARACT_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCARACT_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo_caract
            where id_activo_fijo_caract=v_parametros.id_activo_fijo_caract;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Caracteristicas eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_caract',v_parametros.id_activo_fijo_caract::varchar);
              
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
ALTER FUNCTION "kaf"."ft_activo_fijo_caract_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
