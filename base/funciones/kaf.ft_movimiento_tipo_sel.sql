CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_tipo_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_tipo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_tipo'
 AUTOR: 		 (admin)
 FECHA:	        23-03-2016 05:18:37
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

	v_nombre_funcion = 'kaf.ft_movimiento_tipo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOVTIP_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		23-03-2016 05:18:37
	***********************************/

	if(p_transaccion='SKA_MOVTIP_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						movtip.id_movimiento_tipo,
						movtip.id_cat_movimiento,
						movtip.estado_reg,
						movtip.id_proceso_macro,
						movtip.fecha_reg,
						movtip.usuario_ai,
						movtip.id_usuario_reg,
						movtip.id_usuario_ai,
						movtip.fecha_mod,
						movtip.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cat.codigo as codigo_tipomov,
						cat.descripcion as desc_tipomov,
						pm.codigo as codigo_pm,
						pm.nombre as nombre_pm,
						movtip.plantilla_cbte_uno,
						movtip.plantilla_cbte_dos,
						movtip.plantilla_cbte_tres
						from kaf.tmovimiento_tipo movtip
						inner join segu.tusuario usu1 on usu1.id_usuario = movtip.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = movtip.id_usuario_mod
						inner join param.tcatalogo cat on cat.id_catalogo = movtip.id_cat_movimiento
						inner join wf.tproceso_macro pm on pm.id_proceso_macro = movtip.id_proceso_macro
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVTIP_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		23-03-2016 05:18:37
	***********************************/

	elsif(p_transaccion='SKA_MOVTIP_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_movimiento_tipo)
					    from kaf.tmovimiento_tipo movtip
					    inner join segu.tusuario usu1 on usu1.id_usuario = movtip.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = movtip.id_usuario_mod
						inner join param.tcatalogo cat on cat.id_catalogo = movtip.id_cat_movimiento
						inner join wf.tproceso_macro pm on pm.id_proceso_macro = movtip.id_proceso_macro
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
ALTER FUNCTION "kaf"."ft_movimiento_tipo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
