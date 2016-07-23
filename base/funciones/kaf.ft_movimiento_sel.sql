CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_sel"(	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento'
 AUTOR: 		 (admin)
 FECHA:	        22-10-2015 20:42:41
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

	v_nombre_funcion = 'kaf.ft_movimiento_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		22-10-2015 20:42:41
	***********************************/

	if(p_transaccion='SKA_MOV_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						mov.id_movimiento,
						mov.direccion,
						mov.fecha_hasta,
						mov.id_cat_movimiento,
						mov.fecha_mov,
						mov.id_depto,
						mov.id_proceso_wf,
						mov.id_estado_wf,
						mov.glosa,
						mov.id_funcionario,
						mov.estado,
						mov.id_oficina,
						mov.estado_reg,
						mov.num_tramite,
						mov.id_usuario_ai,
						mov.id_usuario_reg,
						mov.fecha_reg,
						mov.usuario_ai,
						mov.fecha_mod,
						mov.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod,
						cat.descripcion as movimiento,
						cat.codigo as cod_movimiento,
						cat.icono,
						dep.nombre as depto,
						dep.codigo as cod_depto,
						fun.desc_funcionario2,
						ofi.nombre as oficina,
						mov.id_responsable_depto,
						mov.id_persona,
						usu.desc_persona as responsable_depto,
						per.nombre_completo2 as custodio,
						tew.icono as icono_estado,
						mov.codigo,
			            mov.id_deposito,
			            mov.id_depto_dest,
			            mov.id_deposito_dest,
			            mov.id_funcionario_dest,
			            mov.id_movimiento_motivo,
			            depo.nombre as deposito,
			            depdest.nombre as depto_dest,
			            depodest.nombre as deposito_dest,
			            fundest.desc_funcionario2,
			            movmot.motivo
						from kaf.tmovimiento mov
						inner join segu.tusuario usu1 on usu1.id_usuario = mov.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mov.id_usuario_mod
						inner join param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
						inner join param.tdepto dep on dep.id_depto = mov.id_depto
						left join orga.vfuncionario fun on fun.id_funcionario = mov.id_funcionario
						left join orga.toficina ofi on ofi.id_oficina = mov.id_oficina
						inner join segu.vusuario usu on usu.id_usuario = mov.id_responsable_depto
						left join segu.vpersona per on per.id_persona = mov.id_persona
						inner join wf.testado_wf ew on ew.id_estado_wf = mov.id_estado_wf
						inner join wf.ttipo_estado tew on tew.id_tipo_estado = ew.id_tipo_estado
						left join kaf.tdeposito depo on depo.id_deposito = mov.id_deposito
						left join param.tdepto depdest on depdest.id_depto = mov.id_depto_dest
						left join kaf.tdeposito depodest on depodest.id_deposito = mov.id_deposito_dest
						left join orga.vfuncionario fundest on fundest.id_funcionario = mov.id_funcionario_dest
						left join kaf.tmovimiento_motivo movmot on movmot.id_movimiento_motivo = mov.id_movimiento_motivo
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		22-10-2015 20:42:41
	***********************************/

	elsif(p_transaccion='SKA_MOV_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_movimiento)
					    from kaf.tmovimiento mov
					    inner join segu.tusuario usu1 on usu1.id_usuario = mov.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mov.id_usuario_mod
					    inner join param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
						inner join param.tdepto dep on dep.id_depto = mov.id_depto
						left join orga.vfuncionario fun on fun.id_funcionario = mov.id_funcionario
						left join orga.toficina ofi on ofi.id_oficina = mov.id_oficina
						inner join segu.vusuario usu on usu.id_usuario = mov.id_responsable_depto
						left join segu.vpersona per on per.id_persona = mov.id_persona
						inner join wf.testado_wf ew on ew.id_estado_wf = mov.id_estado_wf
						inner join wf.ttipo_estado tew on tew.id_tipo_estado = ew.id_tipo_estado
						left join kaf.tdeposito depo on depo.id_deposito = mov.id_deposito
						left join param.tdepto depdest on depdest.id_depto = mov.id_depto_dest
						left join kaf.tdeposito depodest on depodest.id_deposito = mov.id_deposito_dest
						left join orga.vfuncionario fundest on fundest.id_funcionario = mov.id_funcionario_dest
						left join kaf.tmovimiento_motivo movmot on movmot.id_movimiento_motivo = mov.id_movimiento_motivo
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_REP'
 	#DESCRIPCION:	Reporte de movimientos
 	#AUTOR:			RCM
 	#FECHA:			20/03/2016
	***********************************/

	elsif(p_transaccion='SKA_MOV_REP')then

		begin

			--Consulta
			v_consulta:='select
						cat.descripcion as movimiento,
						cat.codigo as cod_movimiento,
						coalesce(mov.codigo,''S/N'') as formulario,
						coalesce(mov.num_tramite,''S/N'') as num_tramite,
						mov.fecha_mov, 
						mov.fecha_hasta,
						mov.glosa,
						mov.estado,
						dpto.nombre as depto,
						fun.desc_funcionario2 as responsable,
						fun.nombre_cargo,
						fun.ci,
						ofi.nombre as oficina,
						mov.direccion,
						usu.desc_persona as responsable_depto,
						per.nombre_completo2 as custodio,
						per.ci as ci_custodio,
						af.codigo,
						af.denominacion,
						af.descripcion,
						cat2.descripcion as estado_fun,
						maf.vida_util,
						maf.importe,
						mmot.motivo,
						af.marca,
						af.nro_serie,
						af.fecha_compra,
						af.monto_compra,
						kaf.f_get_tipo_activo(af.id_activo_fijo) as tipo_activo
						from kaf.tmovimiento mov
						inner join param.tcatalogo cat
						on cat.id_catalogo = mov.id_cat_movimiento
						inner join param.tdepto dpto
						on dpto.id_depto = mov.id_depto
						left join orga.vfuncionario_cargo fun
						on fun.id_funcionario = mov.id_funcionario
						left join orga.toficina ofi
						on ofi.id_oficina = mov.id_oficina
						inner join segu.vusuario usu
						on usu.id_usuario = mov.id_responsable_depto
						left join segu.vpersona per
						on per.id_persona = mov.id_persona
						left join kaf.tmovimiento_af maf
						on maf.id_movimiento = mov.id_movimiento
						left join kaf.tactivo_fijo af
						on af.id_activo_fijo = maf.id_activo_fijo
						left join param.tcatalogo cat2
						on cat2.id_catalogo = maf.id_cat_estado_fun
						left join kaf.tmovimiento_motivo mmot
						on mmot.id_movimiento_motivo = maf.id_movimiento_motivo
					    where ';

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
ALTER FUNCTION "kaf"."ft_movimiento_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
