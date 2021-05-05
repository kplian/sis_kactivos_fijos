CREATE OR REPLACE FUNCTION kaf.ft_movimiento_sel (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_movimiento_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tmovimiento'
 AUTOR:          (admin)
 FECHA:         22-10-2015 20:42:41
 COMENTARIOS:
 ***************************************************************************
 ISSUE          SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2170      KAF       ETR           18/12/2020  RCM         Adición de campo para registro del tipo de cambio final para actualización
 #AF-41         KAF       ETR           01/03/2021  RCM         Modificación de Columnas para el caso de Altas
 #ETR-3660      KAF       ETR           19/04/2021  RCM         Correción columna moneda original
 #AF-44         KAF       ETR           05/05/2021  RCM         Para obtener los importes para el reporte, es necesario considear tambien el origen dval
***************************************************************************/

DECLARE

    v_consulta          varchar;
    v_parametros        record;
    v_nombre_funcion    text;
    v_resp              varchar;
    v_filtro            varchar;
    v_id_funcionario    integer;
    v_tipo_interfaz     varchar;
    v_depto_ids         varchar;
    v_aux               varchar;

BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
    #TRANSACCION:  'SKA_MOV_SEL'
    #DESCRIPCION:   Consulta de datos
    #AUTOR:     admin
    #FECHA:     22-10-2015 20:42:41
    ***********************************/

    if(p_transaccion='SKA_MOV_SEL')then

        begin

            --Inicialización de filtro
            v_filtro = '0=0 and ';

            --Filtro por departamento cuando no son administradores
            if p_administrador !=1 then

                select
                pxp.list(distinct dep.id_depto::varchar)
                into v_depto_ids
                from param.tdepto_usuario depu
                inner join param.tdepto dep
                on dep.id_depto = depu.id_depto
                inner join segu.tsubsistema sis
                on sis.id_subsistema = dep.id_subsistema
                where sis.codigo = 'KAF'
                and depu.id_usuario = p_id_usuario;

                if v_depto_ids is null then
                    --v_filtro = v_filtro || ' mov.id_depto = -1 and ';
                else
                    v_filtro = v_filtro || ' mov.id_depto in ('||v_depto_ids||') and ';
                end if;

            end if;

            --Verificación de existencia de parámetro de interfaz
            v_tipo_interfaz = 'normal';
            if pxp.f_existe_parametro(p_tabla,'tipo_interfaz') then
                v_tipo_interfaz = coalesce(v_parametros.tipo_interfaz,'normal');
            end if;

            if p_administrador !=1  and v_tipo_interfaz = 'MovimientoVb' then
                --Obtención del funcionario a partir del usuario recibido
                select id_funcionario
                into v_id_funcionario
                from segu.tusuario usu
                inner join orga.tfuncionario fun
                on fun.id_persona = usu.id_persona
                where usu.id_usuario = p_id_usuario;

                if v_id_funcionario is null then
                    raise exception 'El usuario no es funcionario.';
                end if;

                v_filtro = v_filtro || 'ew.id_funcionario='||v_id_funcionario::varchar||' and ';

            end if;

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
                        usu.desc_funcionario1 as responsable_depto,
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
                        movmot.motivo,
                        mov.id_int_comprobante,
                        mov.id_int_comprobante_aitb,
                        funwf.desc_funcionario2 as resp_wf,
                        mov.prestamo,
                        mov.fecha_dev_prestamo,
                        mov.id_int_comprobante_3,
                        cb1.id_proceso_wf as id_proceso_wf_cbte1,
                        cb2.id_proceso_wf as id_proceso_wf_cbte2,
                        cb3.id_proceso_wf as id_proceso_wf_cbte3,
                        mov.id_int_comprobante_4,
                        cb4.id_proceso_wf as id_proceso_wf_cbte4,
                        mov.tc_final_act --#ETR-2170
                        from kaf.tmovimiento mov
                        inner join segu.tusuario usu1 on usu1.id_usuario = mov.id_usuario_reg
                        left join segu.tusuario usu2 on usu2.id_usuario = mov.id_usuario_mod
                        inner join param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
                        inner join param.tdepto dep on dep.id_depto = mov.id_depto
                        left join orga.vfuncionario fun on fun.id_funcionario = mov.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = mov.id_oficina
                        inner join orga.vfuncionario usu on usu.id_funcionario = mov.id_responsable_depto
                        left join segu.vpersona per on per.id_persona = mov.id_persona
                        left join wf.testado_wf ew on ew.id_estado_wf = mov.id_estado_wf
                        left join wf.ttipo_estado tew on tew.id_tipo_estado = ew.id_tipo_estado
                        left join kaf.tdeposito depo on depo.id_deposito = mov.id_deposito
                        left join param.tdepto depdest on depdest.id_depto = mov.id_depto_dest
                        left join kaf.tdeposito depodest on depodest.id_deposito = mov.id_deposito_dest
                        left join orga.vfuncionario fundest on fundest.id_funcionario = mov.id_funcionario_dest
                        left join kaf.tmovimiento_motivo movmot on movmot.id_movimiento_motivo = mov.id_movimiento_motivo
                        left join orga.vfuncionario funwf on funwf.id_funcionario = ew.id_funcionario
                        left join conta.tint_comprobante cb1 on cb1.id_int_comprobante = mov.id_int_comprobante
                        left join conta.tint_comprobante cb2 on cb2.id_int_comprobante = mov.id_int_comprobante_aitb
                        left join conta.tint_comprobante cb3 on cb3.id_int_comprobante = mov.id_int_comprobante_3
                        left join conta.tint_comprobante cb4 on cb4.id_int_comprobante = mov.id_int_comprobante_4
                        where '||v_filtro;

            --Verifica si la consulta es por usuario
            if pxp.f_existe_parametro(p_tabla,'por_usuario') then
                if v_parametros.por_usuario = 'si' then
                    v_consulta = v_consulta || ' (mov.id_funcionario in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') or
                                                mov.id_funcionario_dest in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') )and ';
                end if;
            end if;

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_MOV_CONT'
    #DESCRIPCION:   Conteo de registros
    #AUTOR:     admin
    #FECHA:     22-10-2015 20:42:41
    ***********************************/

    elsif(p_transaccion='SKA_MOV_CONT')then

        begin

            --Inicialización de filtro
            v_filtro = '0=0 and ';

            --Filtro por departamento cuando no son administradores
            if p_administrador !=1 then

                select
                pxp.list(distinct dep.id_depto::varchar)
                into v_depto_ids
                from param.tdepto_usuario depu
                inner join param.tdepto dep
                on dep.id_depto = depu.id_depto
                inner join segu.tsubsistema sis
                on sis.id_subsistema = dep.id_subsistema
                where sis.codigo = 'KAF'
                and depu.id_usuario = p_id_usuario;

                if v_depto_ids is null then
                    v_filtro = v_filtro || ' mov.id_depto = -1 and ';
                else
                    v_filtro = v_filtro || ' mov.id_depto in ('||v_depto_ids||') and ';
                end if;

            end if;

            --Verificación de existencia de parámetro de interfaz
            v_tipo_interfaz = 'normal';
            if pxp.f_existe_parametro(p_tabla,'tipo_interfaz') then
                v_tipo_interfaz = coalesce(v_parametros.tipo_interfaz,'normal');
            end if;

            if p_administrador !=1  and v_tipo_interfaz = 'MovimientoVb' then
                --Obtención del funcionario a partir del usuario recibido
                select id_funcionario
                into v_id_funcionario
                from segu.tusuario usu
                inner join orga.tfuncionario fun
                on fun.id_persona = usu.id_persona
                where usu.id_usuario = p_id_usuario;

                if v_id_funcionario is null then
                    raise exception 'El usuario no es funcionario.';
                end if;

                v_filtro = v_filtro || 'ew.id_funcionario='||v_id_funcionario::varchar||' and ';

            end if;

            --Sentencia de la consulta de conteo de registros
            v_consulta:='select count(id_movimiento)
                        from kaf.tmovimiento mov
                        inner join segu.tusuario usu1 on usu1.id_usuario = mov.id_usuario_reg
                        left join segu.tusuario usu2 on usu2.id_usuario = mov.id_usuario_mod
                        inner join param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
                        inner join param.tdepto dep on dep.id_depto = mov.id_depto
                        left join orga.vfuncionario fun on fun.id_funcionario = mov.id_funcionario
                        left join orga.toficina ofi on ofi.id_oficina = mov.id_oficina
                        inner join orga.vfuncionario usu on usu.id_funcionario = mov.id_responsable_depto
                        left join segu.vpersona per on per.id_persona = mov.id_persona
                        left join wf.testado_wf ew on ew.id_estado_wf = mov.id_estado_wf
                        left join wf.ttipo_estado tew on tew.id_tipo_estado = ew.id_tipo_estado
                        left join kaf.tdeposito depo on depo.id_deposito = mov.id_deposito
                        left join param.tdepto depdest on depdest.id_depto = mov.id_depto_dest
                        left join kaf.tdeposito depodest on depodest.id_deposito = mov.id_deposito_dest
                        left join orga.vfuncionario fundest on fundest.id_funcionario = mov.id_funcionario_dest
                        left join kaf.tmovimiento_motivo movmot on movmot.id_movimiento_motivo = mov.id_movimiento_motivo
                        left join orga.vfuncionario funwf on funwf.id_funcionario = ew.id_funcionario
                        left join conta.tint_comprobante cb1 on cb1.id_int_comprobante = mov.id_int_comprobante
                        left join conta.tint_comprobante cb2 on cb2.id_int_comprobante = mov.id_int_comprobante_aitb
                        left join conta.tint_comprobante cb3 on cb3.id_int_comprobante = mov.id_int_comprobante_3
                        left join conta.tint_comprobante cb4 on cb4.id_int_comprobante = mov.id_int_comprobante_4
                        where '||v_filtro;

            --Verifica si la consulta es por usuario
            if pxp.f_existe_parametro(p_tabla,'por_usuario') then
                if v_parametros.por_usuario = 'si' then
                    v_consulta = v_consulta || ' (mov.id_funcionario in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') or
                                                mov.id_funcionario_dest in (select
                                                fun.id_funcionario
                                                from segu.tusuario usu
                                                inner join orga.vfuncionario_persona fun
                                                on fun.id_persona = usu.id_persona
                                                where usu.id_usuario = '||p_id_usuario||') )and ';
                end if;
            end if;

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_MOV_REP'
    #DESCRIPCION:   Reporte de movimientos  maesto
    #AUTOR:         RCM, RAC
    #FECHA:         20/03/2016, 20/03/2017
    ***********************************/

    elsif(p_transaccion='SKA_MOV_REP')then

        begin

            --Consulta
            v_consulta:=' select cat.descripcion as movimiento,
                                cat.codigo as cod_movimiento,
                                coalesce(mov.codigo, ''S/N'') as formulario,
                                coalesce(mov.num_tramite, ''S/N'') as num_tramite,
                                mov.fecha_mov,
                                mov.fecha_hasta,
                                mov.glosa,
                                mov.estado,
                                dpto.nombre as depto,
                                fun.desc_funcionario2 as responsable,
                                fun.nombre_cargo,
                                fun.lugar_nombre as lugar_funcionario,
                                fun.oficina_nombre oficina_funcionario,
                                 case when (length(fun.oficina_direccion) > 0 and position(''Tel'' in fun.oficina_direccion) > 0) then
                                        substring(fun.oficina_direccion,1,position(''Tel'' in fun.oficina_direccion)-1)::varchar
                                    else  case when length(fun.oficina_direccion)>0 then fun.oficina_direccion::varchar else ''No tiene dirección''::varchar end end as direccion_funcionario,
                                fun.ci,
                                ofi.nombre as oficina,
                                mov.direccion,
                                fun1.desc_funcionario2 as responsable_depto,
                                per.nombre_completo2 as custodio,
                                per.ci as ci_custodio,
                                fundes.desc_funcionario2 as responsable_dest,
                                fundes.nombre_cargo as nombre_cargo_dest,
                                fundes.ci as ci_dest,
                                tlu.nombre as lugar,
                                coalesce((select tcar.nombre
                                from orga.tcargo tcar
                                where tcar.id_cargo = any (orga.f_get_cargo_x_funcionario(fun1.id_funcionario,now()::date))),''SIN CARGO'') as cargo_jefe,
                                fundes.lugar_nombre as lugar_destino,
                                fundes.oficina_nombre as oficina_destino,
                                case when (length(fundes.oficina_direccion)>0 and position(''Tel'' in fundes.oficina_direccion) > 0) then
                                    substring(fundes.oficina_direccion,1,position(''Tel'' in fundes.oficina_direccion)-1)::varchar
                                else case when length(fundes.oficina_direccion)>0 then fundes.oficina_direccion::varchar else ''No tiene dirección''::varchar end end as oficina_direccion,
                                mov.id_funcionario_dest,
                                fun1.lugar_nombre as lugar_responsable,
                                fun1.oficina_nombre as oficina_responsable,
                                case when (length(fun1.oficina_direccion)>0 and position(''Tel'' in fun1.oficina_direccion) > 0) then
                                        substring(fun1.oficina_direccion,1,position(''Tel'' in fun1.oficina_direccion)-1)::varchar
                                    else case when length(fun1.oficina_direccion)>0 then fun1.oficina_direccion else ''No tiene dirección''::varchar end end as direccion_responsable,
                                mov.prestamo,
                                dpto.codigo
                         from kaf.tmovimiento mov
                              inner join param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
                              inner join param.tdepto dpto on dpto.id_depto = mov.id_depto
                              left join orga.vfuncionario_cargo_lugar fun on fun.id_funcionario =  mov.id_funcionario
                              and ((mov.fecha_mov BETWEEN fun.fecha_asignacion and fun.fecha_finalizacion) or (mov.fecha_mov >= fun.fecha_asignacion or fun.fecha_finalizacion is NULL))
                                          left join orga.vfuncionario_cargo_lugar fundes on fundes.id_funcionario = mov.id_funcionario_dest
                              and ((mov.fecha_mov BETWEEN fundes.fecha_asignacion  and fundes.fecha_finalizacion) or (mov.fecha_mov >= fundes.fecha_asignacion or fundes.fecha_finalizacion is NULL))
                              left join orga.toficina ofi on ofi.id_oficina = mov.id_oficina
                              left join param.tlugar tlu on tlu.id_lugar = ofi.id_lugar
                              inner join orga.vfuncionario_cargo_lugar fun1 on fun1.id_funcionario = mov.id_responsable_depto
                              left join segu.vpersona per on per.id_persona = mov.id_persona
                              left join param.tlugar lug on lug.id_lugar = ofi.id_lugar
                       WHERE  id_movimiento = '||v_parametros.id_movimiento;

                  --Devuelve la respuesta
            raise notice '%',v_consulta;
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_MOVDET_REP'
    #DESCRIPCION:   Reporte de movimientos detalle
    #AUTOR:         RAC
    #FECHA:         20/03/2017
    ***********************************/

    elsif(p_transaccion='SKA_MOVDET_REP')then

        begin

            --Consulta
            v_consulta:=' 
                            select
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
                            kaf.f_get_tipo_activo(af.id_activo_fijo) as tipo_activo,
                            cla.codigo_completo_tmp||'' - ''|| cla.nombre as desc_clasificacion,
                            af.fecha_ini_dep,
                            af.monto_compra_orig,
                            af.monto_compra_orig_100,
                            af.nro_cbte_asociado,
                            af.observaciones,
                            af.vida_util_original, --#AF-41
                            --Inicio #ETR-3660
                            (SELECT monto_vigente_orig 
                            FROM kaf.tactivo_fijo_valores 
                            WHERE id_activo_fijo = af.id_activo_fijo
                            AND (tipo = ''alta'' OR tipo = ''dval'') --#AF-44
                            AND id_moneda = 1) as monto_orig_bs,
                            (SELECT monto_vigente_orig 
                            FROM kaf.tactivo_fijo_valores 
                            WHERE id_activo_fijo = af.id_activo_fijo
                            AND (tipo = ''alta'' OR tipo = ''dval'') --#AF-44
                            AND id_moneda = 2) as monto_orig_usd,
                            (SELECT monto_vigente_orig 
                            FROM kaf.tactivo_fijo_valores 
                            WHERE id_activo_fijo = af.id_activo_fijo
                            AND (tipo = ''alta'' OR tipo = ''dval'') --#AF-44
                            AND id_moneda = 3) as monto_orig_ufv
                            --Fin #ETR-3660
                     from kaf.tmovimiento_af maf
                          inner join kaf.tactivo_fijo af on af.id_activo_fijo = maf.id_activo_fijo
                          left join param.tcatalogo cat2 on cat2.id_catalogo = maf.id_cat_estado_fun
                          left join kaf.tmovimiento_motivo mmot on mmot.id_movimiento_motivo =  maf.id_movimiento_motivo
                          inner join kaf.tclasificacion cla on cla.id_clasificacion = af.id_clasificacion
                     where maf.id_movimiento = '||v_parametros.id_movimiento;


            v_consulta = v_consulta||' order by af.codigo asc';
            --Devuelve la respuesta
            return v_consulta;

        end;


    /*********************************
    #TRANSACCION:  'SKA_REPDETDE_REP'
    #DESCRIPCION:   Reporte detalle de depreciacion para contabilizacion
    #AUTOR:         RAC
    #FECHA:         17/04/2017
    ***********************************/

    elsif(p_transaccion='SKA_REPDETDE_REP')then

        begin

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

                          FROM kaf.vdetalle_depreciacion_activo_por_gestion daf
                          INNER  JOIN kaf.vclaificacion_raiz cr on cr.id_clasificacion = daf.id_clasificacion
                          INNER JOIN kaf.tmoneda_dep mod on mod.id_moneda_dep = daf.id_moneda_dep
                          WHERE daf.id_movimiento = '||v_parametros.id_movimiento||'
                          ORDER BY
                              daf.id_moneda_dep,
                              daf.gestion_final,
                              daf.tipo,
                              cr.id_claificacion_raiz,
                              daf.id_clasificacion,
                              id_activo_fijo_valor ,
                              daf.fecha_ini_dep';


            --Devuelve la respuesta
            return v_consulta;

        end;

    /*********************************
    #TRANSACCION:  'SKA_OBTMOV_SEL'
    #DESCRIPCION:   Obtención del movimiento por el ID
    #AUTOR:         RCM
    #FECHA:         18-05-2018
    ***********************************/

    elsif(p_transaccion='SKA_OBTMOV_SEL')then

        begin

            --Consulta
            v_consulta:='select
                        mov.id_movimiento,
                        to_char(mov.fecha_hasta,''mm-yyyy'') as fecha_hasta,
                        to_char(mov.fecha_mov,''dd-mm-yyyy'') as fecha_mov,
                        mov.id_depto,
                        mov.glosa,
                        mov.num_tramite,
                        mov.estado,
                        dep.nombre as depto,
                        dep.codigo as cod_depto
                        from kaf.tmovimiento mov
                        inner join param.tdepto dep on dep.id_depto = mov.id_depto
                        where mov.id_movimiento = '||v_parametros.id_movimiento;

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