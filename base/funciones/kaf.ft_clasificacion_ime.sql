CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.ft_clasificacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tclasificacion'
 AUTOR: 		 (admin)
 FECHA:	        09-11-2015 01:22:17
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
	v_id_clasificacion	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_clasificacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	if(p_transaccion='SKA_CLAF_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tclasificacion(
			descripcion,
			codigo,
			nombre,
			final,
			nombre,
			estado_reg,
			id_cat_metodo_dep,
			codigo,
			tipo,
			id_concepto_ingas,
			monto_residual,
			codigo_largo,
			estado_reg,
			icono,
			activo_fijo,
			id_clasificacion_fk,
			vida_util,
			correlativo_act,
			id_clasificacion_fk,
			estado,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			id_usuario_mod,
			fecha_mod,
			fecha_mod
          	) values(
			v_parametros.descripcion,
			v_parametros.codigo,
			v_parametros.nombre,
			v_parametros.final,
			v_parametros.nombre,
			'activo',
			v_parametros.id_cat_metodo_dep,
			v_parametros.codigo,
			v_parametros.tipo,
			v_parametros.id_concepto_ingas,
			v_parametros.monto_residual,
			v_parametros.codigo_largo,
			'activo',
			v_parametros.icono,
			v_parametros.activo_fijo,
			v_parametros.id_clasificacion_fk,
			v_parametros.vida_util,
			v_parametros.correlativo_act,
			v_parametros.id_clasificacion_fk,
			v_parametros.estado,
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null,
			null,
			null
							
			
			
			)RETURNING id_clasificacion into v_id_clasificacion;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación almacenado(a) con exito (id_clasificacion'||v_id_clasificacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_id_clasificacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAF_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tclasificacion set
			descripcion = v_parametros.descripcion,
			codigo = v_parametros.codigo,
			nombre = v_parametros.nombre,
			final = v_parametros.final,
			nombre = v_parametros.nombre,
			id_cat_metodo_dep = v_parametros.id_cat_metodo_dep,
			codigo = v_parametros.codigo,
			tipo = v_parametros.tipo,
			id_concepto_ingas = v_parametros.id_concepto_ingas,
			monto_residual = v_parametros.monto_residual,
			codigo_largo = v_parametros.codigo_largo,
			icono = v_parametros.icono,
			activo_fijo = v_parametros.activo_fijo,
			id_clasificacion_fk = v_parametros.id_clasificacion_fk,
			vida_util = v_parametros.vida_util,
			correlativo_act = v_parametros.correlativo_act,
			id_clasificacion_fk = v_parametros.id_clasificacion_fk,
			estado = v_parametros.estado,
			id_usuario_mod = p_id_usuario,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_clasificacion=v_parametros.id_clasificacion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAF_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tclasificacion
            where id_clasificacion=v_parametros.id_clasificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
              
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
ALTER FUNCTION "kaf"."ft_clasificacion_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
