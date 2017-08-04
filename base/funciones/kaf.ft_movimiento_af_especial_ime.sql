CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_af_especial_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_especial_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_especial'
 AUTOR: 		 (admin)
 FECHA:	        23-06-2017 08:21:47
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
	v_id_movimiento_af_especial	integer;
	v_id_movimiento_af 		integer;
	v_id_cat_estado_fun		integer;
	v_id_activo_fijo		integer;
	v_id_activo_fijo_valor	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_af_especial_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOVESP_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-06-2017 08:21:47
	***********************************/

	if(p_transaccion='SKA_MOVESP_INS')then
					
        begin
        	--Inicializa ID del padre
        	v_id_movimiento_af = v_parametros.id_movimiento_af;
        	v_id_activo_fijo = v_parametros.id_activo_fijo;
        	v_id_activo_fijo_valor = v_parametros.id_activo_fijo_valor;

        	--Verifica si existe el padre (id_movimiento_af)
        	if not exists (select 1 from kaf.tmovimiento_af
        					where id_movimiento_af = v_parametros.id_movimiento_af) then
        		--TODO: Llamar a función para insertar movimiento_af en vez del insert (primero hay que crear esa función)
        		select id_cat_estado_fun
        		into v_id_cat_estado_fun
        		from kaf.tactivo_fijo
        		where id_activo_fijo = v_parametros.id_activo_fijo;
        		
        		--Sentencia de la insercion para los demás movimientos
	            insert into kaf.tmovimiento_af(
	                  id_movimiento,
	                  id_activo_fijo,
	                  id_cat_estado_fun,
	                  estado_reg,
	                  fecha_reg,
	                  id_usuario_reg
	              ) values(
	                  v_parametros.id_movimiento,
	                  v_parametros.id_activo_fijo,
	                  v_id_cat_estado_fun,
	                  'activo',
	                  now(),
	                  p_id_usuario
	            ) RETURNING id_movimiento_af into v_id_movimiento_af;
	        else

	        	--Verifica si se cambió el activo fijo
				if not exists(select 1 from kaf.tmovimiento_af
							where id_movimiento_af = v_parametros.id_movimiento_af
							and id_activo_fijo = v_parametros.id_activo_fijo) then
					--Se cambió de activo fijo. Primero se borra todos los movimientos especiales, luego update a movimiento_af
					delete from kaf.tmovimiento_af_especial where id_movimiento_af = v_parametros.id_movimiento_af;

					update kaf.tmovimiento_af set
					id_activo_fijo = v_parametros.id_activo_fijo
					where id_movimiento_af = v_parametros.id_movimiento_af;

				end if;

        	end if;

        	--Validación por tipo de movimiento especial
        	if v_parametros.cod_movimiento = 'divis' then
        		v_id_activo_fijo = null;
        		v_id_activo_fijo_valor = null;
        	elsif v_parametros.cod_movimiento = 'desgl' then
        		v_id_activo_fijo = null;
        	elsif v_parametros.cod_movimiento = 'intpar' then
        		v_id_activo_fijo = v_parametros.id_activo_fijo_det;
        	end if;

        	--Sentencia de la insercion
        	insert into kaf.tmovimiento_af_especial(
			estado_reg,
			id_activo_fijo,
			id_activo_fijo_valor,
			importe,
			id_movimiento_af,
			fecha_reg,
			usuario_ai,
			id_usuario_reg,
			id_usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			'activo',
			v_id_activo_fijo,
			v_id_activo_fijo_valor,
			v_parametros.importe,
			v_id_movimiento_af,
			now(),
			v_parametros._nombre_usuario_ai,
			p_id_usuario,
			v_parametros._id_usuario_ai,
			null,
			null
			)RETURNING id_movimiento_af_especial into v_id_movimiento_af_especial;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimientos Especiales almacenado(a) con exito (id_movimiento_af_especial'||v_id_movimiento_af_especial||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_especial',v_id_movimiento_af_especial::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_id_movimiento_af::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVESP_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-06-2017 08:21:47
	***********************************/

	elsif(p_transaccion='SKA_MOVESP_MOD')then

		begin

			--Verifica si se cambió el activo fijo
			if not exists(select 1 from kaf.tmovimiento_af
						where id_movimiento_af = v_parametros.id_movimiento_af
						and id_activo_fijo = v_parametros.id_activo_fijo) then
				--Se cambió de activo fijo. Primero se borra todos los movimientos especiales, luego update a movimiento_af
				delete from kaf.tmovimiento_af_especial where id_movimiento_af = v_parametros.id_movimiento_af;

				update kaf.tmovimiento_af set
				id_activo_fijo = v_parametros.id_activo_fijo
				where id_movimiento_af = v_parametros.id_movimiento_af;

			end if;

			v_id_activo_fijo = v_parametros.id_activo_fijo;
        	v_id_activo_fijo_valor = v_parametros.id_activo_fijo_valor;

        	--Validación por tipo de movimiento especial
        	if v_parametros.cod_movimiento = 'divis' then
        		v_id_activo_fijo = null;
        		v_id_activo_fijo_valor = null;
        	elsif v_parametros.cod_movimiento = 'desgl' then
        		v_id_activo_fijo = null;
        	elsif v_parametros.cod_movimiento = 'intpar' then
        		v_id_activo_fijo = v_parametros.id_activo_fijo_det;
        	end if;

			--Sentencia de la modificacion
			update kaf.tmovimiento_af_especial set
			id_activo_fijo = v_id_activo_fijo,
			id_activo_fijo_valor = v_id_activo_fijo_valor,
			importe = v_parametros.importe,
			id_movimiento_af = v_parametros.id_movimiento_af,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_movimiento_af_especial=v_parametros.id_movimiento_af_especial;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimientos Especiales modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_especial',v_parametros.id_movimiento_af_especial::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVESP_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-06-2017 08:21:47
	***********************************/

	elsif(p_transaccion='SKA_MOVESP_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af_especial
            where id_movimiento_af_especial=v_parametros.id_movimiento_af_especial;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimientos Especiales eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af_especial',v_parametros.id_movimiento_af_especial::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOVESPAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:			RCM	
 	#FECHA:			26-06-2017
	***********************************/

	elsif(p_transaccion='SKA_MOVESPAF_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af_especial
            where id_movimiento_af=v_parametros.id_movimiento_af
            and id_activo_fijo = v_parametros.id_activo_fijo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Movimientos Especiales eliminado(a)'); 
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
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_movimiento_af_especial_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
