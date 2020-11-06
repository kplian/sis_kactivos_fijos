CREATE OR REPLACE FUNCTION kaf.f_depreciacion_mover_mes_x_afv (
  p_id_afvs varchar,
  p_fecha_hasta date
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       f_depreciacion_mover_mes_x_afv
 DESCRIPCION:   Función para utilizar desde la BD basada en kaf.f_depreciacion_mover_mes sólo que recibe IDs AFV como prámetro
 AUTOR:         RCM
 FECHA:         31/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-10 KAF       ETR           31/08/2020  RCM         Creación del archivo
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
    v_sql TEXT;

BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_ime';
    v_fecha = p_fecha_hasta;

    v_sql = 'select distinct
    			afv.id_activo_fijo, mdep.id_activo_fijo_valor
                from kaf.tmovimiento_af_dep mdep
                inner join kaf.tactivo_fijo_valores afv
                on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                where afv.id_activo_fijo_valor in (' || p_id_afvs || ')
                and afv.fecha_ult_dep is null';

    for v_rec in execute(v_sql) loop

            --Sumar toda la depreciación
            select sum(depreciacion), sum(depreciacion_acum_ant), sum(depreciacion_acum_actualiz)
            into v_sum_deprec, v_dep_acum_ant, v_dep_acum_actualiz
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor;

            --Obtener la primera depreciación
            select *
            into v_rec_pri
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and fecha in (select min(fecha)
                          from kaf.tmovimiento_af_dep
                          where id_activo_fijo_valor = v_rec.id_activo_fijo_valor);

            --Obtener la última depreciación
            select *
            into v_rec_ult
            from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and fecha in (select max(fecha)
                          from kaf.tmovimiento_af_dep
                          where id_activo_fijo_valor = v_rec.id_activo_fijo_valor);

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
            where id_movimiento_af_dep = v_rec_ult.id_movimiento_af_dep;

            --Eliminar las depreciaciones menos la última
            delete from kaf.tmovimiento_af_dep
            where id_activo_fijo_valor = v_rec.id_activo_fijo_valor
            and id_movimiento_af_dep <> v_rec_ult.id_movimiento_af_dep;

    end loop;

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
PARALLEL UNSAFE
COST 100;