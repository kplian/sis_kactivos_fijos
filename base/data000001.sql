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
select pxp.f_insert_tgui ('Reportes', 'Reportes', 'KAFREP', 'si', 4, '', 2, '', '', 'ALM');

select pxp.f_insert_testructura_gui ('KAF', 'SISTEMA');
select pxp.f_insert_testructura_gui ('KAFCLA', 'KAF');
select pxp.f_insert_testructura_gui ('KAFACF', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOV', 'KAF');
select pxp.f_insert_testructura_gui ('KAFREP', 'KAF');


INSERT INTO pxp.variable_global ("variable", "valor", "descripcion")
VALUES 
  (E'kaf_codigo_longitud', E'4', E'Longitud correlativo en el codigo de activos');
  
  
  
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
select param.f_import_tcatalogo ('insert','KAF','Mejora/Revalorización','reval','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Depreciación/Actualización','deprec','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Asignación','asig','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Devolución','devol','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Transferencia','transf','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Incrementos/Decrementos','incdec','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Desuso temporal','desuso','tmovimiento__id_cat_movimiento');
select param.f_import_tcatalogo ('insert','KAF','Transferencia Deposito','tranfdep','tmovimiento__id_cat_movimiento');



/***********************************F-DAT-RAC-KAF-1-25/07/2016****************************************/

