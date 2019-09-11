CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_variable_ime" (
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_clasificacion_variable_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tclasificacion_variable'
 AUTOR: 		 (admin)
 FECHA:	        27-06-2017 09:34:29
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #18    KAF       ETR           15/07/2019  RCM         Inclusión de expresión regular como máscara para validación
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_clasificacion_variable	integer;

BEGIN

    v_nombre_funcion = 'kaf.ft_clasificacion_variable_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_CLAVAR_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		27-06-2017 09:34:29
	***********************************/

	if(p_transaccion='SKA_CLAVAR_INS')then

        begin
        	--Sentencia de la insercion
        	insert into kaf.tclasificacion_variable(
			id_clasificacion,
			nombre,
			tipo_dato,
			descripcion,
			estado_reg,
			obligatorio,
			orden_var,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod,
			regex, --#18: se agrega columna
			regex_ejemplo --#18: se agrega columna
          	) values(
			v_parametros.id_clasificacion,
			v_parametros.nombre,
			v_parametros.tipo_dato,
			v_parametros.descripcion,
			'activo',
			v_parametros.obligatorio,
			v_parametros.orden_var,
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null,
			v_parametros.regex, --#18: se agrega columna
			v_parametros.regex_ejemplo --#18: se agrega columna
			)RETURNING id_clasificacion_variable into v_id_clasificacion_variable;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Variables almacenado(a) con exito (id_clasificacion_variable'||v_id_clasificacion_variable||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_variable',v_id_clasificacion_variable::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_CLAVAR_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		27-06-2017 09:34:29
	***********************************/

	elsif(p_transaccion='SKA_CLAVAR_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tclasificacion_variable set
			id_clasificacion = v_parametros.id_clasificacion,
			nombre = v_parametros.nombre,
			tipo_dato = v_parametros.tipo_dato,
			descripcion = v_parametros.descripcion,
			obligatorio = v_parametros.obligatorio,
			orden_var = v_parametros.orden_var,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			regex = v_parametros.regex, --#18: se agrega columna
			regex_ejemplo = v_parametros.regex_ejemplo --#18: se agrega columna
			where id_clasificacion_variable=v_parametros.id_clasificacion_variable;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Variables modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_variable',v_parametros.id_clasificacion_variable::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_CLAVAR_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		27-06-2017 09:34:29
	***********************************/

	elsif(p_transaccion='SKA_CLAVAR_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tclasificacion_variable
            where id_clasificacion_variable=v_parametros.id_clasificacion_variable;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Variables eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion_variable',v_parametros.id_clasificacion_variable::varchar);

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
ALTER FUNCTION "kaf"."ft_clasificacion_variable_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
