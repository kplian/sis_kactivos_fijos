CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo'
 AUTOR: 		 (admin)
 FECHA:	        04-09-2015 03:11:50
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

	v_nombre_funcion = 'kaf.ft_activo_fijo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_ACTIVO_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		04-09-2015 03:11:50
	***********************************/

	if(p_transaccion='SKA_ACTIVO_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						activo.id_activo_fijo,
						activo.id_clasificacion,
						activo.id_centro_costo,
						activo.monto_compra_mon_orig,
						activo.id_persona,
						activo.monto_compra,
						activo.fecha_ini_dep,
						activo.depreciacion_acum,
						activo.documento,
						activo.monto_vigente,
						activo.observaciones,
						activo.descripcion,
						activo.id_depto,
						activo.estado_reg,
						activo.vida_util_restante,
						activo.id_funcionario,
						activo.denominacion,
						activo.id_cat_estado_fun,
						activo.id_moneda,
						activo.id_moneda_orig,
						activo.depreciacion_acum_ant,
						activo.codigo,
						activo.foto,
						activo.monto_actualiz,
						activo.estado,
						activo.vida_util,
						activo.usuario_ai,
						activo.fecha_reg,
						activo.id_usuario_reg,
						activo.id_usuario_ai,
						activo.fecha_mod,
						activo.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from kaf.tactivo_fijo activo
						inner join segu.tusuario usu1 on usu1.id_usuario = activo.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = activo.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_ACTIVO_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		04-09-2015 03:11:50
	***********************************/

	elsif(p_transaccion='SKA_ACTIVO_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo)
					    from kaf.tactivo_fijo activo
					    inner join segu.tusuario usu1 on usu1.id_usuario = activo.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = activo.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_activo_fijo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
