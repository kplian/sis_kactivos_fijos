CREATE OR REPLACE FUNCTION kaf.f_actualizacion_masiva_afv (
    p_record record)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_actualizacion_masiva_afv
 DESCRIPCION:   Verifica si en la plantilla excel se modificarán datos de la cabecera de AFV (kaf.tactivo_fijo_valores) y genera el SQL del update
 AUTOR:         (rchumacero)
 FECHA:         01-02-2021
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2778  KAF       ETR           01/02/2021  RCM         Creación del archivo
****************************************************************************/
DECLARE

    v_nro_requerimiento        INTEGER;
    v_resp                     VARCHAR;
    v_nombre_funcion           TEXT;
    v_mensaje_error            TEXT;
    v_sql                      VARCHAR;
    v_dinamico                 VARCHAR;
    v_update                   TEXT;

BEGIN

    v_nombre_funcion = 'kaf.f_actualizacion_masiva_afv';
    v_sql = '';
    v_update = '';
    
    ----------------------
    --BOLIVIANOS
    ----------------------
    v_dinamico = '';

    --valor_compra,
    IF p_record.bs_valor_compra IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig_100 = ' || p_record.bs_valor_compra || ', ';
    END IF;

    --valor_inicial,
    IF p_record.bs_valor_inicial IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig = ' || p_record.bs_valor_inicial || ', ';
    END IF;

    --fecha_ini_dep,
    IF p_record.bs_fecha_ini_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ini_dep = ''' || p_record.bs_fecha_ini_dep || ''', ';
    END IF;

    --vutil_orig,
    IF p_record.bs_vutil_orig IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util_orig = ' || p_record.bs_vutil_orig || ', ';
    END IF;

    --vutil,
    IF p_record.bs_vutil IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util = ' || p_record.bs_vutil || ', ';
    END IF;

    --fult_dep,
    IF p_record.bs_fult_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ult_dep = ''' || p_record.bs_fult_dep || ''', ';
    END IF;

    --fecha_fin,
    IF p_record.bs_fecha_fin IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_fin = ''' || p_record.bs_fecha_fin || ''', ';
    END IF;

    --val_resc,
    IF p_record.bs_val_resc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_rescate = ' || p_record.bs_val_resc || ', ';
    END IF;

    --vact_ini,
    IF p_record.bs_vact_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_actualiz_inicial = ' || p_record.bs_vact_ini || ', ';
    END IF;

    --dacum_ini,
    IF p_record.bs_dacum_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_acum_inicial = ' || p_record.bs_dacum_ini || ', ';
    END IF;

    --dper_ini,
    IF p_record.bs_dper_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_per_inicial = ' || p_record.bs_dper_ini || ', ';
    END IF;

    --inc,
    IF p_record.bs_inc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif = ' || p_record.bs_inc || ', ';
    END IF;

    --inc_sact,
    IF p_record.bs_inc_sact IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif_sin_act = ' || p_record.bs_inc_sact || ', ';
    END IF;

    --fechaufv_ini,
    IF p_record.bs_fechaufv_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_tc_ini_dep = ''' || p_record.bs_fechaufv_ini || ''', ';
    END IF;


    --Terminar de formar la cadena de actualización
    v_dinamico = TRIM(v_dinamico);

    IF REGEXP_REPLACE(v_dinamico, '^.*(.)$', '\1') = ',' THEN
        v_dinamico = SUBSTR(v_dinamico, 1, length(v_dinamico) - 1);
    END IF;

    IF v_dinamico <> '' THEN
        v_update = v_update || ' UPDATE kaf.tactivo_fijo_valores SET ' || v_dinamico || ' WHERE id_activo_fijo = ' || p_record.id_activo_fijo || ' AND fecha_fin IS NULL AND id_moneda = ' || param.f_get_moneda_base()::VARCHAR || ';';
    END IF;


    ----------------------
    --DOLARES
    ----------------------
    v_dinamico = '';

    --valor_compra,
    IF p_record.usd_valor_compra IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig_100 = ' || p_record.usd_valor_compra || ', ';
    END IF;

    --valor_inicial,
    IF p_record.usd_valor_inicial IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig = ' || p_record.usd_valor_inicial || ', ';
    END IF;

    --fecha_ini_dep,
    IF p_record.usd_fecha_ini_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ini_dep = ''' || p_record.usd_fecha_ini_dep || ''', ';
    END IF;

    --vutil_orig,
    IF p_record.usd_vutil_orig IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util_orig = ' || p_record.usd_vutil_orig || ', ';
    END IF;

    --vutil,
    IF p_record.usd_vutil IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util = ' || p_record.usd_vutil || ', ';
    END IF;

    --fult_dep,
    IF p_record.usd_fult_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ult_dep = ''' || p_record.usd_fult_dep || ''', ';
    END IF;

    --fecha_fin,
    IF p_record.usd_fecha_fin IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_fin = ''' || p_record.usd_fecha_fin || ''', ';
    END IF;

    --val_resc,
    IF p_record.usd_val_resc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_rescate = ' || p_record.usd_val_resc || ', ';
    END IF;

    --vact_ini,
    IF p_record.usd_vact_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_actualiz_inicial = ' || p_record.usd_vact_ini || ', ';
    END IF;

    --dacum_ini,
    IF p_record.usd_dacum_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_acum_inicial = ' || p_record.usd_dacum_ini || ', ';
    END IF;

    --dper_ini,
    IF p_record.usd_dper_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_per_inicial = ' || p_record.usd_dper_ini || ', ';
    END IF;

    --inc,
    IF p_record.usd_inc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif = ' || p_record.usd_inc || ', ';
    END IF;

    --inc_sact,
    IF p_record.usd_inc_sact IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif_sin_act = ' || p_record.usd_inc_sact || ', ';
    END IF;

    --fechaufv_ini,
    IF p_record.usd_fecha_ufv_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_tc_ini_dep = ''' || p_record.usd_fecha_ufv_ini || ''', ';
    END IF;


    --Terminar de formar la cadena de actualización
    v_dinamico = TRIM(v_dinamico);

    IF REGEXP_REPLACE(v_dinamico, '^.*(.)$', '\1') = ',' THEN
        v_dinamico = SUBSTR(v_dinamico, 1, length(v_dinamico) - 1);
    END IF;

    IF v_dinamico <> '' THEN
        v_update = v_update || ' UPDATE kaf.tactivo_fijo_valores SET ' || v_dinamico || ' WHERE id_activo_fijo = ' || p_record.id_activo_fijo || ' AND fecha_fin IS NULL AND id_moneda = ' || param.f_get_moneda_triangulacion()::VARCHAR || ';';
    END IF;





    ----------------------
    --UFV
    ----------------------
    v_dinamico = '';

    --valor_compra,
    IF p_record.ufv_valor_compra IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig_100 = ' || p_record.ufv_valor_compra || ', ';
    END IF;

    --valor_inicial,
    IF p_record.ufv_valor_inicial IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_orig = ' || p_record.ufv_valor_inicial || ', ';
    END IF;

    --fecha_ini_dep,
    IF p_record.ufv_fecha_ini_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ini_dep = ''' || p_record.ufv_fecha_ini_dep || ''', ';
    END IF;

    --vutil_orig,
    IF p_record.ufv_vutil_orig IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util_orig = ' || p_record.ufv_vutil_orig || ', ';
    END IF;

    --vutil,
    IF p_record.ufv_vutil IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'vida_util = ' || p_record.ufv_vutil || ', ';
    END IF;

    --fult_dep,
    IF p_record.ufv_fult_dep IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_ult_dep = ''' || p_record.ufv_fult_dep || ''', ';
    END IF;

    --fecha_fin,
    IF p_record.ufv_fecha_fin IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_fin = ''' || p_record.ufv_fecha_fin || ''', ';
    END IF;

    --val_resc,
    IF p_record.ufv_val_resc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_rescate = ' || p_record.ufv_val_resc || ', ';
    END IF;

    --vact_ini,
    IF p_record.ufv_vact_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'monto_vigente_actualiz_inicial = ' || p_record.ufv_vact_ini || ', ';
    END IF;

    --dacum_ini,
    IF p_record.ufv_dacum_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_acum_inicial = ' || p_record.ufv_dacum_ini || ', ';
    END IF;

    --dper_ini,
    IF p_record.ufv_dper_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'depreciacion_per_inicial = ' || p_record.ufv_dper_ini || ', ';
    END IF;

    --inc,
    IF p_record.ufv_inc IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif = ' || p_record.ufv_inc || ', ';
    END IF;

    --inc_sact,
    IF p_record.ufv_inc_sact IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'importe_modif_sin_act = ' || p_record.ufv_inc_sact || ', ';
    END IF;

    --fechaufv_ini,
    IF p_record.ufv_fecha_ufv_ini IS NULL THEN
        --Nada que hacer
    ELSE
        v_dinamico = v_dinamico || 'fecha_tc_ini_dep = ''' || p_record.ufv_fecha_ufv_ini || ''', ';
    END IF;


    --Terminar de formar la cadena de actualización
    v_dinamico = TRIM(v_dinamico);

    IF REGEXP_REPLACE(v_dinamico, '^.*(.)$', '\1') = ',' THEN
        v_dinamico = SUBSTR(v_dinamico, 1, length(v_dinamico) - 1);
    END IF;

    IF v_dinamico <> '' THEN
        v_update = v_update || ' UPDATE kaf.tactivo_fijo_valores SET ' || v_dinamico || ' WHERE id_activo_fijo = ' || p_record.id_activo_fijo || ' AND fecha_fin IS NULL AND id_moneda = ' || param.f_get_moneda_actualizacion()::VARCHAR || ';';
    END IF;


    --Devuelve la respuesta
    RETURN v_update;


EXCEPTION

    WHEN OTHERS THEN

        v_resp = '';
        v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);
        
        RAISE EXCEPTION '%', v_resp;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."f_actualizacion_masiva_afv"(record) OWNER TO postgres;