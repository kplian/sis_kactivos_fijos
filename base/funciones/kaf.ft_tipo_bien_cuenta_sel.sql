CREATE OR REPLACE FUNCTION "kaf"."ft_tipo_bien_cuenta_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_bien_cuenta_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.ttipo_bien_cuenta'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 10:01:08
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

	v_nombre_funcion = 'kaf.ft_tipo_bien_cuenta_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_BIECUE_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:01:08
	***********************************/

	if(p_transaccion='SKA_BIECUE_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						biecue.id_tipo_bien_cuenta,
						biecue.id_tipo_cuenta,
						biecue.estado_reg,
						biecue.id_tipo_bien,
						biecue.id_usuario_ai,
						biecue.id_usuario_reg,
						biecue.usuario_ai,
						biecue.fecha_reg,
						biecue.id_usuario_mod,
						biecue.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						tipcue.codigo as codigo_cuenta,
						tipcue.descripcion as desc_cuenta,
						tipcue.codigo_corto as codigo_corto_cuenta
						from kaf.ttipo_bien_cuenta biecue
						inner join kaf.ttipo_cuenta tipcue on tipcue.id_tipo_cuenta = biecue.id_tipo_cuenta
						inner join segu.tusuario usu1 on usu1.id_usuario = biecue.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = biecue.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_BIECUE_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 10:01:08
	***********************************/

	elsif(p_transaccion='SKA_BIECUE_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_tipo_bien_cuenta)
					    from kaf.ttipo_bien_cuenta biecue
						inner join kaf.ttipo_cuenta tipcue on tipcue.id_tipo_cuenta = biecue.id_tipo_cuenta
						inner join segu.tusuario usu1 on usu1.id_usuario = biecue.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = biecue.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_tipo_bien_cuenta_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
