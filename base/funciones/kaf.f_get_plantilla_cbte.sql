CREATE OR REPLACE FUNCTION kaf.f_get_plantilla_cbte (
  p_id_movimiento_motivo integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_get_plantilla_cbte
 DESCRIPCION:   Obtiene el código de la Plantilla de Comprobante según el Motivo Movimiento Id
 AUTOR: 		RCM
 FECHA:	        25-08-2017
 COMENTARIOS:	
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:	
 AUTOR:			
 FECHA:		
***************************************************************************/
DECLARE

    v_resp              varchar;
    v_nombre_funcion    text;
    v_plantilla_cbte    varchar;
    v_movimiento        varchar;
    v_motivo            varchar;

BEGIN

    v_nombre_funcion = 'kaf.f_get_plantilla_cbte';

    --Ontención de datos del movimiento
    select cat.descripcion, mmot.motivo
    into v_movimiento, v_motivo
    from kaf.tmovimiento_motivo mmot
    inner join  kaf.tmovimiento mov
    on mov.id_cat_movimiento = mmot.id_cat_movimiento
    inner join param.tcatalogo cat
    on cat.id_catalogo = mov.id_cat_movimiento 
    where mmot.id_movimiento_motivo = p_id_movimiento_motivo;

    --Obtención de la plantilla
    select plantilla_cbte
    into v_plantilla_cbte
    from kaf.tmovimiento_motivo
    where id_movimiento_motivo = p_id_movimiento_motivo;

    --Verificación de existencia
    if v_plantilla_cbte is null then
        raise exception 'Plantilla de Comprobante no definida para % por %',v_movimiento,v_motivo;
    end if;

    --Verificación de existencia en el sistema de contabilidad
    if not exists(select 1 from conta.tplantilla_comprobante
                where codigo = v_plantilla_cbte) then
        raise exception 'Código de Plantilla no existente (%)',v_plantilla_cbte;
    end if;

    --Respuesta
    return v_plantilla_cbte;
    

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