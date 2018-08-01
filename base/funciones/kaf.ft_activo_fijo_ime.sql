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
			v_parametros.monto_compra_orig,
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
			NULL,
            v_parametros.id_proyecto,
            v_parametros.cantidad_af,
            v_parametros.id_unidad_medida,
            v_parametros.monto_compra_orig_100,
            v_parametros.nro_cbte_asociado,
            v_parametros.fecha_cbte_asociado,
            v_parametros.id_grupo,
            v_parametros.id_centro_costo,
            v_parametros.id_ubicacion,
            v_parametros.id_grupo_clasif
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
                 
               IF v_rec_af.monto_compra_orig != v_parametros.monto_compra_orig or v_rec_af.fecha_ini_dep != v_parametros.fecha_ini_dep or v_rec_af.id_moneda != v_parametros.id_moneda_orig  THEN
                 raise exception 'no puede editar datos de compras cuando el activo ya esta de alta, registre una revalorizacion para hacer cualquier ajuste';
               END IF;
              END IF;  
              
              v_monto_compra = param.f_convertir_moneda(
                                                         v_parametros.id_moneda_orig, 
                                                         NULL,   --por defecto moenda base
                                                         v_parametros.monto_compra_orig, 
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
                id_funcionario = coalesce(v_parametros.id_funcionario_asig,v_parametros.id_funcionario),
                id_deposito = v_parametros.id_deposito,
                monto_compra_orig = v_parametros.monto_compra_orig,
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
                id_centro_costo = v_parametros.id_centro_costo,
                id_oficina = v_parametros.id_oficina,
                id_depto = v_parametros.id_depto,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                id_usuario_ai = v_parametros._id_usuario_ai,
                usuario_ai = v_parametros._nombre_usuario_ai,
                codigo_ant = v_parametros.codigo_ant,
                nro_serie = v_parametros.nro_serie,
                marca = v_parametros.marca,
                id_proyecto = v_parametros.id_proyecto,
                --caraceristicas = v_parametros._nombre_usuario_ai,
                cantidad_af = v_parametros.cantidad_af,
                id_unidad_medida = v_parametros.id_unidad_medida,
                monto_compra_orig_100 = v_parametros.monto_compra_orig_100,
                nro_cbte_asociado = v_parametros.nro_cbte_asociado,
                fecha_cbte_asociado = v_parametros.fecha_cbte_asociado,
                id_grupo = v_parametros.id_grupo,
                id_ubicacion = v_parametros.id_ubicacion,
                id_grupo_clasif = v_parametros.id_grupo_clasif
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
			null as id_usuario_ai,
			cantidad_af,
			id_unidad_medida,
			monto_compra_orig_100,
			nro_cbte_asociado,
			fecha_cbte_asociado,
			id_grupo,
			id_centro_costo,
			id_ubicacion,
			id_grupo_clasif
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
              COALESCE(ent.nombre, '') as nombre_entidad,
              kaf.descripcion
             into
               v_rec_af
            from kaf.tactivo_fijo  kaf
            inner join param.tdepto dep on dep.id_depto = kaf.id_depto 
            left join param.tentidad ent on ent.id_entidad = dep.id_entidad
			where id_activo_fijo = v_parametros.id_activo_fijo;
            
            --Recuperar configuracion del reporte de codigo de barrar por defecto de variable global
             v_clase_reporte = pxp.f_get_variable_global('kaf_clase_reporte_codigo');

            --Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Código recuperado'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo',v_rec_af.codigo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo_ant',v_rec_af.codigo_ant::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'denominacion',v_rec_af.denominacion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'nombre_depto',v_rec_af.nombre_depto::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'nombre_entidad',v_rec_af.nombre_entidad::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'v_clase_reporte',COALESCE(v_clase_reporte,'RCodigoQRAF')::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'descripcion',v_rec_af.descripcion::varchar);

            --Devuelve la respuesta
            return v_resp;
        
        end; 

    /*********************************    
 	#TRANSACCION:  'SKA_PHOTO_UPL'
 	#DESCRIPCION:	Upload de l a foto principal
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

    /*********************************    
	#TRANSACCION:  'SKA_AFIJ_CLO'
	#DESCRIPCION:   Clonación de activos fijos
	#AUTOR:         RCM
	#FECHA:         13/06/2017
	***********************************/

	elsif(p_transaccion='SKA_AFIJ_CLO')then

    	begin
        	--Verifica existencia del movimiento
          	if not exists(select 1 from kaf.tactivo_fijo
                			where id_activo_fijo = v_parametros.id_activo_fijo) then
            	raise exception 'Activo Fijo no encontrado';
          	end if;

          	--Obtención de datos del activo fijo principal
          	select
	        id_persona,
			id_proveedor,
			fecha_compra,
			--monto_vigente,
			id_cat_estado_fun,
			ubicacion,
			--vida_util,
			documento,
			observaciones,
			--fecha_ult_dep,
			monto_rescate,
			denominacion,
			id_funcionario,
			id_deposito,
			monto_compra_orig,
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
			p_id_usuario,
			null, -- nombre_usuario_ai,
			null, --id_usuario_ai
			codigo_ant,
			marca,
			nro_serie,
			NULL,
            id_proyecto,
            cantidad_af,
            id_unidad_medida,
            monto_compra_orig_100,
            nro_cbte_asociado,
            fecha_cbte_asociado,
            id_grupo,
            id_centro_costo,
            id_ubicacion,
            id_grupo_clasif
	        into v_rec_af
	        from kaf.tactivo_fijo
	        where id_activo_fijo = v_parametros.id_activo_fijo;
          
          	for i in 1..v_parametros.cantidad_clon loop
          		--Activo fijo
		        v_id_activo_fijo = kaf.f_insercion_af(p_id_usuario, hstore(v_rec_af));
		        --Características
		        insert into kaf.tactivo_fijo_caract(
				clave,
				valor,
				id_activo_fijo,
				estado_reg,
				fecha_reg,
				id_usuario_reg
	          	)
		        select
				clave,
				valor,
				v_id_activo_fijo,
				estado_reg,
				now(),
				p_id_usuario
		        from kaf.tactivo_fijo_caract
		        where id_activo_fijo = v_parametros.id_activo_fijo;

			end loop;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Activos fijos clonados (id_activo_fijo: '||v_parametros.id_activo_fijo::varchar||', cantidad: '||v_parametros.cantidad_clon::varchar||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_parametros.id_activo_fijo::varchar);
                
            --Devuelve la respuesta
            return v_resp;

      end; 

    /*********************************    
 	#TRANSACCION:  'SKA_AFQR_DAT'
 	#DESCRIPCION:	Consulta de datos desde QR
 	#AUTOR:			RCM
 	#FECHA:			24/07/2017
	***********************************/

	elsif(p_transaccion='SKA_AFQR_DAT')then

		begin

			if not exists(select 1 from kaf.tactivo_fijo
							where id_activo_fijo = v_parametros.id_activo_fijo) then
				raise exception 'Activo fijo no existente';
			end if;

			select
			af.id_activo_fijo, af.codigo, af.denominacion, af.descripcion, af.fecha_compra,
			ofi.codigo || ' - ' ||ofi.nombre as oficina_asignacion,
			af.ubicacion, af.fecha_ini_dep, 
			af.monto_compra_orig,
			af.monto_compra_orig_100,
			af.nro_cbte_asociado,
			af.fecha_cbte_asociado,
			mon.codigo as moneda,
			af.vida_util_original,
			COALESCE(round(afvi.monto_vigente_real_af,2), af.monto_compra) as valor_actual,
			af.vida_util_original - COALESCE(afvi.vida_util_real_af, af.vida_util_original) as vida_util_restante,
			fun.desc_funcionario2 as responsable,
			fun.nombre_cargo as cargo,
			fun.oficina_nombre as oficina_responsable
			into v_rec_af
			from kaf.tactivo_fijo af
			left join kaf.f_activo_fijo_vigente() afvi
            on afvi.id_activo_fijo = af.id_activo_fijo
            and afvi.id_moneda = af.id_moneda_orig
			inner join orga.toficina ofi
			on af.id_oficina = ofi.id_oficina
			inner join param.tmoneda mon
			on mon.id_moneda = af.id_moneda_orig
			left join orga.vfuncionario_cargo_lugar fun
			on fun.id_funcionario = af.id_funcionario
			where af.id_activo_fijo = v_parametros.id_activo_fijo
			order by fun.fecha_asignacion desc limit 1;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Consulta QR realizada'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',v_rec_af.id_activo_fijo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo',v_rec_af.codigo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'denominacion',v_rec_af.denominacion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'descripcion',v_rec_af.descripcion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'fecha_compra',v_rec_af.fecha_compra::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'oficina_asignacion',v_rec_af.oficina_asignacion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'ubicacion',v_rec_af.ubicacion::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'fecha_ini_dep',v_rec_af.fecha_ini_dep::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'monto_compra_orig',v_rec_af.monto_compra_orig::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'monto_compra_orig_100',v_rec_af.monto_compra_orig_100::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'nro_cbte_asociado',v_rec_af.nro_cbte_asociado::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'fecha_cbte_asociado',v_rec_af.fecha_cbte_asociado::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'moneda',v_rec_af.moneda::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'vida_util_original',v_rec_af.vida_util_original::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'valor_actual',v_rec_af.valor_actual::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'vida_util_restante',v_rec_af.vida_util_restante::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'responsable',v_rec_af.responsable::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'cargo',v_rec_af.cargo::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'oficina_responsable',v_rec_af.oficina_responsable::varchar);
              
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