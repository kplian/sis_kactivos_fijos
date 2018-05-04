CREATE OR REPLACE FUNCTION kaf.f_obtener_plantilla_cbte (
  p_id_movimiento integer,
  p_numero_plantilla integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:   	Sistema de Activos Fijos
 FUNCION:     	kaf.fget_plantilla_cbte
 DESCRIPCION:   Obtiene la plantilla de comprobante
 AUTOR:      	RCM
 FECHA:         24/04/2018
 COMENTARIOS: 
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION: 
 AUTOR:     
 FECHA:   
***************************************************************************/
DECLARE

	v_nombre_funcion	text;
    v_id_cat_movimiento integer;
    v_plantilla			varchar;
    v_rec 				record;
    v_resp              varchar;

BEGIN
  
	v_nombre_funcion = 'kaf.f_obtener_plantilla_cbte';
    
    --Obtención del motivo del movimiento
    select
    id_cat_movimiento
    into
    v_id_cat_movimiento
    from kaf.tmovimiento
    where id_movimiento = p_id_movimiento;
    
    --Obtención de la plantilla de cbte
    select
    plantilla_cbte_uno, plantilla_cbte_dos, plantilla_cbte_tres
    into
    v_rec
    from kaf.tmovimiento_tipo
    where id_cat_movimiento = v_id_cat_movimiento;
    
    --Elección de la plantilla
    if p_numero_plantilla = 1 then
		v_plantilla = v_rec.plantilla_cbte_uno;
    elsif p_numero_plantilla = 2 then
		v_plantilla = v_rec.plantilla_cbte_dos;    
    elsif p_numero_plantilla = 3 then
    	v_plantilla = v_rec.plantilla_cbte_tres;
    else
    	raise exception 'Número de plantilla inexistente';
    end if;

    --Verificación de existencia de la plantilla
    if v_plantilla is null then
        raise exception 'Plantilla inexistente';
    end if;
    
    --Respuesta
    return v_plantilla;

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