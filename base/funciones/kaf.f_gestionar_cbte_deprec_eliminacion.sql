CREATE OR REPLACE FUNCTION kaf.f_gestionar_cbte_deprec_eliminacion (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/*
Autor:  RCM
Fecha:  20/04/2018
Descripción:  Gestión de la eliminacion de comprobantes de depreciación. Elimina los 3 comprobantes generados.
*/
DECLARE
  
    v_nombre_funcion        text;
    v_resp                  varchar;
    v_registros             record;
    v_id_estado_actual      integer;
    va_id_tipo_estado       integer[];
    va_codigo_estado        varchar[];
    va_disparador           varchar[];
    va_regla                varchar[]; 
    va_prioridad            integer[];
    v_tipo_sol              varchar;
    v_nro_cuota             numeric;
    v_id_proceso_wf         integer;
    v_id_estado_wf          integer;
    v_id_plan_pago          integer;
    v_verficacion           boolean;
    v_verficacion2          varchar[];
    v_id_tipo_estado        integer;
    v_id_funcionario        integer;
    v_id_usuario_reg        integer;
    v_id_depto              integer;
    v_codigo_estado         varchar;
    v_id_estado_wf_ant      integer;
    v_rec_cbte_trans        record;
    v_reg_cbte              record;
    v_cbte                  varchar;
    v_id_movimiento         integer;
    
BEGIN

    v_nombre_funcion = 'kaf.f_gestionar_cbte_deprec_eliminacion';

    --1) Verifica a que tipo de comprobante corresponde
    select 'actualiz_activo'::varchar, id_movimiento
    into v_cbte, v_id_movimiento
    from kaf.tmovimiento
    where id_int_comprobante = p_id_int_comprobante;

    if v_id_movimiento is null then
        select 'actualiz_dep_acum'::varchar, id_movimiento
        into v_cbte, v_id_movimiento
        from kaf.tmovimiento
        where id_int_comprobante_aitb = p_id_int_comprobante;    
    end if;

    if v_id_movimiento is null then
        select 'deprec'::varchar, id_movimiento
        into v_cbte, v_id_movimiento
        from kaf.tmovimiento
        where id_int_comprobante_3 = p_id_int_comprobante;    
    end if;

    --Si no encuentra el movimiento despliega una excepción
    if v_id_movimiento is null then
        raise exception 'El comprobante no está relacionado a ningún movimiento de depreciación';
    end if;


    --2) Obtención de datos del movimiento
    select 
    mov.id_movimiento,
    mov.id_estado_wf,
    mov.id_proceso_wf,
    mov.estado,
    mov.num_tramite,
    c.id_int_comprobante,         
    c.estado_reg as estadato_cbte,
    mov.id_int_comprobante,
    mov.id_int_comprobante_aitb,
    mov.id_int_comprobante_3
    into
    v_registros
    from kaf.tmovimiento  mov
    inner join conta.tint_comprobante c on c.id_int_comprobante = mov.id_int_comprobante 
    where mov.id_movimiento = v_id_movimiento; 


    --3) Verifica que los 3 comprobantes no estén validados
    if exists(select 1 from conta.tint_comprobante
              where (id_int_comprobante = v_registros.id_int_comprobante and estado_reg = 'validado')
              or (id_int_comprobante = v_registros.id_int_comprobante_aitb and estado_reg = 'validado')
              or (id_int_comprobante = v_registros.id_int_comprobante_3 and estado_reg = 'validado')) then

        raise exception 'No puede eliminarse el comprobante, alguno de los comprobantes generados ya fue validado';

    end if;

   
    --4) Elimina los otros comprobantes generados por la depreciación
    if v_cbte != 'actualiz_activo' and coalesce(v_registros.id_int_comprobante,0)<>0 then
        perform conta.f_cambia_estado_wf_cbte(p_id_usuario, p_id_usuario_ai, p_usuario_ai, v_registros.id_int_comprobante, 'eliminado', 'Cbte eliminado');
                                                    
        --Eliminación de las transacciones
        delete from conta.tint_transaccion
        where id_int_comprobante=v_registros.id_int_comprobante;
                          
        --Eliminación del comprobante
        delete from conta.tint_comprobante
        where id_int_comprobante=v_registros.id_int_comprobante;
        
    end if;
    if v_cbte != 'actualiz_dep_acum' and coalesce(v_registros.id_int_comprobante_aitb,0)<>0 then
        perform conta.f_cambia_estado_wf_cbte(p_id_usuario, p_id_usuario_ai, p_usuario_ai, v_registros.id_int_comprobante_aitb, 'eliminado', 'Cbte eliminado');
    
        --Eliminación de las transacciones
        delete from conta.tint_transaccion
        where id_int_comprobante=v_registros.id_int_comprobante_aitb;
                          
        --Eliminación del comprobante
        delete from conta.tint_comprobante
        where id_int_comprobante=v_registros.id_int_comprobante_aitb;
        
    end if;
    if v_cbte != 'deprec' and coalesce(v_registros.id_int_comprobante_3,0)<>0 then
        perform conta.f_cambia_estado_wf_cbte(p_id_usuario, p_id_usuario_ai, p_usuario_ai, v_registros.id_int_comprobante_3, 'eliminado', 'Cbte eliminado');
        
        --Eliminación de las transacciones
        delete from conta.tint_transaccion
        where id_int_comprobante=v_registros.id_int_comprobante_3;
                          
        --Eliminación del comprobante
        delete from conta.tint_comprobante
        where id_int_comprobante=v_registros.id_int_comprobante_3;
                                                    
    end if;

    --5) Retrocede el estado del movimiento
    --Recupera estado anterior segun Log del WF
    select
    ps_id_tipo_estado,
    ps_id_funcionario,
    ps_id_usuario_reg,
    ps_id_depto,
    ps_codigo_estado,
    ps_id_estado_wf_ant
    into
    v_id_tipo_estado,
    v_id_funcionario,
    v_id_usuario_reg,
    v_id_depto,
    v_codigo_estado,
    v_id_estado_wf_ant 
    from wf.f_obtener_estado_ant_log_wf(v_registros.id_estado_wf);

    select ew.id_proceso_wf 
    into v_id_proceso_wf
    from wf.testado_wf ew
    where ew.id_estado_wf = v_id_estado_wf_ant;

    --Registro del estado anterior
    v_id_estado_actual = wf.f_registra_estado_wf(
        v_id_tipo_estado, 
        v_id_funcionario, 
        v_registros.id_estado_wf, 
        v_id_proceso_wf, 
        p_id_usuario,
        p_id_usuario_ai,
        p_usuario_ai,
        v_id_depto,
        'Eliminación de comprobantes de depreciación generados automáticamente:'|| COALESCE(v_registros.id_int_comprobante::varchar,'NaN')
    );
                    
    --Actualiza estado del movimiento
    update kaf.tmovimiento mov set 
    id_estado_wf = v_id_estado_actual,
    estado = v_codigo_estado,
    id_usuario_mod = p_id_usuario,
    fecha_mod = now(),
    id_int_comprobante = null,
    id_int_comprobante_aitb = null,
    id_int_comprobante_3 = null,
    id_usuario_ai = p_id_usuario_ai,
    usuario_ai = p_usuario_ai
    where mov.id_movimiento = v_registros.id_movimiento;

    --Respuesta
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