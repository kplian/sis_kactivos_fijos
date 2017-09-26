--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_moneda_dep_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_moneda_dep_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmoneda_dep'
 AUTOR: 		 (admin)
 FECHA:	        20-04-2017 10:18:50
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
	v_id_moneda_dep	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_moneda_dep_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MOD_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		20-04-2017 10:18:50
	***********************************/

	if(p_transaccion='SKA_MOD_INS')then
					
        begin
            
            
        
        
        	--Sentencia de la insercion
        	insert into kaf.tmoneda_dep(
                id_moneda_act,
                actualizar,
                contabilizar,
                estado_reg,
                id_moneda,
                id_usuario_ai,
                usuario_ai,
                fecha_reg,
                id_usuario_reg,
                id_usuario_mod,
                fecha_mod,
                descripcion
          	) values(
                v_parametros.id_moneda_act,
                v_parametros.actualizar,
                v_parametros.contabilizar,
                'activo',
                v_parametros.id_moneda,
                v_parametros._id_usuario_ai,
                v_parametros._nombre_usuario_ai,
                now(),
                p_id_usuario,
                null,
                null,
                v_parametros.descripcion
							
			
			
			)RETURNING id_moneda_dep into v_id_moneda_dep;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Configuracion almacenado(a) con exito (id_moneda_dep'||v_id_moneda_dep||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_moneda_dep',v_id_moneda_dep::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOD_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		20-04-2017 10:18:50
	***********************************/

	elsif(p_transaccion='SKA_MOD_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tmoneda_dep set
                id_moneda_act = v_parametros.id_moneda_act,
                actualizar = v_parametros.actualizar,
                contabilizar = v_parametros.contabilizar,
                id_moneda = v_parametros.id_moneda,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                id_usuario_ai = v_parametros._id_usuario_ai,
                usuario_ai = v_parametros._nombre_usuario_ai,
                descripcion = v_parametros.descripcion
			where id_moneda_dep=v_parametros.id_moneda_dep;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Configuracion modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_moneda_dep',v_parametros.id_moneda_dep::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MOD_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		20-04-2017 10:18:50
	***********************************/

	elsif(p_transaccion='SKA_MOD_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmoneda_dep
            where id_moneda_dep=v_parametros.id_moneda_dep;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Configuracion eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_moneda_dep',v_parametros.id_moneda_dep::varchar);
              
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