CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo'
 AUTOR: 		 (admin)
 FECHA:	        29-10-2015 03:18:45
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
 	#TRANSACCION:  'SKA_AFIJ_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	if(p_transaccion='SKA_AFIJ_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo(
			id_persona,
			cantidad_revaloriz,
			foto,
			id_proveedor,
			estado_reg,
			fecha_compra,
			monto_vigente,
			id_cat_estado_fun,
			ubicacion,
			vida_util,
			documento,
			observaciones,
			fecha_ult_dep,
			monto_rescate,
			denominacion,
			id_funcionario,
			id_deposito,
			monto_compra,
			id_moneda,
			depreciacion_mes,
			codigo,
			descripcion,
			id_moneda_orig,
			fecha_ini_dep,
			id_cat_estado_compra,
			depreciacion_per,
			vida_util_original,
			depreciacion_acum,
			estado,
			id_clasificacion,
			id_centro_costo,
			id_oficina,
			id_depto,
			id_usuario_reg,
			fecha_reg,
			usuario_ai,
			id_usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.id_persona,
			v_parametros.cantidad_revaloriz,
			v_parametros.foto,
			v_parametros.id_proveedor,
			'activo',
			v_parametros.fecha_compra,
			v_parametros.monto_vigente,
			v_parametros.id_cat_estado_fun,
			v_parametros.ubicacion,
			v_parametros.vida_util,
			v_parametros.documento,
			v_parametros.observaciones,
			v_parametros.fecha_ult_dep,
			v_parametros.monto_rescate,
			v_parametros.denominacion,
			v_parametros.id_funcionario,
			v_parametros.id_deposito,
			v_parametros.monto_compra,
			v_parametros.id_moneda,
			v_parametros.depreciacion_mes,
			v_parametros.codigo,
			v_parametros.descripcion,
			v_parametros.id_moneda_orig,
			v_parametros.fecha_ini_dep,
			v_parametros.id_cat_estado_compra,
			v_parametros.depreciacion_per,
			v_parametros.vida_util_original,
			v_parametros.depreciacion_acum,
			v_parametros.estado,
			v_parametros.id_clasificacion,
			v_parametros.id_centro_costo,
			v_parametros.id_oficina,
			v_parametros.id_depto,
			p_id_usuario,
			now(),
			v_parametros._nombre_usuario_ai,
			v_parametros._id_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_activo_fijo into v_id_activo_fijo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos almacenado(a) con exito (id_activo_fijo'||v_id_activo_fijo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_id_activo_fijo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo set
			id_persona = v_parametros.id_persona,
			cantidad_revaloriz = v_parametros.cantidad_revaloriz,
			foto = v_parametros.foto,
			id_proveedor = v_parametros.id_proveedor,
			fecha_compra = v_parametros.fecha_compra,
			monto_vigente = v_parametros.monto_vigente,
			id_cat_estado_fun = v_parametros.id_cat_estado_fun,
			ubicacion = v_parametros.ubicacion,
			vida_util = v_parametros.vida_util,
			documento = v_parametros.documento,
			observaciones = v_parametros.observaciones,
			fecha_ult_dep = v_parametros.fecha_ult_dep,
			monto_rescate = v_parametros.monto_rescate,
			denominacion = v_parametros.denominacion,
			id_funcionario = v_parametros.id_funcionario,
			id_deposito = v_parametros.id_deposito,
			monto_compra = v_parametros.monto_compra,
			id_moneda = v_parametros.id_moneda,
			depreciacion_mes = v_parametros.depreciacion_mes,
			codigo = v_parametros.codigo,
			descripcion = v_parametros.descripcion,
			id_moneda_orig = v_parametros.id_moneda_orig,
			fecha_ini_dep = v_parametros.fecha_ini_dep,
			id_cat_estado_compra = v_parametros.id_cat_estado_compra,
			depreciacion_per = v_parametros.depreciacion_per,
			vida_util_original = v_parametros.vida_util_original,
			depreciacion_acum = v_parametros.depreciacion_acum,
			estado = v_parametros.estado,
			id_clasificacion = v_parametros.id_clasificacion,
			id_centro_costo = v_parametros.id_centro_costo,
			id_oficina = v_parametros.id_oficina,
			id_depto = v_parametros.id_depto,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_activo_fijo=v_parametros.id_activo_fijo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo
            where id_activo_fijo=v_parametros.id_activo_fijo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos eliminado(a)'); 
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
