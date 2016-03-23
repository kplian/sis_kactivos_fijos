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

	v_id_activo_fijo integer;

BEGIN

	--Se hace el registro del activo fijo
	insert into kaf.tactivo_fijo(
		id_persona,
		cantidad_revaloriz,
		foto,
		id_proveedor,
		estado_reg,
		fecha_compra,
		monto_vigente,
		id_cat_estado_fun,
		ubicacion,
		vida_util,
		documento,
		observaciones,
		fecha_ult_dep,
		monto_rescate,
		denominacion,
        id_funcionario,
        id_deposito,
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
        fecha_mod
    ) values(
        (p_parametros->'id_persona')::integer, 
        0,
        'default.jpg',
        (p_parametros->'id_proveedor')::integer,
        'activo',
        (p_parametros->'fecha_compra')::date,
        (p_parametros->'monto_vigente')::numeric,
        (p_parametros->'id_cat_estado_fun')::integer,
        (p_parametros->'ubicacion')::varchar,
        (p_parametros->'vida_util')::integer,
        (p_parametros->'documento')::varchar,
        (p_parametros->'observaciones')::varchar,
        (p_parametros->'fecha_ult_dep')::date,
        (p_parametros->'monto_rescate')::numeric,
        (p_parametros->'denominacion')::varchar,
        (p_parametros->'id_funcionario')::integer,
        (p_parametros->'id_deposito')::integer,
        (p_parametros->'monto_compra')::numeric,
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
        null
    )RETURNING id_activo_fijo into v_id_activo_fijo;


	--Respuesta
    return v_id_activo_fijo;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;