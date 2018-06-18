CREATE OR REPLACE FUNCTION kaf.f_reportes_af (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_reportes_af
 DESCRIPCION:    Funcion que devuelve conjunto de datos para reportes de activos fijos
 AUTOR:          RCM
 FECHA:          09/05/2016
 COMENTARIOS:   
***************************************************************************/

DECLARE

    v_nombre_funcion  varchar;
    v_consulta        varchar;
    v_parametros      record;
    v_respuesta       varchar;
    v_id_items        varchar[];
    v_where           varchar;
    v_ids             varchar;
    v_fecha           date;
    v_ids_depto       varchar;
    v_sql             varchar;
    v_aux             varchar;
    
    v_lugar   varchar = '';
    v_filtro      varchar;
    v_record      record;
    v_desc_nombre     varchar;

BEGIN
 
    v_nombre_funcion='kaf.f_reportes_af';
    v_parametros=pxp.f_get_record(p_tabla);
  
    /*********************************   
     #TRANSACCION:  'SKA_RESDEP_SEL'
     #DESCRIPCION:  Reporte de depreciacion
     #AUTOR:        RCM
     #FECHA:        09/05/2016
    ***********************************/
  
    if(p_transaccion='SKA_RESDEP_SEL') then

        begin
            
            --------------------------------
            -- 0. VALIDACION DE PARAMETROS
            --------------------------------
            if v_parametros.id_movimiento is null then
                if v_parametros.fecha is null or v_parametros.ids_depto is null then
                    raise exception 'Parametros invalidos';
                end if;
            end if;


            --------------------------------------------------------------------------
            -- 1. IDENTIFICAR ACTIVOS FIJOS/REVALORIZACIONES EN BASE A LOS PARAMETROS
            --------------------------------------------------------------------------
            v_fecha = v_parametros.fecha;
            v_ids_depto = v_parametros.ids_depto;

            if p_id_movimiento is not null then
                select fecha_hasta, id_depto
                into v_fecha, v_ids_depto
                from kaf.tmovimiento
                where id_movimiento = p_id_movimiento;
            end if;

            --Creacion de tabla temporal para almacenar los IDs de los activos fijos
            create temp table tt_kaf_rep_dep (
                id_activo_fijo integer,
                id_activo_fijo_valor integer,
                id_movimiento_af_dep integer
            ) on commit drop;

            if p_id_movimiento is not null then

                insert into tt_kaf_rep_dep (id_activo_fijo,id_activo_fijo_valor,id_movimiento_af_dep)
                select maf.id_activo_fijo, mafdep.id_activo_fijo_valor, mafdep.id_movimiento_af_dep
                from kaf.tmovimiento_af maf
                inner join kaf.tmovimiento_af_dep mafdep
                on mafdep.id_movimiento_af = maf.id_movimiento_af
                where maf.id_movimiento = p_id_movimiento;
            
            else

                v_sql = 'insert into tt_kaf_rep_dep (id_activo_fijo,id_activo_fijo_valor,id_movimiento_af_dep)
                    select id_activo_fijo,id_activo_fijo_valor,id_movimiento_af_dep
                    from (
                    select
                    maf.id_activo_fijo, mafdep.id_activo_fijo_valor, mafdep.id_movimiento_af_dep, max(mafdep.fecha)
                    from kaf.tmovimiento_af_dep mafdep
                    inner join kaf.tmovimiento_af maf
                    on maf.id_movimiento_af = mafdep.id_movimiento_af
                    inner join kaf.tmovimiento mov
                    on mov.id_movimiento = maf.id_movimiento
                    where mov.estado = ''finalizado''
                    and mafdep.fecha <= '''||v_fecha||'''
                    and mov.id_depto = ANY(ARRAY['||v_parametros.ids_depto||'])
                    group by maf.id_activo_fijo,mafdep.id_activo_fijo_valor,mafdep.id_movimiento_af_dep
                    ) dd';

                execute(v_sql);

            end if;
            
            ---------------------------------------
            -- 2. CONSULTA EN FORMATO DEL REPORTE
            ---------------------------------------
            v_consulta = 'select
                    actval.codigo, af.denominacion, actval.fecha_ini_dep as ''fecha_inc'', actval.monto_vigente_orig as ''valor_original'',
                    mafdep.monto_actualiz - actval.monto_vigente_orig as ''inc_actualiz'', mafdep.monto_actualiz as ''valor_actualiz'',
                    actval.vida_util_orig, mafdep.vida_util, 
                    (select o_dep_acum_ant from kaf.f_get_datos_deprec_ant(mafdep.id_activo_fijo_valor,mafdep.fecha)) as ''dep_acum_gestion_ant'',
                    (select o_inc_dep_actualiz from kaf.f_get_datos_deprec_ant(mafdep.id_activo_fijo_valor,mafdep.fecha)) as ''dep_acum_gestion_ant_actualiz'',
                    (mafdep.depreciacion_aum - select o_dep_acum_ant from kaf.f_get_datos_deprec_ant(mafdep.id_activo_fijo_valor,mafdep.fecha)) as dep_gestion,
                    mafdep.depreciacion_aum,
                    mafdep.monto_vigente
                    from tt_kaf_rep_dep rep
                    inner join kaf.tactivo_fijo af
                    on af.id_activo_fijo = rep.id_activo_fijo
                    inner join kaf.tactivo_fijo_valores actval
                    on actval.id_activo_fijo_valor = rep.id_activo_fijo_valor
                    inner join kaf.tmovimiento_af_dep mafdep
                    on mafdep.id_movimiento_af_dep = rep.id_movimiento_af_dep';
            

            return v_consulta;  
        end;

    /*********************************   
     #TRANSACCION:  'SKA_KARD_SEL'
     #DESCRIPCION:  Reporte de kardex de activo fijo
     #AUTOR:        RCM
     #FECHA:        27/07/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_KARD_SEL') then

        begin

            v_aux = 'no';
            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_aux = 'si';
                end if;
            end if;

            v_consulta = 'select
                        af.codigo,
                        af.denominacion,
                        af.fecha_compra,
                        af.fecha_ini_dep,
                        af.estado,
                        af.vida_util_original,
                        (af.vida_util_original/12) as porcentaje_dep,
                        af.ubicacion,
                        af.monto_compra_orig,
                        mon.moneda,
                        af.nro_cbte_asociado,
                        af.fecha_cbte_asociado,
                        cla.codigo_completo_tmp as cod_clasif, cla.nombre as desc_clasif,
                        mdep.descripcion as metodo_dep,
                        param.f_get_tipo_cambio(3,af.fecha_compra,''O'') as ufv_fecha_compra,
                        fun.desc_funcionario2 as responsable,
                        orga.f_get_cargo_x_funcionario_str(coalesce(mov.id_funcionario_dest,coalesce(mov.id_funcionario,af.id_funcionario)),now()::date) as cargo,
                        mov.fecha_mov, mov.num_tramite, 
                        proc.descripcion as desc_mov,
                        proc.codigo as codigo_mov,
                        param.f_get_tipo_cambio(3,mov.fecha_mov,''O'') as ufv_mov,
                        af.id_activo_fijo,
                        mov.id_movimiento,
                        coalesce(afvi.monto_vigente_orig_100,afvi.monto_vigente_orig) as monto_vigente_orig_100,
                        afvi.monto_vigente_orig,
                        afvi.monto_vigente_ant,
                        afvi.monto_actualiz - afvi.monto_vigente_ant actualiz_monto_vigente,
                        afvi.monto_actualiz as monto_actualiz,
                        afvi.vida_util_orig - afvi.vida_util as vida_util_usada,
                        afvi.vida_util,
                        (select
                        afvi1.depreciacion_acum
                        from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||v_parametros.fecha_hasta ||'''),'''||v_aux||''') afvi1
                        where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                        and afvi.id_moneda = 1 ) as dep_acum_gest_ant,
                        afvi.depreciacion_per - (select
                                                afvi1.depreciacion_acum
                                                from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||v_parametros.fecha_hasta ||'''),'''||v_aux||''') afvi1
                                                where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                                                and afvi.id_moneda = 1) as act_dep_gest_ant,
                        afvi.depreciacion_per,
                        afvi.depreciacion_acum,
                        afvi.monto_vigente
                        from kaf.tmovimiento_af movaf
                        inner join kaf.tmovimiento mov
                        on mov.id_movimiento = movaf.id_movimiento
                        and mov.estado <> ''cancelado''
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = movaf.id_activo_fijo
                        left join kaf.f_activo_fijo_dep_x_fecha_afv('''||v_parametros.fecha_hasta ||''','''||v_aux||''') afvi
                        on afvi.id_activo_fijo = af.id_activo_fijo
                        and afvi.id_moneda = '|| v_parametros.id_moneda ||'
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = af.id_clasificacion
                        left join orga.vfuncionario fun
                        on fun.id_funcionario = coalesce(mov.id_funcionario_dest,coalesce(mov.id_funcionario,af.id_funcionario))
                        inner join param.tmoneda mon
                        on mon.id_moneda = af.id_moneda_orig
                        left join param.tcatalogo mdep
                        on mdep.id_catalogo = cla.id_cat_metodo_dep
                        left join param.tcatalogo proc
                        on proc.id_catalogo = mov.id_cat_movimiento
                        where movaf.id_activo_fijo = '||v_parametros.id_activo_fijo||'
                        and mov.fecha_mov between '''||v_parametros.fecha_desde ||''' and ''' ||v_parametros.fecha_hasta||''' ';

            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_consulta = v_consulta || ' and mov.estado = ''finalizado'' ';
                end if;
            end if;

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' and '||v_parametros.filtro;
                v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            else
                v_consulta = v_consulta||' order by mov.fecha_mov';
            end if;
            
            if v_parametros.id_activo_fijo = 48258 then
                raise notice '%',v_consulta;
            end if;

            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_KARD_CONT'
     #DESCRIPCION:  Reporte de kardex de activo fijo
     #AUTOR:        RCM
     #FECHA:        27/07/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_KARD_CONT') then

        begin

            v_aux = 'no';
            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_aux = 'si';
                end if;
            end if;

            v_consulta = 'select
                        count(1) as total
                        from kaf.tmovimiento_af movaf
                        inner join kaf.tmovimiento mov
                        on mov.id_movimiento = movaf.id_movimiento
                        and mov.estado <> ''cancelado''
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = movaf.id_activo_fijo
                        left join kaf.f_activo_fijo_dep_x_fecha_afv('''||v_parametros.fecha_hasta ||''','''||v_aux||''') afvi
                        on afvi.id_activo_fijo = af.id_activo_fijo
                        and afvi.id_moneda = '|| v_parametros.id_moneda ||'
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = af.id_clasificacion
                        left join orga.vfuncionario fun
                        on fun.id_funcionario = coalesce(mov.id_funcionario_dest,coalesce(mov.id_funcionario,af.id_funcionario))
                        inner join param.tmoneda mon
                        on mon.id_moneda = af.id_moneda_orig
                        left join param.tcatalogo mdep
                        on mdep.id_catalogo = cla.id_cat_metodo_dep
                        left join param.tcatalogo proc
                        on proc.id_catalogo = mov.id_cat_movimiento
                        where movaf.id_activo_fijo = '||v_parametros.id_activo_fijo||'
                        and mov.fecha_mov between '''||v_parametros.fecha_desde ||'''and ''' ||v_parametros.fecha_hasta||''' ';

            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_consulta = v_consulta || ' and mov.estado = ''finalizado'' ';
                end if;
            end if;

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' and '||v_parametros.filtro;
            end if;
            

            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_GRALAF_SEL'
     #DESCRIPCION:  Reporte Gral de activos fijos con el filtro general
     #AUTOR:        RCM
     #FECHA:        27/07/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_GRALAF_SEL') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);
            v_consulta='';

            v_aux = 'no';
            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_aux = 'si';
                end if;
            end if;

            if v_parametros.reporte = 'rep.sasig' then

                v_consulta = 'select
                            afij.codigo,
                            afij.denominacion,
                            afij.descripcion,
                            afvi.fecha_ini_dep,
                            --afij.fecha_ini_dep,
                            --afij.monto_compra_orig_100,
                            --afij.monto_compra_orig,
                            afij.ubicacion,
                            fun.desc_funcionario2 as responsable,
                            coalesce(afvi.monto_vigente_orig_100,coalesce(afvi.monto_vigente_orig,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig_100,'''||now()||'''::date,''O'',2))) as monto_vigente_orig_100,
                            coalesce(afvi.monto_vigente_orig,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig_100,'''||now()||'''::date,''O'',2)) as monto_vigente_orig,
                            coalesce(afvi.monto_vigente_ant,0) as monto_vigente_ant,
                            coalesce(afvi.monto_actualiz - afvi.monto_vigente_ant,0) as actualiz_monto_vigente,
                            coalesce(afvi.monto_actualiz,0) as monto_actualiz,
                            coalesce(afvi.vida_util_orig - afvi.vida_util,0) as vida_util_usada,
                            coalesce(afvi.vida_util,afij.vida_util_original) as vida_util,
                            coalesce((select
                            afvi1.depreciacion_acum
                            from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||now()||'''::date),'''||v_aux||''') afvi1
                            where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                            and afvi.id_moneda = '||v_parametros.id_moneda||' ),0) as dep_acum_gest_ant,
                            coalesce(afvi.depreciacion_per - (select
                                                    afvi1.depreciacion_acum
                                                    from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||now()||'''::date),'''||v_aux||''') afvi1
                                                    where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                                                    and afvi.id_moneda = '||v_parametros.id_moneda||'),0) as act_dep_gest_ant,
                            coalesce(afvi.depreciacion_per,0) as depreciacion_per,
                            coalesce(afvi.depreciacion_acum,0) as depreciacion_acum,
                            coalesce(afvi.monto_vigente,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig,'''||now()||'''::date,''O'',2)) as monto_vigente
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            left join kaf.f_activo_fijo_dep_x_fecha_afv('''||now()||'''::date,'''||v_aux||''') afvi
                            on afvi.id_activo_fijo = afij.id_activo_fijo
                            and afvi.id_moneda = '||v_parametros.id_moneda||'
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''si''
                            ';


            elsif v_parametros.reporte = 'rep.asig' then

                v_consulta = 'select
                            afij.codigo,
                            afij.denominacion,
                            afij.descripcion,
                            afvi.fecha_ini_dep,
                            --afij.fecha_ini_dep,
                            --afij.monto_compra_orig_100,
                            --afij.monto_compra_orig,
                            afij.ubicacion,
                            fun.desc_funcionario2 as responsable,
                            coalesce(afvi.monto_vigente_orig_100,coalesce(afvi.monto_vigente_orig,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig_100,'''||now()||'''::date,''O'',2))) as monto_vigente_orig_100,
                            coalesce(afvi.monto_vigente_orig,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig_100,'''||now()||'''::date,''O'',2)) as monto_vigente_orig,
                            coalesce(afvi.monto_vigente_ant,0) as monto_vigente_ant,
                            coalesce(afvi.monto_actualiz - afvi.monto_vigente_ant,0) as actualiz_monto_vigente,
                            coalesce(afvi.monto_actualiz,0) as monto_actualiz,
                            coalesce(afvi.vida_util_orig - afvi.vida_util,0) as vida_util_usada,
                            coalesce(afvi.vida_util,afij.vida_util_original) as vida_util,
                            coalesce((select
                            afvi1.depreciacion_acum
                            from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||now()||'''::date),'''||v_aux||''') afvi1
                            where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                            and afvi.id_moneda = '||v_parametros.id_moneda||' ),0) as dep_acum_gest_ant,
                            coalesce(afvi.depreciacion_per - (select
                                                    afvi1.depreciacion_acum
                                                    from kaf.f_activo_fijo_dep_x_fecha_afv(kaf.f_get_fecha_gestion_ant('''||now()||'''::date),'''||v_aux||''') afvi1
                                                    where afvi1.id_activo_fijo_valor = afvi.id_activo_fijo_valor
                                                    and afvi.id_moneda = '||v_parametros.id_moneda||'),0) as act_dep_gest_ant,
                            coalesce(afvi.depreciacion_per,0) as depreciacion_per,
                            coalesce(afvi.depreciacion_acum,0) as depreciacion_acum,
                            coalesce(afvi.monto_vigente,param.f_convertir_moneda(afij.id_moneda_orig, '||v_parametros.id_moneda||',afij.monto_compra_orig,'''||now()||'''::date,''O'',2)) as monto_vigente
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            left join kaf.f_activo_fijo_dep_x_fecha_afv('''||now()||'''::date,'''||v_aux||''') afvi
                            on afvi.id_activo_fijo = afij.id_activo_fijo
                            and afvi.id_moneda = '||v_parametros.id_moneda||'
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''
                            ';
            else
                raise exception 'Reporte desconocido';
            end if;

            --Si la consulta es para un grid, aumenta los parametros para la páginación
            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' and '||v_parametros.filtro;
                v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;
            else
                v_consulta:=v_consulta||' limit 2000';
            end if;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_GRALAF_CONT'
     #DESCRIPCION:  Reporte de kardex de activo fijo
     #AUTOR:        RCM
     #FECHA:        27/07/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_GRALAF_CONT') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);
            v_consulta='';

            v_aux = 'no';
            if(pxp.f_existe_parametro(p_tabla,'af_estado_mov')) then
                if v_parametros.af_estado_mov <> 'todos' then
                    v_aux = 'si';
                end if;
            end if;

            if v_parametros.reporte = 'rep.sasig' then

                v_consulta = 'select
                            count(1) as total
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            left join kaf.f_activo_fijo_dep_x_fecha_afv('''||now()||'''::date,'''||v_aux||''') afvi
                            on afvi.id_activo_fijo = afij.id_activo_fijo
                            and afvi.id_moneda = '||v_parametros.id_moneda||'
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''si''
                            and ';

            elsif v_parametros.reporte = 'rep.asig' then
                 v_consulta = 'select
                            count(1) as total
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            left join kaf.f_activo_fijo_dep_x_fecha_afv('''||now()||'''::date,'''||v_aux||''') afvi
                            on afvi.id_activo_fijo = afij.id_activo_fijo
                            and afvi.id_moneda = '||v_parametros.id_moneda||'
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''
                            and ';
            else
                raise exception 'Reporte desconocido';
            end if;

            --Se aumenta el filtro para el listado
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_DEPDEPTO_SEL'
     #DESCRIPCION:  Reporte de kardex de activo fijo
     #AUTOR:        RCM
     #FECHA:        15/09/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_DEPDEPTO_SEL') then

        begin

            v_consulta = 'select
                        mov.id_depto, dep.codigo || '' - '' || dep.nombre as desc_depto, max(mov.fecha_hasta) as fecha_max_dep
                        from kaf.tmovimiento mov
                        inner join param.tcatalogo cat
                        on cat.id_catalogo = mov.id_cat_movimiento
                        inner join param.tdepto dep
                        on dep.id_depto = mov.id_depto
                        where cat.codigo = ''deprec''
                        --and mov.estado = ''finalizado''
                        ';

            if coalesce(v_parametros.deptos,'') <> '' and coalesce(v_parametros.deptos,'') <> '%' then
                v_consulta = v_consulta || ' and mov.id_depto in ('||v_parametros.deptos||') ';
            end if;


            v_consulta = v_consulta || ' group by mov.id_depto, dep.codigo, dep.nombre';

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RASIG_SEL'
     #DESCRIPCION:  Reporte Gral de activos fijos con el filtro general
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RASIG_SEL') then

        begin
        
            select tl.nombre 
            into v_lugar
            from param.tlugar tl 
            where id_lugar = v_parametros.id_lugar::integer;
            
            if (v_lugar is null) then
                v_lugar = '';
            end if;
        --raise exception 'v_parametros.filtro: %',v_parametros.filtro;
            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;
    
            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;
            
            execute(v_consulta);
            
            if(v_parametros.tipo = 'lug_fun')then
    v_filtro = ' afij.id_funcionario in (SELECT tf.id_funcionario
                     FROM orga.vfuncionario_cargo_lugar tf
                                                     where  (tf.fecha_finalizacion > now()::date or tf.fecha_finalizacion is null) and tf.id_oficina in (select id_oficina from orga.toficina where id_lugar = '||v_parametros.id_lugar||'))
                            and afij.en_deposito = ''no'' and afij.id_depto = '||v_parametros.id_depto; 
            else
                v_filtro = ' afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''';
            end if;
    
            --Consulta
            v_consulta = 'select
                            afij.codigo,
                            '''||v_lugar||'''::varchar as lugar,
                            cla.nombre as desc_clasificacion,
                            afij.denominacion,
                            afij.descripcion,
                            afij.estado,
                            afij.observaciones,
                            ''''::varchar as ubicacion,
                            afij.fecha_asignacion,
                            ofi.nombre,
                            fun.desc_funcionario2 as responsable,
                            orga.f_get_cargo_x_funcionario_str(afij.id_funcionario,now()::date,''oficial'') as cargo,
                            dep.codigo ||'' - ''||dep.nombre
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
                            inner join param.tdepto dep on dep.id_depto = afij.id_depto
                            where '||v_filtro;
    
            v_consulta:=v_consulta||' order by fun.desc_funcionario2, ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion;
            --raise EXCEPTION 'v_consulta: %', v_consulta;
            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RASIG_CONT'
     #DESCRIPCION:  Reporte Gral de activos fijos con el filtro general
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RASIG_CONT') then

        begin
        
            select tl.nombre 
            into v_lugar
            from param.tlugar tl 
            where id_lugar = v_parametros.id_lugar::integer;
            
            if (v_lugar is null) then
                v_lugar = '';
            end if;

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);
            
            if(v_parametros.tipo = 'lug_fun')then
    v_filtro = ' afij.id_funcionario in (SELECT tf.id_funcionario
                     FROM orga.vfuncionario_cargo_lugar tf
                                                     where (tf.fecha_finalizacion > now()::date or tf.fecha_finalizacion is null) and tf.id_oficina in (select id_oficina from orga.toficina where id_lugar = '||v_parametros.id_lugar||'))
                            and afij.en_deposito = ''no''and afij.id_depto = '||v_parametros.id_depto;  
            else
                v_filtro = ' afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''';
            end if;

            --Consulta
            v_consulta = 'select
                            count(1) as total
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi
                            on ofi.id_oficina = afij.id_oficina
                            inner join param.tdepto dep
                            on dep.id_depto = afij.id_depto
                            where '||v_filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RSINASIG_SEL'
     #DESCRIPCION:  Reporte de Activos Fijos sin Asignar
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RSINASIG_SEL') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);

            --Consulta
            v_consulta = 'select
                            afij.codigo,
                            cla.nombre as desc_clasificacion,
                            afij.denominacion,
                            afij.descripcion,
                            afij.estado,
                            afij.observaciones,
                            afij.ubicacion,
                            afij.fecha_asignacion,
                            ofi.nombre,
                            fun.desc_funcionario2 as responsable
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi
                            on ofi.id_oficina = afij.id_oficina
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''si''
                            ';
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RSINASIG_CONT'
     #DESCRIPCION:  Reporte de Activos Fijos en Depósito
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RSINASIG_CONT') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);

            --Consulta
            v_consulta = 'select
                            count(1) as total
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi
                            on ofi.id_oficina = afij.id_oficina
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''si''
                            ';

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RENDEP_SEL'
     #DESCRIPCION:  Reporte activos fijos asignados en Depósito
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RENDEP_SEL') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);

            --Consulta
            v_consulta = 'select
                            afij.codigo,
                            cla.nombre as desc_clasificacion,
                            afij.denominacion,
                            afij.descripcion,
                            afij.estado,
                            afij.observaciones,
                            afij.ubicacion,
                            afij.fecha_asignacion,
                            ofi.nombre,
                            fun.desc_funcionario2 as responsable
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi
                            on ofi.id_oficina = afij.id_oficina
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''
                            ';

            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RENDEP_CONT'
     #DESCRIPCION:  Reporte activos fijos asignados en Depósito
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RENDEP_CONT') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);

            --Consulta
            v_consulta = 'select
                            count(1) as total
                            from kaf.tactivo_fijo afij
                            inner join kaf.tclasificacion cla
                            on cla.id_clasificacion = afij.id_clasificacion
                            left join orga.vfuncionario fun
                            on fun.id_funcionario = afij.id_funcionario
                            inner join orga.toficina ofi
                            on ofi.id_oficina = afij.id_oficina
                            where afij.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                            and afij.en_deposito = ''no''
                            ';

            --Devuelve la respuesta
            return v_consulta;

        end;


    /*********************************   
     #TRANSACCION:  'SKA_RDETDEP_SEL'
     #DESCRIPCION:  Reporte del Detalle de depreciación
     #AUTOR:        RCM
     #FECHA:        16/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RDETDEP_SEL') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);


            --Consulta
            v_consulta:=' SELECT 
                              daf.id_moneda_dep,
                              mod.descripcion as desc_moneda,
                              daf.gestion_final::INTEGER,
                              daf.tipo,
                              cr.nombre_raiz,
                              daf.fecha_ini_dep, 
                              daf.id_movimiento,
                              daf.id_movimiento_af,
                              daf.id_activo_fijo_valor,
                              daf.id_activo_fijo,
                              daf.codigo,
                              daf.id_clasificacion,  
                              daf.descripcion,  
                              daf.monto_vigente_orig,
                              daf.monto_vigente_inicial,
                              daf.monto_vigente_final,  
                              daf.monto_actualiz_inicial,
                              daf.monto_actualiz_final,
                              daf.depreciacion_acum_inicial,
                              daf.depreciacion_acum_final,  
                              daf.aitb_activo,
                              daf.aitb_depreciacion_acumulada,
                              daf.vida_util_orig,
                              daf.vida_util_inicial,
                              daf.vida_util_final,
                              daf.vida_util_orig - daf.vida_util_final as vida_util_trans,  
                              cr.codigo_raiz,
                              cr.id_claificacion_raiz,                              
                              daf.depreciacion_per_final,
                              daf.depreciacion_per_actualiz_final
                            
                          FROM kaf.vdetalle_depreciacion_activo daf
                          INNER  JOIN kaf.vclaificacion_raiz cr on cr.id_clasificacion = daf.id_clasificacion
                          INNER JOIN kaf.tmoneda_dep mod on mod.id_moneda_dep = daf.id_moneda_dep
                          WHERE daf.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                        and daf.id_moneda = ' ||v_parametros.id_moneda||'
                          ORDER BY 
                              daf.id_moneda_dep,   
                              daf.gestion_final, 
                              daf.tipo,   
                              cr.id_claificacion_raiz, 
                              daf.id_clasificacion,
                              id_activo_fijo_valor ,                                
                              daf.fecha_ini_dep';


            v_consulta:=v_consulta||' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_RDETDEP_CONT'
     #DESCRIPCION:  Reporte Detalle de depreciación
     #AUTOR:        RCM
     #FECHA:        16/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RDETDEP_CONT') then

        begin

            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;

            execute(v_consulta);

            --Consulta
            v_consulta:=' SELECT count(1) as total
                          FROM kaf.vdetalle_depreciacion_activo daf
                          INNER  JOIN kaf.vclaificacion_raiz cr on cr.id_clasificacion = daf.id_clasificacion
                          INNER JOIN kaf.tmoneda_dep mod on mod.id_moneda_dep = daf.id_moneda_dep
                          WHERE daf.id_activo_fijo in (select id_activo_fijo
                                                        from tt_af_filtro)
                        and daf.id_moneda = ' ||v_parametros.id_moneda;

            --Devuelve la respuesta
            return v_consulta;

        end;


    /*********************************   
     #TRANSACCION:  'SKA_RDEPREC_SEL'
     #DESCRIPCION:  Reporte del Detalle de depreciación
     #AUTOR:        RCM
     #FECHA:        18/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RDEPREC_SEL') then

        begin 
            
            --Creacion de tabla temporal de los actios fijos a filtrar
            create temp table tt_af_filtro (
                id_activo_fijo integer
            ) on commit drop;

            v_consulta = 'insert into tt_af_filtro
                        select afij.id_activo_fijo
                        from kaf.tactivo_fijo afij
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = afij.id_clasificacion
                        where '||v_parametros.filtro;
                        
                        
              --Grover activos del exterior
               /*afij.id_activo_fijo in (
                        
    Select af.id_activo_fijo
            --,af.codigo, af.denominacion, af.descripcion, 
            --of.nombre, param.f_get_id_lugar_pais(of.id_lugar)
            from kaf.tactivo_fijo af
            inner join orga.tfuncionario fun on fun.id_funcionario=af.id_funcionario
            inner join orga.tuo_funcionario uf on uf.id_funcionario=fun.id_funcionario
            inner join orga.tcargo car on car.id_cargo=uf.id_cargo
            inner join orga.toficina of on of.id_oficina=car.id_oficina
            where param.f_get_id_lugar_pais(of.id_lugar)<>1)
            
            and */
                        
            
            execute(v_consulta);
    
            
            --Creación de la tabla con los datos de la depreciación
            create temp table tt_detalle_depreciacion (
                id_activo_fijo_valor integer,
                codigo varchar(50),
                denominacion varchar(500),
                fecha_ini_dep date,
                monto_vigente_orig_100 numeric(18,2),
                monto_vigente_orig numeric(18,2),
                inc_actualiz numeric(18,2),
                monto_actualiz numeric(18,2),
                vida_util_orig integer,
                vida_util integer,
                depreciacion_acum_gest_ant numeric(18,2),
                depreciacion_acum_actualiz_gest_ant numeric(18,2),
                depreciacion_per numeric(18,2),
                depreciacion_acum numeric(18,2),
                monto_vigente numeric(18,2),
                codigo_padre varchar(15),
                denominacion_padre varchar(100),
                tipo varchar(50),
                tipo_cambio_fin numeric,
                id_moneda_act integer,
                id_activo_fijo_valor_original integer,
                codigo_ant varchar(50),
                id_moneda integer,
                id_centro_costo integer,
                id_activo_fijo integer,
                codigo_activo varchar,
                afecta_concesion varchar,
                id_activo_fijo_valor_padre integer,
                depreciacion numeric(18,2)
            ) on commit drop;

            --Carga los datos en la tabla temporal
            insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            --afv.fecha_ini_dep,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.fecha_ini_dep
                else (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as fecha_ini_dep,
            --coalesce(afv.monto_vigente_orig_100,afv.monto_vigente_orig),
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig_100
                else (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original/*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as monto_vigente_orig_100,
--            afv.monto_vigente_orig,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as monto_vigente_orig,
            --(coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) as inc_actualiz,
            case 
                when (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) < 0 then 0
                else (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0))
            end as inc_actualiz,
            mdep.monto_actualiz,
            /*case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig * mdep.factor
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original) * mdep.factor
            end as monto_actualiz,*/
            afv.vida_util_orig, mdep.vida_util,
            mdep.depreciacion_per,
            mdep.depreciacion_acum,
            mdep.monto_vigente,
            substr(afv.codigo,1, position('.' in afv.codigo)-1) as codigo_padre,
            (select nombre from kaf.tclasificacion where codigo_completo_tmp = substr(afv.codigo,1, position('.' in afv.codigo)-1)) as denominacion_padre,
            afv.tipo,
            mdep.tipo_cambio_fin,
            mon.id_moneda_act,
            afv.id_activo_fijo_valor_original,
            af.codigo_ant,
            mon.id_moneda,
            af.id_centro_costo,
            af.id_activo_fijo,
            af.codigo,
            af.afecta_concesion,
            mdep.depreciacion
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where date_trunc('month',mdep.fecha) = date_trunc('month',v_parametros.fecha_hasta::date)
            and mdep.id_moneda_dep = v_parametros.id_moneda
            and af.id_activo_fijo in (select id_activo_fijo from tt_af_filtro)
                                                            --and afv.codigo not like '%-G%'
            and af.estado <> 'eliminado';
            
        
            insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            afv.fecha_ini_dep,
            afv.monto_vigente_orig_100,
            afv.monto_vigente_orig,
            --(coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) as inc_actualiz,
            case 
                  when (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) < 0 then 0
                  else (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0))
            end as inc_actualiz,
            mdep.monto_actualiz,
            /*case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig * mdep.factor
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original) * mdep.factor
            end as monto_actualiz,*/
            afv.vida_util_orig, mdep.vida_util,
            mdep.depreciacion_per,
            mdep.depreciacion_acum,
            mdep.monto_vigente,
            substr(afv.codigo,1, position('.' in afv.codigo)-1) as codigo_padre,
            (select nombre from kaf.tclasificacion where codigo_completo_tmp = substr(afv.codigo,1, position('.' in afv.codigo)-1)) as denominacion_padre,
            afv.tipo,
            mdep.tipo_cambio_fin,
            mon.id_moneda_act,
            afv.id_activo_fijo_valor_original,
            af.codigo_ant,
            mon.id_moneda,
            af.id_centro_costo,
            af.id_activo_fijo,
            af.codigo,
            af.afecta_concesion,
            mdep.depreciacion
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where afv.fecha_fin is not null
            and  not exists (select from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor and tipo<>'alta')
            and afv.codigo not in (select codigo
                                                from tt_detalle_depreciacion)
            --and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor /*and tipo = 'alta'*/ )
            and date_trunc('month',mdep.fecha) <> date_trunc('month',v_parametros.fecha_hasta::date)
            and date_trunc('month',mdep.fecha) < date_trunc('month',v_parametros.fecha_hasta::date) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta::date)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta::date)
            and date_trunc('month',mdep.fecha) = (select max(fecha)
                                                    from kaf.tmovimiento_af_dep
                                                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                                                    and id_moneda_dep = mdep.id_moneda_dep
                                                    and date_trunc('month',fecha) <> date_trunc('month',v_parametros.fecha_hasta::date)
                                                    and date_trunc('month',fecha) < date_trunc('month',v_parametros.fecha_hasta::date) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta)
                                                )
            and mdep.id_moneda_dep = v_parametros.id_moneda
            and af.id_activo_fijo in (select id_activo_fijo from tt_af_filtro)
            and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor
                                                from tt_detalle_depreciacion)
            and af.estado <> 'eliminado'
            and af.fecha_baja >= v_parametros.fecha_hasta::date;     
            
            --------------------------------
            --------------------------------
            insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            --afv.fecha_ini_dep,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.fecha_ini_dep
                else (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as fecha_ini_dep,
            --coalesce(afv.monto_vigente_orig_100,afv.monto_vigente_orig),
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig_100
                else (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as monto_vigente_orig_100,
--            afv.monto_vigente_orig,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
            end as monto_vigente_orig,
            --(coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) as inc_actualiz,
            case 
                when (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) < 0 then 0
                else (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0))
            end as inc_actualiz,
            mdep.monto_actualiz,
            /*case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig * mdep.factor
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original) * mdep.factor
            end as monto_actualiz,*/
            afv.vida_util_orig, mdep.vida_util,
            mdep.depreciacion_per,
            mdep.depreciacion_acum,
            mdep.monto_vigente,
            substr(afv.codigo,1, position('.' in afv.codigo)-1) as codigo_padre,
            (select nombre from kaf.tclasificacion where codigo_completo_tmp = substr(afv.codigo,1, position('.' in afv.codigo)-1)) as denominacion_padre,
            afv.tipo,
            mdep.tipo_cambio_fin,
            mon.id_moneda_act,
            afv.id_activo_fijo_valor_original,
            af.codigo_ant,
            mon.id_moneda,
            af.id_centro_costo,
            af.id_activo_fijo,
            af.codigo,
            af.afecta_concesion,
            mdep.depreciacion
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where af.estado in ('baja','retiro')
            and mdep.fecha >= '01-01-2017'
            and mdep.fecha = (select max(fecha) from kaf.tmovimiento_af_dep mdep1
                                where mdep1.id_activo_fijo_valor = afv.id_activo_fijo_valor
                                and fecha between ('01-01-'||extract(year from mdep.fecha))::date and v_parametros.fecha_hasta::date)
            
            and mdep.id_moneda_dep = v_parametros.id_moneda
            and af.id_activo_fijo in (select id_activo_fijo from tt_af_filtro)
                                                            --and afv.codigo not like '%-G%'
            and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor
                                                from tt_detalle_depreciacion);
            --------------------------------
            --------------------------------
            
                   

            ----
            /*insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            afv.fecha_ini_dep,
            coalesce(afv.monto_vigente_orig_100,afv.monto_vigente_orig),
            afv.monto_vigente_orig,
            (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) as inc_actualiz,
            mdep.monto_actualiz,
            afv.vida_util_orig, afv.vida_util,
            /*coalesce((select depreciacion_acum
                    from kaf.tmovimiento_af_dep
                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                    and id_moneda_dep = mdep.id_moneda_dep
                    and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)),0) as depreciacion_acum_gest_ant,
            coalesce((select depreciacion_acum_actualiz
                    from kaf.tmovimiento_af_dep
                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                    and id_moneda_dep = mdep.id_moneda_dep
                    and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)),0) as depreciacion_acum_actualiz_gest_ant,*/
            mdep.depreciacion_per,
            mdep.depreciacion_acum,
            mdep.monto_vigente,
            substr(afv.codigo,1, position('.' in afv.codigo)-1) as codigo_padre,
            (select nombre from kaf.tclasificacion where codigo_completo_tmp = substr(afv.codigo,1, position('.' in afv.codigo)-1)) as denominacion_padre
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            where date_trunc('month',mdep.fecha) <> date_trunc('month',v_parametros.fecha_hasta)
            and date_trunc('month',mdep.fecha) < date_trunc('month',v_parametros.fecha_hasta) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta)
            and date_trunc('month',mdep.fecha) = (select max(fecha)
                                                    from kaf.tmovimiento_af_dep
                                                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                                                    and id_moneda_dep = mdep.id_moneda_dep
                                                    and date_trunc('month',fecha) <> date_trunc('month',v_parametros.fecha_hasta)
                                                    and date_trunc('month',fecha) < date_trunc('month',v_parametros.fecha_hasta) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta)
                                                )
            and mdep.id_moneda_dep = v_parametros.id_moneda
            and af.id_activo_fijo in (select id_activo_fijo from tt_af_filtro)
            and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor
                                                from tt_detalle_depreciacion)
                                                and afv.codigo not like '%-G%'
            and af.estado <> 'eliminado';*/
            
            --Obtiene los datos de gestion anterior
            /*update tt_detalle_depreciacion set
            depreciacion_acum_gest_ant = coalesce((
                select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                and id_moneda_dep = v_parametros.id_moneda
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)
            ),0),
            depreciacion_acum_actualiz_gest_ant = coalesce((
                select depreciacion_acum_actualiz
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                and id_moneda_dep = v_parametros.id_moneda
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)
            ),0);*/
            
            --------------------------------------------------
            --------------------------------------------------
            update tt_detalle_depreciacion set
            id_activo_fijo_valor_padre = kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor);
            
            update tt_detalle_depreciacion set
            fecha_ini_dep = (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
            monto_vigente_orig_100 = (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
            monto_vigente_orig = (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre)
            where coalesce(id_activo_fijo_valor_original,0) <> 0;
            
            --------------------------------------------------
            --------------------------------------------------
            
            
            
            --Obtiene los datos de gestion anterior
            update tt_detalle_depreciacion set
            depreciacion_acum_gest_ant = coalesce((
                select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                and id_moneda_dep = v_parametros.id_moneda
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta::date)::integer -1 )::date)
            ),0),
            depreciacion_acum_actualiz_gest_ant = (((tt_detalle_depreciacion.tipo_cambio_fin/(param.f_get_tipo_cambio_v2(tt_detalle_depreciacion.id_moneda_act,tt_detalle_depreciacion.id_moneda /*v_parametros.id_moneda*/, ('31/12/'||extract(year from v_parametros.fecha_hasta::date)::integer -1)::date, 'O'))))-1)*(coalesce((
                            select depreciacion_acum
                            from kaf.tmovimiento_af_dep
                            where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                            and id_moneda_dep = v_parametros.id_moneda
                            and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)
                        ),0));
                        
            --Si la depreciación anterior es cero, busca la depreciación de su activo fijo valor original si es que tuviese
            update tt_detalle_depreciacion set
            depreciacion_acum_gest_ant = coalesce((
                select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre/*tt_detalle_depreciacion.id_activo_fijo_valor_original*/ /*kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor)*/
                and tipo = tt_detalle_depreciacion.tipo
                and id_moneda_dep = v_parametros.id_moneda
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta::date)::integer -1 )::date)
            ),0),
            depreciacion_acum_actualiz_gest_ant = (((tt_detalle_depreciacion.tipo_cambio_fin/(param.f_get_tipo_cambio_v2(tt_detalle_depreciacion.id_moneda_act,tt_detalle_depreciacion.id_moneda/*v_parametros.id_moneda*/, ('31/12/'||extract(year from v_parametros.fecha_hasta::date)::integer -1)::date, 'O'))))-1)*(coalesce((
                            select depreciacion_acum
                            from kaf.tmovimiento_af_dep
                            where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre/*tt_detalle_depreciacion.id_activo_fijo_valor_original*/  /*kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor)*/
                            and tipo = tt_detalle_depreciacion.tipo
                            and id_moneda_dep = v_parametros.id_moneda
                            and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta::date)::integer -1 )::date)
                        ),0))
            where coalesce(depreciacion_acum_gest_ant,0) = 0
            and id_activo_fijo_valor_original is not null;
            

            

            --Verifica si hay reg con tipo = ajuste_restar, y le cambia el signo
            update tt_detalle_depreciacion set
            monto_vigente_orig_100 = -1 * monto_vigente_orig_100,
            monto_vigente_orig = -1 * monto_vigente_orig,
            inc_actualiz = -1 * inc_actualiz,
            monto_actualiz = -1 * monto_actualiz,
            depreciacion_acum_gest_ant = -1 * depreciacion_acum_gest_ant,
            depreciacion_acum_actualiz_gest_ant = -1 * depreciacion_acum_actualiz_gest_ant,
            depreciacion_per = -1 * depreciacion_per,
            depreciacion_acum = -1 * depreciacion_acum,
            monto_vigente = -1 * monto_vigente
            where tipo = 'ajuste_restar';


                /*coalesce((select depreciacion_acum
                    from kaf.tmovimiento_af_dep
                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                    and id_moneda_dep = mdep.id_moneda_dep
                    and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)),0) as depreciacion_acum_gest_ant,
            coalesce((select depreciacion_acum_actualiz
                    from kaf.tmovimiento_af_dep
                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                    and id_moneda_dep = mdep.id_moneda_dep
                    and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta)::integer -1 )::date)),0) as depreciacion_acum_actualiz_gest_ant,*/

            
            

           

            --Creación de la tabla con la agrupación y totales
            create temp table tt_detalle_depreciacion_totales (
                codigo varchar(50),
                denominacion varchar(500),
                fecha_ini_dep date,
                monto_vigente_orig_100 numeric(24,2),
                monto_vigente_orig numeric(24,2),
                inc_actualiz numeric(24,2),
                monto_actualiz numeric(24,2),
                vida_util_orig integer,
                vida_util integer,
                depreciacion_acum_gest_ant numeric(24,2),
                depreciacion_acum_actualiz_gest_ant numeric(24,2),
                depreciacion_per numeric(24,2),
                depreciacion_acum numeric(24,2),
                monto_vigente numeric(24,2),
                nivel integer,
                orden bigint,
                tipo varchar(10),
                codigo_ant varchar(50),
                id_centro_costo integer,
                id_activo_fijo integer,
                codigo_activo varchar,
                afecta_concesion varchar,
                depreciacion numeric(24,2)
            ) on commit drop;

            --Inserta los totales por clasificacióm
            insert into tt_detalle_depreciacion_totales
            select
            codigo_padre,
            denominacion_padre,
            null,
            sum(monto_vigente_orig_100),
            sum(monto_vigente_orig),
            sum(inc_actualiz),
            sum(monto_actualiz),
            null,
            null,
            sum(depreciacion_acum_gest_ant),
            sum(depreciacion_acum_actualiz_gest_ant),
            sum(depreciacion_per),
            sum(depreciacion_acum),
            sum(monto_vigente),
            1, --replace(codigo_padre,'RE','')::integer,
            0,
            'clasif',
            '',
            null,
            sum(depreciacion)
            from tt_detalle_depreciacion
            group by codigo_padre, denominacion_padre;

            --Inserta el detalle
            insert into tt_detalle_depreciacion_totales
            select
            codigo,
            denominacion,
            fecha_ini_dep,
            monto_vigente_orig_100,
            monto_vigente_orig,
            inc_actualiz,
            monto_actualiz,
            vida_util_orig,
            vida_util,
            depreciacion_acum_gest_ant,
            depreciacion_acum_actualiz_gest_ant,
            depreciacion_per,
            depreciacion_acum,
            monto_vigente,
            1,--codigo_padre::integer,
            1,--replace(replace(replace(replace(replace(replace(codigo,'A0',''),'AJ',''),'G',''),'RE',''),'.',''),'-','')::bigint,
            'detalle',
            codigo_ant,
            id_centro_costo,
            id_activo_fijo,
            codigo,
            afecta_concesion,
            depreciacion
            from tt_detalle_depreciacion;

            --Inserta los totales finales
            insert into tt_detalle_depreciacion_totales
            select
            'TOTAL FINAL',
            null,
            null,
            sum(monto_vigente_orig_100),
            sum(monto_vigente_orig),
            sum(inc_actualiz),
            sum(monto_actualiz),
            null,
            null,
            sum(depreciacion_acum_gest_ant),
            sum(depreciacion_acum_actualiz_gest_ant),
            sum(depreciacion_per),
            sum(depreciacion_acum),
            sum(monto_vigente),
            999,
            0,
            'total',
            '',
            null,
            sum(depreciacion)
            from tt_detalle_depreciacion;

            v_where = '(''total'',''detalle'',''clasif'')';
            if v_parametros.af_deprec = 'clasif' then
                v_where = '(''total'',''clasif'')';
            end if;

            v_consulta = '
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
        trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text))
                        select
                        tt.codigo,
                        tt.denominacion,
                        tt.fecha_ini_dep,
                        tt.monto_vigente_orig_100,
                        tt.monto_vigente_orig,
                        (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2) as inc_actualiz,
                        tt.monto_actualiz,
                        tt.vida_util_orig,
                        tt.vida_util,
                        tt.depreciacion_acum_gest_ant,
                        tt.depreciacion_acum-tt.depreciacion_acum_gest_ant-tt.depreciacion,--tt.depreciacion_acum_actualiz_gest_ant,
                        tt.depreciacion_per, --tt.depreciacion_acum - coalesce(tt.depreciacion_acum_gest_ant,0) - coalesce(tt.depreciacion_acum_actualiz_gest_ant,0),
                        tt.depreciacion_acum,
                        tt.depreciacion,
                        tt.monto_vigente,
                        tt.nivel,
                        tt.orden,
                        tt.tipo,
                        tt.codigo_ant,
                        cc.codigo_tcc,
                        /*split_part(tt.codigo,''.'',1) as cod_raiz,
                        split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2) as cod_grupo,
                        split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2)||''.''||split_part(tt.codigo,''.'',3) as cod_clase,
                        split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2)||''.''||split_part(tt.codigo,''.'',3)||''.''||split_part(tt.codigo,''.'',4) as cod_subgrupo,
                        
                        (select nombre from kaf.tclasificacion where codigo_completo_tmp = split_part(tt.codigo,''.'',1)) as desc_raiz,
                        (select nombre from kaf.tclasificacion where codigo_completo_tmp = split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2)) as desc_grupo,
                        (select nombre from kaf.tclasificacion where codigo_completo_tmp = split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2)||''.''||split_part(tt.codigo,''.'',3)) as desc_clase,
                        (select nombre from kaf.tclasificacion where codigo_completo_tmp = split_part(tt.codigo,''.'',1)||''.''||split_part(tt.codigo,''.'',2)||''.''||split_part(tt.codigo,''.'',3)||''.''||split_part(tt.codigo,''.'',4)) as desc_subgrupo,*/
                        tt.afecta_concesion,
                        tt.id_activo_fijo,

    (select c.nro_cuenta||''-''||c.nombre_cuenta 
            from conta.tcuenta c 
            where c.id_cuenta in (select id_cuenta
                                from conta.trelacion_contable rc 
                                where rc.id_tipo_relacion_contable =  90
                                and rc.id_gestion = 2
                                and rc.estado_reg = ''activo''
                                and rc.id_tabla = tta.id_clasificacion
                                )
        )
as cuenta_activo,
(select c.nro_cuenta||''-''||c.nombre_cuenta 
            from conta.tcuenta c 
            where c.id_cuenta in (select id_cuenta
                                from conta.trelacion_contable rc 
                                where rc.id_tipo_relacion_contable =  92
                                and rc.id_gestion = 2
                                and rc.estado_reg = ''activo''
                                and rc.id_tabla = tta.id_clasificacion
                                )
        )
as cuenta_dep_acum,
(select c.nro_cuenta||''-''||c.nombre_cuenta 
            from conta.tcuenta c 
            where c.id_cuenta in (select id_cuenta
                                from conta.trelacion_contable rc 
                                where rc.id_tipo_relacion_contable =  91
                                and rc.id_gestion = 2
                                and rc.estado_reg = ''activo''
                                and rc.id_tabla = tta.id_clasificacion
                                )
        )
as cuenta_deprec
                        from tt_detalle_depreciacion_totales tt
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = tt.id_centro_costo
                        left join kaf.tactivo_fijo af on af.id_activo_fijo = tt.id_activo_fijo
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        where tt.tipo in '||v_where||'
                        order by tt.codigo';

            --Devuelve la respuesta
            return v_consulta;

        end;
    else
        raise exception 'Transacción inexistente';  
    end if;
EXCEPTION
  WHEN OTHERS THEN
    v_respuesta='';
    v_respuesta=pxp.f_agrega_clave(v_respuesta,'mensaje',SQLERRM);
    v_respuesta=pxp.f_agrega_clave(v_respuesta,'codigo_error',SQLSTATE);
    v_respuesta=pxp.f_agrega_clave(v_respuesta,'procedimiento',v_nombre_funcion);
    raise exception '%',v_respuesta;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;