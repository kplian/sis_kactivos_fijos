CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_variable_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_clasificacion_variable_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tclasificacion_variable'
 AUTOR: 		 (admin)
 FECHA:	        27-06-2017 09:34:29
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

	v_nombre_funcion = 'kaf.ft_clasificacion_variable_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_CLAVAR_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		27-06-2017 09:34:29
	***********************************/

	if(p_transaccion='SKA_CLAVAR_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						clavar.id_clasificacion_variable,
						clavar.id_clasificacion,
						clavar.nombre,
						clavar.tipo_dato,
						clavar.descripcion,
						clavar.estado_reg,
						clavar.obligatorio,
						clavar.orden_var,
						clavar.id_usuario_ai,
						clavar.usuario_ai,
						clavar.fecha_reg,
						clavar.id_usuario_reg,
						clavar.id_usuario_mod,
						clavar.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from kaf.tclasificacion_variable clavar
						inner join segu.tusuario usu1 on usu1.id_usuario = clavar.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = clavar.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAVAR_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		27-06-2017 09:34:29
	***********************************/

	elsif(p_transaccion='SKA_CLAVAR_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_clasificacion_variable)
					    from kaf.tclasificacion_variable clavar
					    inner join segu.tusuario usu1 on usu1.id_usuario = clavar.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = clavar.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_clasificacion_variable_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
