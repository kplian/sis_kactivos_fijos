CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_det_original_ime" (
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_mod_masivo_det_original_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_mod_masivo_det_original'
 AUTOR:         (rchumacero)
 FECHA:         10-12-2020 03:43:46
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

    v_nro_requerimiento        INTEGER;
    v_parametros               RECORD;
    v_id_requerimiento         INTEGER;
    v_resp                     VARCHAR;
    v_nombre_funcion           TEXT;
    v_mensaje_error            TEXT;
    v_id_activo_mod_masivo_det_original    INTEGER;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_det_original_ime';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_MADOR_INS'
     #DESCRIPCION:    Insercion de registros
     #AUTOR:        rchumacero
     #FECHA:        10-12-2020 03:43:46
    ***********************************/

    IF (p_transaccion='SKA_MADOR_INS') THEN

        BEGIN
            --Sentencia de la insercion
            INSERT INTO kaf.tactivo_mod_masivo_det_original(
            estado_reg,
            id_activo_mod_masivo_det,
            id_activo_fijo,
            codigo,
            nro_serie,
            marca,
            denominacion,
            descripcion,
            id_unidad_medida,
            observaciones,
            ubicacion,
            id_ubicacion,
            id_funcionario,
            id_proveedor,
            fecha_compra,
            documento,
            cbte_asociado,
            fecha_cbte_asociado,
            id_grupo,
            id_grupo_clasif,
            id_centro_costo,
            id_usuario_reg,
            fecha_reg,
            id_usuario_ai,
            usuario_ai,
            id_usuario_mod,
            fecha_mod
              ) VALUES (
            'activo',
            v_parametros.id_activo_mod_masivo_det,
            v_parametros.id_activo_fijo,
            v_parametros.codigo,
            v_parametros.nro_serie,
            v_parametros.marca,
            v_parametros.denominacion,
            v_parametros.descripcion,
            v_parametros.id_unidad_medida,
            v_parametros.observaciones,
            v_parametros.ubicacion,
            v_parametros.id_ubicacion,
            v_parametros.id_funcionario,
            v_parametros.id_proveedor,
            v_parametros.fecha_compra,
            v_parametros.documento,
            v_parametros.cbte_asociado,
            v_parametros.fecha_cbte_asociado,
            v_parametros.id_grupo,
            v_parametros.id_grupo_clasif,
            v_parametros.id_centro_costo,
            p_id_usuario,
            now(),
            v_parametros._id_usuario_ai,
            v_parametros._nombre_usuario_ai,
            null,
            null
            ) RETURNING id_activo_mod_masivo_det_original into v_id_activo_mod_masivo_det_original;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Original almacenado(a) con exito (id_activo_mod_masivo_det_original'||v_id_activo_mod_masivo_det_original||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det_original',v_id_activo_mod_masivo_det_original::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_MADOR_MOD'
     #DESCRIPCION:    Modificacion de registros
     #AUTOR:        rchumacero
     #FECHA:        10-12-2020 03:43:46
    ***********************************/
    ELSIF (p_transaccion='SKA_MADOR_MOD') THEN

        BEGIN
            --Sentencia de la modificacion
            UPDATE kaf.tactivo_mod_masivo_det_original SET
            id_activo_mod_masivo_det = v_parametros.id_activo_mod_masivo_det,
            id_activo_fijo = v_parametros.id_activo_fijo,
            codigo = v_parametros.codigo,
            nro_serie = v_parametros.nro_serie,
            marca = v_parametros.marca,
            denominacion = v_parametros.denominacion,
            descripcion = v_parametros.descripcion,
            id_unidad_medida = v_parametros.id_unidad_medida,
            observaciones = v_parametros.observaciones,
            ubicacion = v_parametros.ubicacion,
            id_ubicacion = v_parametros.id_ubicacion,
            id_funcionario = v_parametros.id_funcionario,
            id_proveedor = v_parametros.id_proveedor,
            fecha_compra = v_parametros.fecha_compra,
            documento = v_parametros.documento,
            cbte_asociado = v_parametros.cbte_asociado,
            fecha_cbte_asociado = v_parametros.fecha_cbte_asociado,
            id_grupo = v_parametros.id_grupo,
            id_grupo_clasif = v_parametros.id_grupo_clasif,
            id_centro_costo = v_parametros.id_centro_costo,
            id_usuario_mod = p_id_usuario,
            fecha_mod = now(),
            id_usuario_ai = v_parametros._id_usuario_ai,
            usuario_ai = v_parametros._nombre_usuario_ai
            WHERE id_activo_mod_masivo_det_original=v_parametros.id_activo_mod_masivo_det_original;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Original modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det_original',v_parametros.id_activo_mod_masivo_det_original::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_MADOR_ELI'
     #DESCRIPCION:    Eliminacion de registros
     #AUTOR:        rchumacero
     #FECHA:        10-12-2020 03:43:46
    ***********************************/

    ELSIF (p_transaccion='SKA_MADOR_ELI') THEN

        BEGIN
            --Sentencia de la eliminacion
            DELETE FROM kaf.tactivo_mod_masivo_det_original
            WHERE id_activo_mod_masivo_det_original=v_parametros.id_activo_mod_masivo_det_original;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Original eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det_original',v_parametros.id_activo_mod_masivo_det_original::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    ELSE

        RAISE EXCEPTION 'Transaccion inexistente: %',p_transaccion;

    END IF;

EXCEPTION

    WHEN OTHERS THEN
        v_resp='';
        v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
        raise exception '%',v_resp;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_det_original_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
