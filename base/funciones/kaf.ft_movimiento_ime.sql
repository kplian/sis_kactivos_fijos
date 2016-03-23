CREATE OR REPLACE FUNCTION kaf.ft_movimiento_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento'
 AUTOR: 		 (admin)
 FECHA:	        22-10-2015 20:42:41
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_movimiento			integer;
    v_sql					varchar;
    v_rec					record;
    v_id_responsable_depto	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		22-10-2015 20:42:41
	***********************************/

	if(p_transaccion='SKA_MOV_INS')then
					
        begin

        	--Obtiene el usuario responsable del depto.
        	if not exists(select 1 from param.tdepto_usuario
        					where id_depto = v_parametros.id_depto
        					and cargo = 'responsable') then
        		raise exception 'No es posible guardar el movimiento porque no se ha definido Responsable del Depto.';
        	end if;

        	select id_usuario into v_id_responsable_depto
        	from param.tdepto_usuario
        	where id_depto = v_parametros.id_depto
        	and cargo = 'responsable' limit 1;

        	--Sentencia de la insercion
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
			id_persona
          	) values(
			v_parametros.direccion,
			v_parametros.fecha_hasta,
			v_parametros.id_cat_movimiento,
			v_parametros.fecha_mov,
			v_parametros.id_depto,
			v_parametros.id_proceso_wf,
			v_parametros.id_estado_wf,
			v_parametros.glosa,
			v_parametros.id_funcionario,
			'borrador',
			v_parametros.id_oficina,
			'activo',
			v_parametros.num_tramite,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			now(),
			v_parametros._nombre_usuario_ai,
			null,
			null,
			v_id_responsable_depto,
			v_parametros.id_persona
			)RETURNING id_movimiento into v_id_movimiento;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimiento de Activos Fijos almacenado(a) con exito (id_movimiento'||v_id_movimiento||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento',v_id_movimiento::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		22-10-2015 20:42:41
	***********************************/

	elsif(p_transaccion='SKA_MOV_MOD')then

		begin

			--Obtiene el responsable de depto en base a los ultimos cambios
			select id_usuario into v_id_responsable_depto
        	from param.tdepto_usuario
        	where id_depto = v_parametros.id_depto
        	and cargo = 'responsable' limit 1;

        	if v_id_responsable_depto is not null then
        		update kaf.tmovimiento set
        		id_responsable_depto = v_id_responsable_depto
        		where id_movimiento=v_parametros.id_movimiento;
        	end if;

			--Sentencia de la modificacion
			update kaf.tmovimiento set
			direccion = v_parametros.direccion,
			fecha_hasta = v_parametros.fecha_hasta,
			id_cat_movimiento = v_parametros.id_cat_movimiento,
			fecha_mov = v_parametros.fecha_mov,
			id_depto = v_parametros.id_depto,
			id_proceso_wf = v_parametros.id_proceso_wf,
			id_estado_wf = v_parametros.id_estado_wf,
			glosa = v_parametros.glosa,
			id_funcionario = v_parametros.id_funcionario,
			estado = v_parametros.estado,
			id_oficina = v_parametros.id_oficina,
			num_tramite = v_parametros.num_tramite,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			id_persona = v_parametros.id_persona
			where id_movimiento=v_parametros.id_movimiento;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimiento de Activos Fijos modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento',v_parametros.id_movimiento::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOV_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		22-10-2015 20:42:41
	***********************************/

	elsif(p_transaccion='SKA_MOV_ELI')then

		begin
        	--Verifica existencia del movimiento
            if not exists(select 1 from kaf.tmovimiento
            			where id_movimiento = v_parametros.id_movimiento) then
            	raise exception 'Movimiento no encontrado';
            end if;
            
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento
            where id_movimiento=v_parametros.id_movimiento;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimiento de Activos Fijos eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento',v_parametros.id_movimiento::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
    /*********************************    
 	#TRANSACCION:  'SKA_MOVREL_DAT'
 	#DESCRIPCION:	REllena masivamente el detalle del movimiento con los activos fijos enviados
 	#AUTOR:			RCM
 	#FECHA:			14/01/2016
	***********************************/

	elsif(p_transaccion='SKA_MOVREL_DAT')then

		begin
        	--Verifica existencia del movimiento
            if not exists(select 1 from kaf.tmovimiento
            			where id_movimiento = v_parametros.id_movimiento) then
            	raise exception 'Movimiento no encontrado';
            end if;
            
            --Obtiene datos del movimiento
            select
            mov.id_movimiento, cat.codigo as tipo_mov
            into v_rec
            from kaf.tmovimiento mov
            inner join param.tcatalogo cat
            on cat.id_catalogo = mov.id_cat_movimiento
            where id_movimiento = v_parametros.id_movimiento;
            
            --Generación de registros en el detalle del movimiento por tipo de movimiento
            v_sql = 'insert into kaf.tmovimiento_af(
                id_usuario_reg,fecha_reg,estado_reg,id_movimiento,id_activo_fijo,
                id_cat_estado_fun,id_depto,id_funcionario,id_persona,vida_util,monto_vigente,
                estado
                )
                select '||
                p_id_usuario||','''|| now()||''',''activo'','||v_rec.id_movimiento||',af.id_activo_fijo,
                af.id_cat_estado_fun,af.id_depto,af.id_funcionario,af.id_persona,af.vida_util_original,
                af.monto_vigente,''borrador''
                from kaf.tactivo_fijo af
                where af.id_activo_fijo in (' ||v_parametros.ids||')
                and af.id_activo_fijo not in (select id_activo_fijo
                							from kaf.tmovimiento_af
                                            where id_movimiento = '||v_rec.id_movimiento||')';
            
            execute v_sql;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos fijos registrados masivamente el el movimiento'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento',v_parametros.id_movimiento::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'ids',v_parametros.ids);
              
            --Devuelve la respuesta
            return v_resp;

		end;
         
	else
     
    	raise exception 'Transaccion inexistente: %',p_transaccion;

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
COST 100;