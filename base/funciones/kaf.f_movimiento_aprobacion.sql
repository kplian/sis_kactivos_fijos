CREATE OR REPLACE FUNCTION "kaf"."f_movimiento_aprobacion"(p_id_usuario int4, p_id_proceso_wf int4, p_id_estado_anterior int4, p_id_tipo_estado_actual int4)
  RETURNS "pg_catalog"."bool" AS $BODY$DECLARE

	v_estado 				varchar;
	v_movimiento 		record;
	v_movimiento_af record;
	v_rec 					record;

BEGIN

	--Verificar que sea el estado final para aplicar los cambios
	select codigo
	into v_estado
	from wf.ttipo_estado
	where id_tipo_estado = p_id_tipo_estado_actual;

  

	--Obtiene datos del movimiento
	select
	mov.id_movimiento, mov.id_cat_movimiento,
	cat.codigo as movimiento
	into v_movimiento
	from kaf.tmovimiento mov
	inner join param.tcatalogo cat
	on cat.id_catalogo = mov.id_cat_movimiento
	where id_proceso_wf = p_id_proceso_wf;
	

	if v_estado = 'finalizado' then


		--Logica por estado
		if v_movimiento.movimiento = 'alta' then

				--Crea el registro de importes
				insert into kaf.tactivo_fijo_valores(
				id_usuario_reg, fecha_reg,estado_reg,
				id_activo_fijo,monto_vigente_orig,vida_util_orig,fecha_ini_dep,
				depreciacion_mes,depreciacion_per,depreciacion_acum,
				monto_vigente,vida_util,estado,principal,monto_rescate,id_movimiento_af
				)
				select
				p_id_usuario,now(),'activo',
				af.id_activo_fijo,af.monto_compra,af.vida_util_original,af.fecha_ini_dep,
				0,0,0,
				af.monto_compra,af.vida_util_original,'activo','si',af.monto_rescate,movaf.id_movimiento_af
				from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento;

				--Actualiza estado de activo fijo
				update kaf.tactivo_fijo set
				estado = 'alta'
				from kaf.tmovimiento_af movaf
				where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
				and movaf.id_movimiento = v_movimiento.id_movimiento;

				return true;

		elsif v_movimiento.movimiento = 'baja' then
			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			estado = 'baja',
			fecha_baja = mov.fecha_mov
			from kaf.tmovimiento_af movaf
			inner kaf.tmovimiento mov
			on mov.id_movimiento = movaf.id_movimiento
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;


			return true;
		elsif v_movimiento.movimiento = 'asig' then
			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			en_deposito = 'no',
			id_funcionario = mov.id_funcionario,
			id_persona = mov.id_persona
			from kaf.tmovimiento_af movaf
			inner join kaf.tmovimiento mov
			on mov.id_movimiento = movaf.id_movimiento
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;

			return true;

		elsif v_movimiento.movimiento = 'devol' then
			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			en_deposito = 'si',
			id_funcionario = mov.id_funcionario,
			id_persona = null
			from kaf.tmovimiento_af movaf
			inner join kaf.tmovimiento mov
			on mov.id_movimiento = movaf.id_movimiento
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;

			return true;
		elsif v_movimiento.movimiento = 'reval' then
			--Crea el registro de importes
			insert into kaf.tactivo_fijo_valores(
			id_usuario_reg, fecha_reg,estado_reg,
			id_activo_fijo,monto_vigente_orig,vida_util_orig,fecha_ini_dep,
			depreciacion_mes,depreciacion_per,depreciacion_acum,
			monto_vigente,vida_util,estado,principal,monto_rescate,id_movimiento_af
			)
			select
			p_id_usuario,now(),'activo',
			af.id_activo_fijo,af.monto_compra,af.vida_util_original,af.fecha_ini_dep,
			0,0,0,
			moavaf.importe,movaf.vida_util,'activo','si',af.monto_rescate,movaf.id_movimiento_af
			from kaf.tmovimiento_af movaf
			inner join kaf.tactivo_fijo af
			on af.id_activo_fijo = movaf.id_activo_fijo
			where movaf.id_movimiento = v_movimiento.id_movimiento;

			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			cantidad_revaloriz = cantidad_revaloriz + 1,
			monto_vigente = movaf.importe,
			vida_util = movaf.vida_util
			from kaf.tmovimiento_af movaf
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;


			return true;
		elsif v_movimiento.movimiento = 'deprec' then
			return true;
		end if;
	
	else
		return true;
	end if;
	
--	raise exception 'FFFF: %',v_movimiento.movimiento;
	return true;

END
$BODY$
  LANGUAGE 'plpgsql' VOLATILE COST 100
;

