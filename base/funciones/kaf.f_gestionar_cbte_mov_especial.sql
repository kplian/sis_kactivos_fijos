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
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2         KAF       ETR           12/06/2019  RCM         Creación del archivo
 #ETR-3334  KAF       ETR           26/03/2021  RCM         Creación de movimientos de Alta y Ajustes según corresponda
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
    --Inicio #ETR-3334
    v_id_cat_movimiento         INTEGER;
    v_fecha_mov                   DATE;
    v_id_depto                  INTEGER; 
    v_num_tramite               VARCHAR;
    v_rec_mov                   RECORD;
    v_id_movimiento             INTEGER;
    v_id_tipo_estado            INTEGER;
    v_id_estado_wf_act          INTEGER;
    v_id_proceso_wf_act         INTEGER;
    v_codigo_estado_sig         VARCHAR;
    v_acceso_directo            VARCHAR;
    v_clase                     VARCHAR;
    v_parametros_ad             VARCHAR;
    v_tipo_noti                 VARCHAR;
    v_titulo                    VARCHAR;
    v_glosa                     VARCHAR;
    --Fin #ETR-3334

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

    ---------------------
    --Inicio #ETR-3334: creación de Movimientos de Alta y Ajuste
    ---------------------
    --Alta
    IF EXISTS(SELECT 1
            FROM kaf.tmovimiento_af maf
            JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_nuevo'
            WHERE maf.id_movimiento = v_registros.id_movimiento) THEN

        --Obtención del ID del movimiento Alta
        SELECT cat.id_catalogo
        INTO v_id_cat_movimiento
        FROM param.tcatalogo cat
        INNER JOIN param.tcatalogo_tipo ctip
        ON ctip.id_catalogo_tipo = cat.id_catalogo_tipo
        WHERE ctip.tabla = 'tmovimiento__id_cat_movimiento'
        AND cat.codigo = 'alta';

        IF v_id_cat_movimiento IS NULL THEN
            raise exception 'No se encuentra registrado el Proceso de Ajuste. Comuníquese con el administrador del sistema.';
        END IF;

        --Obtencion de datos del movimiento original
        SELECT
        fecha_mov, id_depto, num_tramite, glosa
        INTO
        v_fecha_mov, v_id_depto, v_num_tramite, v_glosa
        FROM kaf.tmovimiento
        WHERE id_movimiento = v_registros.id_movimiento;

        --Definción de parámetros
        SELECT
        'N/D' AS direccion,
        NULL AS fecha_hasta,
        v_id_cat_movimiento AS id_cat_movimiento,
        v_fecha_mov AS fecha_mov,
        v_id_depto AS id_depto,
        v_num_tramite || ' ' || v_glosa AS glosa, --#ETR-3334
        NULL AS id_funcionario,
        NULL AS id_oficina,
        NULL AS _id_usuario_ai,
        p_id_usuario AS id_usuario,
        NULL AS _nombre_usuario_ai,
        NULL AS id_persona,
        NULL AS codigo,
        NULL AS id_deposito,
        NULL AS id_depto_dest,
        NULL AS id_deposito_dest,
        NULL AS id_funcionario_dest,
        NULL AS id_movimiento_motivo,
        'si' AS mov_rapido --#58
        INTO v_rec_mov;

        --Creación del movimiento de ajuste
        v_id_movimiento = kaf.f_insercion_movimiento(p_id_usuario, hstore(v_rec_mov));

        --Inclusion del detalle del Ajuste
        INSERT INTO kaf.tmovimiento_af(
            id_movimiento,
            id_activo_fijo
        )
        SELECT
        v_id_movimiento,
        mafe.id_activo_fijo
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_nuevo'
        WHERE mov.id_movimiento = v_registros.id_movimiento;

        --Fiinaliza del Alta
        --Obtención del estado finalizado y datos principales para el cambio de estado
        SELECT
        te.id_tipo_estado,
        ew.id_estado_wf,
        ew.id_proceso_wf,
        mov.id_depto,
        te.codigo
        INTO
        v_id_tipo_estado,
        v_id_estado_wf_act,
        v_id_proceso_wf_act,
        v_id_depto,
        v_codigo_estado_sig
        FROM kaf.tmovimiento mov
        INNER JOIN wf.testado_wf ew
        ON ew.id_estado_wf = mov.id_estado_wf
        INNER JOIN wf.tproceso_wf pw
        ON pw.id_proceso_wf = ew.id_proceso_wf
        INNER JOIN wf.ttipo_estado te
        ON te.id_tipo_proceso = pw.id_tipo_proceso
        WHERE mov.id_movimiento = v_id_movimiento
        AND te.codigo = 'finalizado';

        --Definición de datos para la notificación
        v_acceso_directo = '../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php';
        v_clase = 'Movimiento';
        v_parametros_ad = '{filtro_directo: {campo: "mov.id_proceso_wf", valor: "' || v_id_proceso_wf_act::VARCHAR || '"}}';
        v_tipo_noti = 'notificacion';
        v_titulo  = 'Finalización';

        --Cambio de estado a Finalizado del alta
        v_id_estado_actual = wf.f_registra_estado_wf
                            (
                                v_id_tipo_estado,
                                NULL,
                                v_id_estado_wf_act,
                                v_id_proceso_wf_act,
                                p_id_usuario,
                                NULL,
                                NULL,
                                v_id_depto,
                                'Obs: Finalización automática del movimiento',
                                v_acceso_directo,
                                v_clase,
                                v_parametros_ad,
                                v_tipo_noti,
                                v_titulo
                            );

        UPDATE kaf.tmovimiento SET
        id_estado_wf = v_id_estado_actual,
        estado = v_codigo_estado_sig
        WHERE id_movimiento = v_id_movimiento;

        --------------------------------------
        --Codifica los activos fijos y afvs
        UPDATE kaf.tactivo_fijo SET
        codigo = kaf.f_genera_codigo(movaf.id_activo_fijo),
        estado = 'alta'
        FROM kaf.tmovimiento_af movaf
        WHERE kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
        AND COALESCE(kaf.tactivo_fijo.codigo,'') = ''
        AND movaf.id_movimiento = v_id_movimiento;

        --Codifica los AFVs ya creados para el caso de las disgregaciones
        UPDATE kaf.tactivo_fijo_valores AA SET
        codigo = DD.codigo
        FROM (
            SELECT
            afv.id_activo_fijo_valor, af.codigo
            FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tmovimiento_af_especial mesp
            ON mesp.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = mesp.id_activo_fijo
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = afv.id_activo_fijo
            AND afv.codigo IS NULL
            WHERE maf.id_movimiento = v_id_movimiento
        ) DD
        WHERE AA.id_activo_fijo_valor = DD.id_activo_fijo_valor
        AND AA.codigo IS NULL;

    END IF;

    --Ajuste
    IF EXISTS(SELECT 1
            FROM kaf.tmovimiento_af maf
            JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_exist'
            WHERE maf.id_movimiento = v_registros.id_movimiento) THEN

        --Obtención del ID del movimiento Alta
        SELECT cat.id_catalogo
        INTO v_id_cat_movimiento
        FROM param.tcatalogo cat
        INNER JOIN param.tcatalogo_tipo ctip
        ON ctip.id_catalogo_tipo = cat.id_catalogo_tipo
        WHERE ctip.tabla = 'tmovimiento__id_cat_movimiento'
        AND cat.codigo = 'ajuste';

        IF v_id_cat_movimiento IS NULL THEN
            raise exception 'No se encuentra registrado el Proceso de Ajuste. Comuníquese con el administrador del sistema.';
        END IF;

        --Definción de parámetros
        SELECT
        'N/D' AS direccion,
        NULL AS fecha_hasta,
        v_id_cat_movimiento AS id_cat_movimiento,
        v_fecha_mov AS fecha_mov,
        v_id_depto AS id_depto,
        v_num_tramite || ' ' || v_glosa AS glosa, --#ETR-3334
        NULL AS id_funcionario,
        NULL AS id_oficina,
        NULL AS _id_usuario_ai,
        p_id_usuario AS id_usuario,
        NULL AS _nombre_usuario_ai,
        NULL AS id_persona,
        NULL AS codigo,
        NULL AS id_deposito,
        NULL AS id_depto_dest,
        NULL AS id_deposito_dest,
        NULL AS id_funcionario_dest,
        NULL AS id_movimiento_motivo,
        'si' AS mov_rapido --#58
        INTO v_rec_mov;

        --Creación del movimiento de ajuste
        v_id_movimiento = kaf.f_insercion_movimiento(p_id_usuario, hstore(v_rec_mov));

        --Inclusion del detalle del Ajuste
        INSERT INTO kaf.tmovimiento_af(
            id_movimiento,
            id_activo_fijo
        )
        SELECT
        v_id_movimiento,
        mafe.id_activo_fijo
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_exist'
        WHERE mov.id_movimiento = v_registros.id_movimiento;

        --Finalizacion del ajuste: obtención del estado finalizado y datos principales para el cambio de estado
        SELECT
        te.id_tipo_estado,
        ew.id_estado_wf,
        ew.id_proceso_wf,
        mov.id_depto,
        te.codigo
        INTO
        v_id_tipo_estado,
        v_id_estado_wf_act,
        v_id_proceso_wf_act,
        v_id_depto,
        v_codigo_estado_sig
        FROM kaf.tmovimiento mov
        INNER JOIN wf.testado_wf ew
        ON ew.id_estado_wf = mov.id_estado_wf
        INNER JOIN wf.tproceso_wf pw
        ON pw.id_proceso_wf = ew.id_proceso_wf
        INNER JOIN wf.ttipo_estado te
        ON te.id_tipo_proceso = pw.id_tipo_proceso
        WHERE mov.id_movimiento = v_id_movimiento
        AND te.codigo = 'finalizado';

        --Definición de datos para la notificación
        v_acceso_directo = '../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php';
        v_clase = 'Movimiento';
        v_parametros_ad = '{filtro_directo: {campo: "mov.id_proceso_wf", valor: "' || v_id_proceso_wf_act::varchar || '"}}';
        v_tipo_noti = 'notificacion';
        v_titulo  = 'Finalización';

        --Cambio de estado a Finalizado del ajuste
        v_id_estado_actual = wf.f_registra_estado_wf
                            (
                                v_id_tipo_estado,
                                NULL,
                                v_id_estado_wf_act,
                                v_id_proceso_wf_act,
                                p_id_usuario,
                                NULL,
                                NULL,
                                v_id_depto,
                                'Obs: Finalización automática del movimiento',
                                v_acceso_directo,
                                v_clase,
                                v_parametros_ad,
                                v_tipo_noti,
                                v_titulo
                            );
                            
        UPDATE kaf.tmovimiento SET
        id_estado_wf = v_id_estado_actual,
        estado = v_codigo_estado_sig
        WHERE id_movimiento = v_id_movimiento;

    END IF;
    
    ---------------------
    --Fin #ETR-3334
    ---------------------

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