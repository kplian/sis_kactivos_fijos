

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




INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 101, null, null, 'Depreciación hasta tal fecha', '31/12/2019',
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);

INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 104, null, null, 'Alta de activos Fijos', null,
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);
INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 105, null, null, 'Baja de activo fijo X', null,
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);
INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 106, null, null, 'Revalorización activo fijo', null,
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);
INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 108, null, null, 'Asignación del activo fijo', null,
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);
INSERT INTO  kaf.tmovimiento (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_cat_movimiento, id_estado_wf, id_proceso_wf, glosa, fecha_hasta, estado, fecha_mov, id_depto
) 
VALUES (
1, null, now(), null, 'activo', null, null, 109, null, null, 'Devolución de activo fijo x', null,
'borrador', now(), 7
);

INSERT INTO kaf.tmovimiento_af (
id_usuario_reg, id_usuario_mod, fecha_reg, fecha_mod, estado_reg, id_usuario_ai, usuario_ai,
id_movimiento, id_activo_fijo, id_cat_estado_fun, id_depto, id_funcionario,
id_persona, vida_util, monto_vigente, id_cat_estado_fun_nuevo, id_depto_nuevo,
id_funcionario_nuevo, vida_util_nuevo, monto_vigente_nuevo
)  VALUES (
1,null,now(),null,'activo',null,null,
1, 1, null, null, null, null, null, null, null, null, null, null, null 
);


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

