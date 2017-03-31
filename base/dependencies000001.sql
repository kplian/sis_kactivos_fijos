/***********************************I-DEP-RCM-KAF-1-02/09/2015****************************************/
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_clasificacion_fk foreign key (id_clasificacion_fk) references kaf.tclasificacion (id_clasificacion);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_concepto_ingas foreign key (id_concepto_ingas) references param.tconcepto_ingas (id_concepto_ingas);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_cat_metodo_dep foreign key (id_cat_metodo_dep) references param.tcatalogo (id_catalogo);


alter table kaf.tactivo_fijo
add constraint fk_tactivo_fijo__id_moneda foreign key (id_moneda) references param.tmoneda (id_moneda);
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
add constraint fk_tmovimiento_af__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tmovimiento_af
add constraint fk_tmovimiento_af__id_funcionario_nuevo foreign key (id_funcionario_nuevo) references orga.tfuncionario (id_funcionario);

alter table kaf.tmovimiento_af_dep
add constraint fk_tmovimiento_af_dep__id_movimiento_af foreign key (id_movimiento_af) references kaf.tmovimiento_af (id_movimiento_af);
alter table kaf.tmovimiento_af_dep
add constraint fk_tmovimiento_af_dep__id_moneda foreign key (id_moneda) references param.tmoneda (id_moneda);
/***********************************F-DEP-RCM-KAF-1-02/09/2015****************************************/

/***********************************I-DEP-RCM-KAF-1-18/03/2016****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT fk_tmovimiento_af__id_movimiento FOREIGN KEY (id_movimiento)
    REFERENCES kaf.tmovimiento(id_movimiento)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT fk_tmovimiento_af__id_activo_fijo FOREIGN KEY (id_activo_fijo)
    REFERENCES kaf.tactivo_fijo(id_activo_fijo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT fk_tmovimiento_af__id_cat_estado_fun FOREIGN KEY (id_cat_estado_fun)
    REFERENCES param.tcatalogo(id_catalogo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tmovimiento_tipo
  ADD CONSTRAINT fk_tmovimiento_tipo_motivo__id_cat_movimiento FOREIGN KEY (id_cat_movimiento)
    REFERENCES param.tcatalogo(id_catalogo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT fk_tmovimiento_af__id_movimiento_motivo FOREIGN KEY (id_movimiento_motivo)
    REFERENCES kaf.tmovimiento_motivo(id_movimiento_motivo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-18/03/2016****************************************/    

/***********************************I-DEP-RCM-KAF-1-28/03/2016****************************************/

ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_moneda_orig FOREIGN KEY (id_moneda_orig)
    REFERENCES param.tmoneda(id_moneda)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_moneda FOREIGN KEY (id_moneda)
    REFERENCES param.tmoneda(id_moneda)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo_id__proveedor FOREIGN KEY (id_proveedor)
    REFERENCES param.tproveedor(id_proveedor)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_cat_estado_compra FOREIGN KEY (id_cat_estado_compra)
    REFERENCES param.tcatalogo(id_catalogo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_cat_estado_fun FOREIGN KEY (id_cat_estado_fun)
    REFERENCES param.tcatalogo(id_catalogo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_centro_costo FOREIGN KEY (id_centro_costo)
    REFERENCES param.tcentro_costo(id_centro_costo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;    
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_depto FOREIGN KEY (id_depto)
    REFERENCES param.tdepto(id_depto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;    
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT tactivo_fijo__id_oficina FOREIGN KEY (id_oficina)
    REFERENCES orga.toficina(id_oficina)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_deposito FOREIGN KEY (id_deposito)
    REFERENCES kaf.tdeposito(id_deposito)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT tactivo_fijo__id_funcionario FOREIGN KEY (id_funcionario)
    REFERENCES orga.tfuncionario(id_funcionario)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_persona FOREIGN KEY (id_persona)
    REFERENCES segu.tpersona(id_persona)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;        
/***********************************F-DEP-RCM-KAF-1-28/03/2016****************************************/

/***********************************I-DEP-RCM-KAF-1-06/05/2016****************************************/
alter table kaf.tactivo_fijo_caract
add constraint fk_tactivo_fijo_caract__id_activo_fijo foreign key (id_activo_fijo) references kaf.tactivo_fijo (id_activo_fijo);
alter table kaf.tactivo_fijo_valores
add constraint fk_tactivo_fijo_valores__id_activo_fijo foreign key (id_activo_fijo) references kaf.tactivo_fijo (id_activo_fijo);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_depto foreign key (id_depto) references param.tdepto (id_depto);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_oficina foreign key (id_oficina) references orga.toficina (id_oficina);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_depto foreign key (id_depto) references param.tdepto (id_depto);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_oficina foreign key (id_oficina) references orga.toficina (id_oficina);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_responsable_depto foreign key (id_responsable_depto) references orga.tfuncionario (id_funcionario);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_persona foreign key (id_persona) references segu.tpersona (id_persona);
alter table kaf.tmovimiento_af_dep
add constraint fk_tmovimiento_af_dep__id_activo_fijo_valor foreign key (id_activo_fijo_valor) references kaf.tactivo_fijo_valores (id_activo_fijo_valor);
alter table kaf.tmovimiento_tipo
add constraint fk_tmovimiento_tipo__id_cat_movimiento foreign key (id_cat_movimiento) references param.tcatalogo (id_catalogo);
alter table kaf.tactivo_fijo_valores
add constraint fk_tactivo_fijo_valores__id_movimiento_af foreign key (id_movimiento_af) references kaf.tmovimiento_af (id_movimiento_af);


/***********************************F-DEP-RCM-KAF-1-06/05/2016****************************************/


/***********************************I-DEP-RAC-KAF-1-29/03/2017****************************************/
CREATE OR REPLACE VIEW kaf.vminimo_movimiento_af_dep
AS
  SELECT distinct on  (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
         afd.monto_vigente ,
         afd.vida_util ,
         afd.fecha ,
         afd.depreciacion_acum ,
         afd.depreciacion_per ,
         afd.depreciacion_acum_ant 
  FROM kaf.tmovimiento_af_dep afd
  order by afd.id_activo_fijo_valor, fecha desc;
  
CREATE OR REPLACE VIEW kaf.vactivo_fijo_valor
AS
  SELECT afv.id_usuario_reg,
         afv.id_usuario_mod,
         afv.fecha_reg,
         afv.fecha_mod,
         afv.estado_reg,
         afv.id_usuario_ai,
         afv.usuario_ai,
         afv.id_activo_fijo_valor,
         afv.id_activo_fijo,
         afv.monto_vigente_orig,
         afv.vida_util_orig,
         afv.fecha_ini_dep,
         afv.depreciacion_mes,
         afv.depreciacion_per,
         afv.depreciacion_acum,
         afv.monto_vigente,
         afv.vida_util,
         afv.fecha_ult_dep,
         afv.tipo_cambio_ini,
         afv.tipo_cambio_fin,
         afv.tipo,
         afv.estado,
         afv.principal,
         afv.monto_rescate,
         afv.id_movimiento_af,
         afv.codigo,
         COALESCE(min.monto_vigente, afv.monto_vigente_orig) AS
           monto_vigente_real,
         COALESCE(min.vida_util, afv.vida_util_orig) AS vida_util_real,
         COALESCE(min.fecha, afv.fecha_ini_dep) AS fecha_ult_dep_real,
         COALESCE(min.depreciacion_acum,0) as depreciacion_acum_real, 
         COALESCE(min.depreciacion_per,0) as depreciacion_per_real, 
         COALESCE(min.depreciacion_acum_ant,0) as depreciacion_acum_ant_real
  FROM kaf.tactivo_fijo_valores afv
       LEFT JOIN kaf.vminimo_movimiento_af_dep min ON min.id_activo_fijo_valor =
         afv.id_activo_fijo_valor;  


CREATE OR REPLACE VIEW kaf.vactivo_fijo_vigente(
    id_activo_fijo,
    monto_vigente_real_af,
    vida_util_real_af,
    fecha_ult_dep_real_af,
    depreciacion_acum_real_af,
    depreciacion_per_real_af)
AS
  SELECT afd.id_activo_fijo,
         sum(afd.monto_vigente_real) AS monto_vigente_real_af,
         max(afd.vida_util_real) AS vida_util_real_af,
         max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
         sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
         sum(afd.depreciacion_per_real) AS depreciacion_per_real_af
  FROM kaf.vactivo_fijo_valor afd
  GROUP BY afd.id_activo_fijo;

/***********************************F-DEP-RAC-KAF-1-29/03/2017****************************************/












