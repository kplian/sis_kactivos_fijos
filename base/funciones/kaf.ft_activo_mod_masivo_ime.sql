CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_ime" (
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:        Sistema de Activos Fijos
 FUNCION:         kaf.ft_activo_mod_masivo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_mod_masivo'
 AUTOR:          (rchumacero)
 FECHA:            09-12-2020 20:34:43
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
****************************************************************************/
DECLARE

    v_nro_requerimiento        INTEGER;
    v_parametros               RECORD;
    v_id_requerimiento         INTEGER;
    v_resp                     VARCHAR;
    v_nombre_funcion           TEXT;
    v_mensaje_error            TEXT;
    v_id_activo_mod_masivo     INTEGER;
    v_codigos_af               TEXT;
    v_fun                      VARCHAR;
    v_id_proceso_macro         INTEGER;
    v_codigo_tipo_proceso      VARCHAR;
    v_id_gestion               INTEGER;
    v_num_tramite              VARCHAR;
    v_id_proceso_wf            INTEGER;
    v_id_estado_wf             INTEGER;
    v_codigo_estado            VARCHAR;
    v_acceso_directo           VARCHAR;
    v_clase                    VARCHAR;
    v_parametros_ad            VARCHAR;
    v_tipo_noti                VARCHAR;
    v_titulo                   VARCHAR;
    v_id_tipo_estado           INTEGER;
    v_codigo_estado_siguiente  VARCHAR;
    v_id_estado_actual         INTEGER;
    v_registros_proc           RECORD;
    v_codigo_tipo_pro          VARCHAR;
    v_pedir_obs                VARCHAR;
    v_id_funcionario           INTEGER;
    v_id_usuario_reg           INTEGER;
    v_id_depto                 INTEGER;
    v_id_estado_wf_ant         INTEGER;
    v_obs                      VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_AFM_INS'
     #DESCRIPCION:    Insercion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/
    IF (p_transaccion='SKA_AFM_INS') THEN

        BEGIN

            --Obtención del proceso macro
            v_codigo_tipo_proceso = 'KAF-MASIV';

            SELECT
            pm.id_proceso_macro
            INTO
            v_id_proceso_macro
            FROM wf.tproceso_macro pm
            LEFT JOIN wf.ttipo_proceso tp
            ON tp.id_proceso_macro  = pm.id_proceso_macro
            WHERE tp.codigo = v_codigo_tipo_proceso;

            IF v_id_proceso_macro IS NULL THEN
                RAISE EXCEPTION 'El proceso % de workflow no existe', v_codigo_tipo_proceso;
            END IF;

            --Iniciación del flujo de trabajo
            SELECT
            ges.id_gestion
            INTO
            v_id_gestion
            FROM param.tgestion ges
            WHERE DATE_TRUNC('YEAR', ges.fecha_ini) = DATE_TRUNC('YEAR', v_parametros.fecha);

            SELECT
            ps_num_tramite,
            ps_id_proceso_wf,
            ps_id_estado_wf,
            ps_codigo_estado
            INTO
            v_num_tramite,
            v_id_proceso_wf,
            v_id_estado_wf,
            v_codigo_estado
            FROM wf.f_inicia_tramite(
                p_id_usuario,
                v_parametros._id_usuario_ai,
                v_parametros._nombre_usuario_ai,
                v_id_gestion,
                v_codigo_tipo_proceso,
                NULL,
                NULL,
                'Inicio de Registro de la Modificación Masiva',
                ''
            );

            --Sentencia de la insercion
            INSERT INTO kaf.tactivo_mod_masivo(
            estado_reg,
            id_proceso_wf,
            id_estado_wf,
            fecha,
            motivo,
            estado,
            id_usuario_reg,
            fecha_reg,
            id_usuario_ai,
            usuario_ai,
            id_usuario_mod,
            fecha_mod,
            num_tramite
              ) VALUES (
            'activo',
            v_id_proceso_wf,
            v_id_estado_wf,
            v_parametros.fecha,
            v_parametros.motivo,
            v_codigo_estado,
            p_id_usuario,
            now(),
            v_parametros._id_usuario_ai,
            v_parametros._nombre_usuario_ai,
            null,
            null,
            v_num_tramite
            ) RETURNING id_activo_mod_masivo into v_id_activo_mod_masivo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Actualización Masiva almacenado(a) con exito (id_activo_mod_masivo'||v_id_activo_mod_masivo||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo',v_id_activo_mod_masivo::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AFM_MOD'
     #DESCRIPCION:    Modificacion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/
    ELSIF (p_transaccion='SKA_AFM_MOD') THEN

        BEGIN
            --Sentencia de la modificacion
            UPDATE kaf.tactivo_mod_masivo SET
            id_proceso_wf = v_parametros.id_proceso_wf,
            id_estado_wf = v_parametros.id_estado_wf,
            fecha = v_parametros.fecha,
            motivo = v_parametros.motivo,
            id_usuario_mod = p_id_usuario,
            fecha_mod = now(),
            id_usuario_ai = v_parametros._id_usuario_ai,
            usuario_ai = v_parametros._nombre_usuario_ai
            WHERE id_activo_mod_masivo=v_parametros.id_activo_mod_masivo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Actualización Masiva modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo',v_parametros.id_activo_mod_masivo::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AFM_ELI'
     #DESCRIPCION:    Eliminacion de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/
    ELSIF (p_transaccion='SKA_AFM_ELI') THEN

        BEGIN
            --Sentencia de la eliminacion
            DELETE FROM kaf.tactivo_mod_masivo
            WHERE id_activo_mod_masivo=v_parametros.id_activo_mod_masivo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Actualización Masiva eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo',v_parametros.id_activo_mod_masivo::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AFMDATOS_UPD'
     #DESCRIPCION:  Procedimiento que realiza la modificación de los datos en la tabla de kaf.tactivo_fijo, dejando un backup al inicio de cada registro que se va a modificar
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/
    ELSIF (p_transaccion='SKA_AFMDATOS_UPD') THEN

        BEGIN

            --1 Verificación de códigos
            SELECT pxp.list(amm.codigo)
            INTO v_codigos_af
            FROM kaf.tactivo_mod_masivo_det amm
            WHERE amm.id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
            AND LOWER(TRIM(amm.codigo)) NOT IN (SELECT LOWER(codigo)
                                                FROM kaf.tactivo_fijo);
            IF v_codigos_af IS NOT NULL THEN
                RAISE EXCEPTION 'Existen registros con Códigos de activos fijos inexistentes: %', v_codigos_af;
            END IF;

            --Verifica el estado
            IF NOT EXISTS(SELECT 1
                        FROM kaf.tactivo_mod_masivo
                        WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo
                        AND estado = 'borrador') THEN
                RAISE EXCEPTION 'El estado del registro debe ser Borrador';
            END IF;

            --2 Obtención del backup original antes de los cambios
            INSERT INTO kaf.tactivo_mod_masivo_det_original (
                id_usuario_reg,
                fecha_reg,
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
                id_centro_costo
            )
            SELECT
            p_id_usuario,
            now(),
            'activo',
            amm.id_activo_mod_masivo_det,
            af.id_activo_fijo,
            af.codigo,
            af.nro_serie,
            af.marca,
            af.denominacion,
            af.descripcion,
            af.id_unidad_medida,
            af.observaciones,
            af.ubicacion,
            af.id_ubicacion, --local
            af.id_funcionario,
            af.id_proveedor,
            af.fecha_compra,
            af.documento,
            af.nro_cbte_asociado,
            af.fecha_cbte_asociado,
            af.id_grupo, --grupo_ae
            af.id_grupo_clasif, --clasificador_ae
            af.id_centro_costo
            FROM kaf.tactivo_mod_masivo_det amm
            JOIN kaf.tactivo_fijo af
            ON LOWER(af.codigo) = LOWER(TRIM(amm.codigo))
            WHERE amm.id_activo_mod_masivo = v_parametros.id_activo_mod_masivo;

            --3 Modificación de los datos en la tabla kaf.tactivo_fijo
            v_fun = kaf.f_actualizacion_masiva_activos(p_id_usuario, v_parametros.id_activo_mod_masivo);

            --Actualización del estado
            UPDATE kaf.tactivo_mod_masivo SET
            estado = 'procesado'
            WHERE id_activo_mod_masivo = v_parametros.id_activo_mod_masivo;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Actualización Masiva realizada');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_mod_masivo',v_parametros.id_activo_mod_masivo::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
    #TRANSACCION:   'SKA_SIGMODAF_INS'
    #DESCRIPCION:   Controla el cambio al siguiente estado
    #AUTOR:         RCM
    #FECHA:         15/12/2020
    #ISSUE:
    ***********************************/
    ELSIF(p_transaccion = 'SKA_SIGMODAF_INS') THEN

        BEGIN
            --Obtención de datos
            SELECT
            ew.id_proceso_wf,
            c.id_estado_wf,
            c.estado,
            c.id_activo_mod_masivo
            into
            v_id_proceso_wf,
            v_id_estado_wf,
            v_codigo_estado,
            v_id_activo_mod_masivo
            FROM kaf.tactivo_mod_masivo c
            INNER JOIN wf.testado_wf ew
            ON ew.id_estado_wf = c.id_estado_wf
            WHERE c.id_proceso_wf = v_parametros.id_proceso_wf_act;

            --Recupera datos del estado
            SELECT
            ew.id_tipo_estado,
            te.codigo
            into
            v_id_tipo_estado,
            v_codigo_estado
            FROM wf.testado_wf ew
            INNER JOIN wf.ttipo_estado te
            ON te.id_tipo_estado = ew.id_tipo_estado
            WHERE ew.id_estado_wf = v_parametros.id_estado_wf_act;

            --Obtener datos tipo estado
            SELECT
            te.codigo
            INTO
            v_codigo_estado_siguiente
            FROM wf.ttipo_estado te
            WHERE te.id_tipo_estado = v_parametros.id_tipo_estado;

            --Acciones por estado siguiente que podrian realizarse
            IF v_codigo_estado_siguiente IN ('procesado') THEN

                --1 Verificación de códigos
                SELECT pxp.list(amm.codigo)
                INTO v_codigos_af
                FROM kaf.tactivo_mod_masivo_det amm
                WHERE amm.id_activo_mod_masivo = v_id_activo_mod_masivo
                AND LOWER(TRIM(amm.codigo)) NOT IN (SELECT LOWER(codigo)
                                                    FROM kaf.tactivo_fijo);
                IF v_codigos_af IS NOT NULL THEN
                    RAISE EXCEPTION 'Existen registros con Códigos de activos fijos inexistentes: %', v_codigos_af;
                END IF;

                --Verifica el estado
                IF NOT EXISTS(SELECT 1
                            FROM kaf.tactivo_mod_masivo
                            WHERE id_activo_mod_masivo = v_id_activo_mod_masivo
                            AND estado = 'borrador') THEN
                    RAISE EXCEPTION 'El estado del registro debe ser Borrador';
                END IF;

                --2 Obtención del backup original antes de los cambios
                INSERT INTO kaf.tactivo_mod_masivo_det_original (
                    id_usuario_reg,
                    fecha_reg,
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
                    id_centro_costo
                )
                SELECT
                p_id_usuario,
                now(),
                'activo',
                amm.id_activo_mod_masivo_det,
                af.id_activo_fijo,
                af.codigo,
                af.nro_serie,
                af.marca,
                af.denominacion,
                af.descripcion,
                af.id_unidad_medida,
                af.observaciones,
                af.ubicacion,
                af.id_ubicacion, --local
                af.id_funcionario,
                af.id_proveedor,
                af.fecha_compra,
                af.documento,
                af.nro_cbte_asociado,
                af.fecha_cbte_asociado,
                af.id_grupo, --grupo_ae
                af.id_grupo_clasif, --clasificador_ae
                af.id_centro_costo
                FROM kaf.tactivo_mod_masivo_det amm
                JOIN kaf.tactivo_fijo af
                ON LOWER(af.codigo) = LOWER(TRIM(amm.codigo))
                WHERE amm.id_activo_mod_masivo = v_id_activo_mod_masivo;

                --3 Modificación de los datos en la tabla kaf.tactivo_fijo
                v_fun = kaf.f_actualizacion_masiva_activos(p_id_usuario, v_id_activo_mod_masivo);

            END IF;

            ---------------------------------------
            -- REGISTRA EL SIGUIENTE ESTADO DEL WF
            ---------------------------------------
            --Configurar acceso directo para la alarma
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'VoBo';

            IF v_codigo_estado_siguiente NOT IN ('borrador','finalizado','anulado') THEN

                v_acceso_directo = '../../../sis_kactivos_fijos/vista/activo_mod_masivo/ActivoModMasivo.php';
                v_clase = 'ActivoModMasivo';
                v_parametros_ad = '{filtro_directo:{campo:"afm.id_proceso_wf", valor:"' || v_id_proceso_wf:: varchar||'"}}';
                v_tipo_noti = 'notificacion';
                v_titulo = 'VoBo';

            END IF;

            v_id_estado_actual = wf.f_registra_estado_wf
                                (
                                    v_parametros.id_tipo_estado,
                                    v_parametros.id_funcionario_wf,
                                    v_parametros.id_estado_wf_act,
                                    v_id_proceso_wf,
                                    p_id_usuario,
                                    v_parametros._id_usuario_ai,
                                    v_parametros._nombre_usuario_ai,
                                    v_id_depto,
                                    COALESCE(v_obs, ''),
                                    v_acceso_directo,
                                    v_clase,
                                    v_parametros_ad,
                                    v_tipo_noti,
                                    v_titulo
                                );


            --Actualización del estado
            UPDATE kaf.tactivo_mod_masivo SET
            id_estado_wf = v_id_estado_actual,
            estado = v_codigo_estado_siguiente
            WHERE id_activo_mod_masivo = v_id_activo_mod_masivo;
            --------------------------------------
            -- Registra los procesos disparados
            --------------------------------------
            FOR v_registros_proc IN ( SELECT * FROM json_populate_recordset(NULL::wf.proceso_disparado_wf, v_parametros.json_procesos::json)) loop

                --Obtencion del codigo tipo proceso
                SELECT
                tp.codigo
                INTO
                v_codigo_tipo_pro
                FROM wf.ttipo_proceso tp
                WHERE tp.id_tipo_proceso = v_registros_proc.id_tipo_proceso_pro;

                --Disparar creacion de procesos seleccionados
                SELECT
                ps_id_proceso_wf,
                ps_id_estado_wf,
                ps_codigo_estado
                INTO
                v_id_proceso_wf,
                v_id_estado_wf,
                v_codigo_estado
                FROM wf.f_registra_proceso_disparado_wf(
                    p_id_usuario,
                    v_parametros._id_usuario_ai,
                    v_parametros._nombre_usuario_ai,
                    v_id_estado_actual,
                    v_registros_proc.id_funcionario_wf_pro,
                    v_registros_proc.id_depto_wf_pro,
                    v_registros_proc.obs_pro,
                    v_codigo_tipo_pro,
                    v_codigo_tipo_pro
                );

            END LOOP;

            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Cambio de estado realizado');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_activo_mod_masivo', v_id_activo_mod_masivo::varchar);

            -- Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
    #TRANSACCION:   'SKA_ANTMODAF_INS'
    #DESCRIPCION:   Controla el cambio al siguiente estado
    #AUTOR:         RCM
    #FECHA:         16/12/2020
    #ISSUE:
    ***********************************/
    ELSIF(p_transaccion = 'SKA_ANTMODAF_INS') THEN

        BEGIN

            --Obtiene los datos del Estado Actual
            SELECT
                ew.id_tipo_estado,
                te.pedir_obs,
                ew.id_estado_wf
            INTO
                v_id_tipo_estado,
                v_pedir_obs,
                v_id_estado_wf
            FROM wf.testado_wf ew
            INNER JOIN wf.ttipo_estado te
            ON te.id_tipo_estado = ew.id_tipo_estado
            WHERE ew.id_estado_wf = v_parametros.id_estado_wf;

            --------------------------------------------------
            --Retrocede al estado inmediatamente anterior
            -------------------------------------------------
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
            FROM wf.f_obtener_estado_ant_log_wf(v_parametros.id_estado_wf);

            --Obtención del proceso wf
            SELECT
            ew.id_proceso_wf
            INTO
            v_id_proceso_wf
            FROM wf.testado_wf ew
            WHERE ew.id_estado_wf = v_id_estado_wf_ant;

            --Configurar acceso directo para la alarma
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'Notificacion';

            if v_codigo_estado_siguiente not in ('finalizado') then
                v_acceso_directo = '../../../sis_kactivos_fijos/vista/activo_mod_masivo/ActivoModMasivo.php';
                v_clase = 'ActivoModMasivo';
                v_parametros_ad = '{filtro_directo: {campo: "mov.id_proceso_wf", valor: "'||v_parametros.id_proceso_wf_act::varchar||'"}}';
                v_tipo_noti = 'notificacion';
                v_titulo = 'Notificacion';
            end if;

            --Registra nuevo estado
            v_id_estado_actual = wf.f_registra_estado_wf(
                v_id_tipo_estado,
                v_id_funcionario,
                v_parametros.id_estado_wf,
                v_id_proceso_wf,
                p_id_usuario,
                v_parametros._id_usuario_ai,
                v_parametros._nombre_usuario_ai,
                v_id_depto,
                '[RETROCESO] '|| v_parametros.obs,
                v_acceso_directo,
                v_clase,
                v_parametros_ad,
                v_tipo_noti,
                v_titulo
            );

            --Actualiza el estado actual
            SELECT
            codigo
            INTO v_codigo_estado_siguiente
            FROM wf.ttipo_estado tes
            INNER JOIN wf.testado_wf ew
            ON ew.id_tipo_estado = tes.id_tipo_estado
            WHERE ew.id_estado_wf = v_id_estado_actual;

            UPDATE kaf.tactivo_mod_masivo SET
            id_estado_wf = v_id_estado_actual,
            estado = v_codigo_estado_siguiente
            WHERE id_proceso_wf = v_parametros.id_proceso_wf;

            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se retrocedió el estado del registro');
            v_resp = pxp.f_agrega_clave(v_resp,'id_proceso_wf', v_parametros.id_proceso_wf::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    ELSE

        RAISE EXCEPTION 'Transaccion inexistente: %', p_transaccion;

    END IF;

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
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;