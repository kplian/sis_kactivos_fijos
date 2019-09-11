CREATE OR REPLACE FUNCTION kaf.f_get_activo_fijo_caract (
  p_id_usuario INTEGER,
  p_id_activo_fijo INTEGER,
  p_variable VARCHAR
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_get_activo_fijo_caract
 DESCRIPCION:   Devuelve la característica registrada de una variable de un activo fijo
 AUTOR: 		RCM
 FECHA:	        15/07/2019
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #18    KAF       ETR           15/07/2019  RCM         Creación
***************************************************************************/
DECLARE

	v_resp		            varchar;
	v_nombre_funcion        text;
    v_valor 				varchar;

BEGIN

	v_nombre_funcion = 'kaf.f_get_activo_fijo_caract';

    SELECT
    afc.valor
    INTO
    v_valor
    FROM kaf.tclasificacion_variable clv
    INNER JOIN kaf.tactivo_fijo_caract afc
    ON afc.id_clasificacion_variable = clv.id_clasificacion_variable
    WHERE afc.id_activo_fijo = p_id_activo_fijo
    AND clv.nombre = p_variable;

    RETURN COALESCE(v_valor,'(No Definido)');

EXCEPTION

	WHEN OTHERS THEN
		v_resp='';
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);

		RAISE EXCEPTION '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;