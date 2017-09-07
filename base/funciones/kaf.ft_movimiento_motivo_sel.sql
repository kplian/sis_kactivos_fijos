CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_motivo_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_motivo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_motivo'
 AUTOR: 		 (admin)
 FECHA:	        18-03-2016 07:25:59
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

	v_nombre_funcion = 'kaf.ft_movimiento_motivo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MMOT_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 07:25:59
	***********************************/

	if(p_transaccion='SKA_MMOT_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						mmot.id_movimiento_motivo,
						mmot.id_cat_movimiento,
						mmot.motivo,
						mmot.estado_reg,
						mmot.id_usuario_ai,
						mmot.usuario_ai,
						mmot.fecha_reg,
						mmot.id_usuario_reg,
						mmot.id_usuario_mod,
						mmot.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cat.descripcion as movimiento,
						mmot.plantilla_cbte
						from kaf.tmovimiento_motivo mmot
						inner join segu.tusuario usu1 on usu1.id_usuario = mmot.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mmot.id_usuario_mod
						inner join param.tcatalogo cat on cat.id_catalogo = mmot.id_cat_movimiento
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MMOT_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin
 	#FECHA:		18-03-2016 07:25:59
	***********************************/

	elsif(p_transaccion='SKA_MMOT_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_movimiento_motivo)
					    from kaf.tmovimiento_motivo mmot
					    inner join segu.tusuario usu1 on usu1.id_usuario = mmot.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mmot.id_usuario_mod
						inner join param.tcatalogo cat on cat.id_catalogo = mmot.id_cat_movimiento
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
ALTER FUNCTION "kaf"."ft_movimiento_motivo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
