--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_valores_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_valores_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo_valores'
 AUTOR: 		 (admin)
 FECHA:	        04-05-2016 03:02:26
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           11/01/2019  RCM         Actualización de archivo con producción. Consultas para obtener últimos valores de la depreciación
 ***************************************************************************/

DECLARE

	v_consulta    		varchar;
	v_parametros  		record;
	v_nombre_funcion   	text;
	v_resp				varchar;

BEGIN

	v_nombre_funcion = 'kaf.ft_activo_fijo_valores_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin
 	#FECHA:		04-05-2016 03:02:26
	***********************************/

	if(p_transaccion='SKA_ACTVAL_SEL')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						actval.id_activo_fijo_valor,
						actval.id_activo_fijo,
						actval.depreciacion_per,
						actval.estado,
						actval.principal,
						actval.monto_vigente,
						actval.monto_rescate,
						actval.tipo_cambio_ini,
						actval.estado_reg,
						actval.tipo,
						actval.depreciacion_mes,
						actval.depreciacion_acum,
						actval.fecha_ult_dep,
						actval.fecha_ini_dep,
						actval.monto_vigente_orig,
						actval.vida_util,
						actval.vida_util_orig,
						actval.id_movimiento_af,
						actval.tipo_cambio_fin,
						actval.usuario_ai,
						actval.fecha_reg,
						actval.id_usuario_reg,
						actval.id_usuario_ai,
						actval.fecha_mod,
						actval.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						actval.codigo,
						actval.fecha_fin,
						actval.monto_vigente_orig_100,
						actval.id_moneda,
						mon.codigo as desc_moneda
						from kaf.tactivo_fijo_valores actval
						inner join segu.tusuario usu1 on usu1.id_usuario = actval.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = actval.id_usuario_mod
						inner join param.tmoneda mon
						on mon.id_moneda = actval.id_moneda
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		04-05-2016 03:02:26
	***********************************/

	elsif(p_transaccion='SKA_ACTVAL_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo_valor)
					    from kaf.tactivo_fijo_valores actval
					    inner join segu.tusuario usu1 on usu1.id_usuario = actval.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = actval.id_usuario_mod
						inner join param.tmoneda mon
						on mon.id_moneda = actval.id_moneda
					    where ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_ACTVAL_ARB'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:			RCM
 	#FECHA:			19/06/2017
	***********************************/

	elsif(p_transaccion='SKA_ACTVAL_ARB')then

    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						actval.id_activo_fijo_valor,
						actval.id_activo_fijo,
						actval.depreciacion_per,
						actval.estado,
						actval.principal,
						actval.monto_vigente,
						actval.monto_rescate,
						actval.tipo_cambio_ini,
						actval.estado_reg,
						actval.tipo,
						actval.depreciacion_mes,
						actval.depreciacion_acum,
						actval.fecha_ult_dep,
						actval.fecha_ini_dep,
						actval.monto_vigente_orig,
						actval.vida_util,
						actval.vida_util_orig,
						actval.id_movimiento_af,
						actval.tipo_cambio_fin,
						actval.usuario_ai,
						actval.fecha_reg,
						actval.id_usuario_reg,
						actval.id_usuario_ai,
						actval.fecha_mod,
						actval.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						actval.codigo,
						actval.fecha_fin,
						''hijo''::varchar as tipo_nodo,
						actval.monto_vigente as monto_vigente_real_afv,
						actval.monto_vigente_orig_100,
						round(mdep.monto_vigente,2) as valor_neto
						from kaf.tactivo_fijo_valores actval
						inner join kaf.tmovimiento_af_dep mdep
						on mdep.id_activo_fijo_valor = actval.id_activo_fijo_valor
						and mdep.id_moneda = actval.id_moneda
						inner join segu.tusuario usu1 on usu1.id_usuario = actval.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = actval.id_usuario_mod
				        where  ';

			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;

		end;

	--Inicio #2: consultas para obtener los últimos valores de depreciación
	/*********************************
    #TRANSACCION:  'SKA_AFULTDEP_SEL'
    #DESCRIPCION:   Consulta de datos del último valor de la depreciación de los afv
    #AUTOR:         RCM
    #FECHA:         17/01/2019
    ***********************************/

    elsif(p_transaccion='SKA_AFULTDEP_SEL')then

        begin
            --Sentencia de la consulta
            v_consulta:='select
                        dep.id_activo_fijo,
                        dep.id_activo_fijo_valor,
                        dep.codigo,
                        dep.fecha_max,
                        dep.id_moneda,
                        dep.valor_vigente_actualiz,
                        dep.inc_actualiz,
                        dep.valor_actualiz,
                        dep.vida_util_ant,
                        dep.dep_acum_ant,
                        dep.inc_actualiz_dep_acum,
                        dep.dep_acum_ant_actualiz,
                        dep.dep_mes,
                        dep.dep_periodo,
                        dep.dep_acum,
                        dep.valor_neto
                        from kaf.vafv_deprec_ultimo dep
                        where ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;


        end;

    /*********************************
    #TRANSACCION:  'SKA_AFULTDEP_CONT'
    #DESCRIPCION:   Conteo de registros de datos del último valor de la depreciación de los afv
    #AUTOR:         RCM
    #FECHA:         17/01/2019
    ***********************************/

    elsif(p_transaccion='SKA_AFULTDEP_CONT')then

        begin

            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(1)
                        from kaf.vafv_deprec_ultimo dep
                        where  ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_AFULTVAL_SEL'
    #DESCRIPCION:   Obtiene el valor total del activo fijo (sumando los valores de los afv vigentes) a la fecha max de depreciación de todo el activo fijo
    #AUTOR:         RCM
    #FECHA:         23/01/2019
    ***********************************/
    elsif(p_transaccion = 'SKA_AFULTVAL_SEL') then

        begin
            --Sentencia de la consulta
            v_consulta = '
            			WITH tult_dep AS (
						  SELECT
						  afv.id_activo_fijo,
						  MAX(mdep.fecha) AS fecha_max
						  FROM kaf.tmovimiento_af_dep mdep
						  INNER JOIN kaf.tactivo_fijo_valores afv
						  ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
						  GROUP BY afv.id_activo_fijo
						)
						SELECT
						afv.id_activo_fijo,
						afv.codigo,
						dult.fecha_max,
						mdep.id_moneda,
						mdep.vida_util_ant,
						ROUND(SUM(mdep.depreciacion_per), 2) AS dep_periodo,
						ROUND(SUM(mdep.depreciacion_acum), 2) AS dep_acum,
						ROUND(SUM(mdep.monto_vigente), 2) AS valor_neto
						FROM kaf.tactivo_fijo_valores  afv
						INNER JOIN tult_dep dult
						ON dult.id_activo_fijo = afv.id_activo_fijo
						INNER JOIN kaf.tmovimiento_af_dep mdep
						ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
						AND mdep.fecha = dult.fecha_max
						WHERE ';

            --Definicion de la respuesta
            v_consulta = v_consulta || v_parametros.filtro;
            v_consulta = v_consulta || ' GROUP BY afv.id_activo_fijo, afv.codigo, dult.fecha_max, mdep.id_moneda, mdep.vida_util_ant';

            --Devuelve la respuesta
            return v_consulta;


        end;
        --Fin #2

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
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;