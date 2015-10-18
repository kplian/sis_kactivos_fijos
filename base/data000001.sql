/***********************************I-DAT-RCM-KAF-1-02/09/2015****************************************/
INSERT INTO segu.tsubsistema ("codigo", "nombre", "fecha_reg", "prefijo", "estado_reg", "nombre_carpeta", "id_subsis_orig")
VALUES (E'KAF', E'Sistema de Activos Fijos', E'2015-09-03', E'SKA', E'activo', E'ACTIVOS FIJOS', NULL);

-----------------------------------
--DEFINICION DE INTERFACES
-----------------------------------
select pxp.f_insert_tgui ('K - ACTIVOS FIJOS', '', 'KAF', 'si',1 , '', 1, '../../../lib/imagenes/alma32x32.png', '', 'KAF');
select pxp.f_insert_tgui ('Clasificación', 'Clasificación de activos fijos', 'KAFCLA', 'si', 1, 'sis_kactivos_fijos/vista/clasificacion/Clasificacion.php', 2, '', 'Clasificacion', 'KAF');
select pxp.f_insert_tgui ('Principal', 'Interfaz principal', 'KAFACF', 'si', 2, 'sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php', 2, '', 'ActivoFijo', 'KAF');
select pxp.f_insert_tgui ('Movimientos', 'Movimientos de los activos fijos', 'KAFMOV', 'si', 3, 'sis_kactivos_fijos/vista/movimiento/Movimiento.php', 2, '', 'Movimiento', 'KAF');
select pxp.f_insert_tgui ('Reportes', 'Reportes', 'KAFREP', 'si', 4, '', 2, '', '', 'ALM');

select pxp.f_insert_testructura_gui ('KAF', 'SISTEMA');
select pxp.f_insert_testructura_gui ('KAFCLA', 'KAF');
select pxp.f_insert_testructura_gui ('KAFACF', 'KAF');
select pxp.f_insert_testructura_gui ('KAFMOV', 'KAF');
select pxp.f_insert_testructura_gui ('KAFREP', 'KAF');
/***********************************F-DAT-RCM-KAF-1-02/09/2015****************************************/

/***********************************I-DAT-RCM-KAF-1-11/09/2015****************************************/
select pxp.f_add_catalog('KAF','tclasificacion__id_cat_metodo_dep','lineal');
select pxp.f_add_catalog('KAF','tclasificacion__id_cat_metodo_dep','hrs_prod');
select pxp.f_add_catalog('KAF','tactivo_fijo__id_cat_estado_fun','bueno');
select pxp.f_add_catalog('KAF','tactivo_fijo__id_cat_estado_fun','regular');
select pxp.f_add_catalog('KAF','tactivo_fijo__id_cat_estado_fun','malo');

ALTER SEQUENCE kaf.tactivo_fijo_valores_id_activo_fijo_valor_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_af_dep_id_movimiento_af_dep_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_id_movimiento_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tmovimiento_af_id_movimiento_af_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
ALTER SEQUENCE kaf.tactivo_fijo_id_activo_fijo_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 RESTART 1 CACHE 1 NO CYCLE;
DELETE FROM kaf.tmovimiento_af_dep;
DELETE FROM kaf.tmovimiento_af;
DELETE FROM kaf.tmovimiento;
DELETE FROM kaf.tactivo_fijo_valores;
DELETE FROM kaf.tactivo_fijo;

INSERT INTO kaf.tactivo_fijo (
  id_usuario_reg ,id_usuario_mod  ,fecha_reg      ,fecha_mod   ,estado_reg ,id_usuario_ai ,usuario_ai     ,id_clasificacion  ,id_moneda             ,id_moneda_orig        ,id_cat_estado_fun,
  id_depto       ,id_centro_costo ,id_funcionario ,id_persona  ,codigo     ,denominacion  ,descripcion    ,vida_util_original         ,vida_util    ,monto_compra_mon_orig ,
  monto_compra   ,monto_vigente   ,monto_actualiz ,foto        ,estado     ,documento     ,fecha_ini_dep  ,depreciacion_acum ,depreciacion_per 		,observaciones,
  fecha_ult_dep, depreciacion_mes
) VALUES (
  1, null, now(), null, 'activo', null, null, 300, 1, 1, 79,
  7, null, null, null, null, 'RACK', 'RACK  - CDR700 DESKTOP RPTR HOUSING, MARCA MOTOROLA, MODELO HKLN4056A.', 120, 120, 2888.4,
  2888.4, 2888.4, 2888.4, null, 'alta', null, '01/10/2014', 0, null, 0, null, 0
);

/***********************************F-DAT-RCM-KAF-1-11/09/2015****************************************/

/***********************************I-DAT-RCM-KAF-1-22/09/2015****************************************/
INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, descripcion, fecha_ini, fecha_hasta, estado, observaciones
) 
VALUES (
1, null, now(), null, 'activo', null, null, 85, null, null, 'Depreciación hasta tal fecha', null, '31/12/2019', 'borrador','prueba'
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_centro_costo, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo, id_centro_costo_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null, null, null 
);
/***********************************F-DAT-RCM-KAF-1-22/09/2015****************************************/

/***********************************I-DAT-RCM-KAF-1-06/10/2015****************************************/
INSERT INTO kaf.tactivo_fijo_valores (
  id_usuario_reg,id_usuario_mod,fecha_reg,fecha_mod,estado_reg,id_usuario_ai,usuario_ai,
  id_activo_fijo,monto_vigente_orig,vida_util_orig,fecha_ini_dep,depreciacion_mes,
  depreciacion_per,depreciacion_acum,monto_vigente,vida_util,fecha_ult_dep,tipo_cambio_ini,
  tipo_cambio_fin,tipo,estado,principal, monto_rescate
) VALUES (
  1, null, now(), now(), 'activo', null, null,
  1, 2888.4, 120,'01/10/2014',0,0,0,2888.4,120,null,
  null,null,'compra','activo','si',1
);
/***********************************F-DAT-RCM-KAF-1-06/10/2015****************************************/