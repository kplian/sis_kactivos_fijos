--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_tipo_prorrateo_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_prorrateo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.ttipo_prorrateo'
 AUTOR: 		 (admin)
 FECHA:	        02-05-2017 08:30:44
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

	v_nombre_funcion = 'kaf.ft_tipo_prorrateo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_TIPR_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		02-05-2017 08:30:44
	***********************************/

	if(p_transaccion='SKA_TIPR_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
                            tipr.id_tipo_prorrateo,
                            tipr.descripcion,
                            tipr.estado_reg,
                            tipr.id_gestion,
                            tipr.id_ot,
                            tipr.id_activo_fijo,
                            tipr.id_centro_costo,
                            tipr.id_proyecto,
                            tipr.factor,
                            tipr.id_usuario_reg,
                            tipr.usuario_ai,
                            tipr.fecha_reg,
                            tipr.id_usuario_ai,
                            tipr.id_usuario_mod,
                            tipr.fecha_mod,
                            usu1.cuenta as usr_reg,
                            usu2.cuenta as usr_mod,
                            ges.gestion::varchar as desc_gestion,
                            cc.codigo_cc::varchar as desc_centro_costo,
                            ot.desc_orden::varchar desc_ot	
						from kaf.ttipo_prorrateo tipr
						inner join segu.tusuario usu1 on usu1.id_usuario = tipr.id_usuario_reg
                        inner join param.tgestion ges on ges.id_gestion = tipr.id_gestion
                        inner join param.vcentro_costo cc on cc.id_centro_costo = tipr.id_centro_costo
                        left join conta.torden_trabajo ot on ot.id_orden_trabajo = tipr.id_ot
						left join segu.tusuario usu2 on usu2.id_usuario = tipr.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPR_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		02-05-2017 08:30:44
	***********************************/

	elsif(p_transaccion='SKA_TIPR_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_tipo_prorrateo)
					    from kaf.ttipo_prorrateo tipr
						inner join segu.tusuario usu1 on usu1.id_usuario = tipr.id_usuario_reg
                        inner join param.tgestion ges on ges.id_gestion = tipr.id_gestion
                        inner join param.vcentro_costo cc on cc.id_centro_costo = tipr.id_centro_costo
                        left join conta.torden_trabajo ot on ot.id_orden_trabajo = tipr.id_ot
						left join segu.tusuario usu2 on usu2.id_usuario = tipr.id_usuario_mod
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
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;