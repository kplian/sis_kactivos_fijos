CREATE OR REPLACE FUNCTION kaf.f_migracion_afs (
)
RETURNS varchar  AS 
$body$
/*
Autor: RCM
Fecha: 07/09/2017
Descripcion: Migracion de activos fijos del esquema actif a kaf
*/
DECLARE

  v_rec record;
  v_rec_af record;

  v_id_usuario integer;
  v_estado_reg varchar;
  v_id_cat_estado_fun integer;
  v_id_cat_estado_compra integer;
  v_documento varchar;
  v_observaciones varchar;
  v_id_funcionario integer;
  v_id_depto integer;
  v_id_deposito integer;
  v_id_oficina integer;
  v_id_clasificacion integer;
  v_id_moneda integer;
  v_marca varchar;
  v_nro_serie varchar;
  v_id_activo_fijo integer;
  v_monto_compra numeric;
  v_tipo_mov varchar;
  v_deducible varchar = 'si';

BEGIN

  -----------------------------
  --Inicializacion de variables
  -----------------------------
  v_id_usuario = 1;
  v_estado_reg = 'activo';
  v_marca = 'N/D';
  v_nro_serie = 'N/D';

  --Estado funcional
  v_id_cat_estado_fun = 97; --bueno
  --Estado de compra
  v_id_cat_estado_compra = 106; --bueno

  ---------------------------------
  --Migracion de los activos fijos
  ---------------------------------
  for v_rec in select * from actif.taf_activo_fijo order by fecha_compra loop

    --Clasificacion
    select id_clasificacion into v_id_clasificacion
    from kaf.tclasificacion
    where codigo = trim(substr(v_rec.codigo,0,9));


    select
    null,--id_persona,
    null, --id_proveedor,
    v_rec.fecha_compra as fecha_compra,--fecha_compra,
    --v_parametros.monto_vigente,
    v_id_cat_estado_fun as id_cat_estado_fun, --estado funcional
    v_rec.ubicacion_fisica as ubicacion, --ubicacion
    --v_parametros.vida_util,
    v_rec.num_factura as documento, --documento
    v_rec.observaciones as observaciones, --observaciones
    --v_parametros.fecha_ult_dep,
    1 as monto_rescate, --monto_rescate,
    v_rec.descripcion as denominacion, --denominacion
    v_id_funcionario as id_funcionario, --funcionario
    v_id_deposito as id_deposito, --id_deposito
    v_rec.monto_compra_mon_orig as monto_compra_orig, --monto_compra_orig
    v_rec.id_moneda_original as id_moneda_orig, --moneda_orig
    v_rec.codigo as codigo, --codigo,
    v_rec.descripcion_larga as descripcion, --descripcion
    v_rec.id_moneda as id_moneda, --id_moneda_orig
    v_rec.fecha_ini_dep as fecha_ini_dep,--fecha_ini_dep
    v_id_cat_estado_compra as id_cat_estado_compra, --id_cat_estado_compra,
    v_rec.vida_util_original vida_util_original, --vida_util_original,
    v_id_clasificacion as id_clasificacion, --id_clasificacion
    v_id_oficina as id_oficina, --id_oficina
    v_id_depto as id_depto, --id_depto,
    v_id_usuario as id_usuario,
    null, -- v_parametros.nombre_usuario_ai,
    null, --v_parametros.id_usuario_ai
    v_rec.codigo_ant as codigo_ant, --codigo_ant
    v_marca as marca, --marca
    v_nro_serie as nro_serie, --parametros.nro_serie,
    NULL,
    NULL
    into v_rec_af;



    ----------
    ----------
    --Conversión de monedas
    v_monto_compra = param.f_pm_conversion_monedas(
        v_rec.fecha_compra,
        v_rec.monto_compra_mon_orig,
        v_rec.id_moneda_original,
        1,
        'O'
    );
            
    --Se hace el registro del activo fijo
    insert into kaf.tactivo_fijo(
      id_persona,
      cantidad_revaloriz,
      foto,
      id_proveedor,
      estado_reg,
      fecha_compra,
      --monto_vigente,
      id_cat_estado_fun,
      ubicacion,
      --vida_util,
      documento,
      observaciones,
      --fecha_ult_dep,
      monto_rescate,
      denominacion,
      id_funcionario,
      id_deposito,
      monto_compra_orig,
      monto_compra,
      id_moneda,
      depreciacion_mes,
      codigo,
      descripcion,
      id_moneda_orig,
      fecha_ini_dep,
      id_cat_estado_compra,
      depreciacion_per,
      vida_util_original,
      depreciacion_acum,
      estado,
      id_clasificacion,
      id_centro_costo,
      id_oficina,
      id_depto,
      id_usuario_reg,
      fecha_reg,
      usuario_ai,
      id_usuario_ai,
      id_usuario_mod,
      fecha_mod,
      en_deposito,
      codigo_ant,
      marca,
      nro_serie,
      caracteristicas,
      id_proyecto,
      id_unidad_medida,
      cantidad_af,
      monto_compra_orig_100,
      nro_cbte_asociado,
      fecha_cbte_asociado,
      id_cotizacion_det,
      id_preingreso_det
      ) values(
          null, --persona 
          0,
          './../../../uploaded_files/sis_kactivos_fijos/ActivoFijo/default.jpg',
          null,
          'activo',
          v_rec.fecha_compra,
          --(p_parametros->'monto_vigente')::numeric,
          v_id_cat_estado_fun,
          v_rec.ubicacion_fisica,
         -- (p_parametros->'vida_util')::integer,
          v_rec.num_factura,
          v_rec.observaciones,
         -- (p_parametros->'fecha_ult_dep')::date,
          1,
          v_rec.descripcion,
          v_id_funcionario,
          v_id_deposito,
          v_rec.monto_compra_mon_orig,
          v_monto_compra,
          v_rec.id_moneda_original,
          0,
          null,
          v_rec.descripcion_larga,
          v_rec.id_moneda,
          v_rec.fecha_ini_dep,
          v_id_cat_estado_compra,
          0,
          v_rec.vida_util_original,
          0,
          v_rec.estado,
          v_id_clasificacion,
          null,
          v_id_oficina,
          v_id_depto,
          v_id_usuario,
          now(),
          null,
          null,
          null,
          null,
          'si',
          v_rec.codigo_ant,
          v_marca,
          v_nro_serie,
          null,
          null,
          null,
          1,
          v_rec.importe_100,
          null,
          null,
          null,
          null
          
      ) returning id_activo_fijo into v_id_activo_fijo;

      ------------------------------------------
      --(2) Creación de sus AFV
      ------------------------------------------
      v_tipo_mov = 'alta';

      --AFV Bolivianos
      insert into kaf.tactivo_fijo_valores(
          id_usuario_reg    ,fecha_reg      ,estado_reg   ,id_activo_fijo,   
          monto_vigente_orig  ,vida_util_orig   ,fecha_ini_dep  ,depreciacion_mes, 
          depreciacion_per  ,depreciacion_acum  ,monto_vigente  ,vida_util,
          estado        ,principal      ,monto_rescate  ,id_movimiento_af,
          tipo        ,codigo       ,fecha_inicio   ,id_moneda_dep,
          id_moneda       ,deducible
          ) values (
          v_id_usuario ,now() ,'activo' ,v_id_activo_fijo,
          v_monto_compra ,v_rec.vida_util_original ,v_rec.fecha_ini_dep ,0,                 
          0 , 0 ,v_monto_compra, v_rec.vida_util_original,         
          'activo' ,'si' ,1, null,
          v_tipo_mov ,null ,v_rec.fecha_ini_dep, 3,
          1 ,v_deducible
          );

      --AFV Dólares
      v_monto_compra = param.f_pm_conversion_monedas(
          v_rec.fecha_compra,
          v_rec.monto_compra_mon_orig,
          v_rec.id_moneda_original,
          2,
          'O'
      );
      insert into kaf.tactivo_fijo_valores(
          id_usuario_reg    ,fecha_reg      ,estado_reg   ,id_activo_fijo,   
          monto_vigente_orig  ,vida_util_orig   ,fecha_ini_dep  ,depreciacion_mes, 
          depreciacion_per  ,depreciacion_acum  ,monto_vigente  ,vida_util,
          estado        ,principal      ,monto_rescate  ,id_movimiento_af,
          tipo        ,codigo       ,fecha_inicio   ,id_moneda_dep,
          id_moneda       ,deducible
          ) values (
          v_id_usuario ,now() ,'activo' ,v_id_activo_fijo,
          v_monto_compra ,v_rec.vida_util_original ,v_rec.fecha_ini_dep ,0,                 
          0 , 0 ,v_monto_compra, v_rec.vida_util_original,         
          'activo' ,'si' ,1, null,
          v_tipo_mov ,null ,v_rec.fecha_ini_dep, 3,
          2 ,v_deducible
          );


      --AFV Bolivianos
      v_monto_compra = param.f_pm_conversion_monedas(
          v_rec.fecha_compra,
          v_rec.monto_compra_mon_orig,
          v_rec.id_moneda_original,
          3,
          'O'
      );

      insert into kaf.tactivo_fijo_valores(
          id_usuario_reg    ,fecha_reg      ,estado_reg   ,id_activo_fijo,   
          monto_vigente_orig  ,vida_util_orig   ,fecha_ini_dep  ,depreciacion_mes, 
          depreciacion_per  ,depreciacion_acum  ,monto_vigente  ,vida_util,
          estado        ,principal      ,monto_rescate  ,id_movimiento_af,
          tipo        ,codigo       ,fecha_inicio   ,id_moneda_dep,
          id_moneda       ,deducible
          ) values (
          v_id_usuario ,now() ,'activo' ,v_id_activo_fijo,
          v_monto_compra ,v_rec.vida_util_original ,v_rec.fecha_ini_dep ,0,                 
          0 , 0 ,v_monto_compra, v_rec.vida_util_original,         
          'activo' ,'si' ,1, null,
          v_tipo_mov ,null ,v_rec.fecha_ini_dep, 3,
          3 ,v_deducible
          );
    ---------
    ---------




  end loop;

  return 'hecho';
  

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;
