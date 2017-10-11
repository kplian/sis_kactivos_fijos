--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.f_get_af_cc (
  p_id_activo_fijo integer, 
  p_id_gestion integer,
  p_fecha_mov date
)
RETURNS SETOF record AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.f_get_af_cc
 DESCRIPCION:   Funcion que devuelve los centros de costo por activo fijo. El orde de prioridad es el siguiente:
 
 					1. por Activo Fijo (tabla kaf.ttipo_prorrateo)
                    2. del Cargo del Responsable del Activo Fijo (orga.tcargo_presupuesto)
                    3. por Proyecto del Activo Fijo
                    
 AUTOR: 		RCM
 FECHA:	        09/10/2017
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

   	
 ISSUE            FECHA:		      AUTOR       DESCRIPCION
 0                10/10/2017        RAC         Se aumenta contador  de filas
***************************************************************************/
DECLARE
  
	v_nombre_funcion   	text;
	v_resp				varchar;
    v_rec				record;
    v_fila				integer = 0;

BEGIN

	v_nombre_funcion = 'kaf.f_get_af_cc';
    
    --Prioridad 1: por Activo Fijo (kaf.ttipo_prorrateo)
    if exists (select 1 from kaf.ttipo_prorrateo
    			where id_activo_fijo = p_id_activo_fijo) then

		for v_rec in select
            cc.id_centro_costo, tp.id_ot, tp.factor,row_number()  over() 
            from kaf.ttipo_prorrateo tp
            inner join param.ttipo_cc tcc
            on tcc.id_tipo_cc = tp.id_tipo_cc
            left join param.tcentro_costo cc
            on cc.id_tipo_cc = tp.id_tipo_cc 
            and cc.id_gestion = p_id_gestion
            where tp.id_activo_fijo = p_id_activo_fijo loop
           
        	return next v_rec;
        end loop;
        
        return;

	--Prioridad 2: del Cargo del Responsable del Activo Fijo (orga.tcargo_presupuesto)            
    elsif exists(select 1
    			from kaf.tactivo_fijo af
    			inner join  orga.tuo_funcionario uofun
				on uofun.id_funcionario = af.id_funcionario
                inner join orga.tcargo car
                on car.id_cargo = uofun.id_cargo
                inner join orga.tcargo_presupuesto cp
                on cp.id_cargo = car.id_cargo
                and cp.id_gestion = p_id_gestion
                where af.id_activo_fijo = p_id_activo_fijo
                and uofun.estado_reg = 'activo'
                and uofun.tipo = 'oficial'
                and uofun.fecha_asignacion <= p_fecha_mov
                and (uofun.fecha_finalizacion is null or uofun.fecha_finalizacion >= p_fecha_mov)) then
                
		for v_rec in select cp.id_centro_costo, cp.id_ot, cp.porcentaje/100::numeric   , row_number()  over()
                    from kaf.tactivo_fijo af
                    inner join  orga.tuo_funcionario uofun
                    on uofun.id_funcionario = af.id_funcionario
                    inner join orga.tcargo car
                    on car.id_cargo = uofun.id_cargo
                    inner join orga.tcargo_presupuesto cp
                    on cp.id_cargo = car.id_cargo
                    and cp.id_gestion = p_id_gestion
                    where af.id_activo_fijo = p_id_activo_fijo
                    and uofun.estado_reg = 'activo'
                    and uofun.tipo = 'oficial'
                    and uofun.fecha_asignacion <= p_fecha_mov
                    and (uofun.fecha_finalizacion is null or uofun.fecha_finalizacion >= p_fecha_mov) loop
        	
            
			return next v_rec;
                    
        end loop;                
                
        return;
        
	--Prioridad 3: por Proyecto del Activo Fijo
    else
             
    	for v_rec in select
                    cc.id_centro_costo, tp.id_ot, tp.factor,row_number()  over()
                    from kaf.tactivo_fijo af
                    inner join kaf.ttipo_prorrateo tp
                    on tp.id_proyecto = af.id_proyecto
                    inner join param.ttipo_cc tcc
                    on tcc.id_tipo_cc = tp.id_tipo_cc
                    left join param.tcentro_costo cc
                    on cc.id_tipo_cc = tp.id_tipo_cc 
                    and cc.id_gestion = p_id_gestion 
                    where af.id_activo_fijo = p_id_activo_fijo loop
        	
    		return next v_rec;
        end loop;
       
    end if;
    
    

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
COST 100 ROWS 1000;