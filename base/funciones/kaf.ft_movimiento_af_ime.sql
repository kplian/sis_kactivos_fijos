--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_movimiento_af_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_af'
 AUTOR: 		 (admin)
 FECHA:	        18-03-2016 05:34:15
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/

DECLARE

	v_nro_requerimiento    integer;
	v_parametros           record;
	v_id_requerimiento     integer;
	v_resp		           varchar;
	v_nombre_funcion       text;
	v_mensaje_error        text;
	v_id_movimiento_af     integer;
	v_id_cat_estado_fun	   integer;
    v_registros		       record;
    v_registros_mov        record;
    v_id_moneda_base       integer;
			    
BEGIN

  v_nombre_funcion = 'kaf.ft_movimiento_af_ime';
  v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_INS'
 	#DESCRIPCION:	Insercion de registros, validaciones de estado y cantidad
 	#AUTOR:		admin ,RAC	
 	#FECHA:		18-03-2016, 23/03/2017
	***********************************/

	if(p_transaccion='SKA_MOVAF_INS')then
					
      begin
        
        --Se setea los datos para llamar a la función de inserción
        select
        coalesce(v_parametros.id_movimiento,null) as id_movimiento,
        coalesce(v_parametros.id_activo_fijo,null) as id_activo_fijo,
        coalesce(v_parametros.id_movimiento_motivo,null) as id_movimiento_motivo,
        coalesce(v_parametros.importe,null) as importe,
        coalesce(v_parametros.vida_util,null) as vida_util,
        coalesce(v_parametros._nombre_usuario_ai,null) as _nombre_usuario_ai,
        coalesce(v_parametros._id_usuario_ai,null) as _id_usuario_ai,
        coalesce(v_parametros.depreciacion_acum,null) as depreciacion_acum,
        coalesce(v_parametros.importe_ant,null) as importe_ant,
        coalesce(v_parametros.vida_util_ant,null) as vida_util_ant
        into v_registros;

        --Inserción del movimiento
        v_id_movimiento_af = kaf.f_insercion_movimiento_af(p_id_usuario, hstore(v_registros));
  			
  			--Definicion de la respuesta
  			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento almacenado(a) con exito (id_movimiento_af'||v_id_movimiento_af||')'); 
        v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_id_movimiento_af::varchar);

        --Devuelve la respuesta
        return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_MOD')then

		begin
			
            select
              mov.estado,
              mov.codigo
             INTO 
              v_registros
            from kaf.tmovimiento mov
            where mov.id_movimiento = v_parametros.id_movimiento;
            
            IF v_registros.estado != 'borrador' THEN
               raise exception 'Solo puede modificar acctivos en movimientos en borrador';
            END IF;
            
            
            --Obtiene estado funcional del activo fijo
        	select
        	id_cat_estado_fun
        	into
        	v_id_cat_estado_fun
        	from kaf.tactivo_fijo
        	where id_activo_fijo = v_parametros.id_activo_fijo;
            
           --  verificamos que el activo no este duplicado
            
            IF EXISTS(SELECT 1 
                      from kaf.tmovimiento_af maf 
                      where     maf.id_movimiento =  v_parametros.id_movimiento 
                           and  maf.id_activo_fijo = v_parametros.id_activo_fijo 
                           and maf.estado_reg = 'activo'  and maf.id_movimiento_af != v_parametros.id_movimiento_af) THEN
                 raise exception 'El activo ya se encuentre registro para este movimiento';
            END IF; 
            
            IF not kaf.f_validar_ins_mov_af(v_parametros.id_movimiento,v_parametros.id_activo_fijo) THEN
               raise exception 'ERROR al validar activos';
            END IF;

            --Se obtiene la moneda base
            v_id_moneda_base  = param.f_get_moneda_base();

			--Sentencia de la modificacion
			update kaf.tmovimiento_af set
                id_movimiento = v_parametros.id_movimiento,
                id_activo_fijo = v_parametros.id_activo_fijo,
                id_cat_estado_fun = v_id_cat_estado_fun,
                id_movimiento_motivo = v_parametros.id_movimiento_motivo,
                importe = v_parametros.importe,
                vida_util = v_parametros.vida_util,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                id_usuario_ai = v_parametros._id_usuario_ai,
                usuario_ai = v_parametros._nombre_usuario_ai,
                depreciacion_acum = v_parametros.depreciacion_acum,
                id_moneda = v_id_moneda_base,
                importe_ant = v_parametros.importe_ant,
                vida_util_ant = v_parametros.vida_util_ant
			where id_movimiento_af=v_parametros.id_movimiento_af;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_ELI')then

		begin
        
            select
              mov.estado,
              mov.codigo
             INTO 
              v_registros
            from kaf.tmovimiento mov
            inner join kaf.tmovimiento_af maf on maf.id_movimiento = mov.id_movimiento
            where maf.id_movimiento_af = v_parametros.id_movimiento_af;
            
            IF v_registros.estado != 'borrador' THEN
               raise exception 'Solo puede retirar activos en movimientos en borrador';
            END IF;
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af
            where id_movimiento_af=v_parametros.id_movimiento_af;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);
              
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