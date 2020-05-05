CREATE OR REPLACE FUNCTION "kaf"."ft_ubicacion_ime" (
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_ubicacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tubicacion'
 AUTOR: 		 (admin)
 FECHA:	        15-06-2018 15:08:40
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           15-06-2018  RCM         Creación del archivo
 #64    KAF       ETR           05-05'2020  RCM         Agregar campo orden que ya está en la base de datos
 ***************************************************************************
 */

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_ubicacion	integer;

BEGIN

    v_nombre_funcion = 'kaf.ft_ubicacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_UBIC_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		15-06-2018 15:08:40
	***********************************/

	if(p_transaccion='SKA_UBIC_INS')then

        begin
        	--Sentencia de la insercion
        	insert into kaf.tubicacion(
			nombre,
			estado_reg,
			codigo,
			id_usuario_ai,
			id_usuario_reg,
			fecha_reg,
			usuario_ai,
			id_usuario_mod,
			fecha_mod,
			orden --#64
          	) values(
			v_parametros.nombre,
			'activo',
			v_parametros.codigo,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			now(),
			v_parametros._nombre_usuario_ai,
			null,
			null,
			v_parametros.orden --#64
			)RETURNING id_ubicacion into v_id_ubicacion;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Locales almacenado(a) con exito (id_ubicacion'||v_id_ubicacion||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_ubicacion',v_id_ubicacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_UBIC_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		15-06-2018 15:08:40
	***********************************/

	elsif(p_transaccion='SKA_UBIC_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tubicacion set
			nombre = v_parametros.nombre,
			codigo = v_parametros.codigo,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			orden = v_parametros.orden --#64
			where id_ubicacion=v_parametros.id_ubicacion;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Locales modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_ubicacion',v_parametros.id_ubicacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_UBIC_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		15-06-2018 15:08:40
	***********************************/

	elsif(p_transaccion='SKA_UBIC_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tubicacion
            where id_ubicacion=v_parametros.id_ubicacion;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Locales eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_ubicacion',v_parametros.id_ubicacion::varchar);

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
ALTER FUNCTION "kaf"."ft_ubicacion_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
