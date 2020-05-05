CREATE OR REPLACE FUNCTION "kaf"."ft_ubicacion_sel"(
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_ubicacion_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tubicacion'
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

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

BEGIN

	v_nombre_funcion = 'kaf.ft_ubicacion_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_UBIC_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin
 	#FECHA:		15-06-2018 15:08:40
	***********************************/

	if(p_transaccion='SKA_UBIC_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						ubic.id_ubicacion,
						ubic.nombre,
						ubic.estado_reg,
						ubic.codigo,
						ubic.id_usuario_ai,
						ubic.id_usuario_reg,
						ubic.fecha_reg,
						ubic.usuario_ai,
						ubic.id_usuario_mod,
						ubic.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						ubic.orden --#64
						from kaf.tubicacion ubic
						inner join segu.tusuario usu1 on usu1.id_usuario = ubic.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = ubic.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_UBIC_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		15-06-2018 15:08:40
	***********************************/

	elsif(p_transaccion='SKA_UBIC_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_ubicacion)
					    from kaf.tubicacion ubic
					    inner join segu.tusuario usu1 on usu1.id_usuario = ubic.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = ubic.id_usuario_mod
					    where ';

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
ALTER FUNCTION "kaf"."ft_ubicacion_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
