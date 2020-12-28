CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_det_original_sel"(
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_mod_masivo_det_original_sel
 DESCRIPCION:   Funcion que devuelve conjuntos de registros de las consultas relacionadas con la tabla 'kaf.tactivo_mod_masivo_det_original'
 AUTOR:         (rchumacero)
 FECHA:         10-12-2020 03:43:46
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
***************************************************************************/
DECLARE

    v_consulta            VARCHAR;
    v_parametros          RECORD;
    v_nombre_funcion      TEXT;
    v_resp                VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_det_original_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_MADOR_SEL'
     #DESCRIPCION:    Consulta de datos
     #AUTOR:        rchumacero
     #FECHA:        10-12-2020 03:43:46
    ***********************************/

    IF (p_transaccion='SKA_MADOR_SEL') THEN

        BEGIN
            --Sentencia de la consulta
            v_consulta:='SELECT
                        mador.id_activo_mod_masivo_det_original,
                        mador.estado_reg,
                        mador.id_activo_mod_masivo_det,
                        mador.id_activo_fijo,
                        mador.codigo,
                        mador.nro_serie,
                        mador.marca,
                        mador.denominacion,
                        mador.descripcion,
                        mador.id_unidad_medida,
                        mador.observaciones,
                        mador.ubicacion,
                        mador.id_ubicacion,
                        mador.id_funcionario,
                        mador.id_proveedor,
                        mador.fecha_compra,
                        mador.documento,
                        mador.cbte_asociado,
                        mador.fecha_cbte_asociado,
                        mador.id_grupo,
                        mador.id_grupo_clasif,
                        mador.id_centro_costo,
                        mador.id_usuario_reg,
                        mador.fecha_reg,
                        mador.id_usuario_ai,
                        mador.usuario_ai,
                        mador.id_usuario_mod,
                        mador.fecha_mod,
                        usu1.cuenta as usr_reg,
                        usu2.cuenta as usr_mod,
                        umed.codigo as desc_unidad_medida,
                        ubi.codigo as desc_ubicacion,
                        fun.desc_funcionario1 as desc_funcionario,
                        pro.desc_proveedor,
                        gru.codigo || '' - '' || gru.nombre as desc_grupo,
                        gru1.codigo || '' - '' || gru1.nombre as desc_grupo_clasif,
                        cc.codigo_tcc as desc_centro_costo
                        FROM kaf.tactivo_mod_masivo_det_original mador
                        JOIN segu.tusuario usu1 ON usu1.id_usuario = mador.id_usuario_reg
                        LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = mador.id_usuario_mod
                        LEFT JOIN param.tunidad_medida umed
                        ON umed.id_unidad_medida = mador.id_unidad_medida
                        LEFT JOIN kaf.tubicacion ubi
                        ON ubi.id_ubicacion = mador.id_ubicacion
                        LEFT JOIN orga.vfuncionario fun
                        ON fun.id_funcionario = mador.id_funcionario
                        LEFT JOIN param.vproveedor pro
                        ON pro.id_proveedor = mador.id_proveedor
                        LEFT JOIN kaf.tgrupo gru
                        ON gru.id_grupo = mador.id_grupo
                        LEFT JOIN kaf.tgrupo gru1
                        ON gru1.id_grupo = mador.id_grupo_clasif
                        LEFT JOIN param.vcentro_costo cc
                        ON cc.id_centro_costo = mador.id_centro_costo
                        WHERE  ';

            --Definicion de la respuesta
            v_consulta:=v_consulta||v_parametros.filtro;
            v_consulta:=v_consulta||' order by ' ||v_parametros.ordenacion|| ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_MADOR_CONT'
     #DESCRIPCION:    Conteo de registros
     #AUTOR:        rchumacero
     #FECHA:        10-12-2020 03:43:46
    ***********************************/

    ELSIF (p_transaccion='SKA_MADOR_CONT') THEN

        BEGIN
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT COUNT(id_activo_mod_masivo_det_original)
                         FROM kaf.tactivo_mod_masivo_det_original mador
                         JOIN segu.tusuario usu1 ON usu1.id_usuario = mador.id_usuario_reg
                         LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = mador.id_usuario_mod
                         LEFT JOIN param.tunidad_medida umed
                        ON umed.id_unidad_medida = mador.id_unidad_medida
                        LEFT JOIN kaf.tubicacion ubi
                        ON ubi.id_ubicacion = mador.id_ubicacion
                        LEFT JOIN orga.vfuncionario fun
                        ON fun.id_funcionario = mador.id_funcionario
                        LEFT JOIN param.vproveedor pro
                        ON pro.id_proveedor = mador.id_proveedor
                        LEFT JOIN kaf.tgrupo gru
                        ON gru.id_grupo = mador.id_grupo
                        LEFT JOIN kaf.tgrupo gru1
                        ON gru1.id_grupo = mador.id_grupo_clasif
                        LEFT JOIN param.vcentro_costo cc
                        ON cc.id_centro_costo = mador.id_centro_costo
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
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_det_original_sel"(integer, integer, character varying, character varying) OWNER TO postgres;
