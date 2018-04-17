CREATE OR REPLACE FUNCTION "kaf"."ft_grupo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_grupo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tgrupo'
 AUTOR: 		 (admin)
 FECHA:	        17-04-2018 17:35:18
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
#ISSUE				FECHA				AUTOR				DESCRIPCION
 #0				17-04-2018 17:35:18								Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tgrupo'	
 #
 ***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_grupo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_grupo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_GRU_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2018 17:35:18
	***********************************/

	if(p_transaccion='SKA_GRU_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tgrupo(
			nombre,
			estado_reg,
			codigo,
			fecha_reg,
			usuario_ai,
			id_usuario_ai,
			id_usuario_reg,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.nombre,
			'activo',
			v_parametros.codigo,
			now(),
			v_parametros._nombre_usuario_ai,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			null,
			null
							
			
			
			)RETURNING id_grupo into v_id_grupo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Grupo AF almacenado(a) con exito (id_grupo'||v_id_grupo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_grupo',v_id_grupo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_GRU_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2018 17:35:18
	***********************************/

	elsif(p_transaccion='SKA_GRU_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tgrupo set
			nombre = v_parametros.nombre,
			codigo = v_parametros.codigo,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_grupo=v_parametros.id_grupo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Grupo AF modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_grupo',v_parametros.id_grupo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_GRU_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		17-04-2018 17:35:18
	***********************************/

	elsif(p_transaccion='SKA_GRU_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tgrupo
            where id_grupo=v_parametros.id_grupo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Grupo AF eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_grupo',v_parametros.id_grupo::varchar);
              
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
ALTER FUNCTION "kaf"."ft_grupo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
