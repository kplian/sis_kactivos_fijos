/***********************************I-DEP-RCM-KAF-1-02/09/2015****************************************/
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_clasificacion_fk foreign key (id_clasificacion_fk) references kaf.tclasificacion (id_clasificacion);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_concepto_ingas foreign key (id_concepto_ingas) references param.tconcepto_ingas (id_concepto_ingas);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_cat_metodo_dep foreign key (id_cat_metodo_dep) references param.tcatalogo (id_catalogo);

alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_clasificacion foreign key (id_clasificacion) references kaf.tclasificacion (id_clasificacion);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_moneda foreign key (id_moneda) references param.tmoneda (id_moneda);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_moneda_orig foreign key (id_moneda_orig) references param.tmoneda (id_moneda);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_cat_estado_fun foreign key (id_cat_estado_fun) references param.tcatalogo (id_catalogo);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_depto foreign key (id_depto) references param.tdepto (id_depto);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_centro_costo foreign key (id_centro_costo) references param.tcentro_costo (id_centro_costo);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_persona foreign key (id_persona) references segu.tpersona (id_persona);

alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_cat_movimiento foreign key (id_cat_movimiento) references param.tcatalogo (id_catalogo);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_estado_wf foreign key (id_estado_wf) references wf.testado_wf (id_estado_wf);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_proceso_wf foreign key (id_proceso_wf) references wf.tproceso_wf (id_proceso_wf);

alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_movimiento foreign key (id_movimiento) references kaf.tmovimiento (id_movimiento);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_activo_fijo foreign key (id_activo_fijo) references kaf.tactivo_fijo (id_activo_fijo);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_cat_estado_fun foreign key (id_cat_estado_fun) references param.tcatalogo (id_catalogo);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_depto foreign key (id_depto) references param.tdepto (id_depto);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_centro_costo foreign key (id_centro_costo) references param.tcentro_costo (id_centro_costo);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_persona foreign key (id_persona) references segu.tpersona (id_persona);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_cat_estado_fun_nuevo foreign key (id_cat_estado_fun_nuevo) references param.tcatalogo (id_catalogo);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_depto_nuevo foreign key (id_depto_nuevo) references param.tdepto (id_depto);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_centro_costo_nuevo foreign key (id_centro_costo_nuevo) references param.tcentro_costo (id_centro_costo);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_funcionario_nuevo foreign key (id_funcionario_nuevo) references orga.tfuncionario (id_funcionario);

alter table kaf.tmovimiento_af_dep
add constraint fk_tmovimiento_af_dep__id_movimiento_af foreign key (id_movimiento_af) references kaf.tmovimiento_af (id_movimiento_af);
alter table kaf.tmovimiento_af_dep
add constraint fk_tmovimiento_af_dep__id_moneda foreign key (id_moneda) references param.tmoneda (id_moneda);
/***********************************F-DEP-RCM-KAF-1-02/09/2015****************************************/