CREATE OR REPLACE FUNCTION kaf.ftmp_generar_wf_proc_deprec (
)
RETURNS varchar AS
$body$
DECLARE

	v_rec 					record;
    v_id_proceso_macro      integer;
    v_codigo_tipo_proceso   varchar;
    v_num_tramite           varchar;
    v_id_proceso_wf         integer;
    v_id_estado_wf          integer;
    v_codigo_estado         varchar;
    v_cod_movimiento        varchar;
    v_id_gestion            integer;

BEGIN
  
	for v_rec in (select * from kaf.tmovimiento
    			where id_movimiento in (4845,4849,4848,4847,4844)) loop
                
		if not exists(select 1 from kaf.tmovimiento
        		where id_movimiento = v_rec.id_movimiento
                and id_proceso_wf is not null) then
        
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
            where mt.id_cat_movimiento = v_rec.id_cat_movimiento
            and tp.estado_reg = 'activo'
            and tp.inicio = 'si';

            if v_id_proceso_macro is null then
                raise exception 'El proceso de % no tiene asociado un Flujo de Aprobación. Revise la configuración',v_desc_movimiento;
            end if;

            --Obtencion de la gestion a partir de la fecha del movimiento
            select 
            id_gestion into v_id_gestion
            from param.tgestion
            where gestion = extract(year from (v_rec.fecha_mov)::date);

            if v_id_gestion is null then
                raise exception 'Gestión inexistente';
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
            1, 
            null::integer,
            null::varchar,
            v_id_gestion, 
            v_codigo_tipo_proceso, 
            NULL,
            NULL,
            'Activos Fijos: Depreciación',
            'S/N');                
                    
            update kaf.tmovimiento set
            id_proceso_wf = v_id_proceso_wf,
            id_estado_wf = v_id_estado_wf,
            num_tramite = v_num_tramite
            where id_movimiento = v_rec.id_movimiento;
            
        else
        	raise notice 'Nada. Tiene proceso WF';
        
        end if;
    	
    
    	
                
    end loop;
    
    return 'done';

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;