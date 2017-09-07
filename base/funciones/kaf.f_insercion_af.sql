--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_insercion_af (
  p_id_usuario integer,
  p_parametros public.hstore
)
RETURNS integer AS
$body$
/*
Autor: RCM
Fecha: 10/01/2015
Descripción: Función para insertar un activo fijo (Se la independiza para poder llamarla desde otras funciones)
*/
DECLARE

	v_id_activo_fijo 		integer;
    v_nombre_funcion		varchar;
    v_resp					varchar;
    v_monto_compra			numeric;

BEGIN

    v_nombre_funcion = 'kaf.f_insercion_af';
     
    --Conversión de monedas
    v_monto_compra = param.f_convertir_moneda(
                           (p_parametros->'id_moneda_orig')::integer, 
                           NULL,   --por defecto moneda base
                           (p_parametros->'monto_compra_orig')::numeric, 
                           (p_parametros->'fecha_compra')::date, 
                           'O',-- tipo oficial, venta, compra 
                           NULL);--defecto dos decimales
            
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
        (p_parametros->'id_persona')::integer, 
        0,
        './../../../uploaded_files/sis_kactivos_fijos/ActivoFijo/default.jpg',
        (p_parametros->'id_proveedor')::integer,
        'activo',
        (p_parametros->'fecha_compra')::date,
        --(p_parametros->'monto_vigente')::numeric,
        (p_parametros->'id_cat_estado_fun')::integer,
        (p_parametros->'ubicacion')::varchar,
       -- (p_parametros->'vida_util')::integer,
        (p_parametros->'documento')::varchar,
        (p_parametros->'observaciones')::varchar,
       -- (p_parametros->'fecha_ult_dep')::date,
        (p_parametros->'monto_rescate')::numeric,
        (p_parametros->'denominacion')::varchar,
        (p_parametros->'id_funcionario')::integer,
        (p_parametros->'id_deposito')::integer,
        (p_parametros->'monto_compra_orig')::numeric,
         v_monto_compra,
        (p_parametros->'id_moneda_orig')::integer,
        0,
        null,
        (p_parametros->'descripcion')::varchar,
        (p_parametros->'id_moneda_orig')::integer,
        (p_parametros->'fecha_ini_dep')::date,
        (p_parametros->'id_cat_estado_compra')::integer,
        0,
        (p_parametros->'vida_util_original')::integer,
        0,
        'registrado',
        (p_parametros->'id_clasificacion')::integer,
        null,
        (p_parametros->'id_oficina')::integer,
        (p_parametros->'id_depto')::integer,
        p_id_usuario,
        now(),
        (p_parametros->'nombre_usuario_ai')::varchar,
        (p_parametros->'id_usuario_ai')::integer,
        null,
        null,
        'si',
        (p_parametros->'codigo_ant')::varchar,
        (p_parametros->'marca')::varchar,
        (p_parametros->'nro_serie')::varchar,
        (p_parametros->'caracteristicas')::text,
        (p_parametros->'id_proyecto')::integer,
        (p_parametros->'id_unidad_medida')::integer,
        (p_parametros->'cantidad_af')::integer,
        (p_parametros->'monto_compra_orig_100')::numeric,
        (p_parametros->'nro_cbte_asociado')::varchar,
        (p_parametros->'fecha_cbte_asociado')::date,
        (p_parametros->'id_cotizacion_det')::integer,
        (p_parametros->'id_preingreso_det')::integer
        
    ) returning id_activo_fijo into v_id_activo_fijo;

	--Respuesta
    return v_id_activo_fijo;

EXCEPTION
  WHEN OTHERS THEN
      v_resp='';
      v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
      v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
      v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
      raise exception '%',v_resp;


END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;