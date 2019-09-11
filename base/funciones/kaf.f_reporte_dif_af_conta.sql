CREATE OR REPLACE FUNCTION kaf.f_reporte_dif_af_conta (
    p_administrador INTEGER,
    p_id_usuario INTEGER,
    p_tabla VARCHAR,
    p_transaccion VARCHAR
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_reporte_dif_af_conta
 DESCRIPCION:   Reporte para identificar diferencias en saldos contables obteniendo la información de Activos Fijos y de Contabilidad
 AUTOR:         RCM
 FECHA:         29/07/2019
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #23    KAF       ETR           29/07/2019  RCM         Creación del archivo
***************************************************************************
*/
DECLARE

    v_nombre_funcion   VARCHAR;
    v_consulta         VARCHAR;
    v_parametros       RECORD;
    v_respuesta        VARCHAR;

BEGIN

    --Inicialización de variables
    v_nombre_funcion = 'kaf.f_reporte_dif_af_conta';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_REPDIFAFCT_SEL'
     #DESCRIPCION:  Reporte diferencia Activos Fijos Contabilidad
     #AUTOR:        RCM
     #FECHA:        30/07/2019
    ***********************************/
    IF (p_transaccion = 'SKA_REPDIFAFCT_SEL') THEN

        BEGIN

            --OBTENCIÓN DEL DETALLE DE DEPRECIACIÓN A UNA FECHA
            /*WITH tdetalle_dep AS (
                SELECT
                cuenta_activo,
                cuenta_dep_acum,
                cuenta_deprec,
                cuenta_dep_acum_dos,
                SUM(monto_actualiz) AS monto_actualiz,
                SUM(depreciacion) AS depreciacion,
                SUM(depreciacion_per) AS depreciacion_per,
                SUM(depreciacion_acum) AS depreciacion_acum
                FROM pxp.f_intermediario_sel
                (
                    p_id_usuario,
                    NULL,
                    NULL::VARCHAR,
                    'gau0s6qa8lo8kl2r11riers2j2',
                    0,
                    '127.0.0.1',
                    '99:99:99:99:99:99',
                    'kaf.f_reportes_af',
                    'SKA_RDEPREC_SEL',
                    NULL,
                    NULL,
                    array ['filtro',
                    'ordenacion', 'dir_ordenacion', 'puntero', 'cantidad', '_id_usuario_ai',
                    '_nombre_usuario_ai', 'tipo_salida', 'fecha_hasta', 'id_moneda', 'af_deprec'
                    ],
                    array [E' 0 = 0 ',
                    E'codigo ASC', E' ', E'0', E'100000', E'NULL', E'NULL', E'grid',
                    v_parametros.fecha,
                    v_parametros.id_moneda,
                    E'detalle'],
                    array ['VARCHAR', 'VARCHAR', 'VARCHAR', 'INTEGER',
                    'INTEGER', 'int4', 'VARCHAR', 'VARCHAR', 'DATE', 'INTEGER', 'VARCHAR'],
                    FALSE,
                    'VARCHAR',
                    NULL
                ) AS (
                    numero                      BIGINT,  codigo                              VARCHAR, codigo_ant             VARCHAR,
                    denominacion                VARCHAR, fecha_ini_dep                       DATE,    cantidad_af            INTEGER,
                    desc_unidad_medida          VARCHAR, codigo_tcc                          VARCHAR, nro_serie              VARCHAR,
                    desc_ubicacion              VARCHAR, responsable                         TEXT,    monto_vigente_orig_100 NUMERIC,
                    monto_vigente_orig          NUMERIC, af_altas                            NUMERIC, af_bajas               NUMERIC,
                    af_traspasos                NUMERIC, inc_actualiz                        NUMERIC, monto_actualiz         NUMERIC,
                    vida_util_orig              INTEGER, vida_util                           INTEGER, vida_util_usada        INTEGER,
                    depreciacion_acum_gest_ant  NUMERIC, depreciacion_acum_actualiz_gest_ant NUMERIC, depreciacion           NUMERIC,
                    depreciacion_acum_bajas     NUMERIC, depreciacion_acum_traspasos         NUMERIC, depreciacion_acum      NUMERIC,
                    depreciacion_per            NUMERIC, monto_vigente                       NUMERIC, cuenta_activo          TEXT,
                    cuenta_dep_acum             TEXT,    cuenta_deprec                       TEXT,    desc_grupo             VARCHAR,
                    desc_grupo_clasif           VARCHAR, cuenta_dep_acum_dos                 TEXT,    bk_codigo              VARCHAR,
                    cc1                         VARCHAR, dep_mes_cc1                         NUMERIC, cc2                    VARCHAR,
                    dep_mes_cc2                 NUMERIC, cc3                                 VARCHAR, dep_mes_cc3            NUMERIC,
                    cc4                         VARCHAR, dep_mes_cc4                         NUMERIC, cc5                    VARCHAR,
                    dep_mes_cc5                 NUMERIC, cc6                                 VARCHAR, dep_mes_cc6            NUMERIC,
                    cc7                         VARCHAR, dep_mes_cc7                         NUMERIC, cc8                    VARCHAR,
                    dep_mes_cc8                 NUMERIC, cc9                                 VARCHAR, dep_mes_cc9            NUMERIC,
                    cc10                        VARCHAR, dep_mes_cc10                        NUMERIC, id_activo_fijo         INTEGER,
                    nivel                       INTEGER, orden                               BIGINT,  tipo                   VARCHAR
                )
                GROUP BY cuenta_activo, cuenta_dep_acum, cuenta_deprec, cuenta_dep_acum_dos
            ), tdetalle_conta AS(
                WITH tcuenta_activo AS(
                    SELECT DISTINCT
                    rc.id_cuenta, cu.nro_cuenta, cu.nombre_cuenta
                    FROM conta.ttabla_relacion_contable tb
                    JOIN conta.ttipo_relacion_contable trc
                    ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                    JOIN conta.trelacion_contable rc
                    ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                    INNER JOIN param.tgestion ges
                    ON ges.id_gestion = rc.id_gestion
                    AND DATE_TRUNC('year', ges.fecha_ini) = DATE_TRUNC('year', v_parametros.fecha)
                    INNER JOIN conta.tcuenta cu
                    on cu.id_cuenta = rc.id_cuenta
                    WHERE tb.esquema = 'KAF'
                    AND tb.tabla = 'tclasificacion'
                    AND trc.codigo_tipo_relacion IN ('ALTAAF', 'DEPACCLAS', 'DEPCLAS')
                )
                SELECT
                c.nro_cuenta || '-' || c.nombre_cuenta AS desc_cuenta,
                ABS(SUM(tr.importe_debe_mb) - SUM(tr.importe_haber_mb)) AS importe
                FROM conta.tint_transaccion tr
                INNER JOIN conta.tint_comprobante cb
                ON cb.id_int_comprobante = tr.id_int_comprobante
                INNER JOIN tcuenta_activo c
                ON c.id_cuenta = tr.id_cuenta
                WHERE cb.estado_reg = 'validado'
                AND cb.fecha BETWEEN DATE_TRUNC('year', v_parametros.fecha) and v_parametros.fecha
                GROUP BY c.nro_cuenta, c.nombre_cuenta
            )
            SELECT
            dc.desc_cuenta, af.importe as saldo_af, dc.importe as saldo_conta,
            af.importe - dc.importe as diferencia
            FROM (
                SELECT
                cuenta_activo AS desc_cuenta, SUM(monto_actualiz) AS importe
                FROM tdetalle_dep
                WHERE cuenta_activo IS NOT NULL
                GROUP BY cuenta_activo
                UNION
                SELECT distinct
                cuenta_dep_acum AS desc_cuenta, SUM(depreciacion_acum) AS importe
                FROM tdetalle_dep
                WHERE cuenta_dep_acum IS NOT NULL
                GROUP BY cuenta_dep_acum
                UNION
                SELECT distinct
                cuenta_deprec AS desc_cuenta, depreciacion_per AS importe
                FROM tdetalle_dep
                WHERE cuenta_deprec IS NOT NULL
                AND cuenta_dep_acum_dos IS NULL
                UNION
                SELECT distinct
                cuenta_dep_acum_dos AS desc_cuenta, depreciacion_per AS importe
                FROM tdetalle_dep
                WHERE cuenta_dep_acum_dos IS NOT NULL
            ) af
            INNER JOIN tdetalle_conta dc
            ON dc.desc_cuenta = af.desc_cuenta
            ORDER BY 1;*/

            v_consulta = '
            WITH tdetalle_dep AS (
                SELECT
                cuenta_activo,
                cuenta_dep_acum,
                cuenta_deprec,
                cuenta_dep_acum_dos,
                SUM(monto_actualiz) AS monto_actualiz,
                SUM(depreciacion) AS depreciacion,
                SUM(depreciacion_per) AS depreciacion_per,
                SUM(depreciacion_acum) AS depreciacion_acum
                FROM pxp.f_intermediario_sel
                (
                    p_id_usuario,
                    NULL,
                    NULL::VARCHAR,
                    ''gau0s6qa8lo8kl2r11riers2j2'',
                    0,
                    ''127.0.0.1'',
                    ''99:99:99:99:99:99'',
                    ''kaf.f_reportes_af'',
                    ''SKA_RDEPREC_SEL'',
                    NULL,
                    NULL,
                    array [''filtro'',
                    ''ordenacion'', ''dir_ordenacion'', ''puntero'', ''cantidad'', ''_id_usuario_ai'',
                    ''_nombre_usuario_ai'', ''tipo_salida'', ''fecha_hasta'', ''id_moneda'', ''af_deprec''
                    ],
                    array [E'' 0 = 0 '',
                    E''codigo ASC'', E'' '', E''0'', E''100000'', E''NULL'', E''NULL'', E''grid'',''' ||
                    v_parametros.fecha || ''',' || v_parametros.id_moneda || ',
                    E''detalle''],
                    array [''VARCHAR'', ''VARCHAR'', ''VARCHAR'', ''INTEGER'',
                    ''INTEGER'', ''int4'', ''VARCHAR'', ''VARCHAR'', ''DATE'', ''INTEGER'', ''VARCHAR''],
                    FALSE,
                    ''VARCHAR'',
                    NULL
                ) AS (
                    numero                      BIGINT,  codigo                              VARCHAR, codigo_ant             VARCHAR,
                    denominacion                VARCHAR, fecha_ini_dep                       DATE,    cantidad_af            INTEGER,
                    desc_unidad_medida          VARCHAR, codigo_tcc                          VARCHAR, nro_serie              VARCHAR,
                    desc_ubicacion              VARCHAR, responsable                         TEXT,    monto_vigente_orig_100 NUMERIC,
                    monto_vigente_orig          NUMERIC, af_altas                            NUMERIC, af_bajas               NUMERIC,
                    af_traspasos                NUMERIC, inc_actualiz                        NUMERIC, monto_actualiz         NUMERIC,
                    vida_util_orig              INTEGER, vida_util                           INTEGER, vida_util_usada        INTEGER,
                    depreciacion_acum_gest_ant  NUMERIC, depreciacion_acum_actualiz_gest_ant NUMERIC, depreciacion           NUMERIC,
                    depreciacion_acum_bajas     NUMERIC, depreciacion_acum_traspasos         NUMERIC, depreciacion_acum      NUMERIC,
                    depreciacion_per            NUMERIC, monto_vigente                       NUMERIC, cuenta_activo          TEXT,
                    cuenta_dep_acum             TEXT,    cuenta_deprec                       TEXT,    desc_grupo             VARCHAR,
                    desc_grupo_clasif           VARCHAR, cuenta_dep_acum_dos                 TEXT,    bk_codigo              VARCHAR,
                    cc1                         VARCHAR, dep_mes_cc1                         NUMERIC, cc2                    VARCHAR,
                    dep_mes_cc2                 NUMERIC, cc3                                 VARCHAR, dep_mes_cc3            NUMERIC,
                    cc4                         VARCHAR, dep_mes_cc4                         NUMERIC, cc5                    VARCHAR,
                    dep_mes_cc5                 NUMERIC, cc6                                 VARCHAR, dep_mes_cc6            NUMERIC,
                    cc7                         VARCHAR, dep_mes_cc7                         NUMERIC, cc8                    VARCHAR,
                    dep_mes_cc8                 NUMERIC, cc9                                 VARCHAR, dep_mes_cc9            NUMERIC,
                    cc10                        VARCHAR, dep_mes_cc10                        NUMERIC, id_activo_fijo         INTEGER,
                    nivel                       INTEGER, orden                               BIGINT,  tipo                   VARCHAR
                )
                GROUP BY cuenta_activo, cuenta_dep_acum, cuenta_deprec, cuenta_dep_acum_dos
            ), tdetalle_conta AS(
                WITH tcuenta_activo AS(
                    SELECT DISTINCT
                    rc.id_cuenta, cu.nro_cuenta, cu.nombre_cuenta
                    FROM conta.ttabla_relacion_contable tb
                    JOIN conta.ttipo_relacion_contable trc
                    ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                    JOIN conta.trelacion_contable rc
                    ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                    INNER JOIN param.tgestion ges
                    ON ges.id_gestion = rc.id_gestion
                    AND DATE_TRUNC(''year'', ges.fecha_ini) = DATE_TRUNC(''year'', v_parametros.fecha)
                    INNER JOIN conta.tcuenta cu
                    on cu.id_cuenta = rc.id_cuenta
                    WHERE tb.esquema = ''KAF''
                    AND tb.tabla = ''tclasificacion''
                    AND trc.codigo_tipo_relacion IN (''ALTAAF'', ''DEPACCLAS'', ''DEPCLAS'')
                )
                SELECT
                c.nro_cuenta || ''-'' || c.nombre_cuenta AS desc_cuenta,
                ABS(SUM(tr.importe_debe_mb) - SUM(tr.importe_haber_mb)) AS importe
                FROM conta.tint_transaccion tr
                INNER JOIN conta.tint_comprobante cb
                ON cb.id_int_comprobante = tr.id_int_comprobante
                INNER JOIN tcuenta_activo c
                ON c.id_cuenta = tr.id_cuenta
                WHERE cb.estado_reg = ''validado''
                AND cb.fecha BETWEEN DATE_TRUNC(''year'', v_parametros.fecha) and v_parametros.fecha
                GROUP BY c.nro_cuenta, c.nombre_cuenta
            )
            SELECT
            dc.desc_cuenta, af.importe as saldo_af, dc.importe as saldo_conta,
            af.importe - dc.importe as diferencia
            FROM (
                SELECT
                cuenta_activo AS desc_cuenta, SUM(monto_actualiz) AS importe
                FROM tdetalle_dep
                WHERE cuenta_activo IS NOT NULL
                GROUP BY cuenta_activo
                UNION
                SELECT distinct
                cuenta_dep_acum AS desc_cuenta, SUM(depreciacion_acum) AS importe
                FROM tdetalle_dep
                WHERE cuenta_dep_acum IS NOT NULL
                GROUP BY cuenta_dep_acum
                UNION
                SELECT distinct
                cuenta_deprec AS desc_cuenta, depreciacion_per AS importe
                FROM tdetalle_dep
                WHERE cuenta_deprec IS NOT NULL
                AND cuenta_dep_acum_dos IS NULL
                UNION
                SELECT distinct
                cuenta_dep_acum_dos AS desc_cuenta, depreciacion_per AS importe
                FROM tdetalle_dep
                WHERE cuenta_dep_acum_dos IS NOT NULL
            ) af
            INNER JOIN tdetalle_conta dc
            ON dc.desc_cuenta = af.desc_cuenta
            ORDER BY 1';

            --RESPUESTA
            RETURN v_consulta;

        END;

    ELSE

        RAISE EXCEPTION 'Transacción inexistente';

    END IF;

EXCEPTION

    WHEN OTHERS THEN

        v_respuesta = '';
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'mensaje', SQLERRM);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'codigo_error', SQLSTATE);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'procedimientos', v_nombre_funcion);

        RAISE EXCEPTION '%', v_respuesta;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;