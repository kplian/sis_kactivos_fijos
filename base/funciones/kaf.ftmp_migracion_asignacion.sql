CREATE OR REPLACE FUNCTION kaf.ftmp_migracion_asignacion (
)
RETURNS varchar AS
$body$
DECLARE

    v_rec record;
  v_rec1 record;
    v_sql varchar;
    
  v_nro_requerimiento       integer;
    v_parametros            record;
    v_id_requerimiento      integer;
    v_resp                  varchar;
    v_nombre_funcion        text;
    v_mensaje_error         text;
    v_id_movimiento         integer;
  v_id_responsable_depto    integer;
  v_id_gestion          integer;
  v_codigo_tipo_proceso varchar;
  v_id_proceso_macro        integer;
  v_id_proceso_wf           integer;
  v_id_estado_wf            integer;
  v_codigo_estado           varchar;
  v_num_tramite         varchar;
  v_sw                  boolean;

BEGIN
    
        v_sw = true;
   
    select pm.id_proceso_macro, tp.codigo
    into v_id_proceso_macro, v_codigo_tipo_proceso
    from kaf.tmovimiento_tipo mt
    inner join wf.tproceso_macro pm 
    on pm.id_proceso_macro =  mt.id_proceso_macro
    inner join wf.ttipo_proceso tp
    on tp.id_proceso_macro = pm.id_proceso_macro
    where mt.id_cat_movimiento = 79
    and tp.estado_reg = 'activo'
    and tp.inicio = 'si';

    if v_id_proceso_macro is null then
       raise exception 'No existe un proceso inicial para el proceso macro indicado (Revise la configuración)';
    end if;

    --Obtencion de la gestion a partir de la fecha del movimiento
    select id_gestion
    into v_id_gestion
    from param.tgestion
    where gestion = extract(year from now());

    if v_id_gestion is null then
        raise exception 'No existe la gestion abierta';
    end if;
    
    
    v_sql = 'select distinct a."ID_FUNCIONARIO" as id_funcionario from kaf.tmp_migracion a
            where a."ID_FUNCIONARIO" is not null';    
    for v_rec in execute(v_sql) loop
--      raise exception 'id_funcionario: %',v_rec.id_funcionario;
        v_sw=true;
        for v_rec1 in execute('select
                                                        aa."ID_FUNCIONARIO" as empleado,af.id_activo_fijo,
                            af.id_depto, af.id_oficina,af.ubicacion,
                            af.id_funcionario as resp_depto,
                                                        upper(fun.desc_funcionario2) as desc_funcionario2
                                                        from kaf.tmp_migracion aa
                                                        inner join kaf.tactivo_fijo af
                            on af.id_mig = aa."ID"
                                                        inner join orga.vfuncionario fun
                                                        on fun.id_funcionario = aa."ID_FUNCIONARIO"
                            where aa."ID_FUNCIONARIO" = '||v_rec.id_funcionario) loop
                               
            --CABECERA MOVIMIENTO
            if v_sw then
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
                1, 
                null,
                null,
                v_id_gestion, 
                v_codigo_tipo_proceso, 
                NULL,
                NULL,
                'Asignacion Activo Fijo a: '||v_rec1.desc_funcionario2,
                'S/N');

                --Sentencia de la insercion
                insert into kaf.tmovimiento(
                direccion,
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
                id_usuario_reg,
                fecha_reg,
                id_responsable_depto
                ) values(
                v_rec1.ubicacion,
                79,
                now(),
                v_rec1.id_depto,
                v_id_proceso_wf,
                v_id_estado_wf,
                'Asignacion de Activos Fijos a: '||v_rec1.desc_funcionario2||', por migracion de sistema',
                v_rec.id_funcionario,
                v_codigo_estado,
                v_rec1.id_oficina,
                'activo',
                v_num_tramite,
                1,
                now(),
                                4
                )RETURNING id_movimiento into v_id_movimiento;
                v_sw = false;
            end if;
            
            --DETALLE
            insert into kaf.tmovimiento_af(
            id_movimiento,
            id_activo_fijo,
            id_cat_estado_fun,
            estado_reg,
            fecha_reg,
            id_usuario_reg
            ) values(
            v_id_movimiento,
            v_rec1.id_activo_fijo,
            90,
            'activo',
            now(),
            1
            );

        end loop;

    end loop;

    return 'done';  

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;