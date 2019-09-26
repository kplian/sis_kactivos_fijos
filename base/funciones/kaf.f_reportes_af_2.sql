CREATE OR REPLACE FUNCTION kaf.f_reportes_af_2 (
  p_administrador INTEGER,
  p_id_usuario INTEGER,
  p_tabla VARCHAR,
  p_transaccion VARCHAR
)
RETURNS VARCHAR AS
$body$
/***************************************************************************
 SISTEMA:        Activos Fijos
 FUNCION:        kaf.f_reportes_af_2
 DESCRIPCION:    Funcion que devuelve conjunto de datos para reportes de activos fijos
 AUTOR:          RCM
 FECHA:          25/06/2018
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 0      KAF       ETR           25/06/2018  RCM         Creación del archivo
 #20    KAF       ETR           22/07/2019  RCM         Reporte Activos Fijos con Distribución de Valores
 #25    KAF       ETR           05/08/2019  RCM         Reporte 2 Form. 605
 #24    KAF       ETR           12/08/2019  RCM         Reporte 1 Inventario Detallado por Grupo Contable
 #17    KAF       ETR           14/08/2019  RCM         Reporte 3 Impuestos a la Propiedad e Inmuebles
 #19    KAF       ETR           14/08/2019  RCM         Reporte 4 Impuestos de Vehículos
 #26    KAF       ETR           22/08/2019  RCM         Reporte 7 Altas por Origen
 #23    KAF       ETR           23/08/2019  RCM         Reporte 8 Comparación Activos Fijos y Contabilidad
 #29    KAF       ETR           23/08/2019  RCM         Corrección reportes
 #31    KAF       ETR           17/09/2019  RCM         Modificación llamada a detalle depreciación por adición en el reporte detalle depreciación de las columnas de anexos 1 (cbte. 2) y 2 (cbte. 4)
****************************************************************************/
DECLARE

    v_nombre_funcion   varchar;
    v_consulta         varchar;
    v_parametros       record;
    v_respuesta        varchar;
    v_id_items         varchar[];
    v_where            varchar;
    v_ids              varchar;
    v_fecha            date;
    v_ids_depto        varchar;
    v_sql              varchar;
    v_aux              varchar;
    v_lugar            varchar = '';
    v_filtro           varchar;
    v_record           record;
    v_desc_nombre      varchar;
    v_caract_invalidos varchar;
    --Inicio #23
    v_id_moneda_base   integer;
    v_id_moneda_dep    integer;
    v_id_int_cbte      integer;
    v_sw_insert        boolean;
    v_id_estado_wf     integer;
    --Fin #23
    --Inicio #25
    v_fecha_dep        date;
    v_max_fecha        date;
    --Fin #25

BEGIN

    v_nombre_funcion = 'kaf.f_reportes_af_2';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_FRM605_SEL'
     #DESCRIPCION:  Reporte Formulario 605 para impuestos
     #AUTOR:        RCM
     #FECHA:        25/06/2018
    ***********************************/
    --Inicio #25
    IF (p_transaccion = 'SKA_FRM605_SEL') then

        BEGIN

            v_caract_invalidos = pxp.f_get_variable_global('kaf_caracteres_no_validos_form605');
            v_fecha = '01/01/' || v_parametros.gestion::varchar;

            v_consulta = 'WITH tult_dep AS (
                            SELECT
                            afv.id_activo_fijo,
                            mdep.id_moneda,
                            MAX(mdep.fecha) AS fecha_max
                            FROM kaf.tmovimiento_af_dep mdep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                            WHERE date_trunc(''year'',mdep.fecha) = date_trunc(''year'', ''' || v_fecha ||'''::date)
                            GROUP BY afv.id_activo_fijo, mdep.id_moneda
                        ), tclasif_rel AS (
                            SELECT
                            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                            ((''{'' || kaf.f_get_id_clasificaciones(rc.id_tabla, ''hijos'')) || ''}'')::INTEGER [ ] AS nodos
                            FROM conta.ttabla_relacion_contable tb
                            JOIN conta.ttipo_relacion_contable trc
                            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                            JOIN conta.trelacion_contable rc
                            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                            WHERE tb.esquema::text = ''KAF''
                            AND tb.tabla::text = ''tclasificacion''
                            AND trc.codigo_tipo_relacion in (''ALTAAF'')
                        ), tpri_dep AS (
                            SELECT
                            afv.id_activo_fijo,
                            mdep.id_moneda,
                            MIN(mdep.fecha) AS fecha_min
                            FROM kaf.tmovimiento_af_dep mdep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                            GROUP BY afv.id_activo_fijo, mdep.id_moneda
                        )
                        SELECT
                        afij.codigo, cue.nro_cuenta,
                        (pxp.f_limpiar_cadena(afij.denominacion, ''' || v_caract_invalidos || '''))::varchar as denominacion,
                        ume.codigo as unidad_medida,
                        afij.cantidad_af,
                        CASE
                            WHEN (date_trunc(''year'',afv.fecha_ini_dep) = date_trunc(''year'', ''' || v_fecha ||'''::date)) AND afij.fecha_baja IS NULL THEN
                                ROUND(mdep.monto_actualiz - mdep.depreciacion_acum, 2)
                            ELSE 0
                        END AS inventario_final,
                        CASE
                            WHEN (date_trunc(''year'',afv.fecha_ini_dep) = date_trunc(''year'', ''' || v_fecha ||'''::date)) AND afij.fecha_baja IS NULL THEN
                                0
                            ELSE ROUND(mdep.monto_actualiz /*- mdep.depreciacion_acum*/, 2) --#29: se solicita que en caso de bajas muestre el monto actualizado únicamente
                        END AS inventario_bajas,
                        (pxp.f_limpiar_cadena(afij.denominacion, ''' || v_caract_invalidos || ''') || '', '' || ume.codigo)::varchar as nombre_con_unidad,
                        mon.codigo as codigo_moneda,
                        mon.moneda as desc_moneda
                        FROM kaf.tactivo_fijo afij
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo = afij.id_activo_fijo
                        INNER JOIN tult_dep ud
                        ON ud.id_activo_fijo = afv.id_activo_fijo
                        AND ud.id_moneda = afv.id_moneda
                        INNER JOIN kaf.tmovimiento_af_dep mdep
                        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
                        AND mdep.fecha = ud.fecha_max
                        INNER JOIN tclasif_rel clr
                        ON afij.id_clasificacion = ANY(clr.nodos)
                        AND clr.codigo = ''ALTAAF''
                        INNER JOIN conta.trelacion_contable rc_af
                        ON rc_af.id_tabla = clr.id_clasificacion
                        AND rc_af.estado_reg = ''activo''
                        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
                        AND rc_af.id_gestion = (
                            CASE
                                WHEN afij.fecha_ini_dep < ''01-01-2019''::date then (SELECT po_id_gestion FROM param.f_get_periodo_gestion (''01-01-2019''::date))
                                ELSE (SELECT po_id_gestion FROM param.f_get_periodo_gestion (afij.fecha_ini_dep))
                            END
                        )
                        INNER JOIN conta.tcuenta cue
                        ON cue.id_cuenta = rc_af.id_cuenta
                        LEFT JOIN param.tunidad_medida ume
                        ON ume.id_unidad_medida = afij.id_unidad_medida
                        INNER JOIN tpri_dep pd
                        ON pd.id_activo_fijo = afv.id_activo_fijo
                        AND pd.id_moneda = afv.id_moneda
                        INNER JOIN param.tmoneda mon
                        ON mon.id_moneda = afv.id_moneda
                        WHERE afv.id_moneda = ' || v_parametros.id_moneda || '
                        AND (
                        (date_trunc(''year'', pd.fecha_min) = date_trunc(''year'', ''' || v_fecha || '''::date) AND afij.fecha_baja IS NULL)
                        OR
                        (date_trunc(''year'', afij.fecha_baja) = date_trunc(''year'', ''' || v_fecha || '''::date))
                        ) ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' AND ' || v_parametros.filtro;
                v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' limit ' || coalesce(v_parametros.cantidad, 9999999) || ' offset ' || coalesce(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY afij.codigo, afij.denominacion';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_FRM605_CONT'
     #DESCRIPCION:  Reporte Formulario 605 para impuestos
     #AUTOR:        RCM
     #FECHA:        25/06/2018
    ***********************************/

    ELSIF(p_transaccion = 'SKA_FRM605_CONT') then

        BEGIN

            v_caract_invalidos = pxp.f_get_variable_global('kaf_caracteres_no_validos_form605');
            v_fecha = '01/01/' || v_parametros.gestion::varchar;

            v_consulta = 'WITH tult_dep AS (
                            SELECT
                            afv.id_activo_fijo,
                            mdep.id_moneda,
                            MAX(mdep.fecha) AS fecha_max
                            FROM kaf.tmovimiento_af_dep mdep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                            WHERE date_trunc(''year'',mdep.fecha) = date_trunc(''year'', ''' || v_fecha ||'''::date)
                            GROUP BY afv.id_activo_fijo, mdep.id_moneda
                        ), tclasif_rel AS (
                            SELECT
                            rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                            ((''{'' || kaf.f_get_id_clasificaciones(rc.id_tabla, ''hijos'')) || ''}'')::INTEGER [ ] AS nodos
                            FROM conta.ttabla_relacion_contable tb
                            JOIN conta.ttipo_relacion_contable trc
                            ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                            JOIN conta.trelacion_contable rc
                            ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                            WHERE tb.esquema::text = ''KAF''
                            AND tb.tabla::text = ''tclasificacion''
                            AND trc.codigo_tipo_relacion in (''ALTAAF'')
                        ), tpri_dep AS (
                            SELECT
                            afv.id_activo_fijo,
                            mdep.id_moneda,
                            MIN(mdep.fecha) AS fecha_min
                            FROM kaf.tmovimiento_af_dep mdep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                            GROUP BY afv.id_activo_fijo, mdep.id_moneda
                        )
                        SELECT
                        COUNT(1) as total
                        FROM kaf.tactivo_fijo afij
                        INNER JOIN kaf.tactivo_fijo_valores afv
                        ON afv.id_activo_fijo = afij.id_activo_fijo
                        INNER JOIN tult_dep ud
                        ON ud.id_activo_fijo = afv.id_activo_fijo
                        AND ud.id_moneda = afv.id_moneda
                        INNER JOIN kaf.tmovimiento_af_dep mdep
                        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
                        AND mdep.fecha = ud.fecha_max
                        INNER JOIN tclasif_rel clr
                        ON afij.id_clasificacion = ANY(clr.nodos)
                        AND clr.codigo = ''ALTAAF''
                        INNER JOIN conta.trelacion_contable rc_af
                        ON rc_af.id_tabla = clr.id_clasificacion
                        AND rc_af.estado_reg = ''activo''
                        AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
                        AND rc_af.id_gestion = (
                            CASE
                                WHEN afij.fecha_ini_dep < ''01-01-2019''::date then (SELECT po_id_gestion FROM param.f_get_periodo_gestion (''01-01-2019''::date))
                                ELSE (SELECT po_id_gestion FROM param.f_get_periodo_gestion (afij.fecha_ini_dep))
                            END
                        )
                        INNER JOIN conta.tcuenta cue
                        ON cue.id_cuenta = rc_af.id_cuenta
                        LEFT JOIN param.tunidad_medida ume
                        ON ume.id_unidad_medida = afij.id_unidad_medida
                        INNER JOIN tpri_dep pd
                        ON pd.id_activo_fijo = afv.id_activo_fijo
                        AND pd.id_moneda = afv.id_moneda
                        INNER JOIN param.tmoneda mon
                        ON mon.id_moneda = afv.id_moneda
                        WHERE afv.id_moneda = ' || v_parametros.id_moneda || '
                        AND (
                        (date_trunc(''year'',pd.fecha_min) = date_trunc(''year'', ''' || v_fecha || '''::date) AND afij.fecha_baja IS NULL)
                        OR
                        (date_trunc(''year'',afij.fecha_baja) = date_trunc(''year'', ''' || v_fecha || '''::date))
                        ) ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' AND ' || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;
    --Fin #25

    /*********************************
     #TRANSACCION:  'SKA_LISAF_SEL'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
    ELSIF(p_transaccion = 'SKA_LISAF_SEL') THEN

        BEGIN

              v_consulta = 'select
                          afij.codigo,
                          afij.codigo_ant,
                          afij.denominacion,
                          cla.descripcion,
                          afij.fecha_compra,
                          afij.fecha_ini_dep,
                          afij.vida_util_original,
                          afij.cantidad_af,
                          um.codigo as desc_unidad_medida,
                          afij.estado,
                          afij.monto_compra_orig,
                          cc.codigo_tcc,
                          fun.desc_funcionario2,
                          afij.fecha_asignacion,
                          ubi.codigo as desc_ubicacion
                          from kaf.tactivo_fijo afij
                          inner join param.tunidad_medida um
                          on um.id_unidad_medida = afij.id_unidad_medida
                          inner join param.tmoneda mon
                          on mon.id_moneda = afij.id_moneda_orig
                          left join param.vcentro_costo cc
                          on cc.id_centro_costo = afij.id_centro_costo
                          inner join kaf.tclasificacion cla
                          on cla.id_clasificacion = afij.id_clasificacion
                          left join orga.vfuncionario fun
                          on fun.id_funcionario = afij.id_funcionario
                          left join kaf.tubicacion ubi
                          on ubi.id_ubicacion = afij.id_ubicacion ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' where ' || v_parametros.filtro;
                v_consulta = v_consulta || ' order by ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' limit ' || coalesce(v_parametros.cantidad,9999999) || ' offset ' || coalesce(v_parametros.puntero,0);
            ELSE
                v_consulta = v_consulta || ' order by afij.codigo';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_LISAF_CONT'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
    ELSIF(p_transaccion='SKA_LISAF_CONT') THEN

        BEGIN

            v_consulta = 'select
                          count(1) as total
                          from kaf.tactivo_fijo afij
                          inner join param.tunidad_medida um
                          on um.id_unidad_medida = afij.id_unidad_medida
                          inner join param.tmoneda mon
                          on mon.id_moneda = afij.id_moneda_orig
                          left join param.vcentro_costo cc
                          on cc.id_centro_costo = afij.id_centro_costo
                          inner join kaf.tclasificacion cla
                          on cla.id_clasificacion = afij.id_clasificacion
                          left join orga.vfuncionario fun
                          on fun.id_funcionario = afij.id_funcionario
                          left join kaf.tubicacion ubi
                          on ubi.id_ubicacion = afij.id_ubicacion ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' where ' || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;

    --Inicio #20
    /*********************************
     #TRANSACCION:  'SKA_REAFDVCAB_SEL'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
    ELSIF(p_transaccion = 'SKA_REAFDVCAB_SEL') THEN

        BEGIN

              v_consulta = 'SELECT
                            maf.id_movimiento_af, af.id_activo_fijo, mov.id_movimiento, mdep1.id_moneda, maf.id_movimiento_af_dep,
                            af.codigo, af.denominacion,
                            mov.num_tramite, mov.fecha_mov, mov.estado,
                            ROUND(mdep1.monto_actualiz, 2) AS monto_actualiz, ROUND(mdep1.depreciacion_acum, 2) AS depreciacion_acum
                            FROM kaf.tmovimiento_af maf
                            INNER JOIN kaf.tmovimiento mov
                            ON mov.id_movimiento = maf.id_movimiento
                            INNER JOIN kaf.tactivo_fijo af
                            ON af.id_activo_fijo = maf.id_activo_fijo
                            INNER JOIN kaf.tmovimiento_af_dep mdep
                            ON mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo = maf.id_activo_fijo
                            INNER JOIN kaf.tmovimiento_af_dep mdep1
                            ON mdep1.id_activo_fijo_valor = afv.id_activo_fijo_valor
                            AND mdep1.fecha = mdep.fecha
                            WHERE mov.id_cat_movimiento IN (SELECT id_catalogo FROM param.tcatalogo WHERE codigo = ''dval'')
                            AND ';

            --Definicion de la respuesta
            v_consulta = v_consulta || v_parametros.filtro;
            v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || v_parametros.cantidad || ' OFFSET ' || v_parametros.puntero;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_REAFDVCAB_CONT'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/

    ELSIF(p_transaccion = 'SKA_REAFDVCAB_CONT') THEN

        BEGIN

            v_consulta = 'SELECT COUNT(1)
                            FROM kaf.tmovimiento_af maf
                            INNER JOIN kaf.tmovimiento mov
                            ON mov.id_movimiento = maf.id_movimiento
                            INNER JOIN kaf.tactivo_fijo af
                            ON af.id_activo_fijo = maf.id_activo_fijo
                            INNER JOIN kaf.tmovimiento_af_dep mdep
                            ON mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                            INNER JOIN kaf.tactivo_fijo_valores afv
                            ON afv.id_activo_fijo = maf.id_activo_fijo
                            INNER JOIN kaf.tmovimiento_af_dep mdep1
                            ON mdep1.id_activo_fijo_valor = afv.id_activo_fijo_valor
                            AND mdep1.fecha = mdep.fecha
                            WHERE mov.id_cat_movimiento IN (SELECT id_catalogo FROM param.tcatalogo WHERE codigo = ''dval'')
                            AND ';

            v_consulta = v_consulta || v_parametros.filtro;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_REAFDVDET_SEL'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/
    ELSIF(p_transaccion = 'SKA_REAFDVDET_SEL') THEN

        BEGIN

              v_consulta = 'SELECT
                          mov.fecha_mov,
                          afij.codigo as codigo_activo_origen,
                          afij.denominacion as denominacion_activo_origen,
                          mov.num_tramite,
                          ROUND(mdep1.monto_actualiz, 2) as monto_actualiz_orig,
                          ROUND(mdep1.depreciacion_acum, 2) as depreciacion_acum_orig,
                          mafe.tipo,
                          af1.codigo as codigo_activo_dest,
                          af1.denominacion as denominacion_activo_dest,
                          af1.estado as estado_af,
                          al.codigo as codigo_almacen,
                          al.nombre as nombre_almacen,
                          mafe.porcentaje,
                          ROUND(mdep1.monto_actualiz * mafe.porcentaje / 100, 2) as monto_actualiz,
                          ROUND(mdep1.depreciacion_acum * mafe.porcentaje / 100, 2) as depreciacion_acum,
                          mafe.id_movimiento_af_especial,
                          mafe.id_movimiento_af,
                          mdep1.id_moneda,
                          mov.glosa,
                          mov.estado,
                          mdep1.fecha
                          FROM kaf.tmovimiento_af_especial mafe
                          INNER JOIN kaf.tmovimiento_af maf
                          ON maf.id_movimiento_af = mafe.id_movimiento_af
                          INNER JOIN kaf.tmovimiento mov
                          ON mov.id_movimiento = maf.id_movimiento
                          INNER JOIN kaf.tactivo_fijo afij
                          ON afij.id_activo_fijo = maf.id_activo_fijo
                          INNER JOIN kaf.tmovimiento_af_dep mdep
                          ON mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                          INNER JOIN kaf.tactivo_fijo_valores afv
                          ON afv.id_activo_fijo = maf.id_activo_fijo
                          INNER JOIN kaf.tmovimiento_af_dep mdep1
                          ON mdep1.id_activo_fijo_valor = afv.id_activo_fijo_valor
                          AND mdep1.fecha = mdep.fecha
                          LEFT JOIN kaf.tactivo_fijo af1
                          ON af1.id_activo_fijo = mafe.id_activo_fijo
                          LEFT JOIN alm.talmacen al
                          ON al.id_almacen = mafe.id_almacen ';

            --Definicion de la respuesta
            v_consulta = v_consulta || ' WHERE ' || v_parametros.filtro;
            v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' offset ' || COALESCE(v_parametros.puntero, 0);

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_REAFDVDET_CONT'
     #DESCRIPCION:  Listado de Activos fijos
     #AUTOR:        RCM
     #FECHA:        27/06/2018
    ***********************************/

    ELSIF(p_transaccion = 'SKA_REAFDVDET_CONT') THEN

        BEGIN

            v_consulta = 'SELECT COUNT(1)
                          FROM kaf.tmovimiento_af_especial mafe
                          INNER JOIN kaf.tmovimiento_af maf
                          ON maf.id_movimiento_af = mafe.id_movimiento_af
                          INNER JOIN kaf.tmovimiento mov
                          ON mov.id_movimiento = maf.id_movimiento
                          INNER JOIN kaf.tactivo_fijo afij
                          ON afij.id_activo_fijo = maf.id_activo_fijo
                          INNER JOIN kaf.tmovimiento_af_dep mdep
                          ON mdep.id_movimiento_af_dep = maf.id_movimiento_af_dep
                          INNER JOIN kaf.tactivo_fijo_valores afv
                          ON afv.id_activo_fijo = maf.id_activo_fijo
                          INNER JOIN kaf.tmovimiento_af_dep mdep1
                          ON mdep1.id_activo_fijo_valor = afv.id_activo_fijo_valor
                          AND mdep1.fecha = mdep.fecha
                          LEFT JOIN kaf.tactivo_fijo af1
                          ON af1.id_activo_fijo = mafe.id_activo_fijo
                          LEFT JOIN alm.talmacen al
                          ON al.id_almacen = mafe.id_almacen ';

            v_consulta = v_consulta || ' WHERE ' || v_parametros.filtro;

            RETURN v_consulta;

        END;
        --Fin #20

    --Inicio #24
    /*********************************
     #TRANSACCION:  'SKA_INVDETGC_SEL'
     #DESCRIPCION:  Reporte Inventario Detallado por Grupo Contable
     #AUTOR:        RCM
     #FECHA:        12/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_INVDETGC_SEL') THEN

        BEGIN

            v_consulta = '
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                mdep.id_moneda,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                WHERE date_trunc(''month'',mdep.fecha) = date_trunc(''month'', ''' || v_parametros.fecha_hasta ||'''::date)
                GROUP BY afv.id_activo_fijo, mdep.id_moneda
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                ((''{'' || kaf.f_get_id_clasificaciones(rc.id_tabla, ''hijos'')) || ''}'')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = ''KAF''
                AND tb.tabla::text = ''tclasificacion''
                AND trc.codigo_tipo_relacion in (''ALTAAF'')
            )
            SELECT
            cue.nro_cuenta, afij.codigo, afij.fecha_ini_dep,
            afij.denominacion,
            ROUND(mdep.monto_actualiz, 2) AS monto_actualiz,
            ROUND(-1 * mdep.depreciacion_acum, 2) AS depreciacion_acum,
            ROUND(mdep.monto_actualiz,2 ) - ROUND(mdep.depreciacion_acum, 2) AS valor_actual,
            mon.codigo AS codigo_moneda,
            mon.moneda AS desc_moneda
            FROM kaf.tactivo_fijo afij
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = afij.id_activo_fijo
            INNER JOIN tult_dep ud
            ON ud.id_activo_fijo = afv.id_activo_fijo
            AND ud.id_moneda = afv.id_moneda
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            AND mdep.fecha = ud.fecha_max
            INNER JOIN tclasif_rel clr
            ON afij.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = ''ALTAAF''
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = ''activo''
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = (
                CASE
                    WHEN afij.fecha_ini_dep < ''01-01-2019''::date then (SELECT po_id_gestion FROM param.f_get_periodo_gestion (''01-01-2019''::date)) --2019 es fijo, antes de 2019 no había parametrizaciones así que tomará la de 2019
                    ELSE (SELECT po_id_gestion FROM param.f_get_periodo_gestion (afij.fecha_ini_dep))
                END
            )
            INNER JOIN conta.tcuenta cue
            ON cue.id_cuenta = rc_af.id_cuenta
            INNER JOIN param.tmoneda mon
            ON mon.id_moneda = afv.id_moneda
            WHERE afv.id_moneda = ' || v_parametros.id_moneda || '
            AND (afij.fecha_baja IS NULL OR afij.fecha_baja > ''' || v_parametros.fecha_hasta ||'''::date)';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' AND ' || v_parametros.filtro;
                v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' OFFSET ' || COALESCE(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY afij.codigo, afij.denominacion';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_INVDETGC_CONT'
     #DESCRIPCION:  Reporte Inventario Detallado por Grupo Contable
     #AUTOR:        RCM
     #FECHA:        12/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_INVDETGC_CONT') THEN

        BEGIN

            v_consulta = '
            WITH tult_dep AS (
                SELECT
                afv.id_activo_fijo,
                mdep.id_moneda,
                MAX(mdep.fecha) AS fecha_max
                FROM kaf.tmovimiento_af_dep mdep
                INNER JOIN kaf.tactivo_fijo_valores afv
                ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
                WHERE date_trunc(''month'',mdep.fecha) = date_trunc(''month'', ''' || v_parametros.fecha_hasta ||'''::date)
                GROUP BY afv.id_activo_fijo, mdep.id_moneda
            ), tclasif_rel AS (
                SELECT
                rc.id_tabla AS id_clasificacion, trc.codigo_tipo_relacion as codigo, trc.id_tipo_relacion_contable,
                ((''{'' || kaf.f_get_id_clasificaciones(rc.id_tabla, ''hijos'')) || ''}'')::integer [ ] AS nodos
                FROM conta.ttabla_relacion_contable tb
                JOIN conta.ttipo_relacion_contable trc
                ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                JOIN conta.trelacion_contable rc
                ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                WHERE tb.esquema::text = ''KAF''
                AND tb.tabla::text = ''tclasificacion''
                AND trc.codigo_tipo_relacion in (''ALTAAF'')
            )
            SELECT COUNT(1) AS total
            FROM kaf.tactivo_fijo afij
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = afij.id_activo_fijo
            INNER JOIN tult_dep ud
            ON ud.id_activo_fijo = afv.id_activo_fijo
            AND ud.id_moneda = afv.id_moneda
            INNER JOIN kaf.tmovimiento_af_dep mdep
            ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
            AND mdep.fecha = ud.fecha_max
            INNER JOIN tclasif_rel clr
            ON afij.id_clasificacion = ANY(clr.nodos)
            AND clr.codigo = ''ALTAAF''
            INNER JOIN conta.trelacion_contable rc_af
            ON rc_af.id_tabla = clr.id_clasificacion
            AND rc_af.estado_reg = ''activo''
            AND rc_af.id_tipo_relacion_contable = clr.id_tipo_relacion_contable
            AND rc_af.id_gestion = (
                CASE
                    WHEN afij.fecha_ini_dep < ''01-01-2019''::date then (SELECT po_id_gestion FROM param.f_get_periodo_gestion (''01-01-2019''::date)) --2019 es fijo, antes de 2019 no había parametrizaciones así que tomará la de 2019
                    ELSE (SELECT po_id_gestion FROM param.f_get_periodo_gestion (afij.fecha_ini_dep))
                END
            )
            INNER JOIN conta.tcuenta cue
            ON cue.id_cuenta = rc_af.id_cuenta
            INNER JOIN param.tmoneda mon
            ON mon.id_moneda = afv.id_moneda
            WHERE afv.id_moneda = ' || v_parametros.id_moneda || '
            AND (afij.fecha_baja IS NULL OR afij.fecha_baja > ''' || v_parametros.fecha_hasta ||'''::date)';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || ' AND ' || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;
    --Fin #24

    --Inicio #17
    /*********************************
     #TRANSACCION:  'SKA_RIMPPROP_SEL'
     #DESCRIPCION:  Reporte Impuestos a la Propiedad e Inmuebles
     #AUTOR:        RCM
     #FECHA:        14/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RIMPPROP_SEL') THEN

        BEGIN

            v_consulta = '
            SELECT
            ubicacion,
            clasificacion,
            moneda,
            ROUND(COALESCE(valor_actualiz_gest_ant, 0), 2) AS valor_actualiz_gest_ant,
            ROUND(COALESCE(deprec_acum_gest_ant, 0), 2) AS deprec_acum_gest_ant,
            ROUND(COALESCE(valor_actualiz, 0), 2) AS valor_actualiz,
            --Inicio #29: se cambia deprec_sin_actualiz por la resta de deprec acum - deprec acum gest ant
            CASE COALESCE(deprec_acum, 0)
                WHEN 0 THEN -1 * ROUND(COALESCE(deprec_acum_gest_ant, 0), 2)
                ELSE CASE COALESCE(deprec_acum_gest_ant, 0)
                        WHEN 0 THEN
                            ROUND(COALESCE(deprec_acum, 0), 2)
                        ELSE
                            ROUND(COALESCE(deprec_acum - deprec_acum_gest_ant, 0), 2)
                    END
            END AS deprec_sin_actualiz,
            --Fin #29
            ROUND(COALESCE(deprec_acum, 0), 2) AS deprec_acum,
            ROUND(COALESCE(valor_neto, 0), 2) AS valor_neto,
            orden
            FROM kaf.f_reporte_impuestos_inmueb(' || p_id_usuario || ', ''' || v_parametros.fecha_hasta || ''', ' || v_parametros.id_moneda || ', ''no'') AS
            (
                ubicacion varchar,
                clasificacion varchar,
                moneda varchar,
                valor_actualiz_gest_ant numeric,
                deprec_acum_gest_ant numeric,
                valor_actualiz numeric,
                deprec_sin_actualiz numeric,
                deprec_acum numeric,
                valor_neto numeric,
                orden integer
            )
            WHERE ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
                v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' OFFSET ' || COALESCE(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY ubicacion';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_RIMPPROP_CONT'
     #DESCRIPCION:  Reporte Impuestos a la Propiedad e Inmuebles
     #AUTOR:        RCM
     #FECHA:        14/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RIMPPROP_CONT') THEN

        BEGIN

            v_consulta = '
            SELECT
            COUNT(1) AS total
            FROM kaf.f_reporte_impuestos_inmueb(' || p_id_usuario || ', ''' || v_parametros.fecha_hasta || ''', ' || v_parametros.id_moneda || ', ''no'') AS
            (
                ubicacion varchar,
                clasificacion varchar,
                moneda varchar,
                valor_actualiz_gest_ant numeric,
                deprec_acum_gest_ant numeric,
                valor_actualiz numeric,
                deprec_sin_actualiz numeric,
                deprec_acum numeric,
                valor_neto numeric,
                orden integer
            )
            WHERE ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;
    --Fin #17

    --Inicio #19
    /*********************************
     #TRANSACCION:  'SKA_RIMPVEH_SEL'
     #DESCRIPCION:  Reporte Impuestos de Vehículos
     #AUTOR:        RCM
     #FECHA:        14/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RIMPVEH_SEL') THEN

        BEGIN

            v_consulta = '
            SELECT
            codigo,
            ubicacion,
            clasificacion,
            moneda,
            denominacion,
            placa,
            radicatoria,
            fecha_ini_dep,
            valor_actualiz_gest_ant,
            deprec_acum_gest_ant,
            valor_actualiz,
            deprec_per,
            deprec_acum,
            valor_neto,
            codigo_ant,
            bk_codigo,
            local
            FROM kaf.f_reporte_impuestos_vehiculos(' || p_id_usuario || ', ''' || v_parametros.fecha_hasta || ''', ' || v_parametros.id_moneda || ', ''si'') AS
            (
                id_activo_fijo integer,
                id_activo_fijo_valor integer,
                id_ubicacion integer,
                codigo varchar,
                ubicacion varchar,
                clasificacion varchar,
                moneda varchar,
                denominacion varchar,
                placa varchar,
                radicatoria varchar,
                fecha_ini_dep date,
                valor_actualiz_gest_ant numeric,
                deprec_acum_gest_ant numeric,
                valor_actualiz numeric,
                deprec_per numeric,
                deprec_acum numeric,
                valor_neto numeric,
                codigo_ant varchar,
                bk_codigo varchar,
                local varchar
            )
            WHERE ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
                v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' OFFSET ' || COALESCE(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY codigo';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_RIMPVEH_CONT'
     #DESCRIPCION:  Reporte Impuestos de Vehículos
     #AUTOR:        RCM
     #FECHA:        14/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RIMPVEH_CONT') THEN

        BEGIN

            v_consulta = '
            SELECT
            COUNT(1) AS total
            FROM kaf.f_reporte_impuestos_vehiculos(' || p_id_usuario || ', ''' || v_parametros.fecha_hasta || ''', ' || v_parametros.id_moneda || ', ''si'') AS
            (
                id_activo_fijo integer,
                id_activo_fijo_valor integer,
                id_ubicacion integer,
                codigo varchar,
                ubicacion varchar,
                clasificacion varchar,
                moneda varchar,
                denominacion varchar,
                placa varchar,
                radicatoria varchar,
                fecha_ini_dep date,
                valor_actualiz_gest_ant numeric,
                deprec_acum_gest_ant numeric,
                valor_actualiz numeric,
                deprec_per numeric,
                deprec_acum numeric,
                valor_neto numeric,
                codigo_ant varchar,
                bk_codigo varchar,
                local varchar
            )
            WHERE ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;
    --Fin #19

    --Inicio #26
    /*********************************
     #TRANSACCION:  'SKA_RALORIG_SEL'
     #DESCRIPCION:  Reporte Origen de Altas
     #AUTOR:        RCM
     #FECHA:        22/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RALORIG_SEL') THEN

        BEGIN

            v_consulta = '
            SELECT
            tipo,
            codigo,
            denominacion,
            estado,
            fecha_ini_dep,
            monto_activo,
            --dep_acum_inicial,  --#29
            vida_util_orig,
            nro_tramite,
            descripcion,
            id_moneda,
            id_estado_wf,
            id,
            tabla,
            cod_tipo
            FROM (
            --Cierre de Proyectos activos nuevos
            SELECT
            ''cierre_proy'' AS cod_tipo,
            ''Cierre Proyectos'' AS tipo, af.codigo, af.denominacion, af.estado, afv.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            py.nro_tramite_cierre AS nro_tramite,
            (SELECT ''['' || pxp.list(tcc.codigo) || ''] ''
            FROM pro.tproyecto_activo_detalle pad
            INNER JOIN param.ttipo_cc tcc
            ON tcc.id_tipo_cc = pad.id_tipo_cc
            WHERE pad.id_proyecto_activo = pa.id_proyecto_activo) || py.nombre AS descripcion,
            py.id_estado_wf_cierre AS id_estado_wf,
            py.id_proyecto AS id, ''pro.tproyecto'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN pro.tproyecto_activo pa
            on pa.id_activo_fijo = af.id_activo_fijo
            INNER JOIN pro.tproyecto py
            ON py.id_proyecto = pa.id_proyecto
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            UNION
            --Cierre de Proyectos activos existentes
            SELECT
            ''cierre_proy_inc'' AS cod_tipo,
            ''Cierre Proyectos Incrementos'' AS tipo, af.codigo, af.denominacion, af.estado, afv.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            ROUND((
                param.f_get_tipo_cambio(3, date_trunc(''year'', py.fecha_fin)::date, ''O'') /
                param.f_get_tipo_cambio(3, (date_trunc(''month'', py.fecha_fin) - interval ''1 day'')::date, ''O'')
            ) * afv.importe_modif, 2) AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            py.nro_tramite_cierre AS nro_tramite,
            (SELECT ''['' || pxp.list(tcc.codigo) || ''] ''
            FROM pro.tproyecto_activo_detalle pad
            INNER JOIN param.ttipo_cc tcc
            ON tcc.id_tipo_cc = pad.id_tipo_cc
            WHERE pad.id_proyecto_activo = pa.id_proyecto_activo) || py.nombre AS descripcion,
            py.id_estado_wf_cierre AS id_estado_wf,
            py.id_proyecto AS id, ''pro.tproyecto'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN pro.tproyecto_activo pa
            on pa.id_activo_fijo = af.id_activo_fijo
            INNER JOIN pro.tproyecto py
            ON py.id_proyecto = pa.id_proyecto
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''ajuste''
            WHERE af.estado <> ''registrado''
            AND COALESCE(afv.importe_modif, 0) > 0
            UNION
            --Preingresos
            SELECT ''preingreso'' AS cod_tipo,
            ''Preingresos'' AS tipo, af.codigo, af.denominacion, af.estado, afv.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            cot.num_tramite, sol.justificacion AS descripcion, cot.id_estado_wf,
            cot.id_cotizacion AS id, ''adq.tcotizacion'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN alm.tpreingreso_det pdet
            ON pdet.id_preingreso_det = af.id_preingreso_det
            INNER JOIN alm.tpreingreso pin
            ON pin.id_preingreso =pdet.id_preingreso
            INNER JOIN adq.tcotizacion cot
            ON cot.id_cotizacion = pin.id_cotizacion
            INNER JOIN wf.tproceso_wf pw
            ON pw.id_proceso_wf = cot.id_proceso_wf
            INNER JOIN adq.tproceso_compra pcom
            ON pcom.id_proceso_compra = cot.id_proceso_compra
            INNER JOIN adq.tsolicitud sol
            ON sol.id_solicitud = pcom.id_solicitud
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            UNION
            --Distribución de valores, caso activo fijo nuevo
            SELECT ''distribucion_val'' AS cod_tipo,
            ''Distribución de Valores'' AS tipo, af.codigo, af.denominacion, af.estado, afv.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            mov.num_tramite AS nro_tramite, mov.glosa AS descripcion, mov.id_estado_wf AS id_estado_wf,
            mov.id_movimiento AS id, ''kaf.tmovimiento'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_activo_fijo = af.id_activo_fijo
            AND mafe.tipo = ''af_nuevo''
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento_af = mafe.id_movimiento_af
            INNER JOIN kaf.tmovimiento mov
            ON mov.id_movimiento = maf.id_movimiento
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            UNION
            --Resto de Activos Fijos
            SELECT ''activos_fijos'' AS cod_tipo,
            ''Activos Fijos'' AS tipo, af.codigo, af.denominacion, af.estado, afv.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            mov.num_tramite AS nro_tramite, mov.glosa AS descripcion, mov.id_estado_wf AS id_estado_wf,
            mov.id_movimiento AS id, ''kaf.tmovimiento'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_activo_fijo = af.id_activo_fijo
            INNER JOIN kaf.tmovimiento mov
            ON mov.id_movimiento = maf.id_movimiento
            INNER JOIN param.tcatalogo cat
            ON cat.id_catalogo = mov.id_cat_movimiento
            AND cat.codigo = ''alta''
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            AND af.id_activo_fijo NOT IN (SELECT id_activo_fijo FROM pro.tproyecto_activo WHERE id_activo_fijo IS NOT NULL)
            AND af.id_preingreso_det IS NULL
            AND af.id_activo_fijo NOT IN (SELECT id_activo_fijo FROM kaf.tmovimiento_af_especial WHERE id_activo_fijo IS NOT NULL)
            ) afij
            WHERE afij.fecha_ini_dep BETWEEN ''' || v_parametros.fecha_desde || ''' AND ''' || v_parametros.fecha_hasta || '''
            AND afij.id_moneda = ' || v_parametros.id_moneda || '
            AND ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
                v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' OFFSET ' || COALESCE(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY 3';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_RALORIG_CONT'
     #DESCRIPCION:  Reporte Impuestos de Vehículos
     #AUTOR:        RCM
     #FECHA:        14/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RALORIG_CONT') THEN

        BEGIN

            v_consulta = '
            SELECT
            COUNT(1) AS total
            FROM (
            --Cierre de Proyectos
            SELECT
            ''cierre_proy'' AS cod_tipo,
            ''Cierre Proyectos'' AS tipo, af.codigo, af.denominacion, af.estado, af.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            py.nro_tramite_cierre AS nro_tramite, py.nombre AS descripcion, py.id_estado_wf_cierre AS id_estado_wf,
            py.id_proyecto AS id, ''pro.tproyecto'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN pro.tproyecto_activo pa
            on pa.id_activo_fijo = af.id_activo_fijo
            INNER JOIN pro.tproyecto py
            ON py.id_proyecto = pa.id_proyecto
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            UNION
            --Preingresos
            SELECT ''preingreso'' AS cod_tipo,
            ''Preingresos'' AS tipo, af.codigo, af.denominacion, af.estado, af.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            cot.num_tramite, sol.justificacion AS descripcion, cot.id_estado_wf,
            cot.id_cotizacion AS id, ''adq.tcotizacion'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN alm.tpreingreso_det pdet
            ON pdet.id_preingreso_det = af.id_preingreso_det
            INNER JOIN alm.tpreingreso pin
            ON pin.id_preingreso =pdet.id_preingreso
            INNER JOIN adq.tcotizacion cot
            ON cot.id_cotizacion = pin.id_cotizacion
            INNER JOIN wf.tproceso_wf pw
            ON pw.id_proceso_wf = cot.id_proceso_wf
            INNER JOIN adq.tproceso_compra pcom
            ON pcom.id_proceso_compra = cot.id_proceso_compra
            INNER JOIN adq.tsolicitud sol
            ON sol.id_solicitud = pcom.id_solicitud
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            UNION
            --Distribución de valores, caso activo fijo nuevo
            SELECT ''distribucion_val'' AS cod_tipo,
            ''Distribución de Valores'' AS tipo, af.codigo, af.denominacion, af.estado, af.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            mov.num_tramite AS nro_tramite, mov.glosa AS descripcion, mov.id_estado_wf AS id_estado_wf,
            mov.id_movimiento AS id, ''kaf.tmovimiento'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN kaf.tmovimiento_af_especial mafe
            ON mafe.id_activo_fijo = af.id_activo_fijo
            AND mafe.tipo = ''af_nuevo''
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_movimiento_af = mafe.id_movimiento_af
            INNER JOIN kaf.tmovimiento mov
            ON mov.id_movimiento = maf.id_movimiento
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            UNION
            --Resto de Activos Fijos
            SELECT ''activos_fijos'' AS cod_tipo,
            ''Activos Fijos'' AS tipo, af.codigo, af.denominacion, af.estado, af.fecha_ini_dep,
            afv.id_moneda,
            --Inicio #29
            CASE COALESCE(afv.monto_vigente_actualiz_inicial, 0)
                WHEN 0 THEN ROUND(afv.monto_vigente_orig, 2)
                ELSE ROUND(afv.monto_vigente_actualiz_inicial, 2)
            END AS monto_activo,
            --Fin #29
            COALESCE(afv.depreciacion_acum_inicial,0) AS dep_acum_inicial, afv.vida_util_orig,
            mov.num_tramite AS nro_tramite, mov.glosa AS descripcion, mov.id_estado_wf AS id_estado_wf,
            mov.id_movimiento AS id, ''kaf.tmovimiento'' AS tabla
            FROM kaf.tactivo_fijo af
            INNER JOIN kaf.tmovimiento_af maf
            ON maf.id_activo_fijo = af.id_activo_fijo
            INNER JOIN kaf.tmovimiento mov
            ON mov.id_movimiento = maf.id_movimiento
            INNER JOIN param.tcatalogo cat
            ON cat.id_catalogo = mov.id_cat_movimiento
            AND cat.codigo = ''alta''
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo = af.id_activo_fijo
            AND afv.tipo = ''alta''
            WHERE af.estado <> ''registrado''
            AND af.id_activo_fijo NOT IN (SELECT id_activo_fijo FROM pro.tproyecto_activo WHERE id_activo_fijo IS NOT NULL)
            AND af.id_preingreso_det IS NULL
            AND af.id_activo_fijo NOT IN (SELECT id_activo_fijo FROM kaf.tmovimiento_af_especial WHERE id_activo_fijo IS NOT NULL)
            ) afij
            WHERE afij.fecha_ini_dep BETWEEN ''' || v_parametros.fecha_desde || ''' AND ''' || v_parametros.fecha_hasta || '''
            AND afij.id_moneda = ' || v_parametros.id_moneda || '
            AND ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                v_consulta = v_consulta || v_parametros.filtro;
            END IF;

            RETURN v_consulta;

        END;
    --Fin #26

    --Inicio #23
    /*********************************
     #TRANSACCION:  'SKA_RCOMPAFCT_SEL'
     #DESCRIPCION:  Reporte Comparación Activos Fijos y Contabilidad
     #AUTOR:        RCM
     #FECHA:        23/08/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_RCOMPAFCT_SEL') THEN

        BEGIN

            v_id_moneda_base = param.f_get_moneda_base();

            --Obtiene la moneda para la actualización
            SELECT id_moneda_dep
            INTO
            v_id_moneda_dep
            FROM kaf.tmoneda_dep
            WHERE id_moneda = v_id_moneda_base;

            --Obtiene datos del movimiento
            SELECT id_estado_wf
            INTO v_id_estado_wf
            FROM kaf.tmovimiento
            WHERE id_movimiento = v_parametros.id_movimiento;

            v_sw_insert = TRUE;

            --Elimina los registros cuando existen y no tienen comprobante
            DELETE FROM kaf.tcomparacion_af_conta
            WHERE id_movimiento = v_parametros.id_movimiento
            AND id_int_comprobante IS NULL;

            --Verifica si existe registros de comparación para el movimiento y tien comprobante
            IF EXISTS(SELECT 1
                    FROM kaf.tcomparacion_af_conta
                    WHERE id_movimiento = v_parametros.id_movimiento
                    AND id_int_comprobante IS NOT NULL) THEN
                v_sw_insert = FALSE;
            END IF;

            --Inserción de las posibles diferencias
            IF v_sw_insert THEN

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
                        p_id_usuario, NULL, NULL::varchar,
                        'gau0s6qa8lo8kl2r11riers2j2', 99999, '127.0.0.1', '99:99:99:99:99:99',
                        'kaf.f_reportes_af', 'SKA_RDEPREC_SEL', NULL, NULL,
                        array ['filtro', 'ordenacion', 'dir_ordenacion', 'puntero', 'cantidad', '_id_usuario_ai', '_nombre_usuario_ai', 'tipo_salida', 'fecha_hasta', 'id_moneda', 'af_deprec', 'id_moneda_dep'], --#29 se agrega parámetro id_moneda_dep
                        array [E' 0 = 0 ',E'codigo ASC', E' ', E'0', E'100000', E'NULL', E'NULL', E'grid', (''''||v_parametros.fecha::varchar||'''')::varchar, (''''||v_id_moneda_dep::varchar||'''')::varchar, E'completo', (''''||v_id_moneda_dep::varchar||'''')::varchar],--#29 se agrega parámetro id_moneda_dep
                        array ['varchar', 'varchar', 'varchar', 'integer','integer', 'int4', 'varchar', 'varchar', 'date', 'integer', 'varchar', 'integer'],
                        false, 'varchar', NULL
                    ) AS
                    (
                        numero bigint,                                  codigo varchar,             codigo_ant varchar,
                        denominacion varchar,                           fecha_ini_dep date,         cantidad_af integer,
                        desc_unidad_medida varchar,                     codigo_tcc varchar,         nro_serie varchar,
                        desc_ubicacion varchar,                         responsable text,           monto_vigente_orig_100 numeric,
                        monto_vigente_orig numeric,                     af_altas numeric,           af_bajas numeric,                   af_traspasos numeric,
                        inc_actualiz numeric,                           monto_actualiz numeric,     vida_util_orig integer,
                        vida_util integer,                              vida_util_usada integer,    depreciacion_acum_gest_ant numeric,
                        depreciacion_acum_actualiz_gest_ant numeric,    depreciacion numeric,
                        depreciacion_acum_bajas numeric,                depreciacion_acum_traspasos numeric,
                        depreciacion_acum numeric,                      depreciacion_per numeric,   monto_vigente numeric,
                        aitb_dep_acum numeric,                          aitb_dep numeric,           aitb_dep_acum_anual numeric,        aitb_dep_anual numeric, --#31
                        cuenta_activo text,                             cuenta_dep_acum text,       cuenta_deprec text,                 desc_grupo varchar,
                        desc_grupo_clasif varchar,                      cuenta_dep_acum_dos text,   bk_codigo varchar,
                        cc1 varchar,                                    dep_mes_cc1 numeric,        cc2 varchar,                        dep_mes_cc2 numeric,    cc3 varchar,
                        dep_mes_cc3 numeric,                            cc4 varchar,                dep_mes_cc4 numeric,                cc5 varchar,            dep_mes_cc5 numeric,
                        cc6 varchar,                                    dep_mes_cc6 numeric,        cc7 varchar,                        dep_mes_cc7 numeric,    cc8 varchar,
                        dep_mes_cc8 numeric,                            cc9 varchar,                dep_mes_cc9 numeric,                cc10 varchar,           dep_mes_cc10 numeric,
                        id_activo_fijo integer,                         nivel integer,              orden bigint,                       tipo varchar
                    )
                    GROUP BY cuenta_activo, cuenta_dep_acum, cuenta_deprec, cuenta_dep_acum_dos
                ), tdetalle_conta AS (
                    WITH tcuenta_activo AS (
                        SELECT DISTINCT
                        rc.id_cuenta, cu.nro_cuenta, cu.nombre_cuenta
                        FROM conta.ttabla_relacion_contable tb
                        JOIN conta.ttipo_relacion_contable trc
                        ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                        JOIN conta.trelacion_contable rc
                        ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                        INNER JOIN param.tgestion ges
                        ON ges.id_gestion = rc.id_gestion
                        AND DATE_TRUNC('year', ges.fecha_ini) = DATE_TRUNC('year', v_parametros.fecha::date)
                        INNER JOIN conta.tcuenta cu
                        on cu.id_cuenta = rc.id_cuenta
                        WHERE tb.esquema = 'KAF'
                        AND tb.tabla = 'tclasificacion'
                        AND trc.codigo_tipo_relacion IN ('ALTAAF', 'DEPACCLAS', 'DEPCLAS')
                    )
                    SELECT
                    c.nro_cuenta || '-' || c.nombre_cuenta AS desc_cuenta,
                    c.nro_cuenta, c.nombre_cuenta, c.id_cuenta,
                    ABS(SUM(tr.importe_debe_mb) - SUM(tr.importe_haber_mb)) AS importe
                    FROM conta.tint_transaccion tr
                    INNER JOIN conta.tint_comprobante cb
                    ON cb.id_int_comprobante = tr.id_int_comprobante
                    INNER JOIN tcuenta_activo c
                    ON c.id_cuenta = tr.id_cuenta
                    WHERE cb.estado_reg = 'validado'
                    AND cb.fecha BETWEEN DATE_TRUNC('year', v_parametros.fecha::date) AND v_parametros.fecha::date
                    GROUP BY c.nro_cuenta, c.nombre_cuenta, c.id_cuenta
                )
                INSERT INTO kaf.tcomparacion_af_conta (
                    id_usuario_reg,
                    fecha_reg,
                    estado_reg,
                    id_movimiento,
                    id_cuenta,
                    fecha,
                    saldo_af,
                    saldo_conta,
                    diferencia_af_conta
                )
                SELECT
                p_id_usuario,
                now(),
                'activo',
                v_parametros.id_movimiento,
                dc.id_cuenta,
                now(),
                af.importe AS saldo_af,
                dc.importe AS saldo_conta,
                af.importe - dc.importe AS diferencia
                FROM (
                    SELECT
                    cuenta_activo AS desc_cuenta, SUM(monto_actualiz) AS importe
                    FROM tdetalle_dep
                    WHERE cuenta_activo IS NOT NULL
                    GROUP BY cuenta_activo
                    UNION
                    SELECT DISTINCT
                    cuenta_dep_acum AS desc_cuenta, SUM(depreciacion_acum) AS importe
                    FROM tdetalle_dep
                    WHERE cuenta_dep_acum IS NOT NULL
                    GROUP BY cuenta_dep_acum
                    UNION
                    SELECT DISTINCT
                    cuenta_deprec AS desc_cuenta, depreciacion_per AS importe
                    FROM tdetalle_dep
                    WHERE cuenta_deprec IS NOT NULL
                    AND cuenta_dep_acum_dos IS NULL
                    UNION
                    SELECT DISTINCT
                    cuenta_dep_acum_dos AS desc_cuenta, depreciacion_per AS importe
                    FROM tdetalle_dep
                    WHERE cuenta_dep_acum_dos IS NOT NULL
                ) af
                INNER JOIN tdetalle_conta dc
                ON dc.desc_cuenta = af.desc_cuenta;

                --Genera comprobante en caso de que haya alguna diferencia
                IF EXISTS(SELECT 1
                        FROM kaf.tcomparacion_af_conta
                        WHERE id_movimiento = v_parametros.id_movimiento
                        AND COALESCE(diferencia_af_conta, 0) <> 0) THEN

                    v_id_int_cbte = conta.f_gen_comprobante
                                    (
                                        v_parametros.id_movimiento,
                                        'KAF-DEP-IGUAL',
                                        v_id_estado_wf,
                                        p_id_usuario,
                                        NULL,
                                        NULL
                                    );

                    UPDATE kaf.tcomparacion_af_conta SET
                    id_int_comprobante = v_id_int_cbte
                    WHERE id_movimiento = v_parametros.id_movimiento;

                END IF;

            END IF;

            --Consulta para la respuesta
            v_consulta = 'SELECT
                        cac.fecha,
                        cu.nro_cuenta,
                        cu.nombre_cuenta,
                        cac.saldo_af,
                        cac.saldo_conta,
                        cac.diferencia_af_conta,
                        cac.id_int_comprobante,
                        cac.id_usuario_reg,
                        cac.fecha_reg,
                        cac.estado_reg,
                        cac.id_movimiento,
                        cac.id_cuenta
                        FROM kaf.tcomparacion_af_conta cac
                        INNER JOIN conta.tcuenta  cu
                        ON cu.id_cuenta = cac.id_cuenta
                        WHERE id_movimiento = ' || v_parametros.id_movimiento;

            /*v_consulta = '
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
                    ' || p_id_usuario || ', NULL, NULL::varchar,
                    ''gau0s6qa8lo8kl2r11riers2j2'', 99999, ''127.0.0.1'', ''99:99:99:99:99:99'',
                    ''kaf.f_reportes_af'', ''SKA_RDEPREC_SEL'', NULL, NULL, array [''filtro'',
                    ''ordenacion'', ''dir_ordenacion'', ''puntero'', ''cantidad'', ''_id_usuario_ai'',
                    ''_nombre_usuario_ai'', ''tipo_salida'', ''fecha_hasta'', ''id_moneda'', ''af_deprec''],
                    array [E'' 0 = 0 '',
                    E''codigo ASC'', E'' '', E''0'', E''100000'', E''NULL'', E''NULL'', E''grid'',
                    E''' || v_parametros.fecha || ''', --fecha cambiar a la que se requiera
                    E''' || v_id_moneda_dep || ''', --id_moneda 2: Bs, 3: USD, 4: UFV
                    E''completo''], array [''varchar'', ''varchar'', ''varchar'', ''integer'',
                    ''integer'', ''int4'', ''varchar'', ''varchar'', ''date'', ''integer'', ''varchar''],
                    false, ''varchar'', NULL
                ) AS
                (
                    numero bigint,                                  codigo varchar,             codigo_ant varchar,
                    denominacion varchar,                           fecha_ini_dep date,         cantidad_af integer,
                    desc_unidad_medida varchar,                     codigo_tcc varchar,         nro_serie varchar,
                    desc_ubicacion varchar,                         responsable text,           monto_vigente_orig_100 numeric,
                    monto_vigente_orig numeric,                     af_altas numeric,           af_bajas numeric,                   af_traspasos numeric,
                    inc_actualiz numeric,                           monto_actualiz numeric,     vida_util_orig integer,
                    vida_util integer,                              vida_util_usada integer,    depreciacion_acum_gest_ant numeric,
                    depreciacion_acum_actualiz_gest_ant numeric,    depreciacion numeric,
                    depreciacion_acum_bajas numeric,                depreciacion_acum_traspasos numeric,
                    depreciacion_acum numeric,                      depreciacion_per numeric,   monto_vigente numeric,
                    cuenta_activo text,                             cuenta_dep_acum text,       cuenta_deprec text,                 desc_grupo varchar,
                    desc_grupo_clasif varchar,                      cuenta_dep_acum_dos text,   bk_codigo varchar,
                    cc1 varchar,                                    dep_mes_cc1 numeric,        cc2 varchar,                        dep_mes_cc2 numeric,    cc3 varchar,
                    dep_mes_cc3 numeric,                            cc4 varchar,                dep_mes_cc4 numeric,                cc5 varchar,            dep_mes_cc5 numeric,
                    cc6 varchar,                                    dep_mes_cc6 numeric,        cc7 varchar,                        dep_mes_cc7 numeric,    cc8 varchar,
                    dep_mes_cc8 numeric,                            cc9 varchar,                dep_mes_cc9 numeric,                cc10 varchar,           dep_mes_cc10 numeric,
                    id_activo_fijo integer,                         nivel integer,              orden bigint,                       tipo varchar
                )
                GROUP BY cuenta_activo, cuenta_dep_acum, cuenta_deprec, cuenta_dep_acum_dos
            ), tdetalle_conta AS (
                WITH tcuenta_activo AS (
                    SELECT DISTINCT
                    rc.id_cuenta, cu.nro_cuenta, cu.nombre_cuenta
                    FROM conta.ttabla_relacion_contable tb
                    JOIN conta.ttipo_relacion_contable trc
                    ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
                    JOIN conta.trelacion_contable rc
                    ON rc.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
                    INNER JOIN param.tgestion ges
                    ON ges.id_gestion = rc.id_gestion
                    AND DATE_TRUNC(''year'', ges.fecha_ini) = DATE_TRUNC(''year'', ''' || v_parametros.fecha || '''::date)
                    INNER JOIN conta.tcuenta cu
                    on cu.id_cuenta = rc.id_cuenta
                    WHERE tb.esquema = ''KAF''
                    AND tb.tabla = ''tclasificacion''
                    AND trc.codigo_tipo_relacion IN (''ALTAAF'', ''DEPACCLAS'', ''DEPCLAS'')
                )
                SELECT
                c.nro_cuenta || ''-'' || c.nombre_cuenta AS desc_cuenta,
                c.nro_cuenta, c.nombre_cuenta, c.id_cuenta,
                ABS(SUM(tr.importe_debe_mb) - SUM(tr.importe_haber_mb)) AS importe
                FROM conta.tint_transaccion tr
                INNER JOIN conta.tint_comprobante cb
                ON cb.id_int_comprobante = tr.id_int_comprobante
                INNER JOIN tcuenta_activo c
                ON c.id_cuenta = tr.id_cuenta
                WHERE cb.estado_reg = ''validado''
                AND cb.fecha BETWEEN DATE_TRUNC(''year'', ''' || v_parametros.fecha || '''::date) and ''' || v_parametros.fecha || '''::date
                GROUP BY c.nro_cuenta, c.nombre_cuenta, c.id_cuenta
            )
            SELECT
            dc.desc_cuenta,
            af.importe AS saldo_af,
            dc.importe AS saldo_conta,
            af.importe - dc.importe AS diferencia,
            dc.nro_cuenta,
            dc.nombre_cuenta,
            dc.id_cuenta
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
            ON dc.desc_cuenta = af.desc_cuenta';*/

            RETURN v_consulta;

        END;
    --Fin #23

    --Inicio #29
    /*********************************
     #TRANSACCION:  'SKA_FORM605V2_SEL'
     #DESCRIPCION:  Reporte Form605 V2
     #AUTOR:        RCM
     #FECHA:        25/09/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_FORM605V2_SEL') THEN

        BEGIN

            --Obtiene la fecha máxima de depreciación en base a la fecha enviada
            v_fecha_dep = ('31-12-' || v_parametros.gestion)::date;

            SELECT MAX(fecha)
            INTO v_max_fecha
            FROM kaf.tmovimiento_af_dep
            WHERE DATE_TRUNC('month', fecha) <= DATE_TRUNC('month', v_fecha_dep);

            v_caract_invalidos = pxp.f_get_variable_global('kaf_caracteres_no_validos_form605');

            v_consulta = 'SELECT
                        rd.codigo,
                        rd.cuenta_activo AS nro_cuenta,
                        rd.denominacion,
                        rd.desc_unidad_medida AS unidad_medida,
                        rd.cantidad_af,
                        rd.monto_vigente AS inventario_final,
                        rd.af_bajas AS inventario_bajas,
                        (pxp.f_limpiar_cadena(rd.denominacion, ''' || v_caract_invalidos || ''') || '', '' || rd.codigo)::varchar as nombre_con_unidad,
                        mon.codigo as codigo_moneda,
                        mon.moneda as desc_moneda
                        FROM kaf.treporte_detalle_dep rd
                        INNER JOIN param.tmoneda mon
                        ON mon.id_moneda = rd.id_moneda
                        WHERE DATE_TRUNC(''month'', fecha) = DATE_TRUNC(''month'', ''' || v_max_fecha || '''::date)
                        AND rd.id_moneda = ' || v_parametros.id_moneda || ' ';

            IF v_parametros.tipo_salida = 'grid' THEN
                --Definicion de la respuesta
                --v_consulta = v_consulta || v_parametros.filtro;
                --v_consulta = v_consulta || ' ORDER BY ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' LIMIT ' || COALESCE(v_parametros.cantidad, 9999999) || ' OFFSET ' || COALESCE(v_parametros.puntero, 0);
            ELSE
                v_consulta = v_consulta || ' ORDER BY 1';
            END IF;

            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_FORM605V2_CONT'
     #DESCRIPCION:  Reporte Form605 V2
     #AUTOR:        RCM
     #FECHA:        25/09/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_FORM605V2_CONT') THEN

        BEGIN

            --Obtiene la fecha máxima de depreciación en base a la fecha enviada
            v_fecha_dep = ('31-12-' || v_parametros.gestion)::date;

            SELECT MAX(fecha)
            INTO v_max_fecha
            FROM kaf.tmovimiento_af_dep
            WHERE DATE_TRUNC('month', fecha) <= DATE_TRUNC('month', v_fecha_dep);

            v_caract_invalidos = pxp.f_get_variable_global('kaf_caracteres_no_validos_form605');

            v_consulta = 'SELECT
                        COUNT(1) AS total
                        FROM kaf.treporte_detalle_dep rd
                        INNER JOIN param.tmoneda mon
                        ON mon.id_moneda = rd.id_moneda
                        WHERE DATE_TRUNC(''month'', fecha) = DATE_TRUNC(''month'', ''' || v_max_fecha || '''::date)
                        AND rd.id_moneda = ' || v_parametros.id_moneda;

            RETURN v_consulta;

        END;
    --Fin #29

    ELSE
        RAISE EXCEPTION 'Transacción inexistente';
    END IF;

EXCEPTION

    WHEN OTHERS THEN

        v_respuesta = '';
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'mensaje', SQLERRM);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'codigo_error', SQLSTATE);
        v_respuesta = pxp.f_agrega_clave(v_respuesta, 'procedimiento', v_nombre_funcion);

        RAISE EXCEPTION '%', v_respuesta;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;