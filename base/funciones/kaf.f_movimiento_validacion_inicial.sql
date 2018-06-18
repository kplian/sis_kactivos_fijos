CREATE OR REPLACE FUNCTION kaf.f_movimiento_validacion_inicial (
  p_id_usuario integer,
  p_id_proceso_wf integer,
  p_id_estado_anterior integer,
  p_id_tipo_estado_actual integer
)
RETURNS boolean AS
$body$
DECLARE

	v_estado 				varchar;
	v_movimiento 		record;
	v_movimiento_af record;
	v_rec 					record;
	v_fecha_ult_dep	date;

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


	--Validaciones por tipo de movimiento
	if v_estado = 'borrador' then

		--Logica por estado
		if v_movimiento.movimiento = 'alta' then

				--Verifica si existe algun activo fijo ya dado de alta
				if exists(select 1 from kaf.tmovimiento_af movaf
					inner join kaf.tactivo_fijo af
					on af.id_activo_fijo = movaf.id_activo_fijo
					where movaf.id_movimiento = v_movimiento.id_movimiento
					and af.estado = 'alta') then

					update kaf.tmovimiento_af set
					respuesta = 'Activo fijo ya dado de alta'
					from kaf.tactivo_fijo af
					where kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento
					and kaf.tmovimiento_af.id_activo_fijo = af.id_activo_fijo
					and af.estado = 'alta';

					return false;
				end if;

				--Verifica que no este en un movimiento de Alta previamente
				if exists(select 1 from kaf.tmovimiento_af movaf
					inner join kaf.tmovimiento mov
					on mov.id_movimiento = movaf.id_movimiento
					inner join param.tcatalogo cat
					on cat.id_catalogo = mov.id_cat_movimiento
					where movaf.id_movimiento != v_movimiento.id_movimiento
					and cat.codigo = 'alta') then

					update kaf.tmovimiento_af set
					respuesta = 'Activo fijo esta en Movimiento de Alta: '||coalesce(obs.codigo,'S/N') || ', en estado: ' ||obs.estado|| ', de fecha: '||obs.fecha_mov
					from (select movaf.id_activo_fijo, mov.codigo, mov.estado, mov.fecha_mov
					from kaf.tmovimiento_af movaf
					inner join kaf.tmovimiento mov
					on mov.id_movimiento = movaf.id_movimiento
					inner join param.tcatalogo cat
					on cat.id_catalogo = mov.id_cat_movimiento
					where movaf.id_movimiento != v_movimiento.id_movimiento
					and cat.codigo = 'alta') obs
					where obs.id_activo_fijo = kaf.tmovimiento_af.id_activo_fijo
					and kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento;

					return false;
				end if;

				return true;

		elsif v_movimiento.movimiento = 'baja' then
			v_fecha_ult_dep = v_movimiento.fecha_mov - interval '1 month';
			v_fecha_ult_dep = cast('01/'||date_part('month', v_fecha_ult_dep)||'/'||date_part('year', v_fecha_ult_dep) as date);

			--Verifica que se haya depreciado hasta el mes anterior a la fecha de baja
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.fecha_baja < v_fecha_ult_dep) then

				update kaf.tmovimiento_af set
				respuesta = 'Activo fijo debe depreciarse hasta el periodo de: '||to_char(v_fecha_ult_dep, 'mm/yyyy')
				from kaf.tactivo_fijo af
				where kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento
				and kaf.tmovimiento_af.id_activo_fijo = af.id_activo_fijo
				and af.fecha_baja < v_fecha_ult_dep;

				return false;
			end if;

			--Verifica que no este en otro movimiento no finalizado o cancelado
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tmovimiento mov
				on mov.id_movimiento = movaf.id_movimiento
				where movaf.id_movimiento != v_movimiento.id_movimiento
				and mov.estado not in ('finalizado','cancelado')) then

				update kaf.tmovimiento_af set
				respuesta = 'Activo fijo no deberia estar en ningun movimiento pendiente, se encuentra en el Movimiento de : '||obs.movimiento||' '||coalesce(obs.codigo,'S/N') || ', en estado: ' ||obs.estado|| ', de fecha: '||obs.fecha_mov
				from (select movaf.id_activo_fijo, mov.codigo, mov.estado, mov.fecha_mov, cat.descripcion as movimiento
				from kaf.tmovimiento_af movaf
				inner join kaf.tmovimiento mov
				on mov.id_movimiento = movaf.id_movimiento
				inner join param.tcatalogo cat
				on cat.id_catalog = mov.id_cat_movimiento
				where movaf.id_movimiento != v_movimiento.id_movimiento
				and mov.estado not in ('finalizado','cancelado')) obs
				where obs.id_activo_fijo = kaf.tmovimiento_af.id_activo_fijo
				and kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento;

				return false;
			end if;

			return true;
		elsif v_movimiento.movimiento = 'asig' then
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af 
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.en_deposito = 'no') then

				update kaf.tmovimiento_af set
				respuesta = 'Debe hacerse una Devolucion del Activo fijo; actualmente asignado a:' || obs.funcionario
				from (select movaf.id_activo_fijo, movaf.id_movimiento, fun.desc_funcionario2 as funcionario
				from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af on af.id_activo_fijo = movaf.id_activo_fijo
				inner join orga.vfuncionario fun on fun.id_funcionario = af.id_funcionario
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.en_deposito = 'no') obs
				where obs.id_activo_fijo = kaf.tmovimiento_af.id_activo_fijo
				and kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento;

				return false;
			end if;

			return true;
		elsif v_movimiento.movimiento = 'devol' then
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af 
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.en_deposito = 'si') then

				update kaf.tmovimiento_af set
				respuesta = 'Activo fijo ya en Deposito; actualmente asignado a:' || obs.funcionario
				from (select movaf.id_activo_fijo, movaf.id_movimiento
				from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.en_deposito = 'si') obs
				where obs.id_activo_fijo = kaf.tmovimiento_af.id_activo_fijo
				and kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento;

				return false;
			end if;

			return true;
		elsif v_movimiento.movimiento = 'reval' then
			v_fecha_ult_dep = v_movimiento.fecha_mov - interval '1 month';
			v_fecha_ult_dep = cast('01/'||date_part('month', v_fecha_ult_dep)||'/'||date_part('year', v_fecha_ult_dep) as date);

			--Verifica que se haya depreciado hasta el mes anterior a la fecha de revalorizacion
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.estado = 'alta'
				and af.fecha_baja < v_fecha_ult_dep) then

				update kaf.tmovimiento_af set
				respuesta = 'Activo fijo debe depreciarse hasta el periodo de: '||to_char(v_fecha_ult_dep, 'mm/yyyy')
				from kaf.tactivo_fijo af
				where kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento
				and kaf.tmovimiento_af.id_activo_fijo = af.id_activo_fijo
				and af.fecha_baja < v_fecha_ult_dep;

				return false;
			end if;

			return true;
		elsif v_movimiento.movimiento = 'deprec' then
			--Verifica que se haya depreciado hasta el mes anterior a la fecha de revalorizacion
			if exists(select 1 from kaf.tmovimiento_af movaf
				inner join kaf.tactivo_fijo af
				on af.id_activo_fijo = movaf.id_activo_fijo
				where movaf.id_movimiento = v_movimiento.id_movimiento
				and af.estado != 'alta') then

				update kaf.tmovimiento_af set
				respuesta = 'Activo fijo debe estar en estado de Alta, esta en: '||af.estado 
				from kaf.tactivo_fijo af
				where kaf.tmovimiento_af.id_movimiento = v_movimiento.id_movimiento
				and kaf.tmovimiento_af.id_activo_fijo = af.id_activo_fijo
				and af.estado != 'alta';

				return false;
			end if;

			return true;
		end if;
	
	else
		raise exception 'Esta validacion solo se aplica cuando el estado anterior es Borrador';
	end if;
	
	return true;

END
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;