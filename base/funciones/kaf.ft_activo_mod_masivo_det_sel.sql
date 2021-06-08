CREATE OR REPLACE FUNCTION "kaf"."ft_activo_mod_masivo_det_sel"(
                p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.ft_activo_mod_masivo_det_sel
 DESCRIPCION:   Importación/actualización de datos en forma masiva
 AUTOR:         (rchumacero)
 FECHA:         09-12-2020 20:36:35
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
 #ETR-2778  KAF       ETR           02/02/2021  RCM         Adición de campos para modificación de AFVs
****************************************************************************/
DECLARE

    v_consulta            VARCHAR;
    v_parametros          RECORD;
    v_nombre_funcion      TEXT;
    v_resp                VARCHAR;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_mod_masivo_det_sel';
    v_parametros = pxp.f_get_record(p_tabla);

    /*********************************
     #TRANSACCION:  'SKA_AMD_SEL'
     #DESCRIPCION:    Consulta de datos
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:35
    ***********************************/

    IF (p_transaccion='SKA_AMD_SEL') THEN

        BEGIN
            --Sentencia de la consulta
            v_consulta:='SELECT
                        amd.id_activo_mod_masivo_det,
                        amd.estado_reg,
                        amd.id_activo_mod_masivo,
                        amd.codigo,
                        amd.nro_serie,
                        amd.marca,
                        amd.denominacion,
                        amd.descripcion,
                        amd.unidad_medida,
                        amd.observaciones,
                        amd.ubicacion,
                        amd.local,
                        amd.responsable,
                        amd.proveedor,
                        amd.fecha_compra,
                        amd.documento,
                        amd.cbte_asociado,
                        amd.fecha_cbte_asociado,
                        amd.grupo_ae,
                        amd.clasificador_ae,
                        amd.centro_costo,
                        amd.id_usuario_reg,
                        amd.fecha_reg,
                        amd.id_usuario_ai,
                        amd.usuario_ai,
                        amd.id_usuario_mod,
                        amd.fecha_mod,
                        usu1.cuenta as usr_reg,
                        usu2.cuenta as usr_mod,
                        --Inicio #ETR-2778
                        amd.bs_valor_compra,
                        amd.bs_valor_inicial,
                        amd.bs_fecha_ini_dep,
                        amd.bs_vutil_orig,
                        amd.bs_vutil,
                        amd.bs_fult_dep,
                        amd.bs_fecha_fin,
                        amd.bs_val_resc,
                        amd.bs_vact_ini,
                        amd.bs_dacum_ini,
                        amd.bs_dper_ini,
                        amd.bs_inc,
                        amd.bs_inc_sact,
                        amd.bs_fechaufv_ini,
                        amd.usd_valor_compra,
                        amd.usd_valor_inicial,
                        amd.usd_fecha_ini_dep,
                        amd.usd_vutil_orig,
                        amd.usd_vutil,
                        amd.usd_fult_dep,
                        amd.usd_fecha_fin,
                        amd.usd_val_resc,
                        amd.usd_vact_ini,
                        amd.usd_dacum_ini,
                        amd.usd_dper_ini,
                        amd.usd_inc,
                        amd.usd_inc_sact,
                        amd.usd_fecha_ufv_ini,
                        amd.ufv_valor_compra,
                        amd.ufv_valor_inicial,
                        amd.ufv_fecha_ini_dep,
                        amd.ufv_vutil_orig,
                        amd.ufv_vutil,
                        amd.ufv_fult_dep,
                        amd.ufv_fecha_fin,
                        amd.ufv_val_resc,
                        amd.ufv_vact_ini,
                        amd.ufv_dacum_ini,
                        amd.ufv_dper_ini,
                        amd.ufv_inc,
                        amd.ufv_inc_sact,
                        amd.ufv_fecha_ufv_ini
                        --Fin #ETR-2778
                        FROM kaf.tactivo_mod_masivo_det amd
                        JOIN segu.tusuario usu1 ON usu1.id_usuario = amd.id_usuario_reg
                        LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = amd.id_usuario_mod
                        WHERE  ';

            --Definicion de la respuesta
            v_consulta := v_consulta || v_parametros.filtro;
            v_consulta := v_consulta || ' order by ' || v_parametros.ordenacion || ' ' || v_parametros.dir_ordenacion || ' limit ' || v_parametros.cantidad || ' offset ' || v_parametros.puntero;

            --Devuelve la respuesta
            RETURN v_consulta;

        END;

    /*********************************
     #TRANSACCION:  'SKA_AMD_CONT'
     #DESCRIPCION:    Conteo de registros
     #AUTOR:        rchumacero
     #FECHA:        09-12-2020 20:36:35
    ***********************************/

    ELSIF (p_transaccion='SKA_AMD_CONT') THEN

        BEGIN
            --Sentencia de la consulta de conteo de registros
            v_consulta:='SELECT COUNT(id_activo_mod_masivo_det)
                         FROM kaf.tactivo_mod_masivo_det amd
                         JOIN segu.tusuario usu1 ON usu1.id_usuario = amd.id_usuario_reg
                         LEFT JOIN segu.tusuario usu2 ON usu2.id_usuario = amd.id_usuario_mod
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
ALTER FUNCTION "kaf"."ft_activo_mod_masivo_det_sel"(integer, integer, character varying, character varying) OWNER TO postgres;