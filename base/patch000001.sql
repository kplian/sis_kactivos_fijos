/***********************************I-SCP-RCM-KAF-1-02/09/2015****************************************/
create table kaf.tclasificacion (
	id_clasificacion serial,
	id_clasificacion_fk integer,
	id_cat_metodo_dep integer,
	id_concepto_ingas integer,
	codigo varchar(15) null,
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
	depreciacion_acum_ant numeric,
	depreciacion_per_ant numeric,
	monto_vigente_ant numeric,
	vida_util_ant integer,
	depreciacion_acum_actualiz numeric,
	depreciacion_per_actualiz numeric,
	monto_actualiz numeric,
	depreciacion numeric,
	depreciacion_acum numeric,
	depreciacion_per numeric,
	monto_vigente numeric,
	vida_util integer,
	tipo_cambio_ini numeric(18,2),
	tipo_cambio_fin numeric(18,2),
	factor numeric,
	constraint pk_tmovimiento_af_dep__id_movimiento_af_dep primary key (id_movimiento_af_dep)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-02/09/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-11/09/2015****************************************/
alter table kaf.tclasificacion
drop column porcentaje_dep;

alter table kaf.tactivo_fijo
add column fecha_ult_dep date;

create function months_of(interval)
 returns int strict immutable language sql as $$
  select extract(years from $1)::int * 12 + extract(month from $1)::int
$$;

create function months_between(date, date)
 returns int strict immutable language sql as $$
   select abs(months_of(age($1, $2)))
$$;
/***********************************F-SCP-RCM-KAF-1-11/09/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-21/09/2015****************************************/
alter table kaf.tactivo_fijo
drop column depreciacion_acum_ant;

alter table kaf.tactivo_fijo
add column depreciacion_per numeric;

alter table kaf.tactivo_fijo
add column monto_rescate numeric(18,2);

alter table kaf.tactivo_fijo
add column depreciacion_mes numeric;

alter table kaf.tactivo_fijo
alter column monto_compra_mon_orig type numeric;
alter table kaf.tactivo_fijo
alter column monto_compra type numeric;
alter table kaf.tactivo_fijo
alter column monto_vigente type numeric;
alter table kaf.tactivo_fijo
alter column monto_actualiz type numeric;

/***********************************F-SCP-RCM-KAF-1-21/09/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-06/10/2015****************************************/
create table kaf.tactivo_fijo_valores (
	id_activo_fijo_valor serial,
	id_activo_fijo integer,
	monto_actual_orig numeric, --monto de compra/revalorización/otros
	vida_util_orig integer,
	fecha_ini_dep date,
	depreciacion_mes numeric,
	depreciacion_per numeric,
	depreciacion_acum numeric,
	monto_actual numeric,
	vida_util integer,
	fecha_ult_dep date,
	tipo_cambio_ini numeric,
	tipo_cambio_fin numeric,
	tipo varchar(15), --tipo in ('revaloriz','otros')
	estado varchar(15), -- estado in ('activo','inactivo') :inactivo no deprecia
	principal varchar(2) -- principal in ('si','no')
) inherits (pxp.tbase) without oids;

alter table kaf.tmovimiento_af_dep
add column id_activo_fijo_valor integer;

/***********************************F-SCP-RCM-KAF-1-06/10/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-07/10/2015****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN estado VARCHAR(15); --estado in ('pendiente','procesado','no_procesado')
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN respuesta TEXT;

/***********************************F-SCP-RCM-KAF-1-07/10/2015****************************************/  

/***********************************I-SCP-RCM-KAF-1-08/10/2015****************************************/  
ALTER TABLE kaf.tactivo_fijo
  RENAME COLUMN vida_util TO vida_util_original;

ALTER TABLE kaf.tactivo_fijo
  RENAME COLUMN vida_util_restante TO vida_util;

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN monto_rescate NUMERIC;

ALTER TABLE kaf.tactivo_fijo_valores
  RENAME COLUMN monto_actual_orig TO monto_vigente_orig;

ALTER TABLE kaf.tactivo_fijo_valores
  RENAME COLUMN monto_actual TO monto_vigente;
/***********************************F-SCP-RCM-KAF-1-08/10/2015****************************************/    

/***********************************I-SCP-RCM-KAF-1-10/10/2015****************************************/    
ALTER TABLE kaf.tmovimiento
  RENAME COLUMN descripcion TO glosa;
ALTER TABLE kaf.tmovimiento
  DROP COLUMN fecha_ini;
ALTER TABLE kaf.tmovimiento
  DROP COLUMN observaciones;
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_depto INTEGER;
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_funcionario INTEGER;
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN id_movimiento_motivo INTEGER;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_centro_costo;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_centro_costo_nuevo;  
/***********************************F-SCP-RCM-KAF-1-10/10/2015****************************************/      