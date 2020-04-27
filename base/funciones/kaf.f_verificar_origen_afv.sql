CREATE OR REPLACE FUNCTION kaf.f_define_origen (
  p_id_proyecto_activo INTEGER,
  p_id_preingreso_det INTEGER,
  p_id_movimiento_af_especial INTEGER,
  p_id_movimiento_af INTEGER,
  p_mov_esp VARCHAR
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_verificar_origen_afv
 DESCRIPCION:   Determina a que tipo de movimiento corresponde un AFV
 AUTOR:         RCM
 FECHA:         07/04/2020
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #58    KAF       ETR           07/04/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

	v_nombre_funcion		varchar;
    v_resp					varchar;

BEGIN

	v_nombre_funcion = 'kaf.f_verificar_origen_afv';

	--Verifica que tipo de origen tiene el AFV a partir de los IDs del parámetro
	IF COALESCE(p_id_proyecto_activo, 0) > 0 THEN
		v_resp = 'proy';
	ELSIF COALESCE(p_id_preingreso_det, 0) > 0 THEN
		v_resp = 'preing';
	ELSIF COALESCE(p_id_movimiento_af_especial, 0) > 0 THEN
		v_resp = 'dval';
	ELSIF COALESCE(p_id_movimiento_af, 0) > 0 AND COALESCE(p_mov_esp, '') <> '' THEN
		v_resp = 'dval-bolsa';
	ELSE
		v_resp = 'af';
	END IF;

	--Respuesta
	RETURN v_resp;

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
PARALLEL UNSAFE;
