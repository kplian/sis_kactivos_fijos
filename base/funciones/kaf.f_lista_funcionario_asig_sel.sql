CREATE OR REPLACE FUNCTION kaf.f_lista_funcionario_asig_sel (
  p_id_usuario integer,
  p_id_tipo_estado integer,
  p_fecha date = now(),
  p_id_estado_wf integer = NULL::integer,
  p_count boolean = false,
  p_limit integer = 1,
  p_start integer = 0,
  p_filtro varchar = '0=0'::character varying
)
RETURNS SETOF record AS
$body$
/**************************************************************************
 SISTEMA ENDESIS - SISTEMA DE ...
***************************************************************************
 SCRIPT:        kaf.f_lista_funcionario_asig_sel
 DESCRIPCIÓN:   Lista al funcionario al que se le asigna el activo fijo
 AUTOR:         RCM
 FECHA:         04/10/2017
 COMENTARIOS:   
***************************************************************************
 HISTORIA DE MODIFICACIONES:

 DESCRIPCIÓN:
 AUTOR:       
 FECHA:      

***************************************************************************/

-------------------------
-- CUERPO DE LA FUNCIÓN --
--------------------------

-- PARÁMETROS FIJOS
/*

  p_id_usuario integer,                                identificador del actual usuario de sistema
  p_id_tipo_estado integer,                            idnetificador del tipo estado del que se quiere obtener el listado de funcionario  (se correponde con tipo_estado que le sigue a id_estado_wf proporcionado)                       
  p_fecha date = now(),                                fecha  --para verificar asginacion de cargo con organigrama
  p_id_estado_wf integer = NULL::integer,              identificaro de estado_wf actual en el proceso_wf
  p_count boolean = false,                             si queremos obtener numero de funcionario = true por defecto false
  p_limit integer = 1,                                 los siguiente son parametros para filtrar en la consulta
  p_start integer = 0,
  p_filtro varchar = '0=0'::character varying

*/

DECLARE

    v_nombre_funcion varchar;
    v_id_funcionario  integer;
    v_consulta varchar;
    v_rec       record;
    v_resp varchar;

BEGIN

    v_nombre_funcion ='kaf.f_lista_funcionario_asig_sel';

    --Recuperación del funcionario a asignar
    select
    coalesce(id_funcionario_dest,id_funcionario)
    into
    v_id_funcionario
    from kaf.tmovimiento
    where id_estado_wf = p_id_estado_wf;
    
   
    if not p_count then
    
        v_consulta:='select
                    fun.id_funcionario,
                    fun.desc_funcionario1 as desc_funcionario,
                    ''Destinatario''::text  as desc_funcionario_cargo,
                    1 as prioridad
                    from orga.vfuncionario fun
                    where fun.id_funcionario = '||COALESCE(v_id_funcionario,0)::varchar||'
                    and '||p_filtro||'
                    limit '|| p_limit::varchar||' offset '||p_start::varchar; 


        for v_rec in execute (v_consulta) loop
            return next v_rec;
        end loop;
                      
    else

        v_consulta='select
                    COUNT(fun.id_funcionario) as total
                    FROM orga.vfuncionario fun
                    WHERE fun.id_funcionario = '||COALESCE(v_id_funcionario,0)::varchar||'
                    and '||p_filtro;   
                                  
        for v_rec in execute (v_consulta) loop
            return next v_rec;
        end loop;
                       
    end if;
        
       
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
COST 100 ROWS 1000;