CREATE OR REPLACE FUNCTION kaf.f_movimiento_aprobacion (
  p_id_usuario integer,
  p_id_proceso_wf integer,
  p_id_estado_anterior integer,
  p_id_tipo_estado_actual integer
)
RETURNS boolean AS
$body$
DECLARE

	v_estado 					varchar;
	v_movimiento 				record;
	v_movimiento_af 			record;
	v_rec 						record;
	v_monto_inc_dec_real		numeric;
	v_vida_util_inc_dec_real	integer;

BEGIN

	--Verificar que sea el estado final para aplicar los cambios
	select codigo
	into v_estado
	from wf.ttipo_estado
	where id_tipo_estado = p_id_tipo_estado_actual;



	--Obtiene datos del movimiento
	select
	mov.id_movimiento, mov.id_cat_movimiento,
	cat.codigo as movimiento, mov.fecha_mov
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
				monto_vigente,vida_util,estado,principal,monto_rescate,id_movimiento_af,
				monto_vigente_orig_100
				)
				select
				p_id_usuario,now(),'activo',
				af.id_activo_fijo,af.monto_compra,af.vida_util_original,af.fecha_ini_dep,
				0,0,0,
				af.monto_compra,af.vida_util_original,'activo','si',af.monto_rescate,movaf.id_movimiento_af,
				af.monto_compra_orig_100
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
			inner join kaf.tmovimiento mov
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
			--RCM 12/06/2017: Aplicación de lógica en base a nuevo diagrama de flujo
			for v_movimiento_af in (with activo_fijo_vigente as (
										select * from kaf.f_activo_fijo_vigente() as
										(
											id_activo_fijo integer,
											monto_vigente_real_af numeric,
											vida_util_real_af integer,
											fecha_ult_dep_real_af date,
											depreciacion_acum_real_af numeric,
											depreciacion_per_real_af numeric,
											monto_actualiz_real_af numeric,
											id_moneda integer,
											id_moneda_dep integer
										)
									)
									select * from kaf.tmovimiento_af maf
									inner join activo_fijo_vigente av
									on av.id_activo_fijo = maf.id_activo_fijo
									where maf.id_movimiento = v_movimiento.id_movimiento) loop

				--Obtener el valor real de la revalorización
				v_monto_inc_dec_real = v_movimiento_af.monto_vigente_real_af - v_movimiento_af.importe;
				v_vida_util_inc_dec_real = v_movimiento_af.vida_util_real_af - v_movimiento_af.vida_util;

				if v_monto_inc_dec_real = 0 and v_vida_util_inc_dec_real = 0 then
					raise exception 'Inc/Dec de la revalorización es cero. Nada que hacer.';
				end if;

				--Caso en función del valor vigente
				if v_movimiento_af.monto_vigente_real_af <= 1 then
					--Caso 1

				else
					if v_monto_inc_dec_real > 0 then
						--Caso 2

						--Finalizar AFV actual colocando fecha_fin
						update kaf.tactivo_fijo_valores set
						fecha_fin = v_movimiento.fecha_mov
						where id_movimiento_af = v_movimiento_af.id_movimiento_af
						and fecha_fin is null;

						--Replicar AFV con nueva vida útil
						insert into kaf.tactivo_fijo_valores(
							id_usuario_reg,
							fecha_reg,
							estado_reg,
							id_activo_fijo,
							monto_vigente_orig,
							vida_util_orig,
							fecha_ini_dep,
							depreciacion_mes,
							depreciacion_per,
							depreciacion_acum,
							monto_vigente,
							vida_util ,
							tipo,
							estado,
							principal,
							monto_rescate,
							id_movimiento_af ,
							codigo,
							id_moneda_dep ,
							id_moneda ,
							fecha_inicio,
							deducible,
							id_activo_fijo_valor_original,
							monto_vigente_orig_100
						)
						select
						p_id_usuario,
						now(),
						'activo',
						id_activo_fijo,
						monto_vigente_orig,
						v_vida_util_inc_dec_real,
						v_movimiento.fecha_mov,
						0,
						0,
						0,
						monto_vigente,
						v_vida_util_inc_dec_real,
						tipo,
						estado,
						principal,
						monto_rescate,
						v_movimiento_af.id_movimiento_af,
						codigo||'-G',
						id_moneda_dep,
						id_moneda,
						v_movimiento.fecha_mov,
						deducible,
						id_activo_fijo_valor,
						monto_vigente_orig
						from kaf.activo_fijo_valores
						where id_movimiento_af = v_movimiento_af.id_movimiento_af
						and fecha_fin is null;

						--Creación de AFV para la revalorización
						insert into kaf.tactivo_fijo_valores(
						id_usuario_reg,
						fecha_reg,
						estado_reg,
						id_activo_fijo,
						monto_vigente_orig,
						vida_util_orig,
						fecha_ini_dep,
						depreciacion_mes,
						depreciacion_per,
						depreciacion_acum,
						monto_vigente,
						vida_util,
						tipo,
						estado,
						principal,
						monto_rescate,
						id_movimiento_af,
						id_moneda_dep,
						id_moneda,
						fecha_inicio,
						deducible,
						monto_vigente_orig_100
						) values(
						p_id_usuario,
						now(),
						'activo',
						v_movimiento_af.id_activo_fijo,
						v_monto_inc_dec_real,
						v_vida_util_inc_dec_real,
						v_movimiento.fecha_mov,
						0,
						0,
						0,
						v_monto_inc_dec_real,
						v_vida_util_inc_dec_real,
						v_movimiento.movimiento,
						'activo',
						'si',
						1,
						v_movimiento_af.id_movimiento_af,
						1,
						1,
						v_movimiento.fecha_mov,
						'si',
						v_monto_inc_dec_real
						);


					else
						--Caso 3

					end if;

				end if;


			end loop;


			--Crea el registro de importes
			insert into kaf.tactivo_fijo_valores(
			id_usuario_reg, fecha_reg,estado_reg,
			id_activo_fijo,monto_vigente_orig,vida_util_orig,fecha_ini_dep,
			depreciacion_mes,depreciacion_per,depreciacion_acum,
			monto_vigente,vida_util,estado,principal,monto_rescate,id_movimiento_af,
			monto_vigente_orig_100
			)
			select
			p_id_usuario,now(),'activo',
			af.id_activo_fijo,af.monto_compra,af.vida_util_original,af.fecha_ini_dep,
			0,0,0,
			moavaf.importe,movaf.vida_util,'activo','si',af.monto_rescate,movaf.id_movimiento_af,
			af.monto_compra
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

		elsif v_movimiento.movimiento = 'retiro' then
			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			estado = 'retiro',
			fecha_baja = mov.fecha_mov
			from kaf.tmovimiento_af movaf
			inner join kaf.tmovimiento mov
			on mov.id_movimiento = movaf.id_movimiento
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;


			return true;

		elsif v_movimiento.movimiento = 'transito' then
			--Actualiza estado de activo fijo
			update kaf.tactivo_fijo set
			estado = 'transito',
			fecha_baja = mov.fecha_mov
			from kaf.tmovimiento_af movaf
			inner join kaf.tmovimiento mov
			on mov.id_movimiento = movaf.id_movimiento
			where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
			and movaf.id_movimiento = v_movimiento.id_movimiento;


			return true;
		end if;

	else
		return true;
	end if;

--	raise exception 'FFFF: %',v_movimiento.movimiento;
	return true;

END
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;