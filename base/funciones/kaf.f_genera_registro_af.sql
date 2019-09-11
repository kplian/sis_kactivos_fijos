CREATE OR REPLACE FUNCTION kaf.f_genera_registro_af (
  p_id_usuario integer,
  p_id_preingreso integer
)
RETURNS varchar AS
$body$
/*
Autor: RCM  (KPLIAN)
Fecha: 05/08/2017
Descripción: GENERACION DE REGISTROS EN ACTIVOS FIJOS PROVINIENTES DEL SISTEMA DE ADQUISICIONES
*/
DECLARE

    v_sql varchar;
    v_rec record;
    v_vida_util integer;
    v_id_presupuesto integer;
    v_id_cat_estado_fun integer;
    v_id_cat_estado_compra integer;
    v_rec_af record;
    v_id_activo_fijo integer;
    v_id_deposito integer;
    v_id_unidad_medida integer;
    v_id_responsable_depto integer;
    v_id_oficina integer;

BEGIN

  --Estado funcional
  select cat.id_catalogo
  into v_id_cat_estado_fun
  from param.tcatalogo cat
  inner join param.tcatalogo_tipo ctip
  on ctip.id_catalogo_tipo = cat.id_catalogo_tipo
  where ctip.tabla = 'tactivo_fijo__id_cat_estado_fun'
  and cat.descripcion = 'bueno';

  --Estado compra
  select cat.id_catalogo
  into v_id_cat_estado_compra
  from param.tcatalogo cat
  inner join param.tcatalogo_tipo ctip
  on ctip.id_catalogo_tipo = cat.id_catalogo_tipo
  where ctip.tabla = 'tactivo_fijo__id_cat_estado_compra'
  and cat.codigo = 'nuevo';

  --Unidad Medida
  select id_unidad_medida
  into v_id_unidad_medida
  from param.tunidad_medida
  where codigo = 'Und.';

  for v_rec in select
               cot.fecha_adju,
               pdet.precio_compra,
               ping.id_moneda,
               pdet.cantidad_det::integer,
               pdet.id_depto,
               pdet.id_clasificacion,
               pdet.observaciones,
               cot.numero_oc,
               cot.id_cotizacion,
               pdet.id_cotizacion_det,
               sol.id_solicitud,
               cc.id_centro_costo,
               cc.id_ep,
               cc.id_uo,
               cc.id_gestion,
               cg.desc_ingas,
               pdet.nombre,
               pdet.descripcion,
               pdet.precio_compra_87,
               pdet.id_lugar,
               pdet.ubicacion,
               pdet.c31,
               pdet.fecha_conformidad,
               dep.codigo,
               pdet.fecha_compra,
               cot.id_proveedor,
               dep.id_depto,
               pdet.id_preingreso_det
        from alm.tpreingreso ping
            inner join alm.tpreingreso_det pdet on pdet.id_preingreso = ping.id_preingreso
            inner join adq.tcotizacion_det  cd on cd.id_cotizacion_det = pdet.id_cotizacion_det
            inner join adq.tsolicitud_det sdet on sdet.id_solicitud_det =cd.id_solicitud_det
            inner join param.tconcepto_ingas cg on cg.id_concepto_ingas = sdet.id_concepto_ingas
            inner join adq.tcotizacion cot on cot.id_cotizacion = cd.id_cotizacion
            inner join adq.tproceso_compra pro on pro.id_proceso_compra = cot.id_proceso_compra
            inner join adq.tsolicitud sol on sol.id_solicitud = pro.id_solicitud
            inner join param.tcentro_costo cc on cc.id_centro_costo = sdet.id_centro_costo
            left join param.tdepto dep on dep.id_depto = pdet.id_depto
            where ping.id_preingreso  = p_id_preingreso
            and pdet.sw_generar = 'si'
            and pdet.estado = 'mod'
            and pdet.estado_reg = 'activo' loop

        --Vida útil
        select vida_util
        into v_vida_util
        from kaf.tclasificacion
        where id_clasificacion = v_rec.id_clasificacion;

        --Deposito
        if not exists(select 1
                    from kaf.tdeposito
                    where id_depto = v_rec.id_depto) then
            raise exception 'No existe depósito para el Departamento ';
        end if;
        select id_deposito into v_id_deposito
        from kaf.tdeposito
        where id_depto = v_rec.id_depto;



        --Obtener la ep
        /*select p.id_presupuesto
        into v_id_presupuesto
        from presto.tpr_parametro par
        inner join presto.tpr_presupuesto p
        on p.id_parametro = par.id_parametro
        where par.id_gestion = v_rec.id_gestion
        and p.id_fina_regi_prog_proy_acti = v_rec.id_ep
        and p.id_unidad_organizacional = v_rec.id_uo;*/

        --Obtiene el usuario responsable del depto.
        if not exists(select 1 from param.tdepto_usuario
              where id_depto = v_rec.id_depto
              and cargo = 'responsable') then
            raise exception 'No es posible guardar el movimiento porque no se ha definido Responsable del Depto. de Activos Fijos';
        end if;

        select id_usuario into v_id_responsable_depto
        from param.tdepto_usuario
        where id_depto = v_rec.id_depto
        and cargo = 'responsable' limit 1;

        if not exists(select 1
                    from segu.tusuario usu
                    inner join orga.vfuncionario_persona fun
                    on fun.id_persona = usu.id_persona
                    where usu.id_usuario = v_id_responsable_depto
                    ) then
            raise exception 'El usuario responsable del Dpto. no está registrado como funcionario';
        end if;

        select fun.id_funcionario
        into v_id_responsable_depto
        from segu.tusuario usu
        inner join orga.vfuncionario_persona fun
        on fun.id_persona = usu.id_persona
        where usu.id_usuario = v_id_responsable_depto;

        --Oficina del responsable
        if not exists(select 1
                      from orga.tuo_funcionario uof
                      inner join orga.tcargo car
                      on car.id_cargo = uof.id_cargo
                      where uof.id_funcionario = v_id_responsable_depto
                      and uof.fecha_asignacion <= now()
                      and coalesce(uof.fecha_finalizacion, now())>=now()
                      and uof.estado_reg = 'activo'
                      and uof.tipo = 'oficial') then
        end if;

        select car.id_oficina
        into v_id_oficina
        from orga.tuo_funcionario uof
        inner join orga.tcargo car
        on car.id_cargo = uof.id_cargo
        where uof.id_funcionario = v_id_responsable_depto
        and uof.fecha_asignacion <= now()
        and coalesce(uof.fecha_finalizacion, now())>=now()
        and uof.estado_reg = 'activo'
        and uof.tipo = 'oficial';

        --Inserción de la cantidad definida de activos fijos
        for v_i in 1..v_rec.cantidad_det::integer loop

          select
          null as id_persona, --ok
          0 as cantidad_revaloriz, --ok
          v_rec.id_proveedor as id_proveedor, --ok
          v_rec.fecha_compra as fecha_compra, --ok
          v_id_cat_estado_fun as id_cat_estado_fun, --ok
          v_rec.ubicacion as ubicacion, --ok
          null as documento, --ok
          v_rec.observaciones as observaciones, --ok
          1 as monto_rescate, --ok
          v_rec.nombre as denominacion, --ok
          v_id_responsable_depto as id_funcionario, --ok
          v_id_deposito as id_deposito, --ok
          v_rec.precio_compra_87 as monto_compra_orig, --ok
          v_rec.precio_compra_87 as monto_compra,
          v_rec.id_moneda as id_moneda, --ok
          v_rec.descripcion as descripcion, --ok
          v_rec.id_moneda as id_moneda_orig, --ok
          v_rec.fecha_conformidad as fecha_ini_dep, --ok
          v_id_cat_estado_compra as id_cat_estado_compra, --ok
          v_vida_util as vida_util_original, --ok
          'registrado' as estado, --ok
          v_rec.id_clasificacion as id_clasificacion, --ok
          v_id_oficina as id_oficina, --ok
          v_rec.id_depto as id_depto, --ok
          p_id_usuario as id_usuario_reg, --ok
          null as usuario_ai, --ok
          null as id_usuario_ai, --ok
          null as id_usuario_mod, --ok
          'si' as en_deposito, --ok
          null as codigo_ant, --ok
          null as marca, --ok
          null as nro_serie, --ok
          v_id_unidad_medida as id_unidad_medida, --ok
          v_rec.cantidad_det as cantidad_af, --ok
          v_rec.precio_compra as monto_compra_orig_100, --ok
          v_rec.c31 as nro_cbte_asociado,
          null as fecha_cbte_asociado,
          v_rec.id_cotizacion_det as id_cotizacion_det,
          v_rec.id_preingreso_det as id_preingreso_det
          into v_rec_af;

          --Inserción del registro
          v_id_activo_fijo = kaf.f_insercion_af(p_id_usuario, hstore(v_rec_af));

        end loop;

    end loop;
raise 'paso';
    return 'Hecho';

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;