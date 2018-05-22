CREATE OR REPLACE FUNCTION kaf.f_i_conta_cbte_retiro (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:     Sistema de Activos Fijos
 FUNCION:     kaf.f_i_conta_cbte_retiro
 DESCRIPCION: Gestiona las acciones a seguir al validar el comprobante generado desde el sistema de contabilidad
 AUTOR:       RCM
 FECHA:       25/08/2017
 COMENTARIOS: 
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION: 
 AUTOR:     
 FECHA:   
***************************************************************************/
DECLARE

    v_nombre_funcion    text;
    v_resp              varchar;
    v_registros         record;
    va_id_tipo_estado   integer[];
    va_codigo_estado    varchar[];
    va_disparador       varchar[];
    va_regla            varchar[]; 
    va_prioridad        integer[];
    v_id_estado_actual  integer;
    
    
BEGIN

    v_nombre_funcion = 'kaf.f_i_conta_cbte_retiro';
 
    --Obtención de datos del movimiento y comprobante generado
    select 
    mov.id_movimiento,
    mov.id_estado_wf,
    mov.id_proceso_wf,
    mov.estado,
    mov.fecha_mov,
    c.temporal,
    c.fecha as fecha_cbte,
    ew.id_funcionario,
    ew.id_depto,
    mov.id_int_comprobante,
    mov.id_int_comprobante_aitb,
    c.estado_reg,
    c.id_depto as id_depto_conta
    into
    v_registros
    from kaf.tmovimiento mov      
    inner join conta.tint_comprobante c
    on c.id_int_comprobante = mov.id_int_comprobante 
    inner join wf.testado_wf ew
    on ew.id_estado_wf = mov.id_estado_wf
    where mov.id_int_comprobante = p_id_int_comprobante; 
    
    --Validación de existencia del movimiento
    if v_registros.id_movimiento is null then
        raise exception 'El comprobante no está relacionado con ningún proceso de activos fijos';
    end if;
     
    --Si el comprobante es validado, se adelanta el paso del WF del proceso de activos fijos
    if v_registros.estado_reg = 'validado' then
        
        --Se obtiene el siguiente estado del flujo 
        select *
        into va_id_tipo_estado, va_codigo_estado, va_disparador, va_regla, va_prioridad
        from wf.f_obtener_estado_wf(v_registros.id_proceso_wf, v_registros.id_estado_wf,NULL,'siguiente');

        --Validaciones de configuración del WF
        if va_codigo_estado[2] is not null then              
            raise exception 'El proceso de WF está mal parametrizado,  solo admite un estado siguiente para el estado: %', v_registros.estado;
        end if;

        if va_codigo_estado[1] is  null then
            raise exception 'El proceso de WF está mal parametrizado, no se encuentra el estado siguiente,  para el estado: %', v_registros.estado;           
        end if;

        --Siguiente estado
        v_id_estado_actual =  wf.f_registra_estado_wf(va_id_tipo_estado[1], 
            v_registros.id_funcionario, 
            v_registros.id_estado_wf, 
            v_registros.id_proceso_wf,
            p_id_usuario,
            p_id_usuario_ai, -- id_usuario_ai
            p_usuario_ai, -- usuario_ai
            v_registros.id_depto_conta,
            'Comprobante validado'
        );

        --Actualiza estado del proceso de activos fijos
        update kaf.tmovimiento mov  set 
        id_estado_wf        = v_id_estado_actual,
        estado              = va_codigo_estado[1],
        id_usuario_mod      = p_id_usuario,
        fecha_mod           = now(),
        id_usuario_ai       = p_id_usuario_ai,
        usuario_ai          = p_usuario_ai
        where mov.id_movimiento = v_registros.id_movimiento; 

    end if;
            
   return true;

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