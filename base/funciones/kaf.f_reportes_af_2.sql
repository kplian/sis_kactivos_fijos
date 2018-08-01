CREATE OR REPLACE FUNCTION kaf.f_reportes_af_2 (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_reportes_af_2
 DESCRIPCION:    Funcion que devuelve conjunto de datos para reportes de activos fijos
 AUTOR:          RCM
 FECHA:          25/06/2018
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
    
    v_lugar         varchar = '';
    v_filtro        varchar;
    v_record        record;
    v_desc_nombre   varchar;
    v_caract_invalidos varchar;

BEGIN
 
    v_nombre_funcion='kaf.f_reportes_af_2';
    v_parametros=pxp.f_get_record(p_tabla);
  
    /*********************************   
     #TRANSACCION:  'SKA_FRM605_SEL'
     #DESCRIPCION:  Reporte Formulario 605 para impuestos
     #AUTOR:        RCM
     #FECHA:        25/06/2018
    ***********************************/
    if(p_transaccion='SKA_FRM605_SEL') then

        begin
        
            v_caract_invalidos = pxp.f_get_variable_global('kaf_caracteres_no_validos_form605');

            v_consulta = 'select
                        af.codigo,
                        af.codigo_ant,
                        af.fecha_ini_dep,
                        pxp.f_limpiar_cadena(af.denominacion,'''||v_caract_invalidos||''') as denominacion,
                        round(mdep.monto_actualiz,2),
                        round(mdep.depreciacion_acum,2),
                        round(mdep.monto_vigente,2)
                        from kaf.tmovimiento_af_dep mdep
                        inner join kaf.tactivo_fijo_valores afv
                        on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = afv.id_activo_fijo
                        where mdep.id_moneda = '||v_parametros.id_moneda||'
                        and date_trunc(''month'',mdep.fecha) = date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) ';

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' and '||v_parametros.filtro;
                v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || coalesce(v_parametros.cantidad,9999999) || ' offset ' || coalesce(v_parametros.puntero,0);
            else
                v_consulta = v_consulta||' order by af.codigo';
            end if;

            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_FRM605_CONT'
     #DESCRIPCION:  Reporte Formulario 605 para impuestos
     #AUTOR:        RCM
     #FECHA:        25/06/2018
    ***********************************/
  
    elsif(p_transaccion='SKA_FRM605_CONT') then

        begin

            v_consulta = 'select
                        count(1) as total
                        from kaf.tmovimiento_af_dep mdep
                        inner join kaf.tactivo_fijo_valores afv
                        on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                        inner join kaf.tactivo_fijo af
                        on af.id_activo_fijo = afv.id_activo_fijo
                        where mdep.id_moneda = '||v_parametros.id_moneda||'
                        and date_trunc(''month'',mdep.fecha) = date_trunc(''month'','''||v_parametros.fecha_hasta||'''::date) ';

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' and '||v_parametros.filtro;
            end if;

            return v_consulta;

        end;
        
    /*********************************   
     #TRANSACCION:  'SKA_LISAF_SEL'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
    elsif(p_transaccion='SKA_LISAF_SEL') then

        begin
        
              v_consulta = 'select
                          afij.codigo,
                          afij.codigo_ant,
                          afij.denominacion,
                          cla.descripcion,
                          afij.fecha_compra,
                          afij.fecha_ini_dep,
                          afij.vida_util_original,
                          afij.cantidad_af,
                          um.codigo as desc_unidad_medida,
                          afij.estado,
                          afij.monto_compra_orig,
                          cc.codigo_tcc,
                          fun.desc_funcionario2,
                          afij.fecha_asignacion,
                          ubi.codigo as desc_ubicacion
                          from kaf.tactivo_fijo afij
                          inner join param.tunidad_medida um
                          on um.id_unidad_medida = afij.id_unidad_medida
                          inner join param.tmoneda mon
                          on mon.id_moneda = afij.id_moneda_orig
                          left join param.vcentro_costo cc
                          on cc.id_centro_costo = afij.id_centro_costo
                          inner join kaf.tclasificacion cla
                          on cla.id_clasificacion = afij.id_clasificacion
                          left join orga.vfuncionario fun
                          on fun.id_funcionario = afij.id_funcionario
                          left join kaf.tubicacion ubi
                          on ubi.id_ubicacion = afij.id_ubicacion ';

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' where '||v_parametros.filtro;
                v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || coalesce(v_parametros.cantidad,9999999) || ' offset ' || coalesce(v_parametros.puntero,0);
            else
                v_consulta = v_consulta||' order by afij.codigo';
            end if;

            return v_consulta;

        end;

    /*********************************   
     #TRANSACCION:  'SKA_LISAF_CONT'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
  
    elsif(p_transaccion='SKA_LISAF_CONT') then

        begin

            v_consulta = 'select
                          count(1) as total
                          from kaf.tactivo_fijo afij
                          inner join param.tunidad_medida um
                          on um.id_unidad_medida = afij.id_unidad_medida
                          inner join param.tmoneda mon
                          on mon.id_moneda = afij.id_moneda_orig
                          left join param.vcentro_costo cc
                          on cc.id_centro_costo = afij.id_centro_costo
                          inner join kaf.tclasificacion cla
                          on cla.id_clasificacion = afij.id_clasificacion
                          left join orga.vfuncionario fun
                          on fun.id_funcionario = afij.id_funcionario
                          left join kaf.tubicacion ubi
                          on ubi.id_ubicacion = afij.id_ubicacion ';

            if v_parametros.tipo_salida = 'grid' then
                --Definicion de la respuesta
                v_consulta:=v_consulta||' where '||v_parametros.filtro;
            end if;

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