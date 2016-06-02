CREATE OR REPLACE FUNCTION "kaf"."ft_clasificacion_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$



/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos - K
 FUNCION: 		kaf.ft_clasificacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tclasificacion'
 AUTOR: 		 (admin)
 FECHA:	        09-11-2015 01:22:17
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
	v_id_clasificacion		integer;
	v_codigo				varchar;
	v_sep					varchar;
	v_nivel					integer;
	v_rec 					record;
	v_cod_fin_padre			varchar;
	v_ins 					boolean;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_clasificacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);
    v_sep = '.';

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	if(p_transaccion='SKA_CLAF_INS')then
					
        begin

        	--Obtiene el código del padre
        	select codigo, substring(codigo from length(codigo)-3 for 4)
        	into v_codigo, v_cod_fin_padre
        	from kaf.tclasificacion
        	where id_clasificacion = v_parametros.id_clasificacion_fk;

        	if v_codigo is null then
        		v_codigo = v_parametros.codigo;
        	else
        		v_codigo = coalesce(v_codigo,'')||v_sep||v_parametros.codigo;
        	end if;

        	--Sentencia de la insercion
        	insert into kaf.tclasificacion(
			id_clasificacion_fk,
			id_cat_metodo_dep,
			id_concepto_ingas,
			codigo,
			nombre,
			vida_util,
			correlativo_act,
			monto_residual,
			tipo,
			final,
			icono,
			id_usuario_reg,
			id_usuario_mod,
			fecha_reg,
			fecha_mod,
			estado_reg,
			id_usuario_ai,
			usuario_ai,
			descripcion
          	) values(
          	v_parametros.id_clasificacion_fk,
			v_parametros.id_cat_metodo_dep,
			v_parametros.id_concepto_ingas,
			v_codigo,
			v_parametros.nombre,
			v_parametros.vida_util,
			0,
			v_parametros.monto_residual,
			v_parametros.tipo,
			v_parametros.final,
			v_parametros.icono,
			p_id_usuario,
			null,
			now(),
			null,
			'activo',
			null,
			null,
			v_parametros.descripcion
			)RETURNING id_clasificacion into v_id_clasificacion;

			--Excepcion CBOL, replica de la clasificacion
			v_ins=true;
			if pxp.f_get_variable_global('kaf_clasif_replicar') = 'true' then
				v_nivel = length(regexp_replace(v_codigo, '[^\.]', '', 'g'))+1;
				if v_nivel = 3 or v_nivel = 4 then
					for v_rec in (select * from kaf.tclasificacion 
								where length(regexp_replace(codigo, '[^\.]', '', 'g'))+1 = v_nivel-1) loop
						if not exists(select 1 from kaf.tclasificacion where codigo = v_rec.codigo||'.'||v_parametros.codigo) then

							--Verifica el nivel para hacer la insercion
							if v_nivel = 4 then
								if substring(v_rec.codigo from length(v_rec.codigo)-3 for 4) != v_cod_fin_padre then
									v_ins = false;
								end if;
							end if;


							if v_ins then
								insert into kaf.tclasificacion(
								id_clasificacion_fk,
								id_cat_metodo_dep,
								id_concepto_ingas,
								codigo,
								nombre,
								vida_util,
								correlativo_act,
								monto_residual,
								tipo,
								final,
								icono,
								id_usuario_reg,
								id_usuario_mod,
								fecha_reg,
								fecha_mod,
								estado_reg,
								id_usuario_ai,
								usuario_ai,
								descripcion
					          	) values(
					          	v_rec.id_clasificacion,
								v_parametros.id_cat_metodo_dep,
								v_parametros.id_concepto_ingas,
								v_rec.codigo||'.'||v_parametros.codigo,
								v_parametros.nombre,
								v_parametros.vida_util,
								0,
								v_parametros.monto_residual,
								v_parametros.tipo,
								v_parametros.final,
								v_parametros.icono,
								p_id_usuario,
								null,
								now(),
								null,
								'activo',
								null,
								null,
								v_parametros.descripcion
								);
							end if;
							v_ins = true;
							
						end if;
					end loop;
				end if;
			end if;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación almacenado(a) con exito (id_clasificacion'||v_id_clasificacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_id_clasificacion::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAF_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tclasificacion set
			id_clasificacion_fk = v_parametros.id_clasificacion_fk,
			id_cat_metodo_dep = v_parametros.id_cat_metodo_dep,
			id_concepto_ingas = v_parametros.id_concepto_ingas,
			codigo  = v_parametros.codigo,
			nombre = v_parametros.nombre,
			vida_util = v_parametros.vida_util,
			correlativo_act = v_parametros.correlativo_act,
			monto_residual = v_parametros.monto_residual,
			tipo = v_parametros.tipo,
			final = v_parametros.final,
			icono = v_parametros.icono,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			estado_reg = 'activo',
			--id_usuario_ai = v_parametros.id_usuario_ai,
			--usuario_ai = v_parametros.usuario_ai,
			descripcion = v_parametros.descripcion
			where id_clasificacion=v_parametros.id_clasificacion;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_CLAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		09-11-2015 01:22:17
	***********************************/

	elsif(p_transaccion='SKA_CLAF_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tclasificacion
            where id_clasificacion=v_parametros.id_clasificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
              
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
ALTER FUNCTION "kaf"."ft_clasificacion_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
