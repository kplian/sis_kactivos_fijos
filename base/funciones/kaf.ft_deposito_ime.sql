CREATE OR REPLACE FUNCTION "kaf"."ft_deposito_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.ft_deposito_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tdeposito'
 AUTOR: 		 (admin)
 FECHA:	        09-11-2015 03:27:12
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
	v_id_deposito	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_deposito_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_DEPAF_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 03:27:12
	***********************************/

	if(p_transaccion='SKA_DEPAF_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tdeposito(
			estado_reg,
			codigo,
			nombre,
			ubicacion,
			id_depto,
			id_funcionario,
			id_oficina,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			'activo',
			v_parametros.codigo,
			v_parametros.nombre,
			v_parametros.ubicacion,
			v_parametros.id_depto,
			v_parametros.id_funcionario,
			v_parametros.id_oficina,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			v_parametros._id_usuario_ai,
			null,
			null
			)RETURNING id_deposito into v_id_deposito;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Depósito almacenado(a) con exito (id_deposito'||v_id_deposito||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_deposito',v_id_deposito::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_DEPAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 03:27:12
	***********************************/

	elsif(p_transaccion='SKA_DEPAF_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tdeposito set
			codigo = v_parametros.codigo,
			nombre = v_parametros.nombre,
			ubicacion = v_parametros.ubicacion,
			id_depto = v_parametros.id_depto,
			id_funcionario = v_parametros.id_funcionario,
			id_oficina = v_parametros.id_oficina,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_deposito=v_parametros.id_deposito;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Depósito modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_deposito',v_parametros.id_deposito::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_DEPAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 03:27:12
	***********************************/

	elsif(p_transaccion='SKA_DEPAF_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tdeposito
            where id_deposito=v_parametros.id_deposito;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Depósito eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_deposito',v_parametros.id_deposito::varchar);
              
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
ALTER FUNCTION "kaf"."ft_deposito_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
