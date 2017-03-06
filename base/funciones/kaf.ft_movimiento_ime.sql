--------------- SQL ---------------

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
    v_id_gestion			integer;
    v_codigo_tipo_proceso	varchar;
    v_id_proceso_macro		integer;
    v_id_proceso_wf			integer;
    v_id_estado_wf			integer;
    v_codigo_estado			varchar;
    v_num_tramite			varchar;
    v_acceso_directo        varchar;
    v_clase                 varchar;
    v_parametros_ad         varchar;
    v_tipo_noti             varchar;
    v_titulo                varchar;
    v_movimiento            record;
    v_id_tipo_estado        integer;
    v_pedir_obs             varchar;
    v_codigo_estado_siguiente   varchar;
    v_id_depto              integer;
    v_obs                   varchar;
    v_id_estado_actual      integer;
    v_id_funcionario        integer;
    v_id_usuario_reg        integer;
    v_id_estado_wf_ant      integer;
    v_cod_movimiento        varchar;
    v_codigo_estado_anterior    varchar;
			    
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
        	where mt.id_cat_movimiento = v_parametros.id_cat_movimiento
        	      and tp.estado_reg = 'activo'
        	      and tp.inicio = 'si';

        	if v_id_proceso_macro is null then
	           raise exception 'No existe un proceso inicial para el proceso macro indicado (Revise la configuración)';
	        end if;

	        --Obtencion de la gestion a partir de la fecha del movimiento
	        select 
                id_gestion
	        into 
                 v_id_gestion
	        from param.tgestion
	        where gestion = extract(year from v_parametros.fecha_mov);

	        if v_id_gestion is null then
	        	raise exception 'No existe la gestion abierta';
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
            v_parametros._id_usuario_ai,
            v_parametros._nombre_usuario_ai,
            v_id_gestion, 
            v_codigo_tipo_proceso, 
            NULL,
            NULL,
            'Movimiento Activo Fijo',
            'S/N');

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
                id_persona,
                codigo,
                id_deposito,
                id_depto_dest,
                id_deposito_dest,
                id_funcionario_dest,
                id_movimiento_motivo
          	) values(
                v_parametros.direccion,
                v_parametros.fecha_hasta,
                v_parametros.id_cat_movimiento,
                v_parametros.fecha_mov,
                v_parametros.id_depto,
                v_id_proceso_wf,
                v_id_estado_wf,
                v_parametros.glosa,
                v_parametros.id_funcionario,
                v_codigo_estado,
                v_parametros.id_oficina,
                'activo',
                v_num_tramite,
                v_parametros._id_usuario_ai,
                p_id_usuario,
                now(),
                v_parametros._nombre_usuario_ai,
                null,
                null,
                v_id_responsable_depto,
                v_parametros.id_persona,
                v_parametros.codigo,
                v_parametros.id_deposito,
                v_parametros.id_depto_dest,
                v_parametros.id_deposito_dest,
                v_parametros.id_funcionario_dest,
                v_parametros.id_movimiento_motivo
			)RETURNING id_movimiento into v_id_movimiento;

            --Verifica si es depreciacion y esta en Estado Borrador, para precargar con todos los activos fijos del departamento
            select 
               cat.codigo
            into 
                v_cod_movimiento
            from param.tcatalogo cat
            where cat.id_catalogo = v_parametros.id_cat_movimiento;

            if v_cod_movimiento = 'deprec' then

                  --Registra todos los activos del departamento que les corresponda depreciar en el periodo solicitado
                  insert into kaf.tmovimiento_af(
                      id_movimiento,
                      id_activo_fijo,
                      id_cat_estado_fun,
                      estado_reg,
                      fecha_reg,
                      id_usuario_reg,
                      fecha_mod
                  )
                  select 
                    v_id_movimiento,
                    afij.id_activo_fijo,
                    afij.id_cat_estado_fun,
                    'activo',
                    now(),
                    p_id_usuario,
                    null
                  from kaf.tactivo_fijo afij
                  where afij.estado = 'alta'
                  and   afij.id_depto = v_parametros.id_depto
                  and (
                           (afij.fecha_ult_dep is null and afij.fecha_ini_dep < v_parametros.fecha_hasta) 
                       or 
                           (afij.fecha_ult_dep < v_parametros.fecha_hasta));

            elsif v_cod_movimiento = 'transf' then
                
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
                select
                    v_id_movimiento,
                    afij.id_activo_fijo,
                    afij.id_cat_estado_fun,
                    'activo',
                    now(),
                    p_id_usuario,
                    null
                    from kaf.tactivo_fijo afij
                    where 
                         afij.id_funcionario = v_parametros.id_funcionario
                    and  afij.estado = 'alta'
                    and  afij.en_deposito = 'no';
            end if;
			
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
            --Edicion solo para estado borrador
            if not exists(select 1 from kaf.tmovimiento
                        where id_movimiento = v_parametros.id_movimiento
                        and estado = 'borrador') then
                raise exception 'No se puede Modificar los datos porque no esta en Borrador';
            end if;

            --Obtiene los datos actuales del movimiento
            select 
               *
            into 
                v_rec
            from kaf.tmovimiento
            where id_movimiento = v_parametros.id_movimiento;

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

            --Permite el cambio solamente si esta en estado Borrador
            if v_rec.estado = 'borrador' then

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
                        fecha_mod = now(),
                        id_usuario_mod = p_id_usuario,
                        id_usuario_ai = v_parametros._id_usuario_ai,
                        usuario_ai = v_parametros._nombre_usuario_ai,
                        id_persona = v_parametros.id_persona,
                        codigo=v_parametros.codigo,
                        id_deposito=v_parametros.id_deposito,
                        id_depto_dest=v_parametros.id_depto_dest,
                        id_deposito_dest=v_parametros.id_deposito_dest,
                        id_funcionario_dest=v_parametros.id_funcionario_dest,
                        id_movimiento_motivo=v_parametros.id_movimiento_motivo
                    where id_movimiento=v_parametros.id_movimiento;

                    --Verifica el tipo de movimiento para aplicar reglas
                    select 
                        cat.codigo
                    into 
                        v_cod_movimiento
                    from param.tcatalogo cat
                    where cat.id_catalogo = v_parametros.id_cat_movimiento;

                    if v_cod_movimiento = 'deprec' then
                        --Si se cambio de depto se borra el detalle y se lo vuelve a llenar
                        if v_rec.id_depto != v_parametros.id_depto then

                            delete from kaf.tmovimiento_af_dep
                            where id_movimiento_af in (select id_movimiento_af from kaf.tmovimiento_af where id_movimiento = v_parametros.id_movimiento);
                            
                            delete from kaf.tmovimiento_af where id_movimiento = v_parametros.id_movimiento;

                            insert into kaf.tmovimiento_af(
                                id_movimiento,
                                id_activo_fijo,
                                id_cat_estado_fun,
                                estado_reg,
                                fecha_reg,
                                id_usuario_reg,
                                fecha_mod
                            )
                            select 
                                v_parametros.id_movimiento,
                                afij.id_activo_fijo,
                                afij.id_cat_estado_fun,
                                'activo',
                                now(),
                                p_id_usuario,
                                null
                                from kaf.tactivo_fijo afij
                                where afij.estado = 'alta'
                                and afij.id_depto = v_parametros.id_depto
                                and ((afij.fecha_ult_dep is null and afij.fecha_ini_dep < v_parametros.fecha_hasta) or (afij.fecha_ult_dep < v_parametros.fecha_hasta));

                        end if;

                    elsif v_cod_movimiento = 'transf' then

                        if v_rec.id_funcionario != v_parametros.id_funcionario then
                            
                            delete from kaf.tmovimiento_af where id_movimiento = v_parametros.id_movimiento;

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
                            select
                            v_id_movimiento,
                            afij.id_activo_fijo,
                            afij.id_cat_estado_fun,
                            'activo',
                            now(),
                            p_id_usuario,
                            null
                            from kaf.tactivo_fijo afij
                            where afij.id_funcionario = v_parametros.id_funcionario
                            and afij.estado = 'alta'
                            and afij.en_deposito = 'no';

                        end if;


                    end if;

            else
                raise exception 'Modificacion no permitida, debe estar en Estado Borrador';
            end if;

            
               
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
            
            --Obtiene los datos actuales del movimiento
            select *
            into v_rec
            from kaf.tmovimiento
            where id_movimiento = v_parametros.id_movimiento;

            if v_rec.estado = 'borrador' then
    			--Sentencia de la eliminacion
    			delete from kaf.tmovimiento
                where id_movimiento=v_parametros.id_movimiento;
            else
                raise exception 'Eliminacion no permitida, debe estar en Estado Borrador';
            end if;
               
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

    /*********************************    
    #TRANSACCION:  'KAF_SIGEMOV_IME'
    #DESCRIPCION:   funcion que controla el cambio al Siguiente estado del movimiento
    #AUTOR:         RCM
    #FECHA:         30/03/2016
    ***********************************/

    elseif(p_transaccion='KAF_SIGEMOV_IME')then   
        begin
            --Obtiene los datos del movimiento       
            select mov.*, cat.codigo as cod_movimiento
            into v_movimiento
            from kaf.tmovimiento mov
            inner join param.tcatalogo cat
            on cat.id_catalogo = mov.id_cat_movimiento    
            where id_proceso_wf = v_parametros.id_proceso_wf_act;

            --Obtiene los datos del Estado Actual
            select 
            ew.id_tipo_estado,
            te.pedir_obs,
            ew.id_estado_wf
            into 
            v_id_tipo_estado,
            v_pedir_obs,
            v_id_estado_wf
            from wf.testado_wf ew
            inner join wf.ttipo_estado te on te.id_tipo_estado = ew.id_tipo_estado
            where ew.id_estado_wf = v_parametros.id_estado_wf_act;
              
            --Obtener datos tipo estado
            select
            te.codigo
            into
            v_codigo_estado_siguiente
            from wf.ttipo_estado te
            where te.id_tipo_estado = v_parametros.id_tipo_estado;

            --raise exception '%: % -> %',v_movimiento.cod_movimiento,v_movimiento.estado,v_codigo_estado_siguiente;
            
            
            
            --raise exception '%',v_movimiento.cod_movimiento;
            --------------------------------------------
            --Acciones por Tipo de Movimiento y Estado
            --------------------------------------------
            if v_movimiento.cod_movimiento = 'alta' then
            
              

                if v_codigo_estado_siguiente = 'finalizado' then
                
                    --Actualiza estado de activo fijo
                    update kaf.tactivo_fijo set
                    estado = 'alta',
                    codigo = kaf.f_genera_codigo (movaf.id_activo_fijo)
                    from kaf.tmovimiento_af movaf
                    where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
                    and movaf.id_movimiento = v_movimiento.id_movimiento;
                    
                   

                    --Crea el registro de importes
                    insert into kaf.tactivo_fijo_valores(
                       	id_usuario_reg, 
                       	fecha_reg,estado_reg,
                        id_activo_fijo,
                        monto_vigente_orig,
                        vida_util_orig,
                        fecha_ini_dep,
                        depreciacion_mes,
                        depreciacion_per,
                        depreciacion_acum,
                        monto_vigente,
                        vida_util,
                        estado,
                        principal,
                        monto_rescate,
                        id_movimiento_af,
                        tipo, 
                        codigo
                    )
                    select
                    	p_id_usuario,
                        now(),
                        'activo',
                    	af.id_activo_fijo,
                        af.monto_compra,            --  considerar en modificacion
                        af.vida_util_original,      --  considerar en modificacion
                        af.fecha_ini_dep,           --  considerar en modificacion
                    	0,
                        0,
                        0,
                    	af.monto_compra,            --  considerar en modificacion
                        af.vida_util_original,      --  considerar en modificacion
                        'activo',
                        'si',
                        af.monto_rescate,           --  considerar en modificacion
                        movaf.id_movimiento_af,
                    	'alta',
                        af.codigo                   --  considerar en modificacion
                    from kaf.tmovimiento_af movaf
                    inner join kaf.tactivo_fijo af
                    on af.id_activo_fijo = movaf.id_activo_fijo
                    where movaf.id_movimiento = v_movimiento.id_movimiento;
                    
                    --  TODO
                    --  RAC 03/03/2017
                    --  Si lo valroes originales son modificados en la tabla activo_fijo
                    --  no se estan acutlizando los valores ......
                    --  pienso que conviene ahcerlo con un triguer para evitar inconsistencias 
                    --  si alguien decide cambiar directo en base de datos
                    
                    
                    
                end if;
                
              

            elsif v_movimiento.cod_movimiento = 'baja' then
                if v_codigo_estado_siguiente = 'finalizado' then
                    --Actualiza estado de activo fijo
                    update kaf.tactivo_fijo set
                    estado = 'baja',
                    fecha_baja = mov.fecha_mov
                    from kaf.tmovimiento_af movaf
                    inner join kaf.tmovimiento mov
                    on mov.id_movimiento = movaf.id_movimiento
                    where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
                    and movaf.id_movimiento = v_movimiento.id_movimiento;
                
                end if;

            elsif v_movimiento.cod_movimiento = 'asig' then
                if v_codigo_estado_siguiente = 'finalizado' then
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
                
                end if;
                
                
                

            -- RAC 03/03/2017
            -- aumento un if para considerar el caso de transferencias finalizadas
            -- y actulizar el responsable del activo
            -- TODO (Validaolo rodrigo)
            -- TODO que pasa cuando tranfieres de un departamento a otro ....????
            
            elsif v_movimiento.cod_movimiento = 'transf' then
                
                if v_codigo_estado_siguiente = 'finalizado' then
                    --Actualiza estado de activo fijo
                    update kaf.tactivo_fijo set
                    	en_deposito = 'no',
                    	id_funcionario = mov.id_funcionario_dest,
                    	id_persona = mov.id_persona
                     from kaf.tmovimiento_af movaf
                     inner join kaf.tmovimiento mov on mov.id_movimiento = movaf.id_movimiento
                    where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
                    and movaf.id_movimiento = v_movimiento.id_movimiento;
                
                end if;
            
            
            elsif v_movimiento.cod_movimiento = 'devol' then
                if v_codigo_estado_siguiente = 'finalizado' then
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
                
                end if;

            elsif v_movimiento.cod_movimiento = 'reval' then
                
                if v_codigo_estado_siguiente = 'finalizado' then
                    
                    --Actualiza estado de activo fijo
                    update kaf.tactivo_fijo set
                    	cantidad_revaloriz = cantidad_revaloriz + 1,
                   		monto_vigente = movaf.importe,
                    	vida_util = movaf.vida_util
                    from kaf.tmovimiento_af movaf
                    where kaf.tactivo_fijo.id_activo_fijo = movaf.id_activo_fijo
                    and movaf.id_movimiento = v_movimiento.id_movimiento;

                    --Crea el registro de importes
                    insert into kaf.tactivo_fijo_valores(
                      id_usuario_reg, fecha_reg,estado_reg,
                      id_activo_fijo,monto_vigente_orig,vida_util_orig,fecha_ini_dep,
                      depreciacion_mes,depreciacion_per,depreciacion_acum,
                      monto_vigente,vida_util,estado,principal,monto_rescate,id_movimiento_af,
                      tipo, codigo
                    )
                    select
                      p_id_usuario,now(),'activo',
                      af.id_activo_fijo,af.monto_compra,af.vida_util_original,af.fecha_ini_dep,
                      0,0,0,
                      movaf.importe,movaf.vida_util,'activo','si',af.monto_rescate,movaf.id_movimiento_af,
                      'reval', af.codigo||'-R'||cast(af.cantidad_revaloriz as varchar)
                    from kaf.tmovimiento_af movaf
                    inner join kaf.tactivo_fijo af
                    on af.id_activo_fijo = movaf.id_activo_fijo
                    where movaf.id_movimiento = v_movimiento.id_movimiento;

                end if;

            elsif v_movimiento.cod_movimiento = 'deprec' then

                if v_codigo_estado_siguiente = 'generado' then
                
                   

                    --Generacion de la depreciacion
                    for v_rec in (select id_movimiento_af, id_activo_fijo
                                from kaf.tmovimiento_af
                                where id_movimiento = v_movimiento.id_movimiento) loop

                        v_resp = kaf.f_depreciacion_lineal(p_id_usuario,v_rec.id_activo_fijo,v_movimiento.fecha_hasta,  v_rec.id_movimiento_af);

                    end loop;

                elsif v_codigo_estado_siguiente = 'finalizado' then

                end if;

            end if;


            if pxp.f_existe_parametro(p_tabla,'id_depto_wf') then
                v_id_depto = v_parametros.id_depto_wf;
            end if;
                    
            if pxp.f_existe_parametro(p_tabla,'obs') THEN
                v_obs=v_parametros.obs;
            else
                v_obs='---';
            end if;
                   
            --Configurar acceso directo para la alarma   
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'Visto Bueno';

                
            if v_codigo_estado_siguiente not in ('finalizado') then
                v_acceso_directo = '../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php';
                v_clase = 'Movimiento';
                v_parametros_ad = '{filtro_directo:{campo:"mov.id_proceso_wf",valor:"'||v_parametros.id_proceso_wf_act::varchar||'"}}';
                v_tipo_noti = 'notificacion';
                v_titulo  = 'Notificacion';             
            end if;
                 
            v_id_estado_actual =  wf.f_registra_estado_wf(
                v_parametros.id_tipo_estado, 
                v_parametros.id_funcionario_wf, 
                v_parametros.id_estado_wf_act, 
                v_parametros.id_proceso_wf_act,
                p_id_usuario,
                v_parametros._id_usuario_ai,
                v_parametros._nombre_usuario_ai,
                v_id_depto,
                coalesce(v_movimiento.codigo,'--')||' Obs:'||v_obs,
                v_acceso_directo ,
                v_clase,
                v_parametros_ad,
                v_tipo_noti,
                v_titulo
            );
              
            --Actualiza el estado actual
            select 
            codigo
            into v_codigo_estado_siguiente
            from wf.ttipo_estado tes
            inner join wf.testado_wf ew
            on ew.id_tipo_estado = tes.id_tipo_estado
            where ew.id_estado_wf = v_id_estado_actual;

            update kaf.tmovimiento set
            id_estado_wf = v_id_estado_actual,
            estado = v_codigo_estado_siguiente
            where id_movimiento = v_movimiento.id_movimiento;

            -- si hay mas de un estado disponible  preguntamos al usuario
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se realizo el cambio de estado del movimiento)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'operacion','cambio_exitoso');
              
              
            -- Devuelve la respuesta
            return v_resp;
            
         end;     

    
    /*********************************    
    #TRANSACCION:  'KAF_ANTEMOV_IME'
    #DESCRIPCION:   Transaccion utilizada  pasar a  estados anterior al movimiento
    #AUTOR:         RCM
    #FECHA:         02/04/2016
    ***********************************/

    elseif(p_transaccion='KAF_ANTEMOV_IME') then   

        begin

            --Obtiene los datos del movimiento       
            select mov.*, cat.codigo as cod_movimiento
            into v_movimiento
            from kaf.tmovimiento mov
            inner join param.tcatalogo cat
            on cat.id_catalogo = mov.id_cat_movimiento    
            where id_proceso_wf = v_parametros.id_proceso_wf;

            --Obtiene los datos del Estado Actual
            select 
            ew.id_tipo_estado,
            te.pedir_obs,
            ew.id_estado_wf
            into 
            v_id_tipo_estado,
            v_pedir_obs,
            v_id_estado_wf
            from wf.testado_wf ew
            inner join wf.ttipo_estado te on te.id_tipo_estado = ew.id_tipo_estado
            where ew.id_estado_wf = v_parametros.id_estado_wf;


            --------------------------------------------------
            --Retrocede al estado inmediatamente anterior
            -------------------------------------------------
            SELECT  
            ps_id_tipo_estado,
            ps_id_funcionario,
            ps_id_usuario_reg,
            ps_id_depto,
            ps_codigo_estado,
            ps_id_estado_wf_ant
            into
            v_id_tipo_estado,
            v_id_funcionario,
            v_id_usuario_reg,
            v_id_depto,
            v_codigo_estado,
            v_id_estado_wf_ant 
            FROM wf.f_obtener_estado_ant_log_wf(v_parametros.id_estado_wf);

            --Obtener datos tipo estado
             if v_movimiento.cod_movimiento = 'deprec' then
                if v_codigo_estado = 'borrador' then
                    --Eliminar registros de la depreciacion
                    delete from kaf.tmovimiento_af_dep
                    where id_movimiento_af in (select id_movimiento_af
                                            from kaf.tmovimiento_af
                                            where id_movimiento = v_movimiento.id_movimiento);
                end if;
            end if;


            select 
            ew.id_proceso_wf 
            into 
            v_id_proceso_wf
            from wf.testado_wf ew
            where ew.id_estado_wf= v_id_estado_wf_ant;
          
          
            --Configurar acceso directo para la alarma   
            v_acceso_directo = '';
            v_clase = '';
            v_parametros_ad = '';
            v_tipo_noti = 'notificacion';
            v_titulo  = 'Notificacion';
             
           
            if v_codigo_estado_siguiente not in ('finalizado') then
                v_acceso_directo = '../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php';
                v_clase = 'Movimiento';
                v_parametros_ad = '{filtro_directo:{campo:"mov.id_proceso_wf",valor:"'||v_parametros.id_proceso_wf_act::varchar||'"}}';
                v_tipo_noti = 'notificacion';
                v_titulo  = 'Notificacion';             
            end if;
             
          
          --Registra nuevo estado
            v_id_estado_actual = wf.f_registra_estado_wf(
                v_id_tipo_estado, 
                v_id_funcionario, 
                v_parametros.id_estado_wf, 
                v_id_proceso_wf, 
                p_id_usuario,
                v_parametros._id_usuario_ai,
                v_parametros._nombre_usuario_ai,
                v_id_depto,
                '[RETROCESO] '|| v_parametros.obs,
                v_acceso_directo,
                v_clase,
                v_parametros_ad,
                v_tipo_noti,
                v_titulo
            );

            --Actualiza el estado actual
            select 
            codigo
            into v_codigo_estado_siguiente
            from wf.ttipo_estado tes
            inner join wf.testado_wf ew
            on ew.id_tipo_estado = tes.id_tipo_estado
            where ew.id_estado_wf = v_id_estado_actual;

            update kaf.tmovimiento set
            id_estado_wf = v_id_estado_actual,
            estado = v_codigo_estado_siguiente
            where id_movimiento = v_movimiento.id_movimiento;
                      

            -- si hay mas de un estado disponible  preguntamos al usuario
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Se retorocedio el estado del movimiento)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'operacion','cambio_exitoso');
                        
                              
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