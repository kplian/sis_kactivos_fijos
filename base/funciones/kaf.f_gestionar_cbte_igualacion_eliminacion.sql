CREATE OR REPLACE FUNCTION kaf.f_gestionar_cbte_igualacion_eliminacion (
  p_id_usuario integer,
  p_id_usuario_ai integer,
  p_usuario_ai varchar,
  p_id_int_comprobante integer,
  p_conexion varchar = NULL::character varying
)
RETURNS boolean AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_gestionar_cbte_igualacion_eliminacion
 DESCRIPCION:    Gestiona la eliminación del comprobante de igualación de saldos
 AUTOR:          RCM
 FECHA:          10/09/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #23    KAF       ETR           10/09/2019  RCM         Creación del archivo
 ****************************************************************************/


DECLARE

	v_nombre_funcion   	text;
	v_resp				varchar;
	v_estado_cbte 		varchar;

BEGIN

	v_nombre_funcion = 'kaf.f_gestionar_cbte_igualacion_eliminacion';

    --Obtención de datos del movimiento
    IF EXISTS(SELECT
			cac.id_movimiento
			FROM  kaf.tcomparacion_af_conta cac
			INNER JOIN conta.tint_comprobante  c
			ON c.id_int_comprobante = cac.id_int_comprobante
			WHERE cac.id_int_comprobante = p_id_int_comprobante) THEN

   		SELECT
		ic.estado_reg
		INTO
		v_estado_cbte
		FROM conta.tint_comprobante ic
		WHERE ic.id_int_comprobante = p_id_int_comprobante;

		IF v_estado_cbte = 'validado' THEN
			RAISE EXCEPTION 'No puede eliminarse el comprobante por estar Validado';
		END IF;

		--Elimina la relación con el comprobante
		UPDATE kaf.tcomparacion_af_conta SET
		id_usuario_mod = p_id_usuario,
		fecha_mod = now(),
		id_int_comprobante = NULL,
		id_usuario_ai = p_id_usuario_ai,
		usuario_ai = p_usuario_ai
		WHERE id_int_comprobante = p_id_int_comprobante;

    ELSE
    	RAISE EXCEPTION 'El comprobante no esta relacionado a ningún movimiento de depreciación';
	END IF;

	RETURN  TRUE;

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