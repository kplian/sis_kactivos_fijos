CREATE OR REPLACE FUNCTION "kaf"."ft_movimiento_motivo_ime" (	
				p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_motivo_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_motivo'
 AUTOR: 		 (admin)
 FECHA:	        18-03-2016 07:25:59
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
	v_id_movimiento_motivo	integer;
			    
BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_motivo_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************    
 	#TRANSACCION:  'SKA_MMOT_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 07:25:59
	***********************************/

	if(p_transaccion='SKA_MMOT_INS')then
					
        begin
        	--Sentencia de la insercion
        	insert into kaf.tmovimiento_motivo(
			id_cat_movimiento,
			motivo,
			estado_reg,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			id_usuario_mod,
			fecha_mod,
			plantilla_cbte
          	) values(
			v_parametros.id_cat_movimiento,
			v_parametros.motivo,
			'activo',
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null,
			v_parametros.plantilla_cbte
			)RETURNING id_movimiento_motivo into v_id_movimiento_motivo;
			
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Motivo almacenado(a) con exito (id_movimiento_motivo'||v_id_movimiento_motivo||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_motivo',v_id_movimiento_motivo::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MMOT_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 07:25:59
	***********************************/

	elsif(p_transaccion='SKA_MMOT_MOD')then

		begin
			--Sentencia de la modificacion
			update kaf.tmovimiento_motivo set
			id_cat_movimiento = v_parametros.id_cat_movimiento,
			motivo = v_parametros.motivo,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			plantilla_cbte = v_parametros.plantilla_cbte
			where id_movimiento_motivo=v_parametros.id_movimiento_motivo;
               
			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Motivo modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_motivo',v_parametros.id_movimiento_motivo::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
		end;

	/*********************************    
 	#TRANSACCION:  'SKA_MMOT_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin	
 	#FECHA:		18-03-2016 07:25:59
	***********************************/

	elsif(p_transaccion='SKA_MMOT_ELI')then

		begin
			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_motivo
            where id_movimiento_motivo=v_parametros.id_movimiento_motivo;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Motivo eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_motivo',v_parametros.id_movimiento_motivo::varchar);
              
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
ALTER FUNCTION "kaf"."ft_movimiento_motivo_ime"(integer, integer, character varying, character varying) OWNER TO postgres;
