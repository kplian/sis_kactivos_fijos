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
	tipo_cambio_fin numeric(18,2),
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
IS 'indica que moenda se utiliza para actulizar';

COMMENT ON COLUMN kaf.tmoneda_dep.contabilizar
IS 'solo una de la monedas puede contabilizar , esa sera considerada la principal';

COMMENT ON COLUMN kaf.tmoneda_dep.actulizar
IS 'indica si esta moneda actuliza en tal casola moneda de actulizacion tiene que estar configurada';



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

 
 


