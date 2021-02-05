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

CREATE TABLE kaf.tactivo_fijo (
  id_activo_fijo SERIAL,
  id_clasificacion INTEGER,
  codigo VARCHAR(50),
  denominacion VARCHAR(100),
  descripcion VARCHAR(5000),
  foto VARCHAR(100),
  estado VARCHAR(15),
  cantidad_revaloriz integer,
  fecha_ini_dep DATE,
  monto_compra numeric,
  id_moneda_orig INTEGER,
  fecha_compra date,
  documento varchar(100),
  id_proveedor integer,
  vida_util_original integer,
  id_cat_estado_compra integer,
  id_cat_estado_fun INTEGER,
  observaciones VARCHAR(5000),
  fecha_ult_dep DATE,
  monto_rescate NUMERIC(18,2),
  id_centro_costo INTEGER,
  id_depto INTEGER,
  id_oficina integer,
  id_deposito integer,
  ubicacion varchar(1000),
  id_moneda INTEGER,
  depreciacion_mes NUMERIC,
  depreciacion_acum NUMERIC,
  depreciacion_per NUMERIC,
  monto_vigente NUMERIC,
  vida_util INTEGER,
  id_funcionario INTEGER,
  id_persona INTEGER,
  CONSTRAINT pk_tactivo_fijo__id_activo_fijo PRIMARY KEY(id_activo_fijo)
) INHERITS (pxp.tbase)
WITHOUT OIDS;

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
	tipo_cambio_fin numeric,
	factor numeric,
	constraint pk_tmovimiento_af_dep__id_movimiento_af_dep primary key (id_movimiento_af_dep)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-02/09/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-11/09/2015****************************************/
alter table kaf.tclasificacion
drop column porcentaje_dep;


/***********************************F-SCP-RCM-KAF-1-11/09/2015****************************************/

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

/***********************************I-SCP-RCM-KAF-1-25/10/2015****************************************/
ALTER TABLE kaf.tmovimiento
  ADD COLUMN num_tramite VARCHAR(200);
ALTER TABLE kaf.tmovimiento
  ADD COLUMN fecha_mov DATE;
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_oficina INTEGER;
ALTER TABLE kaf.tmovimiento
  ADD COLUMN direccion VARCHAR(500);

COMMENT ON COLUMN kaf.tmovimiento.id_cat_movimiento
IS 'Catálogo para el Movimiento de activos fijos (Alta, Baja, etc.)';
COMMENT ON COLUMN kaf.tmovimiento.fecha_hasta
IS 'Aplicable a la Depreciación. Límite superior para la ejecución de la deprecación.';
COMMENT ON COLUMN kaf.tmovimiento.id_funcionario
IS 'Aplicable a Asignación y Devolución';
COMMENT ON COLUMN kaf.tmovimiento.id_oficina
IS 'Aplicable a Asignación y Devolución';
COMMENT ON COLUMN kaf.tmovimiento.direccion
IS 'Aplicable a Asignación y Devolución';
/***********************************F-SCP-RCM-KAF-1-25/10/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-28/10/2015****************************************/
COMMENT ON COLUMN kaf.tactivo_fijo.estado
IS 'Estado del activo fijo';
COMMENT ON COLUMN kaf.tactivo_fijo.cantidad_revaloriz
IS 'Contador de las revalorizaciones realizadas al activo fijo';
COMMENT ON COLUMN kaf.tactivo_fijo.documento
IS 'Numero de factura, recibo, nota de remision con la que se realizo la adquisicion del activo fijo';
COMMENT ON COLUMN kaf.tactivo_fijo.id_cat_estado_compra
IS 'Catalogo, estado del activo a la compra: nuevo, usado';
COMMENT ON COLUMN kaf.tactivo_fijo.id_cat_estado_fun
IS 'Catalogo, estado funcional actual del activo fijo';
/***********************************F-SCP-RCM-KAF-1-28/10/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-09/11/2015****************************************/
create table kaf.tdeposito (
	id_deposito serial,
	id_depto integer not null,
	id_funcionario integer not null,
	id_oficina integer not null,
	codigo varchar(15) not null,
	nombre varchar(50) not null,
	ubicacion varchar(200),
	constraint pk_tdeposito__id_deposito primary key (id_deposito)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-09/11/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-18/03/2016****************************************/
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_depto;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_funcionario;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_cat_estado_fun_nuevo;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_depto_nuevo;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN id_persona;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN vida_util_nuevo;
ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN monto_vigente_nuevo;
ALTER TABLE kaf.tmovimiento_af
  RENAME COLUMN monto_vigente TO importe;
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_responsable_depto INTEGER;

COMMENT ON COLUMN kaf.tmovimiento.id_responsable_depto
IS 'Id del funcionario responsable del dpto en la fecha de procesamiento del movimiento';
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_persona INTEGER;

COMMENT ON COLUMN kaf.tmovimiento.id_persona
IS 'Id de la persona que estara como custodio de los activos fijos';


CREATE TABLE kaf.tmovimiento_motivo (
  id_movimiento_motivo SERIAL,
  id_cat_movimiento INTEGER NOT NULL,
  motivo VARCHAR(100) NOT NULL,
  PRIMARY KEY(id_movimiento_motivo)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE kaf.tmovimiento_af
  DROP COLUMN estado;

ALTER TABLE kaf.tmovimiento
  ADD COLUMN codigo VARCHAR(50);

COMMENT ON COLUMN kaf.tmovimiento.codigo
IS 'Codigo o numero del reporte generado';

ALTER TABLE kaf.tmovimiento
  ALTER COLUMN glosa TYPE VARCHAR(1500) COLLATE pg_catalog."default";

/***********************************F-SCP-RCM-KAF-1-18/03/2016****************************************/

/***********************************I-SCP-RCM-KAF-1-23/03/2016****************************************/
CREATE TABLE kaf.tmovimiento_tipo (
  id_movimiento_tipo SERIAL,
  id_cat_movimiento INTEGER NOT NULL,
  id_proceso_macro INTEGER NOT NULL,
  PRIMARY KEY(id_movimiento_tipo)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE kaf.tmovimiento_tipo
  ADD CONSTRAINT uq_tmovimiento_tipo__id_cat_movimiento__id_proceso_macro
    UNIQUE (id_cat_movimiento, id_proceso_macro);

ALTER TABLE kaf.tclasificacion
  ADD COLUMN descripcion VARCHAR(250);

ALTER TABLE kaf.tclasificacion
  ALTER COLUMN nombre TYPE VARCHAR(100) COLLATE pg_catalog."default";

ALTER TABLE kaf.tclasificacion
  ADD CONSTRAINT uq_tclasificacion__codigo
    UNIQUE (codigo);
/***********************************F-SCP-RCM-KAF-1-23/03/2016****************************************/

/***********************************I-SCP-RCM-KAF-1-03/04/2016****************************************/
ALTER TABLE "kaf"."tactivo_fijo_valores"
ADD COLUMN "id_movimiento_af" int4,
ADD PRIMARY KEY ("id_activo_fijo_valor");

/***********************************F-SCP-RCM-KAF-1-03/04/2016****************************************/

/***********************************I-SCP-RCM-KAF-1-04/04/2016****************************************/
ALTER TABLE "kaf"."tactivo_fijo"
ALTER COLUMN "denominacion" TYPE varchar(500) COLLATE "default";
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "en_deposito" varchar(2);
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "fecha_baja" date;
/***********************************F-SCP-RCM-KAF-1-04/04/2016****************************************/

/***********************************I-SCP-RCM-KAF-1-18/04/2016****************************************/
ALTER TABLE "kaf"."tmovimiento_af_dep"
ADD COLUMN "fecha" date;
/***********************************F-SCP-RCM-KAF-1-18/04/2016****************************************/

/***********************************I-SCP-RCM-KAF-2-18/04/2015****************************************/
create table kaf.ttipo_bien (
	id_tipo_bien serial,
	codigo varchar(20) null,
	descripcion varchar(100) not null,
	constraint pk_ttipo_bien__id_tipo_bien primary key (id_tipo_bien)
) inherits (pxp.tbase) without oids;

create table kaf.ttipo_cuenta (
	id_tipo_cuenta serial,
	codigo varchar(25) null,
	descripcion varchar(150) not null,
	codigo_corto varchar(10) null,
	constraint pk_ttipo_cuenta__id_tipo_cuenta primary key (id_tipo_cuenta)
) inherits (pxp.tbase) without oids;

create table kaf.ttipo_bien_cuenta (
	id_tipo_bien_cuenta serial,
	id_tipo_bien integer,
	id_tipo_cuenta integer,
	constraint pk_ttipo_bien_cuenta__id_tipo_bien_cuenta primary key (id_tipo_bien_cuenta)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-2-18/04/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-19/04/2016****************************************/
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "codigo_ant" varchar(50);
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "marca" varchar(200);
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "nro_serie" varchar(50);
ALTER TABLE "kaf"."tactivo_fijo"
ADD COLUMN "caracteristicas" text;
/***********************************F-SCP-RCM-KAF-1-19/04/2016****************************************/

/***********************************I-SCP-RCM-KAF-1-20/04/2015****************************************/
create table kaf.tactivo_fijo_caract (
	id_activo_fijo_caract serial,
	clave varchar(100),
	valor varchar(1000),
	constraint pk_tactivo_fijo_caract__id_activo_fijo_caract primary key (id_activo_fijo_caract)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-20/04/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-07/05/2015****************************************/
alter table kaf.tactivo_fijo_valores
add column codigo varchar(50);
/***********************************F-SCP-RCM-KAF-1-07/05/2015****************************************/

/***********************************I-SCP-RCM-KAF-1-07/05/2015****************************************/
ALTER TABLE "kaf"."tmovimiento"
ALTER COLUMN "estado" DROP DEFAULT,
ADD COLUMN "id_deposito" int4,
ADD COLUMN "id_depto_dest" int4,
ADD COLUMN "id_deposito_dest" int4,
ADD COLUMN "id_funcionario_dest" int4;

COMMENT ON COLUMN "kaf"."tmovimiento"."glosa" IS 'Para todos los movimientos';

COMMENT ON COLUMN "kaf"."tmovimiento"."estado" IS 'Estado de aprobacion del Movimiento';

COMMENT ON COLUMN "kaf"."tmovimiento"."id_depto" IS 'Depto. de Activos Fijos al que pertenece el activo';

COMMENT ON COLUMN "kaf"."tmovimiento"."id_deposito" IS 'Deposito al que pertenece el activo fijo. Aplicable a todos.';

COMMENT ON COLUMN "kaf"."tmovimiento"."id_depto_dest" IS 'Depto. Activos Fijos destino. Para Transferencia Deposito';

COMMENT ON COLUMN "kaf"."tmovimiento"."id_deposito_dest" IS 'Deposito  Activos Fijos destino. Para Transferencia Deposito';

COMMENT ON COLUMN "kaf"."tmovimiento"."id_funcionario_dest" IS 'Funcionario destino. Solo para transferencias';
/***********************************F-SCP-RCM-KAF-1-07/05/2015****************************************/



/***********************************I-SCP-RCM-KAF-1-27/11/2016****************************************/


--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN extension VARCHAR(20);

  --------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_caract
  ADD COLUMN id_activo_fijo INTEGER;

/***********************************F-SCP-RCM-KAF-1-27/11/2016****************************************/



/***********************************I-SCP-RAC-KAF-1-10/02/2017****************************************/

--estas columnas daban error al listar movimientos

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_deposito INTEGER;


  --------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_depto_dest INTEGER;

  --------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_deposito_dest INTEGER;

  --------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_funcionario_dest INTEGER;

  --------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_movimiento_motivo INTEGER;

/***********************************F-SCP-RAC-KAF-1-10/02/2017****************************************/




/***********************************I-SCP-RAC-KAF-1-04/04/2017****************************************/

--------------- SQL ---------------

ALTER TABLE kaf.tclasificacion
  ADD COLUMN tipo_activo VARCHAR(30) DEFAULT 'tangible' NOT NULL;

COMMENT ON COLUMN kaf.tclasificacion.tipo_activo
IS 'tangible o intangible';


--------------- SQL ---------------

ALTER TABLE kaf.tclasificacion
  ADD COLUMN depreciable VARCHAR(4) DEFAULT 'si' NOT NULL;

COMMENT ON COLUMN kaf.tclasificacion.depreciable
IS 'si se aplicaqn o no depreciaciones';



/***********************************F-SCP-RAC-KAF-1-04/04/2017****************************************/




/***********************************I-SCP-RAC-KAF-1-10/04/2017****************************************/


--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN tipo_cambio_ini TYPE NUMERIC;


  --------------- SQL ---------------

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN tipo_cambio_ini TYPE NUMERIC;


--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN monto_actualiz_ant NUMERIC DEFAULT 0 NOT NULL;

/***********************************F-SCP-RAC-KAF-1-10/04/2017****************************************/





/***********************************I-SCP-RAC-KAF-1-20/04/2017****************************************/



  --------------- SQL ---------------

CREATE TABLE kaf.tmoneda_dep (
  id_moneda_dep SERIAL,
  id_moneda INTEGER,
  id_moneda_act INTEGER,
  contabilizar VARCHAR(5) DEFAULT 'no' NOT NULL,
  actualizar VARCHAR(5) DEFAULT 'no' NOT NULL,
  PRIMARY KEY(id_moneda_dep)
) INHERITS (pxp.tbase)

WITH (oids = false);

COMMENT ON COLUMN kaf.tmoneda_dep.id_moneda_act
IS 'indica que moenda se utiliza para actualizar';

COMMENT ON COLUMN kaf.tmoneda_dep.contabilizar
IS 'solo una de la monedas puede contabilizar , esa sera considerada la principal';

COMMENT ON COLUMN kaf.tmoneda_dep.actualizar
IS 'indica si esta moneda actualiza en tal casola moneda de actulizacion tiene que estar configurada';



--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN id_moneda_dep INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.id_moneda_dep
IS 'indica la configuracion utilizada para la depreciacion / actualizacion';



--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN id_movimiento_af_dep DROP DEFAULT;

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN id_movimiento_af_dep TYPE BIGINT;

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN id_movimiento_af_dep SET DEFAULT nextval('kaf.tmovimiento_af_dep_id_movimiento_af_dep_seq'::regclass);



--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN monto_compra_mt NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo.monto_compra_mt
IS 'monto de la compra en moneda de la trasaccion, indicada por el id_moneda';


--------------- SQL ---------------

COMMENT ON COLUMN kaf.tactivo_fijo.monto_compra
IS 'monto de la compra en moneda base';



--------------- SQL ---------------

COMMENT ON COLUMN kaf.tactivo_fijo.monto_rescate
IS 'monto de rescate en moneda base';

--------------- SQL ---------------

COMMENT ON COLUMN kaf.tactivo_fijo.monto_vigente
IS 'este campo esta obsoleto no utilizar, el monto vigente real se obtiene de la vista de base de datos vactivo_fijo';

--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN id_moneda INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.id_moneda
IS 'moneda en que estan regitrado los montos';


--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN id_moneda_dep INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.id_moneda_dep
IS 'configuracion de moneda con que se realizo el registro de depreicacion';

/***********************************F-SCP-RAC-KAF-1-20/04/2017****************************************/


/***********************************I-SCP-RAC-KAF-1-25/04/2017****************************************/

--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN tipo_reg VARCHAR(100) DEFAULT 'manual' NOT NULL;

COMMENT ON COLUMN kaf.tactivo_fijo.tipo_reg
IS 'manual, preingreso, division, identifica la forma en que fue creado el activo fijo';


--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN num_div INTEGER DEFAULT 0 NOT NULL;

COMMENT ON COLUMN kaf.tactivo_fijo.num_div
IS 'controla el numero de divisiones del activo fijo';

--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN fecha_inicio DATE;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.fecha_inicio
IS 'fecha desde que considerar este regitro de valor para el activo fijo';

--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN fecha_fin DATE;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.fecha_fin
IS 'fecha hasta al cual se considera el valor de este activo fijo';


--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN deducible VARCHAR(6) DEFAULT 'si' NOT NULL;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.deducible
IS 'no o  si,  si es decubile el gasto peude reducirce del impuesto a las utilidades';

--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN id_activo_fijo_valor_original INTEGER;



COMMENT ON COLUMN kaf.tactivo_fijo_valores.id_activo_fijo_valor_original
IS 'indetifica el valor origen para el caso de activos que se dividen';

--------------- SQL ---------------

COMMENT ON COLUMN kaf.tmovimiento_af.importe
IS 'es importe siemre estara en moneda base';


/***********************************F-SCP-RAC-KAF-1-25/04/2017****************************************/


/***********************************I-SCP-RAC-KAF-1-29/04/2017****************************************/


--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN id_proyecto INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo.id_proyecto
IS 'indetifica el proyecto dodne se carga las depreciaciones dela citvo fijo, peude obtener del centro de costo de la compra pero no es obligatorio esta dato peude cambiarce en cualqeuir momento';



/***********************************F-SCP-RAC-KAF-1-29/04/2017****************************************/


/***********************************I-SCP-RAC-KAF-1-02/05/2017****************************************/

 CREATE TABLE kaf.ttipo_prorrateo (
  id_tipo_prorrateo SERIAL,
  id_proyecto INTEGER,
  id_activo_fijo INTEGER,
  id_centro_costo INTEGER,
  id_ot INTEGER,
  descripcion VARCHAR,
  factor NUMERIC DEFAULT 1 NOT NULL,
  id_gestion INTEGER,
  CONSTRAINT ttipo_prorrateo_pkey PRIMARY KEY(id_tipo_prorrateo)
) INHERITS (pxp.tbase)

WITH (oids = false);

COMMENT ON COLUMN kaf.ttipo_prorrateo.id_activo_fijo
IS 'opcional, primero se busca configuracion para el activo si no hay busca configuracion para el proyecto';


--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_int_comprobante INTEGER;

COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante
IS 'hace referencia al comproante contable del movimeitno, ejm si es de depreciacion el cbte sera el de depreciacion';


--------------- SQL ---------------

ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_int_comprobante_aitb INTEGER;

COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante_aitb
IS 'solo para movimiento de depreciacion, este es el comprobante de actulizacion y tenencia de bienes';


--------------- SQL ---------------

ALTER TABLE kaf.tclasificacion
  ADD COLUMN contabilizar VARCHAR(6) DEFAULT 'no' NOT NULL;

COMMENT ON COLUMN kaf.tclasificacion.contabilizar
IS 'incidique a que nivel de la claisficacion se buscara la relacion contable apra generar comprobantes';

/***********************************F-SCP-RAC-KAF-1-02/05/2017****************************************/



/***********************************I-SCP-RAC-KAF-1-31/05/2017****************************************/


/***********************************F-SCP-RAC-KAF-1-31/05/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-05/06/2017****************************************/
ALTER TABLE kaf.tmovimiento
  ADD COLUMN id_periodo_subsistema INTEGER;
ALTER TABLE kaf.tclasificacion
  DROP CONSTRAINT uq_tclasificacion__codigo RESTRICT;
/***********************************F-SCP-RCM-KAF-1-05/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-19/06/2017****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN id_moneda INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af.id_moneda
IS 'Moneda Base';

ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN depreciacion_acum NUMERIC(18,2);

COMMENT ON COLUMN kaf.tmovimiento_af.depreciacion_acum
IS 'Depreciacion acumulada de inicio solo para movimiento de Ajustes';
/***********************************F-SCP-RCM-KAF-1-19/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-22/06/2017****************************************/
create table kaf.tmovimiento_af_especial(
	id_movimiento_af_especial serial,
	id_movimiento_af  integer not null,
	id_activo_fijo_valor integer,
	id_activo_fijo integer,
	importe numeric(18,2) not null,
	constraint pk_tmovimiento_af_especial__id_movimiento_af_especial primary key (id_movimiento_af_especial)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-22/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-23/06/2017****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT uq_tmovimiento_af__id_movimiento__id_activo_fijo
    UNIQUE (id_activo_fijo, id_movimiento) NOT DEFERRABLE;
/***********************************F-SCP-RCM-KAF-1-23/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-27/06/2017****************************************/
CREATE TABLE kaf.tclasificacion_variable (
  id_clasificacion_variable SERIAL,
  id_clasificacion INTEGER NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  descripcion VARCHAR(500),
  tipo_dato VARCHAR(20),
  obligatorio VARCHAR(2) DEFAULT 'no',
  orden_var INTEGER,
  PRIMARY KEY(id_clasificacion_variable)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE kaf.tactivo_fijo_caract
  ADD COLUMN id_clasificacion_variable INTEGER;

ALTER TABLE kaf.tactivo_fijo_caract
  ADD CONSTRAINT uq_tactivo_fijo_caract__id_activo_fijo__id_clasificacion_variab
    UNIQUE (id_activo_fijo, id_clasificacion_variable) NOT DEFERRABLE;
/***********************************F-SCP-RCM-KAF-1-27/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-28/06/2017****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN id_activo_fijo_creado INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.id_activo_fijo_creado
IS 'Id del activo fijo creado por el Desglose de activos fijos';

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN id_activo_fijo_padre INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo.id_activo_fijo_padre
IS 'Id del activo origen del que se creó el activo';
/***********************************F-SCP-RCM-KAF-1-28/06/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-10/07/2017****************************************/
alter table kaf.tactivo_fijo
add column cantidad_af integer default 1;
alter table kaf.tactivo_fijo
add column id_unidad_medida integer;
/***********************************F-SCP-RCM-KAF-1-10/07/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-12/07/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  RENAME COLUMN monto_compra_mt TO monto_compra_orig;

COMMENT ON COLUMN kaf.tactivo_fijo.monto_compra_orig
IS 'monto de la compra en la moneda original';
/***********************************F-SCP-RCM-KAF-1-12/07/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-26/07/2017****************************************/
alter table kaf.tactivo_fijo
add column monto_compra_orig_100 numeric;
alter table kaf.tactivo_fijo
add column nro_cbte_asociado varchar(50);
alter table kaf.tactivo_fijo
add column fecha_cbte_asociado date;
/***********************************F-SCP-RCM-KAF-1-26/07/2017****************************************/


/***********************************I-SCP-RCM-KAF-1-08/08/2017****************************************/
ALTER TABLE kaf.tclasificacion
  ADD COLUMN codigo_completo_tmp VARCHAR(50);
/***********************************F-SCP-RCM-KAF-1-08/08/2017****************************************/


/***********************************I-SCP-RCM-KAF-1-09/08/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN id_cotizacion_det INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo.id_cotizacion_det
IS 'Id del cotización detalle';

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN id_preingreso_det INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo.id_preingreso_det
IS 'Id del preingeso detalle';

CREATE INDEX idx_tactivo_fijo__id_activo_fijo ON kaf.tactivo_fijo
  USING btree (id_activo_fijo);
/***********************************F-SCP-RCM-KAF-1-09/08/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-15/08/2017****************************************/
CREATE TABLE kaf.tclasificacion_cuenta_motivo (
  id_clasificacion_cuenta_motivo SERIAL,
  id_clasificacion INTEGER NOT NULL,
  id_movimiento_motivo INTEGER NOT NULL,
  PRIMARY KEY(id_clasificacion_cuenta_motivo)
) INHERITS (pxp.tbase);

CREATE UNIQUE INDEX uq_tclasificacion_cuenta_motivo__id_movimiento_motivo__id_clasi ON kaf.tclasificacion_cuenta_motivo
  USING btree (id_movimiento_motivo, id_clasificacion);
/***********************************F-SCP-RCM-KAF-1-15/08/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-16/08/2017****************************************/
COMMENT ON COLUMN kaf.tactivo_fijo_valores.monto_vigente_orig
IS 'Corresponde al Importe del 87%';

alter table kaf.tactivo_fijo_valores
add column  monto_vigente_orig_100 numeric;
/***********************************F-SCP-RCM-KAF-1-16/08/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-22/08/2017****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN importe_ant NUMERIC(18,2);

COMMENT ON COLUMN kaf.tmovimiento_af.importe_ant
IS 'Importe anterior a la realización del movimiento. Usados por los movimientos que mueven importe';


ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN vida_util_ant INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af.vida_util_ant
IS 'Vida útil anterior a la realización del movimiento. Usados por los movimientos que mueven importe y vida útil';
/***********************************F-SCP-RCM-KAF-1-22/08/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-23/08/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN aplicacion_contable VARCHAR(30);

COMMENT ON COLUMN kaf.tactivo_fijo.aplicacion_contable
IS 'Variable que permitirá precisar a que tipo de cuenta irá. Valores posibles (''afecta_concesion'',''no_afecta_concesion'')';

ALTER TABLE kaf.tclasificacion
  ADD COLUMN aplicacion_contable VARCHAR(30);

COMMENT ON COLUMN kaf.tclasificacion.aplicacion_contable
IS 'Variable que permitirá a cada activo fijo precisar a que tipo de cuenta irá. Valores posibles (''afecta_concesion'',''no_afecta_concesion'')';

create table kaf.tactivo_fijo_modificacion (
	id_activo_fijo_modificacion serial,
	id_activo_fijo integer,
	id_oficina integer,
	id_tipo_cc integer,
	ubicacion varchar(1000),
	id_oficina_ant integer,
	id_tipo_cc_ant integer,
	ubicacion_ant varchar(1000),
	observaciones varchar(5000),
	constraint pk_tactivo_fijo_modificacion__id_activo_fijo_modificacion primary key (id_activo_fijo_modificacion)
) inherits (pxp.tbase) without oids;

ALTER TABLE kaf.ttipo_prorrateo
  RENAME COLUMN id_centro_costo TO id_tipo_cc;

COMMENT ON COLUMN kaf.ttipo_prorrateo.id_tipo_cc
IS 'ID del tipo de centro de costo';

ALTER TABLE kaf.ttipo_prorrateo
  DROP COLUMN descripcion;
ALTER TABLE kaf.ttipo_prorrateo
  DROP COLUMN id_gestion;
/***********************************F-SCP-RCM-KAF-1-23/08/2017****************************************/


/***********************************I-SCP-RCM-KAF-1-25/08/2017****************************************/
ALTER TABLE kaf.tmovimiento_motivo
  ADD COLUMN plantilla_cbte VARCHAR(20);

COMMENT ON COLUMN kaf.tmovimiento_motivo.plantilla_cbte
IS 'Código de la Plantilla de Comprobante';
/***********************************F-SCP-RCM-KAF-1-25/08/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-05/10/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN fecha_asignacion date;
/***********************************F-SCP-RCM-KAF-1-05/10/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-06/10/2017****************************************/
ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN id_moneda INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.id_moneda
IS 'Moneda para el caso de modificación de importe de compra antes de depreciar';

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN id_moneda_ant INTEGER;

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.id_moneda_ant
IS 'Moneda anterior en el caso de modificación de importe de compra antes de depreciar';

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN monto_compra_orig NUMERIC(18,2);

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.monto_compra_orig
IS 'Monto de compra (87) para el caso de modificación de importe de compra antes de depreciar';

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN monto_compra_orig_100 NUMERIC(18,2);

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.monto_compra_orig_100
IS 'Monto de compra (100) para el caso de modificación de importe de compra antes de depreciar';

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN monto_compra_orig_ant NUMERIC(18,2);

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.monto_compra_orig_ant
IS 'Monto de compra (87) anterior en el caso de modificación de importe de compra antes de depreciar';

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD COLUMN monto_compra_orig_100_ant NUMERIC(18,2);

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.monto_compra_orig_100_ant
IS 'Monto de compra (100) anterior en el caso de modificación de importe de compra antes de depreciar';
/***********************************F-SCP-RCM-KAF-1-06/10/2017****************************************/

/***********************************I-SCP-RAC-KAF-1-06/10/2017****************************************/
CREATE TABLE kaf.tprorrateo_af (
  id_prorrateo_af BIGSERIAL,
  id_movimiento_af INTEGER NOT NULL,
  id_activo_fijo_valor VARCHAR(20) NOT NULL,
  id_centro_costo INTEGER,
  id_ot INTEGER,
  id_cuenta_dep INTEGER,
  id_partida_dep INTEGER,
  id_auxiliar_dep INTEGER,
  id_cuenta_dep_acum INTEGER,
  id_partida_dep_acum INTEGER,
  id_auxiliar_dep_aucm INTEGER,
  id_cuenta_act_activo INTEGER,
  id_partida_act_activo INTEGER,
  id_auxiliar_act_activo INTEGER,
  id_cuenta_act_dep INTEGER,
  id_partida_act_dep INTEGER,
  id_auxiliar_act_dep INTEGER,
  depreciacion NUMERIC(8,2) DEFAULT 0 NOT NULL,
  depreciacion_acum NUMERIC(8,2) DEFAULT 0 NOT NULL,
  aitb_activo NUMERIC(8,2) DEFAULT 0 NOT NULL,
  aitb_dep_acum NUMERIC(8,2) NOT NULL,
  CONSTRAINT table_pkey PRIMARY KEY(id_prorrateo_af)
)
WITH (oids = false);

ALTER TABLE kaf.tprorrateo_af
  ALTER COLUMN id_activo_fijo_valor SET STATISTICS 0;

COMMENT ON COLUMN kaf.tprorrateo_af.id_centro_costo
IS 'usamos centro de costos apr ala gestion del movimeino, asumimos que odo procesos de depreicacion solo se hace por una gestion';
/***********************************F-SCP-RAC-KAF-1-06/10/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-16/10/2017****************************************/
ALTER TABLE kaf.tmovimiento
  ADD COLUMN prestamo varchar(2);
ALTER TABLE kaf.tmovimiento
  ADD COLUMN fecha_dev_prestamo date;

COMMENT ON COLUMN kaf.tmovimiento.prestamo
IS 'Bandera que indica si la asignación es de tipo Préstamo';
COMMENT ON COLUMN kaf.tmovimiento.fecha_dev_prestamo
IS 'Fecha en la que se debería devolver el préstamos realizado';

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN prestamo varchar(2);
ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN fecha_dev_prestamo date;

COMMENT ON COLUMN kaf.tmovimiento.prestamo
IS 'Bandera que indica si la asignación es de tipo Préstamo';
COMMENT ON COLUMN kaf.tmovimiento.fecha_dev_prestamo
IS 'Fecha en la que se debería devolver el préstamos realizado';

/***********************************F-SCP-RCM-KAF-1-16/10/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-17/10/2017****************************************/
ALTER TABLE kaf.tmovimiento_af_dep
  ADD CONSTRAINT uq_tmovimiento_af_dep__id_activo_fijo_valor__id_moneda_dep__fecha
    UNIQUE (id_activo_fijo_valor, id_moneda_dep, fecha) NOT DEFERRABLE;
/***********************************F-SCP-RCM-KAF-1-17/10/2017****************************************/

/***********************************I-SCP-RCM-KAF-1-08/01/2018****************************************/

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN monto_vigente_actualiz_inicial NUMERIC DEFAULT 0 NOT NULL;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.monto_vigente_actualiz_inicial
IS 'Columna que tiene el monto vigente actualizacion del padre (caso de revalorizaciones, ajustes, etc.)';

/***********************************F-SCP-RCM-KAF-1-08/01/2018****************************************/


/***********************************I-SCP-RCM-KAF-1-21/02/2018****************************************/
ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN registro VARCHAR(15) DEFAULT 'generado' NOT NULL;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.registro
IS 'Tipo de registro: generado, manual';

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN observaciones VARCHAR(5000);

COMMENT ON COLUMN kaf.tmovimiento_af_dep.observaciones
IS 'Observaciones para los registros que se hagan manualmente';
/***********************************F-SCP-RCM-KAF-1-21/02/2018****************************************/


/***********************************I-SCP-RCM-KAF-1-17/04/2018****************************************/
create table kaf.tgrupo (
	id_grupo serial,
	codigo varchar(15) not null,
	nombre varchar(150) not null,
	constraint pk_tgrupo__id_grupo primary key (id_grupo)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-17/04/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-19/04/2018****************************************/
alter table kaf.tmovimiento_tipo
add column plantilla_cbte_uno varchar(20);
alter table kaf.tmovimiento_tipo
add column plantilla_cbte_dos varchar(20);
alter table kaf.tmovimiento_tipo
add column plantilla_cbte_tres varchar(20);
/***********************************F-SCP-RCM-KAF-1-19/04/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-20/04/2018****************************************/
alter table kaf.tmovimiento
add column id_int_comprobante_3 integer;

COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante
IS 'Comprobante de la actualización del activo';
COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante_aitb
IS 'Comprobante de la actualización de la depreciación acumulada';
COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante_3
IS 'Comprobante de la depreciacion';
/***********************************F-SCP-RCM-KAF-1-20/04/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-05/06/2018****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN dependiente VARCHAR(2) DEFAULT 'si' NOT NULL;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.dependiente
IS 'Bandera (si,no) que indica si el activo fijo valor dependerá de los afv padres. Si es dependiente, la lógica será tomar los valores del padre. Si no es dependiente, el afv utilizará sus propios valores para todo';
/***********************************F-SCP-RCM-KAF-1-05/06/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-15/06/2018****************************************/
create table kaf.tubicacion (
	id_ubicacion serial,
	codigo varchar(30) null,
	nombre varchar(100) not null,
	constraint pk_tubicacion__id_ubicacion primary key (id_ubicacion)
) inherits (pxp.tbase) without oids;

alter table kaf.tactivo_fijo
add column id_ubicacion integer;

COMMENT ON COLUMN kaf.tactivo_fijo.id_ubicacion
IS 'Campo creado para almacenar los locales que usa ETR';


/***********************************F-SCP-RCM-KAF-1-15/06/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-10/07/2018****************************************/
alter table kaf.tgrupo
add column tipo varchar(15) default 'grupo' not null;

ALTER TABLE kaf.tgrupo
  ADD CONSTRAINT id_tgrupo__codigo__tipo
    UNIQUE (codigo, tipo) NOT DEFERRABLE;

alter table kaf.tactivo_fijo
add column id_grupo integer;

COMMENT ON COLUMN kaf.tactivo_fijo.id_grupo
IS 'Grupo para generar información en formato AE';

alter table kaf.tactivo_fijo
add column id_grupo_clasif integer;

COMMENT ON COLUMN kaf.tactivo_fijo.id_grupo_clasif
IS 'Grupo de tipo clasificacion de la AE';
/***********************************F-SCP-RCM-KAF-1-10/07/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-09/08/2018****************************************/
alter table kaf.tmovimiento
add column id_int_comprobante_4 integer;

COMMENT ON COLUMN kaf.tmovimiento.id_int_comprobante_4
IS 'Comprobante de la actualización de la depreciación del período';

ALTER TABLE kaf.tmovimiento_tipo
  ADD COLUMN plantilla_cnte_cuatro VARCHAR(20);
/***********************************F-SCP-RCM-KAF-1-09/08/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-03/10/2018****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN monto_compra_sin_actualiz NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo.monto_compra_sin_actualiz
IS 'Monto creado para activación de proyectos, para  tener el dato del activo sin la actualizacion (Bs)';
/***********************************F-SCP-RCM-KAF-1-03/10/2018****************************************/


/***********************************I-SCP-RCM-KAF-1-05/11/2018****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN depreciacion_acum_inicial NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.depreciacion_acum_inicial
IS 'Depreciación acumulada con la que iniciará la depreciación';

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN depreciacion_per_inicial NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.depreciacion_per_inicial
IS 'Depreciación del período con el que iniciará la depreciación';



ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN depreciacion_per NUMERIC;

COMMENT ON COLUMN kaf.tmovimiento_af.depreciacion_per
IS 'Depreciación del período con el que iniciará la depreciación';

ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN monto_vigente_actualiz NUMERIC;

COMMENT ON COLUMN kaf.tmovimiento_af.monto_vigente_actualiz
IS 'Monto vigente actualizado con el que iniciará la depreciación';

COMMENT ON COLUMN kaf.tmovimiento_af.depreciacion_acum
IS 'Depreciación del período con el que iniciará la depreciación';

ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN fecha_ini_dep DATE;

COMMENT ON COLUMN kaf.tmovimiento_af.fecha_ini_dep
IS 'Fecha de inicio de depreciación cuando son casos que no parte la depreciación desde cero';

ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN id_activo_fijo_valor_original INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af.id_activo_fijo_valor_original
IS 'ID del activo fijo padre del que continúa la depreciación';
/***********************************F-SCP-RCM-KAF-1-05/11/2018****************************************/

/***********************************I-SCP-RCM-KAF-1-08/11/2018****************************************/
create table kaf.treporte_detalle_depreciacion (
   fecha_deprec date,
   id_activo_fijo_valor integer,
    codigo varchar(50),
    denominacion varchar(500),
    fecha_ini_dep date,
    monto_vigente_orig_100 numeric(18,2),
    monto_vigente_orig numeric(18,2),
    inc_actualiz numeric(18,2),
    monto_actualiz numeric(18,2),
    vida_util_orig integer,
    vida_util integer,
    depreciacion_acum_gest_ant numeric(18,2),
    depreciacion_acum_actualiz_gest_ant numeric(18,2),
    depreciacion_per numeric(18,2),
    depreciacion_acum numeric(18,2),
    monto_vigente numeric(18,2),
    codigo_padre varchar(15),
    denominacion_padre varchar(100),
    tipo varchar(50),
    tipo_cambio_fin numeric,
    id_moneda_act integer,
    id_activo_fijo_valor_original integer,
    codigo_ant varchar(50),
    id_moneda integer,
    id_centro_costo integer,
    id_activo_fijo integer,
    codigo_activo varchar,
    afecta_concesion varchar,
    id_activo_fijo_valor_padre integer,
    depreciacion numeric(18,2),
    depreciacion_per_ant numeric
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-1-08/11/2018****************************************/

/***********************************I-SCP-EGS-KAF-1-30/11/2018****************************************/

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN fecha_ant DATE;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.fecha_ant
IS 'En caso de que el mes anterior a esta depreciacion no sea restando 1 mes, entonces aqui debe definirse la fecha de la deprec anterior. Usado para vista de generacion de cbte actualizacion depreciacion acumulada';

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN meses_acum VARCHAR(2) DEFAULT 'no'::character varying NOT NULL;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.meses_acum
IS 'Bandera que define si el registro de la depreciación corresponde a un mes (''no'') o corresponde a varios meses (''si''), por ejemplo en caso de activos de cierre de proyectos que deprecian varios meses pero solo afecta al ultimo mes';


ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN tmp_inc_actualiz_dep_acum NUMERIC;

ALTER TABLE kaf.tmovimiento_af_dep
  ALTER COLUMN tmp_inc_actualiz_dep_acum SET DEFAULT 0;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.tmp_inc_actualiz_dep_acum
IS 'Temporal para guardar la actualización de la pdep. acum en caso de depreciación se sume todo en un mes';
/***********************************F-SCP-EGS-KAF-1-30/11/2018****************************************/

/***********************************I-SCP-EGS-KAF-2-01/12/2018****************************************/

CREATE INDEX treporte_detalle_depreciacion_idx ON kaf.treporte_detalle_depreciacion
  USING btree (id_activo_fijo_valor, fecha_deprec);

-------------- SQL -------------------
CREATE TABLE kaf.tactivo_fijo_valores_procesado (
  id_usuario_reg INTEGER,
  id_usuario_mod INTEGER,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE,
  fecha_mod TIMESTAMP WITHOUT TIME ZONE,
  estado_reg VARCHAR(10),
  id_usuario_ai INTEGER,
  usuario_ai VARCHAR(300),
  id_activo_fijo_valor INTEGER,
  id_activo_fijo INTEGER,
  monto_vigente_orig NUMERIC,
  vida_util_orig INTEGER,
  fecha_ini_dep DATE,
  depreciacion_mes NUMERIC,
  depreciacion_per NUMERIC,
  depreciacion_acum NUMERIC,
  monto_vigente NUMERIC,
  vida_util INTEGER,
  fecha_ult_dep DATE,
  tipo_cambio_ini NUMERIC,
  tipo_cambio_fin NUMERIC,
  tipo VARCHAR(15),
  estado VARCHAR(15),
  principal VARCHAR(2),
  monto_rescate NUMERIC,
  id_movimiento_af INTEGER,
  codigo VARCHAR(50),
  id_moneda_dep INTEGER,
  id_moneda INTEGER,
  fecha_inicio DATE,
  fecha_fin DATE,
  deducible VARCHAR(6),
  id_activo_fijo_valor_original INTEGER,
  monto_vigente_orig_100 NUMERIC,
  monto_vigente_actualiz_inicial NUMERIC,
  dependiente VARCHAR(2),
  af_codigo_ant VARCHAR(50),
  af_codigo VARCHAR(50),
  val_act NUMERIC,
  dep_acum NUMERIC
)
WITH (oids = false);

---------------  SQL ----------------------------

CREATE TABLE kaf.tt_nueva_clasificacion (
  agrupador INTEGER,
  nombre VARCHAR(100)
)
WITH (oids = false);
------------- SQL -----------------------------
CREATE TABLE kaf.tt_nueva_clasificacion_activos (
  codigo VARCHAR(100),
  codigo_sap VARCHAR(50),
  agrupador INTEGER,
  codigo_nuevo VARCHAR(50),
  denominacion VARCHAR(200)
)
WITH (oids = false);

-------------SQL -----------------------------

CREATE TABLE kaf.tactivo_fijo_cta_tmp (
  id_usuario_reg INTEGER,
  id_usuario_mod INTEGER,
  fecha_reg TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  fecha_mod TIMESTAMP WITHOUT TIME ZONE DEFAULT now(),
  estado_reg VARCHAR(10) DEFAULT 'activo'::character varying,
  id_usuario_ai INTEGER,
  usuario_ai VARCHAR(300),
  id_activo_fijo_cta_tmp SERIAL,
  id_activo_fijo INTEGER,
  nro_cuenta VARCHAR(20),
  codigo_af VARCHAR(50),
  CONSTRAINT tactivo_fijo_cta_tmp_pkey PRIMARY KEY(id_activo_fijo_cta_tmp)
) INHERITS (pxp.tbase)
WITH (oids = false);


---------------- SQL -----------------
ALTER TABLE kaf.tmovimiento_tipo
  ADD COLUMN plantilla_cbte_cuatro VARCHAR(20);
------------- SQL --------------------------------

ALTER TABLE kaf.tactivo_fijo
  ADD COLUMN afecta_concesion VARCHAR(2) DEFAULT 'no'::character varying NOT NULL;


COMMENT ON COLUMN kaf.tactivo_fijo.id_grupo
IS '';

COMMENT ON COLUMN kaf.tactivo_fijo_modificacion.monto_compra_orig
IS '';

COMMENT ON COLUMN kaf.tactivo_fijo_valores.monto_vigente_orig
IS 'Corresponde al Importe  del 87%';

ALTER TABLE kaf.tactivo_fijo_modificacion
  DROP COLUMN id_tipo_cc_ant;

ALTER TABLE kaf.tactivo_fijo_modificacion
  DROP COLUMN id_tipo_cc;

ALTER TABLE kaf.tmovimiento_tipo
  DROP COLUMN plantilla_cnte_cuatro;

/***********************************F-SCP-EGS-KAF-2-01/12/2018****************************************/



/***********************************I-SCP-EGS-KAF-3-01/12/2018****************************************/
--------------- SQL ---------------

ALTER TABLE kaf.tmoneda_dep
  ADD COLUMN descripcion VARCHAR(200);
/***********************************F-SCP-EGS-KAF-3-01/12/2018****************************************/

/***********************************I-SCP-RCM-KAF-0-10/12/2018****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN sw_modif_valor VARCHAR(2);

COMMENT ON COLUMN kaf.tactivo_fijo_valores.sw_modif_valor
IS 'Bandera que indica si el AFV corresponde a una modificación de valor (incremento, decremento) (Para considerar en el reporte detalle de depreciación)';

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN importe_modif NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.importe_modif
IS 'Importe cuando corresponde a un incremento/decremento, caso cuando viene de Ajustes creados por cierre de proyectos';

ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN importe_modif NUMERIC;

COMMENT ON COLUMN kaf.tmovimiento_af.importe_modif
IS 'Importe cuando corresponde a un incremento/decremento, caso cuando viene de Ajustes creados por cierre de proyectos';
/***********************************F-SCP-RCM-KAF-0-10/12/2018****************************************/

/***********************************I-SCP-RCM-KAF-0-08/02/2019****************************************/
ALTER TABLE kaf.ttipo_prorrateo
  ADD COLUMN id_gestion INTEGER NOT NULL;
/***********************************F-SCP-RCM-KAF-0-08/02/2019****************************************/

/***********************************I-SCP-RCM-KAF-8-08/05/2019****************************************/
create table kaf.tactivo_fijo_cc (
	id_activo_fijo_cc serial,
	id_activo_fijo integer not null,
	id_centro_costo integer not null,
	mes date not null,
	cantidad_horas numeric(18,2) not null,
	constraint pk_tactivo_fijo_cc__id_activo_fijo_cc primary key (id_activo_fijo_cc)
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-RCM-KAF-8-08/05/2019****************************************/

/***********************************I-SCP-MZM-KAF-8-14/05/2019****************************************/
create table kaf.tactivo_fijo_cc_log (
  id_activo_fijo_cc_log SERIAL,
  activo_fijo VARCHAR NOT NULL,
  centro_costo VARCHAR NOT NULL,
  mes DATE NOT NULL,
  cantidad_horas NUMERIC(18,2) NOT NULL,
  detalle TEXT NOT NULL,
  nombre_archivo VARCHAR
) inherits (pxp.tbase) without oids;
/***********************************F-SCP-MZM-KAF-8-14/05/2019****************************************/

/***********************************I-SCP-RCM-KAF-2-21/05/2019****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN porcentaje NUMERIC(18,2);

COMMENT ON COLUMN kaf.tmovimiento_af_especial.porcentaje
IS '(Distribución de valores)Porcentaje a tomar en cuenta del importe del activo fijo original';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN id_clasificacion INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.id_clasificacion
IS 'Utilizado cuando se creara un nuevo activo fijo';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN denominacion VARCHAR(500);

COMMENT ON COLUMN kaf.tmovimiento_af_especial.denominacion
IS 'Utilizado cuando se creara un nuevo activo fijo';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN fecha_ini_dep DATE;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.fecha_ini_dep
IS 'Utilizado cuando se creara un nuevo activo fijo';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN vida_util INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.vida_util
IS 'Utilizado cuando se creara un nuevo activo fijo';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN id_centro_costo INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.id_centro_costo
IS 'Utilizado cuando se creara un nuevo activo';
/***********************************F-SCP-RCM-KAF-2-21/05/2019****************************************/

/***********************************I-SCP-RCM-KAF-2-23/05/2019****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN tipo VARCHAR(15);

COMMENT ON COLUMN kaf.tmovimiento_af_especial.tipo
IS 'Tipo de distribución que se realizará (activo fijo existente, nuevo activo fijo, salida a almacén)';

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN opcion VARCHAR(15);

COMMENT ON COLUMN kaf.tmovimiento_af_especial.opcion
IS 'Opción para la distribución de valores: porcentaje o importe';
/***********************************F-SCP-RCM-KAF-2-23/05/2019****************************************/

/***********************************I-SCP-RCM-KAF-2-06/06/2019****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN id_moneda INTEGER;

ALTER TABLE kaf.tmovimiento_af_especial
  ADD COLUMN id_almacen INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af_especial.id_almacen
IS 'Para el caso de tipo = af_almacen';
/***********************************F-SCP-RCM-KAF-2-06/06/2019****************************************/


/***********************************I-SCP-RCM-KAF-2-24/06/2019****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN mov_esp VARCHAR(50);

COMMENT ON COLUMN kaf.tactivo_fijo_valores.mov_esp
IS 'Valor comodín para deshacer el procesamiento de movimientos especiales';
/***********************************F-SCP-RCM-KAF-2-24/06/2019****************************************/

/***********************************I-SCP-RCM-KAF-17-10/07/2019****************************************/
CREATE TABLE kaf.tgrupo_clasif (
  id_grupo_clasif SERIAL,
  codigo VARCHAR(30) NOT NULL UNIQUE,
  descripcion VARCHAR(300) NOT NULL,
  PRIMARY KEY(id_grupo_clasif)
) INHERITS (pxp.tbase)

WITH (oids = false);

CREATE TABLE kaf.tgrupo_clasif_rel (
  id_grupo_clasif_rel SERIAL,
  id_grupo_clasif INTEGER NOT NULL,
  id_clasificacion INTEGER NOT NULL,
  PRIMARY KEY(id_grupo_clasif_rel)
) INHERITS (pxp.tbase)

WITH (oids = false);

ALTER TABLE kaf.tubicacion
  ADD COLUMN orden INTEGER;
/***********************************F-SCP-RCM-KAF-17-10/07/2019****************************************/

/***********************************I-SCP-RCM-KAF-18-15/07/2019****************************************/
ALTER TABLE kaf.tclasificacion_variable
  ADD COLUMN regex VARCHAR(200);

COMMENT ON COLUMN kaf.tclasificacion_variable.regex
IS 'Expresión regular para validar enla entrada de datos';

ALTER TABLE kaf.tclasificacion_variable
  ADD COLUMN regex_ejemplo VARCHAR(200);

COMMENT ON COLUMN kaf.tclasificacion_variable.regex_ejemplo
IS 'Ejemplo de la Expresión Regular';
/***********************************F-SCP-RCM-KAF-18-15/07/2019****************************************/

/***********************************I-SCP-RCM-KAF-20-23/07/2019****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD COLUMN id_movimiento_af_dep INTEGER;

COMMENT ON COLUMN kaf.tmovimiento_af.id_movimiento_af_dep
IS 'Campo auxiliar para guardar el ID de movimiento af dep, para el caso de Distribución de Valores (dval)';
/***********************************F-SCP-RCM-KAF-20-23/07/2019****************************************/

/***********************************I-SCP-RCM-KAF-23-29/08/2019****************************************/
CREATE TABLE kaf.tcomparacion_af_conta (
	id_comparacion_af_conta SERIAL,
    id_movimiento INTEGER,
    id_int_comprobante INTEGER,
    id_cuenta INTEGER,
    fecha DATE,
    saldo_af NUMERIC,
    saldo_conta NUMERIC,
    diferencia_af_conta NUMERIC,
    CONSTRAINT pk_tcomparacion_af_conta__id_comparacion_af_conta PRIMARY KEY (id_comparacion_af_conta)
) INHERITS (pxp.tbase) WITHOUT OIDS;
/***********************************F-SCP-RCM-KAF-23-29/08/2019****************************************/

/***********************************I-SCP-RCM-KAF-32-24/09/2019****************************************/
CREATE TABLE kaf.treporte_detalle_dep (
    id_movimiento integer,
    id_moneda integer,
    fecha_reg date,
    fecha timestamp,
    numero bigint,
    codigo varchar,
    codigo_ant varchar,
    denominacion varchar,
    fecha_ini_dep date,
    cantidad_af integer,
    desc_unidad_medida varchar,
    codigo_tcc varchar, --10
    nro_serie varchar,
    desc_ubicacion varchar,
    responsable text,
    monto_vigente_orig_100 numeric,
    monto_vigente_orig numeric,
    af_altas numeric,
    af_bajas numeric,
    af_traspasos numeric,
    inc_actualiz numeric,
    monto_actualiz numeric, --20
    vida_util_orig integer,
    vida_util integer,
    vida_util_usada integer,
    depreciacion_acum_gest_ant numeric,
    depreciacion_acum_actualiz_gest_ant numeric,
    depreciacion numeric,
    depreciacion_acum_bajas numeric,
    depreciacion_acum_traspasos numeric,
    depreciacion_acum numeric,
    depreciacion_per numeric, --30
    monto_vigente numeric,
    aitb_dep_acum numeric,
    aitb_dep numeric,
    aitb_dep_acum_anual numeric,
    aitb_dep_anual numeric,
    cuenta_activo text,
    cuenta_dep_acum text,
    cuenta_deprec text,
    desc_grupo varchar,
    desc_grupo_clasif varchar, --40
    cuenta_dep_acum_dos text,
    bk_codigo varchar,
    cc1 varchar(50),
    dep_mes_cc1 numeric(24,2),
    cc2 varchar(50),
    dep_mes_cc2 numeric(24,2),
    cc3 varchar(50),
    dep_mes_cc3 numeric(24,2),
    cc4 varchar(50),
    dep_mes_cc4 numeric(24,2), --50
    cc5 varchar(50),
    dep_mes_cc5 numeric(24,2),
    cc6 varchar(50),
    dep_mes_cc6 numeric(24,2),
    cc7 varchar(50),
    dep_mes_cc7 numeric(24,2),
    cc8 varchar(50),
    dep_mes_cc8 numeric(24,2),
    cc9 varchar(50),
    dep_mes_cc9 numeric(24,2), --60
    cc10 varchar(50),
    dep_mes_cc10 numeric(24,2),
    id_activo_fijo integer,
    nivel integer,
    orden bigint,
    tipo varchar(10) --66
) WITHOUT OIDS;
/***********************************F-SCP-RCM-KAF-32-24/09/2019****************************************/

/***********************************I-SCP-RCM-KAF-33-30/09/2019****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN aux_depmes_tot_del_inc NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.aux_depmes_tot_del_inc
IS 'Columna auxiliar para guardar el total de la depreciación mensual del incremento desde el comienzo de gestion';

ALTER TABLE kaf.tactivo_fijo_valores
  ADD COLUMN aux_inc_dep_acum_del_inc NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.aux_depmes_tot_del_inc
IS 'Columna auxiliar para guardar el total del incremento de la dep. acum. del incremento desde el comienzo de gestion';

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN aux_depmes_tot_del_inc NUMERIC;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.aux_depmes_tot_del_inc
IS 'Columna auxiliar para guardar el total de la depreciación mensual del incremento desde el comienzo de gestion';

ALTER TABLE kaf.tmovimiento_af_dep
  ADD COLUMN aux_inc_dep_acum_del_inc NUMERIC;

COMMENT ON COLUMN kaf.tmovimiento_af_dep.aux_depmes_tot_del_inc
IS 'Columna auxiliar para guardar el total del incremento de la dep. acum. del incremento desde el comienzo de gestion';
/***********************************F-SCP-RCM-KAF-33-30/09/2019****************************************/

/***********************************I-SCP-RCM-KAF-39-26/11/2019****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ALTER COLUMN tipo TYPE VARCHAR(30) COLLATE pg_catalog."default";
/***********************************F-SCP-RCM-KAF-39-26/11/2019****************************************/

/***********************************I-SCP-RCM-KAF-39-29/11/2019****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN nro_serie VARCHAR(50);
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN marca VARCHAR(200);
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN descripcion VARCHAR(5000);
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN cantidad_det NUMERIC(18,2);
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN id_unidad_medida INTEGER;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN ubicacion VARCHAR(255);
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN id_ubicacion INTEGER;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN id_funcionario INTEGER;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN fecha_compra DATE;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN id_grupo INTEGER;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN id_grupo_clasif INTEGER;
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN observaciones VARCHAR(5000);
/***********************************F-SCP-RCM-KAF-39-29/11/2019****************************************/

/***********************************I-SCP-RCM-KAF-45-10/02/2020****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
	ADD COLUMN costo_orig NUMERIC(18, 2);
/***********************************F-SCP-RCM-KAF-45-10/02/2020****************************************/

/***********************************I-SCP-RCM-KAF-50-03/03/2020****************************************/
ALTER TABLE kaf.treporte_detalle_dep
	ADD COLUMN factor NUMERIC;
/***********************************F-SCP-RCM-KAF-50-03/03/2020****************************************/

/***********************************I-SCP-RCM-KAF-56-24/03/2020****************************************/
ALTER TABLE kaf.tactivo_fijo
	ADD COLUMN id_proyecto_activo INTEGER;
ALTER TABLE kaf.tactivo_fijo
	ADD COLUMN id_movimiento_af_especial INTEGER;

ALTER TABLE kaf.tactivo_fijo_valores
	ADD COLUMN id_proyecto_activo INTEGER;
ALTER TABLE kaf.tactivo_fijo_valores
	ADD COLUMN id_preingreso_det INTEGER;
ALTER TABLE kaf.tactivo_fijo_valores
	ADD COLUMN id_movimiento_af_especial INTEGER;
/***********************************F-SCP-RCM-KAF-56-24/03/2020****************************************/

/***********************************I-SCP-RCM-KAF-58-27/04/2020****************************************/
CREATE EXTENSION tablefunc;
DROP FUNCTION kaf.f_define_origen(integer, integer, integer, integer, character varying);
/***********************************F-SCP-RCM-KAF-58-27/04/2020****************************************/

/***********************************I-SCP-RCM-KAF-70-11/08/2020****************************************/
ALTER TABLE kaf.tactivo_fijo_valores
ADD COLUMN fecha_tc_ini_dep DATE;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.fecha_tc_ini_dep
IS 'Fecha para obtener el TC inicial de la primera depreciación del AF, caso cierre de proyectos y disgregaciones';

ALTER TABLE kaf.tactivo_fijo_valores
ADD COLUMN importe_modif_sin_act NUMERIC;

COMMENT ON COLUMN kaf.tactivo_fijo_valores.importe_modif_sin_act
IS 'Importe de la adición del cierre de proyectos sin actualización';

CREATE TABLE kaf.treporte_detalle_dep2 (
  id BIGSERIAL,
  id_movimiento INTEGER,
  id_moneda INTEGER,
  fecha DATE,
  numero BIGINT,
  codigo VARCHAR,
  codigo_sap VARCHAR,
  denominacion VARCHAR,
  fecha_ini_dep DATE,
  cantidad_af INTEGER,
  unidad_medida VARCHAR,
  cc VARCHAR,
  nro_serie VARCHAR,
  lugar VARCHAR,
  responsable TEXT,
  valor_compra NUMERIC,
  valor_inicial NUMERIC,
  valor_mes_ant NUMERIC,
  altas NUMERIC,
  bajas NUMERIC,
  traspasos NUMERIC,
  inc_actualiz NUMERIC,
  valor_actualiz NUMERIC,
  vida_util_orig INTEGER,
  vida_util_transc INTEGER,
  vida_util INTEGER,
  depreciacion_acum_gest_ant NUMERIC,
  depreciacion_acum_mes_ant NUMERIC,
  inc_actualiz_dep_acum NUMERIC,
  depreciacion NUMERIC,
  dep_acum_bajas NUMERIC,
  dep_acum_tras INTEGER,
  depreciacion_acum NUMERIC,
  monto_vigente NUMERIC,
  aitb_dep_mes NUMERIC,
  aitb_af_ene NUMERIC,
  aitb_af_feb NUMERIC,
  aitb_af_mar NUMERIC,
  aitb_af_abr NUMERIC,
  aitb_af_may NUMERIC,
  aitb_af_jun NUMERIC,
  aitb_af_jul NUMERIC,
  aitb_af_ago NUMERIC,
  aitb_af_sep NUMERIC,
  aitb_af_oct NUMERIC,
  aitb_af_nov NUMERIC,
  aitb_af_dic NUMERIC,
  total_aitb_af NUMERIC,
  aitb_dep_acum_ene NUMERIC,
  aitb_dep_acum_feb NUMERIC,
  aitb_dep_acum_mar NUMERIC,
  aitb_dep_acum_abr NUMERIC,
  aitb_dep_acum_may NUMERIC,
  aitb_dep_acum_jun NUMERIC,
  aitb_dep_acum_jul NUMERIC,
  aitb_dep_acum_ago NUMERIC,
  aitb_dep_acum_sep NUMERIC,
  aitb_dep_acum_oct NUMERIC,
  aitb_dep_acum_nov NUMERIC,
  aitb_dep_acum_dic NUMERIC,
  total_aitb_dep_acum NUMERIC,
  dep_ene NUMERIC,
  dep_feb NUMERIC,
  dep_mar NUMERIC,
  dep_abr NUMERIC,
  dep_may NUMERIC,
  dep_jun NUMERIC,
  dep_jul NUMERIC,
  dep_ago NUMERIC,
  dep_sep NUMERIC,
  dep_oct NUMERIC,
  dep_nov NUMERIC,
  dep_dic NUMERIC,
  total_dep NUMERIC,
  aitb_dep_ene NUMERIC,
  aitb_dep_feb NUMERIC,
  aitb_dep_mar NUMERIC,
  aitb_dep_abr NUMERIC,
  aitb_dep_may NUMERIC,
  aitb_dep_jun NUMERIC,
  aitb_dep_jul NUMERIC,
  aitb_dep_ago NUMERIC,
  aitb_dep_sep NUMERIC,
  aitb_dep_oct NUMERIC,
  aitb_dep_nov NUMERIC,
  aitb_dep_dic NUMERIC,
  total_aitb_dep NUMERIC,
  cuenta_activo VARCHAR,
  cuenta_dep_acum VARCHAR,
  cuenta_deprec VARCHAR,
  desc_grupo VARCHAR,
  desc_grupo_clasif VARCHAR,
  cuenta_dep_acum_dos TEXT,
  bk_codigo VARCHAR,
  tipo VARCHAR,
  id_activo_fijo INTEGER,
  id_activo_fijo_valor INTEGER,
  CONSTRAINT treporte_detalle_dep2_pkey PRIMARY KEY(id)
) INHERITS (pxp.tbase)
WITH (oids = false);

CREATE INDEX treporte_detalle_dep2_idx ON kaf.treporte_detalle_dep2
  USING btree (id_movimiento, fecha, id_moneda);

CREATE INDEX treporte_detalle_dep2_idx1 ON kaf.treporte_detalle_dep2
  USING btree (numero);

ALTER TABLE kaf.treporte_detalle_dep2
  ALTER COLUMN dep_acum_tras TYPE NUMERIC;
/***********************************F-SCP-RCM-KAF-70-11/08/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2029-09/12/2020****************************************/
CREATE TABLE kaf.tactivo_mod_masivo (
	id_activo_mod_masivo SERIAL,
	id_proceso_wf INTEGER,
	id_estado_wf INTEGER,
	fecha DATE,
	num_tramite VARCHAR(200),
	motivo VARCHAR(5000),
	estado VARCHAR(30),
	CONSTRAINT pk_tactivo_mod_masivo__id_activo_mod_masivo PRIMARY KEY (id_activo_mod_masivo)
) INHERITS (pxp.tbase)
WITH (oids = false);

CREATE TABLE kaf.tactivo_mod_masivo_det (
	id_activo_mod_masivo_det SERIAL,
	id_activo_mod_masivo INTEGER,
	codigo VARCHAR(50) NOT NULL,
	nro_serie VARCHAR(50),
	marca VARCHAR(200),
	denominacion VARCHAR(500),
	descripcion VARCHAR(5000),
	unidad_medida VARCHAR(100),
	observaciones VARCHAR(5000),
	ubicacion VARCHAR(1000),
	local VARCHAR(100),
	responsable VARCHAR(100),
	proveedor VARCHAR(100),
	fecha_compra DATE,
	documento VARCHAR(100),
	cbte_asociado VARCHAR(50),
	fecha_cbte_asociado DATE,
	grupo_ae VARCHAR(100),
	clasificador_ae VARCHAR(100),
	centro_costo VARCHAR(100),
	CONSTRAINT pk_tactivo_mod_masivo__id_activo_mod_masivo_det PRIMARY KEY (id_activo_mod_masivo_det)
) INHERITS (pxp.tbase)
WITH (oids = false);

ALTER TABLE kaf.tactivo_mod_masivo_det
  ADD CONSTRAINT uq_tactivo_mod_masivo_det__id_activo_mod_masivo__codigo
    UNIQUE (id_activo_mod_masivo, codigo) NOT DEFERRABLE;

CREATE TABLE kaf.tactivo_mod_masivo_det_original (
	id_activo_mod_masivo_det_original SERIAL,
	id_activo_mod_masivo_det INTEGER,
	id_activo_fijo INTEGER,
	codigo VARCHAR(50),
	nro_serie VARCHAR(50),
	marca VARCHAR(200),
	denominacion VARCHAR(500),
	descripcion VARCHAR(5000),
	id_unidad_medida INTEGER,
	observaciones VARCHAR(5000),
	ubicacion VARCHAR(1000),
	id_ubicacion INTEGER, --local
	id_funcionario INTEGER,
	id_proveedor INTEGER,
	fecha_compra DATE,
	documento VARCHAR(100),
	cbte_asociado VARCHAR(50),
	fecha_cbte_asociado DATE,
	id_grupo INTEGER, --grupo_ae
	id_grupo_clasif INTEGER, --clasificador_ae
	id_centro_costo INTEGER,
	CONSTRAINT pk_tactivo_mod_ma_det_or__id_activo_mod_mas_det_orig PRIMARY KEY (id_activo_mod_masivo_det_original)
) INHERITS (pxp.tbase)
WITH (oids = false);
/***********************************F-DAT-RCM-KAF-ETR-2029-09/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2170-18/12/2020****************************************/
ALTER TABLE kaf.tmovimiento
ADD COLUMN tc_final_act NUMERIC;

CREATE INDEX tmovimiento_af_dep_idx ON kaf.tmovimiento_af_dep
  USING btree (id_movimiento_af);

CREATE INDEX tactivo_fijo_valores_idx ON kaf.tactivo_fijo_valores
  USING btree (id_movimiento_af);

CREATE INDEX tmovimiento_af_especial_idx ON kaf.tmovimiento_af_especial
  USING btree (id_movimiento_af);
/***********************************F-DAT-RCM-KAF-ETR-2170-18/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2778-01/02/2021****************************************/
ALTER TABLE kaf.tactivo_mod_masivo_det
	ADD COLUMN bs_valor_compra NUMERIC, 
	ADD COLUMN bs_valor_inicial NUMERIC, 
	ADD COLUMN bs_fecha_ini_dep DATE, 
	ADD COLUMN bs_vutil_orig INTEGER, 
	ADD COLUMN bs_vutil INTEGER, 
	ADD COLUMN bs_fult_dep DATE, 
	ADD COLUMN bs_fecha_fin DATE, 
	ADD COLUMN bs_val_resc NUMERIC, 
	ADD COLUMN bs_vact_ini NUMERIC, 
	ADD COLUMN bs_dacum_ini NUMERIC, 
	ADD COLUMN bs_dper_ini NUMERIC, 
	ADD COLUMN bs_inc NUMERIC, 
	ADD COLUMN bs_inc_sact NUMERIC, 
	ADD COLUMN bs_fechaufv_ini DATE, 
	ADD COLUMN usd_valor_compra NUMERIC, 
	ADD COLUMN usd_valor_inicial NUMERIC, 
	ADD COLUMN usd_fecha_ini_dep DATE, 
	ADD COLUMN usd_vutil_orig INTEGER, 
	ADD COLUMN usd_vutil INTEGER, 
	ADD COLUMN usd_fult_dep DATE, 
	ADD COLUMN usd_fecha_fin DATE, 
	ADD COLUMN usd_val_resc NUMERIC, 
	ADD COLUMN usd_vact_ini NUMERIC, 
	ADD COLUMN usd_dacum_ini NUMERIC, 
	ADD COLUMN usd_dper_ini NUMERIC, 
	ADD COLUMN usd_inc NUMERIC, 
	ADD COLUMN usd_inc_sact NUMERIC, 
	ADD COLUMN usd_fecha_ufv_ini DATE, 
	ADD COLUMN ufv_valor_compra NUMERIC, 
	ADD COLUMN ufv_valor_inicial NUMERIC, 
	ADD COLUMN ufv_fecha_ini_dep DATE, 
	ADD COLUMN ufv_vutil_orig INTEGER, 
	ADD COLUMN ufv_vutil INTEGER, 
	ADD COLUMN ufv_fult_dep DATE, 
	ADD COLUMN ufv_fecha_fin DATE, 
	ADD COLUMN ufv_val_resc NUMERIC, 
	ADD COLUMN ufv_vact_ini NUMERIC, 
	ADD COLUMN ufv_dacum_ini NUMERIC, 
	ADD COLUMN ufv_dper_ini NUMERIC, 
	ADD COLUMN ufv_inc NUMERIC, 
	ADD COLUMN ufv_inc_sact NUMERIC, 
	ADD COLUMN ufv_fecha_ufv_ini DATE;

ALTER TABLE kaf.tactivo_mod_masivo_det_original
	ADD COLUMN id_activo_fijo_valor INTEGER,
	ADD COLUMN valor_compra NUMERIC,
	ADD COLUMN valor_inicial NUMERIC,
	ADD COLUMN fecha_ini_dep DATE,
	ADD COLUMN vutil_orig INTEGER,
	ADD COLUMN vutil INTEGER,
	ADD COLUMN fult_dep DATE,
	ADD COLUMN fecha_fin DATE,
	ADD COLUMN val_resc NUMERIC,
	ADD COLUMN vact_ini NUMERIC,
	ADD COLUMN dacum_ini NUMERIC,
	ADD COLUMN dper_ini NUMERIC,
	ADD COLUMN inc NUMERIC,
	ADD COLUMN inc_sact NUMERIC,
	ADD COLUMN fechaufv_ini DATE,
	ADD COLUMN usd_id_activo_fijo_valor INTEGER,
	ADD COLUMN usd_valor_compra NUMERIC,
	ADD COLUMN usd_valor_inicial NUMERIC,
	ADD COLUMN usd_fecha_ini_dep DATE,
	ADD COLUMN usd_vutil_orig INTEGER,
	ADD COLUMN usd_vutil INTEGER,
	ADD COLUMN usd_fult_dep DATE,
	ADD COLUMN usd_fecha_fin DATE,
	ADD COLUMN usd_val_resc NUMERIC,
	ADD COLUMN usd_vact_ini NUMERIC,
	ADD COLUMN usd_dacum_ini NUMERIC,
	ADD COLUMN usd_dper_ini NUMERIC,
	ADD COLUMN usd_inc NUMERIC,
	ADD COLUMN usd_inc_sact NUMERIC,
	ADD COLUMN usd_fechaufv_ini DATE,
	ADD COLUMN ufv_id_activo_fijo_valor INTEGER,
	ADD COLUMN ufv_valor_compra NUMERIC,
	ADD COLUMN ufv_valor_inicial NUMERIC,
	ADD COLUMN ufv_fecha_ini_dep DATE,
	ADD COLUMN ufv_vutil_orig INTEGER,
	ADD COLUMN ufv_vutil INTEGER,
	ADD COLUMN ufv_fult_dep DATE,
	ADD COLUMN ufv_fecha_fin DATE,
	ADD COLUMN ufv_val_resc NUMERIC,
	ADD COLUMN ufv_vact_ini NUMERIC,
	ADD COLUMN ufv_dacum_ini NUMERIC,
	ADD COLUMN ufv_dper_ini NUMERIC,
	ADD COLUMN ufv_inc NUMERIC,
	ADD COLUMN ufv_inc_sact NUMERIC,
	ADD COLUMN ufv_fechaufv_ini DATE;
/***********************************F-DAT-RCM-KAF-ETR-2778-01/02/2021****************************************/