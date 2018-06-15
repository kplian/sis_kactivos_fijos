CREATE OR REPLACE FUNCTION kaf.f_get_depreciacion_acum_gest_ant (
  p_id_activo_fijo_valor integer,
  p_id_afvs varchar,
  p_id_moneda integer,
  p_fecha date
)
RETURNS numeric AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.f_get_depreciacion_acum_gest_ant
 DESCRIPCION:   Devuelve la depreciación acumulada de la gestión anterior. Si no es dependiente, devuelve la dep acum del p_id_activo_fijo_valor.
 				Si es dependiente, busca la dep acum de los IDs de losafv padres (p_id_afvs)
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
    v_depreciacion_acum_gest_ant numeric;
    v_sql varchar;

BEGIN

	--Obtiene la bandera 'dependiente' del afv
	select dependiente
    into v_dependiente
    from kaf.tactivo_fijo_valores
    where id_activo_fijo_valor = p_id_activo_fijo_valor;
    
    if coalesce(v_dependiente,'') = '' then
    	raise exception 'El AFV: % , no está definido si es dependiente o no para obtener sus datos',p_id_activo_fijo_valor;
    elsif coalesce(v_dependiente,'')='no' then

		select depreciacion_acum
        into v_depreciacion_acum_gest_ant
        from kaf.tmovimiento_af_dep
        where id_activo_fijo_valor = p_id_activo_fijo_valor
        and id_moneda_dep = p_id_moneda
        and date_trunc('month',fecha) = date_trunc('month',('01-12-'||extract(year from p_fecha::date)::integer -1 )::date);
        
    else
    
		v_sql = 'select depreciacion_acum
                from kaf.tmovimiento_af_dep
                where (id_activo_fijo_valor = '||p_id_activo_fijo_valor;
        
        if coalesce(p_id_afvs,'')<>'' then
        	v_sql = v_sql || ' or id_activo_fijo_valor in ('||p_id_afvs||')';
        end if;
        
        v_sql = v_sql || ')
        		and id_moneda_dep = '||p_id_moneda||'
                and date_trunc(''month'',fecha) = date_trunc(''month'',(''01-12-''||extract(year from '''||p_fecha||'''::date)::integer -1 )::date)';
        raise notice 'FF: %',v_sql;
        execute(v_sql) into v_depreciacion_acum_gest_ant;

    end if;
    
    return coalesce(v_depreciacion_acum_gest_ant,0);

END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;