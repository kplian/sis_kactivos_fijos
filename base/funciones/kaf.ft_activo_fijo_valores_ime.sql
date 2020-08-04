CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_valores_ime" (
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_valores_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo_valores'
 AUTOR: 		 (admin)
 FECHA:	        04-05-2016 03:02:26
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 0      KAF       ETR           04/05/2016  admin       Creación del archivo
 #70    KAF       ETR           03/08/2020  RCM         Adición de fecha para TC ini de la primera depreciación'
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_activo_fijo_valor	integer;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_valores_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		04-05-2016 03:02:26
	***********************************/

	if(p_transaccion='SKA_ACTVAL_INS')then

        begin
        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo_valores(
			id_activo_fijo,
			depreciacion_per,
			estado,
			principal,
			monto_vigente,
			monto_rescate,
			tipo_cambio_ini,
			estado_reg,
			tipo,
			depreciacion_mes,
			depreciacion_acum,
			fecha_ult_dep,
			fecha_ini_dep,
			monto_vigente_orig,
			vida_util,
			vida_util_orig,
			id_movimiento_af,
			tipo_cambio_fin,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_ai,
			fecha_mod,
			id_usuario_mod,
			codigo,
			monto_vigente_orig_100,
			fecha_tc_ini_dep --#70
          	) values(
			v_parametros.id_activo_fijo,
			v_parametros.depreciacion_per,
			v_parametros.estado,
			v_parametros.principal,
			v_parametros.monto_vigente,
			v_parametros.monto_rescate,
			v_parametros.tipo_cambio_ini,
			'activo',
			v_parametros.tipo,
			v_parametros.depreciacion_mes,
			v_parametros.depreciacion_acum,
			v_parametros.fecha_ult_dep,
			v_parametros.fecha_ini_dep,
			v_parametros.monto_vigente_orig,
			v_parametros.vida_util,
			v_parametros.vida_util_orig,
			v_parametros.id_movimiento_af,
			v_parametros.tipo_cambio_fin,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			v_parametros._id_usuario_ai,
			null,
			null,
			v_parametros.codigo,
			v_parametros.monto_vigente_orig_100,
			v_parametros.fecha_tc_ini_dep --#70
			) RETURNING id_activo_fijo_valor into v_id_activo_fijo_valor;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Valores Activos Fijos almacenado(a) con exito (id_activo_fijo_valor'||v_id_activo_fijo_valor||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_valor',v_id_activo_fijo_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		04-05-2016 03:02:26
	***********************************/

	elsif(p_transaccion='SKA_ACTVAL_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo_valores set
			id_activo_fijo = v_parametros.id_activo_fijo,
			depreciacion_per = v_parametros.depreciacion_per,
			estado = v_parametros.estado,
			principal = v_parametros.principal,
			monto_vigente = v_parametros.monto_vigente,
			monto_rescate = v_parametros.monto_rescate,
			tipo_cambio_ini = v_parametros.tipo_cambio_ini,
			tipo = v_parametros.tipo,
			depreciacion_mes = v_parametros.depreciacion_mes,
			depreciacion_acum = v_parametros.depreciacion_acum,
			fecha_ult_dep = v_parametros.fecha_ult_dep,
			fecha_ini_dep = v_parametros.fecha_ini_dep,
			monto_vigente_orig = v_parametros.monto_vigente_orig,
			vida_util = v_parametros.vida_util,
			vida_util_orig = v_parametros.vida_util_orig,
			id_movimiento_af = v_parametros.id_movimiento_af,
			tipo_cambio_fin = v_parametros.tipo_cambio_fin,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			codigo = v_parametros.codigo,
			monto_vigente_orig_100 = v_parametros.monto_vigente_orig_100,
			fecha_tc_ini_dep = v_parametros.fecha_tc_ini_dep --#70
			where id_activo_fijo_valor=v_parametros.id_activo_fijo_valor;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Valores Activos Fijos modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_valor',v_parametros.id_activo_fijo_valor::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		04-05-2016 03:02:26
	***********************************/

	elsif(p_transaccion='SKA_ACTVAL_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo_valores
            where id_activo_fijo_valor=v_parametros.id_activo_fijo_valor;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Valores Activos Fijos eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_valor',v_parametros.id_activo_fijo_valor::varchar);

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
ALTER FUNCTION "kaf"."ft_activo_fijo_valores_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
