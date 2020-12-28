CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_sel"(
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_mod_masivo_sel
 DESCRIPCION:   Importación/actualización de datos en forma masiva
 AUTOR:         (rchumacero)
 FECHA:         09-12-2020 20:34:43
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
****************************************************************************/
DECLARE

    v_consulta            VARCHAR;
    v_parametros          RECORD;
    v_nombre_funcion      TEXT;
    v_resp                VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_AFM_SEL'
     #DESCRIPCION:    Consulta de datos
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/
    IF (p_transaccion='SKA_AFM_SEL') THEN

        BEGIN
            --Sentencia de la consulta
            v_consulta:='SELECT
                        afm.id_activo_mod_masivo,
                        afm.estado_reg,
                        afm.id_proceso_wf,
                        afm.id_estado_wf,
                        afm.fecha,
                        afm.motivo,
                        afm.estado,
                        afm.id_usuario_reg,
                        afm.fecha_reg,
                        afm.id_usuario_ai,
                        afm.usuario_ai,
                        afm.id_usuario_mod,
                        afm.fecha_mod,
                        usu1.cuenta as usr_reg,
                        usu2.cuenta as usr_mod,
                        afm.num_tramite
                        FROM kaf.tactivo_mod_masivo afm
                        JOIN segu.tusuario usu1 ON usu1.id_usuario = afm.id_usuario_reg
                        LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = afm.id_usuario_mod
                        WHERE  ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AFM_CONT'
     #DESCRIPCION:    Conteo de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:34:43
    ***********************************/

    ELSIF (p_transaccion='SKA_AFM_CONT') THEN

        BEGIN
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT COUNT(id_activo_mod_masivo)
                         FROM kaf.tactivo_mod_masivo afm
                         JOIN segu.tusuario usu1 ON usu1.id_usuario = afm.id_usuario_reg
                         LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = afm.id_usuario_mod
                         WHERE ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;

            --Devuelve la respuesta
            RETURN v_consulta;

        END;

    ELSE

        RAISE EXCEPTION 'Transaccion inexistente';

    END IF;

EXCEPTION

    WHEN OTHERS THEN
            v_resp='';
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
            v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
            v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
            RAISE EXCEPTION '%',v_resp;
END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
