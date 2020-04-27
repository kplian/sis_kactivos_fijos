CREATE OR REPLACE FUNCTION kaf.f_insercion_movimiento (
  p_id_usuario integer,
  p_parametros public.hstore
)
RETURNS integer AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_insercion_movimiento
 DESCRIPCION:   Función para crear un nuevo movimiento
 AUTOR:         RCM
 FECHA:         03/08/2017
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #7     KAF       ETR           06/05/2019  RCM         Modificación consulta para inclusión de Activos Fijos en el detalle al registrar Depreciación
 #55    KAF       ETR           12/03/2020  RCM         Al crear alta registro por defecto de todos los activos fijos en estado registrado
 #59    KAF       ETR           07/04/2020  RCM         Controlar que no inserte activos fijos en el alta cuando viene de movimientos rápidos
***************************************************************************/
DECLARE

	v_id_movimiento 		integer;
    v_nombre_funcion		varchar;
    v_resp					varchar;
    v_id_subsistema         integer;
    v_id_responsable_depto  integer;
    v_id_periodo_subsistema integer;
    v_res                   varchar;
    v_id_proceso_macro      integer;
    v_codigo_tipo_proceso   varchar;
    v_num_tramite           varchar;
    v_id_proceso_wf         integer;
    v_id_estado_wf          integer;
    v_codigo_estado         varchar;
    v_cod_movimiento        varchar;
    v_desc_movimiento       varchar;
    v_id_gestion            integer;
    v_registros_mov         record;
    v_id_funcionario        integer;
    v_sw_reg_masivo         boolean;

BEGIN

    --Nombre de la función
    v_nombre_funcion = 'kaf.f_insercion_movimiento';

    --Inicialización de variables
    v_sw_reg_masivo = coalesce((p_parametros->'reg_masivo')::boolean,true);

    --Obtención del subsistema para posterior verificación de período abierto
    select id_subsistema into v_id_subsistema
    from segu.tsubsistema
    where codigo = 'KAF';

    --Obtiene el usuario responsable del depto.
    if not exists(select 1 from param.tdepto_usuario
          where id_depto = (p_parametros->'id_depto')::integer
          and cargo = 'responsable') then
        raise exception 'No es posible guardar el movimiento porque no se ha definido Responsable del Depto. de Activos Fijos';
    end if;

    select id_usuario into v_id_responsable_depto
    from param.tdepto_usuario
    where id_depto = (p_parametros->'id_depto')::integer
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

    --Verificación de período abierto
    select po_id_periodo_subsistema into v_id_periodo_subsistema
    from param.f_get_periodo_gestion((p_parametros->'fecha_mov')::date,v_id_subsistema);
    v_res = param.f_verifica_periodo_subsistema_abierto(v_id_periodo_subsistema);

    --Obtención del proceso de activos fijos
    select
    cat.codigo, cat.descripcion
    into
    v_cod_movimiento, v_desc_movimiento
    from param.tcatalogo cat
    where cat.id_catalogo = (p_parametros->'id_cat_movimiento')::integer;

    --------------------------
    --Obtiene el proceso macro
    --------------------------
    select
    pm.id_proceso_macro, tp.codigo
    into
    v_id_proceso_macro, v_codigo_tipo_proceso
    from kaf.tmovimiento_tipo mt
    inner join wf.tproceso_macro pm  on pm.id_proceso_macro =  mt.id_proceso_macro
    inner join wf.ttipo_proceso tp on tp.id_proceso_macro = pm.id_proceso_macro
    where mt.id_cat_movimiento = (p_parametros->'id_cat_movimiento')::integer
    and tp.estado_reg = 'activo'
    and tp.inicio = 'si';

    if v_id_proceso_macro is null then
        raise exception 'El proceso de % no tiene asociado un Flujo de Aprobación. Revise la configuración',v_desc_movimiento;
    end if;

    --Obtencion de la gestion a partir de la fecha del movimiento
    select
    id_gestion into v_id_gestion
    from param.tgestion
    where gestion = extract(year from (p_parametros->'fecha_mov')::date);

    if v_id_gestion is null then
        raise exception 'Gestión inexistente';
    end if;

    --Limpia dato funcionario
    v_id_funcionario = (p_parametros->'id_funcionario')::integer;
    if (p_parametros->'id_funcionario')::integer = -1 then
        v_id_funcionario = null;
    end if;

    ----------------------
    --Inicio tramite en WF
    ----------------------
    SELECT
    ps_num_tramite ,
    ps_id_proceso_wf ,
    ps_id_estado_wf ,
    ps_codigo_estado
    into
    v_num_tramite,
    v_id_proceso_wf,
    v_id_estado_wf,
    v_codigo_estado
    FROM wf.f_inicia_tramite(
    p_id_usuario,
    (p_parametros->'_id_usuario_ai')::integer,
    (p_parametros->'_nombre_usuario_ai')::varchar,
    v_id_gestion,
    v_codigo_tipo_proceso,
    NULL,
    NULL,
    'Activos Fijos: '||v_desc_movimiento,
    'S/N');

    ---------------------------
    -- CREACIÓN DEL MOVIMIENTO
    ---------------------------
    insert into kaf.tmovimiento(
        direccion,
        fecha_hasta,
        id_cat_movimiento,
        fecha_mov,
        id_depto,
        id_proceso_wf,
        id_estado_wf,
        glosa,
        id_funcionario,
        estado,
        id_oficina,
        estado_reg,
        num_tramite,
        id_usuario_ai,
        id_usuario_reg,
        fecha_reg,
        usuario_ai,
        fecha_mod,
        id_usuario_mod,
        id_responsable_depto,
        id_persona,
        codigo,
        id_deposito,
        id_depto_dest,
        id_deposito_dest,
        id_funcionario_dest,
        id_movimiento_motivo,
        prestamo,
        fecha_dev_prestamo
    ) values(
        (p_parametros->'direccion')::varchar,
        (p_parametros->'fecha_hasta')::date,
        (p_parametros->'id_cat_movimiento')::integer,
        (p_parametros->'fecha_mov')::date,
        (p_parametros->'id_depto')::integer,
        v_id_proceso_wf,
        v_id_estado_wf,
        (p_parametros->'glosa')::varchar,
        coalesce(v_id_funcionario,(p_parametros->'id_funcionario_dest')::integer),
        v_codigo_estado,
        (p_parametros->'id_oficina')::integer,
        'activo',
        v_num_tramite,
        (p_parametros->'_id_usuario_ai')::integer,
        p_id_usuario,
        now(),
        (p_parametros->'_nombre_usuario_ai')::varchar,
        null,
        null,
        v_id_responsable_depto,
        (p_parametros->'id_persona')::integer,
        (p_parametros->'codigo')::varchar,
        (p_parametros->'id_deposito')::integer,
        (p_parametros->'id_depto_dest')::integer,
        (p_parametros->'id_deposito_dest')::integer,
        (p_parametros->'id_funcionario_dest')::integer,
        (p_parametros->'id_movimiento_motivo')::integer,
        (p_parametros->'prestamo')::varchar,
        (p_parametros->'fecha_dev_prestamo')::date
    ) returning id_movimiento into v_id_movimiento;

    -------------------------------------
    -- LÓGICA POR PROCESO DE ACTIVO FIJO
    -------------------------------------
    if v_cod_movimiento in ('deprec','actua') then
        --DEPRECIACIÓN/ACTUALIZACIÓN: registro de todos los activos del departamento que les corresponda depreciar en el periodo solicitado
         for v_registros_mov in (
            --Inicio #7: Modificación consulta
            select distinct
            afij.id_activo_fijo,
            afij.id_cat_estado_fun
            from kaf.vactivo_fijo_valor vaf
            inner join kaf.tactivo_fijo afij
            on afij.id_activo_fijo = vaf.id_activo_fijo
            inner join kaf.tactivo_fijo_valores afv
            on afv.id_activo_fijo_valor = vaf.id_activo_fijo_valor
            where afij.id_depto = (p_parametros->'id_depto')::integer
            and afij.estado <> 'registrado'
            --Verifica la fecha inicio depreciación o en su defecto la fecha de última depreciación sean anterior a la fecha de depreciación
            and (
              (
                vaf.fecha_ult_dep is null and date_trunc('month',vaf.fecha_ini_dep) <= date_trunc('month',(p_parametros->'fecha_hasta')::date)
              )
              or
              (
                date_trunc('month',vaf.fecha_ult_dep) < date_trunc('month',(p_parametros->'fecha_hasta')::date)
              )
            )
            --Verifica que no tenga fecha fin
            and (
              afv.fecha_fin is null or date_trunc('month',afv.fecha_fin) <= date_trunc('month',(p_parametros->'fecha_hasta')::date)
            )
            --Verifica si está en baja q su fecha de baja sea anterior a la fecha de depreciación
            and (
              (afij.estado <> 'baja')
              or
              (afij.estado = 'baja' and date_trunc('month',afij.fecha_baja) < date_trunc('month',(p_parametros->'fecha_hasta')::date))
            )
            --Fin #7
        ) loop

            --RAC 29/03/2017: realiza validaciones sobre los activos que pueden relacionarse
            if kaf.f_validar_ins_mov_af(v_id_movimiento, v_registros_mov.id_activo_fijo, false)  then

                insert into kaf.tmovimiento_af(
                    id_movimiento,
                    id_activo_fijo,
                    id_cat_estado_fun,
                    estado_reg,
                    fecha_reg,
                    id_usuario_reg,
                    fecha_mod
                ) values(
                    v_id_movimiento,
                    v_registros_mov.id_activo_fijo,
                    v_registros_mov.id_cat_estado_fun,
                    'activo',
                    now(),
                    p_id_usuario,
                    null
                );

            end if;

        end loop;

    elsif v_cod_movimiento = 'transf' and v_sw_reg_masivo then
        --TRANSFERENCIA
        for v_registros_mov in (select
                                afij.id_activo_fijo,
                                afij.id_cat_estado_fun
                                from kaf.tactivo_fijo afij
                                where
                                afij.id_funcionario = (p_parametros->'id_funcionario')::integer
                                and  afij.estado = 'alta'
                                and  afij.en_deposito = 'no') loop

            if kaf.f_validar_ins_mov_af(v_id_movimiento, v_registros_mov.id_activo_fijo, false)  then

                --Registra todos los activos del funcionario origen
                insert into kaf.tmovimiento_af(
                    id_movimiento,
                    id_activo_fijo,
                    id_cat_estado_fun,
                    estado_reg,
                    fecha_reg,
                    id_usuario_reg,
                    fecha_mod
                )
                values(
                    v_id_movimiento,
                    v_registros_mov.id_activo_fijo,
                    v_registros_mov.id_cat_estado_fun,
                    'activo',
                    now(),
                    p_id_usuario,
                    null
                );

            end if;

        end loop;

    elsif v_cod_movimiento = 'devol' and v_sw_reg_masivo then

        --Actualiza el funcionario destino como el responsable del depto.
        update kaf.tmovimiento set
        id_funcionario_dest = v_id_responsable_depto
        where id_movimiento = v_id_movimiento;

        for v_registros_mov in (select
                                afij.id_activo_fijo,
                                afij.id_cat_estado_fun
                                from kaf.tactivo_fijo afij
                                where
                                afij.id_funcionario = (p_parametros->'id_funcionario')::integer
                                and  afij.estado = 'alta'
                                and  afij.en_deposito = 'no') loop

            if kaf.f_validar_ins_mov_af(v_id_movimiento, v_registros_mov.id_activo_fijo, false)  then

                --Registra todos los activos del funcionario origen
                insert into kaf.tmovimiento_af(
                    id_movimiento,
                    id_activo_fijo,
                    id_cat_estado_fun,
                    estado_reg,
                    fecha_reg,
                    id_usuario_reg,
                    fecha_mod
                )
                values(
                    v_id_movimiento,
                    v_registros_mov.id_activo_fijo,
                    v_registros_mov.id_cat_estado_fun,
                    'activo',
                    now(),
                    p_id_usuario,
                    null
                );

            end if;

        end loop;

    --Inicio #55
    elsif v_cod_movimiento = 'alta' then

        IF COALESCE((p_parametros->'mov_rapido')::varchar, 'no') = 'no' THEN --#59

            INSERT INTO kaf.tmovimiento_af(
                id_movimiento,
                id_activo_fijo,
                id_cat_estado_fun,
                estado_reg,
                fecha_reg,
                id_usuario_reg,
                fecha_mod
            )
            SELECT
            v_id_movimiento,
            af.id_activo_fijo,
            af.id_cat_estado_fun,
            'activo',
            now(),
            p_id_usuario,
            NULL
            FROM kaf.tactivo_fijo af
            WHERE af.estado = 'registrado';

        END IF; --#59
    --Fin #55

    end if;

    ------------
	--Respuesta
    ------------
    return v_id_movimiento;

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