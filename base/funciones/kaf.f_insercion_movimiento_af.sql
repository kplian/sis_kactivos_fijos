CREATE OR REPLACE FUNCTION kaf.f_insercion_movimiento_af (
  p_id_usuario integer,
  p_parametros public.hstore
)
RETURNS integer AS
$body$
/*
Autor: RCM
Fecha: 03/08/2017
Descripción: Función para crear un nuevo movimiento
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           27/05/2019  RCM         Distribución de valores, se añade update para guardar valor actualizado y dep. acumulada
***************************************************************************
*/
DECLARE

    v_nombre_funcion		varchar;
    v_resp					varchar;
    v_registros             record;
    v_id_cat_estado_fun     integer;
    v_id_movimiento_af      integer;
    v_aux                   record;
    v_id_moneda_base        integer;
    --Inicio #2
    v_monto_actualiz        numeric;
    v_depreciacion_acum     numeric;
    v_id_moneda_mov_esp     integer;
    --Fin #2

BEGIN

    --Nombre de la función
    v_nombre_funcion = 'kaf.f_insercion_movimiento_af';

    select
    mov.estado,
    mov.codigo,
    cat.codigo as codigo_movimiento,
    mov.id_depto
    into
    v_registros
    from kaf.tmovimiento mov
    inner join  param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
    where mov.id_movimiento = (p_parametros->'id_movimiento')::integer;


    if not kaf.f_validar_ins_mov_af((p_parametros->'id_movimiento')::integer,(p_parametros->'id_activo_fijo')::integer) then
       raise exception 'Error al validar activo fijo';
    end if;

    if v_registros.estado != 'borrador' THEN
       raise exception 'Solo puede insertar activos en movimientos en borrador';
    end if;

    --Obtiene estado funcional del activo fijo
    select
    id_cat_estado_fun
    into
    v_id_cat_estado_fun
    from kaf.tactivo_fijo
    where id_activo_fijo = (p_parametros->'id_activo_fijo')::integer;

    --Verificamos que el activo no esté duplicado
    if exists(select 1
            from kaf.tmovimiento_af maf
            where maf.id_movimiento = (p_parametros->'id_movimiento')::integer
            and  maf.id_activo_fijo = (p_parametros->'id_activo_fijo')::integer
            and maf.estado_reg = 'activo') then

        for v_aux in select * from kaf.tmovimiento_af maf
            where maf.id_movimiento = (p_parametros->'id_movimiento')::integer loop
            raise notice '%',v_aux.id_activo_fijo;
        end loop;

         raise exception 'El activo ya se encuentra registrado en el movimiento actual';
    end if;

    --Se obtiene la moneda base
    v_id_moneda_base = param.f_get_moneda_base();

    --Inserción del registro
    INSERT INTO kaf.tmovimiento_af(
        id_movimiento,
        id_activo_fijo,
        id_cat_estado_fun,
        id_movimiento_motivo,
        estado_reg,
        importe,
        vida_util,
        fecha_reg,
        usuario_ai,
        id_usuario_reg,
        id_usuario_ai,
        id_usuario_mod,
        fecha_mod,
        depreciacion_acum,
        id_moneda,
        importe_ant,
        vida_util_ant
    ) VALUES(
        (p_parametros->'id_movimiento')::integer,
        (p_parametros->'id_activo_fijo')::integer,
        v_id_cat_estado_fun,
        (p_parametros->'id_movimiento_motivo')::integer,
        'activo',
        (p_parametros->'importe')::numeric,
        (p_parametros->'vida_util')::integer,
        now(),
        (p_parametros->'_nombre_usuario_ai')::varchar,
        p_id_usuario,
        (p_parametros->'_id_usuario_ai')::integer,
        NULL,
        NULL,
        (p_parametros->'depreciacion_acum')::numeric,
        v_id_moneda_base,
        (p_parametros->'importe_ant')::numeric,
        (p_parametros->'vida_util_ant')::integer
    ) RETURNING id_movimiento_af into v_id_movimiento_af;

    --Inicio #2: Si es movimiento de Distribución de Valores obtiene y guarda los valores actuales del activo original
    IF v_registros.codigo_movimiento = 'dval' THEN

        --Obtención de la moneda parametrizada para los movimientos especiales
        select
        id_moneda
        into
        v_id_moneda_mov_esp
        from param.tmoneda
        where lower(codigo) = lower(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

        if coalesce(v_id_moneda_mov_esp, 0) = 0 then
            raise exception 'No está parametrizada la variable global para definir la Moneda para la Distribución de Valores (kaf_mov_especial_moneda)';
        end if;

        --Obtención del valor actualizado y la depreciación acumulada
        WITH tult_dep AS (
            SELECT
            afv.id_activo_fijo,
            MAX(mdep.fecha) AS fecha_max
            FROM kaf.tmovimiento_af_dep mdep
            INNER JOIN kaf.tactivo_fijo_valores afv
            ON afv.id_activo_fijo_valor = mdep.id_activo_fijo_valor
            GROUP BY afv.id_activo_fijo
        )
        SELECT
        mdep.monto_actualiz, mdep.depreciacion_acum
        INTO
        v_monto_actualiz, v_depreciacion_acum
        FROM kaf.tactivo_fijo_valores  afv
        INNER JOIN tult_dep dult
        ON dult.id_activo_fijo = afv.id_activo_fijo
        INNER JOIN kaf.tmovimiento_af_dep mdep
        ON mdep.id_activo_fijo_valor = afv.id_activo_fijo_valor
        AND mdep.fecha = dult.fecha_max
        WHERE afv.id_activo_fijo = (p_parametros->'id_activo_fijo')::integer
        AND mdep.id_moneda = v_id_moneda_mov_esp;

        --Actualización del registro
        UPDATE kaf.tmovimiento_af SET
        importe = v_monto_actualiz,
        depreciacion_acum = v_depreciacion_acum,
        id_moneda = v_id_moneda_mov_esp,
        importe_ant = null
        WHERE id_movimiento_af = v_id_movimiento_af;

    END IF;
    --Fin #2

    ------------
	--Respuesta
    ------------
    return v_id_movimiento_af;

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