CREATE OR REPLACE FUNCTION kaf.f_get_afv_padre (
  p_id_activo_fijo_valor integer
)
RETURNS integer AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_get_afv_padre
 DESCRIPCION:   Devuelve el ID del activo fijo valor padre
 AUTOR:         RCM
 FECHA:         29/05/2018
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/
DECLARE

    v_id integer;
    v_dependiente varchar;

BEGIN

    --Obtiene la bandera 'dependiente' del afv
	select dependiente
    into v_dependiente
    from kaf.tactivo_fijo_valores
    where id_activo_fijo_valor = p_id_activo_fijo_valor;
    
    --Verificación de la bandera
    if coalesce(v_dependiente,'') = '' then
    	raise exception 'El AFV: % , no está definido si es dependiente o no para obtener sus datos',p_id_activo_fijo_valor;
    elsif coalesce(v_dependiente,'')='no' then
        --Si no es dependiente devuelve directamente el id del afv enviado
    	return p_id_activo_fijo_valor;
    end if;

	--Si llega aquí es que es un afv dependiente, y busca su padre
    WITH RECURSIVE t(id,id_fk,codigo,n) AS (
        SELECT l.id_activo_fijo_valor,l.id_activo_fijo_valor_original, l.codigo,1
        FROM kaf.tactivo_fijo_valores l
        WHERE l.id_activo_fijo_valor = p_id_activo_fijo_valor
        UNION ALL
        SELECT l.id_activo_fijo_valor,l.id_activo_fijo_valor_original, l.codigo,n+1
        FROM kaf.tactivo_fijo_valores l, t
        WHERE l.id_activo_fijo_valor = t.id_fk
    )
    SELECT min(id_fk)
    INTO v_id
    FROM t;

	--Respuesta    
    return v_id;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;