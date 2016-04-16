CREATE OR REPLACE FUNCTION "kaf"."ft_tipo_bien_cuenta_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_bien_cuenta_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.ttipo_bien_cuenta'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 10:01:08
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
	v_id_tipo_bien_cuenta	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_tipo_bien_cuenta_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_BIECUE_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:01:08
	***********************************/

	if(p_transaccion='SKA_BIECUE_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.ttipo_bien_cuenta(
			id_tipo_cuenta,
			estado_reg,
			id_tipo_bien,
			id_usuario_ai,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_tipo_cuenta,
			'activo',
			v_parametros.id_tipo_bien,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			null,
			null
							
			
			
			)RETURNING id_tipo_bien_cuenta into v_id_tipo_bien_cuenta;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien - Cuenta contable almacenado(a) con exito (id_tipo_bien_cuenta'||v_id_tipo_bien_cuenta||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien_cuenta',v_id_tipo_bien_cuenta::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_BIECUE_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:01:08
	***********************************/

	elsif(p_transaccion='SKA_BIECUE_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.ttipo_bien_cuenta set
			id_tipo_cuenta = v_parametros.id_tipo_cuenta,
			id_tipo_bien = v_parametros.id_tipo_bien,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_tipo_bien_cuenta=v_parametros.id_tipo_bien_cuenta;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien - Cuenta contable modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien_cuenta',v_parametros.id_tipo_bien_cuenta::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_BIECUE_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:01:08
	***********************************/

	elsif(p_transaccion='SKA_BIECUE_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.ttipo_bien_cuenta
            where id_tipo_bien_cuenta=v_parametros.id_tipo_bien_cuenta;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo de Bien - Cuenta contable eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_bien_cuenta',v_parametros.id_tipo_bien_cuenta::varchar);
              
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
ALTER FUNCTION "kaf"."ft_tipo_bien_cuenta_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
