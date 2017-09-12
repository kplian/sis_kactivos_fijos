CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_modificacion_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_modificacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo_modificacion'
 AUTOR: 		 (admin)
 FECHA:	        23-08-2017 14:14:25
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
	v_id_activo_fijo_modificacion	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_modificacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	if(p_transaccion='SKA_KAFMOD_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo_modificacion(
			id_activo_fijo,
			id_oficina,
			id_oficina_ant,
			ubicacion,
			estado_reg,
			ubicacion_ant,
			observaciones,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_activo_fijo,
			v_parametros.id_oficina,
			v_parametros.id_oficina_ant,
			v_parametros.ubicacion,
			'activo',
			v_parametros.ubicacion_ant,
			v_parametros.observaciones,
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null
			)RETURNING id_activo_fijo_modificacion into v_id_activo_fijo_modificacion;

			--Actualiza la ubicación del activo fijo si corresponde
			if v_parametros.id_oficina is not null then
				update kaf.tactivo_fijo set
				id_oficina = v_parametros.id_oficina,
				ubicacion = v_parametros.ubicacion
				where id_activo_fijo = v_parametros.id_activo_fijo;
			end if;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones almacenado(a) con exito (id_activo_fijo_modificacion'||v_id_activo_fijo_modificacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_id_activo_fijo_modificacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	elsif(p_transaccion='SKA_KAFMOD_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo_modificacion set
			id_activo_fijo = v_parametros.id_activo_fijo,
			id_oficina = v_parametros.id_oficina,
			id_oficina_ant = v_parametros.id_oficina_ant,
			ubicacion = v_parametros.ubicacion,
			ubicacion_ant = v_parametros.ubicacion_ant,
			observaciones = v_parametros.observaciones,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_activo_fijo_modificacion=v_parametros.id_activo_fijo_modificacion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_parametros.id_activo_fijo_modificacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	elsif(p_transaccion='SKA_KAFMOD_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo_modificacion
            where id_activo_fijo_modificacion=v_parametros.id_activo_fijo_modificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_parametros.id_activo_fijo_modificacion::varchar);
              
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
ALTER FUNCTION "kaf"."ft_activo_fijo_modificacion_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
