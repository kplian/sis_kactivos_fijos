CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_fijo_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_fijo'
 AUTOR:          (admin)
 FECHA:         29-10-2015 03:18:45
 COMENTARIOS:
 ***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2         KAF       ETR           22/05/2019  RCM         Se aumenta consulta para obtener los datos más actuales de los activos fijos (SKA_ULTDAT_SEL)
 #ETR-2116  KAF       ETR           28/12/2020  RCM         Adición de criterio de ordenación listado varios QR
 ***************************************************************************/

DECLARE

    v_consulta          varchar;
    v_parametros        record;
    v_nombre_funcion    text;
    v_resp              varchar;
    v_lista_af          varchar;
    v_criterio_filtro   varchar;
    v_clase_reporte     varchar;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
    #TRANSACCION:  'SKA_AFIJ_SEL'
    #DESCRIPCION:   Consulta de datos
    #AUTOR:     admin
    #FECHA:     29-10-2015 03:18:45
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
                            cla.codigo_completo_tmp || '' '' || cla.nombre as clasificacion,
                            cc.codigo_tcc as centro_costo,
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
                            COALESCE(round(afvi.monto_vigente_real_af,2), afij.monto_compra) as monto_vigente_real_af,
                            COALESCE(afvi.vida_util_real_af,afij.vida_util_original) as vida_util_real_af,
                            afvi.fecha_ult_dep_real_af,
                            COALESCE(round(afvi.depreciacion_acum_real_af,2),0) as depreciacion_acum_real_af,
                            COALESCE(round( afvi.depreciacion_per_real_af,2),0) as depreciacion_per_real_af,
                            cla.tipo_activo,
                            cla.depreciable,
                            afij.monto_compra_orig,
                            afij.id_proyecto,
                            proy.codigo_proyecto as desc_proyecto,
                            afij.cantidad_af,
                            afij.id_unidad_medida,
                            unmed.codigo as codigo_unmed,
                            unmed.descripcion as descripcion_unmed,
                            afij.monto_compra_orig_100,
                            afij.nro_cbte_asociado,
                            afij.fecha_cbte_asociado,
                            round(afij.vida_util_original/12,2)::numeric as vida_util_original_anios,
                            uo.nombre_cargo,
                            afij.fecha_asignacion,
                            afij.prestamo,
                            afij.fecha_dev_prestamo,
                            afij.id_grupo,
                            gru.nombre as desc_grupo,
                            afij.id_ubicacion,
                            ubic.codigo as desc_ubicacion,
                            afij.id_grupo_clasif,
                            gru1.nombre as desc_grupo_clasif/*,
                            (select c.nro_cuenta||''-''||c.nombre_cuenta
                             from conta.tcuenta c
                             where c.id_cuenta in (select id_cuenta
                                                    from conta.trelacion_contable rc
                                                    inner join conta.ttipo_relacion_contable trc
                                                    on trc.id_tipo_relacion_contable = rc.id_tipo_relacion_contable
                                                    where trc.codigo_tipo_relacion = ''ALTAAF''
                                                    and rc.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion(afij.fecha_ini_dep))
                                                    and rc.estado_reg = ''activo''
                                                    and rc.id_tabla =
                                                )
                            ) as cuenta_activo*/
                        from kaf.tactivo_fijo afij
                        inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
                        left join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
                        left join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
                        inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
                        inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
                        inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left join param.tproyecto proy on proy.id_proyecto = afij.id_proyecto
                        left  join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
                        left join kaf.vactivo_fijo_vigente_estado afvi on afvi.id_activo_fijo = afij.id_activo_fijo
                        and afvi.id_moneda = afij.id_moneda_orig
                        and (afvi.estado_mov_dep = ''finalizado'' or afvi.estado_mov_dep is null)

                        --left join kaf.f_activo_fijo_vigente() afvi
                        --on afvi.id_activo_fijo = afij.id_activo_fijo
                        --and afvi.id_moneda = afij.id_moneda_orig

                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
                        left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
                        left join segu.vpersona per on per.id_persona = afij.id_persona
                        left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
                        left join param.tunidad_medida unmed on unmed.id_unidad_medida = afij.id_unidad_medida
                        left join orga.tuo_funcionario uof
                        on uof.id_funcionario = afij.id_funcionario
                        and uof.fecha_asignacion <= now()
                        and coalesce(uof.fecha_finalizacion, now())>=now()
                        and uof.estado_reg = ''activo''
                        and uof.tipo = ''oficial''
                        left join orga.tuo uo
                        on uo.id_uo = uof.id_uo
                        left join kaf.tgrupo gru on gru.id_grupo = afij.id_grupo
                        left join kaf.tubicacion ubic
                        on ubic.id_ubicacion = afij.id_ubicacion
                        left join kaf.tgrupo gru1 on gru1.id_grupo = afij.id_grupo_clasif
                        where  ';

            --Verifica si la consulta es por usuario
            if pxp.f_existe_parametro(p_tabla,'por_usuario') then
                if v_parametros.por_usuario = 'si' then
                    v_consulta = v_consulta || ' afij.id_funcionario in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') and ';
                end if;
            end if;

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;


        end;

    /*********************************
    #TRANSACCION:  'SKA_AFIJ_CONT'
    #DESCRIPCION:   Conteo de registros
    #AUTOR:     admin
    #FECHA:     29-10-2015 03:18:45
    ***********************************/

    elsif(p_transaccion='SKA_AFIJ_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(afij.id_activo_fijo)
                        from kaf.tactivo_fijo afij
                        inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
                        left join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
                        left join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
                        inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
                        inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
                        inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left join param.tproyecto proy on proy.id_proyecto = afij.id_proyecto
                        left  join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito

                        /*
                        left join kaf.vactivo_fijo_vigente_estado afvi on afvi.id_activo_fijo = afij.id_activo_fijo
                        and afvi.id_moneda = afij.id_moneda_orig
                        and (afvi.estado_mov_dep = ''finalizado'' or afvi.estado_mov_dep is null) */

                        --left join kaf.f_activo_fijo_vigente() afvi
                        --on afvi.id_activo_fijo = afij.id_activo_fijo
                        --and afvi.id_moneda = afij.id_moneda_orig

                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
                        left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
                        left join segu.vpersona per on per.id_persona = afij.id_persona
                        left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
                        left join param.tunidad_medida unmed on unmed.id_unidad_medida = afij.id_unidad_medida
                        left join orga.tuo_funcionario uof
                        on uof.id_funcionario = afij.id_funcionario
                        and uof.fecha_asignacion <= now()
                        and coalesce(uof.fecha_finalizacion, now())>=now()
                        and uof.estado_reg = ''activo''
                        and uof.tipo = ''oficial''
                        left join orga.tuo uo
                        on uo.id_uo = uof.id_uo
                        left join kaf.tgrupo gru on gru.id_grupo = afij.id_grupo
                        left join kaf.tubicacion ubic
                        on ubic.id_ubicacion = afij.id_ubicacion
                        left join kaf.tgrupo gru1 on gru1.id_grupo = afij.id_grupo_clasif
                        where  ';

            --Verifica si la consulta es por usuario
            if pxp.f_existe_parametro(p_tabla,'por_usuario') then
                if v_parametros.por_usuario = 'si' then
                    v_consulta = v_consulta || ' afij.id_funcionario in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') and ';
                end if;
            end if;

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_IDAF_SEL'
    #DESCRIPCION:   Generación de lista de ID de activos fijos en base a un criterio
    #AUTOR:         RCM
    #FECHA:         30/12/2015
    ***********************************/

    elsif(p_transaccion='SKA_IDAF_SEL')then

        begin
            --Sentencia de la consulta
            v_consulta:='select
                        pxp.list(afij.id_activo_fijo::text) as ids
                        from kaf.tactivo_fijo afij
                        inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
                        left join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
                        left join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
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
    #DESCRIPCION:   listado de activos segun criterio de formulario para generacion del reporte de codigos QR
    #AUTOR:         RAC
    #FECHA:         17/03/2017
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

    /*********************************
    #TRANSACCION:  'SKA_AFFECH_SEL'
    #DESCRIPCION:   Consulta de datos considerando fecha para obtener el valor real a una fecha
    #AUTOR:         RCM
    #FECHA:         14/06/2017
    ***********************************/

    elsif(p_transaccion='SKA_AFFECH_SEL')then

        begin
            if v_parametros.fecha_mov is null then
                raise exception 'Debe especificar la fecha';
            end if;

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
                            cla.codigo_completo_tmp || '' '' || cla.nombre as clasificacion,
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
                            afij.monto_compra, --COALESCE(round(afvi.monto_vigente_real_af,2), afij.monto_compra),
                            afij.vida_util_original, --COALESCE(afvi.vida_util_real_af,afij.vida_util_original),
                            afij.fecha_ini_dep, --afvi.fecha_ult_dep_real_af,
                            afij.depreciacion_acum,--COALESCE(round(afvi.depreciacion_acum_real_af,2),0),
                            afij.depreciacion_per,--COALESCE(round( afvi.depreciacion_per_real_af,2),0),
                            cla.tipo_activo,
                            cla.depreciable,
                            afij.monto_compra_orig,
                            afij.id_proyecto,
                            proy.codigo_proyecto as desc_proyecto,
                            afij.cantidad_af,
                            afij.id_unidad_medida,
                            unmed.codigo as codigo_unmed,
                            unmed.descripcion as descripcion_unmed,
                            afij.monto_compra_orig_100,
                            afij.nro_cbte_asociado,
                            afij.fecha_cbte_asociado,
                            uo.nombre_cargo
                        from kaf.tactivo_fijo afij
                        inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
                        left join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
                        left join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
                        inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
                        inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
                        inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left join param.tproyecto proy on proy.id_proyecto = afij.id_proyecto
                        left  join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
                        /*left join kaf.vactivo_fijo_vigente_estado afvi on afvi.id_activo_fijo = afij.id_activo_fijo
                        and afvi.id_moneda = afij.id_moneda_orig
                        and (afvi.estado_mov_dep = ''finalizado'' or afvi.estado_mov_dep is null) */

                        /*left join kaf.f_activo_fijo_vigente('''||v_parametros.fecha_mov||''') afvi
                        on afvi.id_activo_fijo = afij.id_activo_fijo
                        and afvi.id_moneda = afij.id_moneda_orig*/

                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
                        left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
                        left join segu.vpersona per on per.id_persona = afij.id_persona
                        left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
                        left join param.tunidad_medida unmed on unmed.id_unidad_medida = afij.id_unidad_medida
                        left join orga.tuo_funcionario uof
                        on uof.id_funcionario = afij.id_funcionario
                        and uof.fecha_asignacion <= ''' || v_parametros.fecha_mov || '''
                        and coalesce(uof.fecha_finalizacion, '''||v_parametros.fecha_mov||''')>=''' || v_parametros.fecha_mov || '''
                        and uof.estado_reg = ''activo''
                        and uof.tipo = ''oficial''
                        left join orga.tuo uo
                        on uo.id_uo = uof.id_uo
                        where  ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;


        end;

    /*********************************
    #TRANSACCION:  'SKA_AFFECH_CONT'

    #DESCRIPCION:   Conteo de registros
    #AUTOR:         RCM
    #FECHA:         14/06/2017
    ***********************************/

    elsif(p_transaccion='SKA_AFFECH_CONT')then

        begin
            if v_parametros.fecha_mov is null then
                raise exception 'Debe especificar la fecha';
            end if;
            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(afij.id_activo_fijo)
                        from kaf.tactivo_fijo afij
                        inner join segu.tusuario usu1 on usu1.id_usuario = afij.id_usuario_reg
                        left join param.tcatalogo cat1 on cat1.id_catalogo = afij.id_cat_estado_fun
                        left join param.tcatalogo cat2 on cat2.id_catalogo = afij.id_cat_estado_compra
                        inner join kaf.tclasificacion cla on cla.id_clasificacion = afij.id_clasificacion
                        inner join param.tdepto dpto on dpto.id_depto = afij.id_depto
                        inner join param.tmoneda mon on mon.id_moneda = afij.id_moneda_orig
                        left join param.tproyecto proy on proy.id_proyecto = afij.id_proyecto
                        left join kaf.tdeposito depaf on depaf.id_deposito = afij.id_deposito
                        /*left join kaf.vactivo_fijo_vigente afvi on afvi.id_activo_fijo = afij.id_activo_fijo*/
                        /*left join kaf.f_activo_fijo_vigente('''||v_parametros.fecha_mov||''') afvi
                        on afvi.id_activo_fijo = afij.id_activo_fijo
                        and afvi.id_moneda = afij.id_moneda_orig*/
                        left join param.vcentro_costo cc on cc.id_centro_costo = afij.id_centro_costo
                        left join segu.tusuario usu2 on usu2.id_usuario = afij.id_usuario_mod
                        left join orga.vfuncionario fun on fun.id_funcionario = afij.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = afij.id_oficina
                        left join segu.vpersona per on per.id_persona = afij.id_persona
                        left join param.vproveedor pro on pro.id_proveedor = afij.id_proveedor
                        left join param.tunidad_medida unmed on unmed.id_unidad_medida = afij.id_unidad_medida
                        left join orga.tuo_funcionario uof
                        on uof.id_funcionario = afij.id_funcionario
                        and uof.fecha_asignacion <= ''' || v_parametros.fecha_mov || '''
                        and coalesce(uof.fecha_finalizacion, '''||v_parametros.fecha_mov||''')>=''' || v_parametros.fecha_mov || '''
                        and uof.estado_reg = ''activo''
                        and uof.tipo = ''oficial''
                        left join orga.tuo uo
                        on uo.id_uo = uof.id_uo
                        where  ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_QRVARIOS_SEL'
    #DESCRIPCION:   Listado para imprimir varios códigos de barra
    #AUTOR:         RCM
    #FECHA:         04/10/2017
    ***********************************/

    elsif(p_transaccion='SKA_QRVARIOS_SEL')then

        begin

            --Recuperar configuracion del reporte de codigo de barrar por defecto de variable global
             v_clase_reporte = pxp.f_get_variable_global('kaf_clase_reporte_codigo');

            --Sentencia de la consulta
            v_consulta:='select
                        kaf.id_activo_fijo,
                        kaf.codigo,
                        kaf.codigo_ant,
                        kaf.denominacion,
                        coalesce(dep.nombre_corto, '''') as nombre_depto,
                        coalesce(ent.nombre, '''') as nombre_entidad,
                        kaf.descripcion,'''
                        ||v_clase_reporte||'''::varchar as clase_rep
                        from kaf.tactivo_fijo  kaf
                        inner join param.tdepto dep on dep.id_depto = kaf.id_depto
                        left join param.tentidad ent on ent.id_entidad = dep.id_entidad
                        where ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            v_consulta = v_consulta || ' ORDER BY kaf.codigo'; --#ETR-2116

            --Devuelve la respuesta
            return v_consulta;

        end;

    --Inicio #2: se agregan dos transacciones para el listado de los últimos datos de los activos fijos
    /*********************************
    #TRANSACCION:  'SKA_ULTDAT_SEL'
    #DESCRIPCION:   Consulta de datos
    #AUTOR:         RCM
    #FECHA:         22/05/2019
    ***********************************/
    elsif(p_transaccion='SKA_ULTDAT_SEL')then

        begin
            --Sentencia de la consulta
            v_consulta:='
                WITH tmax_fecha AS (
                    SELECT
                    MAX(MDEP.fecha) AS fecha, AFV.id_activo_fijo
                    FROM kaf.tmovimiento_af_dep MDEP
                    INNER JOIN kaf.tactivo_fijo_valores AFV
                    ON AFV.id_activo_fijo_valor = MDEP.id_activo_fijo_valor
                    GROUP BY AFV.id_activo_fijo
                )
                SELECT
                AFV.id_activo_fijo, MDEP.fecha, MDEP.monto_actualiz, MDEP.depreciacion_acum,
                MDEP.depreciacion_per, MDEP.monto_vigente,
                MDEP.vida_util, AFV.fecha_ini_dep
                FROM kaf.tmovimiento_af_dep MDEP
                INNER JOIN kaf.tactivo_fijo_valores AFV
                ON AFV.id_activo_fijo_valor = MDEP.id_activo_fijo_valor
                INNER JOIN tmax_fecha MF
                ON MF.id_activo_fijo = AFV.id_activo_fijo
                WHERE DATE_TRUNC(''month'', MDEP.fecha) = DATE_TRUNC(''month'', MF.fecha)
                AND ';

            --Definicion de la respuesta
            v_consulta := v_consulta || v_parametros.filtro;
            v_consulta := v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_ULTDAT_CONT'
    #DESCRIPCION:   Conteo de registros
    #AUTOR:         RCM
    #FECHA:         22/05/2019
    ***********************************/
    elsif(p_transaccion='SKA_ULTDAT_CONT')then

        begin
            --Sentencia de la consulta de conteo de registros
            v_consulta:='
                WITH tmax_fecha AS (
                    SELECT
                    MAX(MDEP.fecha) AS fecha, AFV.id_activo_fijo
                    FROM kaf.tmovimiento_af_dep MDEP
                    INNER JOIN kaf.tactivo_fijo_valores AFV
                    ON AFV.id_activo_fijo_valor = MDEP.id_activo_fijo_valor
                    GROUP BY AFV.id_activo_fijo
                )
                SELECT
                COUNT(1)
                FROM kaf.tmovimiento_af_dep MDEP
                INNER JOIN kaf.tactivo_fijo_valores AFV
                ON AFV.id_activo_fijo_valor = MDEP.id_activo_fijo_valor
                INNER JOIN tmax_fecha MF
                ON MF.id_activo_fijo = AFV.id_activo_fijo
                WHERE DATE_TRUNC(''month'',MDEP.fecha) = DATE_TRUNC(''month'',MF.fecha)
                AND ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;
        --Fin #2

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