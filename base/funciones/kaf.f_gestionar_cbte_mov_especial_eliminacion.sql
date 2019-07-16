CREATE OR REPLACE FUNCTION kaf.f_gestionar_cbte_mov_especial_eliminacion (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_gestionar_cbte_mov_especial_eliminacion
 DESCRIPCION:   Lógica empleada luego de eliminar el comprobante
 AUTOR:         RCM
 FECHA:         12/06/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           12/06/2019  RCM         Creación del archivo
***************************************************************************/

DECLARE

    v_nombre_funcion        text;
    v_resp                  varchar;
    v_registros             record;
    v_id_estado_actual      integer;
    v_id_proceso_wf         integer;
    v_id_tipo_estado        integer;
    v_id_funcionario        integer;
    v_id_usuario_reg        integer;
    v_id_depto              integer;
    v_codigo_estado         varchar;
    v_id_estado_wf_ant      integer;
    v_reg_cbte              record;

BEGIN

    v_nombre_funcion = 'kaf.f_gestionar_cbte_mov_especial_eliminacion';

    --1) Obtención de datos
    SELECT
    m.id_movimiento,
    m.id_estado_wf,
    m.id_proceso_wf,
    m.estado,
    m.num_tramite,
    m.id_int_comprobante,
    c.estado_reg AS estado_cbte
    INTO
    v_registros
    FROM kaf.tmovimiento m
    INNER JOIN conta.tint_comprobante c
    ON c.id_int_comprobante = m.id_int_comprobante
    WHERE m.id_int_comprobante = p_id_int_comprobante;

    --2) Validar que tenga una cuenta documentada
    IF COALESCE(v_registros.id_movimiento, 0 ) = 0  THEN
        RAISE EXCEPTION 'El comprobante no está relacionado a ninguna movimiento de Activos Fijos';
    END IF;

    --3) Cambio de estado
    SELECT
    ic.estado_reg
    INTO
    v_reg_cbte
    FROM conta.tint_comprobante ic
    WHERE ic.id_int_comprobante = p_id_int_comprobante;

    IF v_reg_cbte.estado_reg = 'validado' THEN
        RAISE EXCEPTION 'No puede eliminarse el comprobante por estar Validado';
    END IF;

    --Recupera estado anterior segun Log del WF
    SELECT
        ps_id_tipo_estado,
        ps_id_funcionario,
        ps_id_usuario_reg,
        ps_id_depto,
        ps_codigo_estado,
        ps_id_estado_wf_ant
    INTO
        v_id_tipo_estado,
        v_id_funcionario,
        v_id_usuario_reg,
        v_id_depto,
        v_codigo_estado,
        v_id_estado_wf_ant
    FROM wf.f_obtener_estado_ant_log_wf(v_registros.id_estado_wf);

    --
    SELECT ew.id_proceso_wf
    INTO v_id_proceso_wf
    FROM wf.testado_wf ew
    WHERE ew.id_estado_wf = v_id_estado_wf_ant;

    --Registra el nuevo estado
    v_id_estado_actual = wf.f_registra_estado_wf
                        (
                            v_id_tipo_estado,
                            v_id_funcionario,
                            v_registros.id_estado_wf,
                            v_id_proceso_wf,
                            p_id_usuario,
                            p_id_usuario_ai,
                            p_usuario_ai,
                            v_id_depto,
                            'Eliminación de comprobante: ' || COALESCE(v_registros.id_int_comprobante::varchar,'NaN')
                        );

    ------------------------------------------------------------
    --Reversión del procesamiento de la distribución de valores
    ------------------------------------------------------------
    --Eliminación de los AFV creados
    DELETE FROM kaf.tactivo_fijo_valores
    WHERE mov_esp = 'cafv-' || v_registros.id_movimiento::varchar;

    --Quita la relación del nuevo activo fijo creado en el detalle previa a su eliminación
    UPDATE kaf.tmovimiento_af_especial mesp SET
    id_activo_fijo = NULL
    FROM kaf.tmovimiento_af maf
    WHERE maf.id_movimiento = v_registros.id_movimiento
    AND mesp.id_movimiento_af = maf.id_movimiento_af
    AND mesp.tipo = 'af_nuevo';

    --Eliminación de los AFVs nuevos creados
    DELETE FROM kaf.tactivo_fijo
    WHERE bk_codigo = 'caf-' || v_registros.id_movimiento::varchar;

    --Restauración de los AFVs finalizados
    UPDATE kaf.tactivo_fijo_valores SET
    fecha_fin = NULL,
    mov_esp = NULL
    WHERE mov_esp = 'mafv-' || v_registros.id_movimiento::varchar;


    -------------------------------------------
    --Actualización del estado de la solicitud
    -------------------------------------------
    UPDATE kaf.tmovimiento SET
    id_estado_wf        = v_id_estado_actual,
    estado              = v_codigo_estado,
    id_usuario_mod      = p_id_usuario,
    fecha_mod           = now(),
    id_int_comprobante  = NULL,
    id_usuario_ai       = p_id_usuario_ai,
    usuario_ai          = p_usuario_ai
    WHERE id_movimiento = v_registros.id_movimiento;

    RETURN  TRUE;

EXCEPTION

    WHEN OTHERS THEN

        v_resp='';
        v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);

        RAISE EXCEPTION '%', v_resp;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;