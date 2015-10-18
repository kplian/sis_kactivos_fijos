CREATE OR REPLACE FUNCTION kaf.f_procesa_depreciacion (
  p_id_usuario integer,
  p_id_movimiento integer
)
RETURNS varchar AS
$body$
/*
Autor: RCM
Fecha: 11/09/2015
Descripción: Procesa la depreciación de los activos fijos de acuerdo a su método de depreciación
*/
DECLARE

    v_resp varchar;
    v_nombre_funcion varchar;
    v_id_moneda_principal integer;
    v_rec_mov record;
    v_rec record;
    v_errores varchar;
    v_movimiento varchar;

BEGIN
    v_nombre_funcion = 'kaf.f_procesa_depreciacion';
    
    --0. Validación del movimiento
    select
    cat.descripcion, mov.estado, mov.fecha_hasta
    into v_rec_mov
    from kaf.tmovimiento mov
    inner join param.tcatalogo cat
    on cat.id_catalogo = mov.id_cat_movimiento
    where id_movimiento = p_id_movimiento;
    
    if v_rec_mov.descripcion is null then
        raise exception 'Datos de movimiento no encontrados';
    end if;
    
    if v_rec_mov.descripcion <> 'depreciacion' then
        raise exception 'El movimiento no es de Depreciación';
    end if;
    
    if v_rec_mov.estado <> 'borrador' then
        raise exception 'El estado del movimiento debe estar en estado Borrador';
    end if;
    
    --1.Obtención de la moneda base para actualización
    v_id_moneda_principal = param.f_get_moneda_base();
    
    --2.Recorrido de los activos fijos candidatos a depreciar
    v_errores = '';
    for v_rec in (select
                maf.id_activo_fijo, acf.estado, coalesce(cat.descripcion,'N/D') as met_dep,
                cla.id_cat_metodo_dep, maf.id_movimiento_af,
                coalesce(cla.sw_actualizar,'si') as sw_actualizar
                from kaf.tmovimiento mov
                inner join kaf.tmovimiento_af maf
                on maf.id_movimiento = mov.id_movimiento
                inner join kaf.tactivo_fijo acf
                on acf.id_activo_fijo = maf.id_activo_fijo
                inner join kaf.tclasificacion cla
                on cla.id_clasificacion = acf.id_clasificacion
                left join param.tcatalogo cat
                on cat.id_catalogo = cla.id_cat_metodo_dep
                where mov.id_movimiento = p_id_movimiento) loop
        --2.1 Validaciones        
        --Estado
        if v_rec.estado != 'alta' then
            v_errores = v_errores || ' || No dado de Alta';
        end if;        
     
        --Vida útil
        if not exists (select 1
                      from kaf.tactivo_fijo_valores
                      where id_activo_fijo = v_rec.id_activo_fijo
                      and vida_util > 0
                      and estado = 'activo') then
            v_errores = v_errores || ' || Vida útil terminada';
        end if;
        --Fecha inicio depreciación
        if exists (select 1
                      from kaf.tactivo_fijo_valores
                      where id_activo_fijo = v_rec.id_activo_fijo
                      and vida_util > 0
                      and estado = 'activo'
                      and months_between(v_rec_mov.fecha_hasta,fecha_ini_dep) < 0) then
            v_errores = v_errores || ' || Fecha inicio de depreciación posterior a la fecha de depreciación (' || v_rec_mov.fecha_hasta ||')';
        end if;

        --Fecha última depreciación
        if exists (select 1
                      from kaf.tactivo_fijo_valores
                      where id_activo_fijo = v_rec.id_activo_fijo
                      and vida_util > 0
                      and estado = 'activo'
                      and months_between(v_rec_mov.fecha_hasta,fecha_ult_dep) < 0) then
            v_errores = v_errores || ' || Activo Fijo ya depreciado hasta fecha de depreciación (' || v_rec_mov.fecha_hasta ||')';
        end if;
        --Activo en procesos previos pendientes
        select cat.descripcion
        into v_movimiento
        from kaf.tmovimiento_af maf
        inner join kaf.tmovimiento mov
        on mov.id_movimiento = maf.id_movimiento
        inner join param.tcatalogo cat
        on cat.id_catalogo = mov.id_cat_movimiento
        where maf.id_activo_fijo = v_rec.id_activo_fijo
        and mov.estado not in ('finalizado','anulado')
        and mov.id_movimiento != p_id_movimiento;
        
        if v_movimiento is not null then
            v_errores = v_errores || ' || Activo Fijo en Proceso de ' || v_movimiento ||' pendiente';
        end if;
        
        --Activo fijo depreciable
        if v_rec.id_cat_metodo_dep is null then
            if v_rec.sw_actualizar = 'no' then
                v_errores = v_errores || ' || Activo Fijo No Depreciable ni Actualizable';
            end if;
        end if;
        --2.2 Ejecución de la depreciación según el método definido en su clasificación
        if v_errores = '' then
            
            if v_rec.met_dep = 'lineal' then
                v_errores = kaf.f_depreciacion_lineal(p_id_usuario,v_rec.id_activo_fijo,v_rec_mov.fecha_hasta);
            elsif v_rec.met_dep = 'hrs_prod' then
                --Método de depreciación no implementado
            elsif v_rec.met_dep = 'N/D' then
                --Actualización solamente
                v_errores = kaf.f_actualizacion(p_id_usuario,v_rec.id_activo_fijo,v_rec_mov.fecha_hasta);
            else
                --Método de depreciación inválido
                v_errores = ' || Método de depreciación inválido';
            end if;
            
            if v_errores != 'done' then
                --Guardar log de errores
                update kaf.tmovimiento_af set
                estado = 'no_procesado',
                respuesta = v_errores
                where id_movimiento_af = v_rec.id_movimiento_af;
            else
                --Actualizar resultado
                update kaf.tmovimiento_af set
                estado = 'procesado',
                respuesta = null
                where id_movimiento_af = v_rec.id_movimiento_af;
            end if;

        else
            --Guardar log de errores
            update kaf.tmovimiento_af set
            estado = 'no_procesado',
            respuesta = v_errores
            where id_movimiento_af = v_rec.id_movimiento_af;
        end if;
                
    end loop;
    
    return 'done';

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