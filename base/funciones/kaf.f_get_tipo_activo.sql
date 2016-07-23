CREATE OR REPLACE FUNCTION kaf.f_get_tipo_activo (
  p_id_activo_fijo integer
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_get_tipo_activo
 DESCRIPCION:   Obtiene codigo del tipo de activo
 AUTOR:          (RCM)
 FECHA:         25/07/2016
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/
DECLARE
    
    v_codigo varchar;
    i integer;
    v_nivel integer;
    v_cod_tipo varchar;
    v_resp_cod varchar;
    v_resp varchar;

BEGIN
    
    --1.Obtiene el codigo del activo fijo
    select codigo
    into v_codigo
    from kaf.tactivo_fijo
    where id_activo_fijo = p_id_activo_fijo;

    --Obtiene variable de global del nivel del tipo de activo
    if pxp.f_get_variable_global('kaf_nivel_tipo_activo') = 'NULL' then
    	v_nivel = 1;
    else 
    	v_nivel = pxp.f_get_variable_global('kaf_nivel_tipo_activo')::integer;
    end if;

    --Obtiene el codigo del tipo
    v_cod_tipo='';
    for i in 1..v_nivel loop
    	v_cod_tipo = v_cod_tipo||split_part(v_codigo, '.', i);
    	if i < v_nivel then
    		v_cod_tipo = v_cod_tipo || '.';
    	end if;
    end loop;
    v_resp_cod = split_part(v_codigo, '.', 3);

    --Obtiene la descripcion del tipo de activo
    select nombre
    into v_resp 
    from kaf.tclasificacion
    where codigo = v_cod_tipo;

    v_resp = v_resp_cod||' - '||v_resp;

    return v_resp;

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;