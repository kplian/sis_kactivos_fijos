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

    v_nombre_funcion    text;
    v_resp              varchar;
    v_resp1             boolean;
    v_id_movimiento     integer;

BEGIN

    v_nombre_funcion = 'kaf.f_mov_esp_cambio_estado_wf';
    v_resp1 = false;

    --Obtencion de datos del movimiento
    SELECT id_movimiento
    INTO v_id_movimiento
    FROM kaf.tmovimiento
    WHERE id_proceso_wf = p_id_proceso_wf;

    --Verifica si debe generarse comprobante contable
    IF exists (
        --VERIFICA CASO ACTIVOS FIJOS EXISTENTES, SI ES QUE LA CUENTA CONTABLE CAMBIA
        SELECT
        1
        FROM (
            WITH tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF')
            )
            SELECT
            rc_af.id_cuenta, rc_af1.id_cuenta as id_cuenta_dest
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_exist'
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN kaf.tactivo_fijo af1
            ON af1.id_activo_fijo = mafe.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion (mov.fecha_mov))
            INNER JOIN conta.ttipo_relacion_contable trc_af
            ON trc_af.codigo_tipo_relacion = 'ALTAAF'
            AND trc_af.id_tipo_relacion_contable = rc_af.id_tipo_relacion_contable
            INNER JOIN tclasif_rel clr1
            ON af1.id_clasificacion = ANY(clr1.nodos)
            AND clr1.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af1
            ON rc_af1.id_tabla = clr1.id_clasificacion
            AND rc_af1.estado_reg = 'activo'
            AND rc_af1.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion (mov.fecha_mov))
            INNER JOIN conta.ttipo_relacion_contable trc_af1
            ON trc_af1.codigo_tipo_relacion = 'ALTAAF'
            AND trc_af1.id_tipo_relacion_contable = rc_af1.id_tipo_relacion_contable
            WHERE mov.id_movimiento = v_id_movimiento
        ) dat
        WHERE dat.id_cuenta <> dat.id_cuenta_dest
        UNION
        --VERIFICA CASO ACTIVOS FIJOS NUEVOS, SI ES QUE LA CUENTA CONTABLE CAMBIA
        SELECT
        1
        FROM (
            WITH tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF')
            )
            SELECT
            rc_af.id_cuenta, rc_af1.id_cuenta as id_cuenta_dest
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_nuevo'
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion (mov.fecha_mov))
            INNER JOIN conta.ttipo_relacion_contable trc_af
            ON trc_af.codigo_tipo_relacion = 'ALTAAF'
            AND trc_af.id_tipo_relacion_contable = rc_af.id_tipo_relacion_contable
            INNER JOIN tclasif_rel clr1
            ON mafe.id_clasificacion = ANY(clr1.nodos)
            AND clr1.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af1
            ON rc_af1.id_tabla = clr1.id_clasificacion
            AND rc_af1.estado_reg = 'activo'
            AND rc_af1.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion (mov.fecha_mov))
            INNER JOIN conta.ttipo_relacion_contable trc_af1
            ON trc_af1.codigo_tipo_relacion = 'ALTAAF'
            AND trc_af1.id_tipo_relacion_contable = rc_af1.id_tipo_relacion_contable
            WHERE mov.id_movimiento = v_id_movimiento
        ) dat
        WHERE dat.id_cuenta <> dat.id_cuenta_dest
        UNION
        --VERIFICA CASO ALMACEN, SI ES QUE LA CUENTA CONTABLE CAMBIA
        SELECT
        1
        FROM (
            WITH tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_almacen, trc.codigo_tipo_relacion as codigo
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'ALM'
                AND tb.tabla::text = 'talmacen'
                AND trc.codigo_tipo_relacion in ('ALMING')
            )
            SELECT
            rc_af.id_cuenta
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_almacen'
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON mafe.id_almacen = clr.id_almacen
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_almacen
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_gestion = (SELECT po_id_gestion FROM param.f_get_periodo_gestion (mov.fecha_mov))
            INNER JOIN conta.ttipo_relacion_contable trc_af
            ON trc_af.codigo_tipo_relacion = 'ALMING'
            AND trc_af.id_tipo_relacion_contable = rc_af.id_tipo_relacion_contable
            WHERE mov.id_movimiento = v_id_movimiento
        ) dat
        ) THEN
        v_resp1 = true;
    END IF;

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