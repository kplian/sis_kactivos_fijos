CREATE OR REPLACE FUNCTION "kaf"."ftmp_migracion_activos"()
  RETURNS "pg_catalog"."varchar" AS $BODY$BEGIN

  	/*delete from kaf.tmovimiento_af;
	delete from kaf.tmovimiento;
	delete from kaf.tactivo_fijo_valores;
	delete from kaf.tactivo_fijo;

	SELECT setval('"kaf"."tactivo_fijo_id_activo_fijo_seq"', 1, false);
	SELECT setval('"kaf"."tactivo_fijo_valores_id_activo_fijo_valor_seq"', 1, true);
	SELECT setval('"kaf"."tmovimiento_id_movimiento_seq"', 1, true);
	SELECT setval('"kaf"."tmovimiento_af_id_movimiento_af_seq"', 1, true);*/
	
	insert into kaf.tactivo_fijo (
	"id_usuario_reg",
	"id_clasificacion",
	"codigo",
	"denominacion",
	"descripcion",
	"estado",
	"cantidad_revaloriz",
	"fecha_ini_dep",
	"monto_compra",
	"id_moneda_orig",
	"fecha_compra",
	"id_proveedor",
	"vida_util_original",
	"id_cat_estado_compra",
	"id_cat_estado_fun",
	"monto_rescate",
	"id_depto",
	"id_oficina",
	"id_deposito",
	"ubicacion",
	"id_moneda",
	"depreciacion_mes",
	"depreciacion_acum",
	"depreciacion_per",
	"monto_vigente",
	"vida_util",
	"id_funcionario",
	"id_mig"
	)
	select 
	1,
	cla.id_clasificacion,
	cla.codigo||'.'||mig."CORRELATIVO",
	mig."DESCRIPCION",
	mig."DESCRIPCION",
	'alta',
	0,
	mig."FECHA",
	1, --monto_compra
	1, --id_moneda_orig
	mig."FECHA",
	1,
	coalesce(cla.vida_util,1),
	81, --estado_compra
	90, --estado_funcional
	coalesce(cla.monto_residual,1),
	4, --id_depto
	1, --id_oficina
	5, --id_deposito
	mig."UBICACION",
	1, --id_moneda
	0,
	0,
	0,
	1,
	cla.vida_util,
	95,
	mig."ID"
	from kaf.tmp_migracion mig
	left join kaf.tclasificacion cla
	on cla.codigo = mig."COD" ||'.'||mig."COD AREA"||'.'||mig."GRUPO CONT"||'.'||mig."TIPO DE ACTIVO";

	insert into kaf.tactivo_fijo_valores (
		"id_usuario_reg",
		"fecha_mod",
		"id_activo_fijo",
		"monto_vigente_orig",
		"vida_util_orig",
		"fecha_ini_dep",
		"depreciacion_mes",
		"depreciacion_per",
		"depreciacion_acum",
		"monto_vigente",
		"vida_util",
		"estado",
		"principal",
		"monto_rescate"
	)
	select
	1,null,af.id_activo_fijo,af.monto_compra,af.vida_util,
	af.fecha_ini_dep,0,0,0,af.monto_compra,af.vida_util,
	'activo','si',af.monto_rescate
	from kaf.tactivo_fijo af;

	--Actualiza el correlativo de las clasificaciones
	update kaf.tclasificacion set
	correlativo_act = cast(a.correl as int4)
	from (select
	id_clasificacion, max(cast(substring(codigo,15,10) as int4)) as correl
	from kaf.tactivo_fijo
	group by id_clasificacion) a
	where a.id_clasificacion = kaf.tclasificacion.id_clasificacion;


	return 'done';

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100
;