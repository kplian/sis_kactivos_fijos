CREATE OR REPLACE FUNCTION "kaf"."ft_tipo_bien_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_bien_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.ttipo_bien'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 10:00:40
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
	v_id_tipo_bien	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_tipo_bien_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_TIPBIE_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:00:40
	***********************************/

	if(p_transaccion='SKA_TIPBIE_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.ttipo_bien(
			descripcion,
			estado_reg,
			codigo,
			id_usuario_ai,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.descripcion,
			'activo',
			v_parametros.codigo,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			null,
			null
							
			
			
			)RETURNING id_tipo_bien into v_id_tipo_bien;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien almacenado(a) con exito (id_tipo_bien'||v_id_tipo_bien||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien',v_id_tipo_bien::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPBIE_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:00:40
	***********************************/

	elsif(p_transaccion='SKA_TIPBIE_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.ttipo_bien set
			descripcion = v_parametros.descripcion,
			codigo = v_parametros.codigo,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_tipo_bien=v_parametros.id_tipo_bien;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien',v_parametros.id_tipo_bien::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPBIE_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:00:40
	***********************************/

	elsif(p_transaccion='SKA_TIPBIE_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.ttipo_bien
            where id_tipo_bien=v_parametros.id_tipo_bien;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien',v_parametros.id_tipo_bien::varchar);
              
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
ALTER FUNCTION "kaf"."ft_tipo_bien_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
