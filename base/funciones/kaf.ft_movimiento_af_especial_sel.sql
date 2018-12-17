CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_af_especial_sel"(
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_especial_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_af_especial'
 AUTOR: 		 (admin)
 FECHA:	        23-06-2017 08:21:47
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

BEGIN

	v_nombre_funcion = 'kaf.ft_movimiento_af_especial_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_MOVESP_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin
 	#FECHA:		23-06-2017 08:21:47
	***********************************/

	if(p_transaccion='SKA_MOVESP_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='with activo_fijo_vigente as (
							select * from kaf.f_activo_fijo_vigente() as
							(
								id_activo_fijo integer,
								monto_vigente_real_af numeric,
								vida_util_real_af integer,
								fecha_ult_dep_real_af date,
								depreciacion_acum_real_af numeric,
								depreciacion_per_real_af numeric,
								monto_actualiz_real_af numeric,
								id_moneda integer,
								id_moneda_dep integer
							)
						)
						select
						movesp.id_movimiento_af_especial,
						movesp.estado_reg,
						movesp.id_activo_fijo,
						movesp.id_activo_fijo_valor,
						movesp.importe,
						movesp.id_movimiento_af,
						movesp.fecha_reg,
						movesp.usuario_ai,
						movesp.id_usuario_reg,
						movesp.id_usuario_ai,
						movesp.id_usuario_mod,
						movesp.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						afv.codigo as codigo_afv,
						afv.tipo as tipo_afv,
						afv.monto_vigente as monto_vigente_real_afv,
						af.codigo,
						af.denominacion,
						COALESCE(round(afvi.monto_vigente_real_af,2), af.monto_compra) as monto_vigente_real
						from kaf.tmovimiento_af_especial movesp
						left join kaf.tactivo_fijo_valores afv
						on afv.id_activo_fijo_valor = movesp.id_activo_fijo_valor
						left join kaf.tactivo_fijo af
						on af.id_activo_fijo = movesp.id_activo_fijo
						left join activo_fijo_vigente afvi
                        on afvi.id_activo_fijo = af.id_activo_fijo
                        and afvi.id_moneda = af.id_moneda
						inner join segu.tusuario usu1 on usu1.id_usuario = movesp.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = movesp.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MOVESP_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		23-06-2017 08:21:47
	***********************************/

	elsif(p_transaccion='SKA_MOVESP_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='with activo_fijo_vigente as (
							select * from kaf.f_activo_fijo_vigente() as
							(
								id_activo_fijo integer,
								monto_vigente_real_af numeric,
								vida_util_real_af integer,
								fecha_ult_dep_real_af date,
								depreciacion_acum_real_af numeric,
								depreciacion_per_real_af numeric,
								monto_actualiz_real_af numeric,
								id_moneda integer,
								id_moneda_dep integer
							)
						)
						select count(id_movimiento_af_especial)
					    from kaf.tmovimiento_af_especial movesp
					    left join kaf.tactivo_fijo_valores afv
						on afv.id_activo_fijo_valor = movesp.id_activo_fijo_valor
						left join kaf.tactivo_fijo af
						on af.id_activo_fijo = movesp.id_activo_fijo
						left join activo_fijo_vigente afvi
                        on afvi.id_activo_fijo = af.id_activo_fijo
                        and afvi.id_moneda = af.id_moneda
					    inner join segu.tusuario usu1 on usu1.id_usuario = movesp.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = movesp.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_movimiento_af_especial_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
