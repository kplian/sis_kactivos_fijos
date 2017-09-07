CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_modificacion_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_modificacion_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo_modificacion'
 AUTOR: 		 (admin)
 FECHA:	        23-08-2017 14:14:25
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

	v_nombre_funcion = 'kaf.ft_activo_fijo_modificacion_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	if(p_transaccion='SKA_KAFMOD_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						kafmod.id_activo_fijo_modificacion,
						kafmod.id_activo_fijo,
						kafmod.id_oficina,
						kafmod.id_oficina_ant,
						kafmod.ubicacion,
						kafmod.estado_reg,
						kafmod.ubicacion_ant,
						kafmod.observaciones,
						kafmod.id_usuario_ai,
						kafmod.usuario_ai,
						kafmod.fecha_reg,
						kafmod.id_usuario_reg,
						kafmod.id_usuario_mod,
						kafmod.fecha_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						ofi.codigo || '' - '' || ofi.nombre as desc_oficina,
						ofiant.codigo || '' - '' || ofiant.nombre as desc_oficina_ant,
						case 
							when kafmod.id_oficina is not null and kafmod.ubicacion is not null then 1::integer
							when kafmod.observaciones is not null and kafmod.id_oficina is null then 2::integer
							else 0::integer
						end as tipo,
						case 
							when kafmod.id_oficina is not null and kafmod.ubicacion is not null then ''Dirección''::varchar
							when kafmod.observaciones is not null and kafmod.id_oficina is null then ''Notas''::varchar
							else 0::varchar
						end as desc_tipo
						from kaf.tactivo_fijo_modificacion kafmod
						inner join segu.tusuario usu1 on usu1.id_usuario = kafmod.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = kafmod.id_usuario_mod
						left join orga.toficina ofi on ofi.id_oficina = kafmod.id_oficina
						left join orga.toficina ofiant on ofiant.id_oficina = kafmod.id_oficina_ant
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	elsif(p_transaccion='SKA_KAFMOD_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_activo_fijo_modificacion)
					    from kaf.tactivo_fijo_modificacion kafmod
						inner join segu.tusuario usu1 on usu1.id_usuario = kafmod.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = kafmod.id_usuario_mod
						left join orga.toficina ofi on ofi.id_oficina = kafmod.id_oficina
						left join orga.toficina ofiant on ofiant.id_oficina = kafmod.id_oficina_ant
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
ALTER FUNCTION "kaf"."ft_activo_fijo_modificacion_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
