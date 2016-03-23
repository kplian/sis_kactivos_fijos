CREATE OR REPLACE FUNCTION kaf.ft_clasificacion_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.ft_clasificacion_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tclasificacion'
 AUTOR: 		 (admin)
 FECHA:	        09-11-2015 01:22:17
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

	v_nombre_funcion = 'kaf.ft_clasificacion_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	if(p_transaccion='SKA_CLAF_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						claf.id_clasificacion,
						claf.codigo,
						claf.nombre,
						claf.final,
						claf.estado_reg,
						claf.id_cat_metodo_dep,
						claf.tipo,
						claf.id_concepto_ingas,
						claf.monto_residual,
						claf.icono,
						claf.id_clasificacion_fk,
						claf.vida_util,
						claf.correlativo_act,
						claf.usuario_ai,
						claf.fecha_reg,
						claf.id_usuario_reg,
						claf.id_usuario_ai,
						claf.id_usuario_mod,
						claf.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cat.codigo as codigo_met_dep,
						cat.descripcion as met_dep,
						cig.desc_ingas,
						claf.codigo||'' - ''||claf.nombre as clasificacion
						from kaf.tclasificacion claf
						inner join segu.tusuario usu1 on usu1.id_usuario = claf.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = claf.id_usuario_mod
						left join param.tcatalogo cat on cat.id_catalogo = claf.id_cat_metodo_dep
						left join param.tconcepto_ingas cig on cig.id_concepto_ingas = claf.id_concepto_ingas
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAF_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_clasificacion)
					    from kaf.tclasificacion claf
					    inner join segu.tusuario usu1 on usu1.id_usuario = claf.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = claf.id_usuario_mod
						left join param.tcatalogo cat on cat.id_catalogo = claf.id_cat_metodo_dep
						left join param.tconcepto_ingas cig on cig.id_concepto_ingas = claf.id_concepto_ingas
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAFARB_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:			admin	
 	#FECHA:			09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAFARB_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						claf.id_clasificacion,
						claf.codigo,
						claf.nombre,
						claf.final,
						claf.estado_reg,
						claf.id_cat_metodo_dep,
						claf.tipo,
						claf.id_concepto_ingas,
						claf.monto_residual,
						claf.icono,
						claf.id_clasificacion_fk,
						claf.vida_util,
						claf.correlativo_act,
						claf.usuario_ai,
						claf.fecha_reg,
						claf.id_usuario_reg,
						claf.id_usuario_ai,
						claf.id_usuario_mod,
						claf.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cat.codigo as codigo_met_dep,
						cat.descripcion as met_dep,
						cig.desc_ingas,
						case
                        when (claf.id_clasificacion_fk is null) then
                        	''raiz''::varchar
                        else
                            ''hijo''::varchar
                    	end as tipo_nodo,
                    	''false''::varchar as checked
						from kaf.tclasificacion claf
						inner join segu.tusuario usu1 on usu1.id_usuario = claf.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = claf.id_usuario_mod
						left join param.tcatalogo cat on cat.id_catalogo = claf.id_cat_metodo_dep
						left join param.tconcepto_ingas cig on cig.id_concepto_ingas = claf.id_concepto_ingas
				        where ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			raise notice '%',v_consulta;
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