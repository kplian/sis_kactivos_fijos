CREATE OR REPLACE FUNCTION kaf.f_procesa_detalle_depreciacion__extra_tmp (
	p_mes date
)
RETURNS VARCHAR AS
$body$
/**************************************************************************
 SISTEMA:   	Sistema de Activos Fijos
 FUNCION:     	kaf.f_procesa_detalle_depreciacion__extra_tmp
 DESCRIPCION:   Función temporal para aplicar lógica específica al generar reporte de depreciación
 AUTOR:      	RCM
 FECHA:         20/04/2020
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #58    KAF       ETR           20/04/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE


BEGIN

	IF DATE_TRUNC('month', p_mes) = '01-03-2020'::DATE THEN

		UPDATE kaf.treporte_detalle_dep AA SET
	    af_traspasos = - ROUND(DD.monto_vigente, 2),
	    depreciacion_acum_traspasos = 0,
	    monto_vigente_orig = af_altas,
	    af_altas = 0
	    FROM (
	        WITH tori AS (
	            SELECT
	            afv.id_activo_fijo, mdep.id_moneda, mdep.monto_vigente
	            FROM kaf.tmovimiento_af_dep mdep
	            INNER JOIN kaf.tactivo_fijo_valores afv
	            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
	            WHERE DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month', '01-02-2020'::date)
	            AND afv.id_activo_fijo in (
	            	40120,59425,59428,59427,59426,59430,59429,55549,59421,35888,55472,59152,59126,48429,48434,48435,48430,47571,47572,
					47573,58879,58936,58996,59098,59442,59397,59422,59061
				)
	        )
	        select
	        afv.id_activo_fijo_valor, afv.id_activo_fijo, afv.id_moneda, ori.monto_vigente
	        from kaf.tactivo_fijo_valores  afv
	        inner join tori ori
	        on ori.id_activo_fijo = afv.id_activo_fijo
	        and ori.id_moneda = afv.id_moneda
	        where afv.id_activo_fijo in (
	        	40120,59425,59428,59427,59426,59430,59429,55549,59421,35888,55472,59152,59126,48429,48434,48435,48430,47571,47572,
				47573,58879,58936,58996,59098,59442,59397,59422,59061
	        )
	        and afv.tipo = 'dval-b'
	        and afv.id_moneda = 1
	    ) DD
	    WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
	    AND AA.id_moneda = 1
	    AND AA.id_activo_fijo = DD.id_activo_fijo;

	    UPDATE kaf.treporte_detalle_dep AA SET
	    depreciacion_acum_traspasos = 0
	    WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
	    AND AA.id_moneda = 1;

	    --REFACTOR de logica para las bolsas
	    UPDATE kaf.treporte_detalle_dep AA SET
		monto_vigente_orig = ROUND(DD.valor_inicial, 2),
		af_traspasos = ROUND(DD.traspasos, 2)
		FROM (
		    with tdep as (
		        select
		        afv.id_activo_fijo, mdep.fecha, mdep.id_moneda, mdep.monto_vigente
		        from kaf.tmovimiento_af_dep mdep
		        inner join kaf.tactivo_fijo_valores afv
		        on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
		    ), tdep_ant as (
		        select
		        afv.id_activo_fijo, mdep.*
		        from kaf.tmovimiento_af_dep mdep
		        inner join kaf.tactivo_fijo_valores afv
		        on afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
		        where mdep.fecha = '01-12-2019'
		    )
		    select
		    afv.id_activo_fijo, afv.codigo,
		    dan.monto_actualiz AS valor_inicial,
		    afv.id_moneda,
		    CASE
		        WHEN DATE_TRUNC('month', afv.fecha_ini_dep) < '01/01/2020'::date THEN 0
		        ELSE -mdep.monto_vigente
		    END AS traspasos
		    from kaf.tmovimiento mov
		    inner join kaf.tmovimiento_af maf
		    on maf.id_movimiento = mov.id_movimiento
		    inner join kaf.tactivo_fijo_valores afv
		    on afv.id_activo_fijo = maf.id_activo_fijo
		    and afv.tipo = 'dval-b'
		    left  join tdep mdep
		    on mdep.id_activo_fijo = afv.id_activo_fijo
		    and DATE_TRUNC('MONTH', mdep.fecha) = DATE_TRUNC('MONTH', afv.fecha_ini_dep - '1 month'::interval)
		    and mdep.id_moneda = afv.id_moneda
		    left join tdep_ant dan
		    on dan.id_activo_fijo = afv.id_activo_fijo
		    and dan.id_moneda = afv.id_moneda
		    where mov.id_cat_movimiento = 238
		    and maf.id_activo_fijo in (
		      40120,59425,59428,59427,59426,59430,59429,55549,59421,35888,
		      55472,59152,59126,48429,48434,48435,48430,47571,47572,47573,
		      58879,58936,58996,59098,59442,59397,59422,59061
		    )
		    and afv.id_moneda = 1
		) DD
		WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
		AND AA.id_moneda = 1
		AND AA.id_activo_fijo = DD.id_activo_fijo;

		--Caso Disgregaciones
		UPDATE kaf.treporte_detalle_dep AA SET
		monto_vigente_orig = 0,
		af_altas = ROUND(DD.af_altas, 2),
		af_traspasos = ROUND(DD.af_traspasos, 2)
		FROM (
		  SELECT
		  CASE
		      WHEN DATE_TRUNC('month', afv.fecha_ini_dep) < '01/01/2020'::date THEN afv.monto_vigente_orig
		      ELSE 0
		  END AS af_altas,
		  CASE
		      WHEN DATE_TRUNC('month', afv.fecha_ini_dep) < '01/01/2020'::date THEN 0
		      ELSE afv.monto_vigente_orig
		  END AS af_traspasos,
		  afv.id_activo_fijo
		  FROM  kaf.treporte_detalle_dep rd
		  INNER JOIN kaf.tmovimiento_af_especial mesp
		  ON mesp.id_activo_fijo = rd.id_activo_fijo
		  INNER JOIN kaf.tactivo_fijo_valores afv
		  ON afv.id_activo_fijo = mesp.id_activo_fijo
		  AND afv.id_moneda = rd.id_moneda
		  WHERE rd.id_moneda = 1
		  AND rd.fecha = '31-03-2020'
		) DD
		WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
		AND AA.id_moneda = 1
		AND AA.id_activo_fijo = DD.id_activo_fijo;

		--Cambio manual en traspasos para igualación manual
		UPDATE kaf.treporte_detalle_dep AA SET
		af_traspasos = DD.valor
		FROM (
		  select
		  CASE AA.id_activo_fijo
		    WHEN 59430 THEN -1707902.21
		    WHEN 59427 THEN -9934172.55
		    WHEN 40120 THEN -71250.93
		    WHEN 59425 THEN -52008213.16
		    WHEN 59428 THEN -1189950.17
		    WHEN 59426 THEN -32091867.54
		    WHEN 59429 THEN -40078076.56
		  END as valor,
		  id_activo_fijo, af_traspasos
		  from kaf.treporte_detalle_dep AA
		  WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
		  AND AA.id_moneda = 1
		  AND AA.id_activo_fijo IN (40120,59425,59428,59427,59426,59430,59429)
		) DD
		WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '31-03-2020'::date)
		AND AA.id_moneda = 1
		AND AA.id_activo_fijo = DD.id_activo_fijo;

		UPDATE kaf.treporte_detalle_dep AA SET
		af_traspasos = DD.valor
		FROM (
		  select
		  CASE AA.id_activo_fijo
		    WHEN 59430 THEN -1707902.21
		    WHEN 59427 THEN -9934172.55
		    WHEN 40120 THEN -71250.93
		    WHEN 59425 THEN -52008213.16
		    WHEN 59428 THEN -1189950.17
		    WHEN 59426 THEN -32091867.54
		    WHEN 59429 THEN -40078076.56
		  END as valor,
		  id_activo_fijo, af_traspasos
		  from kaf.treporte_detalle_dep AA
		  WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
		  AND AA.id_moneda = 1
		  AND AA.id_activo_fijo IN (40120,59425,59428,59427,59426,59430,59429)
		) DD
		WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '31-03-2020'::date)
		AND AA.id_moneda = 1
		AND AA.id_activo_fijo = DD.id_activo_fijo;

		UPDATE kaf.treporte_detalle_dep AA SET
		af_traspasos = DD.valor
		FROM (
		  	SELECT
			CASE rd.id_activo_fijo
				WHEN 65941 THEN rd.af_traspasos + 0.01
				WHEN 65399 THEN rd.af_traspasos + 0.01
				WHEN 65435 THEN rd.af_traspasos + 0.01
				WHEN 65471 THEN rd.af_traspasos + 0.01
				WHEN 65488 THEN rd.af_traspasos + 0.01
				WHEN 65499 THEN rd.af_traspasos + 0.01
				WHEN 65505 THEN rd.af_traspasos + 0.01
				WHEN 66391 THEN rd.af_traspasos - 0.01
				WHEN 66698 THEN rd.af_traspasos + 0.01
				WHEN 66707 THEN rd.af_traspasos + 0.01
				WHEN 66735 THEN rd.af_traspasos + 0.01
				WHEN 66829 THEN rd.af_traspasos + 0.01
				WHEN 66830 THEN rd.af_traspasos + 0.01
				WHEN 66831 THEN rd.af_traspasos + 0.01
			END as valor,
			id_activo_fijo, af_traspasos
			from kaf.treporte_detalle_dep rd
			WHERE DATE_TRUNC('month', rd.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
			AND rd.id_moneda = 1
			AND rd.id_activo_fijo IN (65941,65399,65435,65471,65488,65499,65505,66391,66698,66707,66735,66829,66830,66831)
		) DD
		WHERE DATE_TRUNC('month', AA.fecha) = DATE_TRUNC('month', '31-03-2020'::date)
		AND AA.id_moneda = 1
		AND AA.id_activo_fijo = DD.id_activo_fijo;

		--19/04/2020: actualización activo 02.14.5.0841-0 en aitb dep acum
		UPDATE kaf.treporte_detalle_dep rd SET
		aitb_dep_acum = 1093.89,
		aitb_dep_acum_anual = 3792.92
		WHERE rd.fecha = '31-03-2020'
		AND rd.id_moneda = 1
		AND rd.codigo in ('02.14.5.0841-0');

		UPDATE kaf.treporte_detalle_dep rd SET
		af_altas = DD.valor
		FROM (
			SELECT
			CASE rd.id_activo_fijo
				WHEN 59427 THEN 255738.20
				WHEN 59429 THEN 620517.06
			END as valor,
			id_activo_fijo
			from kaf.treporte_detalle_dep rd
			WHERE DATE_TRUNC('month', rd.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
			AND rd.id_moneda = 1
			AND rd.id_activo_fijo IN (59427, 59429)
		) DD
		WHERE rd.fecha = '31-03-2020'
		AND rd.id_moneda = 1
		AND rd.id_activo_fijo = DD.id_activo_fijo;

		UPDATE kaf.treporte_detalle_dep rd SET
		aitb_dep = rd.aitb_dep - DD.valor,
		aitb_dep_anual = rd.aitb_dep_anual - DD.valor
		FROM (
		    SELECT
		    CASE rd.id_activo_fijo
		        WHEN 59430 THEN rd.aitb_dep - 36.23
		        WHEN 59427 THEN rd.aitb_dep - 131.70
		        WHEN 40120 THEN rd.aitb_dep - 1.26
		        WHEN 59425 THEN rd.aitb_dep - 239.82
		        WHEN 59428 THEN rd.aitb_dep - 15.78
		        WHEN 59426 THEN rd.aitb_dep - 147.98
		        WHEN 59429 THEN rd.aitb_dep - 184.80
		    END as valor,
		    id_activo_fijo,
		    aitb_dep, aitb_dep_anual
		    from kaf.treporte_detalle_dep rd
		    WHERE DATE_TRUNC('month', rd.fecha) = DATE_TRUNC('month', '01-03-2020'::date)
		    AND rd.id_moneda = 1
		    AND rd.id_activo_fijo IN (40120,59425,59428,59426,59427,59429,59430)
		) DD
		WHERE rd.fecha = '31-03-2020'
		AND rd.id_moneda = 1
		AND rd.id_activo_fijo = DD.id_activo_fijo;
		--Fin Cambio

	ELSIF DATE_TRUNC('month', p_mes) = '01-04-2020'::DATE THEN

	END IF;

	RETURN 'hecho';


END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
PARALLEL UNSAFE;