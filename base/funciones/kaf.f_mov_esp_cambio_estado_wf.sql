CREATE OR REPLACE FUNCTION kaf.f_mov_esp_cambio_estado_wf (
  p_id_usuario integer,
  p_id_proceso_wf integer,
  p_id_estado_anterior integer,
  p_id_tipo_estado_actual integer
)
RETURNS boolean AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_mov_esp_cambio_estado_wf

 DESCRIPCION:   Función para evaluar el cambio de estado para el movimiento especial Distribucion de Valores
 AUTOR:         RCM
 FECHA:         12/06/2019
 COMENTARIOS:

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           12/06/2019  RCM         Creacion de la funcion
***************************************************************************/
DECLARE

    v_nombre_funcion text;
    v_resp varchar;
    v_resp1 boolean;

BEGIN

    v_nombre_funcion = 'kaf.f_mov_esp_cambio_estado_wf';

	v_resp1 = true;

    --Respuesta negativa por defecto
    RETURN v_resp1;

EXCEPTION

  WHEN OTHERS THEN

      v_resp = '';
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