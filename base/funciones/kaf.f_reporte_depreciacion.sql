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