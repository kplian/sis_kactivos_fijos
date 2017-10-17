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
     #TRANSACCION:  'SKA_RASIG_CONT'
     #DESCRIPCION:  Reporte Gral de activos fijos con el filtro general
     #AUTOR:        RCM
     #FECHA:        05/10/2017
    ***********************************/
  
    elsif(p_transaccion='SKA_RASIG_CONT') then

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