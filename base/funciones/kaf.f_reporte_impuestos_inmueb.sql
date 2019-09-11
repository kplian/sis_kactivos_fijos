CREATE OR REPLACE FUNCTION kaf.f_reporte_impuestos_inmueb (
	p_id_usuario integer,
	p_fecha date,
	p_id_moneda integer,
    p_detalle varchar = 'no'
)
RETURNS SETOF RECORD AS
$body$
/**************************************************************************
 SISTEMA:   	Sistema de Activos Fijos
 FUNCION:     	kaf.f_reporte_impuestos_inmueb
 DESCRIPCION:   Funcion que general el reporte Impuestos a las Propiedades e Inmuebles por gestión
 AUTOR:      	RCM
 FECHA:         11/07/2019
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #17    KAF       ETR           11/07/2019  RCM         Reporte Impuestos a las Propiedades e Inmuebles por gestión
 ***************************************************************************/
DECLARE

	v_resp                  varchar;
    v_nombre_funcion        text;
    v_mensaje_error         text;
    v_agrup_clasif			varchar;
    v_rec 					record;

BEGIN

	v_nombre_funcion = 'kaf.f_reporte_impuestos_inmueb';
	v_agrup_clasif = 'RIMPINM';

	--Creación de tabla temporal
	create temp table treporte_imp_inmb(
		id_activo_fijo integer,
		id_activo_fijo_valor integer,
        id_ubicacion integer,
		codigo_af varchar(50),
		ubicacion varchar(100),
		clasificacion varchar(100),
		moneda varchar(30),
		valor_actualiz_gest_ant numeric,
		deprec_acum_gest_ant numeric,
		valor_actualiz numeric,
		deprec_per numeric,
		deprec_acum numeric,
		valor_neto numeric
	) on commit drop;


	--Inserción de la consulta
	INSERT INTO treporte_imp_inmb(
		id_activo_fijo,
		id_activo_fijo_valor,
        id_ubicacion,
		codigo_af,
		ubicacion,
		clasificacion,
		moneda,
		valor_actualiz_gest_ant,
		deprec_acum_gest_ant,
		valor_actualiz,
		deprec_per,
		deprec_acum,
		valor_neto
	)
	WITH tult_dep AS (
	    SELECT
	    afv.id_activo_fijo,
	    mdep.id_moneda,
	    MAX(mdep.fecha) AS fecha_max
	    FROM kaf.tmovimiento_af_dep mdep
	    INNER JOIN kaf.tactivo_fijo_valores afv
	    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
	    WHERE date_trunc('year',mdep.fecha) = date_trunc('year', p_fecha) --p_fecha
	    GROUP BY afv.id_activo_fijo, mdep.id_moneda
	), tult_dep_gest_ant AS (
	    SELECT
	    afv.id_activo_fijo,
	    mdep.id_moneda,
	    MAX(mdep.fecha) AS fecha_max
	    FROM kaf.tmovimiento_af_dep mdep
	    INNER JOIN kaf.tactivo_fijo_valores afv
	    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
	    WHERE date_trunc('year',mdep.fecha) = date_trunc('year', p_fecha) - INTERVAL '1 year' --p_fecha
	    GROUP BY afv.id_activo_fijo, mdep.id_moneda
	), tclasif AS (
	    WITH RECURSIVE t(id,id_fk,nombre,n) AS (
	        SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
	        FROM kaf.tclasificacion l
	        WHERE l.id_clasificacion IN (select id_clasificacion
	        							 from kaf.tgrupo_clasif gc
	                                     INNER JOIN kaf.tgrupo_clasif_rel gcr
	                                     ON gcr.id_grupo_clasif = gc.id_grupo_clasif
	                                     WHERE gc.codigo = v_agrup_clasif)
	        UNION ALL
	        SELECT l.id_clasificacion, l.id_clasificacion_fk, l.nombre, n+1
	        FROM kaf.tclasificacion l, t
	        WHERE l.id_clasificacion_fk = t.id
	    )
	    SELECT
	    t.id AS id_clasificacion, t.nombre
	    FROM t
	)
	SELECT
	af.id_activo_fijo,
	afv.id_activo_fijo_valor,
    af.id_ubicacion,
	af.codigo,
	ub.nombre AS ubicacion,
	cl.nombre AS clasificacion,
	mon.codigo AS moneda,
	mdepant.monto_actualiz AS valor_actualiz_gest_ant,
	mdepant.depreciacion_acum AS deprec_acum_gest_ant,
	mdep.monto_actualiz AS valor_actualiz,
	mdep.depreciacion_per AS deprec_per,
	mdep.depreciacion_acum AS deprec_acum,
	mdep.monto_actualiz - mdep.depreciacion_acum AS valor_neto
	FROM kaf.tactivo_fijo af
	INNER JOIN tclasif cl
	ON cl.id_clasificacion = af.id_clasificacion
	INNER JOIN kaf.tactivo_fijo_valores afv
	ON afv.id_activo_fijo = af.id_activo_fijo
	INNER JOIN tult_dep ud
	ON ud.id_activo_fijo = afv.id_activo_fijo
	AND ud.id_moneda = afv.id_moneda
	INNER JOIN kaf.tmovimiento_af_dep mdep
	ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
	AND mdep.fecha = ud.fecha_max
	INNER JOIN kaf.tubicacion ub
	ON ub.id_ubicacion = af.id_ubicacion
	INNER JOIN param.tmoneda mon
	ON mon.id_moneda = af.id_moneda
	LEFT JOIN tult_dep_gest_ant udant
	ON udant.id_activo_fijo = afv.id_activo_fijo
	AND udant.id_moneda = afv.id_moneda
	LEFT JOIN kaf.tmovimiento_af_dep mdepant
	ON mdepant.id_activo_fijo_valor = afv.id_activo_fijo_valor
	AND mdepant.fecha = udant.fecha_max
	WHERE afv.id_moneda = p_id_moneda
	AND (af.fecha_baja IS NULL OR date_trunc('year',af.fecha_baja) > date_trunc('year',p_fecha) ) --p_fecha
	UNION
    --MÁS LOS DADOS DE BAJA EN LA GESTIÓN SÓLO PARA DESPLEGAR DATOS DE LA ANTERIOR GESTIÓN
	SELECT
	af.id_activo_fijo,
	afv.id_activo_fijo_valor,
    af.id_ubicacion,
	af.codigo,
	ub.nombre AS ubicacion,
	cl.nombre AS clasificacion,
	mon.codigo AS moneda,
	mdep.monto_actualiz AS valor_actualiz_gest_ant,
	mdep.depreciacion_acum AS deprec_acum_gest_ant,
	0 AS valor_actualiz,
	0 AS deprec_per,
	0 AS deprec_acum,
	0 AS valor_neto
	FROM kaf.tactivo_fijo af
	INNER JOIN tclasif cl
	ON cl.id_clasificacion = af.id_clasificacion
	INNER JOIN kaf.tactivo_fijo_valores afv
	ON afv.id_activo_fijo = af.id_activo_fijo
	INNER JOIN tult_dep_gest_ant ud
	ON ud.id_activo_fijo = afv.id_activo_fijo
	AND ud.id_moneda = afv.id_moneda
	INNER JOIN kaf.tmovimiento_af_dep mdep
	ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
	AND mdep.fecha = ud.fecha_max
	INNER JOIN kaf.tubicacion ub
	ON ub.id_ubicacion = af.id_ubicacion
	INNER JOIN param.tmoneda mon
	ON mon.id_moneda = af.id_moneda
	WHERE afv.id_moneda = p_id_moneda
	AND (af.fecha_baja IS NOT NULL AND date_trunc('year',af.fecha_baja) = date_trunc('year',p_fecha)); --p_fecha

	--Obtención de depreciación gestión anterior para casos que no hubiera encontrado
	-----PARA GESTIONES ANTERIORES
	UPDATE treporte_imp_inmb RE SET
	valor_actualiz_gest_ant = UD.monto_actualiz,
	deprec_acum_gest_ant = UD.depreciacion_acum
	FROM (
		WITH tult_dep AS (
		    SELECT
		    afv.id_activo_fijo,
		    mdep.id_moneda,
		    MAX(mdep.fecha) AS fecha_max
		    FROM kaf.tmovimiento_af_dep mdep
		    INNER JOIN kaf.tactivo_fijo_valores afv
		    ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
		    WHERE date_trunc('year',mdep.fecha) = date_trunc('year', p_fecha) - INTERVAL '1 year' --p_fecha
		    GROUP BY afv.id_activo_fijo, mdep.id_moneda
		)
		SELECT
		af.id_activo_fijo, af.codigo, mdep.monto_actualiz, mdep.depreciacion_acum
		FROM kaf.tactivo_fijo af
		INNER JOIN kaf.tactivo_fijo_valores afv
		ON afv.id_activo_fijo = af.id_activo_fijo
		INNER JOIN tult_dep ud
		ON ud.id_activo_fijo = afv.id_activo_fijo
		AND afv.id_moneda = ud.id_moneda
		INNER JOIN kaf.tmovimiento_af_dep mdep
		ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
		AND mdep.id_moneda = afv.id_moneda
		AND mdep.fecha = ud.fecha_max
		INNER JOIN treporte_imp_inmb rim
		ON rim.id_activo_fijo = af.id_activo_fijo
		WHERE afv.id_moneda = p_id_moneda
		AND rim.deprec_acum_gest_ant IS NULL
	) UD
	WHERE RE.id_activo_fijo = UD.id_activo_fijo;


   	--Resultado
    IF p_detalle = 'si' THEN
        FOR v_rec IN (SELECT
                      rim.id_activo_fijo,
                      rim.id_activo_fijo_valor,
                      rim.id_ubicacion,
                      rim.codigo_af,
                      rim.ubicacion,
                      rim.clasificacion,
                      rim.moneda,
                      rim.valor_actualiz_gest_ant,
                      rim.deprec_acum_gest_ant,
                      rim.valor_actualiz,
                      CASE
                      	WHEN COALESCE(rim.deprec_acum, 0) = 0 THEN
                      		0
                      	ELSE
                      		rim.deprec_acum - COALESCE(rim.deprec_acum_gest_ant, 0)
                      END AS deprec_sin_actualiz,
                      rim.deprec_acum,
                      rim.valor_neto,
                      af.codigo_ant,
                      af.bk_codigo,
                      ub.codigo as local
                      FROM treporte_imp_inmb rim
                      INNER JOIN kaf.tactivo_fijo af
                      ON af.id_activo_fijo = rim.id_activo_fijo
                      INNER JOIN kaf.tubicacion ub
                      ON ub.id_ubicacion = rim.id_ubicacion
                      ORDER BY rim.codigo_af) LOOP
            RETURN NEXT v_rec;
        END LOOP;
    ELSE
    	FOR v_rec IN (SELECT
                      (ub.orden || ' - ' || rim.ubicacion)::VARCHAR as ubicacion,
                      rim.clasificacion,
                      rim.moneda,
                      SUM(rim.valor_actualiz_gest_ant) AS valor_actualiz_gest_ant,
                      SUM(rim.deprec_acum_gest_ant) AS deprec_acum_gest_ant,
                      SUM(rim.valor_actualiz) AS valor_actualiz,
                      SUM(rim.deprec_acum - COALESCE(rim.deprec_acum_gest_ant, 0)) AS deprec_sin_actualiz,
                      SUM(rim.deprec_acum) AS deprec_acum,
                      SUM(rim.valor_neto) AS valor_neto,
    				  ub.orden
                      FROM treporte_imp_inmb rim
                      INNER JOIN kaf.tubicacion ub
                      ON ub.id_ubicacion = rim.id_ubicacion
                      WHERE rim.deprec_acum > 0
                      GROUP BY rim.ubicacion, rim.clasificacion, rim.moneda, ub.orden
                      UNION
                      SELECT
                      (ub.orden || ' - ' || rim.ubicacion)::VARCHAR as ubicacion,
                      rim.clasificacion,
                      rim.moneda,
                      SUM(rim.valor_actualiz_gest_ant) AS valor_actualiz_gest_ant,
                      SUM(rim.deprec_acum_gest_ant) AS deprec_acum_gest_ant,
                      SUM(rim.valor_actualiz) AS valor_actualiz,
                      0 AS deprec_sin_actualiz,
                      SUM(rim.deprec_acum) AS deprec_acum,
                      SUM(rim.valor_neto) AS valor_neto,
                      ub.orden
                      FROM treporte_imp_inmb rim
                      INNER JOIN kaf.tubicacion ub
                      ON ub.id_ubicacion = rim.id_ubicacion
                      WHERE COALESCE(rim.deprec_acum) = 0
                      GROUP BY rim.ubicacion, rim.clasificacion, rim.moneda, ub.orden
                      ORDER BY orden) LOOP
            RETURN NEXT v_rec;
        END LOOP;

    END IF;

    --Respuesta
	RETURN;


EXCEPTION

	WHEN OTHERS THEN
	    v_resp = '';
	    v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
	    v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
	    v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);

	    RAISE EXCEPTION '%',v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;