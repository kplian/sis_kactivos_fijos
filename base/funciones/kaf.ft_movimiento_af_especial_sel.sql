CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_af_especial_sel"(
	p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_especial_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_af_especial'
 AUTOR: 		 (rchumacero)
 FECHA:	        22-05-2019 21:34:37
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:
#ISSUE				FECHA				AUTOR				DESCRIPCION
 #2				22-05-2019 21:34:37						Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_af_especial'
#
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
 	#TRANSACCION:  'SKA_MOAFES_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		rchumacero
 	#FECHA:		22-05-2019 21:34:37
	***********************************/

	if(p_transaccion = 'SKA_MOAFES_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						moafes.id_movimiento_af_especial,
						moafes.id_activo_fijo,
						moafes.id_activo_fijo_valor,
						moafes.id_movimiento_af,
						moafes.fecha_ini_dep,
						moafes.importe,
						moafes.vida_util,
						moafes.id_clasificacion,
						moafes.id_activo_fijo_creado,
						moafes.estado_reg,
						moafes.id_centro_costo,
						moafes.denominacion,
						moafes.porcentaje,
						moafes.id_usuario_ai,
						moafes.id_usuario_reg,
						moafes.fecha_reg,
						moafes.usuario_ai,
						moafes.id_usuario_mod,
						moafes.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						af.codigo,
						cla.codigo_completo_tmp || '' '' || cla.nombre as clasificacion,
						cc.codigo_cc,
						moafes.tipo,
						af.denominacion as denominacion_af,
						moafes.opcion,
						moafes.id_almacen,
						alm.nombre as desc_almacen
						from kaf.tmovimiento_af_especial moafes
						inner join segu.tusuario usu1 on usu1.id_usuario = moafes.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = moafes.id_usuario_mod
						left join kaf.tactivo_fijo af on af.id_activo_fijo = moafes.id_activo_fijo
						left join kaf.tclasificacion cla on cla.id_clasificacion = moafes.id_clasificacion
						left join pre.vpresupuesto_cc cc on cc.id_centro_costo = moafes.id_centro_costo
						left join alm.talmacen alm ON alm.id_almacen = moafes.id_almacen
				        where  ';

			--Definicion de la respuesta
			v_consulta := v_consulta || v_parametros.filtro;
			v_consulta := v_consulta || ' order by ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MOAFES_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		rchumacero
 	#FECHA:		22-05-2019 21:34:37
	***********************************/

	elsif(p_transaccion = 'SKA_MOAFES_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta := 'select count(id_movimiento_af_especial)
					    from kaf.tmovimiento_af_especial moafes
					    inner join segu.tusuario usu1 on usu1.id_usuario = moafes.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = moafes.id_usuario_mod
						left join kaf.tactivo_fijo af on af.id_activo_fijo = moafes.id_activo_fijo
						left join kaf.tclasificacion cla on cla.id_clasificacion = moafes.id_clasificacion
						left join pre.vpresupuesto_cc cc on cc.id_centro_costo = moafes.id_centro_costo
						left join alm.talmacen alm ON alm.id_almacen = moafes.id_almacen
					    where ';

			--Definicion de la respuesta
			v_consulta := v_consulta || v_parametros.filtro;

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
