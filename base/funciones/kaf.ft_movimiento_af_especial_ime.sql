CREATE OR REPLACE FUNCTION kaf.ft_movimiento_af_especial_ime (
	p_administrador integer, p_id_usuario integer, p_tabla character varying, p_transaccion character varying)
RETURNS character varying AS
$BODY$

/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_especial_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modIFicaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_especial'
 AUTOR: 		(rchumacero)
 FECHA:	        22-05-2019 21:34:37
 COMENTARIOS:
***************************************************************************
#ISSUE	SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #2		KAF		ETR 		22-05-2019	RCM		Funcion que gestiona las operaciones basicas (inserciones, modIFicaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_especial'
 #39    KAF     ETR         22-11-2019  RCM     Importación masiva Distribución de valores
***************************************************************************/

DECLARE

	v_nro_requerimiento    		integer;
	v_parametros           		record;
	v_id_requerimiento     		integer;
	v_resp		            	varchar;
	v_nombre_funcion        	text;
	v_mensaje_error         	text;
	v_id_movimiento_af_especial	integer;
	v_monto_actualiz        	numeric;
    v_depreciacion_acum     	numeric;
    v_monto_actualiz_usado  	numeric;
    v_depreciacion_acum_usado 	numeric;
    v_monto_actualiz_usado2  	numeric;
    v_monto 					numeric;
    v_importe					numeric;
    v_porcentaje				numeric;
    v_id_moneda                 integer;
    --Inicio #39
    v_id_activo_fijo            INTEGER;
    v_vida_util                 INTEGER;
    v_id_clasificacion          INTEGER;
    v_id_gestion                INTEGER;
    v_id_centro_costo           INTEGER;
    v_id_almacen                INTEGER;
    v_rec                       RECORD;
    v_tipo                      VARCHAR;
    --Fin #39

BEGIN

    v_nombre_funcion = 'kaf.ft_movimiento_af_especial_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_MOAFES_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:			rchumacero
 	#FECHA:			22-05-2019 21:34:37
	***********************************/
	IF(p_transaccion = 'SKA_MOAFES_INS') THEN

        BEGIN

        	---------------
        	--Validaciones
        	---------------
            --Inicio #39
            IF NOT EXISTS (
                SELECT 1
                FROM kaf.tmovimiento_af maf
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af
                AND mov.estado = 'borrador'
            ) THEN
                RAISE EXCEPTION 'El Movimiento debería estar en estado Borrador';
            END IF;
            --Fin #39

        	--Obtención de importes del activo origen
        	SELECT COALESCE(importe, 0)
        	INTO v_monto_actualiz
        	FROM kaf.tmovimiento_af
        	WHERE id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtención de la moneda parametrizada
            SELECT id_moneda
            INTO v_id_moneda
            FROM param.tmoneda
            WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

            IF COALESCE(v_id_moneda, 0) = 0 THEN
                RAISE EXCEPTION 'Falta la parametrización de la Moneda para movimientos (kaf_mov_especial_moneda)';
            END IF;

        	--Obtención del importe utilizado
        	SELECT COALESCE(SUM(importe), 0), COALESCE(v_monto_actualiz * SUM(porcentaje) / 100, 0)
        	INTO v_monto_actualiz_usado, v_monto_actualiz_usado2
        	FROM kaf.tmovimiento_af_especial
        	WHERE id_movimiento_af = v_parametros.id_movimiento_af;

        	--Obtención del nuevo valor a utilizar
        	v_monto = 0;
        	IF COALESCE(v_parametros.importe, 0) > 0 THEN
        		v_monto = v_parametros.importe;
        	END IF;

        	IF COALESCE(v_parametros.porcentaje, 0) > 0 THEN
        		v_monto = v_monto_actualiz * v_parametros.porcentaje / 100;
        	END IF;

        	--Control de no sobregiro
        	IF v_monto_actualiz_usado + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado, v_monto;
        	END IF;

        	IF v_monto_actualiz_usado2 + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado2, v_monto;
        	END IF;

        	------------
        	--Inserción
        	------------
        	IF v_parametros.opcion = 'porcentaje' THEN
        		v_porcentaje = v_parametros.porcentaje;
        		v_importe = v_monto_actualiz * v_parametros.porcentaje / 100;
        	END IF;

        	IF v_parametros.opcion = 'importe' THEN
        		v_importe = v_parametros.importe;
        		v_porcentaje = v_parametros.importe * 100 / v_monto_actualiz;
        	END IF;

        	INSERT INTO kaf.tmovimiento_af_especial(
			id_activo_fijo,
			id_activo_fijo_valor,
			id_movimiento_af,
			fecha_ini_dep,
			importe,
			vida_util,
			id_clasIFicacion,
			id_activo_fijo_creado,
			estado_reg,
			id_centro_costo,
			denominacion,
			porcentaje,
			id_usuario_ai,
			id_usuario_reg,
			fecha_reg,
			usuario_ai,
			id_usuario_mod,
			fecha_mod,
			tipo,
			opcion,
            id_moneda,
            id_almacen,
            --Inicio #39
            nro_serie,
            marca,
            descripcion,
            cantidad_det,
            id_unidad_medida,
            ubicacion,
            id_ubicacion,
            id_funcionario,
            fecha_compra,
            --id_moneda,
            id_grupo,
            id_grupo_clasif,
            observaciones
            --Fin #39
          	) VALUES (
			v_parametros.id_activo_fijo,
			v_parametros.id_activo_fijo_valor,
			v_parametros.id_movimiento_af,
			v_parametros.fecha_ini_dep,
			v_importe,
			v_parametros.vida_util,
			v_parametros.id_clasIFicacion,
			v_parametros.id_activo_fijo_creado,
			'activo',
			v_parametros.id_centro_costo,
			v_parametros.denominacion,
			v_porcentaje,
			v_parametros._id_usuario_ai,
			p_id_usuario,
			now(),
			v_parametros._nombre_usuario_ai,
			NULL,
			NULL,
			v_parametros.tipo,
			v_parametros.opcion,
            v_id_moneda,
            v_parametros.id_almacen,
            --Inicio #39
            v_parametros.nro_serie,
            v_parametros.marca,
            v_parametros.descripcion,
            v_parametros.cantidad_det,
            v_parametros.id_unidad_medida,
            v_parametros.ubicacion,
            v_parametros.id_ubicacion,
            v_parametros.id_funcionario,
            v_parametros.fecha_compra,
            --v_parametros.id_moneda,
            v_parametros.id_grupo,
            v_parametros.id_grupo_clasif,
            v_parametros.observaciones
            --Fin #39
			) RETURNING id_movimiento_af_especial INTO v_id_movimiento_af_especial;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Movimiento Especial almacenado(a) con exito (id_movimiento_af_especial' || v_id_movimiento_af_especial || ')');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af_especial', v_id_movimiento_af_especial::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

		END;

	/*********************************
 	#TRANSACCION:  'SKA_MOAFES_MOD'
 	#DESCRIPCION:	ModIFicacion de registros
 	#AUTOR:		    rchumacero
 	#FECHA:		    22-05-2019 21:34:37
	***********************************/

	ELSIF(p_transaccion = 'SKA_MOAFES_MOD') THEN

		BEGIN

			---------------
        	--Validaciones
        	---------------
            --Inicio #39
            IF NOT EXISTS (
                SELECT 1
                FROM kaf.tmovimiento_af maf
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af
                AND mov.estado = 'borrador'
            ) THEN
                RAISE EXCEPTION 'El Movimiento debería estar en estado Borrador';
            END IF;
            --Fin #39

        	--Obtención de importes del activo origen
        	SELECT COALESCE(importe, 0)
        	INTO v_monto_actualiz
        	FROM kaf.tmovimiento_af
        	WHERE id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtención de la moneda parametrizada
            SELECT id_moneda
            INTO v_id_moneda
            FROM param.tmoneda
            WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

            IF COALESCE(v_id_moneda, 0) = 0 THEN
                RAISE EXCEPTION 'Falta la parametrización de la Moneda para movimientos (kaf_mov_especial_moneda)';
            END IF;

        	--Obtención del importe utilizado sin considerar el registro a modIFicar
        	SELECT COALESCE(SUM(importe), 0), COALESCE(v_monto_actualiz * SUM(porcentaje) / 100, 0)
        	INTO v_monto_actualiz_usado, v_monto_actualiz_usado2
        	FROM kaf.tmovimiento_af_especial
        	WHERE id_movimiento_af = v_parametros.id_movimiento_af
        	and id_movimiento_af_especial <> v_parametros.id_movimiento_af_especial;

        	--Obtención del nuevo valor a utilizar
        	v_monto = 0;
        	IF COALESCE(v_parametros.importe, 0) > 0 THEN
        		v_monto = v_parametros.importe;
        	END IF;

        	IF COALESCE(v_parametros.porcentaje, 0) > 0 THEN
        		v_monto = v_monto_actualiz * v_parametros.porcentaje / 100;
        	END IF;

        	--Control de no sobregiro
        	IF v_monto_actualiz_usado + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado,  v_monto;
        	END IF;

        	IF v_monto_actualiz_usado2 + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado2,  v_monto;
        	END IF;

        	---------------
        	--ModIFicación
        	---------------
        	IF v_parametros.opcion = 'porcentaje' THEN
        		v_porcentaje = v_parametros.porcentaje;
        		v_importe = v_monto_actualiz * v_parametros.porcentaje / 100;
        	END IF;

        	IF v_parametros.opcion = 'importe' THEN
        		v_importe = v_parametros.importe;
        		v_porcentaje = v_parametros.importe * 100 / v_monto_actualiz;
        	END IF;

			UPDATE kaf.tmovimiento_af_especial SET
			id_activo_fijo = v_parametros.id_activo_fijo,
			id_activo_fijo_valor = v_parametros.id_activo_fijo_valor,
			id_movimiento_af = v_parametros.id_movimiento_af,
			fecha_ini_dep = v_parametros.fecha_ini_dep,
			importe = v_importe,
			vida_util = v_parametros.vida_util,
			id_clasIFicacion = v_parametros.id_clasIFicacion,
			id_activo_fijo_creado = v_parametros.id_activo_fijo_creado,
			id_centro_costo = v_parametros.id_centro_costo,
			denominacion = v_parametros.denominacion,
			porcentaje = v_porcentaje,
			id_usuario_mod = p_id_usuario,
			fecha_mod = now(),
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai,
			tipo = v_parametros.tipo,
			opcion = v_parametros.opcion,
            id_moneda = v_id_moneda,
            id_almacen = v_parametros.id_almacen,
            nro_serie = v_parametros.nro_serie,
            marca = v_parametros.marca,
            descripcion = v_parametros.descripcion,
            cantidad_det = v_parametros.cantidad_det,
            id_unidad_medida = v_parametros.id_unidad_medida,
            ubicacion = v_parametros.ubicacion,
            id_ubicacion = v_parametros.id_ubicacion,
            id_funcionario = v_parametros.id_funcionario,
            fecha_compra = v_parametros.fecha_compra,
            --id_moneda = v_parametros.id_moneda,
            id_grupo = v_parametros.id_grupo,
            id_grupo_clasif = v_parametros.id_grupo_clasif,
            observaciones = v_parametros.observaciones
			WHERE id_movimiento_af_especial = v_parametros.id_movimiento_af_especial;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Movimiento Especial modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af_especial', v_parametros.id_movimiento_af_especial::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

		END;

	/*********************************
 	#TRANSACCION:  'SKA_MOAFES_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		    rchumacero
 	#FECHA:		    22-05-2019 21:34:37
	***********************************/

	ELSIF(p_transaccion = 'SKA_MOAFES_ELI') THEN

		BEGIN

            --Inicio #39
            IF NOT EXISTS (
                SELECT 1
                FROM kaf.tmovimiento_af maf
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af
                AND mov.estado = 'borrador'
            ) THEN
                RAISE EXCEPTION 'El Movimiento debería estar en estado Borrador';
            END IF;
            --Fin #39

			--Sentencia de la eliminacion
			DELETE FROM kaf.tmovimiento_af_especial
            WHERE id_movimiento_af_especial = v_parametros.id_movimiento_af_especial;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Movimiento Especial eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af_especial', v_parametros.id_movimiento_af_especial::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

		END;

    --Inicio #39
    /*********************************
    #TRANSACCION:  'SKA_MOAFESMAS_INS'
    #DESCRIPCION:   Insercion de registros
    #AUTOR:         rchumacero
    #FECHA:         25/11/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_MOAFESMAS_INS') THEN

        BEGIN

            --Inicio #39
            IF NOT EXISTS (
                SELECT 1
                FROM kaf.tmovimiento_af maf
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af
                AND mov.estado = 'borrador'
            ) THEN
                RAISE EXCEPTION 'El Movimiento debería estar en estado Borrador';
            END IF;
            --Fin #39

            --Obtención de la gestión del cierre del proyecto
            SELECT id_gestion
            INTO v_id_gestion
            FROM param.tgestion
            WHERE DATE_TRUNC('year', fecha_ini) IN (
                                                        SELECT DATE_TRUNC('year', mov.fecha_mov)
                                                        FROM kaf.tmovimiento_af maf
                                                        INNER JOIN kaf.tmovimiento mov
                                                        ON mov.id_movimiento = maf.id_movimiento
                                                        WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af
                                                    );

            --Obtención de datos del activo fijo original
            SELECT af.id_clasificacion
            INTO v_rec
            FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af;

            --Inicialización variables
            v_id_almacen = NULL;
            v_vida_util = NULL;
            v_id_activo_fijo = NULL;
            v_tipo = NULL;

            ---------------
            --Validaciones
            ---------------
            --tipo
            IF v_parametros.tipo = 'activo_nuevo' THEN
                v_tipo = 'af_nuevo';
            ELSIF v_parametros.tipo = 'activo_existente' THEN
                v_tipo = 'af_exist';
            ELSIF v_parametros.tipo = 'almacen' THEN
                v_tipo = 'af_almacen';
            ELSE
                RAISE EXCEPTION 'Tipo de operación no reconocida (%)',v_parametros.tipo;
            END IF;

            --clasificacion
            IF pxp.f_existe_parametro(p_tabla, 'clasificacion') THEN
                SELECT id_clasificacion
                INTO v_id_clasificacion
                FROM kaf.tclasificacion
                WHERE codigo_completo_tmp = v_parametros.clasificacion;
            END IF;

            --centro_costo
            IF pxp.f_existe_parametro(p_tabla, 'centro_costo') THEN
                SELECT cc.id_centro_costo
                INTO v_id_centro_costo
                FROM param.ttipo_cc tcc
                INNER JOIN param.tcentro_costo cc
                ON cc.id_tipo_cc = tcc.id_tipo_cc
                WHERE tcc.codigo = v_parametros.centro_costo
                AND cc.id_gestion = v_id_gestion;
            END IF;

            --vida_util_anios
            IF pxp.f_existe_parametro(p_tabla, 'vida_util_anios') THEN
                v_vida_util = v_parametros.vida_util_anios * 12;
            END IF;

            --Validación por Tipo
            IF v_tipo = 'af_nuevo' THEN

                IF v_id_clasificacion IS NULL THEN
                    RAISE EXCEPTION 'Clasificación inexistente (Fila: %)', v_parametros.item;
                END IF;

                IF v_id_centro_costo IS NULL THEN
                    RAISE EXCEPTION 'Centro de Costo inexistente (Fila: %)', v_parametros.item;
                END IF;


            ELSIF v_tipo = 'af_exist' THEN

                --id_activo_fijo
                IF pxp.f_existe_parametro(p_tabla, 'codigo_af') THEN

                    SELECT id_activo_fijo
                    INTO v_id_activo_fijo
                    FROM kaf.tactivo_fijo
                    WHERE codigo = v_parametros.codigo_af;

                END IF;

                IF v_id_activo_fijo IS NULL THEN
                    RAISE EXCEPTION 'Activo Fijo inexistente (Fila: %)', v_parametros.item;
                END IF;

                IF v_id_centro_costo IS NULL THEN
                    v_id_centro_costo = v_rec.id_centro_costo;
                END IF;

                IF v_id_clasificacion IS NULL THEN
                    v_id_clasificacion = v_rec.id_clasificacion;
                END IF;

                IF v_vida_util IS NULL THEN
                    RAISE EXCEPTION 'Vida útil no definida (Fila: %)', v_parametros.item;
                END IF;

            ELSE

            END IF;




            --------------------
            --Lógica específica
            --------------------
            --Obtención de importes del activo origen
            SELECT COALESCE(importe, 0)
            INTO v_monto_actualiz
            FROM kaf.tmovimiento_af
            WHERE id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtención de la moneda parametrizada
            SELECT id_moneda
            INTO v_id_moneda
            FROM param.tmoneda
            WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

            IF COALESCE(v_id_moneda, 0) = 0 THEN
                RAISE EXCEPTION 'Falta la parametrización de la Moneda para movimientos (kaf_mov_especial_moneda)';
            END IF;

            --Obtención del importe utilizado
            SELECT COALESCE(SUM(importe), 0), COALESCE(v_monto_actualiz * SUM(porcentaje) / 100, 0)
            INTO v_monto_actualiz_usado, v_monto_actualiz_usado2
            FROM kaf.tmovimiento_af_especial
            WHERE id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtención del nuevo valor a utilizar
            v_monto = 0;
            IF COALESCE(v_parametros.importe, 0) > 0 THEN
                v_monto = v_parametros.importe;
            END IF;

            IF COALESCE(v_parametros.porcentaje, 0) > 0 THEN
                v_monto = v_monto_actualiz * v_parametros.porcentaje / 100;
            END IF;

            --Control de no sobregiro
            IF v_monto_actualiz_usado + v_monto > v_monto_actualiz THEN
                RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado, v_monto;
            END IF;

            IF v_monto_actualiz_usado2 + v_monto > v_monto_actualiz THEN
                RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_monto_actualiz, v_monto_actualiz_usado2, v_monto;
            END IF;

            ------------
            --Inserción
            ------------
            IF v_parametros.opcion = 'porcentaje' THEN
                v_porcentaje = v_parametros.porcentaje;
                v_importe = v_monto_actualiz * v_parametros.porcentaje / 100;
            END IF;

            IF v_parametros.opcion = 'importe' THEN
                v_importe = v_parametros.importe;
                v_porcentaje = v_parametros.importe * 100 / v_monto_actualiz;
            END IF;

            INSERT INTO kaf.tmovimiento_af_especial(
            id_activo_fijo,
            id_movimiento_af,
            fecha_ini_dep,
            importe,
            vida_util,
            id_clasIFicacion,
            estado_reg,
            id_centro_costo,
            denominacion,
            porcentaje,
            id_usuario_ai,
            id_usuario_reg,
            fecha_reg,
            usuario_ai,
            id_usuario_mod,
            fecha_mod,
            tipo,
            opcion,
            id_moneda,
            id_almacen
            ) VALUES (
            v_id_activo_fijo,
            v_parametros.id_movimiento_af,
            v_parametros.fecha_ini_dep,
            v_importe,
            v_vida_util,
            v_id_clasificacion,
            'activo',
            v_id_centro_costo,
            v_parametros.denominacion,
            v_porcentaje,
            v_parametros._id_usuario_ai,
            p_id_usuario,
            now(),
            v_parametros._nombre_usuario_ai,
            NULL,
            NULL,
            v_tipo,
            v_parametros.opcion,
            v_id_moneda,
            v_id_almacen
            ) RETURNING id_movimiento_af_especial INTO v_id_movimiento_af_especial;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Movimiento Especial almacenado(a) con exito (id_movimiento_af_especial' || v_id_movimiento_af_especial || ')');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af_especial', v_id_movimiento_af_especial::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;
    --Fin #39

	ELSE

    	RAISE EXCEPTION 'Transaccion inexistente: %', p_transaccion;

	END IF;

EXCEPTION

	WHEN OTHERS THEN
		v_resp ='';
		v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', SQLERRM);
		v_resp = pxp.f_agrega_clave(v_resp, 'codigo_error', SQLSTATE);
		v_resp = pxp.f_agrega_clave(v_resp, 'procedimientos', v_nombre_funcion);
		RAISE EXCEPTION '%', v_resp;

END;
$BODY$
LANGUAGE 'plpgsql' VOLATILE
COST 100;
ALTER FUNCTION "kaf"."ft_movimiento_af_especial_ime"(integer, integer, character varying, character varying) OWNER TO postgres;