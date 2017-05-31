--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_tipo_prorrateo_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_tipo_prorrateo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.ttipo_prorrateo'
 AUTOR: 		 (admin)
 FECHA:	        02-05-2017 08:30:44
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
	v_id_tipo_prorrateo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_tipo_prorrateo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_TIPR_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		02-05-2017 08:30:44
	***********************************/

	if(p_transaccion='SKA_TIPR_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.ttipo_prorrateo(
			descripcion,
			estado_reg,
			id_gestion,
			id_ot,
			id_activo_fijo,
			id_centro_costo,
			id_proyecto,
			factor,
			id_usuario_reg,
			usuario_ai,
			fecha_reg,
			id_usuario_ai,
			id_usuario_mod,
			fecha_mod
          	) values(
			v_parametros.descripcion,
			'activo',
			v_parametros.id_gestion,
			v_parametros.id_ot,
			v_parametros.id_activo_fijo,
			v_parametros.id_centro_costo,
			v_parametros.id_proyecto,
			v_parametros.factor,
			p_id_usuario,
			v_parametros._nombre_usuario_ai,
			now(),
			v_parametros._id_usuario_ai,
			null,
			null
							
			
			
			)RETURNING id_tipo_prorrateo into v_id_tipo_prorrateo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Prorrateo almacenado(a) con exito (id_tipo_prorrateo'||v_id_tipo_prorrateo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_prorrateo',v_id_tipo_prorrateo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPR_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		02-05-2017 08:30:44
	***********************************/

	elsif(p_transaccion='SKA_TIPR_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.ttipo_prorrateo set
			descripcion = v_parametros.descripcion,
			id_gestion = v_parametros.id_gestion,
			id_ot = v_parametros.id_ot,
			id_activo_fijo = v_parametros.id_activo_fijo,
			id_centro_costo = v_parametros.id_centro_costo,
			id_proyecto = v_parametros.id_proyecto,
			factor = v_parametros.factor,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_tipo_prorrateo=v_parametros.id_tipo_prorrateo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Prorrateo modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_prorrateo',v_parametros.id_tipo_prorrateo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_TIPR_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		02-05-2017 08:30:44
	***********************************/

	elsif(p_transaccion='SKA_TIPR_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.ttipo_prorrateo
            where id_tipo_prorrateo=v_parametros.id_tipo_prorrateo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Tipo Prorrateo eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_tipo_prorrateo',v_parametros.id_tipo_prorrateo::varchar);
              
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