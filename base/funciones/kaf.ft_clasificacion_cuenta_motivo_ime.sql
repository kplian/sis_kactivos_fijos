CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_cuenta_motivo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_clasificacion_cuenta_motivo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tclasificacion_cuenta_motivo'
 AUTOR: 		 (admin)
 FECHA:	        15-08-2017 17:28:50
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
	v_id_clasificacion_cuenta_motivo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_clasificacion_cuenta_motivo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_CLACUE_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		15-08-2017 17:28:50
	***********************************/

	if(p_transaccion='SKA_CLACUE_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tclasificacion_cuenta_motivo(
			id_movimiento_motivo,
			estado_reg,
			id_clasificacion,
			id_usuario_ai,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_movimiento_motivo,
			'activo',
			v_parametros.id_clasificacion,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			null,
			null
							
			
			
			)RETURNING id_clasificacion_cuenta_motivo into v_id_clasificacion_cuenta_motivo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametrización de Cuentas almacenado(a) con exito (id_clasificacion_cuenta_motivo'||v_id_clasificacion_cuenta_motivo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_cuenta_motivo',v_id_clasificacion_cuenta_motivo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLACUE_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		15-08-2017 17:28:50
	***********************************/

	elsif(p_transaccion='SKA_CLACUE_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tclasificacion_cuenta_motivo set
			id_movimiento_motivo = v_parametros.id_movimiento_motivo,
			id_clasificacion = v_parametros.id_clasificacion,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_clasificacion_cuenta_motivo=v_parametros.id_clasificacion_cuenta_motivo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametrización de Cuentas modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_cuenta_motivo',v_parametros.id_clasificacion_cuenta_motivo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLACUE_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		15-08-2017 17:28:50
	***********************************/

	elsif(p_transaccion='SKA_CLACUE_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tclasificacion_cuenta_motivo
            where id_clasificacion_cuenta_motivo=v_parametros.id_clasificacion_cuenta_motivo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Parametrización de Cuentas eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_cuenta_motivo',v_parametros.id_clasificacion_cuenta_motivo::varchar);
              
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
ALTER FUNCTION "kaf"."ft_clasificacion_cuenta_motivo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
