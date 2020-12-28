CREATE OR REPLACE FUNCTION "kaf"."f_actualizacion_masiva_activos" (
    p_id_usuario integer, p_id_activo_mod_masivo integer)
RETURNS character varying AS
$BODY$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos
 FUNCION:       kaf.f_actualizacion_masiva_activos
 DESCRIPCION:   Funcion para realizar la actualización de los datos
 AUTOR:         (rchumacero)
 FECHA:         10-12-2020 20:34:43
 COMENTARIOS:
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
****************************************************************************/
DECLARE

    v_nro_requerimiento        INTEGER;
    v_resp                     VARCHAR;
    v_nombre_funcion           TEXT;
    v_mensaje_error            TEXT;
    v_update                   TEXT;
    v_rec                      RECORD;
    v_dinamico                 VARCHAR;
    v_id_activo_fijo           INTEGER;
    v_unidad_medida            TEXT;
    v_local                    TEXT;
    v_responsable               TEXT;
    v_proveedor                TEXT;
    v_grupo_ae                 TEXT;
    v_clasificador_ae          TEXT;
    v_centro_costo             TEXT;
    v_centro_costo_gestion     TEXT;


BEGIN

    v_nombre_funcion = 'kaf.f_actualizacion_masiva_activos';

    IF NOT EXISTS(SELECT 1 FROM kaf.tactivo_mod_masivo
                WHERE id_activo_mod_masivo = p_id_activo_mod_masivo) THEN
        RAISE EXCEPTION 'No se encuentran datos para la actualización';
    END IF;

    --Verificación de integridad de los datos
    --id_unidad_medida INTEGER,
    SELECT pxp.list(amm.unidad_medida)
    INTO v_unidad_medida
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.unidad_medida), '') <> '' AND amm.unidad_medida <> '#borrar')
    AND LOWER(TRIM(amm.unidad_medida)) NOT IN (SELECT LOWER(TRIM(codigo))
                                                FROM param.tunidad_medida);

    --id_ubicacion INTEGER, --local
    SELECT pxp.list(amm.local)
    INTO v_local
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.local), '') <> ''  AND amm.local <> '#borrar')
    AND LOWER(TRIM(amm.local)) NOT IN (SELECT LOWER(TRIM(codigo))
                                        FROM kaf.tubicacion);

    --id_funcionario INTEGER,
    SELECT pxp.list(amm.responsable)
    INTO v_responsable
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.responsable), '') <> '' AND amm.responsable <> '#borrar')
    AND LOWER(TRIM(amm.responsable)) NOT IN (SELECT LOWER(TRIM(codigo))
                                        FROM orga.tfuncionario);

    --id_proveedor INTEGER,
    SELECT pxp.list(amm.proveedor)
    INTO v_proveedor
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.proveedor), '') <> '' AND amm.proveedor <> '#borrar')
    AND LOWER(TRIM(amm.proveedor)) NOT IN (SELECT LOWER(TRIM(codigo))
                                        FROM param.tproveedor);

    --id_grupo INTEGER, --grupo_ae
    SELECT pxp.list(amm.grupo_ae)
    INTO v_grupo_ae
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.grupo_ae), '') <> '' AND amm.grupo_ae <> '#borrar')
    AND LOWER(TRIM(amm.grupo_ae)) NOT IN (SELECT LOWER(TRIM(codigo))
                                        FROM kaf.tgrupo
                                        WHERE tipo = 'grupo')
    AND '0' || LOWER(TRIM(amm.grupo_ae)) NOT IN (SELECT LOWER(TRIM(codigo))
                                        FROM kaf.tgrupo
                                        WHERE tipo = 'grupo');

    --id_grupo_clasif INTEGER, --clasificador_ae
    SELECT pxp.list(amm.clasificador_ae)
    INTO v_clasificador_ae
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.clasificador_ae), '') <> '' AND amm.clasificador_ae <> '#borrar')
    AND LOWER(TRIM(amm.clasificador_ae)) NOT IN (SELECT LOWER(TRIM(codigo))
                                                FROM kaf.tgrupo
                                                WHERE tipo = 'clasificacion')
    AND '0' || LOWER(TRIM(amm.clasificador_ae)) NOT IN (SELECT LOWER(TRIM(codigo))
                                                FROM kaf.tgrupo
                                                WHERE tipo = 'clasificacion');

    --id_centro_costo INTEGER,
    SELECT pxp.list(amm.centro_costo)
    INTO v_centro_costo
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.centro_costo), '') <> '' AND amm.centro_costo <> '#borrar')
    AND LOWER(TRIM(amm.centro_costo)) NOT IN (SELECT LOWER(TRIM(codigo))
                                            FROM param.ttipo_cc);

    --id_centro_costo: verificación de existencia en la gestión
    SELECT pxp.list(amm.centro_costo)
    INTO v_centro_costo_gestion
    FROM kaf.tactivo_mod_masivo_det amm
    WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    AND (COALESCE(TRIM(amm.centro_costo), '') <> '' AND amm.centro_costo <> '#borrar')
    AND LOWER(TRIM(amm.centro_costo)) NOT IN (
        SELECT
        tcc.codigo
        FROM kaf.tactivo_mod_masivo_det amm
        JOIN kaf.tactivo_mod_masivo am
        ON am.id_activo_mod_masivo = amm.id_activo_mod_masivo
        JOIN param.ttipo_cc tcc
        ON tcc.codigo = LOWER(TRIM(amm.centro_costo))
        JOIN param.tcentro_costo cc
        ON cc.id_tipo_cc = tcc.id_tipo_cc
        AND cc.id_gestion IN (SELECT id_gestion FROM param.tgestion ge
                            WHERE DATE_TRUNC('year', ge.fecha_ini) = DATE_TRUNC('year', am.fecha))
        WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
    );

    IF v_unidad_medida IS NOT NULL OR
        v_local IS NOT NULL OR
        v_responsable IS NOT NULL OR
        v_proveedor IS NOT NULL OR
        v_grupo_ae IS NOT NULL OR
        v_clasificador_ae IS NOT NULL OR
        v_centro_costo IS NOT NULL OR
        v_centro_costo_gestion IS NOT NULL THEN

        RAISE EXCEPTION 'No es posible hacer la Actualización, existen códigos no encontrados, revise el detalle siguiente: 1) Unidad Medida: %, 2) Locales: %, 3) Responsables: %, 4) Proveedores: %, 5) Grupos AE: %, 6) Clasificación AE: %, 7) Centros de Costo: %, 8) Centros de Costo inexistente en la gestión: %,', v_unidad_medida, v_local, v_responsable, v_proveedor, v_grupo_ae, v_clasificador_ae, v_centro_costo, v_centro_costo_gestion;
    END IF;

    v_update = '';

    FOR v_rec IN SELECT af.codigo,
                af.id_activo_fijo, amm.nro_serie, amm.marca, amm.denominacion, amm.descripcion,
                um.id_unidad_medida, amm.observaciones, amm.ubicacion, ub.id_ubicacion,
                fun.id_funcionario, pr.id_proveedor, amm.fecha_compra, amm.documento,
                amm.cbte_asociado, amm.fecha_cbte_asociado,  gru.id_grupo, gru1.id_grupo AS id_grupo_clasif,
                cc.id_centro_costo, amm.unidad_medida, amm.local, amm.responsable, amm.proveedor,
                amm.grupo_ae, amm.clasificador_ae, amm.centro_costo
                FROM kaf.tactivo_mod_masivo_det amm
                JOIN kaf.tactivo_mod_masivo am
                ON am.id_activo_mod_masivo = amm.id_activo_mod_masivo
                JOIN kaf.tactivo_fijo af
                ON LOWER(af.codigo) = LOWER(TRIM(amm.codigo))
                LEFT JOIN param.tunidad_medida um
                ON LOWER(um.codigo) = LOWER(TRIM(amm.unidad_medida))
                LEFT JOIN kaf.tubicacion ub
                ON LOWER(ub.codigo) = LOWER(TRIM(amm.local))
                LEFT JOIN orga.tfuncionario fun
                ON LOWER(fun.codigo) = LOWER(TRIM(amm.responsable))
                LEFT JOIN param.tproveedor pr
                ON LOWER(pr.codigo) = LOWER(TRIM(amm.proveedor))
                LEFT JOIN kaf.tgrupo gru
                ON (LOWER(gru.codigo) = LOWER(TRIM(amm.grupo_ae)) OR LOWER(gru.codigo) = '0' || LOWER(TRIM(amm.grupo_ae)))
                LEFT JOIN kaf.tgrupo gru1
                ON (LOWER(gru1.codigo) = LOWER(TRIM(amm.clasificador_ae)) OR LOWER(gru1.codigo) = '0' || LOWER(TRIM(amm.clasificador_ae)))
                LEFT JOIN param.ttipo_cc tcc
                ON LOWER(tcc.codigo) = LOWER(TRIM(amm.centro_costo))
                LEFT JOIN param.tcentro_costo cc
                ON cc.id_tipo_cc = tcc.id_tipo_cc
                AND cc.id_gestion IN (SELECT id_gestion FROM param.tgestion ge
                                    WHERE DATE_TRUNC('year', ge.fecha_ini) = DATE_TRUNC('year', am.fecha))
                WHERE amm.id_activo_mod_masivo = p_id_activo_mod_masivo
                ORDER BY amm.id_activo_mod_masivo_det LOOP
        --Inicialización de variables
        v_dinamico = '';

        --nro_serie VARCHAR(50),
        IF v_rec.nro_serie = '#borrar' THEN
            v_dinamico = v_dinamico || 'nro_serie = NULL, ';
        ELSIF COALESCE(v_rec.nro_serie, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico || 'nro_serie = ''' || TRIM(v_rec.nro_serie) || ''', ';
        END IF;

        --marca VARCHAR(200),
        IF v_rec.marca = '#borrar' THEN
            v_dinamico = v_dinamico ||'marca = NULL, ';
        ELSIF COALESCE(v_rec.marca, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'marca = ''' || TRIM(v_rec.marca) || ''', ';
        END IF;

        --denominacion VARCHAR(500),
        IF v_rec.denominacion = '#borrar' THEN
            v_dinamico = v_dinamico ||'denominacion = NULL, ';
        ELSIF COALESCE(v_rec.denominacion, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'denominacion = ''' || TRIM(v_rec.denominacion) || ''', ';
        END IF;

        --descripcion VARCHAR(5000),
        IF v_rec.descripcion = '#borrar' THEN
            v_dinamico = v_dinamico ||'descripcion = NULL, ';
        ELSIF COALESCE(v_rec.descripcion, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'descripcion = ''' || TRIM(v_rec.descripcion) || ''', ';
        END IF;

        --id_unidad_medida INTEGER,
        IF v_rec.unidad_medida = '#borrar' THEN
            v_dinamico = v_dinamico ||'id_unidad_medida = NULL, ';
        ELSIF COALESCE(v_rec.id_unidad_medida, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'id_unidad_medida = ' || v_rec.id_unidad_medida || ', ';
        END IF;

        --observaciones VARCHAR(5000),
        IF v_rec.observaciones = '#borrar' THEN
            v_dinamico = v_dinamico ||'observaciones = NULL, ';
        ELSIF COALESCE(v_rec.observaciones, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'observaciones = ''' || TRIM(v_rec.observaciones) || ''', ';
        END IF;

        --ubicacion VARCHAR(1000),
        IF v_rec.ubicacion = '#borrar' THEN
            v_dinamico = v_dinamico ||'ubicacion = NULL, ';
        ELSIF COALESCE(v_rec.ubicacion, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'ubicacion = ''' || TRIM(v_rec.ubicacion) || ''', ';
        END IF;

        --id_ubicacion INTEGER, --local
        IF v_rec.local = '#borrar' THEN
            v_dinamico = v_dinamico ||'id_ubicacion = NULL, ';
        ELSIF COALESCE(v_rec.id_ubicacion, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'id_ubicacion = ' || v_rec.id_ubicacion || ', ';
        END IF;

        --id_funcionario INTEGER,
        IF v_rec.responsable = '#borrar' THEN
            v_dinamico = v_dinamico ||'id_funcionario = NULL, ';
        ELSIF COALESCE(v_rec.id_funcionario, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'id_funcionario = ' || v_rec.id_funcionario || ', ';
        END IF;

        --id_proveedor INTEGER,
        IF v_rec.proveedor = '#borrar' THEN
            v_dinamico = v_dinamico ||'id_proveedor = NULL, ';
        ELSIF COALESCE(v_rec.id_proveedor, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'id_proveedor = ' || v_rec.id_proveedor || ', ';
        END IF;

        --fecha_compra DATE,
        IF v_rec.fecha_compra IS NULL THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'fecha_compra = ''' || v_rec.fecha_compra || ''', ';
        END IF;

        --documento VARCHAR(100),
        IF v_rec.documento = '#borrar' THEN
            v_dinamico = v_dinamico ||'documento = NULL, ';
        ELSIF COALESCE(v_rec.documento, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'documento = ''' || TRIM(v_rec.documento) || ''', ';
        END IF;

        --cbte_asociado VARCHAR(50),
        IF v_rec.cbte_asociado = '#borrar' THEN
            v_dinamico = v_dinamico ||'nro_cbte_asociado = NULL, ';
        ELSIF COALESCE(v_rec.cbte_asociado, '') = '' THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico ||'nro_cbte_asociado = ''' || TRIM(v_rec.cbte_asociado) || ''', ';
        END IF;

        --fecha_cbte_asociado DATE,
        IF v_rec.fecha_cbte_asociado IS NULL THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico || 'fecha_cbte_asociado = ''' || v_rec.fecha_cbte_asociado || ''', ';
        END IF;

        --id_grupo INTEGER, --grupo_ae
        IF v_rec.grupo_ae = '#borrar' THEN
            v_dinamico = v_dinamico || 'id_grupo = NULL, ';
        ELSIF COALESCE(v_rec.id_grupo, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico || 'id_grupo = ' || v_rec.id_grupo || ', ';
        END IF;

        --id_grupo_clasif INTEGER, --clasificador_ae
        IF v_rec.clasificador_ae = '#borrar' THEN
            v_dinamico = v_dinamico || 'id_grupo_clasif = NULL, ';
        ELSIF COALESCE(v_rec.id_grupo_clasif, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico || 'id_grupo_clasif = ' || v_rec.id_grupo_clasif || ', ';
        END IF;

        --id_centro_costo INTEGER,
        IF v_rec.centro_costo = '#borrar' THEN
            v_dinamico = v_dinamico || 'id_centro_costo = NULL, ';
        ELSIF COALESCE(v_rec.id_centro_costo, 0) = 0 THEN
            --Nada que hacer
        ELSE
            v_dinamico = v_dinamico || 'id_centro_costo = ' || v_rec.id_centro_costo || ', ';
        END IF;

        --Terminar de formar la cadena de actualización
        v_dinamico = TRIM(v_dinamico);

        IF REGEXP_REPLACE(v_dinamico, '^.*(.)$', '\1') = ',' THEN
            v_dinamico = SUBSTR(v_dinamico, 1, length(v_dinamico) - 1);
        END IF;

        IF v_dinamico <> '' THEN
            v_update = v_update || ' UPDATE kaf.tactivo_fijo SET ' || v_dinamico || ' WHERE id_activo_fijo = ' || v_rec.id_activo_fijo || ';';
        END IF;

    END LOOP;

    --Ejecuta el update
    EXECUTE(v_update);

    --Devuelve la respuesta
    RETURN 'hecho';


EXCEPTION

    WHEN OTHERS THEN
        v_resp='';
        v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
        v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
        v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
        raise exception '%',v_resp;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."f_actualizacion_masiva_activos"(integer, integer) OWNER TO postgres;