CREATE OR REPLACE FUNCTION kaf.f_generar_prorrateo_mensual_cc (
	p_id_usuario integer,
	p_fecha date
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:   	Sistema de Activos Fijos
 FUNCION:     	kaf.f_generar_prorrateo_mensual_cc
 DESCRIPCION:   Genera el prorrateo mensual por CC automáticamente para los AF que no completaron el tope mensual
 AUTOR:      	RCM
 FECHA:         18/06/2019
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #16    KAF       ETR           18/06/2019  RCM         Completa el prorrateo mensual con el CC por defecto por AF cuando no completa el total mensual
***************************************************************************/
DECLARE

	v_resp                      varchar;
    v_nombre_funcion            text;
    v_tope_mensual				numeric;
    v_af_err 					varchar;

BEGIN

	v_nombre_funcion = 'kaf.f_generar_prorrateo_mensual_cc';

	--Obtención del tope mensual
    v_tope_mensual = pxp.f_get_variable_global('kaf_activo_fijo_cc')::numeric;

    IF COALESCE(v_tope_mensual, 0) = 0 THEN
        RAISE EXCEPTION 'No se definió el tope mensual para el prorrateo';
    END IF;

    --Verifica que el AF tenga CC
    IF EXISTS(WITH tpro_af_cc AS (
		        SELECT
		        id_activo_fijo, date_trunc('month', afcc.mes) AS fecha,
		        sum(cantidad_horAS) OVER (PARTITION BY afcc.id_activo_fijo) AS total_horas
		        FROM kaf.tactivo_fijo_cc afcc
		        WHERE afcc.estado_reg = 'activo'
		    )
		    SELECT
		    p_id_usuario, NOW(), 'activo', afcc.id_activo_fijo, af.id_centro_costo, afcc.fecha, v_tope_mensual - afcc.total_horas
		    FROM tpro_af_cc afcc
		    INNER JOIN kaf.tactivo_fijo af
		    ON af.id_activo_fijo = afcc.id_activo_fijo
		    WHERE DATE_TRUNC('month', afcc.fecha) = DATE_TRUNC('month',p_fecha)
		    AND afcc.total_horas < v_tope_mensual
		    AND COALESCE(af.id_centro_costo, 0) = 0) THEN

    		WITH tpro_af_cc AS (
		        SELECT
		        id_activo_fijo, date_trunc('month', afcc.mes) AS fecha,
		        sum(cantidad_horAS) OVER (PARTITION BY afcc.id_activo_fijo) AS total_horas
		        FROM kaf.tactivo_fijo_cc afcc
		        WHERE afcc.estado_reg = 'activo'
		    )
		    SELECT
		    pxp.list(af.codigo)
		    INTO v_af_err
		    FROM tpro_af_cc afcc
		    INNER JOIN kaf.tactivo_fijo af
		    ON af.id_activo_fijo = afcc.id_activo_fijo
		    WHERE DATE_TRUNC('month', afcc.fecha) = DATE_TRUNC('month',p_fecha)
		    AND afcc.total_horas < v_tope_mensual
		    AND COALESCE(af.id_centro_costo, 0) = 0;

		    RAISE EXCEPTION 'No puede realizarse el prorrateo, porque los siguientes activos fijos no tienen CC definido: %', v_af_err;

    END IF;

    --Completa el prorrateo en el mes solicitado
    INSERT INTO kaf.tactivo_fijo_cc (
    id_usuario_reg,
    fecha_reg,
    estado_reg,
    id_activo_fijo,
    id_centro_costo,
    mes,
    cantidad_horas
    )
    WITH tpro_af_cc AS (
        SELECT
        id_activo_fijo, date_trunc('month', afcc.mes) AS fecha,
        sum(cantidad_horAS) OVER (PARTITION BY afcc.id_activo_fijo) AS total_horas
        FROM kaf.tactivo_fijo_cc afcc
        WHERE afcc.estado_reg = 'activo'
    )
    SELECT
    p_id_usuario, NOW(), 'activo', afcc.id_activo_fijo, af.id_centro_costo, afcc.fecha, v_tope_mensual - afcc.total_horas
    FROM tpro_af_cc afcc
    INNER JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = afcc.id_activo_fijo
    WHERE DATE_TRUNC('month', afcc.fecha) = DATE_TRUNC('month',p_fecha)
    AND afcc.total_horas < v_tope_mensual;

    --Definicion de la respuesta
    v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Prorrateo mensual completado: ' || p_fecha::varchar);
    v_resp = pxp.f_agrega_clave(v_resp,'fecha',p_fecha::varchar);

    --Devuelve la respuesta
    RETURN v_resp;

EXCEPTION

  WHEN OTHERS THEN
    v_resp='';
    v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
    v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
    v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);
    raise exception '%', v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;