/***********************************I-DEP-RCM-KAF-1-02/09/2015****************************************/
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_clasificacion_fk foreign key (id_clasificacion_fk) references kaf.tclasificacion (id_clasificacion);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_concepto_ingas foreign key (id_concepto_ingas) references param.tconcepto_ingas (id_concepto_ingas);
alter table kaf.tclasificacion
add constraint fk_tclasificacion__id_cat_metodo_dep foreign key (id_cat_metodo_dep) references param.tcatalogo (id_catalogo);


--chros comenté por que ocurría conflictos a momento de restaurar
--alter table kaf.tmovimiento
--add constraint fk_tmovimiento__id_cat_movimiento foreign key (id_cat_movimiento) references param.tcatalogo (id_catalogo);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_estado_wf foreign key (id_estado_wf) references wf.testado_wf (id_estado_wf);
alter table kaf.tmovimiento
add constraint fk_tmovimiento__id_proceso_wf foreign key (id_proceso_wf) references wf.tproceso_wf (id_proceso_wf);

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
--chros da error por que no existe valor por defecto paa dichas columnas y dispara un error (Key (id_activo_fijo)=(1) is not present in table "tactivo_fijo".)
alter table kaf.tactivo_fijo_caract
add constraint fk_tactivo_fijo_caract__id_activo_fijo foreign key (id_activo_fijo) references kaf.tactivo_fijo (id_activo_fijo);
--alter table kaf.tactivo_fijo_valores
--add constraint fk_tactivo_fijo_valores__id_activo_fijo foreign key (id_activo_fijo) references kaf.tactivo_fijo (id_activo_fijo);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_depto foreign key (id_depto) references param.tdepto (id_depto);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_funcionario foreign key (id_funcionario) references orga.tfuncionario (id_funcionario);
alter table kaf.tdeposito
add constraint fk_tdeposito__id_oficina foreign key (id_oficina) references orga.toficina (id_oficina);
--alter table kaf.tmovimiento
--add constraint fk_tmovimiento__id_depto foreign key (id_depto) references param.tdepto (id_depto);
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






/***********************************I-DEP-RAC-KAF-1-20/04/2017****************************************/

select pxp.f_insert_testructura_gui ('CONFAF', 'KAF');
select pxp.f_insert_testructura_gui ('MONDEP', 'CONFAF');


--------------- SQL ---------------

ALTER TABLE kaf.tactivo_fijo_valores
  ADD CONSTRAINT tactivo_fijo_valores__id_moneda_dep_fk FOREIGN KEY (id_moneda_dep)
    REFERENCES kaf.tmoneda_dep(id_moneda_dep)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

/***********************************F-DEP-RAC-KAF-1-20/04/2017****************************************/




/***********************************I-DEP-RCM-KAF-1-05/06/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT tactivo_fijo_fk FOREIGN KEY (id_clasificacion)
    REFERENCES kaf.tclasificacion(id_clasificacion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.ttipo_bien_cuenta
  ADD CONSTRAINT fk__ttipo_bien_cuenta__id_tipo_bien FOREIGN KEY (id_tipo_bien)
    REFERENCES kaf.ttipo_bien(id_tipo_bien)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.ttipo_bien_cuenta
  ADD CONSTRAINT fk_ttipo_bien_cuenta__id_tipo_cuenta FOREIGN KEY (id_tipo_cuenta)
    REFERENCES kaf.ttipo_cuenta(id_tipo_cuenta)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tmovimiento
  ADD CONSTRAINT fk_tmovimiento__id_periodo_subsitema FOREIGN KEY (id_periodo_subsistema)
    REFERENCES param.tperiodo_subsistema(id_periodo_subsistema)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-05/06/2017****************************************/


/***********************************I-DEP-RCM-KAF-1-19/06/2017****************************************/
ALTER TABLE kaf.tmovimiento_af
  ADD CONSTRAINT fk_tmovimiento_af__id_moneda FOREIGN KEY (id_moneda)
    REFERENCES param.tmoneda(id_moneda)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-19/06/2017****************************************/

/***********************************I-DEP-RCM-KAF-1-23/06/2017****************************************/
ALTER TABLE kaf.tmovimiento_af_especial
  ADD CONSTRAINT fk_tmovimiento_af_especial__id_activo_fijo_valor FOREIGN KEY (id_activo_fijo_valor)
    REFERENCES kaf.tactivo_fijo_valores(id_activo_fijo_valor)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tmovimiento_af_especial
  ADD CONSTRAINT fk_tmovimiento_af_especial__id_activo_fijo FOREIGN KEY (id_activo_fijo)
    REFERENCES kaf.tactivo_fijo(id_activo_fijo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tmovimiento_af_especial
  ADD CONSTRAINT fk_tmovimiento_af_especial__id_movimiento_af FOREIGN KEY (id_movimiento_af)
    REFERENCES kaf.tmovimiento_af(id_movimiento_af)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-23/06/2017****************************************/

/***********************************I-DEP-RCM-KAF-1-27/06/2017****************************************/
ALTER TABLE kaf.tclasificacion_variable
  ADD CONSTRAINT fk_tclasificacion_variable__id_clasificacion FOREIGN KEY (id_clasificacion)
    REFERENCES kaf.tclasificacion(id_clasificacion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-27/06/2017****************************************/



/***********************************I-DEP-RCM-KAF-1-09/08/2017****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_unidad_medida FOREIGN KEY (id_unidad_medida)
    REFERENCES param.tunidad_medida(id_unidad_medida)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_cotizacion_det FOREIGN KEY (id_cotizacion_det)
    REFERENCES adq.tcotizacion_det(id_cotizacion_det)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_preingreso_det FOREIGN KEY (id_preingreso_det)
    REFERENCES alm.tpreingreso_det(id_preingreso_det)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-09/08/2017****************************************/


/***********************************I-DEP-RCM-KAF-1-14/08/2017****************************************/
ALTER TABLE kaf.tmovimiento_af_dep
  ADD CONSTRAINT tmovimiento_af_dep__id_moneda_dep_fk FOREIGN KEY (id_moneda_dep)
    REFERENCES kaf.tmoneda_dep(id_moneda_dep)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-14/08/2017****************************************/



/***********************************I-DEP-RCM-KAF-1-23/08/2017****************************************/
ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD CONSTRAINT fk_tactivo_fijo_modificacion__id_activo_fijo FOREIGN KEY (id_activo_fijo)
    REFERENCES kaf.tactivo_fijo(id_activo_fijo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD CONSTRAINT fk_tactivo_fijo_modificacion__id_oficina FOREIGN KEY (id_oficina)
    REFERENCES orga.toficina(id_oficina)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo_modificacion
  ADD CONSTRAINT fk_tactivo_fijo_modificacion__id_oficina_ant FOREIGN KEY (id_oficina_ant)
    REFERENCES orga.toficina(id_oficina)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-23/08/2017****************************************/






/***********************************I-DEP-RCM-KAF-1-10/07/2018****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_grupo FOREIGN KEY (id_grupo)
    REFERENCES kaf.tgrupo(id_grupo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_ubicacion FOREIGN KEY (id_ubicacion)
    REFERENCES kaf.tubicacion(id_ubicacion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT fk_tactivo_fijo__id_grupo_clasif FOREIGN KEY (id_grupo_clasif)
    REFERENCES kaf.tgrupo(id_grupo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.ttipo_prorrateo
  ADD CONSTRAINT fk_ttipo_prorrateo__id_activo_fijo FOREIGN KEY (id_activo_fijo)
    REFERENCES kaf.tactivo_fijo(id_activo_fijo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-1-10/07/2018****************************************/


/***********************************I-DEP-RAC-KAF-1-10/12/2018****************************************/
CREATE OR REPLACE VIEW kaf.v_cbte_aitb_debe (
    id_fila,
    id_cuenta_act_activo,
    id_partida_act_activo,
    id_auxiliar_act_activo,
    aitb_activo,
    id_movimiento)
AS
 SELECT row_number() OVER () AS id_fila,
    pa.id_cuenta_act_activo,
    pa.id_partida_act_activo,
    pa.id_auxiliar_act_activo,
    sum(pa.aitb_activo) AS aitb_activo,
    maf.id_movimiento
   FROM kaf.tprorrateo_af pa
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pa.id_movimiento_af
  WHERE pa.id_cuenta_act_activo IS NOT NULL
  GROUP BY pa.id_cuenta_act_activo, pa.id_partida_act_activo, pa.id_auxiliar_act_activo, maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.v_cbte_aitb_haber (
    id_fila,
    id_cuenta_act_dep,
    id_partida_act_dep,
    id_auxiliar_act_dep,
    aitb_dep_acum,
    id_movimiento)
AS
 SELECT row_number() OVER () AS id_fila,
    pa.id_cuenta_act_dep,
    pa.id_partida_act_dep,
    pa.id_auxiliar_act_dep,
    sum(pa.aitb_dep_acum) AS aitb_dep_acum,
    maf.id_movimiento
   FROM kaf.tprorrateo_af pa
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pa.id_movimiento_af
  WHERE pa.id_cuenta_act_dep IS NOT NULL
  GROUP BY pa.id_cuenta_act_dep, pa.id_partida_act_dep, pa.id_auxiliar_act_dep, maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.v_cbte_alta (
    id_movimiento_af,
    id_movimiento,
    monto_compra,
    id_clasificacion)
AS
 SELECT maf.id_movimiento_af,
    mov.id_movimiento,
    afij.monto_compra,
    afij.id_clasificacion
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     JOIN kaf.tactivo_fijo afij ON afij.id_activo_fijo = maf.id_activo_fijo;

CREATE OR REPLACE VIEW kaf.v_cbte_baja (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_actualiz,
    depreciacion_acum,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    descripcion,
    id_centro_costo)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'ALTAAF'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(mdep.monto_actualiz) AS monto_actualiz,
    sum(mdep.depreciacion_acum) AS depreciacion_acum,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc,
    (((af.codigo::text || ', '::text) || af.codigo_ant::text) || ', '::text) || af.descripcion::text AS descripcion,
    cc.id_centro_costo
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     JOIN kaf.tactivo_fijo_valores afv ON afv.id_activo_fijo = maf.id_activo_fijo
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor AND date_trunc('month'::text, mdep.fecha::timestamp with time zone) = date_trunc('month'::text, mov.fecha_mov - '1 mon'::interval)
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc, af.codigo, af.codigo_ant, af.denominacion, af.descripcion, cc.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_baja_cab (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catalogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion,
    glosa_cbte)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catalogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion,
    'Comprobante de Baja de Activo(s) Fijo(s) al período de '::text || to_char(mov.fecha_mov::timestamp with time zone, 'mm/YYYY'::text) AS glosa_cbte
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_activo (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'ALTAAF'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.monto_actualiz, 2) - round(mdep.monto_actualiz_ant, 2)) AS monto_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_activo_cab (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catalogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion,
    glosa_cbte)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catalogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion,
    'Comprobante de Actualización de Valores del Activo Fijo correspondiente al período de '::text || to_char(mov.fecha_hasta::timestamp with time zone, 'mm/YYYY'::text) AS glosa_cbte
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_activo_detalle (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    codigo,
    codigo_ant,
    monto_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'ALTAAF'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    af.codigo,
    af.codigo_ant,
    mdep.monto_actualiz - mdep.monto_actualiz_ant AS monto_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base();

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_acum (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_acum_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text
        ), tdep_acum_actualiz_ant AS (
         SELECT maf_1.id_movimiento,
            mdep_1.id_activo_fijo_valor,
            mdepant.depreciacion_acum_actualiz,
            mdepant.depreciacion_acum * mdep_1.factor,
            COALESCE(round(mdepant.depreciacion_acum, 2) * mdep_1.factor - round(mdepant.depreciacion_acum, 2), 0::numeric) AS inc_dep_acum_actualiz_orig,
                CASE mdep_1.meses_acum
                    WHEN 'si'::text THEN mdep_1.tmp_inc_actualiz_dep_acum
                    ELSE
                    CASE
                        WHEN COALESCE(mdepant.depreciacion_acum, 0::numeric) = 0::numeric AND COALESCE(mdepant.id_movimiento_af_dep, 0::bigint) = 0 AND COALESCE(afv.id_activo_fijo_valor_original) <> 0 THEN (( SELECT round(tmovimiento_af_dep.depreciacion_acum, 2) AS round
                           FROM kaf.tmovimiento_af_dep
                          WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                                   FROM kaf.tmovimiento_af_dep m
                                  WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original)))) * mdep_1.factor - (( SELECT round(tmovimiento_af_dep.depreciacion_acum, 2) AS round
                           FROM kaf.tmovimiento_af_dep
                          WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                                   FROM kaf.tmovimiento_af_dep m
                                  WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original))))
                        ELSE COALESCE(round(mdepant.depreciacion_acum, 2) * mdep_1.factor - round(mdepant.depreciacion_acum, 2), 0::numeric)
                    END
                END AS inc_dep_acum_actualiz
           FROM kaf.tmovimiento_af_dep mdep_1
             JOIN kaf.tmovimiento_af maf_1 ON maf_1.id_movimiento_af = mdep_1.id_movimiento_af
             LEFT JOIN kaf.tmovimiento_af_dep mdepant ON mdepant.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor AND date_trunc('month'::text, mdepant.fecha::timestamp with time zone) = COALESCE(mdep_1.fecha_ant::timestamp without time zone, date_trunc('month'::text, mdep_1.fecha - '1 mon'::interval))
             JOIN kaf.tactivo_fijo_valores afv ON afv.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(daa.inc_dep_acum_actualiz, 2)) AS dep_acum_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN tdep_acum_actualiz_ant daa ON daa.id_activo_fijo_valor = mdep.id_activo_fijo_valor AND daa.id_movimiento = maf.id_movimiento
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_acum__cta (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_acum_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_cuenta,
    id_partida)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text
        ), tdep_acum_actualiz_ant AS (
         SELECT maf_1.id_movimiento,
            mdep_1.id_activo_fijo_valor,
            mdepant.depreciacion_acum_actualiz,
            mdepant.depreciacion_acum * mdep_1.factor,
            COALESCE(round(mdepant.depreciacion_acum, 2) * mdep_1.factor - round(mdepant.depreciacion_acum, 2), 0::numeric) AS inc_dep_acum_actualiz_orig,
                CASE mdep_1.meses_acum
                    WHEN 'si'::text THEN mdep_1.tmp_inc_actualiz_dep_acum
                    ELSE
                    CASE
                        WHEN COALESCE(mdepant.depreciacion_acum, 0::numeric) = 0::numeric AND COALESCE(mdepant.id_movimiento_af_dep, 0::bigint) = 0 AND COALESCE(afv.id_activo_fijo_valor_original) <> 0 THEN (( SELECT round(tmovimiento_af_dep.depreciacion_acum, 2) AS round
                           FROM kaf.tmovimiento_af_dep
                          WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                                   FROM kaf.tmovimiento_af_dep m
                                  WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original)))) * mdep_1.factor - (( SELECT round(tmovimiento_af_dep.depreciacion_acum, 2) AS round
                           FROM kaf.tmovimiento_af_dep
                          WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                                   FROM kaf.tmovimiento_af_dep m
                                  WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original))))
                        ELSE COALESCE(round(mdepant.depreciacion_acum, 2) * mdep_1.factor - round(mdepant.depreciacion_acum, 2), 0::numeric)
                    END
                END AS inc_dep_acum_actualiz
           FROM kaf.tmovimiento_af_dep mdep_1
             JOIN kaf.tmovimiento_af maf_1 ON maf_1.id_movimiento_af = mdep_1.id_movimiento_af
             LEFT JOIN kaf.tmovimiento_af_dep mdepant ON mdepant.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor AND date_trunc('month'::text, mdepant.fecha::timestamp with time zone) = COALESCE(mdep_1.fecha_ant::timestamp without time zone, date_trunc('month'::text, mdep_1.fecha - '1 mon'::interval))
             JOIN kaf.tactivo_fijo_valores afv ON afv.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(daa.inc_dep_acum_actualiz, 2)) AS dep_acum_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc,
        CASE COALESCE(act.nro_cuenta, ''::character varying)
            WHEN ''::text THEN ( SELECT rc1.id_cuenta
               FROM conta.trelacion_contable rc1
                 JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
              WHERE trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                       FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion)
            ELSE cta.id_cuenta
        END AS id_cuenta,
    ( SELECT rc1.id_partida
           FROM conta.trelacion_contable rc1
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
          WHERE trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                   FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion) AS id_partida
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN tdep_acum_actualiz_ant daa ON daa.id_activo_fijo_valor = mdep.id_activo_fijo_valor AND daa.id_movimiento = maf.id_movimiento
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo = af.id_activo_fijo
     LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::text AND (cta.id_gestion IN ( SELECT tgestion.id_gestion
           FROM param.tgestion
          WHERE date_trunc('year'::text, tgestion.fecha_ini::timestamp with time zone) = date_trunc('year'::text, mov.fecha_hasta::timestamp with time zone)))
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc, mov.fecha_hasta, act.nro_cuenta, cta.id_cuenta;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_acum_cab (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catalogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion,
    glosa_cbte)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catalogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion,
    'Comprobante de Actualización de Depreciación Acumulada correspondiente al período de '::text || to_char(mov.fecha_hasta::timestamp with time zone, 'mm/YYYY'::text) AS glosa_cbte
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_acum_detalle (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    codigo,
    codigo_ant,
    dep_acum_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text
        ), tdep_acum_actualiz_ant AS (
         SELECT maf_1.id_movimiento,
            mdep_1.id_activo_fijo_valor,
            mdepant.depreciacion_acum_actualiz,
            mdepant.depreciacion_acum_actualiz * mdep_1.factor,
            COALESCE(mdepant.depreciacion_acum_actualiz * mdep_1.factor - mdepant.depreciacion_acum_actualiz, 0::numeric) AS inc_dep_acum_actualiz_orig,
                CASE
                    WHEN COALESCE(mdepant.depreciacion_acum_actualiz, 0::numeric) = 0::numeric AND COALESCE(mdepant.id_movimiento_af_dep, 0::bigint) = 0 AND COALESCE(afv.id_activo_fijo_valor_original) <> 0 THEN (( SELECT tmovimiento_af_dep.depreciacion_acum_actualiz
                       FROM kaf.tmovimiento_af_dep
                      WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                               FROM kaf.tmovimiento_af_dep m
                              WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original)))) * mdep_1.factor - (( SELECT tmovimiento_af_dep.depreciacion_acum_actualiz
                       FROM kaf.tmovimiento_af_dep
                      WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                               FROM kaf.tmovimiento_af_dep m
                              WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original))))
                    ELSE COALESCE(mdepant.depreciacion_acum_actualiz * mdep_1.factor - mdepant.depreciacion_acum_actualiz, 0::numeric)
                END AS inc_dep_acum_actualiz
           FROM kaf.tmovimiento_af_dep mdep_1
             JOIN kaf.tmovimiento_af maf_1 ON maf_1.id_movimiento_af = mdep_1.id_movimiento_af
             LEFT JOIN kaf.tmovimiento_af_dep mdepant ON mdepant.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor AND date_trunc('month'::text, mdepant.fecha::timestamp with time zone) = COALESCE(mdep_1.fecha_ant::timestamp without time zone, date_trunc('month'::text, mdep_1.fecha - '1 mon'::interval))
             JOIN kaf.tactivo_fijo_valores afv ON afv.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    af.codigo,
    af.codigo_ant,
    daa.inc_dep_acum_actualiz AS dep_acum_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN tdep_acum_actualiz_ant daa ON daa.id_activo_fijo_valor = mdep.id_activo_fijo_valor AND daa.id_movimiento = maf.id_movimiento
  WHERE mdep.id_moneda = param.f_get_moneda_base();

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_centro_costo)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.depreciacion_per, 2) - round(mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2)) AS dep_per_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc,
    af.id_centro_costo
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc, af.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per__cta (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.depreciacion_per, 2) - round(mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2)) AS dep_per_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc,
    af.id_centro_costo,
        CASE COALESCE(act.nro_cuenta, ''::character varying)
            WHEN ''::text THEN ( SELECT rc1.id_cuenta
               FROM conta.trelacion_contable rc1
                 JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
              WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                       FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion)
            ELSE cta.id_cuenta
        END AS id_cuenta,
    ( SELECT rc1.id_partida
           FROM conta.trelacion_contable rc1
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
          WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                   FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion) AS id_partida
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo = af.id_activo_fijo
     LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::text AND (cta.id_gestion IN ( SELECT tgestion.id_gestion
           FROM param.tgestion
          WHERE date_trunc('year'::text, tgestion.fecha_ini::timestamp with time zone) = date_trunc('year'::text, mov.fecha_hasta::timestamp with time zone)))
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc, af.id_centro_costo, mov.fecha_hasta, act.nro_cuenta, cta.id_cuenta;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per__cta_detalle (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_centro_costo,
    id_cuenta,
    id_partida,
    denominacion,
    codigo,
    codigo_ant)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.depreciacion_per, 2) - round(mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2)) AS dep_per_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc,
    af.id_centro_costo,
        CASE COALESCE(act.nro_cuenta, ''::character varying)
            WHEN ''::text THEN ( SELECT rc1.id_cuenta
               FROM conta.trelacion_contable rc1
                 JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
              WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                       FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion)
            ELSE cta.id_cuenta
        END AS id_cuenta,
    ( SELECT rc1.id_partida
           FROM conta.trelacion_contable rc1
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
          WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                   FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion) AS id_partida,
    af.denominacion,
    af.codigo,
    af.codigo_ant
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo = af.id_activo_fijo
     LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::text AND (cta.id_gestion IN ( SELECT tgestion.id_gestion
           FROM param.tgestion
          WHERE date_trunc('year'::text, tgestion.fecha_ini::timestamp with time zone) = date_trunc('year'::text, mov.fecha_hasta::timestamp with time zone)))
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.codigo_tcc, af.id_centro_costo, mov.fecha_hasta, act.nro_cuenta, cta.id_cuenta, af.denominacion, af.codigo, af.codigo_ant;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per_cab (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catalogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion,
    glosa_cbte)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catalogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion,
    'Comprobante de Actualización de Depreciación Período correspondiente al período de '::text || to_char(mov.fecha_hasta::timestamp with time zone, 'mm/YYYY'::text) AS glosa_cbte
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per_detalle (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    codigo,
    codigo_ant,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    af.codigo,
    af.codigo_ant,
    round(mdep.depreciacion_per, 2) - round(mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2) AS dep_per_actualiz,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.codigo_tcc
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base();

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.depreciacion, 2)) AS monto_depreciacion,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.id_centro_costo
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion__cta (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    sum(round(mdep.depreciacion, 2)) AS monto_depreciacion,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.id_centro_costo,
        CASE COALESCE(act.nro_cuenta, ''::character varying)
            WHEN ''::text THEN ( SELECT rc1.id_cuenta
               FROM conta.trelacion_contable rc1
                 JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
              WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                       FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion)
            ELSE cta.id_cuenta
        END AS id_cuenta,
    ( SELECT rc1.id_partida
           FROM conta.trelacion_contable rc1
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tipo_relacion_contable = rc1.id_tipo_relacion_contable
          WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND rc1.id_gestion = (( SELECT f_get_periodo_gestion.po_id_gestion
                   FROM param.f_get_periodo_gestion(mov.fecha_hasta) f_get_periodo_gestion(po_id_periodo, po_id_gestion, po_id_periodo_subsistema))) AND rc1.estado_reg::text = 'activo'::text AND rc1.id_tabla = rc.id_clasificacion) AS id_partida
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo = af.id_activo_fijo
     LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::text AND (cta.id_gestion IN ( SELECT tgestion.id_gestion
           FROM param.tgestion
          WHERE date_trunc('year'::text, tgestion.fecha_ini::timestamp with time zone) = date_trunc('year'::text, mov.fecha_hasta::timestamp with time zone)))
  WHERE mdep.id_moneda = param.f_get_moneda_base()
  GROUP BY rc.id_clasificacion, cla.codigo_completo_tmp, cla.nombre, maf.id_movimiento, mdep.id_moneda, cc.id_centro_costo, mov.fecha_hasta, act.nro_cuenta, cta.id_cuenta;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion_cab (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catalogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion,
    glosa_cbte)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catalogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion,
    'Comprobante de Depreciación del Activo Fijo correspondiente al período de '::text || to_char(mov.fecha_hasta::timestamp with time zone, 'mm/YYYY'::text) AS glosa_cbte
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion_detalle (
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    codigo,
    codigo_ant,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo)
AS
 WITH trel_contable AS (
         SELECT rc_1.id_tabla AS id_clasificacion,
            (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::character varying)::text) || '}'::text)::integer[] AS nodos
           FROM conta.ttabla_relacion_contable tb
             JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable = tb.id_tabla_relacion_contable
             JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable = trc.id_tipo_relacion_contable
          WHERE tb.esquema::text = 'KAF'::text AND tb.tabla::text = 'tclasificacion'::text AND trc.codigo_tipo_relacion::text = 'DEPACCLAS'::text
        )
 SELECT rc.id_clasificacion,
    cla.codigo_completo_tmp,
    cla.nombre,
    af.codigo,
    af.codigo_ant,
    mdep.depreciacion AS monto_depreciacion,
    maf.id_movimiento,
    mdep.id_moneda,
    cc.id_centro_costo
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af = maf.id_movimiento_af
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
     JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
     JOIN kaf.tclasificacion cla ON cla.id_clasificacion = rc.id_clasificacion
     LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo = af.id_centro_costo
  WHERE mdep.id_moneda = param.f_get_moneda_base();

CREATE OR REPLACE VIEW kaf.v_cbte_depreciacion_debe (
    id_fila,
    id_centro_costo,
    id_ot,
    id_cuenta_dep,
    id_partida_dep,
    id_auxiliar_dep,
    depreciacion,
    id_movimiento)
AS
 SELECT row_number() OVER () AS id_fila,
    pa.id_centro_costo,
    pa.id_ot,
    pa.id_cuenta_dep,
    pa.id_partida_dep,
    pa.id_auxiliar_dep,
    sum(pa.depreciacion) AS depreciacion,
    maf.id_movimiento
   FROM kaf.tprorrateo_af pa
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pa.id_movimiento_af
  GROUP BY pa.id_centro_costo, pa.id_ot, pa.id_cuenta_dep, pa.id_partida_dep, pa.id_auxiliar_dep, maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.v_cbte_depreciacion_haber (
    id_fila,
    id_cuenta_dep_acum,
    id_partida_dep_acum,
    id_auxiliar_dep_aucm,
    depreciacion_acum,
    id_movimiento)
AS
 SELECT row_number() OVER () AS id_fila,
    pa.id_cuenta_dep_acum,
    pa.id_partida_dep_acum,
    pa.id_auxiliar_dep_aucm,
    sum(pa.depreciacion_acum) AS depreciacion_acum,
    maf.id_movimiento
   FROM kaf.tprorrateo_af pa
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pa.id_movimiento_af
  WHERE pa.id_cuenta_dep_acum IS NOT NULL
  GROUP BY pa.id_cuenta_dep_acum, pa.id_partida_dep_acum, pa.id_auxiliar_dep_aucm, maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.v_cbte_det_base (
    id_movimiento_af,
    id_movimiento,
    id_moneda,
    id_activo_fijo,
    fecha_mov,
    id_clasificacion,
    importe_mov,
    id_centro_costo,
    prorrateo,
    monto_vigente,
    vida_util_real,
    depreciacion_acum,
    depreciacion_per)
AS
 SELECT maf.id_movimiento_af,
    maf.id_movimiento,
    maf.id_moneda,
    afij.id_activo_fijo,
    mov.fecha_mov,
    afij.id_clasificacion,
    COALESCE(maf.importe * COALESCE(tpro.factor, 1::numeric), afij.monto_compra * COALESCE(tpro.factor, 1::numeric)) AS importe_mov,
    COALESCE(cc.id_centro_costo, carcc.id_centro_costo) AS id_centro_costo,
    COALESCE(tpro.factor, 1::numeric) AS prorrateo,
    COALESCE(round(afvi.monto_vigente * COALESCE(tpro.factor, 1::numeric), 2), afij.monto_compra) AS monto_vigente,
    COALESCE(afvi.vida_util, afij.vida_util_original) AS vida_util_real,
    COALESCE(round(afvi.depreciacion_acum * COALESCE(tpro.factor, 1::numeric), 2), 0::numeric) AS depreciacion_acum,
    COALESCE(round(afvi.depreciacion_per * COALESCE(tpro.factor, 1::numeric), 2), 0::numeric) AS depreciacion_per
   FROM kaf.tmovimiento_af maf
     JOIN kaf.tactivo_fijo afij ON afij.id_activo_fijo = maf.id_activo_fijo
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
     LEFT JOIN kaf.ttipo_prorrateo tpro ON tpro.id_activo_fijo = afij.id_activo_fijo
     LEFT JOIN param.tcentro_costo cc ON cc.id_tipo_cc = tpro.id_tipo_cc AND cc.id_gestion = (( SELECT f_get_limites_gestion.po_id_gestion
           FROM param.f_get_limites_gestion(mov.fecha_mov) f_get_limites_gestion(po_fecha_ini, po_fecha_fin, po_id_gestion)))
     LEFT JOIN orga.tuo_funcionario uofun ON uofun.id_funcionario = afij.id_funcionario
     LEFT JOIN orga.tcargo_centro_costo carcc ON carcc.id_cargo = uofun.id_cargo
     LEFT JOIN LATERAL kaf.f_activo_fijo_dep_x_fecha_afv(mov.fecha_mov, 'si'::character varying) afvi(id_activo_fijo_valor, id_activo_fijo, id_movimiento_af, id_moneda_dep, id_moneda, codigo, tipo, deducible, fecha_ini_dep, fecha_inicio, fecha_fin, fecha_ult_dep, monto_rescate, monto_vigente_orig, vida_util_orig, depreciacion_acum_ant, depreciacion_per_ant, monto_vigente_ant, vida_util_ant, depreciacion_acum_actualiz, depreciacion_per_actualiz, monto_actualiz, depreciacion, depreciacion_acum, depreciacion_per, monto_vigente, vida_util, monto_vigente_orig_100) ON afvi.id_activo_fijo = afij.id_activo_fijo AND afvi.id_moneda = maf.id_moneda;

CREATE OR REPLACE VIEW kaf.v_cbte_det_importe (
    id_movimiento,
    id_moneda,
    id_clasificacion,
    id_centro_costo,
    importe)
AS
 SELECT det.id_movimiento,
    det.id_moneda,
    det.id_clasificacion,
    det.id_centro_costo,
    sum(det.importe) AS importe
   FROM ( SELECT maf.id_movimiento_af,
            maf.id_movimiento,
            maf.id_moneda,
            afij.id_activo_fijo,
            mov.fecha_mov,
            afij.id_clasificacion,
            COALESCE(maf.importe * COALESCE(tpro.factor, 1::numeric), afij.monto_compra * COALESCE(tpro.factor, 1::numeric)) AS importe,
            COALESCE(cc.id_centro_costo, carcc.id_centro_costo) AS id_centro_costo,
            COALESCE(tpro.factor, 1::numeric) AS prorrateo
           FROM kaf.tmovimiento_af maf
             JOIN kaf.tactivo_fijo afij ON afij.id_activo_fijo = maf.id_activo_fijo
             JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
             LEFT JOIN kaf.ttipo_prorrateo tpro ON tpro.id_activo_fijo = afij.id_activo_fijo
             LEFT JOIN param.tcentro_costo cc ON cc.id_tipo_cc = tpro.id_tipo_cc AND cc.id_gestion = (( SELECT f_get_limites_gestion.po_id_gestion
                   FROM param.f_get_limites_gestion(mov.fecha_mov) f_get_limites_gestion(po_fecha_ini, po_fecha_fin, po_id_gestion)))
             LEFT JOIN orga.tuo_funcionario uofun ON uofun.id_funcionario = afij.id_funcionario
             LEFT JOIN orga.tcargo_centro_costo carcc ON carcc.id_cargo = uofun.id_cargo) det
  GROUP BY det.id_movimiento, det.id_moneda, det.id_clasificacion, det.id_centro_costo;

CREATE OR REPLACE VIEW kaf.vclaificacion_raiz (
    codigo_raiz,
    nombre_raiz,
    descripcion_raiz,
    id_claificacion_raiz,
    ids,
    id_clasificacion,
    id_clasificacion_fk,
    nombre,
    codigo,
    descripcion)
AS
 WITH RECURSIVE clasificacion(ids, id_clasificacion, id_clasificacion_fk, nombre, codigo, descripcion) AS (
         SELECT ARRAY[c_1.id_clasificacion] AS "array",
            c_1.id_clasificacion,
            c_1.id_clasificacion_fk,
            c_1.nombre,
            c_1.codigo,
            c_1.descripcion
           FROM kaf.tclasificacion c_1
          WHERE c_1.contabilizar::text = 'si'::text AND c_1.estado_reg::text = 'activo'::text
        UNION
         SELECT pc.ids || c2.id_clasificacion,
            c2.id_clasificacion,
            c2.id_clasificacion_fk,
            c2.nombre,
            c2.codigo,
            c2.descripcion
           FROM kaf.tclasificacion c2,
            clasificacion pc
          WHERE c2.id_clasificacion_fk = pc.id_clasificacion AND c2.estado_reg::text = 'activo'::text
        )
 SELECT cl.codigo AS codigo_raiz,
    cl.nombre AS nombre_raiz,
    cl.descripcion AS descripcion_raiz,
    cl.id_clasificacion AS id_claificacion_raiz,
    c.ids,
    c.id_clasificacion,
    c.id_clasificacion_fk,
    c.nombre,
    c.codigo,
    c.descripcion
   FROM clasificacion c
     JOIN kaf.tclasificacion cl ON cl.id_clasificacion = c.ids[1];

CREATE OR REPLACE VIEW kaf.vclasificacion_arbol (
    clasificacion,
    nivel,
    id_clasificacion,
    id_clasificacion_fk,
    n,
    orden,
    codigo)
AS
 WITH RECURSIVE t(id, id_fk, nombre, codigo1, n, orden) AS (
         SELECT l.id_clasificacion,
            l.id_clasificacion_fk,
            l.nombre,
            l.codigo_completo_tmp,
            1,
            replace(l.codigo_completo_tmp::text, '.'::text, ''::text)::bigint * 10000000 AS int8
           FROM kaf.tclasificacion l
          WHERE l.id_clasificacion_fk IS NULL
        UNION ALL
         SELECT l.id_clasificacion,
            l.id_clasificacion_fk,
            l.nombre,
            l.codigo_completo_tmp,
            t_1.n + 1,
            pxp.f_llenar_ceros_derecha(replace(l.codigo_completo_tmp::text, '.'::text, ''::text)::character varying, 10)::bigint AS f_llenar_ceros_derecha
           FROM kaf.tclasificacion l,
            t t_1
          WHERE l.id_clasificacion_fk = t_1.id
        )
 SELECT ((((repeat('---'::text, t.n - 1) || '-> '::text) || t.codigo1::text) || ' - '::text) || t.nombre::text)::character varying AS clasificacion,
    t.n AS nivel,
    t.id AS id_clasificacion,
    t.id_fk AS id_clasificacion_fk,
    t.n,
    t.orden,
    t.codigo1 AS codigo
   FROM t
  ORDER BY t.orden;

CREATE OR REPLACE VIEW kaf.vdep_acum_actualiz_ant (
    id_movimiento,
    id_activo_fijo_valor,
    depreciacion_acum_actualiz_orig,
    depreciacion_acum_actualiz,
    inc_dep_acum_actualiz_orig,
    inc_dep_acum_actualiz)
AS
 SELECT maf_1.id_movimiento,
    mdep_1.id_activo_fijo_valor,
    COALESCE(mdepant.depreciacion_acum_actualiz, 0::numeric) AS depreciacion_acum_actualiz_orig,
    COALESCE(mdepant.depreciacion_acum_actualiz * mdep_1.factor) AS depreciacion_acum_actualiz,
    COALESCE(mdepant.depreciacion_acum_actualiz * mdep_1.factor - mdepant.depreciacion_acum_actualiz, 0::numeric) AS inc_dep_acum_actualiz_orig,
        CASE
            WHEN COALESCE(mdepant.depreciacion_acum_actualiz, 0::numeric) = 0::numeric AND COALESCE(mdepant.id_movimiento_af_dep, 0::bigint) = 0 AND COALESCE(afv.id_activo_fijo_valor_original) <> 0 THEN (( SELECT tmovimiento_af_dep.depreciacion_acum_actualiz
               FROM kaf.tmovimiento_af_dep
              WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                       FROM kaf.tmovimiento_af_dep m
                      WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original)))) * mdep_1.factor - (( SELECT tmovimiento_af_dep.depreciacion_acum_actualiz
               FROM kaf.tmovimiento_af_dep
              WHERE (tmovimiento_af_dep.id_movimiento_af_dep IN ( SELECT max(m.id_movimiento_af_dep) AS max
                       FROM kaf.tmovimiento_af_dep m
                      WHERE m.id_activo_fijo_valor = afv.id_activo_fijo_valor_original))))
            ELSE COALESCE(mdepant.depreciacion_acum_actualiz * mdep_1.factor - mdepant.depreciacion_acum_actualiz, 0::numeric)
        END AS inc_dep_acum_actualiz
   FROM kaf.tmovimiento_af_dep mdep_1
     JOIN kaf.tmovimiento_af maf_1 ON maf_1.id_movimiento_af = mdep_1.id_movimiento_af
     LEFT JOIN kaf.tmovimiento_af_dep mdepant ON mdepant.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor AND date_trunc('month'::text, mdepant.fecha::timestamp with time zone) = date_trunc('month'::text, mdep_1.fecha - '1 mon'::interval)
     JOIN kaf.tactivo_fijo_valores afv ON afv.id_activo_fijo_valor = mdep_1.id_activo_fijo_valor;

CREATE OR REPLACE VIEW kaf.vminimo_movimiento_af_dep (
    id_activo_fijo_valor,
    monto_vigente,
    vida_util,
    fecha,
    depreciacion_acum,
    depreciacion_per,
    depreciacion_acum_ant,
    monto_actualiz,
    depreciacion_acum_actualiz,
    depreciacion_per_actualiz,
    id_moneda,
    id_moneda_dep,
    tipo_cambio_fin,
    tipo_cambio_ini)
AS
 WITH maximo AS (
         SELECT z.id_activo_fijo_valor,
            max(z.id_movimiento_af_dep) AS id_movimiento_af_dep
           FROM kaf.tmovimiento_af_dep z
          GROUP BY z.id_activo_fijo_valor
        )
 SELECT afd.id_activo_fijo_valor,
    afd.monto_vigente,
    afd.vida_util,
    afd.fecha,
    afd.depreciacion_acum,
    afd.depreciacion_per,
    afd.depreciacion_acum_ant,
    afd.monto_actualiz,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per_actualiz,
    afd.id_moneda,
    afd.id_moneda_dep,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini
   FROM kaf.tmovimiento_af_dep afd
     JOIN maximo m ON afd.id_movimiento_af_dep = m.id_movimiento_af_dep;

CREATE OR REPLACE VIEW kaf.vminimo_movimiento_af_dep_estado (
    id_activo_fijo_valor,
    monto_vigente,
    vida_util,
    fecha,
    depreciacion_acum,
    depreciacion_per,
    depreciacion_acum_ant,
    monto_actualiz,
    depreciacion_acum_actualiz,
    depreciacion_per_actualiz,
    id_moneda,
    id_moneda_dep,
    tipo_cambio_fin,
    tipo_cambio_ini,
    estado)
AS
 WITH maximo AS (
         SELECT z.id_activo_fijo_valor,
            max(z.id_movimiento_af_dep) AS id_movimiento_af_dep
           FROM kaf.tmovimiento_af_dep z
          GROUP BY z.id_activo_fijo_valor
        )
 SELECT afd.id_activo_fijo_valor,
    afd.monto_vigente,
    afd.vida_util,
    afd.fecha,
    afd.depreciacion_acum,
    afd.depreciacion_per,
    afd.depreciacion_acum_ant,
    afd.monto_actualiz,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per_actualiz,
    afd.id_moneda,
    afd.id_moneda_dep,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini,
    mov.estado
   FROM kaf.tmovimiento_af_dep afd
     JOIN maximo m ON afd.id_movimiento_af_dep = m.id_movimiento_af_dep
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afd.id_movimiento_af
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.vmovimiento_cbte (
    id_movimiento,
    id_depto_af,
    fecha_mov,
    id_cat_movimiento,
    codigo_catelogo,
    desc_catalogo,
    num_tramite,
    fecha_hasta,
    glosa,
    id_depto_conta,
    codigo_depto_conta,
    id_gestion,
    gestion,
    id_moneda,
    descripcion)
AS
 SELECT mov.id_movimiento,
    mov.id_depto AS id_depto_af,
    mov.fecha_mov,
    mov.id_cat_movimiento,
    cat.codigo AS codigo_catelogo,
    cat.descripcion AS desc_catalogo,
    mov.num_tramite,
    mov.fecha_hasta,
    mov.glosa,
    depc.id_depto AS id_depto_conta,
    depc.codigo AS codigo_depto_conta,
    per.id_gestion,
    ges.gestion,
    md.id_moneda,
    md.descripcion
   FROM kaf.tmovimiento mov
     JOIN param.tcatalogo cat ON cat.id_catalogo = mov.id_cat_movimiento
     JOIN param.tdepto_depto dd ON dd.id_depto_origen = mov.id_depto
     JOIN param.tdepto depc ON depc.id_depto = dd.id_depto_destino
     JOIN segu.tsubsistema sis ON sis.id_subsistema = depc.id_subsistema AND sis.codigo::text = 'CONTA'::text
     JOIN param.tperiodo per ON mov.fecha_mov >= per.fecha_ini AND mov.fecha_mov <= per.fecha_fin
     JOIN param.tgestion ges ON ges.id_gestion = per.id_gestion
     JOIN kaf.tmoneda_dep md ON md.contabilizar::text = 'si'::text;

CREATE OR REPLACE VIEW kaf.vprimero_movimiento_af_dep_gestion (
    gestion,
    id_activo_fijo_valor,
    id_movimiento_af,
    vida_util_ant,
    vida_util,
    fecha,
    monto_vigente,
    monto_vigente_ant,
    monto_actualiz,
    monto_actualiz_ant,
    depreciacion_acum,
    depreciacion_acum_ant,
    depreciacion_acum_actualiz,
    depreciacion_per,
    depreciacion_per_ant,
    depreciacion_per_actualiz,
    tipo_cambio_fin,
    tipo_cambio_ini,
    id_movimiento,
    id_moneda_dep)
AS
 SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part('year'::text, afd.fecha)), afd.id_moneda_dep) date_part('year'::text, afd.fecha) AS gestion,
    afd.id_activo_fijo_valor,
    afd.id_movimiento_af,
    afd.vida_util_ant,
    afd.vida_util,
    afd.fecha,
    afd.monto_vigente,
    afd.monto_vigente_ant,
    afd.monto_actualiz,
    afd.monto_actualiz_ant,
    afd.depreciacion_acum,
    afd.depreciacion_acum_ant,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per,
    afd.depreciacion_per_ant,
    afd.depreciacion_per_actualiz,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini,
    maf.id_movimiento,
    afd.id_moneda_dep
   FROM kaf.tmovimiento_af_dep afd
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afd.id_movimiento_af
  ORDER BY afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part('year'::text, afd.fecha)), afd.id_moneda_dep, afd.fecha;

CREATE OR REPLACE VIEW kaf.vprimero_movimiento_af_dep_movimiento (
    gestion,
    id_activo_fijo_valor,
    id_movimiento_af,
    vida_util_ant,
    vida_util,
    fecha,
    monto_vigente,
    monto_vigente_ant,
    monto_actualiz,
    monto_actualiz_ant,
    depreciacion_acum,
    depreciacion_acum_ant,
    depreciacion_acum_actualiz,
    depreciacion_per,
    depreciacion_per_ant,
    depreciacion_per_actualiz,
    tipo_cambio_fin,
    tipo_cambio_ini,
    id_movimiento,
    id_moneda_dep)
AS
 SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, afd.id_moneda_dep) date_part('year'::text, afd.fecha) AS gestion,
    afd.id_activo_fijo_valor,
    afd.id_movimiento_af,
    afd.vida_util_ant,
    afd.vida_util,
    afd.fecha,
    afd.monto_vigente,
    afd.monto_vigente_ant,
    afd.monto_actualiz,
    afd.monto_actualiz_ant,
    afd.depreciacion_acum,
    afd.depreciacion_acum_ant,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per,
    afd.depreciacion_per_ant,
    afd.depreciacion_per_actualiz,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini,
    maf.id_movimiento,
    afd.id_moneda_dep
   FROM kaf.tmovimiento_af_dep afd
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afd.id_movimiento_af
  ORDER BY afd.id_activo_fijo_valor, afd.id_movimiento_af, afd.id_moneda_dep, afd.fecha;

CREATE OR REPLACE VIEW kaf.vultimo_movimiento_af_dep_gestion (
    gestion,
    id_activo_fijo_valor,
    id_movimiento_af,
    vida_util_ant,
    vida_util,
    fecha,
    monto_vigente,
    monto_vigente_ant,
    monto_actualiz,
    monto_actualiz_ant,
    depreciacion_acum,
    depreciacion_acum_ant,
    depreciacion_acum_actualiz,
    depreciacion_per,
    depreciacion_per_ant,
    depreciacion_per_actualiz,
    tipo_cambio_fin,
    tipo_cambio_ini,
    id_movimiento,
    id_moneda_dep)
AS
 SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part('year'::text, afd.fecha)), afd.id_moneda_dep) date_part('year'::text, afd.fecha) AS gestion,
    afd.id_activo_fijo_valor,
    afd.id_movimiento_af,
    afd.vida_util_ant,
    afd.vida_util,
    afd.fecha,
    afd.monto_vigente,
    afd.monto_vigente_ant,
    afd.monto_actualiz,
    afd.monto_actualiz_ant,
    afd.depreciacion_acum,
    afd.depreciacion_acum_ant,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per,
    afd.depreciacion_per_ant,
    afd.depreciacion_per_actualiz,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini,
    maf.id_movimiento,
    afd.id_moneda_dep
   FROM kaf.tmovimiento_af_dep afd
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afd.id_movimiento_af
  ORDER BY afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part('year'::text, afd.fecha)), afd.id_moneda_dep, afd.fecha DESC;

CREATE OR REPLACE VIEW kaf.vultimo_movimiento_af_dep_movimiento (
    gestion,
    id_activo_fijo_valor,
    id_movimiento_af,
    vida_util_ant,
    vida_util,
    fecha,
    monto_vigente,
    monto_vigente_ant,
    monto_actualiz,
    monto_actualiz_ant,
    depreciacion_acum,
    depreciacion_acum_ant,
    depreciacion_acum_actualiz,
    depreciacion_per,
    depreciacion_per_ant,
    depreciacion_per_actualiz,
    tipo_cambio_fin,
    tipo_cambio_ini,
    id_movimiento,
    id_moneda_dep)
AS
 SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, afd.id_moneda_dep) date_part('year'::text, afd.fecha) AS gestion,
    afd.id_activo_fijo_valor,
    afd.id_movimiento_af,
    afd.vida_util_ant,
    afd.vida_util,
    afd.fecha,
    afd.monto_vigente,
    afd.monto_vigente_ant,
    afd.monto_actualiz,
    afd.monto_actualiz_ant,
    afd.depreciacion_acum,
    afd.depreciacion_acum_ant,
    afd.depreciacion_acum_actualiz,
    afd.depreciacion_per,
    afd.depreciacion_per_ant,
    afd.depreciacion_per_actualiz,
    afd.tipo_cambio_fin,
    afd.tipo_cambio_ini,
    maf.id_movimiento,
    afd.id_moneda_dep
   FROM kaf.tmovimiento_af_dep afd
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afd.id_movimiento_af
  ORDER BY afd.id_activo_fijo_valor, afd.id_movimiento_af, afd.id_moneda_dep, afd.fecha DESC;

CREATE OR REPLACE VIEW kaf.v_cbte_baja_valor_neto (
    id_movimiento,
    id_centro_costo,
    id_clasificacion,
    valor_neto)
AS
 SELECT v_cbte_baja.id_movimiento,
    v_cbte_baja.id_centro_costo,
    v_cbte_baja.id_clasificacion,
    sum(v_cbte_baja.monto_actualiz - v_cbte_baja.depreciacion_acum) AS valor_neto
   FROM kaf.v_cbte_baja
  GROUP BY v_cbte_baja.id_movimiento, v_cbte_baja.id_centro_costo, v_cbte_baja.id_clasificacion;

CREATE OR REPLACE VIEW kaf.v_cbte_det_baja (
    id_movimiento,
    id_moneda,
    id_clasificacion,
    id_centro_costo,
    dep_acumulada,
    monto_vigente,
    importe_haber)
AS
 SELECT ba.id_movimiento,
    ba.id_moneda,
    ba.id_clasificacion,
    ba.id_centro_costo,
    sum(ba.depreciacion_acum) AS dep_acumulada,
    sum(ba.monto_vigente) AS monto_vigente,
    sum(ba.depreciacion_acum) + sum(ba.monto_vigente) AS importe_haber
   FROM kaf.v_cbte_det_base ba
  GROUP BY ba.id_movimiento, ba.id_moneda, ba.id_clasificacion, ba.id_centro_costo;

CREATE OR REPLACE VIEW kaf.vactivo_fijo_valor (
    id_usuario_reg,
    id_usuario_mod,
    fecha_reg,
    fecha_mod,
    estado_reg,
    id_usuario_ai,
    usuario_ai,
    id_activo_fijo_valor,
    id_activo_fijo,
    monto_vigente_orig,
    vida_util_orig,
    fecha_ini_dep,
    depreciacion_mes,
    depreciacion_per,
    depreciacion_acum,
    monto_vigente,
    vida_util,
    fecha_ult_dep,
    tipo_cambio_ini,
    tipo_cambio_fin,
    tipo,
    estado,
    principal,
    monto_rescate,
    id_movimiento_af,
    codigo,
    monto_vigente_real,
    vida_util_real,
    fecha_ult_dep_real,
    depreciacion_acum_real,
    depreciacion_per_real,
    depreciacion_acum_ant_real,
    monto_actualiz_real,
    id_moneda,
    id_moneda_dep,
    tipo_cambio_anterior)
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
    COALESCE(min.monto_vigente, afv.monto_vigente_orig) AS monto_vigente_real,
    COALESCE(min.vida_util, afv.vida_util_orig) AS vida_util_real,
    COALESCE(min.fecha, afv.fecha_ini_dep) AS fecha_ult_dep_real,
    COALESCE(min.depreciacion_acum, 0::numeric) AS depreciacion_acum_real,
    COALESCE(min.depreciacion_per, 0::numeric) AS depreciacion_per_real,
    COALESCE(min.depreciacion_acum_ant, 0::numeric) AS depreciacion_acum_ant_real,
    COALESCE(min.monto_actualiz, afv.monto_vigente_orig) AS monto_actualiz_real,
    afv.id_moneda,
    afv.id_moneda_dep,
    COALESCE(min.tipo_cambio_fin, NULL::numeric) AS tipo_cambio_anterior
   FROM kaf.tactivo_fijo_valores afv
     LEFT JOIN kaf.vminimo_movimiento_af_dep min ON min.id_activo_fijo_valor = afv.id_activo_fijo_valor AND afv.id_moneda_dep = min.id_moneda_dep;

CREATE OR REPLACE VIEW kaf.vactivo_fijo_valor_estado (
    id_usuario_reg,
    id_usuario_mod,
    fecha_reg,
    fecha_mod,
    estado_reg,
    id_usuario_ai,
    usuario_ai,
    id_activo_fijo_valor,
    id_activo_fijo,
    monto_vigente_orig,
    vida_util_orig,
    fecha_ini_dep,
    depreciacion_mes,
    depreciacion_per,
    depreciacion_acum,
    monto_vigente,
    vida_util,
    fecha_ult_dep,
    tipo_cambio_ini,
    tipo_cambio_fin,
    tipo,
    estado,
    principal,
    monto_rescate,
    id_movimiento_af,
    codigo,
    monto_vigente_real,
    vida_util_real,
    fecha_ult_dep_real,
    depreciacion_acum_real,
    depreciacion_per_real,
    depreciacion_acum_ant_real,
    monto_actualiz_real,
    id_moneda,
    id_moneda_dep,
    tipo_cambio_anterior,
    estado_mov_dep,
    estado_mov)
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
    COALESCE(min.monto_vigente, afv.monto_vigente_orig) AS monto_vigente_real,
    COALESCE(min.vida_util, afv.vida_util_orig) AS vida_util_real,
    COALESCE(min.fecha, afv.fecha_ini_dep) AS fecha_ult_dep_real,
    COALESCE(min.depreciacion_acum, 0::numeric) AS depreciacion_acum_real,
    COALESCE(min.depreciacion_per, 0::numeric) AS depreciacion_per_real,
    COALESCE(min.depreciacion_acum_ant, 0::numeric) AS depreciacion_acum_ant_real,
    COALESCE(min.monto_actualiz, afv.monto_vigente_orig) AS monto_actualiz_real,
    afv.id_moneda,
    afv.id_moneda_dep,
    COALESCE(min.tipo_cambio_fin, NULL::numeric) AS tipo_cambio_anterior,
    min.estado AS estado_mov_dep,
    mov.estado AS estado_mov
   FROM kaf.tactivo_fijo_valores afv
     LEFT JOIN kaf.vminimo_movimiento_af_dep_estado min ON min.id_activo_fijo_valor = afv.id_activo_fijo_valor AND afv.id_moneda_dep = min.id_moneda_dep
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = afv.id_movimiento_af
     JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento;

CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo_por_gestion (
    id_activo_fijo,
    id_clasificacion,
    id_activo_fijo_valor,
    id_movimiento_af,
    id_movimiento,
    gestion_inicial,
    gestion_final,
    tipo,
    fecha_compra,
    fecha_ini_dep,
    codigo,
    descripcion,
    monto_vigente_orig,
    monto_vigente_inicial,
    monto_vigente_final,
    monto_actualiz_inicial,
    monto_actualiz_final,
    aitb_activo,
    vida_util_orig,
    vida_util_inicial,
    vida_util_final,
    depreciacion_per_inicial,
    depreciacion_per_final,
    depreciacion_per_actualiz_inicial,
    depreciacion_per_actualiz_final,
    depreciacion_acum_inicial,
    depreciacion_acum_final,
    aitb_depreciacion_acumulada,
    depreciacion_acum_actualiz_final,
    tipo_cabio_inicial,
    tipo_cabio_final,
    factor,
    id_moneda,
    id_moneda_dep,
    id_proyecto,
    deducible)
AS
 SELECT af.id_activo_fijo,
    af.id_clasificacion,
    afv.id_activo_fijo_valor,
    maf.id_movimiento_af,
    maf.id_movimiento,
    ud.gestion AS gestion_inicial,
    ud.gestion AS gestion_final,
    afv.tipo,
    af.fecha_compra,
    af.fecha_ini_dep,
    af.codigo,
    af.descripcion,
    afv.monto_vigente_orig,
    pd.monto_vigente_ant AS monto_vigente_inicial,
    ud.monto_vigente AS monto_vigente_final,
    pd.monto_actualiz_ant AS monto_actualiz_inicial,
    ud.monto_actualiz AS monto_actualiz_final,
    ud.monto_actualiz - pd.monto_actualiz_ant AS aitb_activo,
    afv.vida_util_orig,
    pd.vida_util_ant AS vida_util_inicial,
    ud.vida_util AS vida_util_final,
    pd.depreciacion_per_ant AS depreciacion_per_inicial,
    ud.depreciacion_per AS depreciacion_per_final,
    pd.depreciacion_per_actualiz AS depreciacion_per_actualiz_inicial,
    ud.depreciacion_per_actualiz AS depreciacion_per_actualiz_final,
    pd.depreciacion_acum_ant AS depreciacion_acum_inicial,
    ud.depreciacion_acum AS depreciacion_acum_final,
    ud.depreciacion_acum - pd.depreciacion_acum_ant - ud.depreciacion_per AS aitb_depreciacion_acumulada,
    ud.depreciacion_acum_actualiz AS depreciacion_acum_actualiz_final,
    pd.tipo_cambio_ini AS tipo_cabio_inicial,
    ud.tipo_cambio_fin AS tipo_cabio_final,
    ud.tipo_cambio_fin - pd.tipo_cambio_ini AS factor,
    afv.id_moneda,
    afv.id_moneda_dep,
    af.id_proyecto,
    afv.deducible
   FROM kaf.tactivo_fijo_valores afv
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = afv.id_activo_fijo
     JOIN kaf.vprimero_movimiento_af_dep_gestion pd ON pd.id_activo_fijo_valor = afv.id_activo_fijo_valor AND pd.id_moneda_dep = afv.id_moneda_dep
     JOIN kaf.vultimo_movimiento_af_dep_gestion ud ON ud.id_activo_fijo_valor = afv.id_activo_fijo_valor AND ud.gestion = pd.gestion AND ud.id_moneda_dep = pd.id_moneda_dep
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pd.id_movimiento_af AND maf.id_movimiento_af = ud.id_movimiento_af;

CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo (
    id_activo_fijo,
    id_clasificacion,
    id_activo_fijo_valor,
    id_movimiento_af,
    id_movimiento,
    gestion_inicial,
    gestion_final,
    tipo,
    fecha_compra,
    fecha_ini_dep,
    codigo,
    descripcion,
    monto_vigente_orig,
    monto_vigente_inicial,
    monto_vigente_final,
    monto_actualiz_inicial,
    monto_actualiz_final,
    aitb_activo,
    vida_util_orig,
    vida_util_inicial,
    vida_util_final,
    depreciacion_per_inicial,
    depreciacion_per_final,
    depreciacion_per_actualiz_inicial,
    depreciacion_per_actualiz_final,
    depreciacion_acum_inicial,
    depreciacion_acum_final,
    aitb_depreciacion_acumulada,
    depreciacion_acum_actualiz_final,
    tipo_cabio_inicial,
    tipo_cabio_final,
    factor,
    id_moneda,
    id_moneda_dep,
    id_proyecto,
    deducible)
AS
 SELECT af.id_activo_fijo,
    af.id_clasificacion,
    afv.id_activo_fijo_valor,
    maf.id_movimiento_af,
    maf.id_movimiento,
    ud.gestion AS gestion_inicial,
    ud.gestion AS gestion_final,
    afv.tipo,
    af.fecha_compra,
    af.fecha_ini_dep,
    af.codigo,
    af.descripcion,
    afv.monto_vigente_orig,
    pd.monto_vigente_ant AS monto_vigente_inicial,
    ud.monto_vigente AS monto_vigente_final,
    pd.monto_actualiz_ant AS monto_actualiz_inicial,
    ud.monto_actualiz AS monto_actualiz_final,
    ud.monto_actualiz - pd.monto_actualiz_ant AS aitb_activo,
    afv.vida_util_orig,
    pd.vida_util_ant AS vida_util_inicial,
    ud.vida_util AS vida_util_final,
    pd.depreciacion_per_ant AS depreciacion_per_inicial,
    ud.depreciacion_per AS depreciacion_per_final,
    pd.depreciacion_per_actualiz AS depreciacion_per_actualiz_inicial,
    ud.depreciacion_per_actualiz AS depreciacion_per_actualiz_final,
    pd.depreciacion_acum_ant AS depreciacion_acum_inicial,
    ud.depreciacion_acum AS depreciacion_acum_final,
    ud.depreciacion_acum - pd.depreciacion_acum_ant - ud.depreciacion_per AS aitb_depreciacion_acumulada,
    ud.depreciacion_acum_actualiz AS depreciacion_acum_actualiz_final,
    pd.tipo_cambio_ini AS tipo_cabio_inicial,
    ud.tipo_cambio_fin AS tipo_cabio_final,
    ud.tipo_cambio_fin - pd.tipo_cambio_ini AS factor,
    afv.id_moneda,
    afv.id_moneda_dep,
    af.id_proyecto,
    afv.deducible
   FROM kaf.tactivo_fijo_valores afv
     JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = afv.id_activo_fijo
     JOIN kaf.vprimero_movimiento_af_dep_movimiento pd ON pd.id_activo_fijo_valor = afv.id_activo_fijo_valor AND pd.id_moneda_dep = afv.id_moneda_dep
     JOIN kaf.vultimo_movimiento_af_dep_movimiento ud ON ud.id_activo_fijo_valor = afv.id_activo_fijo_valor AND ud.id_movimiento_af = pd.id_movimiento_af AND ud.id_moneda_dep = pd.id_moneda_dep
     JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pd.id_movimiento_af AND maf.id_movimiento_af = ud.id_movimiento_af;

CREATE OR REPLACE VIEW kaf.vactivo_fijo_vigente (
    id_activo_fijo,
    monto_vigente_real_af,
    vida_util_real_af,
    fecha_ult_dep_real_af,
    depreciacion_acum_real_af,
    depreciacion_per_real_af,
    monto_actualiz_real_af,
    id_moneda,
    id_moneda_dep)
AS
 SELECT afd.id_activo_fijo,
    sum(afd.monto_vigente_real) AS monto_vigente_real_af,
    max(afd.vida_util_real) AS vida_util_real_af,
    max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
    sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
    sum(afd.depreciacion_per_real) AS depreciacion_per_real_af,
    sum(afd.monto_actualiz_real) AS monto_actualiz_real_af,
    afd.id_moneda,
    afd.id_moneda_dep
   FROM kaf.vactivo_fijo_valor afd
  GROUP BY afd.id_activo_fijo, afd.id_moneda, afd.id_moneda_dep;

CREATE OR REPLACE VIEW kaf.vactivo_fijo_vigente_estado (
    id_activo_fijo,
    monto_vigente_real_af,
    vida_util_real_af,
    fecha_ult_dep_real_af,
    depreciacion_acum_real_af,
    depreciacion_per_real_af,
    id_moneda,
    id_moneda_dep,
    estado_mov_dep)
AS
 SELECT afd.id_activo_fijo,
    sum(afd.monto_vigente_real) AS monto_vigente_real_af,
    max(afd.vida_util_real) AS vida_util_real_af,
    max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
    sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
    sum(afd.depreciacion_per_real) AS depreciacion_per_real_af,
    afd.id_moneda,
    afd.id_moneda_dep,
    afd.estado_mov_dep
   FROM kaf.vactivo_fijo_valor_estado afd
  GROUP BY afd.id_activo_fijo, afd.id_moneda, afd.id_moneda_dep, afd.estado_mov_dep;

CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo_cbte (
    id_activo_fijo,
    id_clasificacion,
    id_activo_fijo_valor,
    id_movimiento_af,
    id_movimiento,
    gestion_inicial,
    gestion_final,
    tipo,
    fecha_compra,
    fecha_ini_dep,
    codigo,
    descripcion,
    monto_vigente_orig,
    monto_vigente_inicial,
    monto_vigente_final,
    monto_actualiz_inicial,
    monto_actualiz_final,
    aitb_activo,
    vida_util_orig,
    vida_util_inicial,
    vida_util_final,
    depreciacion_per_inicial,
    depreciacion_per_final,
    depreciacion_per_actualiz_inicial,
    depreciacion_per_actualiz_final,
    depreciacion_acum_inicial,
    depreciacion_acum_final,
    aitb_depreciacion_acumulada,
    depreciacion_acum_actualiz_final,
    tipo_cabio_inicial,
    tipo_cabio_final,
    factor,
    id_moneda,
    id_moneda_dep,
    gasto_depreciacion,
    id_centro_costo,
    id_ot)
AS
 SELECT det.id_activo_fijo,
    det.id_clasificacion,
    det.id_activo_fijo_valor,
    det.id_movimiento_af,
    det.id_movimiento,
    det.gestion_inicial,
    det.gestion_final,
    det.tipo,
    det.fecha_compra,
    det.fecha_ini_dep,
    det.codigo,
    det.descripcion,
    det.monto_vigente_orig,
    det.monto_vigente_inicial,
    det.monto_vigente_final,
    det.monto_actualiz_inicial,
    det.monto_actualiz_final,
    det.aitb_activo,
    det.vida_util_orig,
    det.vida_util_inicial,
    det.vida_util_final,
    det.depreciacion_per_inicial,
    det.depreciacion_per_final,
    det.depreciacion_per_actualiz_inicial,
    det.depreciacion_per_actualiz_final,
    det.depreciacion_acum_inicial,
    det.depreciacion_acum_final,
    det.aitb_depreciacion_acumulada,
    det.depreciacion_acum_actualiz_final,
    det.tipo_cabio_inicial,
    det.tipo_cabio_final,
    det.factor,
    det.id_moneda,
    det.id_moneda_dep,
    tp.factor * det.depreciacion_per_final AS gasto_depreciacion,
    tp.id_tipo_cc AS id_centro_costo,
    tp.id_ot
   FROM kaf.vdetalle_depreciacion_activo det
     JOIN kaf.vmovimiento_cbte mov ON mov.id_movimiento = det.id_movimiento
     JOIN kaf.ttipo_prorrateo tp ON tp.id_proyecto = det.id_proyecto
  WHERE mov.gestion::double precision = det.gestion_final AND mov.id_moneda = det.id_moneda;

CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo_cbte_aitb (
    id_activo_fijo,
    id_clasificacion,
    id_activo_fijo_valor,
    id_movimiento_af,
    id_movimiento,
    gestion_inicial,
    gestion_final,
    tipo,
    fecha_compra,
    fecha_ini_dep,
    codigo,
    descripcion,
    monto_vigente_orig,
    monto_vigente_inicial,
    monto_vigente_final,
    monto_actualiz_inicial,
    monto_actualiz_final,
    aitb_activo,
    vida_util_orig,
    vida_util_inicial,
    vida_util_final,
    depreciacion_per_inicial,
    depreciacion_per_final,
    depreciacion_per_actualiz_inicial,
    depreciacion_per_actualiz_final,
    depreciacion_acum_inicial,
    depreciacion_acum_final,
    aitb_depreciacion_acumulada,
    depreciacion_acum_actualiz_final,
    tipo_cabio_inicial,
    tipo_cabio_final,
    factor,
    id_moneda,
    id_moneda_dep)
AS
 SELECT det.id_activo_fijo,
    det.id_clasificacion,
    det.id_activo_fijo_valor,
    det.id_movimiento_af,
    det.id_movimiento,
    det.gestion_inicial,
    det.gestion_final,
    det.tipo,
    det.fecha_compra,
    det.fecha_ini_dep,
    det.codigo,
    det.descripcion,
    det.monto_vigente_orig,
    det.monto_vigente_inicial,
    det.monto_vigente_final,
    det.monto_actualiz_inicial,
    det.monto_actualiz_final,
    det.aitb_activo,
    det.vida_util_orig,
    det.vida_util_inicial,
    det.vida_util_final,
    det.depreciacion_per_inicial,
    det.depreciacion_per_final,
    det.depreciacion_per_actualiz_inicial,
    det.depreciacion_per_actualiz_final,
    det.depreciacion_acum_inicial,
    det.depreciacion_acum_final,
    det.aitb_depreciacion_acumulada,
    det.depreciacion_acum_actualiz_final,
    det.tipo_cabio_inicial,
    det.tipo_cabio_final,
    det.factor,
    det.id_moneda,
    det.id_moneda_dep
   FROM kaf.vdetalle_depreciacion_activo det
     JOIN kaf.vmovimiento_cbte mov ON mov.id_movimiento = det.id_movimiento
  WHERE (mov.gestion::double precision = det.gestion_final OR 1 = 1) AND mov.id_moneda = det.id_moneda;

/***********************************F-DEP-RAC-KAF-1-10/12/2018****************************************/

/***********************************I-DEP-RCM-KAF-5-07/02/2019****************************************/
ALTER TABLE kaf.tactivo_fijo
  ADD CONSTRAINT uq_tactivo_fijo__codigo
    UNIQUE (codigo) NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-5-07/02/2019****************************************/

/***********************************I-DEP-RCM-KAF-8-08/05/2019****************************************/
ALTER TABLE kaf.tactivo_fijo_cc
  ADD CONSTRAINT fk_tactivo_fijo_cc__id_activo_fijo FOREIGN KEY (id_activo_fijo)
    REFERENCES kaf.tactivo_fijo(id_activo_fijo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo_cc
  ADD CONSTRAINT fk_tactivo_fijo_cc__id_centro_costo FOREIGN KEY (id_centro_costo)
    REFERENCES param.tcentro_costo(id_centro_costo)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
    NOT DEFERRABLE;

ALTER TABLE kaf.tactivo_fijo_cc
  ADD CONSTRAINT uq_tactivo_fijo_cc__id_af__id_cc__mes
    UNIQUE (mes, id_centro_costo, id_activo_fijo) NOT DEFERRABLE;
/***********************************F-DEP-RCM-KAF-8-08/05/2019****************************************/


/***********************************I-DEP-RCM-KAF-10-13/05/2019****************************************/
CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion__cta(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           sum(round(mdep.depreciacion, 2)) AS monto_depreciacion,
           maf.id_movimiento,
           mdep.id_moneda,
           cc1.id_centro_costo,
           CASE COALESCE(act.nro_cuenta, ''::character varying)
             WHEN ''::text THEN (
                                  SELECT rc1.id_cuenta
                                  FROM conta.trelacion_contable rc1
                                       JOIN conta.ttipo_relacion_contable trc ON
                                         trc.id_tipo_relacion_contable =
                                         rc1.id_tipo_relacion_contable
                                  WHERE trc.codigo_tipo_relacion::text =
                                    'DEPCLAS'::text AND
                                        rc1.id_gestion =((
                                                           SELECT
                                                             f_get_periodo_gestion.po_id_gestion
                                                           FROM
                                                             param.f_get_periodo_gestion
                                                             (mov.fecha_hasta)
                                                             f_get_periodo_gestion
                                                             (po_id_periodo,
                                                             po_id_gestion,
                                                             po_id_periodo_subsistema
                                                             )
                                        )) AND
                                        rc1.estado_reg::text = 'activo'::text
  AND
                                        rc1.id_tabla = rc.id_clasificacion
           )
             ELSE cta.id_cuenta
           END AS id_cuenta,
           (
             SELECT rc1.id_partida
             FROM conta.trelacion_contable rc1
                  JOIN conta.ttipo_relacion_contable trc ON
                    trc.id_tipo_relacion_contable =
                    rc1.id_tipo_relacion_contable
             WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND
                   rc1.id_gestion =((
                                      SELECT f_get_periodo_gestion.po_id_gestion
                                      FROM param.f_get_periodo_gestion(
                                        mov.fecha_hasta) f_get_periodo_gestion(
                                        po_id_periodo, po_id_gestion,
                                        po_id_periodo_subsistema)
                   )) AND
                   rc1.estado_reg::text = 'activo'::text AND
                   rc1.id_tabla = rc.id_clasificacion
           ) AS id_partida
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo =
           af.id_activo_fijo
         LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::
           text AND (cta.id_gestion IN (
                                         SELECT tgestion.id_gestion
                                         FROM param.tgestion
                                         WHERE date_trunc('year'::text,
                                           tgestion.fecha_ini::timestamp with
                                           time zone) = date_trunc('year'::text,
                                           mov.fecha_hasta::timestamp with time
                                           zone)
         ))
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc1.id_centro_costo,
             mov.fecha_hasta,
             act.nro_cuenta,
             cta.id_cuenta;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           sum(round(mdep.depreciacion, 2)) AS monto_depreciacion,
           maf.id_movimiento,
           mdep.id_moneda,
           cc1.id_centro_costo
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc1.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per__cta(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           sum(round(mdep.depreciacion_per, 2) - round(
             mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2)) AS
             dep_per_actualiz,
           maf.id_movimiento,
           mdep.id_moneda,
           cc.codigo_tcc,
           cc1.id_centro_costo,
           CASE COALESCE(act.nro_cuenta, ''::character varying)
             WHEN ''::text THEN (
                                  SELECT rc1.id_cuenta
                                  FROM conta.trelacion_contable rc1
                                       JOIN conta.ttipo_relacion_contable trc ON
                                         trc.id_tipo_relacion_contable =
                                         rc1.id_tipo_relacion_contable
                                  WHERE trc.codigo_tipo_relacion::text =
                                    'DEPCLAS'::text AND
                                        rc1.id_gestion =((
                                                           SELECT
                                                             f_get_periodo_gestion.po_id_gestion
                                                           FROM
                                                             param.f_get_periodo_gestion
                                                             (mov.fecha_hasta)
                                                             f_get_periodo_gestion
                                                             (po_id_periodo,
                                                             po_id_gestion,
                                                             po_id_periodo_subsistema
                                                             )
                                        )) AND
                                        rc1.estado_reg::text = 'activo'::text
  AND
                                        rc1.id_tabla = rc.id_clasificacion
           )
             ELSE cta.id_cuenta
           END AS id_cuenta,
           (
             SELECT rc1.id_partida
             FROM conta.trelacion_contable rc1
                  JOIN conta.ttipo_relacion_contable trc ON
                    trc.id_tipo_relacion_contable =
                    rc1.id_tipo_relacion_contable
             WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND
                   rc1.id_gestion =((
                                      SELECT f_get_periodo_gestion.po_id_gestion
                                      FROM param.f_get_periodo_gestion(
                                        mov.fecha_hasta) f_get_periodo_gestion(
                                        po_id_periodo, po_id_gestion,
                                        po_id_periodo_subsistema)
                   )) AND
                   rc1.estado_reg::text = 'activo'::text AND
                   rc1.id_tabla = rc.id_clasificacion
           ) AS id_partida
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo =
           af.id_activo_fijo
         LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::
           text AND (cta.id_gestion IN (
                                         SELECT tgestion.id_gestion
                                         FROM param.tgestion
                                         WHERE date_trunc('year'::text,
                                           tgestion.fecha_ini::timestamp with
                                           time zone) = date_trunc('year'::text,
                                           mov.fecha_hasta::timestamp with time
                                           zone)
         ))
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc.codigo_tcc,
             cc1.id_centro_costo,
             mov.fecha_hasta,
             act.nro_cuenta,
             cta.id_cuenta;
/***********************************F-DEP-RCM-KAF-10-13/05/2019****************************************/

/***********************************I-DEP-RCM-KAF-10-14/05/2019****************************************/
CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion__cta(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
  ), tprorrateo_af as (
  select
  acc.id_activo_fijo, sum(acc.cantidad_horas) as total_hrs_af
  from kaf.tactivo_fijo_cc acc
  group by acc.id_activo_fijo
)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           case
            when coalesce(acc.id_centro_costo,0) = 0 then
              sum(round(mdep.depreciacion, 2))
            else
              sum(mdep.depreciacion* acc.cantidad_horas/paf.total_hrs_af)
           end as monto_depreciacion,
           maf.id_movimiento,
           mdep.id_moneda,
           coalesce(acc.id_centro_costo,cc1.id_centro_costo) as id_centro_costo,
           CASE COALESCE(act.nro_cuenta, ''::character varying)
             WHEN ''::text THEN (
                                  SELECT rc1.id_cuenta
                                  FROM conta.trelacion_contable rc1
                                       JOIN conta.ttipo_relacion_contable trc ON
                                         trc.id_tipo_relacion_contable =
                                         rc1.id_tipo_relacion_contable
                                  WHERE trc.codigo_tipo_relacion::text =
                                    'DEPCLAS'::text AND
                                        rc1.id_gestion =((
                                                           SELECT
                                                             f_get_periodo_gestion.po_id_gestion
                                                           FROM
                                                             param.f_get_periodo_gestion
                                                             (mov.fecha_hasta)
                                                             f_get_periodo_gestion
                                                             (po_id_periodo,
                                                             po_id_gestion,
                                                             po_id_periodo_subsistema
                                                             )
                                        )) AND
                                        rc1.estado_reg::text = 'activo'::text
  AND
                                        rc1.id_tabla = rc.id_clasificacion
           )
             ELSE cta.id_cuenta
           END AS id_cuenta,
           (
             SELECT rc1.id_partida
             FROM conta.trelacion_contable rc1
                  JOIN conta.ttipo_relacion_contable trc ON
                    trc.id_tipo_relacion_contable =
                    rc1.id_tipo_relacion_contable
             WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND
                   rc1.id_gestion =((
                                      SELECT f_get_periodo_gestion.po_id_gestion
                                      FROM param.f_get_periodo_gestion(
                                        mov.fecha_hasta) f_get_periodo_gestion(
                                        po_id_periodo, po_id_gestion,
                                        po_id_periodo_subsistema)
                   )) AND
                   rc1.estado_reg::text = 'activo'::text AND
                   rc1.id_tabla = rc.id_clasificacion
           ) AS id_partida
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo =
           af.id_activo_fijo
         LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::
           text AND (cta.id_gestion IN (
                                         SELECT tgestion.id_gestion
                                         FROM param.tgestion
                                         WHERE date_trunc('year'::text,
                                           tgestion.fecha_ini::timestamp with
                                           time zone) = date_trunc('year'::text,
                                           mov.fecha_hasta::timestamp with time
                                           zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cc acc
         ON acc.id_activo_fijo = maf.id_activo_fijo
         LEFT JOIN tprorrateo_af paf
         ON paf.id_activo_fijo = maf.id_activo_fijo
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc1.id_centro_costo,
             mov.fecha_hasta,
             act.nro_cuenta,
             cta.id_cuenta,
             acc.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_depreciacion(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    monto_depreciacion,
    id_movimiento,
    id_moneda,
    id_centro_costo)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
), tprorrateo_af as (
  select
  acc.id_activo_fijo, sum(acc.cantidad_horas) as total_hrs_af
  from kaf.tactivo_fijo_cc acc
  group by acc.id_activo_fijo

)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           case
            when coalesce(acc.id_centro_costo,0) = 0 then
              sum(round(mdep.depreciacion, 2))
            else
              sum(mdep.depreciacion* acc.cantidad_horas/paf.total_hrs_af)
           end as monto_depreciacion,
           maf.id_movimiento,
           mdep.id_moneda,
           coalesce(acc.id_centro_costo,cc1.id_centro_costo) as id_centro_costo
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cc acc
         ON acc.id_activo_fijo = maf.id_activo_fijo
         LEFT JOIN tprorrateo_af paf
         ON paf.id_activo_fijo = maf.id_activo_fijo
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc1.id_centro_costo,
             acc.id_centro_costo;

CREATE OR REPLACE VIEW kaf.v_cbte_deprec_actualiz_dep_per__cta(
    id_clasificacion,
    codigo_completo_tmp,
    nombre,
    dep_per_actualiz,
    id_movimiento,
    id_moneda,
    codigo_tcc,
    id_centro_costo,
    id_cuenta,
    id_partida)
AS
WITH trel_contable AS(
  SELECT rc_1.id_tabla AS id_clasificacion,
         (('{'::text || kaf.f_get_id_clasificaciones(rc_1.id_tabla, 'hijos'::
           character varying)::text) || '}'::text)::integer [ ] AS nodos
  FROM conta.ttabla_relacion_contable tb
       JOIN conta.ttipo_relacion_contable trc ON trc.id_tabla_relacion_contable
         = tb.id_tabla_relacion_contable
       JOIN conta.trelacion_contable rc_1 ON rc_1.id_tipo_relacion_contable =
         trc.id_tipo_relacion_contable
  WHERE tb.esquema::text = 'KAF'::text AND
        tb.tabla::text = 'tclasificacion'::text AND
        trc.codigo_tipo_relacion::text = 'DEPCLAS'::text
), tprorrateo_af as (
  select
  acc.id_activo_fijo, sum(acc.cantidad_horas) as total_hrs_af
  from kaf.tactivo_fijo_cc acc
  group by acc.id_activo_fijo

)
    SELECT rc.id_clasificacion,
           cla.codigo_completo_tmp,
           cla.nombre,
           case
            when coalesce(acc.id_centro_costo,0) = 0 then
              sum(round(mdep.depreciacion_per, 2) - round(mdep.depreciacion_per_ant, 2) - round(mdep.depreciacion, 2))
            else
                sum(round(mdep.depreciacion_per*acc.cantidad_horas/paf.total_hrs_af, 2) - round(mdep.depreciacion_per_ant*acc.cantidad_horas/paf.total_hrs_af, 2) - round(mdep.depreciacion*acc.cantidad_horas/paf.total_hrs_af, 2))
           end as dep_per_actualiz,
           maf.id_movimiento,
           mdep.id_moneda,
           cc.codigo_tcc,
           coalesce(acc.id_centro_costo, cc1.id_centro_costo) as id_centro_costo,
           CASE COALESCE(act.nro_cuenta, ''::character varying)
             WHEN ''::text THEN (
                                  SELECT rc1.id_cuenta
                                  FROM conta.trelacion_contable rc1
                                       JOIN conta.ttipo_relacion_contable trc ON
                                         trc.id_tipo_relacion_contable =
                                         rc1.id_tipo_relacion_contable
                                  WHERE trc.codigo_tipo_relacion::text =
                                    'DEPCLAS'::text AND
                                        rc1.id_gestion =((
                                                           SELECT
                                                             f_get_periodo_gestion.po_id_gestion
                                                           FROM
                                                             param.f_get_periodo_gestion
                                                             (mov.fecha_hasta)
                                                             f_get_periodo_gestion
                                                             (po_id_periodo,
                                                             po_id_gestion,
                                                             po_id_periodo_subsistema
                                                             )
                                        )) AND
                                        rc1.estado_reg::text = 'activo'::text
  AND
                                        rc1.id_tabla = rc.id_clasificacion
           )
             ELSE cta.id_cuenta
           END AS id_cuenta,
           (
             SELECT rc1.id_partida
             FROM conta.trelacion_contable rc1
                  JOIN conta.ttipo_relacion_contable trc ON
                    trc.id_tipo_relacion_contable =
                    rc1.id_tipo_relacion_contable
             WHERE trc.codigo_tipo_relacion::text = 'DEPCLAS'::text AND
                   rc1.id_gestion =((
                                      SELECT f_get_periodo_gestion.po_id_gestion
                                      FROM param.f_get_periodo_gestion(
                                        mov.fecha_hasta) f_get_periodo_gestion(
                                        po_id_periodo, po_id_gestion,
                                        po_id_periodo_subsistema)
                   )) AND
                   rc1.estado_reg::text = 'activo'::text AND
                   rc1.id_tabla = rc.id_clasificacion
           ) AS id_partida
    FROM kaf.tmovimiento_af maf
         JOIN kaf.tmovimiento_af_dep mdep ON mdep.id_movimiento_af =
           maf.id_movimiento_af
         JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = maf.id_activo_fijo
         JOIN trel_contable rc ON af.id_clasificacion = ANY (rc.nodos)
         JOIN kaf.tclasificacion cla ON cla.id_clasificacion =
           rc.id_clasificacion
         JOIN kaf.tmovimiento mov ON mov.id_movimiento = maf.id_movimiento
         LEFT JOIN param.vcentro_costo cc ON cc.id_centro_costo =
           af.id_centro_costo
         LEFT JOIN param.tcentro_costo cc1 ON cc1.id_tipo_cc = cc.id_tipo_cc AND
           (cc1.id_gestion IN (
                                SELECT tgestion.id_gestion
                                FROM param.tgestion
                                WHERE date_trunc('year'::text,
                                  tgestion.fecha_ini::timestamp with time zone)
                                  = date_trunc('year'::text, mov.fecha_hasta::
                                  timestamp with time zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cta_tmp act ON act.id_activo_fijo =
           af.id_activo_fijo
         LEFT JOIN conta.tcuenta cta ON cta.nro_cuenta::text = act.nro_cuenta::
           text AND (cta.id_gestion IN (
                                         SELECT tgestion.id_gestion
                                         FROM param.tgestion
                                         WHERE date_trunc('year'::text,
                                           tgestion.fecha_ini::timestamp with
                                           time zone) = date_trunc('year'::text,
                                           mov.fecha_hasta::timestamp with time
                                           zone)
         ))
         LEFT JOIN kaf.tactivo_fijo_cc acc
         ON acc.id_activo_fijo = maf.id_activo_fijo
         LEFT JOIN tprorrateo_af paf
         ON paf.id_activo_fijo = maf.id_activo_fijo
    WHERE mdep.id_moneda = param.f_get_moneda_base()
    GROUP BY rc.id_clasificacion,
             cla.codigo_completo_tmp,
             cla.nombre,
             maf.id_movimiento,
             mdep.id_moneda,
             cc.codigo_tcc,
             cc1.id_centro_costo,
             mov.fecha_hasta,
             act.nro_cuenta,
             cta.id_cuenta,
             acc.id_centro_costo;
/***********************************F-DEP-RCM-KAF-10-14/05/2019****************************************/