CREATE OR REPLACE FUNCTION kaf.f_afv_crear (
  p_id_usuario integer,
  p_tipo_mov varchar,
  p_id_activo_fijo integer,
  p_id_moneda_base integer,
  p_id_movimiento_af integer,
  p_fecha date,
  p_monto numeric,
  p_vida_util integer,
  p_codigo varchar,
  p_deducible varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:   Sistema de Activos Fijos
 FUNCION:     kaf.f_afv_crear
 DESCRIPCION:   Crea el nuevo activo fijo valor del movimiento que genera la transacción
 AUTOR:     RCM
 FECHA:         14/06/2017
 COMENTARIOS: 
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION: 
 AUTOR:     
 FECHA:   
***************************************************************************/
DECLARE

    v_resp varchar;
    v_nombre_funcion text;
    v_rec record;
    v_monto_compra numeric;

BEGIN

  v_nombre_funcion = 'kaf.f_afv_crear';
    
    --Creación de los nuevos AFV para la revalorización en todas las monedas
    for v_rec in (select 
                  mod.id_moneda_dep,
                  mod.id_moneda,                      
                  mod.id_moneda_act
                  from kaf.tmoneda_dep mod                                               
                  where mod.estado_reg = 'activo') loop

      v_monto_compra = param.f_convertir_moneda(p_id_moneda_base, --moneda origen para conversion
                                                v_rec.id_moneda,   --moneda a la que sera convertido
                                                p_monto, --este monto siemrpe estara en moenda base
                                                p_fecha, 
                                                'O',-- tipo oficial, venta, compra 
                                                NULL);--defecto dos decimales   

      insert into kaf.tactivo_fijo_valores(
        id_usuario_reg,   
        fecha_reg,             
        estado_reg,
        id_activo_fijo,   
        monto_vigente_orig,    
        vida_util_orig,           
        fecha_ini_dep,
        depreciacion_mes, 
        depreciacion_per,      
        depreciacion_acum,
        monto_vigente,    vida_util,             estado,                   principal,
        monto_rescate,    id_movimiento_af,      tipo,                     codigo,
        fecha_inicio,   id_moneda_dep,         id_moneda,                  deducible
      ) values (
        p_id_usuario,      
        now(),                   
        'activo',
        p_id_activo_fijo,
        v_monto_compra,          
        p_vida_util,   
        p_fecha, -- la mejora empieza va depreciar a partir del registro del movimeinto, desde hay se contabiliza el timepo de vida de la mejora  af.fecha_ini_dep,
        0,                 
        0,                        
        0,  --10
        v_monto_compra,      
        p_vida_util,         
        'activo',                
        'si',
        1,   
        p_id_movimiento_af,  
        p_tipo_mov,               
        p_codigo,
        p_fecha,
        v_rec.id_moneda_dep,
        v_rec.id_moneda,
        p_deducible
      );

    end loop;
   
    --Definicion de la respuesta
    v_resp = pxp.f_agrega_clave(v_resp,'mensaje','AFV creados satisfactoriamente (id_activo_fijo'||p_id_activo_fijo||')'); 
    v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo',p_id_activo_fijo::varchar);

    --Devuelve la respuesta
    return v_resp;

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