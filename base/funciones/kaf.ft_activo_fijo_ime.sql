--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo'
 AUTOR: 		 (admin)
 FECHA:	        29-10-2015 03:18:45
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
	v_id_activo_fijo		integer;
    v_codigo 				varchar;
    v_cant_clon				integer;
    v_rec_af         		record;
    v_ids_clon				varchar;
    v_clase_reporte			varchar;
    v_monto_compra			numeric;
    
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	if(p_transaccion='SKA_AFIJ_INS')then
					
        begin

        	select
	        v_parametros.id_persona,
			v_parametros.id_proveedor,
			v_parametros.fecha_compra,
			--v_parametros.monto_vigente,
			v_parametros.id_cat_estado_fun,
			v_parametros.ubicacion,
			--v_parametros.vida_util,
			v_parametros.documento,
			v_parametros.observaciones,
			--v_parametros.fecha_ult_dep,
			v_parametros.monto_rescate,
			v_parametros.denominacion,
			v_parametros.id_funcionario,
			v_parametros.id_deposito,
			v_parametros.monto_compra_mt,
			v_parametros.id_moneda_orig,
			v_parametros.codigo,
			v_parametros.descripcion,
			v_parametros.id_moneda_orig,
			v_parametros.fecha_ini_dep,
			v_parametros.id_cat_estado_compra,
			v_parametros.vida_util_original,
			v_parametros.id_clasificacion,
			v_parametros.id_oficina,
			v_parametros.id_depto,
			p_id_usuario,
			null, -- v_parametros.nombre_usuario_ai,
			null, --v_parametros.id_usuario_ai
			v_parametros.codigo_ant,
			v_parametros.marca,
			v_parametros.nro_serie,
            
			NULL
	        into v_rec_af;

	        --Inserción del registro
	        v_id_activo_fijo = kaf.f_insercion_af(p_id_usuario, hstore(v_rec_af));

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos almacenado(a) con exito (id_activo_fijo'||v_id_activo_fijo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_id_activo_fijo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_MOD')then

		begin
        
             select 
               *
              into
                v_rec_af
             from kaf.tactivo_fijo af
             where af.id_activo_fijo = v_parametros.id_activo_fijo;
             
          
              IF v_rec_af.estado != 'registrado' THEN
                 
               IF v_rec_af.monto_compra != v_parametros.monto_compra or v_rec_af.fecha_ini_dep != v_parametros.fecha_ini_dep or v_rec_af.id_moneda != v_parametros.id_moneda_orig  THEN
                 raise exception 'no puede editar datos de compras cuando el activo ya esta de alta, regitre una revalorizacion para hacer cualquier ajuste';
               END IF;
              END IF;  
              
              v_monto_compra = param.f_convertir_moneda(
                                                         v_parametros.id_moneda_orig, 
                                                         NULL,   --por defecto moenda base
                                                         v_parametros.monto_compra_mt, 
                                                         v_parametros.fecha_compra, 
                                                         'O',-- tipo oficial, venta, compra 
                                                         NULL);--defecto dos decimales
             
        
      
			--Sentencia de la modificacion
			update kaf.tactivo_fijo set
                id_persona = v_parametros.id_persona,
                cantidad_revaloriz = v_parametros.cantidad_revaloriz,
                foto = v_parametros.foto,
                id_proveedor = v_parametros.id_proveedor,
                fecha_compra = v_parametros.fecha_compra,
               -- monto_vigente = v_parametros.monto_vigente,
                id_cat_estado_fun = v_parametros.id_cat_estado_fun,
                ubicacion = v_parametros.ubicacion,
               -- vida_util = v_parametros.vida_util,
                documento = v_parametros.documento,
                observaciones = v_parametros.observaciones,
              --  fecha_ult_dep = v_parametros.fecha_ult_dep,
                monto_rescate = v_parametros.monto_rescate,
                denominacion = v_parametros.denominacion,
                id_funcionario = v_parametros.id_funcionario,
                id_deposito = v_parametros.id_deposito,
                monto_compra_mt = v_parametros.monto_compra_mt,
                monto_compra = v_monto_compra,
                id_moneda = v_parametros.id_moneda_orig,
                codigo = v_parametros.codigo,
                descripcion = v_parametros.descripcion,
                id_moneda_orig = v_parametros.id_moneda_orig,
                fecha_ini_dep = v_parametros.fecha_ini_dep,
                id_cat_estado_compra = v_parametros.id_cat_estado_compra,
                vida_util_original = v_parametros.vida_util_original,
                estado = v_parametros.estado,
                id_clasificacion = v_parametros.id_clasificacion,
                -- id_centro_costo = v_parametros.id_centro_costo,
                id_oficina = v_parametros.id_oficina,
                id_depto = v_parametros.id_depto,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                id_usuario_ai = v_parametros._id_usuario_ai,
                usuario_ai = v_parametros._nombre_usuario_ai,
                codigo_ant = v_parametros.codigo_ant,
                nro_serie = v_parametros.nro_serie,
                marca = v_parametros.marca--,
                --caraceristicas = v_parametros._nombre_usuario_ai
			where id_activo_fijo = v_parametros.id_activo_fijo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_AFIJ_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		29-10-2015 03:18:45
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tactivo_fijo
            where id_activo_fijo=v_parametros.id_activo_fijo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijos eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
              
            --Devuelve la respuesta
            return v_resp;

		end;
        
    /*********************************    
 	#TRANSACCION:  'SKA_AFCOD_MOD'
 	#DESCRIPCION:	Generación del código de activo fijo
 	#AUTOR:			RCM
 	#FECHA:			30/12/2015
	***********************************/

	elsif(p_transaccion='SKA_AFCOD_MOD')then

		begin
        	--Generación del código activo fijo
        	v_codigo = kaf.f_genera_codigo(v_parametros.id_activo_fijo);
            
            --Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos Fijo codificado (id_activo_fijo'||v_id_activo_fijo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'codigo',v_codigo);

            --Devuelve la respuesta
            return v_resp;
        
        end;

    /*********************************    
 	#TRANSACCION:  'SKA_AFCLO_INS'
 	#DESCRIPCION:	Clonación del activo fijo seleccionado
 	#AUTOR:			RCM
 	#FECHA:			10/01/2016
	***********************************/

	elsif(p_transaccion='SKA_AFCLO_INS')then

		begin

			--Verificación de existencia del registro
			if not exists(select 1 from kaf.tactivo_fijo
						where id_activo_fijo = v_parametros.id_activo_fijo) then
				raise exception 'Activo fijo inexistente';
			end if;

			--Verifica que la cantidad solicitada sea mayor a cero y menor a un parámetro definido
			v_cant_clon = coalesce(pxp.f_get_variable_global('kaf_cant_clon')::integer,100);

			if v_parametros.cant_clon <= 0 then
				raise exception 'La cantidad a clonar debe ser mayor a cero';
			end if;

			if v_parametros.cant_clon > v_cant_clon then
				raise exception 'La cantidad excede el máximo de registros parametrizado: %. Este valor puede ser modificado en las variables globales del sistema.',v_cant_clon::varchar;
			end if;

			--Obtención de los datos del activo fijo
			select
	        null as id_persona,
			id_proveedor,
			fecha_compra,
			monto_vigente,
			id_cat_estado_fun,
			ubicacion,
			vida_util_original as vida_util,
			documento,
			observaciones,
			null as fecha_ult_dep,
			monto_rescate,
			denominacion,
			null as id_funcionario,
			id_deposito,
			monto_compra,
			id_moneda_orig,
			codigo,
			descripcion,
			id_moneda_orig,
			fecha_ini_dep,
			id_cat_estado_compra,
			vida_util_original,
			id_clasificacion,
			id_oficina,
			id_depto,
			null as nombre_usuario_ai,
			null as id_usuario_ai
	        into v_rec_af
	        from kaf.tactivo_fijo
	        where id_activo_fijo = v_parametros.id_activo_fijo;

	        v_ids_clon='';
			for i in 1..v_parametros.cant_clon loop
				--Inserción del registro
	        	v_ids_clon = v_ids_clon || ','|| kaf.f_insercion_af(p_id_usuario, hstore(v_rec_af))::varchar;
			end loop;
            
            --Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Han sido clonados "'||v_parametros.cant_clon::varchar||'" Activos Fijos satisfactoriamente en base al activo fijo '|| v_rec_af.codigo||'('||v_parametros.id_activo_fijo::varchar||') [IDs generados: '||v_ids_clon||']'); 
            v_resp = pxp.f_agrega_clave(v_resp,'ids',v_ids_clon);

            --Devuelve la respuesta
            return v_resp;
        
        end;
        
        
     
    /*********************************    
 	#TRANSACCION:  'SKA_GETQR_MOD'
 	#DESCRIPCION:	Recupera codigo QR segun configuracion de variable global
 	#AUTOR:			RAC
 	#FECHA:			15/03/2017
	***********************************/

	elsif(p_transaccion='SKA_GETQR_MOD')then

		begin

			select 
              kaf.id_activo_fijo,
              kaf.codigo,
              kaf.codigo_ant,
              kaf.denominacion,
              COALESCE(dep.nombre_corto, '') as nombre_depto,
              COALESCE(ent.nombre, '') as nombre_entidad
             into
               v_rec_af
            from kaf.tactivo_fijo  kaf
            inner join param.tdepto dep on dep.id_depto = kaf.id_depto 
            left join param.tentidad ent on ent.id_entidad = dep.id_entidad
			where id_activo_fijo = v_parametros.id_activo_fijo;
            
            --recuperar configuracion del reporte de codigo de barrar por defecto de variable global
             v_clase_reporte = pxp.f_get_variable_global('kaf_clase_reporte_codigo');
            
            
			
            
            --Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Foto subida correctamente'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo',v_rec_af.codigo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo_ant',v_rec_af.codigo_ant::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'denominacion',v_rec_af.denominacion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'nombre_depto',v_rec_af.nombre_depto::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'nombre_entidad',v_rec_af.nombre_entidad::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_clase_reporte',COALESCE(v_clase_reporte,'RCodigoQRAF')::varchar);
            

            --Devuelve la respuesta
            return v_resp;
        
        end; 

    /*********************************    
 	#TRANSACCION:  'SKA_AFCLO_INS'
 	#DESCRIPCION:	Clonación del activo fijo seleccionado
 	#AUTOR:			RCM
 	#FECHA:			10/01/2016
	***********************************/

	elsif(p_transaccion='SKA_PHOTO_UPL')then

		begin

			if not exists(select 1 from kaf.tactivo_fijo
				where id_activo_fijo = v_parametros.id_activo_fijo) then
				raise exception 'Activo fijo no existente';
			end if;

			update kaf.tactivo_fijo set
			foto = v_parametros.file_name,
			extension = v_parametros.extension
			where id_activo_fijo = v_parametros.id_activo_fijo;
            
            --Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Foto subida correctamente'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);

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