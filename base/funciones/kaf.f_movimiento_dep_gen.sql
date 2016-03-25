CREATE OR REPLACE FUNCTION "kaf"."f_movimiento_dep_gen"(p_id_usuario int4, p_id_proceso_wf int4, p_id_estado_anterior int4, p_id_tipo_estado_actual int4)
  RETURNS "pg_catalog"."bool" AS $BODY$

DECLARE

	v_estado 			varchar;
	v_movimiento 		record;
	v_movimiento_af 	record;
	v_rec 				record;
	v_fecha_ult_dep		date;

BEGIN

	--Verificar que sea el estado final para aplicar los cambios
	select te.codigo
	into v_estado
	from wf.testado_wf ew
	inner join wf.ttipo_estado te
	on te.id_tipo_estado = ew.id_tipo_estado
	where ew.id_estado_wf = p_id_estado_anterior;

  	--Obtiene datos del movimiento
	select
	mov.id_movimiento, mov.id_cat_movimiento, mov.fecha_mov,
	cat.codigo as movimiento
	into v_movimiento
	from kaf.tmovimiento mov
	inner join param.tcatalogo cat
	on cat.id_catalogo = mov.id_cat_movimiento
	where id_proceso_wf = p_id_proceso_wf;

	return true;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100;

