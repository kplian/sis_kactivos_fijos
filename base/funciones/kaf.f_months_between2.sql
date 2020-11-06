/**************************************************************************
 SISTEMA:       Sistema de Proyectos
 FUNCION:       kaf.f_months_between2
 DESCRIPCION:   Calcula la diferencia de meses entre dos fechas
 AUTOR:         RCM
 FECHA:         14/08/2020
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS     EMPRESA  FECHA        AUTOR       DESCRIPCION
 #AF-10 KAF     ETR      14/08/2020   RCM         Creación del archivo
***************************************************************************/
CREATE OR REPLACE FUNCTION kaf.f_months_between2 (t_start timestamp, t_end timestamp)
RETURNS integer
AS $$
    SELECT
        (
            12 * extract('years' from a.i) + extract('months' from a.i)
        )::integer
    from (
        values (justify_interval($2 - $1))
    ) as a (i)
$$
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;
