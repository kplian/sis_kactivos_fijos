CREATE OR REPLACE FUNCTION "kaf"."ft_tipo_bien_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_bien_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.ttipo_bien'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 10:00:40
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

	v_nombre_funcion = 'kaf.ft_tipo_bien_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_TIPBIE_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:00:40
	***********************************/

	if(p_transaccion='SKA_TIPBIE_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						tipbie.id_tipo_bien,
						tipbie.descripcion,
						tipbie.estado_reg,
						tipbie.codigo,
						tipbie.id_usuario_ai,
						tipbie.id_usuario_reg,
						tipbie.usuario_ai,
						tipbie.fecha_reg,
						tipbie.id_usuario_mod,
						tipbie.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from kaf.ttipo_bien tipbie
						inner join segu.tusuario usu1 on usu1.id_usuario = tipbie.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = tipbie.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPBIE_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:00:40
	***********************************/

	elsif(p_transaccion='SKA_TIPBIE_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_tipo_bien)
					    from kaf.ttipo_bien tipbie
					    inner join segu.tusuario usu1 on usu1.id_usuario = tipbie.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = tipbie.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_tipo_bien_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
