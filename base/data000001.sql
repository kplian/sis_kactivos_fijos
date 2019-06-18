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
select pxp.f_insert_tgui ('Formulario 605', 'Reporte con el formato del formulario 605 para impuestos', 'KAF.REP.08', 'si', 6, 'sis_kactivos_fijos/vista/reportes/ParametrosRepForm605.php', 3, '', 'ParametrosRepForm605', 'KAF');
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