CREATE OR REPLACE FUNCTION kaf.ft_movimiento_af_dep_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_dep_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento_af_dep'
 AUTOR: 		 (admin)
 FECHA:	        16-04-2016 08:14:17
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

	v_nombre_funcion = 'kaf.ft_movimiento_af_dep_sel';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MAFDEP_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 08:14:17
	***********************************/

	if(p_transaccion='SKA_MAFDEP_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select
						mafdep.id_movimiento_af_dep,
						mafdep.vida_util,
						mafdep.tipo_cambio_ini,
						mafdep.depreciacion_per_actualiz,
						mafdep.id_movimiento_af,
						mafdep.vida_util_ant,
						mafdep.estado_reg,
						mafdep.monto_vigente,
						mafdep.monto_vigente_ant,
						mafdep.depreciacion_acum_actualiz,
						mafdep.tipo_cambio_fin,
						mafdep.depreciacion_acum,
						mafdep.id_activo_fijo_valor,
						mafdep.factor,
						mafdep.depreciacion_per,
						mafdep.depreciacion,
						mafdep.id_moneda,
						mafdep.depreciacion_per_ant,
						mafdep.monto_actualiz,
						mafdep.depreciacion_acum_ant,
						mafdep.id_usuario_reg,
						mafdep.usuario_ai,
						mafdep.fecha_reg,
						mafdep.id_usuario_ai,
						mafdep.fecha_mod,
						mafdep.id_usuario_mod,
						usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod	
						from kaf.tmovimiento_af_dep mafdep
						inner join segu.tusuario usu1 on usu1.id_usuario = mafdep.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mafdep.id_usuario_mod
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MAFDEP_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		admin	
 	#FECHA:		16-04-2016 08:14:17
	***********************************/

	elsif(p_transaccion='SKA_MAFDEP_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_movimiento_af_dep)
					    from kaf.tmovimiento_af_dep mafdep
					    inner join segu.tusuario usu1 on usu1.id_usuario = mafdep.id_usuario_reg
						left join segu.tusuario usu2 on usu2.id_usuario = mafdep.id_usuario_mod
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MAFDEPRES_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:		RCM	
 	#FECHA:		05/05/2016
	***********************************/

	elsif(p_transaccion='SKA_MAFDEPRES_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='select mafdep.id_movimiento_af_dep, mafdep.id_movimiento_af, mafdep.id_activo_fijo_valor,
						mafdep.fecha, mafdep.depreciacion_acum_ant, mafdep.depreciacion_per_ant, mafdep.monto_vigente_ant, mafdep.vida_util_ant,
						mafdep.depreciacion_acum_actualiz, mafdep.depreciacion_per_actualiz, mafdep.monto_actualiz,
						mafdep.depreciacion, mafdep.depreciacion_acum,mafdep.depreciacion_per, mafdep.monto_vigente, mafdep.vida_util,
						mafdep.tipo_cambio_ini,mafdep.tipo_cambio_fin, mafdep.factor
						from kaf.tmovimiento_af_dep mafdep
				        where  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MAFDEPRES_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:		RCM	
 	#FECHA:		05/05/2016
	***********************************/

	elsif(p_transaccion='SKA_MAFDEPRES_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select count(id_movimiento_af_dep)
					    from kaf.tmovimiento_af_dep mafdep
					    where ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_RESCAB_SEL'
 	#DESCRIPCION:	Consulta de datos
 	#AUTOR:			RCM
 	#FECHA:			07/05/2016
	***********************************/

	elsif(p_transaccion='SKA_RESCAB_SEL')then
     				
    	begin
    		--Sentencia de la consulta
			v_consulta:='  select
                              actval.id_activo_fijo_valor,
                              actval.id_activo_fijo,
                              actval.depreciacion_per,
                              actval.estado,
                              actval.principal,
                              actval.monto_vigente,
                              actval.monto_rescate,
                              actval.tipo_cambio_ini,
                              actval.estado_reg,
                              actval.tipo,
                              actval.depreciacion_mes,
                              actval.depreciacion_acum,
                              actval.fecha_ult_dep,
                              actval.fecha_ini_dep,
                              actval.monto_vigente_orig,
                              actval.vida_util,
                              actval.vida_util_orig,
                              movaf.id_movimiento_af,
                              actval.tipo_cambio_fin,
                              actval.codigo,
                              afv.monto_vigente_real,
                              afv.vida_util_real,
                              afv.depreciacion_acum_ant_real,
                              afv.depreciacion_acum_real,
                              afv.depreciacion_per_real,
                              afv.monto_actualiz_real,
                              afv.id_moneda,
                              afv.id_moneda_dep,
                              mon.codigo as desc_moneda
						from  kaf.tactivo_fijo_valores actval
						inner join kaf.tmovimiento_af movaf  on actval.id_activo_fijo = movaf.id_activo_fijo
                        inner join kaf.vactivo_fijo_valor afv on afv.id_activo_fijo_valor = actval.id_activo_fijo_valor
                        inner join param.tmoneda mon on mon.id_moneda = afv.id_moneda
                        WHERE  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

			--Devuelve la respuesta
			return v_consulta;
						
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_RESCAB_CONT'
 	#DESCRIPCION:	Conteo de registros
 	#AUTOR:			RCM
 	#FECHA:			07/05/2016
	***********************************/

	elsif(p_transaccion='SKA_RESCAB_CONT')then

		begin
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select
						  count(actval.id_activo_fijo_valor),
                          sum(afv.monto_actualiz_real),
                          sum(afv.depreciacion_acum_real),
                          sum(afv.monto_vigente_real)
						from  kaf.tactivo_fijo_valores actval
						inner join kaf.tmovimiento_af movaf  on actval.id_activo_fijo = movaf.id_activo_fijo
                        inner join kaf.vactivo_fijo_valor afv on afv.id_activo_fijo_valor = actval.id_activo_fijo_valor
                        inner join param.tmoneda mon on mon.id_moneda = afv.id_moneda
                        WHERE  ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
	
    /*********************************    
 	#TRANSACCION:  'SKA_RESCABPRBK_SEL'
 	#DESCRIPCION:	Consulta de datos de depreciacon par ainterface principal
 	#AUTOR:			RAC
 	#FECHA:			07/05/2016
	***********************************/

	elsif(p_transaccion='SKA_RESCABPRBK_SEL')then
     				
    	begin
           
        
            
        
        
    		--Sentencia de la consulta
			v_consulta:='  select
						  distinct actval.id_activo_fijo_valor,
                          actval.id_activo_fijo,
                          actval.depreciacion_per,
                          actval.estado,
                          actval.principal,
                          actval.monto_vigente,
                          actval.monto_rescate,
                          actval.tipo_cambio_ini,
                          actval.estado_reg,
                          actval.tipo,
                          actval.depreciacion_mes,
                          actval.depreciacion_acum,
                          actval.fecha_ult_dep,
                          actval.fecha_ini_dep,
                          actval.monto_vigente_orig,
                          actval.vida_util,
                          actval.vida_util_orig,
                          actval.tipo_cambio_fin,
                          actval.codigo,
                          afv.monto_vigente_real,
                          afv.vida_util_real,
                          afv.depreciacion_acum_ant_real,
                          afv.depreciacion_acum_real,
                          afv.depreciacion_per_real,
                          afv.monto_actualiz_real,
                          afv.id_moneda,
                          afv.id_moneda_dep,
                          mon.codigo as desc_moneda
						from  kaf.tactivo_fijo_valores actval 
                        inner join kaf.vactivo_fijo_valor afv on afv.id_activo_fijo_valor = actval.id_activo_fijo_valor and 
                        inner join param.tmoneda mon on mon.id_moneda = afv.id_moneda
                        WHERE  (kaf.fecha_fin is null or afv.fecha_fin <= '''||fecha_hasta||'''::date)  ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            
            raise notice 'consulta %',v_consulta;

			--Devuelve la respuesta
			return v_consulta;
						
		end;
        
    /*********************************    
 	#TRANSACCION:  'SKA_RESCABPR_SEL'
 	#DESCRIPCION:	Consulta de datos de depreciacon par ainterface principal
 	#AUTOR:			RAC
 	#FECHA:			07/05/2016
	***********************************/

	elsif(p_transaccion='SKA_RESCABPR_SEL')then
     				
    	begin
           
        
    		--Sentencia de la consulta
			v_consulta:='select
						  distinct actval.id_activo_fijo_valor,
                          actval.id_activo_fijo,
                          actval.depreciacion_per,
                          actval.estado,
                          actval.principal,
                          actval.monto_vigente,
                          actval.monto_rescate,
                          actval.tipo_cambio_ini,
                          actval.estado_reg,
                          actval.tipo,
                          actval.depreciacion_mes,
                          actval.depreciacion_acum,
                          actval.fecha_ult_dep,
                          actval.fecha_ini_dep,
                          actval.monto_vigente_orig,
                          actval.vida_util,
                          actval.vida_util_orig,
                          actval.tipo_cambio_fin,
                          actval.codigo,
                          COALESCE(min.monto_vigente, actval.monto_vigente_orig) AS monto_vigente_real,
                          COALESCE(min.vida_util, actval.vida_util_orig) AS vida_util_real,
                          COALESCE(min.depreciacion_acum, 0::numeric) AS depreciacion_acum_real,
                          COALESCE(min.depreciacion_per, 0::numeric) AS depreciacion_per_real,
                          COALESCE(min.depreciacion_acum_ant, 0::numeric) AS depreciacion_acum_ant_real,
                          COALESCE(min.monto_actualiz, actval.monto_vigente_orig) AS monto_actualiz_real,
                          actval.id_moneda,
                          actval.id_moneda_dep,
                          mon.codigo as desc_moneda,
                          actval.fecha_fin
						from  kaf.tactivo_fijo_valores actval 
                        LEFT JOIN ( SELECT DISTINCT ON (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
                                 afd.monto_vigente,
                                 afd.vida_util,
                                 afd.fecha,
                                 afd.depreciacion_acum,
                                 afd.depreciacion_per,
                                 afd.depreciacion_acum_ant,
                                 afd.monto_actualiz,
                                 afd.depreciacion_acum_actualiz,
                                 afd.depreciacion_per_actualiz,
                                 afd.id_moneda,
                                 afd.id_moneda_dep
                          FROM kaf.tmovimiento_af_dep afd
                          inner join kaf.tactivo_fijo_valores afv on afv.id_activo_fijo_valor = afd.id_activo_fijo_valor
                          WHERE       afd.fecha <= '''||v_parametros.fecha_hasta||'''::date
                                 and afv.id_activo_fijo = '||v_parametros.id_activo_fijo||' 
                          ORDER BY afd.id_activo_fijo_valor,
                                   afd.fecha DESC) min ON min.id_activo_fijo_valor =  actval.id_activo_fijo_valor AND actval.id_moneda_dep = min.id_moneda_dep
                        inner join param.tmoneda mon on mon.id_moneda = actval.id_moneda
                        WHERE      (actval.fecha_fin is null or actval.fecha_fin > '''||v_parametros.fecha_hasta||'''::date)  
                               and  actval.fecha_inicio <= '''||v_parametros.fecha_hasta||'''::date 
                               and  actval.id_activo_fijo = '||v_parametros.id_activo_fijo||'
                               and ';
			
			--Definicion de la respuesta
			v_consulta:=v_consulta||v_parametros.filtro;
			v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            
            raise notice 'consulta %',v_consulta;

			--Devuelve la respuesta
			return v_consulta;
						
		end;     
        

	/*********************************    
 	#TRANSACCION:  'SKA_RESCABPR_CONT'
 	#DESCRIPCION:	Conteo de registros de depreciacion para interface principal
 	#AUTOR:			RAC
 	#FECHA:			07/05/2016
	***********************************/

	elsif(p_transaccion='SKA_RESCABPR_CONT')then

		begin
        
			--Sentencia de la consulta de conteo de registros
			v_consulta:='select
						  count(actval.id_activo_fijo_valor),
                          sum(COALESCE(min.monto_actualiz, actval.monto_vigente_orig)),
                          sum(COALESCE(min.depreciacion_acum, 0::numeric)),
                          sum( COALESCE(min.monto_vigente, actval.monto_vigente_orig)),
                          max(COALESCE(min.vida_util, actval.vida_util_orig))
						from  kaf.tactivo_fijo_valores actval 
                        LEFT JOIN ( SELECT DISTINCT ON (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
                                 afd.monto_vigente,
                                 afd.vida_util,
                                 afd.fecha,
                                 afd.depreciacion_acum,
                                 afd.depreciacion_per,
                                 afd.depreciacion_acum_ant,
                                 afd.monto_actualiz,
                                 afd.depreciacion_acum_actualiz,
                                 afd.depreciacion_per_actualiz,
                                 afd.id_moneda,
                                 afd.id_moneda_dep
                          FROM kaf.tmovimiento_af_dep afd
                          inner join kaf.tactivo_fijo_valores afv on afv.id_activo_fijo_valor = afd.id_activo_fijo_valor
                          WHERE       afd.fecha <= '''||v_parametros.fecha_hasta||'''::date
                                 and afv.id_activo_fijo = '||v_parametros.id_activo_fijo||' 
                          ORDER BY afd.id_activo_fijo_valor,
                                   afd.fecha DESC) min ON min.id_activo_fijo_valor =  actval.id_activo_fijo_valor AND actval.id_moneda_dep = min.id_moneda_dep
                        inner join param.tmoneda mon on mon.id_moneda = actval.id_moneda
                        WHERE      (actval.fecha_fin is null or actval.fecha_fin > '''||v_parametros.fecha_hasta||'''::date)  
                               and  actval.fecha_inicio <= '''||v_parametros.fecha_hasta||'''::date 
                               and  actval.id_activo_fijo = '||v_parametros.id_activo_fijo||'
                               and ';
			
			--Definicion de la respuesta		    
			v_consulta:=v_consulta||v_parametros.filtro;

			--Devuelve la respuesta
			return v_consulta;

		end;
        
    /*********************************    
 	#TRANSACCION:  'SKA_RDEPMEN_SEL'
 	#DESCRIPCION:	Reporte depreciación mensual
 	#AUTOR:			RCM		
 	#FECHA:			14/05/2018
	***********************************/

	elsif(p_transaccion='SKA_RDEPMEN_SEL')then
     				
    	begin

			create temp table tt_movimiento_af_dep(
            	id_movimiento_af_dep integer,
                id_activo_fijo_valor integer,
                id_activo_fijo_valor_padre integer,
                id_movimiento integer,
                id_activo_fijo integer,
                monto_actualiz numeric,
                monto_actualiz_ant numeric,
                depreciacion_per numeric,
                depreciacion numeric,
                depreciacion_acum numeric,
                monto_vigente numeric,
                tipo_cambio_ini numeric,
                tipo_cambio_fin numeric,
                fecha_ini_dep date,
                monto_vigente_orig_100 numeric,
                monto_vigente_orig numeric,
                fecha date,
                id_afvs text,
                depreciacion_acum_gest_ant numeric,
                tipo_cambio_fin_gest_ant integer
            ) on commit drop;
            
            --Carga los registros de depreciacion del movimiento
            insert into tt_movimiento_af_dep(
              id_movimiento_af_dep,
              id_activo_fijo_valor,
              id_movimiento,
              id_activo_fijo,
              monto_actualiz,
              monto_actualiz_ant,
              depreciacion_per,
              depreciacion,
              depreciacion_acum,
              monto_vigente,
              tipo_cambio_ini,
              tipo_cambio_fin,
              fecha
            )
            select
            mdep.id_movimiento_af_dep,
            mdep.id_activo_fijo_valor,
            maf.id_movimiento,
            maf.id_activo_fijo,
            mdep.monto_actualiz,
            mdep.monto_actualiz_ant,
            mdep.depreciacion_per,
            mdep.depreciacion,
            mdep.depreciacion_acum,
            mdep.monto_vigente,
            mdep.tipo_cambio_ini,
            mdep.tipo_cambio_fin,
            mdep.fecha
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tmovimiento_af maf
            on maf.id_movimiento_af = mdep.id_movimiento_af
            where mdep.id_moneda = v_parametros.id_moneda
        	and maf.id_movimiento = v_parametros.id_movimiento;
            
            --Obtiene el id_activo_fijo_valor padre
            update tt_movimiento_af_dep set
            id_activo_fijo_valor_padre = kaf.f_get_afv_padre(tt_movimiento_af_dep.id_activo_fijo_valor);
            
            --Obtiene los Ids de los AFV de los dependientes
            update tt_movimiento_af_dep set
            id_afvs = kaf.f_get_ids_afv_dependiente(tt_movimiento_af_dep.id_activo_fijo_valor);
            
            --Obtiene datos del padre
            update tt_movimiento_af_dep set
            fecha_ini_dep = (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_movimiento_af_dep.id_activo_fijo_valor_padre),
			monto_vigente_orig_100 = (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_movimiento_af_dep.id_activo_fijo_valor_padre),
			monto_vigente_orig = (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_movimiento_af_dep.id_activo_fijo_valor_padre)
            where id_activo_fijo_valor_padre is not null;
            
            --Los que no tienen padre
            update tt_movimiento_af_dep mdep set
            fecha_ini_dep = afv.fecha_ini_dep,
            monto_vigente_orig_100 = afv.monto_vigente_orig_100,
            monto_vigente_orig = afv.monto_vigente_orig
            from kaf.tactivo_fijo_valores afv
            where afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            and mdep.id_activo_fijo_valor_padre is null;
            
            --Depreciación acumulada gestión anterior
            update tt_movimiento_af_dep set
            depreciacion_acum_gest_ant = (select ps_depreciacion_acum_gest_ant from kaf.f_get_depreciacion_acum_gest_ant(tt_movimiento_af_dep.id_activo_fijo_valor,
            																	tt_movimiento_af_dep.id_afvs,
                                                                                2,
                                                                                tt_movimiento_af_dep.fecha)),
        	tipo_cambio_fin_gest_ant = (select ps_depreciacion_acum_gest_ant from kaf.f_get_depreciacion_acum_gest_ant(tt_movimiento_af_dep.id_activo_fijo_valor,
            																	tt_movimiento_af_dep.id_afvs,
                                                                                2,
                                                                                tt_movimiento_af_dep.fecha));
            
    		--Sentencia de la consulta            
			v_consulta:='
            			WITH tta as (SELECT distinct rc_1.id_tabla AS id_clasificacion,
                          ((''{''::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, ''hijos''::
                          character varying)::text) || ''}''::text)::integer [ ] AS nodos
                          FROM conta.ttabla_relacion_contable tb
                          JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
                          = tb.id_tabla_relacion_contable
                          JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
                          trc.id_tipo_relacion_contable
                          WHERE tb.esquema::text = ''KAF''::text AND
                          tb.tabla::text = ''tclasificacion''::text AND
                          trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text)
                        )
            			select
            			row_number() over(order by afv.codigo) as numero,
                        afv.codigo, 
                        af.codigo_ant, 
                        af.denominacion,
                        to_char(mdep.fecha_ini_dep,''dd-mm-yyyy''), 
                        af.cantidad_af, 
                        um.descripcion as desc_unidad_medida,
                        cc.codigo_tcc,
                        af.nro_serie,
                        af.ubicacion,
                        fun.desc_funcionario2,
                        mdep.monto_vigente_orig_100,
                        mdep.monto_vigente_orig,
                        mdep.monto_actualiz - mdep.monto_vigente_orig as inc_valor_actualiz,
                        mdep.monto_actualiz as valor_actualiz,
                        afv.vida_util,
                        afv.vida_util_orig,
                        mdep.monto_actualiz - mdep.monto_actualiz_ant as inc_actualiz,
                        mdep.depreciacion_acum_gest_ant,--vde.depreciacion_acum_actualiz as dep_acum_gestant,
                        case 
                        	when coalesce(mdep.depreciacion_acum_gest_ant,0) = 0 then 0
                            else mdep.depreciacion_acum_gest_ant * mdep.tipo_cambio_fin/mdep.tipo_cambio_fin_gest_ant
                        end as actualiz_dep_gest_ant,
                        --mdep.depreciacion_acum_gest_ant * mdep.tipo_cambio_fin/mdep.tipo_cambio_fin_gest_ant as actualiz_dep_gest_ant,--vde.inc_dep_acum_actualiz as actualiz_dep_gest_ant,
                        mdep.depreciacion_per::numeric as depreciacion_gestion,
                        mdep.depreciacion as depreciacion_mensual,
                        mdep.depreciacion_acum as depreciacion_acum,
                        mdep.monto_vigente as valor_activo,
                        mdep.tipo_cambio_ini,
                        mdep.tipo_cambio_fin,
                        min(mdep.fecha) over (partition by mdep.id_activo_fijo_valor), 
                        max(mdep.fecha) over (partition by mdep.id_activo_fijo_valor),
                        (select c.nro_cuenta||''-''||c.nombre_cuenta 
                          from conta.tcuenta c 
                          where c.id_cuenta in (select id_cuenta
                                              from conta.trelacion_contable rc 
                                              where rc.id_tipo_relacion_contable =  90
                                              and rc.id_gestion = 2
                                              and rc.estado_reg = ''activo''
                                              and rc.id_tabla = tta.id_clasificacion
                                              )
                        ) as cuenta_activo,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta 
                                    from conta.tcuenta c 
                                    where c.id_cuenta in (select id_cuenta
                                                        from conta.trelacion_contable rc 
                                                        where rc.id_tipo_relacion_contable =  92
                                                        and rc.id_gestion = 2
                                                        and rc.estado_reg = ''activo''
                                                        and rc.id_tabla = tta.id_clasificacion
                                                        )
                        ) as cuenta_dep_acum,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta 
                                    from conta.tcuenta c 
                                    where c.id_cuenta in (select id_cuenta
                                                        from conta.trelacion_contable rc 
                                                        where rc.id_tipo_relacion_contable =  91
                                                        and rc.id_gestion = 2
                                                        and rc.estado_reg = ''activo''
                                                        and rc.id_tabla = tta.id_clasificacion
                                                        )
                        ) as cuenta_deprec
                        from tt_movimiento_af_dep mdep
                        inner join kaf.tmovimiento mov
                        on mov.id_movimiento = mdep.id_movimiento
                        inner join kaf.tactivo_fijo_valores afv
                        on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = mdep.id_activo_fijo
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = af.id_centro_costo
                        left join param.tunidad_medida um
                        on um.id_unidad_medida = af.id_unidad_medida
                        left join orga.vfuncionario fun
                        on fun.id_funcionario = af.id_funcionario
                        /*left join kaf.vdep_acum_actualiz_ant vde
                        on vde.id_movimiento = mdep.id_movimiento
                        and vde.id_activo_fijo_valor = afv.id_activo_fijo_valor*/
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        order by afv.codigo';
			
			--Definicion de la respuesta
			--v_consulta:=v_consulta||v_parametros.filtro;
            raise notice '%',v_consulta;
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