CREATE OR REPLACE FUNCTION kaf.f_get_ids_afv_dependiente (
  p_id_activo_fijo_valor integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_get_ids_afv_dependiente
 DESCRIPCION:   Devuelve los ids de los afv padres del afv dependiente
 AUTOR: 		RCM
 FECHA:	        05/06/2018
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/
DECLARE

	v_nombre_funcion   	text;
	v_resp				varchar;
    v_dependiente varchar;
    v_ids varchar;

BEGIN

	v_nombre_funcion = 'kaf.f_get_depreciacion_acum_gest_ant';
    
    --Obtiene la bandera 'dependiente' del afv
	select dependiente
    into v_dependiente
    from kaf.tactivo_fijo_valores
    where id_activo_fijo_valor = p_id_activo_fijo_valor;
    
    --Verificación de la bandera
    if coalesce(v_dependiente,'') = '' then
    
    	raise exception 'El AFV: % , no está definido si es dependiente o no para obtener la depreciación acumulada de la anterior gestión',p_id_activo_fijo_valor;
        
    elsif coalesce(v_dependiente,'')='no' then
    
		return null;
        
    else
    	
        --Obtiene la depreciación acumulada en los ids afv del activo fijo valor dependiente
        WITH RECURSIVE t(id,id_fk,codigo,n) AS (
            SELECT l.id_activo_fijo_valor,l.id_activo_fijo_valor_original, l.codigo,1
            FROM kaf.tactivo_fijo_valores l
            WHERE l.id_activo_fijo_valor = p_id_activo_fijo_valor
            UNION ALL
            SELECT l.id_activo_fijo_valor,l.id_activo_fijo_valor_original, l.codigo,n+1
            FROM kaf.tactivo_fijo_valores l, t
            WHERE l.id_activo_fijo_valor = t.id_fk
        )
        SELECT pxp.list(id_fk::varchar)::varchar
        INTO v_ids
        FROM t;
        
    end if;
    
	--Respuesta
    return v_ids;

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
STABLE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;