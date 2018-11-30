CREATE OR REPLACE FUNCTION kaf.f_procesa_detalle_depreciacion (
  p_id_usuario integer,
  p_fecha date
)
RETURNS varchar AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_procesa_detalle_depreciacion
 DESCRIPCION:    Preprocesa el detalle de depreciación
 AUTOR:          RCM
 FECHA:          22/10/2018
 COMENTARIOS:   
***************************************************************************/
DECLARE

	v_nombre_funcion  varchar;
    v_respuesta       varchar;
    v_id_moneda_base    integer;

BEGIN

	v_nombre_funcion='kaf.f_procesa_detalle_depreciacion';
    v_id_moneda_base = param.f_get_moneda_base();

    --Verifica si ya tiene datos procesados en esa fecha
    if exists (select 1 from kaf.treporte_detalle_depreciacion
                where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha)) then
        raise exception 'Ya se tiene procesada la depreciación en esa fecha';
    end if;
    
    
    --Carga los datos en la tabla temporal
            insert into kaf.treporte_detalle_depreciacion(fecha_deprec,
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion,depreciacion_per_ant
            )
            select
            date_trunc('month',p_fecha),
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.fecha_ini_dep
                else (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original)
            end as fecha_ini_dep,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig_100
                else (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original)
            end as monto_vigente_orig_100,
            case coalesce(afv.id_activo_fijo_valor_original,0)
                when 0 then afv.monto_vigente_orig
                else (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = afv.id_activo_fijo_valor_original)
            end as monto_vigente_orig,
            case 
                when (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) < 0 then 0
                else (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0))
            end as inc_actualiz,
            mdep.monto_actualiz,
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
            mdep.depreciacion_per_ant
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where date_trunc('month',mdep.fecha) = date_trunc('month',p_fecha::date)
            and mdep.id_moneda = v_id_moneda_base
            and af.estado <> 'eliminado';
           
        
    		insert into kaf.treporte_detalle_depreciacion(fecha_deprec,
            id_activo_fijo_valor,codigo, denominacion ,fecha_ini_dep,monto_vigente_orig_100,monto_vigente_orig,inc_actualiz,
            monto_actualiz,vida_util_orig,vida_util,
            depreciacion_per,depreciacion_acum,monto_vigente,codigo_padre,denominacion_padre,tipo,tipo_cambio_fin,id_moneda_act,
            id_activo_fijo_valor_original,codigo_ant,id_moneda,id_centro_costo,id_activo_fijo,codigo_activo,afecta_concesion,
            depreciacion,depreciacion_per_ant
            )
            select
            date_trunc('month',p_fecha),
            afv.id_activo_fijo_valor,
            afv.codigo,
            af.denominacion,
            afv.fecha_ini_dep,
            afv.monto_vigente_orig_100,
            afv.monto_vigente_orig,
            case 
                  when (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0)) < 0 then 0
                  else (coalesce(mdep.monto_actualiz,0) - coalesce(afv.monto_vigente_orig,0))
            end as inc_actualiz,
            mdep.monto_actualiz,
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
            mdep.depreciacion_per_ant
            from kaf.tmovimiento_af_dep mdep
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            inner join kaf.tactivo_fijo af
            on af.id_activo_fijo = afv.id_activo_fijo
            inner join kaf.tmoneda_dep mon
            on mon.id_moneda =  afv.id_moneda
            where afv.fecha_fin is not null
            and af.estado in ('retiro','baja')
            and not exists (select from kaf.tactivo_fijo_valores where id_activo_fijo_valor_original = afv.id_activo_fijo_valor and tipo <> 'alta')
            and afv.codigo not in (select codigo
									from kaf.treporte_detalle_depreciacion
                                    where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha))
            and date_trunc('month',mdep.fecha) = (select max(fecha)
                                                    from kaf.tmovimiento_af_dep
                                                    where id_activo_fijo_valor = afv.id_activo_fijo_valor
                                                    and id_moneda_dep = mdep.id_moneda_dep
                                                    and date_trunc('month',fecha) <= date_trunc('month',p_fecha::date) --between date_trunc('month',('01-01-'||extract(year from p_fecha)::varchar)::date) and date_trunc('month',p_fecha)
                                                )
            and mdep.id_moneda = v_id_moneda_base
            and afv.id_activo_fijo_valor not in (select id_activo_fijo_valor
                                                from kaf.treporte_detalle_depreciacion)
            and af.estado <> 'eliminado'
            and date_trunc('year',af.fecha_baja) = date_trunc('year',p_fecha::date)
            and date_trunc('month',af.fecha_baja) = date_trunc('month',afv.fecha_fin + '1 month'::interval);
            
            --Busca y obtiene el AFV padre si lo tiene
            update kaf.treporte_detalle_depreciacion set
            id_activo_fijo_valor_padre = kaf.f_get_afv_padre(kaf.treporte_detalle_depreciacion.id_activo_fijo_valor)
            where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha);
            
            --Setea valores iniciales del padre si lo tienen
            update kaf.treporte_detalle_depreciacion set
            fecha_ini_dep = (select fecha_ini_dep from kaf.tactivo_fijo_valores where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre),
			monto_vigente_orig_100 = (select monto_vigente_orig_100 from kaf.tactivo_fijo_valores where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre),
			monto_vigente_orig = (select monto_vigente_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre),
            vida_util_orig = (select vida_util_orig from kaf.tactivo_fijo_valores where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre)
            where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha)
            and coalesce(id_activo_fijo_valor_original,0) <> 0;
            
            --------------------------------------------------
            --------------------------------------------------
            
            --Obtiene los datos de gestion anterior
            update kaf.treporte_detalle_depreciacion set
            depreciacion_acum_gest_ant = coalesce(
                (
                select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor
                and id_moneda_dep = v_id_moneda_base
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from p_fecha::date)::integer -1 )::date)
                ),0),
            depreciacion_acum_actualiz_gest_ant = (((kaf.treporte_detalle_depreciacion.tipo_cambio_fin/(param.f_get_tipo_cambio_v2(kaf.treporte_detalle_depreciacion.id_moneda_act,kaf.treporte_detalle_depreciacion.id_moneda /*v_id_moneda_base*/, ('31/12/'||extract(year from p_fecha::date)::integer -1)::date, 'O'))))-1)*(coalesce((
                            select depreciacion_acum
                            from kaf.tmovimiento_af_dep
                            where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor
                            and id_moneda_dep = v_id_moneda_base
                            and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from p_fecha)::integer -1 )::date)
                        ),0))
            where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha);
                        
            --Si la depreciación anterior es cero, busca la depreciación de su activo fijo valor original si es que tuviese
            update kaf.treporte_detalle_depreciacion set
            depreciacion_acum_gest_ant = coalesce((
                select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre/*kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_original*/ /*kaf.f_get_afv_padre(kaf.treporte_detalle_depreciacion.id_activo_fijo_valor)*/
                and tipo = kaf.treporte_detalle_depreciacion.tipo
                and id_moneda_dep = v_id_moneda_base
                and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from p_fecha::date)::integer -1 )::date)
            ),0),
            depreciacion_acum_actualiz_gest_ant = (((kaf.treporte_detalle_depreciacion.tipo_cambio_fin/(param.f_get_tipo_cambio_v2(kaf.treporte_detalle_depreciacion.id_moneda_act,kaf.treporte_detalle_depreciacion.id_moneda/*v_id_moneda_base*/, ('31/12/'||extract(year from p_fecha::date)::integer -1)::date, 'O'))))-1)*(coalesce((
                            select depreciacion_acum
                            from kaf.tmovimiento_af_dep
                            where id_activo_fijo_valor = kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_padre/*kaf.treporte_detalle_depreciacion.id_activo_fijo_valor_original*/  /*kaf.f_get_afv_padre(kaf.treporte_detalle_depreciacion.id_activo_fijo_valor)*/
                            and tipo = kaf.treporte_detalle_depreciacion.tipo
                            and id_moneda_dep = v_id_moneda_base
                            and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from p_fecha::date)::integer -1 )::date)
                        ),0))
            where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha)
            and coalesce(depreciacion_acum_gest_ant,0) = 0
            and id_activo_fijo_valor_original is not null;
            

            --Verifica si hay reg con tipo = ajuste_restar, y le cambia el signo
            update kaf.treporte_detalle_depreciacion set
            monto_vigente_orig_100 = -1 * monto_vigente_orig_100,
            monto_vigente_orig = -1 * monto_vigente_orig,
            inc_actualiz = -1 * inc_actualiz,
            monto_actualiz = -1 * monto_actualiz,
            depreciacion_acum_gest_ant = -1 * depreciacion_acum_gest_ant,
            depreciacion_acum_actualiz_gest_ant = -1 * depreciacion_acum_actualiz_gest_ant,
            depreciacion_per = -1 * depreciacion_per,
            depreciacion_acum = -1 * depreciacion_acum,
            monto_vigente = -1 * monto_vigente
            where date_trunc('month',fecha_deprec) = date_trunc('month',p_fecha)
            and tipo = 'ajuste_restar';
    
    
    return 'hecho';

EXCEPTION

	WHEN OTHERS THEN
        v_respuesta = '';
        v_respuesta = pxp.f_agrega_clave(v_respuesta,'mensaje',SQLERRM);
        v_respuesta = pxp.f_agrega_clave(v_respuesta,'codigo_error',SQLSTATE);
        v_respuesta = pxp.f_agrega_clave(v_respuesta,'procedimiento',v_nombre_funcion);
        raise exception '%', v_respuesta;
    
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;
