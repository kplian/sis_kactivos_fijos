CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_det_ime" (
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_mod_masivo_det_ime
 DESCRIPCION:   Importación/actualización de datos en forma masiva
 AUTOR:         (rchumacero)
 FECHA:         09-12-2020 20:36:34
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
    v_id_activo_mod_masivo_det  INTEGER;
    v_nro_serie                 VARCHAR;
    v_marca                     VARCHAR;
    v_denominacion              VARCHAR;
    v_descripcion               VARCHAR;
    v_unidad_medida             VARCHAR;
    v_observaciones             VARCHAR;
    v_ubicacion                 VARCHAR;
    v_local                     VARCHAR;
    v_responsable               VARCHAR;
    v_proveedor                 VARCHAR;
    v_fecha_compra              DATE;
    v_documento                 VARCHAR;
    v_cbte_asociado             VARCHAR;
    v_fecha_cbte_asociado       DATE;
    v_grupo_ae                  VARCHAR;
    v_clasificador_ae           VARCHAR;
    v_centro_costo              VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_det_ime';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_AMD_INS'
     #DESCRIPCION:    Insercion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:34
    ***********************************/

    IF (p_transaccion='SKA_AMD_INS') THEN

        BEGIN

            IF NOT EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND estado = 'borrador') THEN
                RAISE EXCEPTION 'El estado de la cabecera debe estar en Borrador para insertar el registro';
            END IF;

            --Verifica que exista el código
            IF NOT pxp.f_existe_parametro(p_tabla, 'codigo') THEN
                RAISE EXCEPTION 'Error al insertar registro. El Código no puede estar vacío';
            END IF;

            --Verifica que el código no se repita
            IF EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo_det
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND codigo = v_parametros.codigo) THEN
                RAISE EXCEPTION 'El activo fijo % está duplicado', v_parametros.codigo;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'nro_serie') THEN
                v_nro_serie = v_parametros.nro_serie;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'marca') THEN
                v_marca = v_parametros.marca;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'denominacion') THEN
                v_denominacion = v_parametros.denominacion;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'descripcion') THEN
                v_descripcion = v_parametros.descripcion;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'unidad_medida') THEN
                v_unidad_medida = v_parametros.unidad_medida;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'observaciones') THEN
                v_observaciones = v_parametros.observaciones;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'ubicacion') THEN
                v_ubicacion = v_parametros.ubicacion;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'local') THEN
                v_local = v_parametros.local;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'responsable') THEN
                v_responsable = v_parametros.responsable;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'proveedor') THEN
                v_proveedor = v_parametros.proveedor;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'fecha_compra') THEN
                v_fecha_compra = v_parametros.fecha_compra;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'documento') THEN
                v_documento = v_parametros.documento;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'cbte_asociado') THEN
                v_cbte_asociado = v_parametros.cbte_asociado;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'fecha_cbte_asociado') THEN
                v_fecha_cbte_asociado = v_parametros.fecha_cbte_asociado;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'grupo_ae') THEN
                v_grupo_ae = v_parametros.grupo_ae;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'clasificador_ae') THEN
                v_clasificador_ae = v_parametros.clasificador_ae;
            END IF;
            IF pxp.f_existe_parametro(p_tabla, 'centro_costo') THEN
                v_centro_costo = v_parametros.centro_costo;
            END IF;

            --Sentencia de la insercion  24
            INSERT INTO kaf.tactivo_mod_masivo_det(
            estado_reg,
            id_activo_mod_masivo,
            codigo,
            nro_serie,
            marca,
            denominacion,
            descripcion,
            unidad_medida,
            observaciones,
            ubicacion,
            local,
            responsable,
            proveedor,
            fecha_compra,
            documento,
            cbte_asociado,
            fecha_cbte_asociado,
            grupo_ae,
            clasificador_ae,
            centro_costo,
            id_usuario_reg,
            fecha_reg,
            id_usuario_ai,
            usuario_ai,
            id_usuario_mod,
            fecha_mod
              ) VALUES (
            'activo',
            v_parametros.id_activo_mod_masivo,
            v_parametros.codigo,
            v_nro_serie,
            v_marca,
            v_denominacion,
            v_descripcion,
            v_unidad_medida,
            v_observaciones,
            v_ubicacion,
            v_local,
            v_responsable,
            v_proveedor,
            v_fecha_compra,
            v_documento,
            v_cbte_asociado,
            v_fecha_cbte_asociado,
            v_grupo_ae,
            v_clasificador_ae,
            v_centro_costo,
            p_id_usuario,
            now(),
            v_parametros._id_usuario_ai,
            v_parametros._nombre_usuario_ai,
            null,
            null
            ) RETURNING id_activo_mod_masivo_det into v_id_activo_mod_masivo_det;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detale Actualización almacenado(a) con exito (id_activo_mod_masivo_det'||v_id_activo_mod_masivo_det||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det',v_id_activo_mod_masivo_det::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AMD_MOD'
     #DESCRIPCION:    Modificacion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:34
    ***********************************/

    ELSIF (p_transaccion='SKA_AMD_MOD') THEN

        BEGIN

            IF NOT EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND estado = 'borrador') THEN
                RAISE EXCEPTION 'El estado de la cabecera debe estar en Borrador para poder modificar el registro';
            END IF;

            --Sentencia de la modificacion
            UPDATE kaf.tactivo_mod_masivo_det SET
            id_activo_mod_masivo = v_parametros.id_activo_mod_masivo,
            codigo = v_parametros.codigo,
            nro_serie = v_parametros.nro_serie,
            marca = v_parametros.marca,
            denominacion = v_parametros.denominacion,
            descripcion = v_parametros.descripcion,
            unidad_medida = v_parametros.unidad_medida,
            observaciones = v_parametros.observaciones,
            ubicacion = v_parametros.ubicacion,
            local = v_parametros.local,
            responsable = v_parametros.responsable,
            proveedor = v_parametros.proveedor,
            fecha_compra = v_parametros.fecha_compra,
            documento = v_parametros.documento,
            cbte_asociado = v_parametros.cbte_asociado,
            fecha_cbte_asociado = v_parametros.fecha_cbte_asociado,
            grupo_ae = v_parametros.grupo_ae,
            clasificador_ae = v_parametros.clasificador_ae,
            centro_costo = v_parametros.centro_costo,
            id_usuario_mod = p_id_usuario,
            fecha_mod = now(),
            id_usuario_ai = v_parametros._id_usuario_ai,
            usuario_ai = v_parametros._nombre_usuario_ai
            WHERE id_activo_mod_masivo_det=v_parametros.id_activo_mod_masivo_det;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Actualización modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det',v_parametros.id_activo_mod_masivo_det::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AMD_ELI'
     #DESCRIPCION:    Eliminacion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:35
    ***********************************/
    ELSIF (p_transaccion='SKA_AMD_ELI') THEN

        BEGIN

            IF NOT EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND estado = 'borrador') THEN
                RAISE EXCEPTION 'El estado de la cabecera debe estar en Borrador para poder eliminar el registro';
            END IF;

            --Sentencia de la eliminacion
            DELETE FROM kaf.tactivo_mod_masivo_det
            WHERE id_activo_mod_masivo_det=v_parametros.id_activo_mod_masivo_det;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detale Actualización eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo_det',v_parametros.id_activo_mod_masivo_det::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AMDALL_ELI'
     #DESCRIPCION:  Eliminacion de todos los registros de una cabecera
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:35
    ***********************************/
    ELSIF (p_transaccion='SKA_AMDALL_ELI') THEN

        BEGIN
            --Verifica que esté en estado borrador
            IF NOT EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND estado = 'borrador') THEN
                RAISE EXCEPTION 'No puede eliminarse los registros porque la cabecera no está en estado Borrador';
            END IF;

            --Sentencia de la eliminacion
            DELETE
            FROM kaf.tactivo_mod_masivo_det_original ammo
            USING kaf.tactivo_mod_masivo_det amm
            WHERE amm.id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
            AND ammo.id_activo_mod_masivo_det = amm.id_activo_mod_masivo_det;

            DELETE FROM kaf.tactivo_mod_masivo_det
            WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Eliminación masiva realizada');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo',v_parametros.id_activo_mod_masivo::varchar);

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
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_det_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
