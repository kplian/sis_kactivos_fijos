--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo'
 AUTOR: 		 (admin)
 FECHA:	        29-10-2015 03:18:45
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
    v_lista_af			varchar;
    v_criterio_filtro	varchar;
    v_clase_reporte		varchar;
			    
BEGIN

	v_nombre_funcion = 'kaf.ft_activo_fijo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	if(p_transaccion='SKA_AFIJ_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
                            afij.id_activo_fijo,
                            afij.id_persona,
                            afij.cantidad_revaloriz,
                            coalesce(afij.foto,''./../../../uploaded_files/sis_kactivos_fijos/ActivoFijo/default.jpg'') as foto,
                            afij.id_proveedor,
                            afij.estado_reg,
                            afij.fecha_compra,
                            afij.monto_vigente,
                            afij.id_cat_estado_fun,
                            afij.ubicacion,
                            afij.vida_util,
                            afij.documento,
                            afij.observaciones,
                            afij.fecha_ult_dep,
                            afij.monto_rescate,
                            afij.denominacion,
                            afij.id_funcionario,
                            afij.id_deposito,
                            afij.monto_compra,
                            afij.id_moneda,
                            afij.depreciacion_mes,
                            afij.codigo,
                            afij.descripcion,
                            afij.id_moneda_orig,
                            afij.fecha_ini_dep,
                            afij.id_cat_estado_compra,
                            afij.depreciacion_per,
                            afij.vida_util_original,
                            afij.depreciacion_acum,
                            afij.estado,
                            afij.id_clasificacion,
                            afij.id_centro_costo,
                            afij.id_oficina,
                            afij.id_depto,
                            afij.id_usuario_reg,
                            afij.fecha_reg,
                            afij.usuario_ai,
                            afij.id_usuario_ai,
                            afij.id_usuario_mod,
                            afij.fecha_mod,
                            usu1.cuenta as usr_reg,
                            usu2.cuenta as usr_mod,
                            per.nombre_completo2 as persona,
                            pro.desc_proveedor,
                            cat1.descripcion as estado_fun,
                            cat2.descripcion as estado_compra,
                            cla.codigo || '' '' || cla.nombre as clasificacion,
                            cc.codigo_cc as centro_costo,
                            ofi.codigo || '' '' || ofi.nombre as oficina,
                            dpto.codigo || '' '' || dpto.nombre as depto,
                            fun.desc_funcionario2 as funcionario,
                            depaf.nombre as deposito,
                            depaf.codigo as deposito_cod,
                            mon.codigo as desc_moneda_orig,
                            afij.en_deposito,
                            coalesce(afij.extension,''jpg'') as extension,
                            afij.codigo_ant,
                            afij.marca,
                            afij.nro_serie,
                            afij.caracteristicas,
                            COALESCE(round(afvi.monto_vigente_real_af,2), afij.monto_compra),
                            COALESCE(afvi.vida_util_real_af,afij.vida_util_original),                            
                            afvi.fecha_ult_dep_real_af,
                            COALESCE(round(afvi.depreciacion_acum_real_af,2),0),
                            COALESCE(round( afvi.depreciacion_per_real_af,2),0),
                            cla.tipo_activo,
                            cla.depreciable,
                            afij.monto_compra_mt
						from kaf.tactivo_fijo afij                       
						inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg						
						inner join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
						inner join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
						inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
						inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
						inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left  join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
                        left join kaf.vactivo_fijo_vigente afvi on afvi.id_activo_fijo = afij.id_activo_fijo
                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod						
						left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
						left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
						left join segu.vpersona per on per.id_persona = afij.id_persona
						left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
            
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(afij.id_activo_fijo)
					    from kaf.tactivo_fijo afij                       
						inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg						
						inner join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
						inner join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
						inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
						inner join param.tdepto dpto on dpto.id_depto = afij.id_depto                        
						inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
                        left join kaf.vactivo_fijo_vigente afvi on afvi.id_activo_fijo = afij.id_activo_fijo
                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod						
						left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
						left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
						left join segu.vpersona per on per.id_persona = afij.id_persona
						left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
				        where  ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_IDAF_SEL'
 	#DESCRIPCION:	Generación de lista de ID de activos fijos en base a un criterio
 	#AUTOR:			RCM
 	#FECHA:			30/12/2015
	***********************************/

	elsif(p_transaccion='SKA_IDAF_SEL')then

		begin
        	--Sentencia de la consulta
			v_consulta:='select
						pxp.list(afij.id_activo_fijo::text) as ids
						from kaf.tactivo_fijo afij
						inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
						inner join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
						inner join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
						inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
						left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
						inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
						left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
						left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
						left join segu.vpersona per on per.id_persona = afij.id_persona
						left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
						inner join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;
        
        end;
	
    /*********************************    
 	#TRANSACCION:  'SKA_GEVARTQR_SEL'
 	#DESCRIPCION:	listado de activos segun criterio de formulario para generacion del reporte de codigos QR
 	#AUTOR:			RAC
 	#FECHA:			17/03/2017
	***********************************/

	elsif(p_transaccion='SKA_GEVARTQR_SEL')then

		begin
        	
            v_criterio_filtro = '  0=0 ';
           -- raise exception 'sss';
            
            IF  pxp.f_existe_parametro(p_tabla, 'id_clasificacion') THEN   
            
              IF v_parametros.id_clasificacion is not null THEN     
        
                  WITH RECURSIVE clasificacion_rec(id_clasificacion, codigo, id_clasificacion_fk) AS (
                  select 
                    c.id_clasificacion,
                    c.codigo,
                    c.id_clasificacion_fk
                  from kaf.tclasificacion c  
                  where c.estado_reg = 'activo' and c.id_clasificacion = v_parametros.id_clasificacion

                  UNION

                  select 
                    c2.id_clasificacion,
                    c2.codigo,
                    c2.id_clasificacion_fk
                  from kaf.tclasificacion  c2, clasificacion_rec pc
                  WHERE c2.id_clasificacion_fk = pc.id_clasificacion  and c2.estado_reg = 'activo'
                  )
                  
                  
                  SELECT pxp.list(id_clasificacion::varchar) 
                     into 
                        v_lista_af 
                  FROM clasificacion_rec; 
                  v_criterio_filtro = '  id_clasificacion in ('|| COALESCE(v_lista_af,'0')||')';
                  
                  
              END IF;
            
            END IF;
            
            
            IF  pxp.f_existe_parametro(p_tabla, 'desde') THEN  
               IF v_parametros.desde is not null   THEN     
                    v_criterio_filtro = v_criterio_filtro||'  and kaf.fecha_compra >= '''||v_parametros.desde||'''::date  ';
               END IF;
            END IF;
            
             IF  pxp.f_existe_parametro(p_tabla, 'hasta') THEN  
                IF v_parametros.hasta is not null   THEN     
                     v_criterio_filtro = v_criterio_filtro||'  and kaf.fecha_compra <= '''||v_parametros.hasta||'''::date  ';
                END IF;
            END IF;
            
            --Sentencia de la consulta
			v_consulta:='select 
                            kaf.id_activo_fijo,
                            kaf.codigo::varchar,
                            kaf.codigo_ant::varchar,
                            kaf.denominacion::varchar,
                            COALESCE(dep.nombre_corto, '''')::varchar as nombre_depto,
                            COALESCE(ent.nombre, '''')::varchar as nombre_entidad
                          from kaf.tactivo_fijo  kaf
                          inner join param.tdepto dep on dep.id_depto = kaf.id_depto 
                          left join param.tentidad ent on ent.id_entidad = dep.id_entidad
                          where kaf.estado = ''alta'' and  '||v_criterio_filtro;
			
			
			
            
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