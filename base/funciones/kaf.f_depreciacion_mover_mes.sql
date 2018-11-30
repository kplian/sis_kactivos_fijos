CREATE OR REPLACE FUNCTION kaf.f_depreciacion_mover_mes (
  p_id_movimiento integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       f_depreciacion_mover_mes
 DESCRIPCION:   Mueve la depreciación de un movimiento en varios meses al último mes
 AUTOR:         RCM
 FECHA:         05/10/2018
 COMENTARIOS:
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:
 AUTOR:
 FECHA:
***************************************************************************/
DECLARE

    v_resp              varchar;
    v_nombre_funcion    text;
    v_mensaje_error     text;
    v_rec               record;
    v_rec_afv           record;
    v_fecha             date;
    v_sum_deprec        numeric;
    v_rec_pri           record;
    v_rec_ult           record;
    v_dep_acum_ant      numeric;
    v_dep_acum_actualiz numeric;
    v_estado            varchar;

BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_ime';

    select fecha_hasta, estado
    into v_fecha, v_estado
    from kaf.tmovimiento
    where id_movimiento = p_id_movimiento;

    if v_estado = 'finalizado' then
        raise exception 'No es posible mover la depreciación porque el movimiento está Finalizado';
    end if;


    for v_rec in (select distinct maf.id_activo_fijo, maf.id_movimiento_af, mdep.id_activo_fijo_valor
                from kaf.tmovimiento mov
                inner join kaf.tmovimiento_af maf
                on maf.id_movimiento = mov.id_movimiento
                inner join kaf.tmovimiento_af_dep mdep
                on mdep.id_movimiento_af = maf.id_movimiento_af
                and mdep.fecha < mov.fecha_hasta
                inner join kaf.tactivo_fijo_valores afv
                on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                where mov.id_movimiento = p_id_movimiento
                and afv.fecha_ult_dep is null
                --and maf.id_activo_fijo = 55250
    ) loop
            --raise notice '';
            --raise notice 'v_rec.id_activo_fijo_valor, ';
            --Sumar toda la depreciación
            select sum(depreciacion), sum(depreciacion_acum_ant), sum(depreciacion_acum_actualiz)
            into v_sum_deprec, v_dep_acum_ant, v_dep_acum_actualiz
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and id_movimiento_af = v_rec.id_movimiento_af;
            --raise notice 'suma: %',v_sum_deprec;

            --Obtener la primera depreciación
            select *
            into v_rec_pri
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and id_movimiento_af = v_rec.id_movimiento_af
            and fecha in (select min(fecha)
                          from kaf.tmovimiento_af_dep
                          where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
                          and id_movimiento_af = v_rec.id_movimiento_af);

            --Obtener la última depreciación
            select *
            into v_rec_ult
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and id_movimiento_af = v_rec.id_movimiento_af
            and fecha in (select max(fecha)
                          from kaf.tmovimiento_af_dep
                          where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
                          and id_movimiento_af = v_rec.id_movimiento_af);
--            raise notice 'valores 1: %  %  %  %',v_rec_pri.depreciacion_acum_ant,v_rec_pri.depreciacion_per_ant,v_rec_pri.monto_vigente_ant,v_rec_pri.vida_util_ant ;
--            raise notice 'valores 2: %  %  %  %',v_rec_pri.tipo_cambio_ini,v_sum_deprec,v_rec_ult.tipo_cambio_fin / v_rec_pri.tipo_cambio_ini,v_rec_ult.id_movimiento_af_dep;
            --Actualizar la última depreciación
            update kaf.tmovimiento_af_dep set
            depreciacion_acum_ant   = v_rec_pri.depreciacion_acum_ant,
            depreciacion_per_ant    = v_rec_pri.depreciacion_per_ant,
            monto_vigente_ant       = v_rec_pri.monto_vigente_ant,
            vida_util_ant           = v_rec_pri.vida_util_ant,
            tipo_cambio_ini         = v_rec_pri.tipo_cambio_ini,
            monto_actualiz_ant      = v_rec_pri.monto_actualiz_ant,

            depreciacion            = v_sum_deprec, --v_rec_ult.depreciacion_acum,
            factor                  = v_rec_ult.tipo_cambio_fin / v_rec_pri.tipo_cambio_ini,
            meses_acum              = 'si',
            tmp_inc_actualiz_dep_acum = v_dep_acum_actualiz - v_dep_acum_ant


            /*depreciacion_per_ant = v_rec_pri.depreciacion_per_ant,
            monto_vigente_ant = v_rec_pri.monto_vigente_ant,
            vida_util_ant = v_rec_pri.vida_util_ant,
            tipo_cambio_ini = v_rec_pri.tipo_cambio_ini,
            depreciacion = v_rec_ult.depreciacion_acum,
            factor = v_rec_ult.tipo_cambio_fin / v_rec_pri.tipo_cambio_ini,
            meses_acum = 'si',
            depreciacion_acum_ant = v_rec_ult.depreciacion_acum_actualiz - (v_dep_acum_actualiz - v_dep_acum_ant)*/
            --monto_actualiz_ant = v_rec_pri.monto_actualiz_ant
            where id_movimiento_af_dep = v_rec_ult.id_movimiento_af_dep;

            --Eliminar las depreciaciones menos la última
            delete from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and id_movimiento_af = v_rec.id_movimiento_af
            and id_movimiento_af_dep <> v_rec_ult.id_movimiento_af_dep;

    end loop;
    --raise exception 'llego al final';
    --Respuesta
    return 'hecho';

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