/***********************************I-DAT-RCM-KAF-1-02/09/2015****************************************/
INSERT INTO segu.tsubsistema ("codigo", "nombre", "fecha_reg", "prefijo", "estado_reg", "nombre_carpeta", "id_subsis_orig")
VALUES (E'KAF', E'Sistema de Activos Fijos', E'2015-09-03', E'SKA', E'activo', E'ACTIVOS FIJOS', NULL);

-----------------------------------
--DEFINICION DE INTERFACES
-----------------------------------
select pxp.f_insert_tgui ('K - ACTIVOS FIJOS', '', 'KAF', 'si',1 , '', 1, '../../../lib/imagenes/alma32x32.png', '', 'KAF');
select pxp.f_insert_tgui ('Clasificación', 'Clasificación de activos fijos', 'KAFCLA', 'si', 1, 'sis_kactivos_fijos/vista/clasificacion/Clasificacion.php', 2, '', 'ClasificacionAF', 'KAF');
select pxp.f_insert_tgui ('Principal', 'Interfaz principal', 'KAFACF', 'si', 2, 'sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php', 2, '', 'ActivoFijo', 'KAF');
select pxp.f_insert_tgui ('Movimientos', 'Movimientos de los activos fijos', 'KAFMOV', 'si', 3, 'sis_kactivos_fijos/vista/movimiento/Movimiento.php', 2, '', 'Movimiento', 'KAF');
select pxp.f_insert_tgui ('Reportes', 'Reportes', 'KAFREP', 'si', 4, '', 2, '', '', 'KAF');

select pxp.f_insert_testructura_gui ('KAF', 'SISTEMA');
select pxp.f_insert_testructura_gui ('KAFCLA', 'KAF');
select pxp.f_insert_testructura_gui ('KAFACF', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOV', 'KAF');
select pxp.f_insert_testructura_gui ('KAFREP', 'KAF');


INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES
  (E'kaf_codigo_longitud', E'5', E'Longitud correlativo en el codigo de activos');



/***********************************F-DAT-RCM-KAF-1-02/09/2015****************************************/

/***********************************I-DAT-RCM-KAF-1-11/09/2015****************************************/


ALTER SEQUENCE kaf.tactivo_fijo_valores_id_activo_fijo_valor_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_af_dep_id_movimiento_af_dep_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_id_movimiento_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_af_id_movimiento_af_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tactivo_fijo_id_activo_fijo_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;


/***********************************F-DAT-RCM-KAF-1-11/09/2015****************************************/


/***********************************I-DAT-RCM-KAF-1-18/03/2016****************************************/
select pxp.f_insert_tgui ('Tipo Movimiento - Motivos', 'Tipo Movimiento - Motivos', 'KAFMMOT', 'si', 4, 'sis_kactivos_fijos/vista/movimiento_motivo/MovimientoMotivo.php', 2, '', 'MovimientoMotivo', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMMOT', 'KAF');

select pxp.f_insert_tgui ('Tipo Movimiento', 'Tipo Movimiento', 'KAFMOVT', 'si', 5, 'sis_kactivos_fijos/vista/movimiento_tipo/MovimientoTipo.php', 2, '', 'MovimientoTipo', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOVT', 'KAF');
/***********************************F-DAT-RCM-KAF-1-18/03/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-25/03/2016****************************************/
select wf.f_import_tproceso_macro ('insert','KAF-MOV-AF', 'KAF', 'Procesos de Activos Fijos','si');
select wf.f_import_tcategoria_documento ('insert','legales', 'Legales');
select wf.f_import_tcategoria_documento ('insert','proceso', 'Proceso');
select wf.f_import_ttipo_proceso ('insert','PRO-AF',NULL,NULL,'KAF-MOV-AF','Procesos de Activos Fijos','kat.tmovimiento','id_movimiento','si','','','','PRO-AF',NULL);
select wf.f_import_ttipo_estado ('insert','borrador','PRO-AF','Borrador','si','no','no','ninguno','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL);
select wf.f_import_ttipo_estado ('insert','pendiente','PRO-AF','Pendiente','no','no','no','ninguno','','ninguno','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL);
select wf.f_import_ttipo_estado ('insert','finalizado','PRO-AF','Finalizado','no','no','si','ninguno','','ninguno','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL);
select wf.f_import_ttipo_estado ('insert','cancelado','PRO-AF','Cancelado','no','no','si','ninguno','','ninguno','','','no','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL);
select wf.f_import_testructura_estado ('insert','borrador','pendiente','PRO-AF',1,'');
select wf.f_import_testructura_estado ('insert','pendiente','finalizado','PRO-AF',1,'');
/***********************************F-DAT-RCM-KAF-1-25/03/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-29/03/2016****************************************/
select pxp.f_insert_tgui ('Depositos', 'Depositos', 'KAFDEP', 'si', 2, 'sis_kactivos_fijos/vista/deposito/Deposito.php', 2, '', 'Deposito', 'KAF');
select pxp.f_insert_testructura_gui ('KAFDEP', 'KAF');
/***********************************F-DAT-RCM-KAF-1-29/03/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-18/04/2016****************************************/
select pxp.f_insert_tgui ('Tipos de Bienes', 'Tipos de Bienes', 'KAFTIPBIE', 'si', 4, 'sis_kactivos_fijos/vista/tipo_bien/TipoBien.php', 6, '', 'TipoBien', 'KAF');
select pxp.f_insert_tgui ('Tipos de Cuentas', 'Tipos de Cuentas', 'KAFMOVTIPCUE', 'si', 5, 'sis_kactivos_fijos/vista/tipo_cuenta/TipoCuenta.php', 7, '', 'TipoCuenta', 'KAF');

select pxp.f_insert_testructura_gui ('KAFTIPBIE', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOVTIPCUE', 'KAF');
/***********************************F-DAT-RCM-KAF-1-18/03/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-07/05/2016****************************************/
select pxp.f_add_catalog('KAF','tactivo_fijo_valores__tipo','Alta','alta','');
select pxp.f_add_catalog('KAF','tactivo_fijo_valores__tipo','Revalorizacion','reval','');
select pxp.f_add_catalog('KAF','tactivo_fijo_valores__tipo','Otros','otro','');
/***********************************F-DAT-RCM-KAF-1-07/05/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-24/05/2016****************************************/
insert into pxp.variable_global(variable,valor,descripcion) values('kaf_clasif_replicar','true','Replicar clasificacion caso Comibol');
/***********************************F-DAT-RCM-KAF-1-24/05/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-07/06/2016****************************************/
select pxp.f_add_catalog('KAF','tactivo_fijo__codigo','texto');
select pxp.f_add_catalog('KAF','tactivo_fijo__codigo','barras');
select pxp.f_add_catalog('KAF','tactivo_fijo__codigo','qr');
/***********************************F-DAT-RCM-KAF-1-07/06/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-30/06/2016****************************************/
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Transferencia','transf','ball_blue.png');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Incrementos/Decrementos','incdec','ball_blue.png');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Desuso temporal','desuso','ball_blue.png');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Transferencia Deposito','tranfdep','ball_blue.png');
/***********************************F-DAT-RCM-KAF-1-30/06/2016****************************************/

/***********************************I-DAT-RCM-KAF-1-25/07/2016****************************************/
insert into pxp.variable_global(variable,valor,descripcion) values('kaf_nivel_tipo_activo','3','Nivel de la clasificacion que se refiere al Tipo de Activo');
/***********************************F-DAT-RCM-KAF-1-25/07/2016****************************************/




/***********************************I-DAT-RAC-KAF-1-25/07/2016****************************************/

----------------------------------
--COPY LINES TO SUBSYSTEM data.sql FILE
---------------------------------

select param.f_import_tcatalogo_tipo ('insert','tactivo_fijo__id_cat_estado_fun','KAF','tactivo_fijo__id_cat_estado_fun');
select param.f_import_tcatalogo ('insert','KAF','Malo en Uso','3','tactivo_fijo__id_cat_estado_fun');
select param.f_import_tcatalogo ('insert','KAF','Malo en Desuso','4','tactivo_fijo__id_cat_estado_fun');
select param.f_import_tcatalogo ('insert','KAF','Bueno','1','tactivo_fijo__id_cat_estado_fun');
select param.f_import_tcatalogo ('insert','KAF','Regular','2','tactivo_fijo__id_cat_estado_fun');



----------------------------------
--COPY LINES TO SUBSYSTEM data.sql FILE
---------------------------------

select param.f_import_tcatalogo_tipo ('insert','tclasificacion__id_cat_metodo_dep','KAF','tclasificacion__id_cat_metodo_dep');
select param.f_import_tcatalogo ('insert','KAF','lineal',NULL,'tclasificacion__id_cat_metodo_dep');
select param.f_import_tcatalogo ('insert','KAF','hrs_prod',NULL,'tclasificacion__id_cat_metodo_dep');



----------------------------------
--COPY LINES TO SUBSYSTEM data.sql FILE
---------------------------------

select param.f_import_tcatalogo_tipo ('insert','tactivo_fijo__id_cat_estado_compra','KAF','tactivo_fijo__id_cat_estado_compra');
select param.f_import_tcatalogo ('insert','KAF','Nuevo','nuevo','tactivo_fijo__id_cat_estado_compra');
select param.f_import_tcatalogo ('insert','KAF','Usado','usado','tactivo_fijo__id_cat_estado_compra');


----------------------------------
--COPY LINES TO SUBSYSTEM data.sql FILE
---------------------------------

select param.f_import_tcatalogo_tipo ('insert','tmovimiento__id_cat_movimiento','KAF','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Alta','alta','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Baja','baja','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Revalorización','reval','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Depreciación/Actualización','deprec','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Asignación','asig','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Devolución','devol','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Transferencia','transf','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Ajustes','ajuste','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Retiros','retiro','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Transferencia Deposito','tranfdep','tmovimiento__id_cat_movimiento');



/***********************************F-DAT-RAC-KAF-1-25/07/2016****************************************/



/***********************************I-DAT-RAC-KAF-1-14/03/2017****************************************/


select pxp.f_insert_tgui ('Movimientos', 'Movimientos de los activos fijos', 'KAFMOV', 'si', 3, 'sis_kactivos_fijos/vista/movimiento/MovimientoPrincipal.php', 2, '', 'MovimientoPrincipal', 'KAF');

/* Data for the 'pxp.variable_global' table  (Records 1 - 1) */

INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES
  (E'kaf_clase_reporte_codigo', E'RCodigoQRAF', E'nombre de la calse utilizada para imprimir el codigo de af,  el codigo de la clase debe acomodarce dentro del archivo sis_kactivos_fijos/reportes/RCodigoQRAF.php');


/***********************************F-DAT-RAC-KAF-1-14/03/2017****************************************/





/***********************************I-DAT-RAC-KAF-1-10/04/2017****************************************/


select param.f_import_tcatalogo ('insert','KAF','Actualización','actua','tmovimiento__id_cat_movimiento');



/***********************************F-DAT-RAC-KAF-1-10/04/2017****************************************/



/***********************************I-DAT-RAC-KAF-1-20/04/2017****************************************/


----------------------------------
--COPY LINES TO data.sql FILE
---------------------------------

select pxp.f_insert_tgui ('Movimientos', 'Movimientos de los activos fijos', 'KAFMOV', 'si', 3, 'sis_kactivos_fijos/vista/movimiento/MovimientoPrincipal.php', 2, '', 'MovimientoPrincipal', 'KAF');
select pxp.f_insert_tgui ('Configuración', 'Configuración', 'CONFAF', 'si', 1, '', 2, '', '', 'KAF');
select pxp.f_insert_tgui ('Monedas Dep', 'Moneda para depreciación', 'MONDEP', 'si', 1, 'sis_kactivos_fijos/vista/moneda_dep/MonedaDep.php', 3, '', 'MonedaDep', 'KAF');


/***********************************F-DAT-RAC-KAF-1-20/04/2017****************************************/




/***********************************I-DAT-RAC-KAF-1-02/05/2017****************************************/




----------------------------------
--COPY LINES TO data.sql FILE
---------------------------------

select pxp.f_insert_tgui ('Configuración Prorrateo', 'Configuración Prorrateo', 'TIPRO', 'si', 2, 'sis_kactivos_fijos/vista/tipo_prorrateo/ProyectoKaf.php', 3, '', 'ProyectoKaf', 'KAF');
select pxp.f_insert_tgui ('Clasificación Relación Contable', 'Clasificación Relación Contable', 'LAFRC', 'si', 3, 'sis_kactivos_fijos/vista/cta_clasificacion/CtaClasificacion.php', 3, '', 'CtaClasificacion', 'KAF');
----------------------------------
--COPY LINES TO dependencies.sql FILE
---------------------------------

select pxp.f_insert_testructura_gui ('TIPRO', 'CONFAF');
select pxp.f_insert_testructura_gui ('LAFRC', 'CONFAF');




INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES
  (E'kaf_cbte_depreciacion', E'DEPAF', E'codigo de la plantilla de cbte de depreciacion');


INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES
  (E'kaf_cbte_depreciacion_aitb', E'AITBAF', E'cbte de AITB activos Fijos');



/***********************************F-DAT-RAC-KAF-1-02/05/2017****************************************/



/***********************************I-DAT-RCM-KAF-1-02/06/2017****************************************/
select pxp.f_insert_tgui ('Gestión de Periodos', 'Gestión de Periodos', 'KAFPER', 'si', 5, 'sis_kactivos_fijos/vista/periodo_subsistema/PeriodoActivos.php', 2, '', 'PeriodoActivos', 'KAF');
select pxp.f_insert_testructura_gui ('KAFPER', 'KAF');
/***********************************F-DAT-RCM-KAF-1-02/06/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-27/06/2017****************************************/
select pxp.f_add_catalog('KAF','tclasificacion_variable__tipo_dato','Fecha','fecha');
select pxp.f_add_catalog('KAF','tclasificacion_variable__tipo_dato','Número','numero');
select pxp.f_add_catalog('KAF','tclasificacion_variable__tipo_dato','Texto','texto');

select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Mejora','mejora','');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','División de valores','divis','');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Desglose','desgl','');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Intercambio de partes','intpar','');
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Activos fijos en Transito','transito','');

/***********************************F-DAT-RCM-KAF-1-27/06/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-24/07/2017****************************************/
select pxp.f_insert_tgui ('Kardex', 'Kardex por activo fijo', 'KAF.REP.01', 'si', 1, 'sis_kactivos_fijos/vista/reportes/ParametrosReportes.php', 3, '', 'ParametrosReportes', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.01', 'KAFREP');
/***********************************F-DAT-RCM-KAF-1-24/07/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-25/07/2017****************************************/
select pxp.f_add_catalog('KAF','tactivo_fijo__estado','Registrado','registrado');
select pxp.f_add_catalog('KAF','tactivo_fijo__estado','Alta','alta');
select pxp.f_add_catalog('KAF','tactivo_fijo__estado','Tránsito','transito');
select pxp.f_add_catalog('KAF','tactivo_fijo__estado','Baja','baja');
select pxp.f_add_catalog('KAF','tactivo_fijo__estado','Retiro','retiro');
/***********************************F-DAT-RCM-KAF-1-25/07/2017****************************************/

/***********************************I-DAT-RCM-KAF-0-08/08/2017****************************************/
select pxp.f_insert_tgui ('Pre-Ingreso', 'Pre ingreso al módulo de activos fijos', 'KAFPREI', 'si', 11, 'sis_almacenes/vista/preingreso/PreingresoActV2.php', 3, '', 'PreingresoActV2', 'KAF');
select pxp.f_insert_testructura_gui ('KAFPREI', 'KAF');
select pxp.f_insert_tgui ('Mis Activos Fijos', 'Listado de mis activos fijos asignados', 'KAFMIASIG', 'si', 11, 'sis_kactivos_fijos/vista/activo_fijo/ActivoFijoUsuario.php', 3, '', 'ActivoFijoUsuario', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMIASIG', 'KAF');
/***********************************F-DAT-RCM-KAF-0-08/08/2017****************************************/

/***********************************I-DAT-RCM-KAF-0-15/08/2017****************************************/
select pxp.f_insert_tgui ('Procesos - Cuentas', 'Configuración de las cuentas por Proceso y Clasificación', 'MOTTIPCAT', 'si', 1, 'sis_kactivos_fijos/vista/movimiento_tipo/MovimientoTipoCat.php', 3, '', 'MovimientoTipoCat', 'KAF');
select pxp.f_insert_testructura_gui ('MOTTIPCAT', 'CONFAF');
/***********************************F-DAT-RCM-KAF-0-15/08/2017****************************************/

/***********************************I-DAT-RCM-KAF-0-27/09/2017****************************************/
select pxp.f_add_catalog('KAF','tclasificacion_variable__obligatorio','si','si');
select pxp.f_add_catalog('KAF','tclasificacion_variable__obligatorio','no','no');
/***********************************F-DAT-RCM-KAF-0-27/09/2017****************************************/

/***********************************I-DAT-RCM-KAF-0-28/09/2017****************************************/
select pxp.f_insert_tgui ('Visto Bueno Movimientos', 'Visto bueno de los Movimientos de activos fijos', 'KAFMOVVB', 'si', 6, 'sis_kactivos_fijos/vista/movimiento/MovimientoVb.php', 2, '', 'MovimientoVb', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOVVB', 'KAF');
/***********************************F-DAT-RCM-KAF-0-28/09/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-04/10/2017****************************************/
select pxp.f_insert_tgui ('Códigos QR', 'Códigos QR por Activos Fijos o Clasificación', 'KAF.REP.02', 'si', 2, 'sis_kactivos_fijos/vista/reportes/ParametrosRepCodigosQR.php', 3, '', 'ParametrosRepCodigosQR', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.02', 'KAFREP');
/***********************************F-DAT-RCM-KAF-1-04/10/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-05/10/2017****************************************/
select pxp.f_insert_tgui ('Asignación Activos Fijos', 'Reportes sobre la asignación de activos fijos', 'KAFREP.1', 'si', 4, '', 2, '', '', 'KAF');
select pxp.f_insert_tgui ('Asignados', 'Activos Fijos asignados a funcionarios de la institución', 'KAF.REP.03', 'si', 1, 'sis_kactivos_fijos/vista/reportes/ParametrosRepAsignados.php', 3, '', 'ParametrosRepAsignados', 'KAF');
select pxp.f_insert_tgui ('Asignados por Depósito', 'Activos Fijos asignados por Depósito', 'KAF.REP.04', 'si', 2, 'sis_kactivos_fijos/vista/reportes/ParametrosRepEnDeposito.php', 3, '', 'ParametrosRepEnDeposito', 'KAF');
select pxp.f_insert_tgui ('Sin Asignar', 'Activos Fijos en depósito disponibles para asignación', 'KAF.REP.05', 'si', 3, 'sis_kactivos_fijos/vista/reportes/ParametrosRepSinAsignar.php', 3, '', 'ParametrosRepSinAsignar', 'KAF');
select pxp.f_insert_testructura_gui ('KAFREP.1', 'KAFREP');
select pxp.f_insert_testructura_gui ('KAF.REP.03', 'KAFREP.1');
select pxp.f_insert_testructura_gui ('KAF.REP.04', 'KAFREP.1');
select pxp.f_insert_testructura_gui ('KAF.REP.05', 'KAFREP.1');
/***********************************F-DAT-RCM-KAF-1-05/10/2017****************************************/

/***********************************I-DAT-RCM-KAF-1-16/10/2017****************************************/
select pxp.f_insert_tgui ('Detalle Depreciación', 'Detalle Activos Fijos', 'KAF.REP.06', 'si', 3, 'sis_kactivos_fijos/vista/reportes/ParametrosRepDetalleDep.php', 3, '', 'ParametrosRepDetalleDep', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.06', 'KAFREP');

select pxp.f_add_catalog('KAF','tmovimiento__tipo_asig','Todos los Activos','todos','');
select pxp.f_add_catalog('KAF','tmovimiento__tipo_asig','Seleccionar','seleccionar','');
/***********************************F-DAT-RCM-KAF-1-16/10/2017****************************************/


/***********************************I-DAT-RCM-KAF-1-04/11/2017****************************************/
select pxp.f_insert_tgui ('Activos Fijos por Responsable - Inventario', 'Activos Fijos por Responsable - Inventario', 'KAF.REP.07', 'si', 4, 'sis_kactivos_fijos/vista/reportes/ParametrosRepRespInventario.php', 3, '', 'ParametrosRepRespInventario', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.07', 'KAFREP');
/***********************************F-DAT-RCM-KAF-1-04/11/2017****************************************/

/***********************************I-DAT-RCM-KAF-0-17/04/2018****************************************/
select pxp.f_insert_tgui ('Grupos', 'Agrupador de activos fijos', 'AFGRU', 'si', 1, 'sis_kactivos_fijos/vista/grupo/Grupo.php', 3, '', 'Grupo', 'KAF');
select pxp.f_insert_testructura_gui ('AFGRU', 'CONFAF');
/***********************************F-DAT-RCM-KAF-0-17/04/2018****************************************/

/***********************************I-DAT-RCM-KAF-0-15/06/2018****************************************/
select pxp.f_insert_tgui ('Locales', 'Registro de las ubicaciones físicas', 'KAFUBI', 'si', 1, 'sis_kactivos_fijos/vista/ubicacion/Ubicacion.php', 3, '', 'Ubicacion', 'KAF');
select pxp.f_insert_testructura_gui ('KAFUBI', 'CONFAF');
/***********************************F-DAT-RCM-KAF-0-15/06/2018****************************************/

/***********************************I-DAT-RCM-KAF-1-25/06/2018****************************************/
select pxp.f_insert_tgui ('2 Formulario 605', 'Reporte con el formato del formulario 605 para impuestos', 'KAF.REP.08', 'si', 6, 'sis_kactivos_fijos/vista/reportes/ParametrosRepForm605.php', 3, '', 'ParametrosRepForm605', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.08', 'KAFREP');
/***********************************F-DAT-RCM-KAF-1-25/06/2018****************************************/

/***********************************I-DAT-RCM-KAF-0-26/06/2018****************************************/
INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES
  (E'kaf_caracteres_no_validos_form605', E'$,%,&,/', E'Caracteres inválidos para generar reporte del Formulario 605');
/***********************************F-DAT-RCM-KAF-0-26/06/2018****************************************/

/***********************************I-DAT-RCM-KAF-0-10/07/2018****************************************/
select pxp.f_add_catalog('KAF','tgrupo__tipo','grupo','grupo','');
select pxp.f_add_catalog('KAF','tgrupo__tipo','clasificacion','clasificacion','');
/***********************************F-DAT-RCM-KAF-0-10/07/2018****************************************/

/***********************************I-DAT-RCM-KAF-2-25/02/2019****************************************/
select pxp.f_add_catalog('KAF','tmovimiento__id_cat_movimiento','Distribuir Valor AF','dval','');
/***********************************F-DAT-RCM-KAF-2-25/02/2019****************************************/

/***********************************I-DAT-RCM-KAF-2-23/05/2018****************************************/
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__opcion','Activo Fijo','af_exist','');
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__opcion','Nuevo Activo Fijo','af_nuevo','');
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__opcion','Salida a Almacén','af_almacen','');

select pxp.f_add_catalog('KAF','tmovimiento_af_especial__forma','Porcentaje','porcentaje','');
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__forma','Importe','importe','');
/***********************************F-DAT-RCM-KAF-2-23/05/2018****************************************/

/***********************************I-DAT-RCM-KAF-2-28/05/2018****************************************/
INSERT INTO pxp.variable_global (
	variable, valor, descripcion
) VALUES (
	E'kaf_mov_especial_moneda', E'UFV', E'Moneda a utilizar para la Distribución de Valores en Activos Fijos'
);
/***********************************F-DAT-RCM-KAF-2-28/05/2018****************************************/

/***********************************I-DAT-RCM-KAF-15-17/06/2019****************************************/
select param.f_import_tplantilla_archivo_excel ('insert','SUBIRCC','SubirCentroCosto','activo',NULL,'2',NULL,NULL,'xlsx','');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','SCCAF','SUBIRCC','si',NULL,NULL,'1','Activo Fijo','activo_fijo','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','SCCCC','SUBIRCC','si',NULL,NULL,'3','Centro Costo','centro_costo','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','SCCMES','SUBIRCC','si','dd/mm/yyyy',NULL,'2','Mes','mes','date',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','SCCHRA','SUBIRCC','si',NULL,NULL,'4','Horas','cantidad_horas','numeric','.','activo');
/***********************************F-DAT-RCM-KAF-15-17/06/2019****************************************/

/***********************************I-DAT-RCM-KAF-16-18/06/2019****************************************/
INSERT INTO pxp.variable_global (
	variable, valor, descripcion
) VALUES (
	E'kaf_activo_fijo_cc', E'720', E'Horas por mes para prorrateo de CC por activos fijos'
);
/***********************************F-DAT-RCM-KAF-16-18/06/2019****************************************/

/***********************************I-DAT-RCM-KAF-20-19/07/2019****************************************/
select pxp.f_insert_tgui ('6 Distribución de Valores', 'Activos fijos con Distribución de Valores', 'KAF.REP.09', 'si', 13, 'sis_kactivos_fijos/vista/reportes/ReporteAfDistValores.php', 3, '', 'ReporteAfDistValores', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.09', 'KAFREP');
/***********************************F-DAT-RCM-KAF-20-19/07/2019****************************************/

/***********************************I-DAT-RCM-KAF-24-31/07/2019****************************************/
select pxp.f_insert_tgui ('1 Inventario Detallado por Grupo Contable', 'Inventario Detallado por Grupo Contable', 'KAF.REP.10', 'si', 10, 'sis_kactivos_fijos/vista/reportes/ParametrosRepInventarioDetallado.php', 3, '', 'ParametrosRepInventarioDetallado', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.10', 'KAFREP');
/***********************************F-DAT-RCM-KAF-24-31/07/2019****************************************/

/***********************************I-DAT-RCM-KAF-17-13/08/2019****************************************/
select pxp.f_insert_tgui ('3 Impuestos a la Propiedad e Inmuebles', 'Impuestos a la Propiedad e Inmuebles', 'KAF.REP.11', 'si', 11, 'sis_kactivos_fijos/vista/reportes/ParametrosRepImpuestosPropiedad.php', 3, '', 'ParametrosRepImpuestosPropiedad', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.11', 'KAFREP');
/***********************************F-DAT-RCM-KAF-17-13/08/2019****************************************/

/***********************************I-DAT-RCM-KAF-19-14/08/2019****************************************/
select pxp.f_insert_tgui ('4 Impuestos de Vehículos', 'Impuestos de Vehículos', 'KAF.REP.12', 'si', 12, 'sis_kactivos_fijos/vista/reportes/ParametrosRepImpuestosVehiculos.php', 3, '', 'ParametrosRepImpuestosVehiculos', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.12', 'KAFREP');
/***********************************F-DAT-RCM-KAF-19-14/08/2019****************************************/

/***********************************I-DAT-RCM-KAF-26-16/08/2019****************************************/
select pxp.f_insert_tgui ('7 Altas por Origen de Activación', 'Altas por Origen de Activación', 'KAF.REP.13', 'si', 14, 'sis_kactivos_fijos/vista/reportes/ParametrosRepAltaOrigen.php', 3, '', 'ParametrosRepAltaOrigen', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.13', 'KAFREP');

select pxp.f_add_catalog('KAF','reportes__tipo_alta','Activos Fijos','activos_fijos','');
select pxp.f_add_catalog('KAF','reportes__tipo_alta','Cierre Proyectos','cierre_proy','');
select pxp.f_add_catalog('KAF','reportes__tipo_alta','Distribución de Valores','distribucion_val','');
select pxp.f_add_catalog('KAF','reportes__tipo_alta','Preingresos','preingreso','');
select pxp.f_add_catalog('KAF','reportes__tipo_alta','Todos','todos','');
/***********************************F-DAT-RCM-KAF-26-16/08/2019****************************************/

/***********************************I-DAT-RCM-KAF-17-11/09/2019****************************************/
INSERT INTO kaf.tgrupo_clasif ("id_usuario_reg", "id_usuario_mod", "fecha_reg", "fecha_mod", "estado_reg", "id_usuario_ai", "usuario_ai", "codigo", "descripcion")
VALUES
  (1, NULL, now(), NULL, E'activo', NULL, NULL, E'RIMPINM', E'Agrupador para Reporte de Impuestos a la Propiedad e Inmuebles'),
  (1, NULL, now(), NULL, E'activo', NULL, NULL, E'RIMPVEH', E'Agrupador para Reporte de Impuestos Vehículos');

select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-IGUAL','kaf.f_gestionar_cbte_igualacion_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','','{$tabla.fecha_mov}','activo','ENDE TRANSMISIÓN S.A.','{$tabla.id_depto_conta}','contable','','kaf.vdeprec_igualacion_conta_haber_cab','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','Comprobante para igualar saldos del cálculo de depreciación con saldos contables por diferencias por redondeo','','','','','');

select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','AF DEBE','debe','si','si','','ACTIVOS','DEPACTIVO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','AF Transacción al Debe','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_af',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','AF HABER','haber','si','si','','ACTIVOS','DEPACTIVO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','AF Transacción al Haber','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_af',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','AF DEBE CC','haber','si','si','','ACTIVOS CC','DEPACTIVO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','AF DEBE Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_af',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','AF HABER CC','debe','si','si','','ACTIVOS CC','DEPACTIVO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','AF HABER Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_af',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','DEP DEBE','haber','si','si','','DEPREC','DEPGASTO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','DEP Transacción al Debe','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_dep',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','DEP HABER','debe','si','si','','DEPREC','DEPGASTO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','DEP Transacción al Haber','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_dep',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','DEP DEBE CC','debe','si','si','','DEPREC CC','DEPGASTO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','DEP DEBE Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_dep',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','DEP HABER CC','haber','si','si','','DEPREC CC','DEPGASTO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','DEP HABER Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_dep',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','ACT DEBE','debe','si','si','','ACT','DEPACTIVO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','ACT Transacción al Debe','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_act',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','ACT HABER','haber','si','si','','ACT','DEPACTIVO','{$tabla.id_cuenta}','{$tabla.importe}','','','no','','','','si','','id_movimiento','','ACT Transacción al Haber','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_act',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','ACT DEBE CC','haber','si','si','','ACT CC','DEPACTIVO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','ACT DEBE Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_debe_act',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-IGUAL','ACT HABER CC','debe','si','si','','ACT CC','DEPACTIVO','','{$tabla.importe}','','','no','','','','si','','id_movimiento','','ACT HABER Contracuenta','{$tabla.importe}',NULL,'simple','','','no','','','','','','','','2','','kaf.vdeprec_igualacion_conta_haber_act',NULL,'','CCDEPCON','','','todos','','si');
/***********************************F-DAT-RCM-KAF-17-11/09/2019****************************************/

/***********************************I-DAT-RCM-KAF-29-18/09/2019****************************************/
select pxp.f_add_catalog('KAF','reportes__tipo_alta','Cierre Proyectos Incrementos','cierre_proy_inc','');
/***********************************F-DAT-RCM-KAF-29-18/09/2019****************************************/

/***********************************I-DAT-RCM-KAF-36-18/10/2019****************************************/
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__tipo','Activo Fijo','af_exist','');
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__tipo','Nuevo Activo Fijo','af_nuevo','');
select pxp.f_add_catalog('KAF','tmovimiento_af_especial__tipo','Salida a Almacén','af_almacen','');

select conta.f_import_tplantilla_comprobante ('insert','KAF_MOVESP','kaf.f_gestionar_cbte_mov_especial_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_mov_especial','{$tabla.fecha_mov}','activo','ENDE TRANSMISION S.A.','{$tabla.id_depto_conta}','contable','','kaf.v_cbte_mov_especial','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','Distribución de valores a Nuevos Activos Fijos, Existentes y Salida a Almacén','','','','','');
/***********************************F-DAT-RCM-KAF-36-18/10/2019****************************************/

/***********************************I-DAT-RCM-KAF-36-24/10/2019****************************************/
select conta.f_import_ttipo_relacion_contable ('insert','ALINGT','TALM','Ingreso Almacén por Transferencia AF','activo','si-general','si','no','flujo','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','ALINGTA','TALM','Ingreso Almacén por Transferencia para Valor Activo','activo','si-general','si','no','flujo','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','ALINGTD','TALM','Ingreso Almacén por Transferencia para Depreciación Acumulada','activo','si-general','si','no','flujo','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','TRAFALAC',NULL,'Transferencia Activos Fijos a Almacén Activo Fijo','activo','si-unico','si','no','flujo','recurso_gasto','no','no','no',NULL);
select conta.f_import_ttipo_relacion_contable ('insert','TRAFALDAC',NULL,'Transferencia Activos Fijos a Almacén Depreciación Acumulada','activo','si-unico','si','no','flujo','recurso_gasto','no','no','no',NULL);
/***********************************F-DAT-RCM-KAF-36-24/10/2019****************************************/

/***********************************I-DAT-RCM-KAF-37-25/10/2019****************************************/
UPDATE conta.tplantilla_comprobante SET
campo_descripcion = '{$tabla.glosa}'
WHERE codigo = 'KAF_MOVESP';
/***********************************F-DAT-RCM-KAF-37-25/10/2019****************************************/

/***********************************I-DAT-RCM-KAF-38-06/11/2019****************************************/
select param.f_import_tplantilla_archivo_excel ('insert','AF-DVALAF','AF - Dist.Val AF','activo',NULL,'2',NULL,NULL,'xlsx',NULL);
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD1','AF-DVALAF','si',NULL,NULL,'1','item','item','entero',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD2','AF-DVALAF','si',NULL,NULL,'2','clasificacion','clasificacion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD3','AF-DVALAF','si',NULL,NULL,'3','vida_util_anios','vida_util_anios','entero',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD4','AF-DVALAF','si',NULL,NULL,'4','nro_serie','nro_serie','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD5','AF-DVALAF','si',NULL,NULL,'5','marca','marca','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD6','AF-DVALAF','si',NULL,NULL,'6','denominacion','denominacion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD7','AF-DVALAF','si',NULL,NULL,'7','descripcion','descripcion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD8','AF-DVALAF','si',NULL,NULL,'8','cantidad','cantidad','entero',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD9','AF-DVALAF','si',NULL,NULL,'9','unidad','unidad','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD10','AF-DVALAF','si',NULL,NULL,'10','ubicacion','ubicacion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD11','AF-DVALAF','si',NULL,NULL,'11','local','local','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD12','AF-DVALAF','si',NULL,NULL,'12','responsable','responsable','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD13','AF-DVALAF','si','dd-mm-yyyy',NULL,'13','fecha_compra','fecha_compra','date',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD14','AF-DVALAF','si',NULL,NULL,'14','costo','costo','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD15','AF-DVALAF','si',NULL,NULL,'15','valor_compra','valor_compra','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD16','AF-DVALAF','si',NULL,NULL,'16','moneda','moneda','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD17','AF-DVALAF','si','dd-mm-yyyy',NULL,'17','fecha_ini_dep','fecha_ini_dep','date',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD18','AF-DVALAF','si',NULL,NULL,'18','grupo_ae','grupo_ae','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD19','AF-DVALAF','si',NULL,NULL,'19','clasificacion_ae','clasificacion_ae','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD20','AF-DVALAF','si',NULL,NULL,'20','centro_costo','centro_costo','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD21','AF-DVALAF','si',NULL,NULL,'21','codigo_activo','codigo_activo','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD22','AF-DVALAF','si',NULL,NULL,'22','pedido','pedido','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD23','AF-DVALAF','si',NULL,NULL,'23','activo_fijo_1','activo_fijo_1','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD24','AF-DVALAF','si',NULL,NULL,'24','activo_fijo_2','activo_fijo_2','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD25','AF-DVALAF','si',NULL,NULL,'25','activo_fijo_3','activo_fijo_3','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD26','AF-DVALAF','si',NULL,NULL,'26','activo_fijo_4','activo_fijo_4','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD27','AF-DVALAF','si',NULL,NULL,'27','activo_fijo_5','activo_fijo_5','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD28','AF-DVALAF','si',NULL,NULL,'28','activo_fijo_6','activo_fijo_6','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD29','AF-DVALAF','si',NULL,NULL,'29','activo_fijo_7','activo_fijo_7','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD30','AF-DVALAF','si',NULL,NULL,'30','activo_fijo_8','activo_fijo_8','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD31','AF-DVALAF','si',NULL,NULL,'31','activo_fijo_9','activo_fijo_9','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD32','AF-DVALAF','si',NULL,NULL,'32','activo_fijo_10','activo_fijo_10','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD33','AF-DVALAF','si',NULL,NULL,'33','activo_fijo_11','activo_fijo_11','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD34','AF-DVALAF','si',NULL,NULL,'34','activo_fijo_12','activo_fijo_12','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD35','AF-DVALAF','si',NULL,NULL,'35','activo_fijo_13','activo_fijo_13','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD36','AF-DVALAF','si',NULL,NULL,'36','activo_fijo_14','activo_fijo_14','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD37','AF-DVALAF','si',NULL,NULL,'37','activo_fijo_15','activo_fijo_15','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD38','AF-DVALAF','si',NULL,NULL,'38','activo_fijo_16','activo_fijo_16','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD39','AF-DVALAF','si',NULL,NULL,'39','activo_fijo_17','activo_fijo_17','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD40','AF-DVALAF','si',NULL,NULL,'40','activo_fijo_18','activo_fijo_18','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD41','AF-DVALAF','si',NULL,NULL,'41','activo_fijo_19','activo_fijo_19','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD42','AF-DVALAF','si',NULL,NULL,'42','activo_fijo_20','activo_fijo_20','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD43','AF-DVALAF','si',NULL,NULL,'43','activo_fijo_21','activo_fijo_21','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD44','AF-DVALAF','si',NULL,NULL,'44','activo_fijo_22','activo_fijo_22','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD45','AF-DVALAF','si',NULL,NULL,'45','activo_fijo_23','activo_fijo_23','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD46','AF-DVALAF','si',NULL,NULL,'46','activo_fijo_24','activo_fijo_24','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD47','AF-DVALAF','si',NULL,NULL,'47','activo_fijo_25','activo_fijo_25','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD48','AF-DVALAF','si',NULL,NULL,'48','activo_fijo_26','activo_fijo_26','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD49','AF-DVALAF','si',NULL,NULL,'49','activo_fijo_27','activo_fijo_27','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD50','AF-DVALAF','si',NULL,NULL,'50','activo_fijo_28','activo_fijo_28','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD51','AF-DVALAF','si',NULL,NULL,'51','activo_fijo_29','activo_fijo_29','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD52','AF-DVALAF','si',NULL,NULL,'52','activo_fijo_30','activo_fijo_30','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD53','AF-DVALAF','si',NULL,NULL,'53','activo_fijo_31','activo_fijo_31','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD54','AF-DVALAF','si',NULL,NULL,'54','activo_fijo_32','activo_fijo_32','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD55','AF-DVALAF','si',NULL,NULL,'55','activo_fijo_33','activo_fijo_33','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD56','AF-DVALAF','si',NULL,NULL,'56','activo_fijo_34','activo_fijo_34','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD57','AF-DVALAF','si',NULL,NULL,'57','activo_fijo_35','activo_fijo_35','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD58','AF-DVALAF','si',NULL,NULL,'58','activo_fijo_36','activo_fijo_36','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD59','AF-DVALAF','si',NULL,NULL,'59','activo_fijo_37','activo_fijo_37','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD60','AF-DVALAF','si',NULL,NULL,'60','activo_fijo_38','activo_fijo_38','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD61','AF-DVALAF','si',NULL,NULL,'61','activo_fijo_39','activo_fijo_39','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD62','AF-DVALAF','si',NULL,NULL,'62','activo_fijo_40','activo_fijo_40','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD63','AF-DVALAF','si',NULL,NULL,'63','activo_fijo_41','activo_fijo_41','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD64','AF-DVALAF','si',NULL,NULL,'64','activo_fijo_42','activo_fijo_42','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD65','AF-DVALAF','si',NULL,NULL,'65','activo_fijo_43','activo_fijo_43','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD66','AF-DVALAF','si',NULL,NULL,'66','activo_fijo_44','activo_fijo_44','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD67','AF-DVALAF','si',NULL,NULL,'67','activo_fijo_45','activo_fijo_45','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD68','AF-DVALAF','si',NULL,NULL,'68','activo_fijo_46','activo_fijo_46','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD69','AF-DVALAF','si',NULL,NULL,'69','activo_fijo_47','activo_fijo_47','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD70','AF-DVALAF','si',NULL,NULL,'70','activo_fijo_48','activo_fijo_48','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD71','AF-DVALAF','si',NULL,NULL,'71','activo_fijo_49','activo_fijo_49','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD72','AF-DVALAF','si',NULL,NULL,'72','activo_fijo_50','activo_fijo_50','string',NULL,'activo');
/***********************************F-DAT-RCM-KAF-38-06/11/2019****************************************/

/***********************************I-DAT-RCM-KAF-66-11/05/2020****************************************/
select conta.f_import_ttipo_relacion_contable ('insert','AF-DISG_AF','TCLS','Activos Fijos, Disgregación, Activo Fijo','activo','si-general','si','no','flujo','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','AF-DISG_DACUM','TCLS','Activos Fijos, Disgregación, Depreciación Acumulada','activo','si-general','si','no','flujo','recurso_gasto','no','no','no','');
select param.f_import_tplantilla_archivo_excel ('insert','AF-DVALAL','AF - Dist. Val AL','activo',NULL,'1',NULL,'','xlsx','');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD1','AF-DVALAL','si',NULL,NULL,'1','item','item','entero',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD5','AF-DVALAL','si',NULL,NULL,'5','codigo_material','codigo_material','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD3','AF-DVALAL','si',NULL,NULL,'3','codigo','codigo','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD15','AF-DVALAL','si',NULL,NULL,'15','moneda','moneda','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD17','AF-DVALAL','si',NULL,NULL,'17','activo_fijo_2','activo_fijo_2','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD7','AF-DVALAL','si',NULL,NULL,'7','cantidad','cantidad','entero',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD8','AF-DVALAL','si',NULL,NULL,'8','unidad','unidad','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD6','AF-DVALAL','si',NULL,NULL,'6','descripcion','descripcion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD18','AF-DVALAL','si',NULL,NULL,'18','activo_fijo_3','activo_fijo_3','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD13','AF-DVALAL','si',NULL,NULL,'13','moneda_registro','moneda_registro','string',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD16','AF-DVALAL','si',NULL,NULL,'16','activo_fijo_1','activo_fijo_1','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD19','AF-DVALAL','si',NULL,NULL,'19','activo_fijo_4','activo_fijo_4','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD20','AF-DVALAL','si',NULL,NULL,'20','activo_fijo_5','activo_fijo_5','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD21','AF-DVALAL','si',NULL,NULL,'21','activo_fijo_6','activo_fijo_6','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD22','AF-DVALAL','si',NULL,NULL,'22','activo_fijo_7','activo_fijo_7','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD23','AF-DVALAL','si',NULL,NULL,'23','activo_fijo_8','activo_fijo_8','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD24','AF-DVALAL','si',NULL,NULL,'24','activo_fijo_9','activo_fijo_9','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD10','AF-DVALAL','si',NULL,NULL,'10','precio_total_usd_aux','precio_total_usd_aux','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD11','AF-DVALAL','si',NULL,NULL,'11','precio_unit_bs','precio_unit_bs','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD4','AF-DVALAL','si',NULL,NULL,'4','tipo_material','tipo_material','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD12','AF-DVALAL','si',NULL,NULL,'12','precio_total_origen','precio_total_origen','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD9','AF-DVALAL','si',NULL,NULL,'9','precio_unit_usd','precio_unit_usd','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD2','AF-DVALAL','si',NULL,NULL,'2','almacen','clasificacion','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD26','AF-DVALAL','si',NULL,NULL,'26','activo_fijo_11','activo_fijo_11','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD27','AF-DVALAL','si',NULL,NULL,'27','activo_fijo_12','activo_fijo_12','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD35','AF-DVALAL','si',NULL,NULL,'35','activo_fijo_20','activo_fijo_20','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD36','AF-DVALAL','si',NULL,NULL,'36','activo_fijo_21','activo_fijo_21','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD37','AF-DVALAL','si',NULL,NULL,'37','activo_fijo_22','activo_fijo_22','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD38','AF-DVALAL','si',NULL,NULL,'38','activo_fijo_23','activo_fijo_23','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD39','AF-DVALAL','si',NULL,NULL,'39','activo_fijo_24','activo_fijo_24','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD40','AF-DVALAL','si',NULL,NULL,'40','activo_fijo_25','activo_fijo_25','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD41','AF-DVALAL','si',NULL,NULL,'41','activo_fijo_26','activo_fijo_26','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD42','AF-DVALAL','si',NULL,NULL,'42','activo_fijo_27','activo_fijo_27','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD43','AF-DVALAL','si',NULL,NULL,'43','activo_fijo_28','activo_fijo_28','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD44','AF-DVALAL','si',NULL,NULL,'44','activo_fijo_29','activo_fijo_29','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD45','AF-DVALAL','si',NULL,NULL,'45','activo_fijo_30','activo_fijo_30','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD46','AF-DVALAL','si',NULL,NULL,'46','activo_fijo_31','activo_fijo_31','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD47','AF-DVALAL','si',NULL,NULL,'47','activo_fijo_32','activo_fijo_32','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD48','AF-DVALAL','si',NULL,NULL,'48','activo_fijo_33','activo_fijo_33','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD49','AF-DVALAL','si',NULL,NULL,'49','activo_fijo_34','activo_fijo_34','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD50','AF-DVALAL','si',NULL,NULL,'50','activo_fijo_35','activo_fijo_35','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD51','AF-DVALAL','si',NULL,NULL,'51','activo_fijo_36','activo_fijo_36','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD52','AF-DVALAL','si',NULL,NULL,'52','activo_fijo_37','activo_fijo_37','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD53','AF-DVALAL','si',NULL,NULL,'53','activo_fijo_38','activo_fijo_38','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD54','AF-DVALAL','si',NULL,NULL,'54','activo_fijo_39','activo_fijo_39','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD55','AF-DVALAL','si',NULL,NULL,'55','activo_fijo_40','activo_fijo_40','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD56','AF-DVALAL','si',NULL,NULL,'56','activo_fijo_41','activo_fijo_41','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD57','AF-DVALAL','si',NULL,NULL,'57','activo_fijo_42','activo_fijo_42','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD58','AF-DVALAL','si',NULL,NULL,'58','activo_fijo_43','activo_fijo_43','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD59','AF-DVALAL','si',NULL,NULL,'59','activo_fijo_44','activo_fijo_44','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD60','AF-DVALAL','si',NULL,NULL,'60','activo_fijo_45','activo_fijo_45','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD61','AF-DVALAL','si',NULL,NULL,'61','activo_fijo_46','activo_fijo_46','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD62','AF-DVALAL','si',NULL,NULL,'62','activo_fijo_47','activo_fijo_47','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD63','AF-DVALAL','si',NULL,NULL,'63','activo_fijo_48','activo_fijo_48','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD64','AF-DVALAL','si',NULL,NULL,'64','activo_fijo_49','activo_fijo_49','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD65','AF-DVALAL','si',NULL,NULL,'65','activo_fijo_50','activo_fijo_50','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD28','AF-DVALAL','si',NULL,NULL,'28','activo_fijo_13','activo_fijo_13','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD14','AF-DVALAL','si',NULL,NULL,'14','precio_total_usd','precio_total_usd','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD25','AF-DVALAL','si',NULL,NULL,'25','activo_fijo_10','activo_fijo_10','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD29','AF-DVALAL','si',NULL,NULL,'29','activo_fijo_14','activo_fijo_14','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD30','AF-DVALAL','si',NULL,NULL,'30','activo_fijo_15','activo_fijo_15','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD31','AF-DVALAL','si',NULL,NULL,'31','activo_fijo_16','activo_fijo_16','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD32','AF-DVALAL','si',NULL,NULL,'32','activo_fijo_17','activo_fijo_17','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD33','AF-DVALAL','si',NULL,NULL,'33','activo_fijo_18','activo_fijo_18','string',NULL,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD34','AF-DVALAL','si',NULL,NULL,'34','activo_fijo_19','activo_fijo_19','string',NULL,'activo');
/***********************************F-DAT-RCM-KAF-66-11/05/2020****************************************/

/***********************************I-DAT-RCM-KAF-69-23/06/2020****************************************/
select conta.f_import_ttipo_relacion_contable ('insert','AFDVALDACUMHABE',NULL,'Activos Fijos Desglose Dep. Acum. al HABER','activo','no','si','no','flujo','recurso_gasto','no','no','no',NULL);
select conta.f_import_ttipo_relacion_contable ('insert','AFDVALDACUMDEBE',NULL,'Activos Fijos Desglose Dep. Acum al DEBE','activo','no','si','no','flujo','recurso_gasto','no','no','no',NULL);
/***********************************F-DAT-RCM-KAF-69-23/06/2020****************************************/

/***********************************I-DAT-RCM-KAF-70-08/08/2020****************************************/
--Comprobante (1/4) V2 depreciación
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-ACTAF2','kaf.f_gestionar_cbte_deprec_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_depreciacion','{$tabla.fecha_mov}','activo','ENDE TRANSMISIÓN S.A.','{$tabla.id_depto_conta}','contable','','kaf.v_cbte_deprec_actualiz_activo_cab','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','(1/4) V2 Comprobante de actualización del activo fijo por depreciación','','','','','');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTAF2','DEPACTAF','debe','si','si','','','ALTAAF','','{$tabla.monto_actualiz}','{$tabla.id_clasificacion}','','no','','','','si','','id_movimiento','','Depreciación de la actualización del activo fijo','{$tabla.monto_actualiz}',NULL,'simple','','','no','','','','','','','','2','','kaf.v_cbte_deprec_1_v2',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTAF2','GASTO','haber','si','si','','','DEPACTIVO','','','','','no','','','','si','','','','Gasto de la actualización del activo fijo','','146','diferencia','','','no','','','','','','','','2','','','DEPACTAF','','CCDEPCON','','','todos','','si');

--Comprobante (2/4) V2 depreciación
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-ACTDEPAC2','kaf.f_gestionar_cbte_deprec_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_depreciacion','{$tabla.fecha_mov}','activo','ENDE TRANSMISION S.A.','{$tabla.id_depto_conta}','contable','','kaf.v_cbte_deprec_actualiz_dep_acum_cab','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','(2/4) V2 Comprobante de actualización de la depreciación acumulada','','','','','');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTDEPAC2','ACTDEPACUM','haber','si','si','','','DA-AITB','','{$tabla.dep_acum_actualiz}','{$tabla.id_clasificacion}','','no','','','','si','','id_movimiento','','Importe de la actualización de la depreciación acumulada','{$tabla.dep_acum_actualiz}',NULL,'simple','','','no','','','','','','','','2','','kaf.v_cbte_deprec_2_v2',NULL,'','CCDEPCON','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTDEPAC2','DEBE','debe','si','si','','','DEPGASTO','','','','','no','','','','no','','','','Importe al debe de la actualización de la  depreciación acumulada','','148','diferencia','','','no','','','','','','','','2','','','ACTDEPACUM','','CCDEPCON','','','todos','','si');

--Comprobante (3/4) V2 depreciación
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-DEPREC2','kaf.f_gestionar_cbte_deprec_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_depreciacion','{$tabla.fecha_mov}','activo','ENDE TRANSMISIÓN S.A.','{$tabla.id_depto_conta}','presupuestario','','kaf.v_cbte_deprec_depreciacion_cab','DIARIO','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','si','si','no','','','','','{$tabla.num_tramite}','','','','','','(3/4) V2 Comprobante de la depreciación mensual','','','','','');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-DEPREC2','DEPHABER','debe','si','no','{$tabla.id_partida}','','DEPCLAS','{$tabla.id_cuenta}','{$tabla.monto_depreciacion}','{$tabla.id_clasificacion}','','no','{$tabla.id_centro_costo}','','','si','','id_movimiento','','Importe de la depreciación al haber','{$tabla.monto_depreciacion}',NULL,'simple','','','no','','','','','','','','2','','kaf.v_cbte_deprec_3_v2',NULL,'','','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-DEPREC2','DEPDEBE','haber','si','si','','','DEPACCLAS','','{$tabla.monto_depreciacion}','{$tabla.id_clasificacion}','','no','','','','si','','id_movimiento','','Importe de la depreciación al debe','{$tabla.monto_depreciacion}',NULL,'simple','','','no','','','','','','','','2','','kaf.v_cbte_deprec_3_haber_v2',NULL,'','CCDEPCON','','','todos','','si');

--Comprobante (4/4) V2 depreciación
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-ACTDEPER2','kaf.f_gestionar_cbte_deprec_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_depreciacion','{$tabla.fecha_mov}','activo','ENDE TRANSMISION S.A.','{$tabla.id_depto_conta}','contable','','kaf.v_cbte_deprec_actualiz_dep_per_cab','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','(4/4) V2 Comprobante de actualización de la depreciación acumulada','','','','','');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTDEPER2','DEPPERACT','debe','si','no','{$tabla.id_partida}','','','{$tabla.id_cuenta}','{$tabla.dep_per_actualiz}','{$tabla.id_clasificacion}','','no','{$tabla.id_centro_costo}','','','si','','id_movimiento','','Importe de la actualización depreciación del período','{$tabla.dep_per_actualiz}',NULL,'simple','','','no','','','','','','','','2','','kaf.v_cbte_deprec_4_v2',NULL,'','','','','todos','','si');
select conta.f_import_tdetalle_plantilla_comprobante ('insert','KAF-DEP-ACTDEPER2','DIF','haber','si','si','','','KAF-ACT-DEPER','','','','','no','','','','no','','','','Diferencia Actualización','','158','diferencia','','','no','','','','','','','','2','','','DEPPERACT','','CCDEPCON','','','todos','','si');
/***********************************F-DAT-RCM-KAF-70-08/08/2020****************************************/

/***********************************I-DAT-RCM-KAF-AF-13-23/09/2020****************************************/
select pxp.f_insert_tgui ('8 Comparación Saldos BS-UFV', 'Saldos por fecha y comparación entre moneda Bolivianos y UFV', 'KAF.REP.14', 'si', 15, 'sis_kactivos_fijos/vista/reportes/ParametrosRepSaldoAf.php', 3, '', 'ParametrosRepSaldoAf', 'KAF');
select pxp.f_insert_testructura_gui ('KAF.REP.14', 'KAFREP');
/***********************************F-DAT-RCM-KAF-AF-13-23/09/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-1443-06/11/2020****************************************/
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-DEPREC3','kaf.f_gestionar_cbte_deprec_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_depreciacion','{$tabla.fecha_mov}','activo','ENDE TRANSMISIÓN S.A.','{$tabla.id_depto_conta}','presupuestario','','kaf.v_cbte_deprec_depreciacion_cab','DIARIO','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','si','si','no','','','','','{$tabla.num_tramite}','','','','','','(3/4) V3 Comprobante de la depreciación mensual','','','','','');

UPDATE kaf.tmovimiento_tipo SET
plantilla_cbte_tres = 'KAF-DEP-DEPREC3'
WHERE id_cat_movimiento = 59;
/***********************************F-DAT-RCM-KAF-ETR-1443-06/11/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2045-04/12/2020****************************************/
select conta.f_import_tplantilla_comprobante ('insert','KAF-BAJA-VEN','kaf.f_gestionar_cbte_baja_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_baja','{$tabla.fecha_mov}','activo','ENDE TRANSMISION S.A.','{$tabla.id_depto_conta}','presupuestario','','kaf.v_cbte_baja_cab','DIARIO','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','si','si','si','','','','','{$tabla.num_tramite}','','','','','','Comprobante de Baja por Venta','','','','','');
select conta.f_import_tplantilla_comprobante ('insert','KAF-BAJA-SIN','kaf.f_gestionar_cbte_baja_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','kaf.f_gestionar_cbte_baja','{$tabla.fecha_mov}','activo','ENDE TRANSMISION S.A.','{$tabla.id_depto_conta}','presupuestario','','kaf.v_cbte_baja_cab','DIARIO','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','si','si','si','','','','','{$tabla.num_tramite}','','','','','','Comprobante de Baja por Siniestro','','','','','');
select conta.f_import_ttipo_relacion_contable ('insert','KAF-BAJA-SIN',NULL,'Bajas por Siniestro de Activos Fijos','activo','no','si','no','flujo_presupuestaria','recurso_gasto','no','no','no',NULL);
select conta.f_import_ttipo_relacion_contable ('insert','AF-BAJA-VEN','TCLS','Baja por Venta de Activos Fijos','activo','si-general','si','no','flujo_presupuestaria','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','AF-BAJA-DACUM','TCLS','Depreciación acumulada para Bajas','activo','si-general','si','no','flujo_presupuestaria','recurso_gasto','no','no','no','');
select conta.f_import_ttipo_relacion_contable ('insert','AF-BAJA-VACT','TCLS','Valor Actualizado para Bajas','activo','si-general','si','no','flujo_presupuestaria','recurso_gasto','no','no','no','');

UPDATE kaf.tmovimiento_motivo SET
motivo = 'Siniestro',
plantilla_cbte = 'KAF-BAJA-SIN'
WHERE id_movimiento_motivo = 4;

UPDATE kaf.tactivo_fijo SET
id_clasificacion = 447
WHERE id_activo_fijo = 47506;

UPDATE kaf.tactivo_fijo_valores afv SET
codigo = af.codigo
FROM kaf.tactivo_fijo af
WHERE af.id_activo_fijo = afv.id_activo_fijo
AND afv.codigo IS NULL;

DELETE FROM kaf.tmovimiento_af_dep WHERE id_movimiento_af_dep = 13827140;
/***********************************F-DAT-RCM-KAF-ETR-2045-04/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2045-07/12/2020****************************************/
select conta.f_import_tplantilla_comprobante ('insert','KAF-DEP-IGUALV2','kaf.f_gestionar_cbte_igualacion_eliminacion','id_movimiento','KAF','{$tabla.glosa_cbte}','','{$tabla.fecha_mov}','activo','ENDE TRANSMISIÓN S.A.','{$tabla.id_depto_conta}','contable','','kaf.vdeprec_igualacion_conta_haber_cab','DIARIOCON','{$tabla.id_moneda}','{$tabla.id_gestion}','{$tabla.id_movimiento},{$tabla.gestion},{$tabla.id_depto_conta}','no','no','no','','','','','{$tabla.num_tramite}','','','','','','Comprobante para igualar saldos del cálculo de depreciación con saldos contables por diferencias por redondeo','','','','','');
/***********************************F-DAT-RCM-KAF-ETR-2045-07/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2045-08/12/2020****************************************/
DELETE FROM kaf.tmovimiento_af_dep WHERE id_movimiento_af_dep = 14108737;
DELETE FROM kaf.treporte_detalle_dep2 where id = 1678780  AND codigo = '01.06.8.00178';
/***********************************F-DAT-RCM-KAF-ETR-2045-08/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2029-15/12/2020****************************************/
select param.f_import_tplantilla_archivo_excel ('insert','AF-DATAUPD','AF -Actualiz. datos','activo',NULL,'2',NULL,'','xlsx','');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD00','AF-DATAUPD','si','',NULL,'1','codigo','codigo','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD01','AF-DATAUPD','si','',NULL,'2','nro_serie','nro_serie','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD02','AF-DATAUPD','si','',NULL,'3','marca','marca','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD03','AF-DATAUPD','si','',NULL,'4','denominacion','denominacion','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD04','AF-DATAUPD','si','',NULL,'5','descripcion','descripcion','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD05','AF-DATAUPD','si','',NULL,'6','unidad_medida','unidad_medida','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD06','AF-DATAUPD','si','',NULL,'7','observaciones','observaciones','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD07','AF-DATAUPD','si','',NULL,'8','ubicacion','ubicacion','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD08','AF-DATAUPD','si','',NULL,'9','local','local','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD09','AF-DATAUPD','si','',NULL,'10','responsable','responsable','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_10','AF-DATAUPD','si','',NULL,'11','proveedor','proveedor','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_11','AF-DATAUPD','si','dd-mm-yyyy',NULL,'12','fecha_compra','fecha_compra','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_12','AF-DATAUPD','si','',NULL,'13','documento','documento','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_13','AF-DATAUPD','si','',NULL,'14','cbte_asociado','cbte_asociado','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_14','AF-DATAUPD','si','dd-mm-yyyy',NULL,'15','fecha_cbte_asociado','fecha_cbte_asociado','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_15','AF-DATAUPD','si','',NULL,'16','grupo_ae','grupo_ae','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_16','AF-DATAUPD','si','',NULL,'17','clasificador_ae','clasificador_ae','string','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_17','AF-DATAUPD','si','',NULL,'18','centro_costo','centro_costo','string','','activo');

select pxp.f_insert_tgui ('Actualización Masiva', 'Actualización Masiva', 'KAFACMAS', 'si', 6, 'sis_kactivos_fijos/vista/activo_mod_masivo/ActivoModMasivo.php', 2, '', 'ActivoModMasivo', 'KAF');
select pxp.f_insert_testructura_gui ('KAFACMAS', 'KAF');

select wf.f_import_tproceso_macro ('insert','KAF-MASIV', 'KAF', 'Actualización Masiva','si');
select wf.f_import_ttipo_proceso ('insert','KAF-MASIV',NULL,NULL,'KAF-MASIV','Actualización Masiva Activos Fijos','kaf.tmovimiento','id_movimiento','si','','','','KAF-MASIV',NULL);
select wf.f_import_ttipo_estado ('insert','borrador','KAF-MASIV','Borrador','si','no','no','ninguno','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL,'no','Inicial','','',NULL,'no',NULL,'','');
select wf.f_import_ttipo_estado ('insert','procesado','KAF-MASIV','Procesado','no','no','no','ninguno','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL,'no','Proceso','','',NULL,'no',NULL,'','');
select wf.f_import_ttipo_estado ('insert','finalizado','KAF-MASIV','Finalizado','no','no','si','ninguno','','ninguno','','','si','no',NULL,'<font color="99CC00" size="5"><font size="4">{TIPO_PROCESO}</font></font><br><br><b>&nbsp;</b>Tramite:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp; &nbsp;&nbsp; <b>{NUM_TRAMITE}</b><br><b>&nbsp;</b>Usuario :<b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {USUARIO_PREVIO} </b>en estado<b>&nbsp; {ESTADO_ANTERIOR}<br></b>&nbsp;<b>Responsable:&nbsp;&nbsp; &nbsp;&nbsp; </b><b>{FUNCIONARIO_PREVIO}&nbsp; {DEPTO_PREVIO}<br>&nbsp;</b>Estado Actual<b>: &nbsp; &nbsp;&nbsp; {ESTADO_ACTUAL}</b><br><br><br>&nbsp;{OBS} <br>','Aviso WF ,  {PROCESO_MACRO}  ({NUM_TRAMITE})','','no','','','','','notificacion','','{}',NULL,'no','Final','','',NULL,'no',NULL,'','');
select wf.f_import_testructura_estado ('insert','borrador','procesado','KAF-MASIV',1,'','no');
select wf.f_import_testructura_estado ('insert','procesado','finalizado','KAF-MASIV',1,'','no');
/***********************************F-DAT-RCM-KAF-ETR-2029-15/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2170-31/12/2020****************************************/
--SEPTIEMBRE 2020
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 269098.832573739 WHERE id_movimiento_af_dep = 13750415;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2224901.6492635 WHERE id_movimiento_af_dep = 13768542;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2431463.13629132 WHERE id_movimiento_af_dep = 13766986;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 157815.195118555 WHERE id_movimiento_af_dep = 13767092;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 69647.0252407307 WHERE id_movimiento_af_dep = 13750708;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 788176.634571781 WHERE id_movimiento_af_dep = 13770949;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 79646.4160350747 WHERE id_movimiento_af_dep = 13771008;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1882658.54012401 WHERE id_movimiento_af_dep = 13756422;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 940971.75908339 WHERE id_movimiento_af_dep = 13769599;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 15846.8707207166 WHERE id_movimiento_af_dep = 13771265;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 396171.957505789 WHERE id_movimiento_af_dep = 13815949;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 240111.904327116 WHERE id_movimiento_af_dep = 13817852;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 866779.214556492 WHERE id_movimiento_af_dep = 13805041;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 271932.423681905 WHERE id_movimiento_af_dep = 13821336;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 784962.099151519 WHERE id_movimiento_af_dep = 13817997;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 603201.23745362 WHERE id_movimiento_af_dep = 13806886;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 578102.021346125 WHERE id_movimiento_af_dep = 13816541;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 88350.6045899755 WHERE id_movimiento_af_dep = 13807196;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 350247.697944514 WHERE id_movimiento_af_dep = 13821895;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 439969.626262886 WHERE id_movimiento_af_dep = 13807281;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1630829.59007998 WHERE id_movimiento_af_dep = 13804041;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 364953.588499245 WHERE id_movimiento_af_dep = 13820516;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 190162.543392536 WHERE id_movimiento_af_dep = 13817261;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1010349.38520591 WHERE id_movimiento_af_dep = 13802833;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1791537.07543854 WHERE id_movimiento_af_dep = 13819154;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 931986.591595885 WHERE id_movimiento_af_dep = 13817468;

--OCTUBRE 2020
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 269407.375965 WHERE id_movimiento_af_dep = 13962405;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2227452.658236 WHERE id_movimiento_af_dep = 13951590;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2434250.9796345 WHERE id_movimiento_af_dep = 13946617;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 157996.1405295 WHERE id_movimiento_af_dep = 13946941;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 69726.8752245 WHERE id_movimiento_af_dep = 13963345;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 789080.330727 WHERE id_movimiento_af_dep = 13959397;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 79737.7397895 WHERE id_movimiento_af_dep = 13959555;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1884817.138815 WHERE id_movimiento_af_dep = 13981249;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 942050.6461665 WHERE id_movimiento_af_dep = 13954972;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 15865.038423 WHERE id_movimiento_af_dep = 13960408;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 396626.19633 WHERE id_movimiento_af_dep = 13983169;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 240387.208542 WHERE id_movimiento_af_dep = 13989357;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 867773.039328 WHERE id_movimiento_af_dep = 14016765;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 272244.21588 WHERE id_movimiento_af_dep = 14000439;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 785862.1099485 WHERE id_movimiento_af_dep = 13989781;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 603892.845036 WHERE id_movimiento_af_dep = 14022805;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 578764.85121 WHERE id_movimiento_af_dep = 13985139;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 88451.9047035 WHERE id_movimiento_af_dep = 14023749;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 350649.2798055 WHERE id_movimiento_af_dep = 14002164;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 440474.080176 WHERE id_movimiento_af_dep = 14023995;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1632699.4451625 WHERE id_movimiento_af_dep = 14013631;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 365372.0381025 WHERE id_movimiento_af_dep = 13997736;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 190380.5789535 WHERE id_movimiento_af_dep = 13987455;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1011507.817671 WHERE id_movimiento_af_dep = 14009818;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1793591.1993285 WHERE id_movimiento_af_dep = 13993468;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 933055.1783865 WHERE id_movimiento_af_dep = 13988164;

--NOVIEMBRE 2020
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 269582.215644 WHERE id_movimiento_af_dep = 14073581;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2228898.2278176 WHERE id_movimiento_af_dep = 14038714;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 2435830.7569452 WHERE id_movimiento_af_dep = 14056518;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 158098.6766772 WHERE id_movimiento_af_dep = 14056852;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 69772.1264892 WHERE id_movimiento_af_dep = 14097347;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 789592.4271432 WHERE id_movimiento_af_dep = 14046469;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 79789.4878932 WHERE id_movimiento_af_dep = 14046627;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1886040.345204 WHERE id_movimiento_af_dep = 14115651;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 942662.0170764 WHERE id_movimiento_af_dep = 14064998;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 15875.3344968 WHERE id_movimiento_af_dep = 14070589;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 396883.598328 WHERE id_movimiento_af_dep = 14026642;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 240543.2147472 WHERE id_movimiento_af_dep = 14032831;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 868336.2056448 WHERE id_movimiento_af_dep = 14107426;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 272420.896608 WHERE id_movimiento_af_dep = 14067209;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 786372.1178076 WHERE id_movimiento_af_dep = 14056227;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 604284.7586976 WHERE id_movimiento_af_dep = 14113733;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 579140.457336 WHERE id_movimiento_af_dep = 14051593;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 88509.3081156 WHERE id_movimiento_af_dep = 14114731;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 350876.8437588 WHERE id_movimiento_af_dep = 14068953;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 440759.9385216 WHERE id_movimiento_af_dep = 14091933;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1633759.03251 WHERE id_movimiento_af_dep = 14081521;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 365609.156814 WHERE id_movimiento_af_dep = 14064335;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 190504.1319156 WHERE id_movimiento_af_dep = 14030923;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1012164.2648136 WHERE id_movimiento_af_dep = 14077694;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 1794755.2020156 WHERE id_movimiento_af_dep = 14059870;
UPDATE kaf.tmovimiento_af_dep SET monto_actualiz_ant = 933660.7114284 WHERE id_movimiento_af_dep = 14054588;

--Variable global para ya no actualizar y con que fecha de TC UFV realizar la act (caso de baja en la UFV). Si el valor es vacío se hace la actualización normalmente
INSERT INTO pxp.variable_global (
	"variable", "valor", "descripcion"
) VALUES (
	E'kaf_actualizar_baja_ufv', E'10-12-2020', E'Considerando el caso de baja en la UFV, en esta variable se coloca fecha exacta, donde en el mes que se defina actualizará loas AF que iniciaron su depreciación antes de la fecha específica; en meses distintos directamente no actualizará en ningún caso'
);
/***********************************F-DAT-RCM-KAF-ETR-2170-31/12/2020****************************************/

/***********************************I-DAT-RCM-KAF-ETR-2778-05/02/2021****************************************/
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_18','AF-DATAUPD','si','',NULL,'19','bs_valor_compra','bs_valor_compra', 'numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_19','AF-DATAUPD','si','',NULL,'20','bs_valor_inicial','bs_valor_inicial','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_20','AF-DATAUPD','si','dd-mm-yyyy',NULL,'21','bs_fecha_ini_dep','bs_fecha_ini_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_21','AF-DATAUPD','si','',NULL,'22','bs_vutil_orig','bs_vutil_orig','entero','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_22','AF-DATAUPD','si','',NULL,'23','bs_vutil','bs_vutil','entero', '' ,'activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_23','AF-DATAUPD','si','dd-mm-yyyy',NULL,'24','bs_fult_dep','bs_fult_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_24','AF-DATAUPD','si','dd-mm-yyyy',NULL,'25','bs_fecha_fin','bs_fecha_fin','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_25','AF-DATAUPD','si','',NULL,'26','bs_val_resc','bs_val_resc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_26','AF-DATAUPD','si','',NULL,'27','bs_vact_ini','bs_vact_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_27','AF-DATAUPD','si','',NULL,'28','bs_dacum_ini','bs_dacum_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_28','AF-DATAUPD','si','',NULL,'29','bs_dper_ini','bs_dper_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_29','AF-DATAUPD','si','',NULL,'30','bs_inc','bs_inc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_30','AF-DATAUPD','si','',NULL,'31','bs_inc_sact','bs_inc_sact','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_31','AF-DATAUPD','si','dd-mm-yyyy',NULL,'32','bs_fechaufv_ini','bs_fechaufv_ini','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_32','AF-DATAUPD','si','',NULL,'33','usd_valor_compra','usd_valor_compra','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_33','AF-DATAUPD','si','',NULL,'34','usd_valor_inicial','usd_valor_inicial','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_34','AF-DATAUPD','si','dd-mm-yyyy',NULL,'35','usd_fecha_ini_dep','usd_fecha_ini_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_35','AF-DATAUPD','si','',NULL,'36','usd_vutil_orig','usd_vutil_orig','entero','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_36','AF-DATAUPD','si','',NULL,'37','usd_vutil','usd_vutil','entero','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_37','AF-DATAUPD','si','dd-mm-yyyy',NULL,'38','usd_fult_dep','usd_fult_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_38','AF-DATAUPD','si','dd-mm-yyyy',NULL,'39','usd_fecha_fin','usd_fecha_fin','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_39','AF-DATAUPD','si','',NULL,'40','usd_val_resc','usd_val_resc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_40','AF-DATAUPD','si','',NULL,'41','usd_vact_ini','usd_vact_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_41','AF-DATAUPD','si','',NULL,'42','usd_dacum_ini','usd_dacum_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_42','AF-DATAUPD','si','',NULL,'43','usd_dper_ini','usd_dper_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_43','AF-DATAUPD','si','',NULL,'44','usd_inc','usd_inc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_44','AF-DATAUPD','si','',NULL,'45','usd_inc_sact','usd_inc_sact','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_45','AF-DATAUPD','si','dd-mm-yyyy',NULL,'46','usd_fecha_ufv_ini','usd_fecha_ufv_ini','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_46','AF-DATAUPD','si','',NULL,'47','ufv_valor_compra','ufv_valor_compra','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_47','AF-DATAUPD','si','',NULL,'48','ufv_valor_inicial','ufv_valor_inicial','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_48','AF-DATAUPD','si','dd-mm-yyyy',NULL,'49','ufv_fecha_ini_dep','ufv_fecha_ini_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_49','AF-DATAUPD','si','',NULL,'50','ufv_vutil_orig','ufv_vutil_orig','entero','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_50','AF-DATAUPD','si','',NULL,'51','ufv_vutil','ufv_vutil','entero','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_51','AF-DATAUPD','si','dd-mm-yyyy',NULL,'52','ufv_fult_dep','ufv_fult_dep','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_52','AF-DATAUPD','si','dd-mm-yyyy',NULL,'53','ufv_fecha_fin','ufv_fecha_fin','date','','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_53','AF-DATAUPD','si','',NULL,'54','ufv_val_resc','ufv_val_resc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_54','AF-DATAUPD','si','',NULL,'55','ufv_vact_ini','ufv_vact_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_55','AF-DATAUPD','si','',NULL,'56','ufv_dacum_ini','ufv_dacum_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_56','AF-DATAUPD','si','',NULL,'57','ufv_dper_ini','ufv_dper_ini','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_57','AF-DATAUPD','si','',NULL,'58','ufv_inc','ufv_inc','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_58','AF-DATAUPD','si','',NULL,'59','ufv_inc_sact','ufv_inc_sact','numeric',',','activo');
select param.f_import_tcolumna_plantilla_archivo_excel ('insert','COD_59','AF-DATAUPD','si','dd-mm-yyyy',NULL,'60','ufv_fecha_ufv_ini','ufv_fecha_ufv_ini','date','','activo');
/***********************************F-DAT-RCM-KAF-ETR-2778-05/02/2021****************************************/