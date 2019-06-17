CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_cc_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_cc_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo_caract'
 AUTOR: 		 (admin)
 FECHA:	        10-05-2019 11:14:58
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

	v_nombre_funcion = 'kaf.ft_activo_fijo_cc_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_AFCARACT_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		17-04-2016 07:14:58
	***********************************/

	if(p_transaccion='SKA_AFCCOSTO_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						afccosto.id_activo_fijo_cc,
                        afccosto.id_activo_fijo,
                        afccosto.id_centro_costo,
                        afccosto.mes,
                        afccosto.cantidad_horas,
                        afccosto.id_usuario_reg,
                        afccosto.estado_reg,
                        afccosto.fecha_reg,
                        afccosto.id_usuario_mod,
                        afccosto.fecha_mod,
                        afccosto.id_usuario_ai,
                        afccosto.usuario_ai,
                        usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
                        cc.descripcion_tcc as desc_tipo_cc
                        from kaf.tactivo_fijo_cc afccosto
                        inner join param.vcentro_costo cc on cc.id_centro_costo=afccosto.id_centro_costo
						inner join segu.tusuario usu1 on usu1.id_usuario = afccosto.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = afccosto.id_usuario_mod
				        where afccosto.estado_reg=''activo'' and  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFCCOSTO_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		10-05-20196 11:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCCOSTO_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo_cc)
					    from kaf.tactivo_fijo_cc afccosto
                        inner join param.tcentro_costo cc on cc.id_centro_costo=afccosto.id_centro_costo
						inner join segu.tusuario usu1 on usu1.id_usuario = afccosto.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = afccosto.id_usuario_mod
				        where afccosto.estado_reg=''activo'' and ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	elsif(p_transaccion='SKA_LOGAFCC_CONT')then
       begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo_cc_log)
					    from kaf.tactivo_fijo_cc_log afccosto
                        where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
					
	elsif(p_transaccion='SKA_LOGAFCC_SEL')then
    	begin 
    		--Sentencia de la consulta
			v_consulta:='select
						afccosto.activo_fijo, 
                        afccosto.centro_costo, 
                        afccosto.mes, 
                        afccosto.cantidad_horas, 
                        afccosto.detalle
                        from kaf.tactivo_fijo_cc_log afccosto
                        order by detalle desc  ';
			
			--Definicion de la respuesta
			--v_consulta:=v_consulta||v_parametros.filtro;
			--v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

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