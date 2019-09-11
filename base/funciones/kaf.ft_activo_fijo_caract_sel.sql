CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_caract_sel"(
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_caract_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo_caract'
 AUTOR: 		 (admin)
 FECHA:	        17-04-2016 07:14:58
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 		KAF 					17-04-2019  RCM 		Creación
 #18    KAF       ETR           15/07/2019  RCM         Corrección Activo Fijo Característica para la visualización
***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

BEGIN

	v_nombre_funcion = 'kaf.ft_activo_fijo_caract_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_AFCARACT_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	if(p_transaccion='SKA_AFCARACT_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						afcaract.id_activo_fijo_caract,
						afcaract.clave,
						afcaract.valor,
						afcaract.id_activo_fijo,
						afcaract.estado_reg,
						afcaract.id_usuario_ai,
						afcaract.usuario_ai,
						afcaract.fecha_reg,
						afcaract.id_usuario_reg,
						afcaract.fecha_mod,
						afcaract.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						afcaract.id_clasificacion_variable,
						clavar.nombre as nombre_variable,
						clavar.tipo_dato,
						clavar.obligatorio
						from kaf.tactivo_fijo_caract afcaract
						left join kaf.tclasificacion_variable clavar
						on clavar.id_clasificacion_variable = afcaract.id_clasificacion_variable
						inner join segu.tusuario usu1 on usu1.id_usuario = afcaract.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = afcaract.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_AFCARACT_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCARACT_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo_caract)
					    from kaf.tactivo_fijo_caract afcaract
					    left join kaf.tclasificacion_variable clavar
						on clavar.id_clasificacion_variable = afcaract.id_clasificacion_variable
					    inner join segu.tusuario usu1 on usu1.id_usuario = afcaract.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = afcaract.id_usuario_mod
					    where ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_CARALL_SEL'
 	#DESCRIPCION:	Todas las caracteristicas
 	#AUTOR:			RCM
 	#FECHA:			29/04/2016
	***********************************/

	elsif(p_transaccion='SKA_CARALL_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='SELECT DISTINCT cv.nombre --#18
						FROM kaf.tactivo_fijo_caract ac
						INNER JOIN kaf.tclasificacion_variable cv --#18 se añade join
						ON cv.id_clasificacion_variable = ac.id_clasificacion_variable --#18 se añade join
				        WHERE  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' ORDER BY ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_CARALL_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_CARALL_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='SELECT COUNT(DISTINCT cv.nombre)
						FROM kaf.tactivo_fijo_caract ac
						INNER JOIN kaf.tclasificacion_variable cv --#18 se añade join
						ON cv.id_clasificacion_variable = ac.id_clasificacion_variable --#18 se añade join
						WHERE ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	else

		raise exception 'Transaccion inexistente';

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
ALTER FUNCTION "kaf"."ft_activo_fijo_caract_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
