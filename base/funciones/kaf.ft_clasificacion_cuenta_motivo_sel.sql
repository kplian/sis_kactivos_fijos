CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_cuenta_motivo_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_clasificacion_cuenta_motivo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tclasificacion_cuenta_motivo'
 AUTOR: 		 (admin)
 FECHA:	        15-08-2017 17:28:50
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

	v_nombre_funcion = 'kaf.ft_clasificacion_cuenta_motivo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_CLACUE_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		15-08-2017 17:28:50
	***********************************/

	if(p_transaccion='SKA_CLACUE_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						clacue.id_clasificacion_cuenta_motivo,
						clacue.id_movimiento_motivo,
						clacue.estado_reg,
						clacue.id_clasificacion,
						clacue.id_usuario_ai,
						clacue.id_usuario_reg,
						clacue.usuario_ai,
						clacue.fecha_reg,
						clacue.id_usuario_mod,
						clacue.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cla.codigo_completo_tmp || '' - '' || cla.nombre as desc_clasificacion
						from kaf.tclasificacion_cuenta_motivo clacue
						inner join segu.tusuario usu1 on usu1.id_usuario = clacue.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = clacue.id_usuario_mod
						inner join kaf.tclasificacion cla
						on cla.id_clasificacion = clacue.id_clasificacion
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLACUE_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		15-08-2017 17:28:50
	***********************************/

	elsif(p_transaccion='SKA_CLACUE_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_clasificacion_cuenta_motivo)
					    from kaf.tclasificacion_cuenta_motivo clacue
					    inner join segu.tusuario usu1 on usu1.id_usuario = clacue.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = clacue.id_usuario_mod
						inner join kaf.tclasificacion cla
						on cla.id_clasificacion = clacue.id_clasificacion
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
ALTER FUNCTION "kaf"."ft_clasificacion_cuenta_motivo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
