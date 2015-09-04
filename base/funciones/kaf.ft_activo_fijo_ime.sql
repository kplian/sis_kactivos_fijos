CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo'
 AUTOR: 		 (admin)
 FECHA:	        04-09-2015 03:11:50
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
	v_id_activo_fijo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_ACTIVO_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		04-09-2015 03:11:50
	***********************************/

	if(p_transaccion='SKA_ACTIVO_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo(
			id_clasificacion,
			id_centro_costo,
			monto_compra_mon_orig,
			id_persona,
			monto_compra,
			fecha_ini_dep,
			depreciacion_acum,
			documento,
			monto_vigente,
			observaciones,
			descripcion,
			id_depto,
			estado_reg,
			vida_util_restante,
			id_funcionario,
			denominacion,
			id_cat_estado_fun,
			id_moneda,
			id_moneda_orig,
			depreciacion_acum_ant,
			codigo,
			foto,
			monto_actualiz,
			estado,
			vida_util,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_ai,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.id_clasificacion,
			v_parametros.id_centro_costo,
			v_parametros.monto_compra_mon_orig,
			v_parametros.id_persona,
			v_parametros.monto_compra,
			v_parametros.fecha_ini_dep,
			v_parametros.depreciacion_acum,
			v_parametros.documento,
			v_parametros.monto_vigente,
			v_parametros.observaciones,
			v_parametros.descripcion,
			v_parametros.id_depto,
			'activo',
			v_parametros.vida_util_restante,
			v_parametros.id_funcionario,
			v_parametros.denominacion,
			v_parametros.id_cat_estado_fun,
			v_parametros.id_moneda,
			v_parametros.id_moneda_orig,
			v_parametros.depreciacion_acum_ant,
			v_parametros.codigo,
			v_parametros.foto,
			v_parametros.monto_actualiz,
			v_parametros.estado,
			v_parametros.vida_util,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			v_parametros._id_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_activo_fijo into v_id_activo_fijo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activo Fijo almacenado(a) con exito (id_activo_fijo'||v_id_activo_fijo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_id_activo_fijo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_ACTIVO_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		04-09-2015 03:11:50
	***********************************/

	elsif(p_transaccion='SKA_ACTIVO_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo set
			id_clasificacion = v_parametros.id_clasificacion,
			id_centro_costo = v_parametros.id_centro_costo,
			monto_compra_mon_orig = v_parametros.monto_compra_mon_orig,
			id_persona = v_parametros.id_persona,
			monto_compra = v_parametros.monto_compra,
			fecha_ini_dep = v_parametros.fecha_ini_dep,
			depreciacion_acum = v_parametros.depreciacion_acum,
			documento = v_parametros.documento,
			monto_vigente = v_parametros.monto_vigente,
			observaciones = v_parametros.observaciones,
			descripcion = v_parametros.descripcion,
			id_depto = v_parametros.id_depto,
			vida_util_restante = v_parametros.vida_util_restante,
			id_funcionario = v_parametros.id_funcionario,
			denominacion = v_parametros.denominacion,
			id_cat_estado_fun = v_parametros.id_cat_estado_fun,
			id_moneda = v_parametros.id_moneda,
			id_moneda_orig = v_parametros.id_moneda_orig,
			depreciacion_acum_ant = v_parametros.depreciacion_acum_ant,
			codigo = v_parametros.codigo,
			foto = v_parametros.foto,
			monto_actualiz = v_parametros.monto_actualiz,
			estado = v_parametros.estado,
			vida_util = v_parametros.vida_util,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_activo_fijo=v_parametros.id_activo_fijo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activo Fijo modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_ACTIVO_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		04-09-2015 03:11:50
	***********************************/

	elsif(p_transaccion='SKA_ACTIVO_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo
            where id_activo_fijo=v_parametros.id_activo_fijo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activo Fijo eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
              
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
ALTER FUNCTION "kaf"."ft_activo_fijo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
