CREATE OR REPLACE FUNCTION kaf.f_get_datos_deprec_ant (
  p_id_activo_fijo_valor integer,
  p_fecha date,
  out o_dep_acum_ant numeric,
  out o_inc_dep_actualiz numeric
)
RETURNS record AS
$body$
DECLARE

    v_nombre_funcion  varchar;
    v_fecha_inf date;
    v_fecha_sup date;
    v_gestion_ant integer;

BEGIN
    
    v_nombre_funcion = 'kaf.f_get_datos_deprec_ant';

    --Obtiene las fechas para la consulta
    v_gestion_ant = extract(year from p_fecha)::integer - 1;
    v_fecha_inf = '01/01/'||v_gestion_ant;
    v_fecha_sup = '31/12/'||v_gestion_ant;

    --Obtiene la depreciacion acumulada de la anterior gestion
    select coalesce(depreciacion_acum,0)
    into o_dep_acum_ant
    from kaf.tmovimiento_af_dep
    where id_activo_fijo_valor = p_id_activo_fijo_valor
    and date_trunc('month', fecha) = date_trunc('month', v_fecha_sup);

    --Obtiene el incremento de la depreciacion acumulada de la gestion anterior
    select sum(depreciacion_acum_actualiz - depreciacion_acum_ant)
    into o_inc_dep_actualiz
    from kaf.tmovimiento_af_dep
    where id_activo_fijo_valor = p_id_activo_fijo_valor
    and date_trunc('month', fecha) between date_trunc('month', v_fecha_inf) and date_trunc('month', v_fecha_sup);

    RETURN ;
END
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;