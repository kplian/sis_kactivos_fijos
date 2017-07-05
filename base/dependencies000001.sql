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
  SELECT DISTINCT ON (afd.id_activo_fijo_valor) afd.id_activo_fijo_valor,
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
  ORDER BY afd.id_activo_fijo_valor,
           afd.fecha DESC;

--------------- SQL ---------------

CREATE OR REPLACE VIEW kaf.vactivo_fijo_valor(
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
    id_moneda_dep)
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
         COALESCE(min.depreciacion_acum, 0::numeric) AS depreciacion_acum_real,
         COALESCE(min.depreciacion_per, 0::numeric) AS depreciacion_per_real,
         COALESCE(min.depreciacion_acum_ant, 0::numeric) AS
           depreciacion_acum_ant_real,
         COALESCE(min.monto_actualiz, afv.monto_vigente_orig) AS
           monto_actualiz_real,
         afv.id_moneda,
         afv.id_moneda_dep,
         COALESCE(min.tipo_cambio_fin , null) AS tipo_cambio_anterior
  FROM kaf.tactivo_fijo_valores afv
       LEFT JOIN kaf.vminimo_movimiento_af_dep min ON min.id_activo_fijo_valor =
         afv.id_activo_fijo_valor AND afv.id_moneda_dep = min.id_moneda_dep;
       
       
       
       
       
CREATE OR REPLACE VIEW kaf.vactivo_fijo_vigente
AS
  SELECT afd.id_activo_fijo,
         sum(afd.monto_vigente_real) AS monto_vigente_real_af,
         max(afd.vida_util_real) AS vida_util_real_af,
         max(afd.fecha_ult_dep_real) AS fecha_ult_dep_real_af,
         sum(afd.depreciacion_acum_real) AS depreciacion_acum_real_af,
         sum(afd.depreciacion_per_real) AS depreciacion_per_real_af,
         afd.id_moneda,
         afd.id_moneda_dep
  FROM kaf.vactivo_fijo_valor afd
  GROUP BY afd.id_activo_fijo,
           afd.id_moneda,
           afd.id_moneda_dep;       
       

--vistas para reportes y contabilizacion
  
  CREATE OR REPLACE VIEW kaf.vultimo_movimiento_af_dep_gestion(
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
    tipo_cambio_ini)
AS
  SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part
    ('year'::text, afd.fecha))) date_part('year'::text, afd.fecha) AS gestion,
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
         afd.tipo_cambio_ini
  FROM kaf.tmovimiento_af_dep afd
  ORDER BY afd.id_activo_fijo_valor,
           afd.id_movimiento_af,
           (date_part('year'::text, afd.fecha)),
           afd.fecha DESC;
 
 
CREATE OR REPLACE VIEW kaf.vprimero_movimiento_af_dep_gestion(
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
    tipo_cambio_ini)
AS
  SELECT DISTINCT ON (afd.id_activo_fijo_valor, afd.id_movimiento_af, (date_part
    ('year'::text, afd.fecha))) date_part('year'::text, afd.fecha) AS gestion,
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
         afd.tipo_cambio_ini
  FROM kaf.tmovimiento_af_dep afd
  ORDER BY afd.id_activo_fijo_valor,
           afd.id_movimiento_af,
           (date_part('year'::text, afd.fecha)),
           afd.fecha;   
           
           
 CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo(
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
    id_proyecto)
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
         ud.depreciacion_acum - pd.depreciacion_acum_ant - ud.depreciacion_per
           AS aitb_depreciacion_acumulada,
         ud.depreciacion_acum_actualiz AS depreciacion_acum_actualiz_final,
         pd.tipo_cambio_ini AS tipo_cabio_inicial,
         ud.tipo_cambio_fin AS tipo_cabio_final,
         ud.tipo_cambio_fin - pd.tipo_cambio_ini AS factor,
         afv.id_moneda,
         afv.id_moneda_dep,
         af.id_proyecto
  FROM kaf.tactivo_fijo_valores afv
       JOIN kaf.tactivo_fijo af ON af.id_activo_fijo = afv.id_activo_fijo
       JOIN kaf.vprimero_movimiento_af_dep_gestion pd ON pd.id_activo_fijo_valor
         = afv.id_activo_fijo_valor
       JOIN kaf.vultimo_movimiento_af_dep_gestion ud ON ud.id_activo_fijo_valor
         = afv.id_activo_fijo_valor AND ud.gestion = pd.gestion
       JOIN kaf.tmovimiento_af maf ON maf.id_movimiento_af = pd.id_movimiento_af
         AND maf.id_movimiento_af = ud.id_movimiento_af;

/***********************************F-DEP-RAC-KAF-1-29/03/2017****************************************/




/***********************************I-DEP-RAC-KAF-1-17/04/2017****************************************/
CREATE OR REPLACE VIEW kaf.vclaificacion_raiz(
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
WITH RECURSIVE clasificacion(
    ids,
    id_clasificacion,
    id_clasificacion_fk,
    nombre,
    codigo,
    descripcion) AS(
  SELECT ARRAY [ c_1.id_clasificacion ] AS "array",
         c_1.id_clasificacion,
         c_1.id_clasificacion_fk,
         c_1.nombre,
         c_1.codigo,
         c_1.descripcion
  FROM kaf.tclasificacion c_1
  WHERE c_1.contabilizar::text = 'si'::text AND
        c_1.estado_reg::text = 'activo'::text
  UNION
  SELECT pc.ids || c2.id_clasificacion,
         c2.id_clasificacion,
         c2.id_clasificacion_fk,
         c2.nombre,
         c2.codigo,
         c2.descripcion
  FROM kaf.tclasificacion c2,
       clasificacion pc
  WHERE c2.id_clasificacion_fk = pc.id_clasificacion AND
        c2.estado_reg::text = 'activo'::text)
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
           JOIN kaf.tclasificacion cl ON cl.id_clasificacion = c.ids [ 1 ];





/***********************************F-DEP-RAC-KAF-1-17/04/2017****************************************/




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


/***********************************I-DEP-RAC-KAF-1-02/05/2017****************************************/


--------------- SQL ---------------

CREATE OR REPLACE VIEW kaf.vmovimiento_cbte 
AS 
SELECT 
mov.id_movimiento,
mov.id_depto as id_depto_af,
mov.fecha_mov,
mov.id_cat_movimiento,
cat.codigo as codigo_catelogo,
cat.descripcion as desc_catalogo,
mov.num_tramite,
mov.fecha_hasta,
mov.glosa,
depc.id_depto as id_depto_conta, 
depc.codigo as codigo_depto_conta,
per.id_gestion,
ges.gestion,
md.id_moneda,
md.descripcion
FROM kaf.tmovimiento mov
INNER JOIN param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
INNER JOIN param.tdepto_depto dd on dd.id_depto_origen = mov.id_depto 
INNER JOIN param.tdepto depc on depc.id_depto = dd.id_depto_destino 
INNER JOIN segu.tsubsistema sis on sis.id_subsistema = depc.id_subsistema and sis.codigo = 'CONTA'
INNER JOIN param.tperiodo per on mov.fecha_mov BETWEEN per.fecha_ini and per.fecha_fin
INNER JOIN param.tgestion ges on ges.id_gestion = per.id_gestion
INNER JOIN kaf.tmoneda_dep md on   md.contabilizar = 'si';

CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo_cbte(
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
    codigo_raiz,
    id_claificacion_raiz,
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
         cr.codigo_raiz,
         cr.id_claificacion_raiz,
         tp.factor * det.depreciacion_per_final AS gasto_depreciacion,
         tp.id_centro_costo,
         tp.id_ot
  FROM kaf.vdetalle_depreciacion_activo det
       JOIN kaf.vmovimiento_cbte mov ON mov.id_movimiento = det.id_movimiento
       JOIN kaf.ttipo_prorrateo tp ON tp.id_proyecto = det.id_proyecto
       JOIN kaf.vclaificacion_raiz cr ON cr.id_clasificacion =
         det.id_clasificacion
  WHERE mov.gestion::double precision = det.gestion_final AND
        mov.id_moneda = det.id_moneda;
        
 CREATE OR REPLACE VIEW kaf.vdetalle_depreciacion_activo_cbte_aitb(
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
    codigo_raiz,
    id_claificacion_raiz)
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
         cr.codigo_raiz,
         cr.id_claificacion_raiz
  FROM kaf.vdetalle_depreciacion_activo det
       JOIN kaf.vmovimiento_cbte mov ON mov.id_movimiento = det.id_movimiento
       JOIN kaf.vclaificacion_raiz cr ON cr.id_clasificacion =
         det.id_clasificacion
  WHERE mov.gestion::double precision = det.gestion_final AND
        mov.id_moneda = det.id_moneda;       


/***********************************F-DEP-RAC-KAF-1-02/05/2017****************************************/





