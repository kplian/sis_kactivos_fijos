CREATE OR REPLACE FUNCTION kaf.f_movimiento_af_validar_mov_compatibles (
  p_id_movimiento integer,
  p_id_activo_fijo integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_movimientos_af_validaf_mov_compatibles
 DESCRIPCION:   Verifica si el activo fijo a insertar al movimiento no está paralelamente en otro movimiento no compatible
 AUTOR:         RCM
 FECHA:         27/06/2017
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/
DECLARE

    v_rec                   record;
    v_nombre_funcion        text;
    v_resp                  varchar;
    v_sql                   varchar;
    v_criterio              varchar;
    v_mensaje               varchar;
    v_codigo_af             varchar;
    v_denominacion_af       varchar;

BEGIN

    v_nombre_funcion = 'kaf.f_movimiento_af_validar_mov_compatibles';
    v_criterio = '';
    
    --Obtiene datos del movimiento
    select 
    mov.estado,
    mov.codigo,
    cat.codigo as codigo_movimiento,
    mov.id_depto
    into 
    v_rec
    from kaf.tmovimiento mov
    inner join  param.tcatalogo cat
    on cat.id_catalogo = mov.id_cat_movimiento
    where mov.id_movimiento =  p_id_movimiento;

    --Obtiene datos del activo fijo
    select codigo, denominacion
    into v_codigo_af, v_denominacion_af
    from kaf.tactivo_fijo
    where id_activo_fijo = p_id_activo_fijo;
    
    --Consulta básica
    v_sql = 'select
        cat.codigo as codigo_movimiento, mov.fecha_mov, mov.num_tramite, mov.estado
        from kaf.tmovimiento mov
        inner join  param.tcatalogo cat
        on cat.id_catalogo = mov.id_cat_movimiento
        inner join kaf.tmovimiento_af maf
        on maf.id_movimiento = mov.id_movimiento
        where maf.id_activo_fijo = p_id_activo_fijo
        and mov.estado not in (''borrador'',''finalizado'',''anulado'')';
    
    --Verificación por tipo de movimiento
    if v_rec.codigo_movimiento = 'alta' then
        
    elsif v_rec.codigo_movimiento = 'baja' then
    elsif v_rec.codigo_movimiento = 'reval' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'mejora' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'deprec' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'asig' then
        v_criterio = ' and cat.codigo in (''alta'',''asig'',''devol'',''transf'',''tranfdep'',''desgl'')';
    elsif v_rec.codigo_movimiento = 'devol' then
        v_criterio = ' and cat.codigo in (''alta'',''asig'',''devol'',''transf'',''tranfdep'',''desgl'')';
    elsif v_rec.codigo_movimiento = 'transf' then
        v_criterio = ' and cat.codigo in (''alta'',''asig'',''devol'',''transf'',''tranfdep'',''desgl'')';
    elsif v_rec.codigo_movimiento = 'ajuste' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'retiro' then

    elsif v_rec.codigo_movimiento = 'tranfdep' then
        v_criterio = ' and cat.codigo in (''alta'',''asig'',''devol'',''transf'',''tranfdep'',''desgl'')';
    elsif v_rec.codigo_movimiento = 'actua' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'divis' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    elsif v_rec.codigo_movimiento = 'desgl' then
        
    elsif v_rec.codigo_movimiento = 'intpar' then
        v_criterio = ' and cat.codigo in (''alta'',''baja'',''reval'',''mejora'',''deprec'',''ajuste'',''retiro'',''actua'',''divis'',''desgl'',''intpar'')';
    end if;

    --Agrega el filtro a la consulta si existe
    if v_criterio != '' then
        v_sql = v_sql || v_criterio;
    end if;

    --Ejecuta la consulta y recorre los resultados
    for v_rec in execute(v_sql) loop
        v_mensaje = v_mensaje || ' ::: '||kaf.f_get_descripcion_mov(v_rec.codigo_movimiento) || ', fecha: ' || to_char(v_rec.fecha_mov,'dd-mm-yyyy') || ', estado: ' || v_rec.estado;
    end loop;

    v_resp = '['||v_codigo_af||'] '||v_denominacion_af||v_mensaje;
    
    --Respuesta
    return v_resp;

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