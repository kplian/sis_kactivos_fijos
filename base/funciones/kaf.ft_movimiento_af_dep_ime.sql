CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_af_dep_ime" (
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_dep_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_dep'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 08:14:17
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           16/04/2016  RCM         Creación del archivo
 #35    KAF       ETR           14/10/2019  RCM         Procesamiento del detalle depreciación
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_movimiento_af_dep	integer;
	v_fecha_hasta 			date;
	v_id_moneda_dep 		integer;
	v_result 				varchar;
	v_total					integer;--#35
	v_existe				varchar;--#35
	v_fecha_reg 			date; --#35

BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_af_dep_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_MAFDEP_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		16-04-2016 08:14:17
	***********************************/

	if(p_transaccion='SKA_MAFDEP_INS')then

        begin
        	--Sentencia de la insercion
        	insert into kaf.tmovimiento_af_dep(
			vida_util,
			tipo_cambio_ini,
			depreciacion_per_actualiz,
			id_movimiento_af,
			vida_util_ant,
			estado_reg,
			monto_vigente,
			monto_vigente_ant,
			depreciacion_acum_actualiz,
			tipo_cambio_fin,
			depreciacion_acum,
			id_activo_fijo_valor,
			factor,
			depreciacion_per,
			depreciacion,
			id_moneda,
			depreciacion_per_ant,
			monto_actualiz,
			depreciacion_acum_ant,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_ai,
			fecha_mod,
			id_usuario_mod
          	) values(
			v_parametros.vida_util,
			v_parametros.tipo_cambio_ini,
			v_parametros.depreciacion_per_actualiz,
			v_parametros.id_movimiento_af,
			v_parametros.vida_util_ant,
			'activo',
			v_parametros.monto_vigente,
			v_parametros.monto_vigente_ant,
			v_parametros.depreciacion_acum_actualiz,
			v_parametros.tipo_cambio_fin,
			v_parametros.depreciacion_acum,
			v_parametros.id_activo_fijo_valor,
			v_parametros.factor,
			v_parametros.depreciacion_per,
			v_parametros.depreciacion,
			v_parametros.id_moneda,
			v_parametros.depreciacion_per_ant,
			v_parametros.monto_actualiz,
			v_parametros.depreciacion_acum_ant,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			v_parametros._id_usuario_ai,
			null,
			null



			)RETURNING id_movimiento_af_dep into v_id_movimiento_af_dep;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle de Depreciacion almacenado(a) con exito (id_movimiento_af_dep'||v_id_movimiento_af_dep||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_dep',v_id_movimiento_af_dep::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MAFDEP_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		16-04-2016 08:14:17
	***********************************/

	elsif(p_transaccion='SKA_MAFDEP_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tmovimiento_af_dep set
			vida_util = v_parametros.vida_util,
			tipo_cambio_ini = v_parametros.tipo_cambio_ini,
			depreciacion_per_actualiz = v_parametros.depreciacion_per_actualiz,
			id_movimiento_af = v_parametros.id_movimiento_af,
			vida_util_ant = v_parametros.vida_util_ant,
			monto_vigente = v_parametros.monto_vigente,
			monto_vigente_ant = v_parametros.monto_vigente_ant,
			depreciacion_acum_actualiz = v_parametros.depreciacion_acum_actualiz,
			tipo_cambio_fin = v_parametros.tipo_cambio_fin,
			depreciacion_acum = v_parametros.depreciacion_acum,
			id_activo_fijo_valor = v_parametros.id_activo_fijo_valor,
			factor = v_parametros.factor,
			depreciacion_per = v_parametros.depreciacion_per,
			depreciacion = v_parametros.depreciacion,
			id_moneda = v_parametros.id_moneda,
			depreciacion_per_ant = v_parametros.depreciacion_per_ant,
			monto_actualiz = v_parametros.monto_actualiz,
			depreciacion_acum_ant = v_parametros.depreciacion_acum_ant,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_movimiento_af_dep=v_parametros.id_movimiento_af_dep;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle de Depreciacion modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_dep',v_parametros.id_movimiento_af_dep::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MAFDEP_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		16-04-2016 08:14:17
	***********************************/

	elsif(p_transaccion='SKA_MAFDEP_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af_dep
            where id_movimiento_af_dep=v_parametros.id_movimiento_af_dep;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle de Depreciacion eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_dep',v_parametros.id_movimiento_af_dep::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	--Inicio #35
	/*********************************
 	#TRANSACCION:  'SKA_PRODETDEP_INS'
 	#DESCRIPCION:	Procesa el detalle depreciación
 	#AUTOR:			RCM
 	#FECHA:			14/10/2019
	***********************************/
	ELSIF(p_transaccion = 'SKA_PRODETDEP_INS') THEN

		BEGIN

			--Obtención de la fecha
			SELECT fecha_hasta
			INTO v_fecha_hasta
			FROM kaf.tmovimiento
			WHERE id_movimiento = v_parametros.id_movimiento;

			--Obtención de la moneda de depreciación
			SELECT id_moneda_dep
			INTO v_id_moneda_dep
			FROM kaf.tmoneda_dep
			WHERE id_moneda = param.f_get_moneda_base();

			--Ejecuta el proceso de detalle de depreciación
			v_result = kaf.f_procesa_detalle_depreciacion
						(
						 	p_id_usuario,
						  	v_fecha_hasta,
						  	v_id_moneda_dep
						);

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Procesamiento detalle depreciación realizado con éxito');
            v_resp = pxp.f_agrega_clave(v_resp, 'respuesta', v_result);

            --Devuelve la respuesta
            RETURN v_resp;

		END;

	/*********************************
 	#TRANSACCION:  'SKA_PRODETDEP_VER'
 	#DESCRIPCION:	Verificar Procesa el detalle depreciación
 	#AUTOR:			RCM
 	#FECHA:			14/10/2019
	***********************************/
	ELSIF(p_transaccion = 'SKA_PRODETDEP_VER') THEN

		BEGIN

			--Obtención de la fecha
			SELECT fecha_hasta
			INTO v_fecha_hasta
			FROM kaf.tmovimiento
			WHERE id_movimiento = v_parametros.id_movimiento;

			--Ejecuta el proceso de detalle de depreciación
			SELECT COUNT(1)
			INTO v_total
			FROM kaf.treporte_detalle_dep
			WHERE id_moneda = param.f_get_moneda_base()
			AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', v_fecha_hasta);

			IF COALESCE(v_total, 0) > 0 THEN
				v_existe = 'si';

				--Obtiene la fecha en que se procesó la información (fecha_reg)
				SELECT fecha_reg
				INTO v_fecha_reg
				FROM kaf.treporte_detalle_dep
				WHERE id_moneda = param.f_get_moneda_base()
				AND DATE_TRUNC('month', fecha) = DATE_TRUNC('month', v_fecha_hasta)
				LIMIT 1;
			ELSE
				v_existe = 'no';
			END IF;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Verificación realizada');
            v_resp = pxp.f_agrega_clave(v_resp, 'existe', v_existe);
            v_resp = pxp.f_agrega_clave(v_resp, 'fecha_proc', to_char(v_fecha_reg, 'dd/mm/yyyy'));

            --Devuelve la respuesta
            RETURN v_resp;

		END;
	--Fin #35

	ELSE

    	RAISE EXCEPTION 'Transaccion inexistente: %', p_transaccion;

	END IF;

EXCEPTION

	WHEN OTHERS THEN

		v_resp = '';
		v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);

		RAISE EXCEPTION '%', v_resp;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_movimiento_af_dep_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
