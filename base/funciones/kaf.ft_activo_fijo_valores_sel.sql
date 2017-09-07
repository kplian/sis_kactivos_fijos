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
						actval.fecha_fin
						from kaf.tactivo_fijo_valores actval
						inner join segu.tusuario usu1 on usu1.id_usuario = actval.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = actval.id_usuario_mod
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
						actval.monto_vigente as monto_vigente_real_afv
						from kaf.tactivo_fijo_valores actval
						inner join segu.tusuario usu1 on usu1.id_usuario = actval.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = actval.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

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
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;