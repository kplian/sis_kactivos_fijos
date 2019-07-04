CREATE OR REPLACE FUNCTION kaf.f_gestionar_cbte_mov_especial (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:       Misceláneo
 FUNCION:       kaf.f_gestionar_cbte_mov_especial
 DESCRIPCION:   Esta funcion gestiona los cbtes de la distribucion de valores
 AUTOR:         RCM
 FECHA:         12/06/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           12/06/2019  RCM         Creación del archivo
***************************************************************************/

DECLARE

    v_nombre_funcion            text;
    v_resp                      varchar;
    v_registros                 record;
    v_id_estado_actual          integer;
    va_id_tipo_estado           integer[];
    va_codigo_estado            varchar[];
    va_disparador               varchar[];
    va_regla                    varchar[];
    va_prioridad                integer[];

BEGIN

    v_nombre_funcion = 'kaf.f_gestionar_cbte_mov_especial';

    --1) Obtención de datos
    SELECT
    m.id_movimiento,
    m.id_estado_wf,
    m.id_proceso_wf,
    m.estado,
    ew.id_funcionario,
    ew.id_depto
    INTO
    v_registros
    FROM kaf.tmovimiento m
    INNER JOIN wf.testado_wf ew
    ON ew.id_estado_wf = m.id_estado_wf
    WHERE m.id_int_comprobante = p_id_int_comprobante;

    --2) Valida que el comprobante esté relacionado con un movimiento
    IF v_registros.id_movimiento IS NULL THEN
        RAISE EXCEPTION 'El comprobante no está relacionado con ningún movimiento de Activos Fijos (Id. Cbtes%, %)', p_id_int_comprobante, v_registros;
    END IF;

    --3) Cambiar el estado del movimiento, Obtiene el siguiente estado del flujo
    SELECT
    *
    INTO
    va_id_tipo_estado,
    va_codigo_estado,
    va_disparador,
    va_regla,
    va_prioridad
    FROM wf.f_obtener_estado_wf(v_registros.id_proceso_wf, v_registros.id_estado_wf, NULL, 'siguiente');

    IF va_codigo_estado[2] IS NOT NULL THEN
        RAISE EXCEPTION 'El proceso de WF esta mal parametrizado, sólo admite un estado siguiente para el estado: %', v_registros.estado;
    END IF;

    IF va_codigo_estado[1] IS NULL THEN
      RAISE EXCEPTION 'El proceso de WF esta mal parametrizado, no se encuentra el estado siguiente, para el estado: %', v_registros.estado;
    END IF;

    --Estado siguiente
    v_id_estado_actual = wf.f_registra_estado_wf
                        (
                            va_id_tipo_estado[1],
                            v_registros.id_funcionario,
                            v_registros.id_estado_wf,
                            v_registros.id_proceso_wf,
                            p_id_usuario,
                            p_id_usuario_ai,
                            p_usuario_ai,
                            v_registros.id_depto,
                            'Comprobante de Distribución de Valores validado satisfactoriamente'
                        );

    --Actualiza estado del proceso
    UPDATE kaf.tmovimiento SET
    id_estado_wf    = v_id_estado_actual,
    estado          = va_codigo_estado[1],
    id_usuario_mod  = p_id_usuario,
    fecha_mod       = now(),
    id_usuario_ai   = p_id_usuario_ai,
    usuario_ai      = p_usuario_ai
    WHERE id_movimiento = v_registros.id_movimiento;

    --Respuesta
    RETURN TRUE;

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