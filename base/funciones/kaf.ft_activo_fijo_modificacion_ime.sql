CREATE OR REPLACE FUNCTION "kaf"."ft_activo_fijo_modificacion_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_modificacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo_modificacion'
 AUTOR: 		 (admin)
 FECHA:	        23-08-2017 14:14:25
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
	v_id_activo_fijo_modificacion	integer;
	v_monto_compra			numeric;
	v_monto_compra_afv		numeric;
	v_monto_compra_100		numeric;
	v_monto_rescate			numeric;
	v_rec 					record;
	v_id_moneda_base		integer;
	v_rec_af				record;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_modificacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	if(p_transaccion='SKA_KAFMOD_INS')then
					
        begin

        	--Verifica si es una modificación de Montos. Sólo puede modificar montos a activos fijos que no se hayan depreciado o hayan sido sujetos a algún movimiento que afecta su importe excepto el Alta, cualquier otro movimiento si es permitido
        	if v_parametros.tipo = 3 then

        		--Verifica que el activo no esté en ninguna depreciación, mejora, revalorización, ajuste, mov. especiales
        		if exists (select 1
						from kaf.tmovimiento mov
						inner join kaf.tmovimiento_af maf
						on maf.id_movimiento = mov.id_movimiento
						inner join param.tcatalogo cat
						on cat.id_catalogo = mov.id_cat_movimiento
						where cat.codigo in ('baja','reval','mejora','deprec','ajuste','retiro','actua','divis','desgl','intpar')
						and maf.id_activo_fijo = v_parametros.id_activo_fijo) then

        			raise exception 'No puede modificarse los Importes del Activo Fijo porque ya fue depreciado o está incluido en algún movimiento que afecta a su importe';

				end if;

        	end if;

        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo_modificacion(
			id_activo_fijo,
			id_oficina,
			id_oficina_ant,
			ubicacion,
			estado_reg,
			ubicacion_ant,
			observaciones,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod,
			id_moneda_ant,
			monto_compra_orig_ant,
			monto_compra_orig_100_ant,
			id_moneda,
			monto_compra_orig,
			monto_compra_orig_100
          	) values(
			v_parametros.id_activo_fijo,
			v_parametros.id_oficina,
			v_parametros.id_oficina_ant,
			v_parametros.ubicacion,
			'activo',
			v_parametros.ubicacion_ant,
			v_parametros.observaciones,
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null,
			v_parametros.id_moneda_ant,
			v_parametros.monto_compra_orig_ant,
			v_parametros.monto_compra_orig_100_ant,
			v_parametros.id_moneda,
			v_parametros.monto_compra_orig,
			v_parametros.monto_compra_orig_100
			)RETURNING id_activo_fijo_modificacion into v_id_activo_fijo_modificacion;

			--Actualiza la ubicación del activo fijo si corresponde
			if v_parametros.tipo = 1 then
				
				--Modificación de Dirección
				if v_parametros.id_oficina is not null then
					update kaf.tactivo_fijo set
					id_oficina = v_parametros.id_oficina,
					ubicacion = v_parametros.ubicacion
					where id_activo_fijo = v_parametros.id_activo_fijo;
				end if;

			elsif v_parametros.tipo = 3 then

				--Modificación del monto de compra
				if v_parametros.monto_compra_orig is not null and v_parametros.monto_compra_orig_100 is not null and v_parametros.id_moneda is not null then
					
					--Obtención de la moneda base
            		v_id_moneda_base  = param.f_get_moneda_base();
					
					--Conversión del monto de compra original a moneda base
					v_monto_compra = param.f_convertir_moneda(
                           v_parametros.id_moneda, 
                           NULL,   --por defecto moneda base
                           v_parametros.monto_compra_orig, 
                           now()::date, 
                           'O',-- tipo oficial, venta, compra 
                           NULL);--defecto dos decimales

					--Actualiza los datos en la tabla activos fijos
					update kaf.tactivo_fijo set
					id_moneda_orig = v_parametros.id_moneda,
					monto_compra_orig = v_parametros.monto_compra_orig,
					monto_compra_orig_100 = v_parametros.monto_compra_orig_100,
					monto_compra = v_monto_compra
					where id_activo_fijo = v_parametros.id_activo_fijo;

					--Elimina y vuelve a crear los activo fijo valor
					delete from kaf.tactivo_fijo_valores where id_activo_fijo = v_parametros.id_activo_fijo;

					--Obtiene  datos del activo fijo
					select monto_rescate, fecha_ini_dep, vida_util_original, codigo
					into v_rec_af
					from kaf.tactivo_fijo
					where id_activo_fijo = v_parametros.id_activo_fijo;

					--Recrea los registros de activo fijo valor
				    --recorrido de las monedas configuradas para insertar un registro para cada una
                    for v_rec in (select 
                                mod.id_moneda_dep,
                                mod.id_moneda,                      
                                mod.id_moneda_act
                                from kaf.tmoneda_dep mod                                               
                                where mod.estado_reg = 'activo') loop
                                                  
                        v_monto_compra_afv = param.f_convertir_moneda(v_id_moneda_base, --moneda origen para conversion
																	v_rec.id_moneda,   --moneda a la que sera convertido
																	v_monto_compra, --este monto siemrpe estara en moenda base
																	v_registros_af_mov.fecha_ini_dep, 
																	'O',-- tipo oficial, venta, compra 
																	NULL);--defecto dos decimales   

                        v_monto_compra_100 = param.f_convertir_moneda(v_parametros.id_moneda, --moneda origen para conversion
																	v_rec.id_moneda,   --moneda a la que sera convertido
																	v_parametros.monto_compra_orig_100, --este monto siemrpe estara en moenda base
																	v_rec_af.fecha_ini_dep, 
																	'O',-- tipo oficial, venta, compra 
																	NULL);--defecto dos decimales   
                                                                             
                        v_monto_rescate = param.f_convertir_moneda(v_id_moneda_base, --moneda origen para conversion
                                                                   v_rec.id_moneda,   --moneda a la que sera convertido
                                                                   v_rec_af.monto_rescate, --este monto siemrpe estara en moenda base
                                                                   v_rec_af.fecha_ini_dep, 
                                                                   'O',-- tipo oficial, venta, compra 
                                                                   NULL);--defecto dos decimales                                                        
                                                  
                        --Crea el registro de importes
                        insert into kaf.tactivo_fijo_valores(
                            id_usuario_reg, 
                            fecha_reg,
                            estado_reg,
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
                            codigo,
                            id_moneda_dep,
                            id_moneda,
                            fecha_inicio,
                            monto_vigente_orig_100
                        ) values(
                            p_id_usuario,
                            now(),
                            'activo',
                            v_parametros.id_activo_fijo,
                            v_monto_compra_afv,            --  monto_vigente_orig
                            v_rec_af.vida_util_original,      --  vida_util_orig
                            v_rec_af.fecha_ini_dep,           --  fecha_ini_dep
                            0,
                            0,
                            0,
                            v_monto_compra_afv,            --  monto_vigente
                            v_rec_af.vida_util_original,      --  vida_util
                            'activo',
                            'si',
                            v_monto_rescate,           --  monto_rescate
                            null,
                            'alta',
                            v_rec_af.codigo,
                            v_rec.id_moneda_dep,
                            v_rec.id_moneda,
                            v_rec_af.fecha_ini_dep,           --  fecha_ini  desde cuando se considera el activo valor
                            v_monto_compra_100
                       );
                        
                    end loop; -- fin loop moneda

				end if;

			end if;
			
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones almacenado(a) con exito (id_activo_fijo_modificacion'||v_id_activo_fijo_modificacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_id_activo_fijo_modificacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	elsif(p_transaccion='SKA_KAFMOD_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tactivo_fijo_modificacion set
			id_activo_fijo = v_parametros.id_activo_fijo,
			id_oficina = v_parametros.id_oficina,
			id_oficina_ant = v_parametros.id_oficina_ant,
			ubicacion = v_parametros.ubicacion,
			ubicacion_ant = v_parametros.ubicacion_ant,
			observaciones = v_parametros.observaciones,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			id_moneda_ant = v_parametros.id_moneda_ant,
			monto_compra_orig_ant = v_parametros.monto_compra_orig_ant,
			monto_compra_orig_100_ant = v_parametros.monto_compra_orig_100_ant,
			id_moneda = v_parametros.id_moneda,
			monto_compra_orig = v_parametros.monto_compra_orig,
			monto_compra_orig_100 = v_parametros.monto_compra_orig_100
			where id_activo_fijo_modificacion=v_parametros.id_activo_fijo_modificacion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_parametros.id_activo_fijo_modificacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_KAFMOD_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		23-08-2017 14:14:25
	***********************************/

	elsif(p_transaccion='SKA_KAFMOD_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo_modificacion
            where id_activo_fijo_modificacion=v_parametros.id_activo_fijo_modificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Modificaciones eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_modificacion',v_parametros.id_activo_fijo_modificacion::varchar);
              
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
ALTER FUNCTION "kaf"."ft_activo_fijo_modificacion_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
