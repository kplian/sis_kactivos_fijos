CREATE OR REPLACE FUNCTION "kaf"."ft_deposito_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.ft_deposito_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tdeposito'
 AUTOR: 		 (admin)
 FECHA:	        09-11-2015 03:27:12
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

	v_nombre_funcion = 'kaf.ft_deposito_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_DEPAF_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 03:27:12
	***********************************/

	if(p_transaccion='SKA_DEPAF_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						depaf.id_deposito,
						depaf.estado_reg,
						depaf.codigo,
						depaf.nombre,
						depaf.id_depto,
						depaf.id_funcionario,
						depaf.id_oficina,
						depaf.ubicacion,
						depaf.id_usuario_reg,
						depaf.usuario_ai,
						depaf.fecha_reg,
						depaf.id_usuario_ai,
						depaf.id_usuario_mod,
						depaf.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						dep.codigo as depto_cod,
						dep.nombre as depto,
						fun.desc_funcionario2 as funcionario,
						ofi.codigo as oficina_cod,
						ofi.nombre as oficina
						from kaf.tdeposito depaf
						inner join segu.tusuario usu1 on usu1.id_usuario = depaf.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = depaf.id_usuario_mod
						inner join param.tdepto dep on dep.id_depto = depaf.id_depto
						inner join orga.vfuncionario fun on fun.id_funcionario = depaf.id_funcionario
						inner join orga.toficina ofi on ofi.id_oficina = depaf.id_oficina
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_DEPAF_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 03:27:12
	***********************************/

	elsif(p_transaccion='SKA_DEPAF_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_deposito)
					    from kaf.tdeposito depaf
					    inner join segu.tusuario usu1 on usu1.id_usuario = depaf.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = depaf.id_usuario_mod
						inner join param.tdepto dep on dep.id_depto = depaf.id_depto
						inner join orga.vfuncionario fun on fun.id_funcionario = depaf.id_funcionario
						inner join orga.toficina ofi on ofi.id_oficina = depaf.id_oficina
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
ALTER FUNCTION "kaf"."ft_deposito_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
