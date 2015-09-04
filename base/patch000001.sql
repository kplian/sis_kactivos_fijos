/***********************************I-SCP-RCM-KAF-1-02/09/2015****************************************/
create table kaf.tclasificacion (
	id_clasificacion serial,
	id_clasificacion_fk integer,
	id_cat_metodo_dep integer,
	id_concepto_ingas integer,
	codigo varchar(15) not null,
	nombre varchar(50) not null,
	vida_util integer,
	porcentaje_dep numeric (5,2),
	correlativo_act integer,
	monto_residual numeric(18,2),
	tipo varchar(10), --('bien','activo')
	final varchar(2), --('si','no')
	icono varchar(20),
	constraint pk_tclasificacion__id_clasificacion primary key (id_clasificacion)
) inherits (pxp.tbase) without oids;

create table kaf.tactivo_fijo (
	id_activo_fijo serial,
	id_clasificacion integer,
	id_moneda integer,
	id_moneda_orig integer,
	id_cat_estado_fun integer,  --actual
	id_depto integer,           --actual
	id_centro_costo integer,    --actual
	id_funcionario integer,     --actual
	id_persona integer,         --actual
	codigo varchar(50) not null,
	denominacion varchar(100),
	descripcion varchar(5000),
	vida_util integer,
	vida_util_restante integer,
	monto_compra_mon_orig numeric(18,2),
	monto_compra numeric(18,2),
	monto_vigente numeric(18,2),
	monto_actualiz numeric(18,2),
	foto varchar(100),
	estado varchar(15),
	documento varchar(50),
	fecha_ini_dep date,
	depreciacion_acum numeric(18,2),
	depreciacion_acum_ant numeric(18,2),
	observaciones varchar(5000),
	constraint pk_tactivo_fijo__id_activo_fijo primary key (id_activo_fijo)
) inherits (pxp.tbase) without oids;

create table kaf.tmovimiento (
	id_movimiento serial,
	id_cat_movimiento integer,
	id_estado_wf integer,
	id_proceso_wf integer,
	descripcion varchar(200),
	fecha_ini date,
	fecha_hasta date,
	estado varchar(15),
	observaciones varchar(500),
	constraint pk_tmovimiento__id_movimiento primary key (id_movimiento)
) inherits (pxp.tbase) without oids;

create table kaf.tmovimiento_af (
	id_movimiento_af serial,
	id_movimiento integer,
	id_activo_fijo integer,
	id_cat_estado_fun integer,
	id_depto integer,
	id_centro_costo integer,
	id_funcionario integer,
	id_persona integer,
	vida_util integer,
	monto_vigente numeric(18,2),
	id_cat_estado_fun_nuevo integer,
	id_depto_nuevo integer,
	id_centro_costo_nuevo integer,
	id_funcionario_nuevo integer,
	vida_util_nuevo integer,
	monto_vigente_nuevo numeric(18,2),
	constraint pk_tmovimiento_af__id_movimiento_af primary key (id_movimiento_af)
) inherits (pxp.tbase) without oids;

create table kaf.tmovimiento_af_dep (
	id_movimiento_af_dep serial,
	id_movimiento_af integer,
	id_moneda integer,
	tipo_cambio_ini numeric(18,2),
	tipo_cambio_fin numeric(18,2),
	monto_vigente numeric(18,2),
	vida_util integer,
	depreciacion numeric(18,2),
	depreciacion_acum_ant numeric(18,2),
	depreciacion_acum numeric(18,2),
	constraint pk_tmovimiento_af_dep__id_movimiento_af_dep primary key (id_movimiento_af_dep)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-02/09/2015****************************************/