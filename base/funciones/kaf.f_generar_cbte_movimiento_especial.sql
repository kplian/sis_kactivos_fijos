CREATE OR REPLACE FUNCTION kaf.f_generar_cbte_movimiento_especial (
    p_id_usuario integer,
    p_id_movimiento integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_generar_cbte_movimiento_especial
 DESCRIPCION:   Genera los comprobantes contables para los casos de movimientos especiales
 AUTOR:         RCM
 FECHA:         06/06/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           06/06/2019  RCM         Creación del archivo
 #21    KAF       ETR           24/07/2019  RCM         Inclusión de glosa por transacción
 #36    KAF       ETR           21/10/2019  RCM         Considerar CC de la gestión de la solicitud. Cambio de moneda por defecto, de UFV a USD
 #37    KAF       ETR           24/10/2019  RCM         Cambio en la lógica de generación comprobante caso salida de almacén
 #41    KAF       ETR           10/12/2019  RCM         Cambio de Relaciones contables ALINGTA, ALINGTD por las definidas en la clasificación de altas y dep. acum.
 #48    KAF       ETR           10/03/2020  RCM         Ajuste a la generación de comprobante caso activos fijos nuevos
 #66    KAF       ETR           08/05/2020  RCM         Ajuste a la generación de comprobante caso almacenes
 #69    KAF       ETR           20/06/2020  RCM         Cambio lógica basada en vaor neto para considerar el valor actualizado
***************************************************************************
*/
DECLARE

    v_nombre_funcion        varchar;
    v_resp                  varchar;
    v_id_int_comprobante    integer;
    v_rec                   record;
    v_kaf_cbte              varchar;
    v_id_estado_actual      varchar;
    v_id_estado_wf          integer;
    v_id_moneda             integer;
    v_id_moneda_bs          integer;
    v_id_moneda_usd         integer;
    v_id_moneda_ufv         integer;
    v_cantidad              integer;
    v_fecha_mov             date;
    v_codigo_moneda         varchar;
    v_id_centro_costo       integer; --#36
    --Inicio #37: Dos arrays para obtener la configuración de relaciones contables generales
    v_rec_rel_cont          record;
    v_rec_rel_cont1         record;
    v_rec_rel_cont2         record; --#69
    v_id_gestion            integer;
    --Fin #37
    v_tipo_cambio           NUMERIC; --#66

BEGIN

    /*
    El comprobante de la distribución de variables se generará en uno sólo los 3 tipos considerados: distribuídos a Activos Existentes,
    Nuevos y Salida a Almacén. Se creará el comprobante con INSERTS en las transacciones directos porque la versión actual del Generador de Comprobantes no
    tiene la capacidad de definir montos para cada una de las monedas.
    */

    --Inicialización de variables
    v_nombre_funcion = 'kaf.f_generar_cbte_movimiento_especial';
    v_id_int_comprobante = 0;
    v_kaf_cbte = 'KAF_MOVESP';

    --Obtención de valores del movimiento
    SELECT id_estado_wf, fecha_mov
    INTO v_id_estado_wf, v_fecha_mov
    FROM kaf.tmovimiento
    WHERE id_movimiento = p_id_movimiento;

    --Obtención de ID moneda parametrizada
    SELECT id_moneda
    INTO v_id_moneda
    FROM param.tmoneda
    WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

    --Obtención de los IDS de monedas
    SELECT id_moneda
    INTO v_id_moneda_bs
    FROM param.tmoneda
    WHERE codigo = 'BS';

    SELECT id_moneda
    INTO v_id_moneda_usd
    FROM param.tmoneda
    WHERE codigo = '$us';

    SELECT id_moneda
    INTO v_id_moneda_ufv
    FROM param.tmoneda
    WHERE codigo = 'UFV';

    --Inicio #36: Obtención de CC Administrativo
    SELECT
    rc.id_centro_costo
    INTO
    v_id_centro_costo
    FROM conta.ttipo_relacion_contable tr
    INNER JOIN conta.trelacion_contable rc
    ON rc.id_tipo_relacion_contable = tr.id_tipo_relacion_contable
    WHERE tr.codigo_tipo_relacion = 'CCDEPCON'
    AND rc.id_gestion IN (SELECT po_id_gestion FROM param.f_get_periodo_gestion (v_fecha_mov));
    --FIn #36

    --Inicio #37: Obtención de la gestión en base a la fecha del movimient
    SELECT po_id_gestion
    INTO v_id_gestion
    FROM param.f_get_periodo_gestion (v_fecha_mov);
    --Fin #37

    ---------------------------
    --Creación del comprobante (sólo cabecera)
    ---------------------------
    v_id_int_comprobante = conta.f_gen_comprobante
                            (
                                p_id_movimiento::integer,
                                v_kaf_cbte::varchar,
                                v_id_estado_wf::integer,
                                p_id_usuario::integer
                            );

    UPDATE kaf.tmovimiento SET
    id_int_comprobante = v_id_int_comprobante
    WHERE id_movimiento = p_id_movimiento;

    --Creación de tabla temporal para las transacciones
    CREATE TEMP TABLE tt_transaccion (
        id_trans                      integer,
        id_cuenta                     integer,
        id_partida                    integer,
        id_centro_costo               integer,
        id_cuenta_dest                integer,
        id_partida_dest               integer,
        id_centro_costo_dest          integer,
        id_cuenta_dep_acum            integer,
        id_partida_dep_acum           integer,
        id_centro_costo_dep_acum      integer,
        id_cuenta_dep_acum_dest       integer,
        id_partida_dep_acum_dest      integer,
        id_centro_costo_dep_acum_dest integer,
        importe_bs                    numeric,
        importe_usd                   numeric,
        importe_ufv                   numeric,
        depreciacion_acum_bs          numeric,
        depreciacion_acum_usd         numeric,
        depreciacion_acum_ufv         numeric,
        tipo                          varchar,
        glosa                         varchar, --#21 adición de columna para la glosa
        --Inicio #36
        id_cuenta_dest_af             integer,
        id_partida_dest_af            integer,
        id_cuenta_dest_dep_acum       integer,
        id_partida_dest_dep_acum      integer,
        codigo_af_original            varchar --#48
        --Fin #36
    ) ON COMMIT DROP;

    --Inserción de los valores a contabilizar
    -------------------------------
    --1 Caso activos fijos nuevos
    -------------------------------
    --Inicio #48
    v_rec_rel_cont = conta.f_get_config_relacion_contable
                    (
                        'AFDISTVAL-DEBE', --p_codigo
                        v_id_gestion --p_id_gestion
                    );

    v_rec_rel_cont1 = conta.f_get_config_relacion_contable
                    (
                        'AFDISTVAL-HABER', --p_codigo
                        v_id_gestion --p_id_gestion
                    );
    --Fin #48

    INSERT INTO tt_transaccion
    WITH tclasif_rel AS (
        SELECT
        rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
        (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
        FROM conta.ttabla_relacion_contable tb
        JOIN conta.ttipo_relacion_contable trc
        ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
        JOIN conta.trelacion_contable rc
        ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
        WHERE tb.esquema::text = 'KAF'
        AND tb.tabla::text = 'tclasificacion'
    )
    SELECT DISTINCT
    mesp.id_movimiento_af_especial,
    rc_af.id_cuenta, v_rec_rel_cont1.ps_id_partida, af.id_centro_costo, --#38
    rc_af1.id_cuenta, v_rec_rel_cont.ps_id_partida, af.id_centro_costo, --#48
    rc_dacum.id_cuenta, rc_dacum.id_partida, af.id_centro_costo,
    rc_dacum1.id_cuenta, rc_dacum1.id_partida, mesp.id_centro_costo,
    0, afv.monto_vigente_orig, 0, --#36 cambio orden
    0,
    afv.depreciacion_acum_inicial,  --#69
    0, --#36 cambio orden
    mesp.tipo,
    afo.codigo || ' => ' || mesp.denominacion, --#48
    NULL::integer, NULL::integer, NULL::integer, NULL::integer, --#36
    afo.codigo --#48
    FROM kaf.tmovimiento_af maf
    --Inicio #48
    INNER JOIN kaf.tactivo_fijo afo
    ON afo.id_activo_fijo = maf.id_activo_fijo
    --Fin #48
    INNER JOIN kaf.tmovimiento_af_especial mesp
    ON mesp.id_movimiento_af = maf.id_movimiento_af
    AND mesp.tipo = 'af_nuevo'
    INNER JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = mesp.id_activo_fijo
    INNER JOIN kaf.tactivo_fijo_valores afv
    ON afv.id_activo_fijo = af.id_activo_fijo
    AND afv.id_moneda = mesp.id_moneda
    INNER JOIN tclasif_rel clr
    ON afo.id_clasificacion = ANY(clr.nodos)
    AND clr.codigo = 'ALTAAF'
    INNER JOIN conta.trelacion_contable rc_af
    ON rc_af.id_tabla = clr.id_clasificacion
    AND rc_af.estado_reg = 'activo'
    AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
    AND rc_af.id_gestion = v_id_gestion
    INNER JOIN tclasif_rel clr1
    ON af.id_clasificacion = ANY(clr1.nodos)
    AND clr1.codigo = 'ALTAAF'
    INNER JOIN conta.trelacion_contable rc_af1
    ON rc_af1.id_tabla = clr1.id_clasificacion
    AND rc_af1.estado_reg = 'activo'
    AND rc_af1.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
    AND rc_af1.id_gestion = v_id_gestion
    INNER JOIN tclasif_rel clrdacum
    ON afo.id_clasificacion = ANY(clrdacum.nodos) --#69
    AND clrdacum.codigo = 'DEPACCLAS'
    INNER JOIN conta.trelacion_contable rc_dacum
    ON rc_dacum.id_tabla = clrdacum.id_clasificacion
    AND rc_dacum.estado_reg = 'activo'
    AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
    AND rc_dacum.id_gestion = v_id_gestion
    INNER JOIN tclasif_rel clrdacum1
    ON af.id_clasificacion = ANY(clrdacum1.nodos)
    AND clrdacum1.codigo = 'DEPACCLAS'
    INNER JOIN conta.trelacion_contable rc_dacum1
    ON rc_dacum1.id_tabla = clrdacum1.id_clasificacion
    AND rc_dacum1.estado_reg = 'activo'
    AND rc_dacum1.id_tipo_relacion_contable = clrdacum1.id_tipo_relacion_contable
    AND rc_dacum1.id_gestion = v_id_gestion
    WHERE maf.id_movimiento = p_id_movimiento;


    UPDATE tt_transaccion tr SET
    importe_ufv = dt.monto_vigente_orig,
    depreciacion_acum_ufv = dt.depreciacion_acum_inicial
    FROM (
        WITH tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
        )
        SELECT DISTINCT
        mesp.id_movimiento_af_especial,
        afv.id_moneda, afv.monto_vigente_orig,
        afv.depreciacion_acum_inicial as depreciacion_acum_inicial,
        afv.depreciacion_acum_inicial as depreciacion_per_inicial,
        mesp.id_centro_costo, rc_af.id_partida, rc_af.id_cuenta, rc_af.id_relacion_contable,
        rc_af1.id_partida, rc_af1.id_cuenta, rc_af1.id_relacion_contable
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento_af_especial mesp
        ON mesp.id_movimiento_af = maf.id_movimiento_af
        AND mesp.tipo = 'af_nuevo'
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = mesp.id_activo_fijo
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = af.id_activo_fijo
        AND afv.id_moneda = v_id_moneda_ufv
        INNER JOIN tclasif_rel clr
        ON mesp.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clr1
        ON af.id_clasificacion = ANY(clr1.nodos)
        AND clr1.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af1
        ON rc_af1.id_tabla = clr1.id_clasificacion
        AND rc_af1.estado_reg = 'activo'
        AND rc_af1.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
        AND rc_af1.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clrdacum
        ON mesp.id_clasificacion = ANY(clrdacum.nodos) --#69
        AND clrdacum.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clrdacum1
        ON af.id_clasificacion = ANY(clrdacum1.nodos)
        AND clrdacum1.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum1
        ON rc_dacum1.id_tabla = clrdacum1.id_clasificacion
        AND rc_dacum1.estado_reg = 'activo'
        AND rc_dacum1.id_tipo_relacion_contable = clrdacum1.id_tipo_relacion_contable
        AND rc_dacum1.id_gestion = v_id_gestion
        WHERE maf.id_movimiento = p_id_movimiento

    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;


    UPDATE tt_transaccion tr SET
    importe_bs = dt.monto_vigente_orig,
    depreciacion_acum_bs = dt.depreciacion_acum_inicial
    FROM (
        WITH tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
        )
        SELECT DISTINCT
        mesp.id_movimiento_af_especial,
        afv.id_moneda, afv.monto_vigente_orig,
        afv.depreciacion_acum_inicial as depreciacion_acum_inicial, --#69
        afv.depreciacion_acum_inicial as depreciacion_per_inicial, --#69
        mesp.id_centro_costo, rc_af.id_partida, rc_af.id_cuenta, rc_af.id_relacion_contable,
        rc_af1.id_partida, rc_af1.id_cuenta, rc_af1.id_relacion_contable
        FROM kaf.tmovimiento_af maf
        INNER JOIN kaf.tmovimiento_af_especial mesp
        ON mesp.id_movimiento_af = maf.id_movimiento_af
        AND mesp.tipo = 'af_nuevo'
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = mesp.id_activo_fijo
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = af.id_activo_fijo
        AND afv.id_moneda = v_id_moneda_bs
        INNER JOIN tclasif_rel clr
        ON mesp.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clr1
        ON af.id_clasificacion = ANY(clr1.nodos)
        AND clr1.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af1
        ON rc_af1.id_tabla = clr1.id_clasificacion
        AND rc_af1.estado_reg = 'activo'
        AND rc_af1.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
        AND rc_af1.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clrdacum
        ON mesp.id_clasificacion = ANY(clrdacum.nodos) --#69
        AND clrdacum.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clrdacum1
        ON af.id_clasificacion = ANY(clrdacum1.nodos)
        AND clrdacum1.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum1
        ON rc_dacum1.id_tabla = clrdacum1.id_clasificacion
        AND rc_dacum1.estado_reg = 'activo'
        AND rc_dacum1.id_tipo_relacion_contable = clrdacum1.id_tipo_relacion_contable
        AND rc_dacum1.id_gestion = v_id_gestion
        WHERE maf.id_movimiento = p_id_movimiento
    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;


    --Inserción de los valores a contabilizar
    -----------------------------------
    --2 Caso activos fijos existentes
    -----------------------------------
    INSERT INTO tt_transaccion
    WITH tactivo_origen AS (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        ), tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
        )
        SELECT DISTINCT
        mov.fecha_mov, mdep.id_activo_fijo_valor, mdep.monto_actualiz, mdep.depreciacion_acum,
        mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mov.id_movimiento,
        rc_af.id_cuenta, rc_af.id_partida, af.id_centro_costo,
        rc_dacum.id_cuenta as id_cuenta_dep_acum_orig, rc_dacum.id_partida as id_partida_dep_acum_orig, af.id_centro_costo as id_centro_costo_dep_acum_orig,
        --Inicio #48
        af.codigo as codigo_orig, --#21 adición de código para usarlo en la glosa
        af.codigo as codigo_original,
        '' as denominacion,
        --Fin #48
        mdep.monto_vigente
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN tclasif_rel clr
        ON af.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion

        INNER JOIN tclasif_rel clrdacum
        ON af.id_clasificacion = ANY(clrdacum.nodos)
        AND clrdacum.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion

        WHERE mov.id_movimiento = p_id_movimiento
    ), tactivo_destino AS (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        ), tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
        )
        SELECT DISTINCT
        mdep.id_activo_fijo_valor, mafe.id_movimiento_af_especial, mafe.costo_orig, --#69
        mafe.porcentaje,
        mdep.monto_actualiz, mdep.depreciacion_acum,
        mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mafe.id_activo_fijo,
        mov.fecha_mov, mod.id_moneda_dep, mdep.vida_util, mov.id_movimiento,
        rc_af.id_cuenta, rc_af.id_partida, mafe.tipo, af.id_centro_costo,
        rc_dacum.id_cuenta as id_cuenta_dep_acum_dest, rc_dacum.id_partida as id_partida_dep_acum_dest, af.id_centro_costo as id_centro_costo_dep_acum_dest,
        --Inicio #48
        af.codigo as codigo_dest, --#21 adición de código para usarlo en la glosa
        afo.codigo as codigo_original,
        mafe.denominacion
        --Fin #48
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        --Inicio #48
        INNER JOIN kaf.tactivo_fijo afo
        ON afo.id_activo_fijo = maf.id_activo_fijo
        --Fin #48
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_exist'
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = mafe.id_activo_fijo
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        AND mdep.fecha = dult.fecha_max
        INNER JOIN kaf.tmoneda_dep mod
        ON mod.id_moneda = mdep.id_moneda
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = mafe.id_activo_fijo
        INNER JOIN tclasif_rel clr
        ON af.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'ALTAAF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion

        INNER JOIN tclasif_rel clrdacum
        ON af.id_clasificacion = ANY(clrdacum.nodos)
        AND clrdacum.codigo = 'DEPACCLAS'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion

        WHERE mov.id_movimiento = p_id_movimiento
    )
    SELECT
    tad.id_movimiento_af_especial,
    tao.id_cuenta, v_rec_rel_cont1.ps_id_partida, tao.id_centro_costo,
    tad.id_cuenta, v_rec_rel_cont.ps_id_partida, tad.id_centro_costo,
    tao.id_cuenta_dep_acum_orig, tao.id_partida_dep_acum_orig, tao.id_centro_costo_dep_acum_orig,
    tad.id_cuenta_dep_acum_dest, tad.id_partida_dep_acum_dest, tad.id_centro_costo_dep_acum_dest,
    0,
    CASE tad.id_moneda
        WHEN v_id_moneda THEN tad.costo_orig --#69
        ELSE (tao.monto_actualiz * tad.porcentaje / 100) --#69
    END AS monto_vigente_orig,
    0,
    0,
    (tao.depreciacion_acum * tad.porcentaje / 100) AS depreciacion_acum, --#69
    0,
    tad.tipo,
    --(tao.codigo_orig || ' => ' || tad.codigo_dest || ' (' || tad.tipo || ') ')::varchar as glosa, --#21 adición de columna para la glosa
    --Inicio #48
    tao.codigo_original || ' => ' || tad.denominacion,
    NULL, NULL, NULL, NULL, --#36
    tao.codigo_original
    --Fin #48
    FROM tactivo_origen tao
    INNER JOIN tactivo_destino tad
    ON tad.id_movimiento_af = tao.id_movimiento_af
    AND tad.id_moneda = tao.id_moneda
    WHERE tad.id_moneda = v_id_moneda_usd; -- #36 antes v_id_moneda_ufv
    /*AND (tao.id_cuenta <> tad.id_cuenta
        OR tao.id_partida <> tad.id_partida
    );*/

    UPDATE tt_transaccion tr SET
    importe_ufv = dt.monto_vigente_orig,
    depreciacion_acum_ufv = dt.depreciacion_acum
    FROM (
        WITH tactivo_origen AS (
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                GROUP BY afv.id_activo_fijo
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
            )
            SELECT DISTINCT
            mov.fecha_mov, mdep.id_activo_fijo_valor, mdep.monto_actualiz, mdep.depreciacion_acum,
            mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mov.id_movimiento,
            rc_af.id_cuenta, rc_af.id_partida,
            mdep.monto_vigente
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            INNER JOIN tult_dep dult
            ON dult.id_activo_fijo = afv.id_activo_fijo
            AND dult.fecha_max = mdep.fecha
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = v_id_gestion

            INNER JOIN tclasif_rel clrdacum
            ON af.id_clasificacion = ANY(clrdacum.nodos)
            AND clrdacum.codigo = 'DEPACCLAS'
            INNER JOIN conta.trelacion_contable rc_dacum
            ON rc_dacum.id_tabla = clrdacum.id_clasificacion
            AND rc_dacum.estado_reg = 'activo'
            AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
            AND rc_dacum.id_gestion = v_id_gestion

            WHERE mov.id_movimiento = p_id_movimiento
        ), tactivo_destino AS (
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                GROUP BY afv.id_activo_fijo
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
            )
            SELECT DISTINCT
            mdep.id_activo_fijo_valor, mafe.id_movimiento_af_especial, mafe.costo_orig, --#69
            mafe.porcentaje,
            mdep.monto_actualiz, mdep.depreciacion_acum,
            mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mafe.id_activo_fijo,
            mov.fecha_mov, mod.id_moneda_dep, mdep.vida_util, mov.id_movimiento,
            rc_af.id_cuenta, rc_af.id_partida, mafe.tipo, af.id_centro_costo
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_exist'
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = mafe.id_activo_fijo
            INNER JOIN tult_dep dult
            ON dult.id_activo_fijo = afv.id_activo_fijo
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            AND mdep.fecha = dult.fecha_max
            INNER JOIN kaf.tmoneda_dep mod
            ON mod.id_moneda = mdep.id_moneda
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = mafe.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = v_id_gestion

            INNER JOIN tclasif_rel clrdacum
            ON af.id_clasificacion = ANY(clrdacum.nodos)
            AND clrdacum.codigo = 'DEPACCLAS'
            INNER JOIN conta.trelacion_contable rc_dacum
            ON rc_dacum.id_tabla = clrdacum.id_clasificacion
            AND rc_dacum.estado_reg = 'activo'
            AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
            AND rc_dacum.id_gestion = v_id_gestion

            WHERE mov.id_movimiento = p_id_movimiento
        )
        SELECT
        tad.id_movimiento_af_especial, tad.id_cuenta, tad.id_partida, tad.id_centro_costo, 0, 0,
        CASE tad.id_moneda
            WHEN v_id_moneda THEN tad.costo_orig
            ELSE (tao.monto_actualiz * tad.porcentaje / 100) --#69
        END AS monto_vigente_orig,
        (tao.depreciacion_acum * tad.porcentaje / 100) AS depreciacion_acum, --#69
        tad.tipo
        FROM tactivo_origen tao
        INNER JOIN tactivo_destino tad
        ON tad.id_movimiento_af = tao.id_movimiento_af
        AND tad.id_moneda = tao.id_moneda
        WHERE tad.id_moneda = v_id_moneda_ufv
        /*AND (tao.id_cuenta <> tad.id_cuenta
            OR tao.id_partida <> tad.id_partida
        )*/
    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;

    UPDATE tt_transaccion tr SET
    importe_bs = dt.monto_vigente_orig,
    depreciacion_acum_bs = dt.depreciacion_acum
    FROM (
        WITH tactivo_origen AS (
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                GROUP BY afv.id_activo_fijo
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
            )
            SELECT DISTINCT
            mov.fecha_mov, mdep.id_activo_fijo_valor, mdep.monto_actualiz, mdep.depreciacion_acum,
            mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mov.id_movimiento,
            rc_af.id_cuenta, rc_af.id_partida,
            mdep.monto_vigente
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            INNER JOIN tult_dep dult
            ON dult.id_activo_fijo = afv.id_activo_fijo
            AND dult.fecha_max = mdep.fecha
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = v_id_gestion

            INNER JOIN tclasif_rel clrdacum
            ON af.id_clasificacion = ANY(clrdacum.nodos)
            AND clrdacum.codigo = 'DEPACCLAS'
            INNER JOIN conta.trelacion_contable rc_dacum
            ON rc_dacum.id_tabla = clrdacum.id_clasificacion
            AND rc_dacum.estado_reg = 'activo'
            AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
            AND rc_dacum.id_gestion = v_id_gestion

            WHERE mov.id_movimiento = p_id_movimiento
        ), tactivo_destino AS (
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                GROUP BY afv.id_activo_fijo
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = 'KAF'
                AND tb.tabla::text = 'tclasificacion'
                AND trc.codigo_tipo_relacion in ('ALTAAF','DEPACCLAS')
            )
            SELECT DISTINCT
            mdep.id_activo_fijo_valor, mafe.id_movimiento_af_especial, mafe.costo_orig, --#69
            mafe.porcentaje,
            mdep.monto_actualiz, mdep.depreciacion_acum,
            mdep.depreciacion_per, maf.id_movimiento_af, mdep.id_moneda, mafe.id_activo_fijo,
            mov.fecha_mov, mod.id_moneda_dep, mdep.vida_util, mov.id_movimiento,
            rc_af.id_cuenta, rc_af.id_partida, mafe.tipo, af.id_centro_costo
            FROM kaf.tmovimiento mov
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento = mov.id_movimiento
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_movimiento_af = maf.id_movimiento_af
            AND mafe.tipo = 'af_exist'
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = mafe.id_activo_fijo
            INNER JOIN tult_dep dult
            ON dult.id_activo_fijo = afv.id_activo_fijo
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            AND mdep.fecha = dult.fecha_max
            INNER JOIN kaf.tmoneda_dep mod
            ON mod.id_moneda = mdep.id_moneda
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = mafe.id_activo_fijo
            INNER JOIN tclasif_rel clr
            ON af.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = 'ALTAAF'
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = 'activo'
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = v_id_gestion

            INNER JOIN tclasif_rel clrdacum
            ON af.id_clasificacion = ANY(clrdacum.nodos)
            AND clrdacum.codigo = 'DEPACCLAS'
            INNER JOIN conta.trelacion_contable rc_dacum
            ON rc_dacum.id_tabla = clrdacum.id_clasificacion
            AND rc_dacum.estado_reg = 'activo'
            AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
            AND rc_dacum.id_gestion = v_id_gestion

            WHERE mov.id_movimiento = p_id_movimiento
        )
        SELECT
        tad.id_movimiento_af_especial, tad.id_cuenta, tad.id_partida, tad.id_centro_costo, 0, 0,
        CASE tad.id_moneda
            WHEN v_id_moneda THEN tad.costo_orig
            ELSE (tao.monto_actualiz * tad.porcentaje / 100) --#69
        END AS monto_vigente_orig,
        (tao.depreciacion_acum * tad.porcentaje / 100) AS depreciacion_acum,
        tad.tipo
        FROM tactivo_origen tao
        INNER JOIN tactivo_destino tad
        ON tad.id_movimiento_af = tao.id_movimiento_af
        AND tad.id_moneda = tao.id_moneda
        WHERE tad.id_moneda = v_id_moneda_bs
        /*AND (tao.id_cuenta <> tad.id_cuenta
            OR tao.id_partida <> tad.id_partida
        )*/
    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;


    -------------------------------
    --3 Caso Salida a Almacen
    -------------------------------
    --Inicio #37: obtención de valores de las relaciones contables: TRAFALAC (transferencia activo fijo), TRAFALDAC (transferencia dep. acum.)
    v_rec_rel_cont = conta.f_get_config_relacion_contable
                    (
                        'TRAFALAC', --p_codigo
                        v_id_gestion --p_id_gestion
                    );

    v_rec_rel_cont1 = conta.f_get_config_relacion_contable
                    (
                        'TRAFALDAC', --p_codigo
                        v_id_gestion --p_id_gestion
                    );
    --Fin #37

    INSERT INTO tt_transaccion
    WITH tult_dep AS (
        SELECT
        afv.id_activo_fijo,
        MAX(mdep.fecha) AS fecha_max
        FROM kaf.tmovimiento_af_dep mdep
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
        GROUP BY afv.id_activo_fijo
    ), tclasif_rel AS (
        SELECT
        rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
        (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
        FROM conta.ttabla_relacion_contable tb
        JOIN conta.ttipo_relacion_contable trc
        ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
        JOIN conta.trelacion_contable rc
        ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
        WHERE (tb.esquema::text = 'KAF'
        AND tb.tabla::text = 'tclasificacion'
        AND trc.codigo_tipo_relacion IN ('AF-DISG_AF','AF-DISG_DACUM'))
        OR (tb.esquema::text = 'ALM'
        AND tb.tabla::text = 'talmacen'
        AND trc.codigo_tipo_relacion IN ('ALINGT'/*, 'ALINGTA', 'ALINGTD'*/)) --#36
    )
    SELECT DISTINCT --#66
    mafe.id_movimiento_af_especial,
    rc_af.id_cuenta, rc_af.id_partida, af.id_centro_costo,
    rc_al.id_cuenta, rc_al.id_partida, af.id_centro_costo,
    rc_dacum.id_cuenta, rc_dacum.id_partida, af.id_centro_costo,
    rc_dacum.id_cuenta, rc_dacum.id_partida, af.id_centro_costo,
    0,
    CASE afv.id_moneda
        WHEN v_id_moneda THEN mafe.costo_orig --#66
        ELSE (mdep.monto_actualiz * mafe.porcentaje / 100)
    END AS monto_vigente_orig,
    0,
    0,
    (mdep.depreciacion_acum * mafe.porcentaje / 100) as depreciacion_acum,
    0,
    mafe.tipo,
    (af.codigo || ' => ' || alm.codigo || ' (' || mafe.tipo || ') ' || mafe.descripcion)::varchar as glosa, --#21 adición de columna para la glosa
    --Inicio #41
    /*--Inicio #36
    rc_al2.id_cuenta, rc_al2.id_partida,
    rc_al3.id_cuenta, rc_al3.id_partida
    --Fin #36*/
    rc_af.id_cuenta, rc_af.id_partida,
    rc_dacum.id_cuenta, rc_dacum.id_partida,
    --Fin #41
    afo.codigo --#48
    FROM kaf.tmovimiento mov
    INNER JOIN kaf.tmovimiento_af maf
    ON maf.id_movimiento = mov.id_movimiento
    --Inicio #48
    INNER join kaf.tactivo_fijo afo
    ON afo.id_activo_fijo = maf.id_activo_fijo
    --Fin #48
    INNER JOIN kaf.tactivo_fijo_valores afv
    ON afv.id_activo_fijo = maf.id_activo_fijo
    INNER JOIN kaf.tmovimiento_af_dep mdep
    ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
    INNER JOIN tult_dep dult
    ON dult.id_activo_fijo = afv.id_activo_fijo
    AND dult.fecha_max = mdep.fecha
    INNER JOIN kaf.tactivo_fijo af
    ON af.id_activo_fijo = maf.id_activo_fijo
    INNER JOIN tclasif_rel clr
    ON af.id_clasificacion = ANY(clr.nodos)
    AND clr.codigo = 'AF-DISG_AF'
    INNER JOIN conta.trelacion_contable rc_af
    ON rc_af.id_tabla = clr.id_clasificacion
    AND rc_af.estado_reg = 'activo'
    AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
    AND rc_af.id_gestion = v_id_gestion
    INNER JOIN kaf.tmovimiento_af_especial mafe
    ON mafe.id_movimiento_af = maf.id_movimiento_af
    AND mafe.tipo = 'af_almacen'
    INNER JOIN alm.talmacen alm
    ON alm.id_almacen = mafe.id_almacen
    INNER JOIN tclasif_rel clr1
    ON clr1.id_clasificacion = alm.id_almacen
    --Inicio #36
    AND clr1.codigo = 'ALINGT'
    INNER JOIN conta.trelacion_contable rc_al
    ON rc_al.id_tabla = alm.id_almacen
    AND rc_al.estado_reg = 'activo'
    AND rc_al.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
    AND rc_al.id_gestion = v_id_gestion
    --Inicio #41: se comenta el bloque siguiente
    /*INNER JOIN tclasif_rel clr2
    ON clr2.id_clasificacion = alm.id_almacen
    AND clr2.codigo = 'ALINGTA'
    INNER JOIN conta.trelacion_contable rc_al2
    ON rc_al2.id_tabla = alm.id_almacen
    AND rc_al2.estado_reg = 'activo'
    AND rc_al2.id_tipo_relacion_contable = clr2.id_tipo_relacion_contable
    AND rc_al2.id_gestion = v_id_gestion
    INNER JOIN tclasif_rel clr3
    ON clr3.id_clasificacion = alm.id_almacen
    AND clr3.codigo = 'ALINGTD'
    INNER JOIN conta.trelacion_contable rc_al3
    ON rc_al3.id_tabla = alm.id_almacen
    AND rc_al3.estado_reg = 'activo'
    AND rc_al3.id_tipo_relacion_contable = clr3.id_tipo_relacion_contable
    AND rc_al3.id_gestion = v_id_gestion
    --Fin #36*/
    --Fin #41
    INNER JOIN tclasif_rel clrdacum
    ON af.id_clasificacion = ANY(clrdacum.nodos)
    AND clrdacum.codigo = 'AF-DISG_DACUM'
    INNER JOIN conta.trelacion_contable rc_dacum
    ON rc_dacum.id_tabla = clrdacum.id_clasificacion
    AND rc_dacum.estado_reg = 'activo'
    AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
    AND rc_dacum.id_gestion = v_id_gestion

    WHERE mov.id_movimiento = p_id_movimiento
    AND afv.id_moneda = v_id_moneda_usd
    AND (rc_al.id_cuenta <> rc_af.id_cuenta
        OR rc_al.id_partida <> rc_af.id_partida
    );

    UPDATE tt_transaccion tr SET
    importe_ufv = dt.monto_vigente_orig,
    depreciacion_acum_ufv = dt.depreciacion_acum
    FROM (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        ), tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE (tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion IN ('AF-DISG_AF','AF-DISG_DACUM'))
            OR (tb.esquema::text = 'ALM'
            AND tb.tabla::text = 'talmacen'
            AND trc.codigo_tipo_relacion IN ('ALINGT'/*, 'ALINGTA', 'ALINGTD'*/)) --#36
        )
        SELECT
        mafe.id_movimiento_af_especial, rc_al.id_cuenta, rc_al.id_partida, null,
        0,
        CASE afv.id_moneda
            WHEN v_id_moneda THEN mafe.costo_orig --#66
            ELSE (mdep.monto_actualiz * mafe.porcentaje / 100)
        END AS monto_vigente_orig,
        0,
        0,
        (mdep.depreciacion_acum * mafe.porcentaje / 100) as depreciacion_acum,
        0,
        mafe.tipo
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN tclasif_rel clr
        ON af.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'AF-DISG_AF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_almacen'
        INNER JOIN alm.talmacen alm
        ON alm.id_almacen = mafe.id_almacen
        INNER JOIN tclasif_rel clr1
        ON clr1.id_clasificacion = alm.id_almacen
        --Inicio #36
        AND clr1.codigo = 'ALINGT'
        INNER JOIN conta.trelacion_contable rc_al
        ON rc_al.id_tabla = alm.id_almacen
        AND rc_al.estado_reg = 'activo'
        AND rc_al.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
        AND rc_al.id_gestion = v_id_gestion
        --Inicio #41: se comenta el siguiente bloque
        /*INNER JOIN tclasif_rel clr2
        ON clr2.id_clasificacion = alm.id_almacen
        AND clr2.codigo = 'ALINGTA'
        INNER JOIN conta.trelacion_contable rc_al2
        ON rc_al2.id_tabla = alm.id_almacen
        AND rc_al2.estado_reg = 'activo'
        AND rc_al2.id_tipo_relacion_contable = clr2.id_tipo_relacion_contable
        AND rc_al2.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clr3
        ON clr3.id_clasificacion = alm.id_almacen
        AND clr3.codigo = 'ALINGTD'
        INNER JOIN conta.trelacion_contable rc_al3
        ON rc_al3.id_tabla = alm.id_almacen
        AND rc_al3.estado_reg = 'activo'
        AND rc_al3.id_tipo_relacion_contable = clr3.id_tipo_relacion_contable
        AND rc_al3.id_gestion = v_id_gestion
        --Fin #36*/

        INNER JOIN tclasif_rel clrdacum
        ON af.id_clasificacion = ANY(clrdacum.nodos)
        AND clrdacum.codigo = 'AF-DISG_DACUM'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion

        WHERE mov.id_movimiento = p_id_movimiento
        AND afv.id_moneda = v_id_moneda_ufv
        AND (rc_al.id_cuenta <> rc_af.id_cuenta
            OR rc_al.id_partida <> rc_af.id_partida
        )
    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;

    UPDATE tt_transaccion tr SET
    importe_bs = dt.monto_vigente_orig,
    depreciacion_acum_bs = dt.depreciacion_acum
    FROM (
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        ), tclasif_rel AS (
            SELECT
            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
            (('{' || kaf.f_get_id_clasificaciones(rc.id_tabla, 'hijos')) || '}')::integer [ ] AS nodos
            FROM conta.ttabla_relacion_contable tb
            JOIN conta.ttipo_relacion_contable trc
            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
            JOIN conta.trelacion_contable rc
            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
            WHERE (tb.esquema::text = 'KAF'
            AND tb.tabla::text = 'tclasificacion'
            AND trc.codigo_tipo_relacion IN ('AF-DISG_AF','AF-DISG_DACUM'))
            OR (tb.esquema::text = 'ALM'
            AND tb.tabla::text = 'talmacen'
            AND trc.codigo_tipo_relacion IN ('ALINGT'/*, 'ALINGTA', 'ALINGTD'*/)) --#36
        )
        SELECT
        mafe.id_movimiento_af_especial, rc_al.id_cuenta, rc_al.id_partida, null, 0, 0,
        CASE afv.id_moneda
            WHEN v_id_moneda THEN mafe.costo_orig --#66
            ELSE (mdep.monto_actualiz * mafe.porcentaje / 100)
        END AS monto_vigente_orig,
        0, 0,
        (mdep.depreciacion_acum * mafe.porcentaje / 100) as depreciacion_acum,
        mafe.tipo
        FROM kaf.tmovimiento mov
        INNER JOIN kaf.tmovimiento_af maf
        ON maf.id_movimiento = mov.id_movimiento
        INNER JOIN kaf.tactivo_fijo_valores afv
        ON afv.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        AND dult.fecha_max = mdep.fecha
        INNER JOIN kaf.tactivo_fijo af
        ON af.id_activo_fijo = maf.id_activo_fijo
        INNER JOIN tclasif_rel clr
        ON af.id_clasificacion = ANY(clr.nodos)
        AND clr.codigo = 'AF-DISG_AF'
        INNER JOIN conta.trelacion_contable rc_af
        ON rc_af.id_tabla = clr.id_clasificacion
        AND rc_af.estado_reg = 'activo'
        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
        AND rc_af.id_gestion = v_id_gestion
        INNER JOIN kaf.tmovimiento_af_especial mafe
        ON mafe.id_movimiento_af = maf.id_movimiento_af
        AND mafe.tipo = 'af_almacen'
        INNER JOIN alm.talmacen alm
        ON alm.id_almacen = mafe.id_almacen
        INNER JOIN tclasif_rel clr1
        ON clr1.id_clasificacion = alm.id_almacen
        --Inicio #36
        AND clr1.codigo = 'ALINGT'
        INNER JOIN conta.trelacion_contable rc_al
        ON rc_al.id_tabla = alm.id_almacen
        AND rc_al.estado_reg = 'activo'
        AND rc_al.id_tipo_relacion_contable = clr1.id_tipo_relacion_contable
        AND rc_al.id_gestion = v_id_gestion
        --Inicio #41: se comenta el siguiente bloque
        /*INNER JOIN tclasif_rel clr2
        ON clr2.id_clasificacion = alm.id_almacen
        AND clr2.codigo = 'ALINGTA'
        INNER JOIN conta.trelacion_contable rc_al2
        ON rc_al2.id_tabla = alm.id_almacen
        AND rc_al2.estado_reg = 'activo'
        AND rc_al2.id_tipo_relacion_contable = clr2.id_tipo_relacion_contable
        AND rc_al2.id_gestion = v_id_gestion
        INNER JOIN tclasif_rel clr3
        ON clr3.id_clasificacion = alm.id_almacen
        AND clr3.codigo = 'ALINGTD'
        INNER JOIN conta.trelacion_contable rc_al3
        ON rc_al3.id_tabla = alm.id_almacen
        AND rc_al3.estado_reg = 'activo'
        AND rc_al3.id_tipo_relacion_contable = clr3.id_tipo_relacion_contable
        AND rc_al3.id_gestion = v_id_gestion
        --Fin #36
        --Fin #41
        */
        INNER JOIN tclasif_rel clrdacum
        ON af.id_clasificacion = ANY(clrdacum.nodos)
        AND clrdacum.codigo = 'AF-DISG_DACUM'
        INNER JOIN conta.trelacion_contable rc_dacum
        ON rc_dacum.id_tabla = clrdacum.id_clasificacion
        AND rc_dacum.estado_reg = 'activo'
        AND rc_dacum.id_tipo_relacion_contable = clrdacum.id_tipo_relacion_contable
        AND rc_dacum.id_gestion = v_id_gestion

        WHERE mov.id_movimiento = p_id_movimiento
        AND afv.id_moneda = v_id_moneda_bs
        AND (rc_al.id_cuenta <> rc_af.id_cuenta
            OR rc_al.id_partida <> rc_af.id_partida
        )
    ) dt
    WHERE tr.id_trans = dt.id_movimiento_af_especial;


    -----------------------------------------------------------------------------------------------------
    --GENERACIÓN DE COMPROBANTE CASOS ACTIVOS FIJOS NUEVOS Y EXISTENTES: Inserción de las transacciones
    -----------------------------------------------------------------------------------------------------
    --Haber: Depreciación acumulada
    v_rec_rel_cont2 = conta.f_get_config_relacion_contable
                    (
                        'AFDVALDACUMHABE',
                        v_id_gestion --p_id_gestion
                    );

    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa --#21 adición de columna para la glosa
    )
    --Inicio #36
    SELECT
    v_rec_rel_cont2.ps_id_partida, --t.id_partida_dep_acum_dest, --#36
    v_id_centro_costo, --#36
    'activo',
    t.id_cuenta_dep_acum_dest, --#36
    v_id_int_comprobante,
    --Inicio #69
    --Inicio #36
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    --Fin #36
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    --Fin #69
    p_id_usuario,
    now(),
    t.glosa --#21 adición de columna para la glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.depreciacion_acum_bs, 0) > 0
    OR COALESCE(t.depreciacion_acum_usd, 0) > 0
    OR COALESCE(t.depreciacion_acum_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') <> 'af_almacen'; --#66: solo para caso activos fijos

    --Inicio #37
    --Debe: Depreciación acumulada
    v_rec_rel_cont2 = conta.f_get_config_relacion_contable
                    (
                        'AFDVALDACUMDEBE',
                        v_id_gestion --p_id_gestion
                    );

    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa --#21 adición de columna para la glosa
    )
    SELECT
    v_rec_rel_cont2.ps_id_partida,--t.id_partida_dep_acum,
    v_id_centro_costo,
    'activo',
    t.id_cuenta_dep_acum,
    v_id_int_comprobante,
    --Inicio #69
    --Inicio #48
    SUM(t.depreciacion_acum_bs),
    SUM(t.depreciacion_acum_bs),
    SUM(t.depreciacion_acum_usd),
    SUM(t.depreciacion_acum_ufv),
    SUM(t.depreciacion_acum_bs),
    SUM(t.depreciacion_acum_bs),
    SUM(t.depreciacion_acum_usd),
    SUM(t.depreciacion_acum_ufv),
    --Fin #48
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    --Fin #69
    p_id_usuario,
    now(),
    t.codigo_af_original --#48
    FROM tt_transaccion t
    WHERE (COALESCE(t.depreciacion_acum_bs, 0) > 0
    OR COALESCE(t.depreciacion_acum_usd, 0) > 0
    OR COALESCE(t.depreciacion_acum_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') <> 'af_almacen' --#66: solo para caso activos fijos
    --Inicio #48
    GROUP BY t.id_partida_dep_acum, v_id_centro_costo, t.id_cuenta_dep_acum, v_id_int_comprobante,
    p_id_usuario, t.codigo_af_original;
    --Fin #48
    --Fin #37

    --Haber: Monto activo fijo
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa --#21 adición de columna para la glosa
    )
    --Inicio #36
    SELECT
    t.id_partida,
    v_id_centro_costo,
    'activo',
    t.id_cuenta,
    v_id_int_comprobante,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    --Inicio #48
    SUM(t.importe_bs),
    SUM(t.importe_bs),
    SUM(t.importe_usd),
    SUM(t.importe_ufv),
    SUM(t.importe_bs),
    SUM(t.importe_bs),
    SUM(t.importe_usd),
    SUM(t.importe_ufv),
    --Fin #48
    p_id_usuario,
    now(),
    t.codigo_af_original --#48
    FROM tt_transaccion t
    WHERE (COALESCE(t.importe_bs, 0) > 0
    OR COALESCE(t.importe_usd, 0) > 0
    OR COALESCE(t.importe_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') <> 'af_almacen' --#66: solo para caso activos fijos
    --Inicio #48
    GROUP BY t.id_partida,
    v_id_centro_costo,
    t.id_cuenta,
    v_id_int_comprobante,
    p_id_usuario,
    t.codigo_af_original;
    --Fin #48


    --Inicio #37
    --Debe: Contracuenta 1/2 DEL activo fijo sólo parcial. Se pone en USD y UFV el monto ya definido, en caso de BS se hace la conversión de USD a BS. La diferencia q existe entre
    --ese monto convertido y el monto en bs previamente definido es la actualización, que debe ir en otra transacción son en BS
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    t.id_partida_dest,--t.id_partida_dest_af,
    v_id_centro_costo,
    'activo',
    t.id_cuenta_dest,--t.id_cuenta_dest_af,
    v_id_int_comprobante,
    --Inicio #48
    t.importe_bs, --param.f_convertir_moneda(2, 1, t.importe_usd, v_fecha_mov, 'O', 2), --t.importe_bs,
    t.importe_bs, --param.f_convertir_moneda(2, 1, t.importe_usd, v_fecha_mov, 'O', 2),--t.importe_bs,
    --fin #48
    t.importe_usd,
    t.importe_ufv,
    --Inicio #48
    t.importe_bs, --param.f_convertir_moneda(2, 1, t.importe_usd, v_fecha_mov, 'O', 2),--t.importe_bs,
    t.importe_bs,--param.f_convertir_moneda(2, 1, t.importe_usd, v_fecha_mov, 'O', 2),--t.importe_bs,
    --Fin #48
    t.importe_usd,
    t.importe_ufv,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.importe_usd, 0) > 0
    OR COALESCE(t.importe_ufv, 0) > 0
    OR COALESCE(t.importe_bs, 0) > 0) --#48
    AND COALESCE(t.tipo, '') <> 'af_almacen'; --#66: solo para caso activos fijos

    --Inicio #66
    ---------------------------------------------------------------------------
    --GENERACIÓN DE COMPROBANTE CASO ALMACENES: Inserción de las transacciones
    ---------------------------------------------------------------------------
    --Obtención del tipo de cambio en la moneda principal de los movimientos especiales
    v_tipo_cambio = COALESCE(param.f_get_tipo_cambio_v2(v_id_moneda_bs, v_id_moneda, now()::date, 'O'), 6.96);
    v_rec_rel_cont = conta.f_get_config_relacion_contable
                    (
                        'AJT_AITB_DEBE',
                        v_id_gestion --p_id_gestion
                    );

    --DEBE AF
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    t.id_partida_dest,
    v_id_centro_costo,
    'activo',
    t.id_cuenta_dest,
    v_id_int_comprobante,
    t.importe_bs - (t.importe_bs - (t.importe_usd * v_tipo_cambio)),
    t.importe_bs - (t.importe_bs - (t.importe_usd * v_tipo_cambio)),
    t.importe_usd,
    t.importe_ufv,
    t.importe_bs - (t.importe_bs - (t.importe_usd * v_tipo_cambio)),
    t.importe_bs - (t.importe_bs - (t.importe_usd * v_tipo_cambio)),
    t.importe_usd,
    t.importe_ufv,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.importe_bs, 0) > 0
    OR COALESCE(t.importe_usd, 0) > 0
    OR COALESCE(t.importe_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') = 'af_almacen';

    --DEBE AF BS DIF ACT
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa --#21 adición de columna para la glosa
    )
    SELECT
    v_rec_rel_cont.ps_id_partida,
    v_id_centro_costo,
    'activo',
    v_rec_rel_cont.ps_id_cuenta,
    v_id_int_comprobante,
    t.importe_bs - (t.importe_usd * v_tipo_cambio),
    t.importe_bs - (t.importe_usd * v_tipo_cambio),
    0,
    0,
    t.importe_bs - (t.importe_usd * v_tipo_cambio),
    t.importe_bs - (t.importe_usd * v_tipo_cambio),
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.importe_bs, 0) > 0
    OR COALESCE(t.importe_usd, 0) > 0
    OR COALESCE(t.importe_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') = 'af_almacen';

    --DEBE DEPACUM
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    t.id_partida_dep_acum,
    v_id_centro_costo,
    'activo',
    t.id_cuenta_dep_acum,
    v_id_int_comprobante,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.depreciacion_acum_bs, 0) > 0
    OR COALESCE(t.depreciacion_acum_usd, 0) > 0
    OR COALESCE(t.depreciacion_acum_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') = 'af_almacen';

    --HABER AF
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    t.id_partida,
    v_id_centro_costo,
    'activo',
    t.id_cuenta,
    v_id_int_comprobante,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    t.importe_bs,
    t.importe_bs,
    t.importe_usd,
    t.importe_ufv,
    t.importe_bs,
    t.importe_bs,
    t.importe_usd,
    t.importe_ufv,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.importe_bs, 0) > 0
    OR COALESCE(t.importe_usd, 0) > 0
    OR COALESCE(t.importe_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') = 'af_almacen';

    --HABER DEP ACUM
    INSERT INTO conta.tint_transaccion
    (
        id_partida,
        id_centro_costo,
        estado_reg,
        id_cuenta,
        id_int_comprobante,
        importe_debe,
        importe_debe_mb,
        importe_debe_mt,
        importe_debe_ma,
        importe_gasto,
        importe_gasto_mb,
        importe_gasto_mt,
        importe_gasto_ma,
        importe_haber,
        importe_haber_mb,
        importe_haber_mt,
        importe_haber_ma,
        importe_recurso,
        importe_recurso_mb,
        importe_recurso_mt,
        importe_recurso_ma,
        id_usuario_reg,
        fecha_reg,
        glosa
    )
    SELECT
    v_rec_rel_cont1.ps_id_partida,
    v_rec_rel_cont1.ps_id_centro_costo,
    'activo',
    v_rec_rel_cont1.ps_id_cuenta,
    v_id_int_comprobante,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_bs,
    t.depreciacion_acum_usd,
    t.depreciacion_acum_ufv,
    p_id_usuario,
    now(),
    t.glosa
    FROM tt_transaccion t
    WHERE (COALESCE(t.depreciacion_acum_bs, 0) > 0
    OR COALESCE(t.depreciacion_acum_usd, 0) > 0
    OR COALESCE(t.depreciacion_acum_ufv, 0) > 0)
    AND COALESCE(t.tipo, '') = 'af_almacen';
    --Fin #66

    -------------------------------------------------
    --Actualizar el ID comprobante en el Movimiento
    -------------------------------------------------
    SELECT COALESCE(COUNT(1), 0)
    INTO v_cantidad
    FROM conta.tint_transaccion
    WHERE id_int_comprobante = v_id_int_comprobante;

    IF v_cantidad > 0 THEN
        v_resp = 'hecho_cbte';
    ELSE
        --DELETE FROM conta.tint_comprobante WHERE id_int_comprobante = v_id_int_comprobante;
        v_resp = 'hecho';
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
SECURITY INVOKER;