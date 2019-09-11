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
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #4     KAF       ETR           11/01/2019  RCM         Ajuste por incremento a AF antiguos por cierre de proyectos
 #9     KAF       ETR           10/05/2019  RCM         Inclusión de nuevas columnas en método de reporte detalle depreciación (Múltiples CC)
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
    v_id_moneda_base    integer;

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
                        af.codigo_ant,
                        af.denominacion,
                        af.fecha_compra,
                        af.fecha_ini_dep,
                        af.estado,
                        af.vida_util_original,
                        (af.vida_util_original/12) as porcentaje_dep,
                        af.ubicacion,
                        af.monto_compra_orig,
                        coalesce(mon.moneda,mon1.moneda),
                        cla.nombre as desc_clasif,
                        met.descripcion as metodo_dep,
                        fun.desc_funcionario2 as responsable,
                        orga.f_get_cargo_x_funcionario_str(coalesce(mov.id_funcionario_dest,coalesce(mov.id_funcionario,af.id_funcionario)),now()::date) as cargo,
                        mov.fecha_mov,
                        mov.num_tramite,
                        proc.descripcion as desc_mov,
                        proc.codigo as codigo_mov,
                        af.id_activo_fijo,
                        mov.id_movimiento,
                        mdep.tipo_cambio_ini,
                        mdep.tipo_cambio_fin,
                        mdep.factor,
                        to_char(mdep.fecha,''mm-yyyy'') as fecha_dep,
                        coalesce(mdep.monto_actualiz_ant,af.monto_compra_orig)as monto_actualiz_ant,
                        mdep.monto_actualiz-mdep.monto_actualiz_ant as inc_monto_actualiz,
                        mdep.monto_actualiz,
                        mdep.vida_util_ant,
                        mdep.depreciacion_acum_ant,
                        mdep.depreciacion_acum_actualiz-mdep.depreciacion_acum_ant as inc_dep_acum,
                        mdep.depreciacion_acum_actualiz,
                        mdep.depreciacion,
                        mdep.depreciacion_per,
                        mdep.depreciacion_acum,
                        mdep.monto_vigente
                        from kaf.tmovimiento_af movaf
                        inner join kaf.tmovimiento mov
                        on mov.id_movimiento = movaf.id_movimiento
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = movaf.id_activo_fijo
                        inner join kaf.tclasificacion cla
                        on cla.id_clasificacion = af.id_clasificacion
                        inner join param.tcatalogo proc
                        on proc.id_catalogo = mov.id_cat_movimiento
                        left join kaf.tactivo_fijo_valores afv
                        on afv.id_movimiento_af = movaf.id_movimiento_af
                        and afv.id_moneda_dep = '|| v_parametros.id_moneda ||'
                        left join param.tmoneda mon
                        on mon.id_moneda = afv.id_moneda
                        left join kaf.tmovimiento_af_dep mdep
                        on mdep.id_movimiento_af = movaf.id_movimiento_af
                        and mdep.id_moneda_dep = '|| v_parametros.id_moneda ||'
                        left join param.tmoneda mon1
                        on mon1.id_moneda = mdep.id_moneda
                        left join param.tcatalogo met
                        on met.id_catalogo = cla.id_cat_metodo_dep
                        left join orga.vfuncionario fun
                        on fun.id_funcionario = coalesce(mov.id_funcionario_dest,coalesce(mov.id_funcionario,af.id_funcionario))
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
raise notice '%',v_consulta;
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

            --Obtiene la moneda base
            v_id_moneda_base = param.f_get_moneda_base();

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
                depreciacion numeric(18,2),
                depreciacion_per_ant numeric,
                importe_modif numeric,
                incremento_otra_gestion varchar(2) default 'no'
            ) on commit drop;

            --Carga los datos en la tabla temporal
            insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion,depreciacion_per_ant,importe_modif
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            --afv.fecha_ini_dep,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.fecha_ini_dep
                else
                    case coalesce(afv.importe_modif,0)
                        when 0 then
                            (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
                        else
                             afv.fecha_ini_dep
                    end
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
            mdep.depreciacion,
            mdep.depreciacion_per_ant,
            afv.importe_modif
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
            --and afv.id_activo_fijo_valor = 276602
            and af.estado <> 'eliminado'
            and date_trunc('year',coalesce(af.fecha_baja,'01-01-1900'::date)) <> date_trunc('year',v_parametros.fecha_hasta::date);


            insert into tt_detalle_depreciacion(
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion,depreciacion_per_ant,importe_modif
            )
            select
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            --afv.fecha_ini_dep,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.fecha_ini_dep
                else
                    case coalesce(afv.importe_modif,0)
                        when 0 then
                            (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original /*kaf.f_get_afv_padre(afv.id_activo_fijo_valor)*/)
                        else
                             afv.fecha_ini_dep
                    end
            end as fecha_ini_dep,
            --afv.monto_vigente_orig_100,
            --afv.monto_vigente_orig,
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
            mdep.depreciacion,
            mdep.depreciacion_per_ant,
            afv.importe_modif
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where afv.fecha_fin is not null
            and af.estado in ('retiro','baja')
            and  not exists (select from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor and tipo<>'alta')
            and afv.codigo not in (select codigo
                                    from tt_detalle_depreciacion)
            --and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor /*and tipo = 'alta'*/ )
            --and date_trunc('month',mdep.fecha) <> date_trunc('month',v_parametros.fecha_hasta::date)
            --and date_trunc('month',mdep.fecha) < date_trunc('month',v_parametros.fecha_hasta::date) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta::date)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta::date)
            and date_trunc('month',mdep.fecha) = (select max(fecha)
                                                    from kaf.tmovimiento_af_dep
                                                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                                                    and id_moneda_dep = mdep.id_moneda_dep
                                                    --and date_trunc('month',fecha) <> date_trunc('month',v_parametros.fecha_hasta::date)
                                                    and date_trunc('month',fecha) <= date_trunc('month',v_parametros.fecha_hasta::date) --between date_trunc('month',('01-01-'||extract(year from v_parametros.fecha_hasta)::varchar)::date) and date_trunc('month',v_parametros.fecha_hasta)
                                                )
            and mdep.id_moneda_dep = v_parametros.id_moneda
            and af.id_activo_fijo in (select id_activo_fijo from tt_af_filtro)
            and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor
                                                from tt_detalle_depreciacion)
            and af.estado <> 'eliminado'
            --and af.fecha_baja >= v_parametros.fecha_hasta::date
            --and afv.id_activo_fijo_valor = 276602
            and date_trunc('year',af.fecha_baja) = date_trunc('year',v_parametros.fecha_hasta::date)
            and date_trunc('month',af.fecha_baja) = date_trunc('month',afv.fecha_fin + '1 month'::interval);

            --------------------------------------------------
            --------------------------------------------------
            update tt_detalle_depreciacion set
            id_activo_fijo_valor_padre = kaf.f_get_afv_padre(tt_detalle_depreciacion.id_activo_fijo_valor);

            update tt_detalle_depreciacion set
            --fecha_ini_dep = (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
            monto_vigente_orig_100 = (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
            monto_vigente_orig = (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre),
            vida_util_orig = (select vida_util_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor_padre)
            where coalesce(id_activo_fijo_valor_original,0) <> 0;

            --09/09/2019: Para los incremento por cierre de proyectos, cuya depreciación del padre es de diferente gestión que del nuevo
            UPDATE tt_detalle_depreciacion DEST SET
            monto_vigente_orig = ORIG.monto_actualiz_ant,
            incremento_otra_gestion = 'si'
            FROM (
              WITH tdeprec AS (
                  SELECT id_activo_fijo_valor, id_moneda,
                  CASE MIN(fecha)
                      WHEN '01-12-2017' THEN '01-01-2018'
                      ELSE MIN(fecha)
                  END AS fecha_min
                  FROM kaf.tmovimiento_af_dep
                  GROUP BY id_activo_fijo_valor, id_moneda
              )
              SELECT
              afv.id_activo_fijo_valor, mdep.monto_actualiz_ant
              FROM kaf.tactivo_fijo_valores afv
              INNER JOIN kaf.tactivo_fijo_valores afv1
              ON afv1.id_activo_fijo_valor = afv.id_activo_fijo_valor_original
              INNER JOIN tdeprec dep
              ON dep.id_activo_fijo_valor = afv1.id_activo_fijo_valor
              AND dep.id_moneda = afv1.id_moneda
              INNER JOIN kaf.tmovimiento_af_dep mdep
              ON mdep.id_activo_fijo_valor = dep.id_activo_fijo_valor
              AND mdep.id_moneda = dep.id_moneda
              AND DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('year', afv.fecha_ini_dep)
              WHERE afv.id_activo_fijo_valor_original IS NOT NULL
              AND COALESCE(afv.importe_modif, 0) <> 0
              AND DATE_TRUNC('year', afv.fecha_ini_dep) > DATE_TRUNC('year', dep.fecha_min)
            ) ORIG
            WHERE DEST.id_activo_fijo_valor = ORIG.id_activo_fijo_valor;

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
                        ),0)),
            monto_vigente_orig = coalesce((
                select monto_actualiz
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = tt_detalle_depreciacion.id_activo_fijo_valor
                and id_moneda_dep = v_parametros.id_moneda
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from v_parametros.fecha_hasta::date)::integer -1 )::date)
            ), monto_vigente_orig);

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
                depreciacion numeric(24,2),
                depreciacion_per_ant numeric,
                importe_modif numeric(24,2),
                --Inicio #9: Inclusión de nuevas columnas
                cc1 varchar(50),
                cc2 varchar(50),
                cc3 varchar(50),
                cc4 varchar(50),
                cc5 varchar(50),
                cc6 varchar(50),
                cc7 varchar(50),
                cc8 varchar(50),
                cc9 varchar(50),
                cc10 varchar(50),
                dep_mes_cc1 numeric(24,2),
                dep_mes_cc2 numeric(24,2),
                dep_mes_cc3 numeric(24,2),
                dep_mes_cc4 numeric(24,2),
                dep_mes_cc5 numeric(24,2),
                dep_mes_cc6 numeric(24,2),
                dep_mes_cc7 numeric(24,2),
                dep_mes_cc8 numeric(24,2),
                dep_mes_cc9 numeric(24,2),
                dep_mes_cc10 numeric(24,2),
                --Fin #9
                incremento_otra_gestion varchar(2) default 'no'
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
            sum(depreciacion),
            sum(depreciacion_per_ant),
            null,
            --Inicio #9: Inclusión de nuevas columnas
            null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
            --Fin #9
            null
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
            depreciacion,
            depreciacion_per_ant,
            importe_modif,
            --Inicio #9: Inclusión de nuevas columnas
            null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
            --Fin #9
            incremento_otra_gestion
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
            sum(depreciacion),
            sum(depreciacion_per_ant),
            null,
            --Inicio #9: Inclusión de nuevas columnas
            null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
            --Fin #9
            null
            from tt_detalle_depreciacion;

            --Inicio #9: Se actualiza las columnas a partir del prorrateo registrado en tactivo_fijo_cc en el mes de la depreciación
            --Creación de tabla temporal con el prorrateo del mes
            create temp table tt_prorrateo_af (
                id_activo_fijo  integer,
                id_centro_costo integer,
                cantidad_horas  numeric(18,2),
                total_hrs_af    numeric(18,2),
                cc              varchar(150),
                dep_mes         numeric(24,2),
                nro_columna     integer
            ) on commit drop;

            --Inserta los datos en la tabla temporal
            insert into tt_prorrateo_af
            with taf_horas as (
                select
                acc.id_activo_fijo, sum(acc.cantidad_horas) as total_hrs_af
                from kaf.tactivo_fijo_cc acc
                where date_trunc('month',mes) = date_trunc('month',v_parametros.fecha_hasta)
                group by acc.id_activo_fijo
              )
            select
            acc.id_activo_fijo, acc.id_centro_costo, acc.cantidad_horas, ah.total_hrs_af, tcc.codigo as cc,
            sum(acc.cantidad_horas/ah.total_hrs_af) over (partition by acc.id_activo_fijo, acc.id_centro_costo) * t.depreciacion as dep_mes,
            row_number() over(partition by acc.id_activo_fijo) as nro_columna
            from kaf.tactivo_fijo_cc acc
            inner join taf_horas ah
            on ah.id_activo_fijo = acc.id_activo_fijo
            inner join param.tcentro_costo cc
            on cc.id_centro_costo = acc.id_centro_costo
            inner join param.ttipo_cc tcc
            on tcc.id_tipo_cc = cc.id_tipo_cc
            inner join tt_detalle_depreciacion_totales t on t.id_activo_fijo = acc.id_activo_fijo
            where date_trunc('month',mes) = date_trunc('month',v_parametros.fecha_hasta);

            --Actualización de los datos
            update tt_detalle_depreciacion_totales DEP set
            cc1 = case when DAT.nro_columna = 1 then DAT.cc else cc1 end,
            dep_mes_cc1 = case when DAT.nro_columna = 1 then DAT.dep_mes else dep_mes_cc1 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 1;

            update tt_detalle_depreciacion_totales DEP set
            cc2 = case when DAT.nro_columna = 2 then DAT.cc else DEP.cc2 end,
            dep_mes_cc2 = case when DAT.nro_columna = 2 then DAT.dep_mes else -99 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 2;

            update tt_detalle_depreciacion_totales DEP set
            cc3 = case when DAT.nro_columna = 3 then DAT.cc else DEP.cc3 end,
            dep_mes_cc3 = case when DAT.nro_columna = 3 then DAT.dep_mes else -99 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 3;

            update tt_detalle_depreciacion_totales DEP set
            cc4 = case when DAT.nro_columna = 4 then DAT.cc else DEP.cc4 end,
            dep_mes_cc4 = case when DAT.nro_columna = 4 then DAT.dep_mes else dep_mes_cc4 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 4;

            update tt_detalle_depreciacion_totales DEP set
            cc5 = case when DAT.nro_columna = 5 then DAT.cc else DEP.cc5 end,
            dep_mes_cc5 = case when DAT.nro_columna = 5 then DAT.dep_mes else dep_mes_cc5 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 5;

            update tt_detalle_depreciacion_totales DEP set
            cc6 = case when DAT.nro_columna = 6 then DAT.cc else DEP.cc6 end,
            dep_mes_cc6 = case when DAT.nro_columna = 6 then DAT.dep_mes else dep_mes_cc6 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 6;

            update tt_detalle_depreciacion_totales DEP set
            cc7 = case when DAT.nro_columna = 7 then DAT.cc else DEP.cc7 end,
            dep_mes_cc7 = case when DAT.nro_columna = 7 then DAT.dep_mes else dep_mes_cc7 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 7;

            update tt_detalle_depreciacion_totales DEP set
            cc8 = case when DAT.nro_columna = 8 then DAT.cc else DEP.cc8 end,
            dep_mes_cc8 = case when DAT.nro_columna = 8 then DAT.dep_mes else dep_mes_cc8 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 8;

            update tt_detalle_depreciacion_totales DEP set
            cc9 = case when DAT.nro_columna = 9 then DAT.cc else DEP.cc9 end,
            dep_mes_cc9 = case when DAT.nro_columna = 9 then DAT.dep_mes else dep_mes_cc9 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 9;

            update tt_detalle_depreciacion_totales DEP set
            cc10 = case when DAT.nro_columna = 10 then DAT.cc else DEP.cc10 end,
            dep_mes_cc10 = case when DAT.nro_columna = 10 then DAT.dep_mes else dep_mes_cc10 end
            from (
                select * from tt_prorrateo_af
            ) DAT
            where DEP.id_activo_fijo = DAT.id_activo_fijo
            and DAT.nro_columna = 10;
            --Fin #9

            v_where = '(''total'',''detalle'',''clasif'')';
            if v_parametros.af_deprec = 'clasif' then
                v_where = '(''total'',''clasif'')';
            elsif  v_parametros.af_deprec = 'detalle' then
                v_where = '(''detalle'')';
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
                          trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text)
                        )
                        select
                        row_number() over(order by tt.codigo) -1 as numero,
                        tt.codigo,
                        tt.codigo_ant,
                        tt.denominacion,
                        tt.fecha_ini_dep,
                        af.cantidad_af,
                        um.descripcion as desc_unidad_medida,
                        cc.codigo_tcc,
                        af.nro_serie,
                        ubi.codigo as desc_ubicacion,
                        fun.desc_funcionario2 as responsable,
                        tt.monto_vigente_orig_100, --monto de la compra
                        --Se aumenta lógica para el caso de ajustes que incementen el monto
                        case
                            --Si el año de la fecha de generación del reporte es diferente al año de la fecha de inicio depreciación, muestra el valor, eoc. muestra 0
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from tt.fecha_ini_dep) then
                                case
                                    when coalesce(tt.importe_modif,0) = 0 then 0--se pone cero porque el importe irá en Altas
                                    else tt.monto_vigente_orig
                                end
                            else
                                tt.monto_vigente_orig
                        end as monto_vigente_orig,
                        --Se aumenta lógica para el caso de ajustes que incementen el monto. Si se genera en la misma gestion y es ajuste de incremento, solo muestra el incremento
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from tt.fecha_ini_dep) then
                                case coalesce(tt.importe_modif,0)
                                  when 0 then tt.monto_vigente_orig
                                  else
                                        case incremento_otra_gestion
                                            --Cuando es incremente y es de otra gestión, muestra el importe modificado sin actualización por lo que aplica X = importe modif / factor
                                            when ''si'' then tt.importe_modif / ( param.f_get_tipo_cambio(3, (date_trunc(''month'', tt.fecha_ini_dep) - interval ''1 day'')::date, ''O'') /
                        param.f_get_tipo_cambio(3, date_trunc(''year'', tt.fecha_ini_dep)::date, ''O''))
                                            else tt.importe_modif
                                        end
                                end
                            else 0
                        end as af_altas,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2)
                            else 0
                        end as af_bajas,
                        0::numeric as af_traspasos,
                        --(tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2) as inc_actualiz,
                        case coalesce(tt.importe_modif,0)
                            when 0 then (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2)
                            else
                                case incremento_otra_gestion
                                    --Cuando es incremente y es de otra gestión, resta además el importe modificado sin actualización por lo que aplica X = importe modif / factor
                                    when ''si'' then (tt.monto_actualiz - tt.monto_vigente_orig - (tt.importe_modif / ( param.f_get_tipo_cambio(3, (date_trunc(''month'', tt.fecha_ini_dep) - interval ''1 day'')::date, ''O'') /
                        param.f_get_tipo_cambio(3, date_trunc(''year'', tt.fecha_ini_dep)::date, ''O''))))::numeric(18,2)
                                    else (tt.monto_actualiz - tt.monto_vigente_orig /*- tt.importe_modif*/)::numeric(18,2)
                                end
                        end as inc_actualiz,
                        --Se aumenta lógica para el caso de ajustes que incementen el monto
                        case coalesce(tt.importe_modif,0)
                            when 0 then tt.monto_actualiz - (case
                                                                    when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                                                        and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                                                        tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2)
                                                                    else 0
                                                                end )
                            else tt.monto_actualiz -- + tt.importe_modif
                        end as monto_actualiz,
                        tt.vida_util_orig,
                        tt.vida_util_orig - tt.vida_util as vida_util_usada,
                        tt.vida_util,
                        tt.depreciacion_acum_gest_ant,
                        --tt.depreciacion_acum-tt.depreciacion_acum_gest_ant-tt.depreciacion,--tt.depreciacion_acum_actualiz_gest_ant,
                         case ' || v_parametros.id_moneda  || '
                            when ' || v_id_moneda_base || ' then tt.depreciacion_acum - tt.depreciacion_acum_gest_ant - tt.depreciacion
                            else 0
                        end as inc_act_dep_acum,
                        tt.depreciacion,--tt.depreciacion_per, --tt.depreciacion_acum - coalesce(tt.depreciacion_acum_gest_ant,0) - coalesce(tt.depreciacion_acum_actualiz_gest_ant,0),
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) >= date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900''))  then
                                tt.depreciacion_acum
                            else 0
                        end as depreciacion_acum_bajas,
                        0::numeric as depreciacion_acum_traspasos,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) >= date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900''))  then
                                0
                            else tt.depreciacion_acum
                        end as depreciacion_acum,
                        tt.depreciacion_per,--tt.depreciacion, ***********
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                0
                            else tt.monto_actualiz - tt.depreciacion_acum
                        end as monto_vigente,

                        --tt.afecta_concesion,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                                from conta.tcuenta c
                                where c.id_cuenta in (select id_cuenta
                                                    from conta.trelacion_contable rc
                                                    inner join conta.ttipo_relacion_contable trc
                                                    on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                                    where trc.codigo_tipo_relacion = ''ALTAAF''
                                                    and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                                    and rc.estado_reg = ''activo''
                                                    and rc.id_tabla = tta.id_clasificacion
                                                    )
                                )
                        as cuenta_activo,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                        from conta.tcuenta c
                        where c.id_cuenta in (select id_cuenta
                                            from conta.trelacion_contable rc
                                            inner join conta.ttipo_relacion_contable trc
                                            on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                            where trc.codigo_tipo_relacion = ''DEPACCLAS''
                                            and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                            and rc.estado_reg = ''activo''
                                            and rc.id_tabla = tta.id_clasificacion
                                            )
                        ) as cuenta_dep_acum,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                                from conta.tcuenta c
                                where c.id_cuenta in (select id_cuenta
                                                    from conta.trelacion_contable rc
                                                    inner join conta.ttipo_relacion_contable trc
                                                    on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                                    where trc.codigo_tipo_relacion = ''DEPCLAS''
                                                    and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                                    and rc.estado_reg = ''activo''
                                                    and rc.id_tabla = tta.id_clasificacion
                                                    )
                                )
                        as cuenta_deprec,

                        gr.nombre as desc_grupo,
                        gr1.nombre as desc_grupo_clasif,
                        cta.nro_cuenta||''-''||cta.nombre_cuenta as cuenta_dep_acum_dos,
                        af.bk_codigo,
                        tt.cc1,
                        tt.dep_mes_cc1,
                        tt.cc2,
                        tt.dep_mes_cc2,
                        tt.cc3,
                        tt.dep_mes_cc3,
                        tt.cc4,
                        tt.dep_mes_cc4,
                        tt.cc5,
                        tt.dep_mes_cc5,
                        tt.cc6,
                        tt.dep_mes_cc6,
                        tt.cc7,
                        tt.dep_mes_cc7,
                        tt.cc8,
                        tt.dep_mes_cc8,
                        tt.cc9,
                        tt.dep_mes_cc9,
                        tt.cc10,
                        tt.dep_mes_cc10,
                        tt.id_activo_fijo,
                        tt.nivel,
                        tt.orden,
                        tt.tipo
                        from tt_detalle_depreciacion_totales tt
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = tt.id_centro_costo
                        left join kaf.tactivo_fijo af on af.id_activo_fijo = tt.id_activo_fijo
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        left join orga.vfuncionario fun on fun.id_funcionario = af.id_funcionario
                        left join kaf.tubicacion ubi on ubi.id_ubicacion = af.id_ubicacion
                        left join kaf.tgrupo gr on gr.id_grupo = af.id_grupo
                        left join kaf.tgrupo gr1 on gr1.id_grupo = af.id_grupo_clasif
                        left join param.tunidad_medida um on um.id_unidad_medida = af.id_unidad_medida
                        left join kaf.tactivo_fijo_cta_tmp act on act.id_activo_fijo = tt.id_activo_fijo
                        left join conta.tcuenta cta on cta.nro_cuenta = act.nro_cuenta AND cta.id_gestion = 2
                        where tt.tipo in '||v_where||'
                        order by tt.codigo';

            if pxp.f_existe_parametro(p_tabla,'tipo_reporte') then

            else
                v_consulta:=v_consulta||' limit ' || coalesce(v_parametros.cantidad,999999) || ' offset ' || coalesce(v_parametros.puntero,0);
            end if;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
     #TRANSACCION:  'SKA_RDEPREC_CONT'
     #DESCRIPCION:  Conteo del Reporte del Detalle de depreciación
     #AUTOR:        RCM
     #FECHA:        19/06/2017
    ***********************************/

    elsif(p_transaccion='SKA_RDEPREC_CONT') then

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
                          trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text)
                        )
                        select
                        count(1)
                        from tt_detalle_depreciacion_totales tt
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = tt.id_centro_costo
                        left join kaf.tactivo_fijo af on af.id_activo_fijo = tt.id_activo_fijo
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        left join orga.vfuncionario fun on fun.id_funcionario = af.id_funcionario
                        left join kaf.tubicacion ubi on ubi.id_ubicacion = af.id_ubicacion
                        left join kaf.tgrupo gr on gr.id_grupo = af.id_grupo
                        left join kaf.tgrupo gr1 on gr1.id_grupo = af.id_grupo_clasif
                        left join param.tunidad_medida um on um.id_unidad_medida = af.id_unidad_medida
                        where tt.tipo in '||v_where;
--raise exception 'count: %',v_consulta;
            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
     #TRANSACCION:  'SKA_DEDEPRE_SEL'
     #DESCRIPCION:  Reporte detalle de depreciación, optimizado generado desde datos preprocesados
     #AUTOR:        RCM
     #FECHA:        08/11/2018
    ***********************************/

    elsif(p_transaccion='SKA_DEDEPRE_SEL') then

        begin

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
                depreciacion numeric(24,2),
                depreciacion_per_ant numeric
            ) on commit drop;

            --Inserta los totales por clasificación
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
            sum(depreciacion),
            sum(depreciacion_per_ant)
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta)
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
            depreciacion,
            depreciacion_per_ant
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta);

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
            sum(depreciacion),
            sum(depreciacion_per_ant)
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta);

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
                          trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text)
                        )
                        select
                        row_number() over(order by tt.codigo) -1 as numero,
                        tt.codigo,
                        tt.codigo_ant,
                        tt.denominacion,
                        tt.fecha_ini_dep,
                        af.cantidad_af,
                        um.descripcion as desc_unidad_medida,
                        cc.codigo_tcc,
                        af.nro_serie,
                        ubi.codigo as desc_ubicacion,
                        fun.desc_funcionario2 as responsable,
                        tt.monto_vigente_orig_100,
                        --tt.monto_vigente_orig,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) <> extract(year from tt.fecha_ini_dep)
                                --and extract(year from '''||v_parametros.fecha_hasta||'''::date) <> extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                then tt.monto_vigente_orig
                            else 0
                        end as monto_vigente_orig,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from tt.fecha_ini_dep) then tt.monto_vigente_orig
                            else 0
                        end as af_altas,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2)
                            else 0
                        end as af_bajas,
                        0::numeric as af_traspasos,
                        (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2) as inc_actualiz,
                        tt.monto_actualiz - (case
                                                when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                                    and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                                    tt.monto_vigente_orig + (tt.monto_actualiz - tt.monto_vigente_orig)::numeric(18,2)
                                                else 0
                                            end ) as monto_actualiz,
                        tt.vida_util_orig,
                        tt.vida_util_orig - tt.vida_util as vida_util_usada,
                        tt.vida_util,
                        tt.depreciacion_acum_gest_ant,
                        tt.depreciacion_acum-tt.depreciacion_acum_gest_ant-tt.depreciacion,--tt.depreciacion_acum_actualiz_gest_ant,
                        tt.depreciacion,--tt.depreciacion_per, --tt.depreciacion_acum - coalesce(tt.depreciacion_acum_gest_ant,0) - coalesce(tt.depreciacion_acum_actualiz_gest_ant,0),
                        --tt.depreciacion_acum,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) >= date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900''))  then
                                tt.depreciacion_acum
                            else 0
                        end as depreciacion_acum_bajas,
                        0::numeric as depreciacion_acum_traspasos,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) >= date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900''))  then
                                0
                            else tt.depreciacion_acum
                        end as depreciacion_acum,
                        tt.depreciacion_per,--tt.depreciacion, ***********
                        --tt.monto_actualiz - tt.depreciacion_acum,--tt.monto_vigente,
                        case
                            when extract(year from '''||v_parametros.fecha_hasta||'''::date) = extract(year from coalesce(af.fecha_baja,''01-01-1900''))
                                and date_trunc(''month'',coalesce(af.fecha_baja,''01-01-1900'')) <= date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) then
                                0
                            else tt.monto_actualiz - tt.depreciacion_acum
                        end as monto_vigente,

                        --tt.afecta_concesion,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                                from conta.tcuenta c
                                where c.id_cuenta in (select id_cuenta
                                                    from conta.trelacion_contable rc
                                                    inner join conta.ttipo_relacion_contable trc
                                                    on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                                    where trc.codigo_tipo_relacion = ''ALTAAF''
                                                    and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                                    and rc.estado_reg = ''activo''
                                                    and rc.id_tabla = tta.id_clasificacion
                                                    )
                                )
                        as cuenta_activo,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                        from conta.tcuenta c
                        where c.id_cuenta in (select id_cuenta
                                            from conta.trelacion_contable rc
                                            inner join conta.ttipo_relacion_contable trc
                                            on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                            where trc.codigo_tipo_relacion = ''DEPACCLAS''
                                            and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                            and rc.estado_reg = ''activo''
                                            and rc.id_tabla = tta.id_clasificacion
                                            )
                        ) as cuenta_dep_acum,
                        (select c.nro_cuenta||''-''||c.nombre_cuenta
                                from conta.tcuenta c
                                where c.id_cuenta in (select id_cuenta
                                                    from conta.trelacion_contable rc
                                                    inner join conta.ttipo_relacion_contable trc
                                                    on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                                    where trc.codigo_tipo_relacion = ''DEPCLAS''
                                                    and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion('''||v_parametros.fecha_hasta||'''::date))
                                                    and rc.estado_reg = ''activo''
                                                    and rc.id_tabla = tta.id_clasificacion
                                                    )
                                )
                        as cuenta_deprec,

                        gr.nombre as desc_grupo,
                        gr1.nombre as desc_grupo_clasif,
                        cta.nro_cuenta||''-''||cta.nombre_cuenta as cuenta_dep_acum_dos,
                        tt.id_activo_fijo,
                        tt.nivel,
                        tt.orden,
                        tt.tipo,
                        af.bk_codigo
                        from tt_detalle_depreciacion_totales tt
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = tt.id_centro_costo
                        left join kaf.tactivo_fijo af on af.id_activo_fijo = tt.id_activo_fijo
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        left join orga.vfuncionario fun on fun.id_funcionario = af.id_funcionario
                        left join kaf.tubicacion ubi on ubi.id_ubicacion = af.id_ubicacion
                        left join kaf.tgrupo gr on gr.id_grupo = af.id_grupo
                        left join kaf.tgrupo gr1 on gr1.id_grupo = af.id_grupo_clasif
                        left join param.tunidad_medida um on um.id_unidad_medida = af.id_unidad_medida
                        left join kaf.tactivo_fijo_cta_tmp act on act.id_activo_fijo = tt.id_activo_fijo
                        left join conta.tcuenta cta on cta.nro_cuenta = act.nro_cuenta AND cta.id_gestion in (select id_gestion
                                                                                                              from param.tgestion
                                                                                                              where date_trunc(''year'',fecha_ini) = date_trunc(''year'','''||v_parametros.fecha_hasta||'''::date))
                        where tt.tipo in '||v_where||'
                        order by tt.codigo';

            if pxp.f_existe_parametro(p_tabla,'tipo_reporte') then

            else
                v_consulta:=v_consulta||' limit ' || coalesce(v_parametros.cantidad,999999) || ' offset ' || coalesce(v_parametros.puntero,0);
            end if;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
     #TRANSACCION:  'SKA_DEDEPRE_CONT'
     #DESCRIPCION:  Reporte detalle de depreciación, optimizado generado desde datos preprocesados
     #AUTOR:        RCM
     #FECHA:        08/11/2018
    ***********************************/

    elsif(p_transaccion='SKA_DEDEPRE_CONT') then

        begin

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
                depreciacion numeric(24,2),
                depreciacion_per_ant numeric
            ) on commit drop;

            --Inserta los totales por clasificación
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
            sum(depreciacion),
            sum(depreciacion_per_ant)
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta)
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
            depreciacion,
            depreciacion_per_ant
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta);

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
            sum(depreciacion),
            sum(depreciacion_per_ant)
            from kaf.treporte_detalle_depreciacion
            where date_trunc('month',fecha_deprec) = date_trunc('month',v_parametros.fecha_hasta);

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
                          trc.codigo_tipo_relacion::text in (''ALTAAF''::text,''DEPACCLAS''::text,''DEPCLAS''::text)
                        )
                        select
                        count(1)
                        from tt_detalle_depreciacion_totales tt
                        left join param.vcentro_costo cc
                        on cc.id_centro_costo = tt.id_centro_costo
                        left join kaf.tactivo_fijo af on af.id_activo_fijo = tt.id_activo_fijo
                        left join tta on af.id_clasificacion = ANY (tta.nodos)
                        left join orga.vfuncionario fun on fun.id_funcionario = af.id_funcionario
                        left join kaf.tubicacion ubi on ubi.id_ubicacion = af.id_ubicacion
                        left join kaf.tgrupo gr on gr.id_grupo = af.id_grupo
                        left join kaf.tgrupo gr1 on gr1.id_grupo = af.id_grupo_clasif
                        left join param.tunidad_medida um on um.id_unidad_medida = af.id_unidad_medida
                        left join kaf.tactivo_fijo_cta_tmp act on act.id_activo_fijo = tt.id_activo_fijo
                        left join conta.tcuenta cta on cta.nro_cuenta = act.nro_cuenta AND cta.id_gestion in (select id_gestion
                                                                                                              from param.tgestion
                                                                                                              where date_trunc(''year'',fecha_ini) = date_trunc(''year'','''||v_parametros.fecha_hasta||'''::date))
                        where tt.tipo in '||v_where;

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

ALTER FUNCTION kaf.f_reportes_af (p_administrador integer, p_id_usuario integer, p_tabla varchar, p_transaccion varchar)
  OWNER TO postgres;