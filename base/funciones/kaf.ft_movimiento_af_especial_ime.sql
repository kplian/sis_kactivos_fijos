CREATE OR REPLACE FUNCTION kaf.ft_movimiento_af_especial_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_especial_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modIFicaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_especial'
 AUTOR: 		(rchumacero)
 FECHA:	        22-05-2019 21:34:37
 COMENTARIOS:
***************************************************************************
#ISSUE	    SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #2		    KAF		ETR 		22-05-2019	RCM		Funcion que gestiona las operaciones basicas (inserciones, modIFicaciones, eliminaciones de la tabla 'kaf.tmovimiento_af_especial'
 #39        KAF     ETR         22-11-2019  RCM     Importación masiva Distribución de valores
 #38        KAF     ETR         11-12-2019  RCM     Reingeniería importación de plantilla para movimientos especiales
 #47        KAF     ETR         11-02-2020  RCM     Corrección de error al eliminar registro
 #46	    KAF		ETR			18-02-2020  MZM		Modificacion a funcion de importacion de movimientos especiales, dado que el valor en plantilla viene en base a valor actualizado y se debe obtener el valor en funcion al importe_neto.
 #53        KAF     ETR         09-03-2020  RCM     Adición de TRIM en comparación de columna
 #62        KAF     ETR         06-05-2020  RCM     Opción para importar plantilla de almacenes
 #ETR-3058  KAF     ETR         10-03-2021  RCM     Adición de excepción cuando no exista el Local
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
    --Inicio #38
    v_id_unidad_medida          INTEGER;
    v_id_ubicacion              INTEGER;
    v_id_funcionario            INTEGER;
    v_id_grupo_ae               INTEGER;
    v_id_grupo_clasif           INTEGER;
    v_nro_serie                 VARCHAR;
    v_marca                     VARCHAR;
    v_codigo_af_orig            VARCHAR;
    --Fin #38
    --#Inicio 46
	v_monto_neto				numeric;
    v_costo_orig				numeric;
	--Fin #46
    --Inicio #62
    v_fecha_ini_dep             DATE;
    v_denominacion              VARCHAR;
    v_ubicacion                 VARCHAR;
    v_fecha_compra              DATE;
    --Fin #62

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
            --Inicio #38
        	SELECT COALESCE(importe, 0), af.codigo
        	INTO v_monto_actualiz, v_codigo_af_orig
        	FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
        	WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af;
            --Fin #38

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
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen %. (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_codigo_af_orig, v_monto_actualiz, v_monto_actualiz_usado, v_monto; --#38
        	END IF;

        	IF v_monto_actualiz_usado2 + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen %. (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_codigo_af_orig, v_monto_actualiz, v_monto_actualiz_usado2, v_monto; --#38
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

            --Inicio #38
        	--Obtención de importes del activo origen
            SELECT COALESCE(importe, 0), af.codigo
            INTO v_monto_actualiz, v_codigo_af_orig
            FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af;
            --Fin #38

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
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen %. (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_codigo_af_orig, v_monto_actualiz, v_monto_actualiz_usado,  v_monto;
        	END IF;

        	IF v_monto_actualiz_usado2 + v_monto > v_monto_actualiz THEN
        		RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen %. (Valor Original: %, Saldo Anterior: %, Nuevo monto: %)', v_codigo_af_orig, v_monto_actualiz, v_monto_actualiz_usado2,  v_monto;
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
                --Inicio #47
                FROM kaf.tmovimiento_af_especial mesp
                INNER JOIN kaf.tmovimiento_af maf
                ON maf.id_movimiento_af = mesp.id_movimiento_af
                INNER JOIN kaf.tmovimiento mov
                ON mov.id_movimiento = maf.id_movimiento
                WHERE mesp.id_movimiento_af_especial = v_parametros.id_movimiento_af_especial
                AND mov.estado = 'borrador'
                --Fin #47
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
            --Inicio #38
            v_tipo = 'af_nuevo';

            --Inicio #62
            IF pxp.f_existe_parametro(p_tabla, 'tipo') THEN
                v_tipo = 'af_almacen';
            END IF;
            --Fin #62

            IF v_tipo = 'af_nuevo' THEN --#62
                IF pxp.f_existe_parametro(p_tabla, 'codigo_af') THEN
                    IF COALESCE(v_parametros.codigo_af, '') <> '' THEN
                        v_tipo = 'af_exist';
                    END IF;
                END IF;
            END IF; --#62
            --Fin #38

            --clasificacion
            IF pxp.f_existe_parametro(p_tabla, 'clasificacion') THEN
                SELECT id_clasificacion
                INTO v_id_clasificacion
                FROM kaf.tclasificacion
                WHERE codigo_completo_tmp = TRIM(v_parametros.clasificacion); --#53
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
                    WHERE codigo = TRIM(v_parametros.codigo_af);

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
            --Inicio #38
            --Obtención de importes del activo origen
            SELECT COALESCE(importe, 0), af.codigo, coalesce(maf.depreciacion_acum,0) --#46
            INTO v_monto_actualiz, v_codigo_af_orig, v_depreciacion_acum --#46
            FROM kaf.tmovimiento_af maf
            INNER JOIN kaf.tactivo_fijo af
            ON af.id_activo_fijo = maf.id_activo_fijo
            WHERE maf.id_movimiento_af = v_parametros.id_movimiento_af;
            --Fin #38

			v_monto_neto:=(v_monto_actualiz-v_depreciacion_acum); --#46

            if(v_monto_neto=0) then
               RAISE EXCEPTION 'El monto neto del Activo Fijo Origen %. es 0 ', v_codigo_af_orig;
            end if;

            --Obtención de la moneda parametrizada
            SELECT id_moneda
            INTO v_id_moneda
            FROM param.tmoneda
            WHERE UPPER(codigo) = UPPER(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

            IF COALESCE(v_id_moneda, 0) = 0 THEN
                RAISE EXCEPTION 'Falta la parametrización de la Moneda para movimientos (kaf_mov_especial_moneda)';
            END IF;

            --Obtención del importe utilizado --#46
            SELECT COALESCE(SUM(importe), 0), round(coalesce(SUM(porcentaje),0),2) --COALESCE(v_monto_neto * SUM(porcentaje) / 100, 0) --COALESCE(v_monto_actualiz * SUM(porcentaje) / 100, 0)
            INTO v_monto_actualiz_usado, v_monto_actualiz_usado2
            FROM kaf.tmovimiento_af_especial
            WHERE id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtención del nuevo valor a utilizar
            v_monto = 0;
            v_costo_orig = 0; --#46
            IF COALESCE(v_parametros.importe, 0) > 0 THEN
                v_monto = (v_parametros.importe*v_monto_neto/v_monto_actualiz);  --#46
                v_costo_orig = v_parametros.importe; --#46
            END IF;

            IF COALESCE(v_parametros.porcentaje, 0) > 0 THEN
                --v_monto = v_monto_actualiz * v_parametros.porcentaje / 100;
                v_monto = v_monto_neto * v_parametros.porcentaje / 100;
                v_costo_orig = v_monto_actualiz * v_parametros.porcentaje / 100;
            END IF;

            --Control de no sobregiro
			IF ROUND(v_monto_actualiz_usado + v_monto,2) > ROUND(v_monto_neto,2) THEN
                RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen %. (Valor Original: %, Saldo Anterior: %, Nuevo monto: %), Monto Orig: %', v_codigo_af_orig, v_monto_neto, v_monto_actualiz_usado, v_monto, v_parametros.importe;
            END IF;

            IF v_monto_actualiz_usado2 + ROUND((v_monto / v_monto_neto * 100), 2) > 100 THEN --#46
            	RAISE EXCEPTION 'Se ha superado el valor total del Activo Fijo Origen en porcentaje %. (Valor Original: %, Saldo Anterior Porcentual: %, Nuevo porcentaje: %)', v_codigo_af_orig,v_monto_neto, v_monto_actualiz_usado2, (v_monto / v_monto_neto * 100);
            END IF;

            --Inicio #38
            --Nro Serie
            v_nro_serie = NULL;
            IF pxp.f_existe_parametro(p_tabla, 'nro_serie') THEN
                v_nro_serie = v_parametros.nro_serie;
            END IF;

            --Marca
            v_marca = NULL;
            IF pxp.f_existe_parametro(p_tabla, 'marca') THEN
                v_marca = v_parametros.marca;
            END IF;

            --Unidad de medida
            IF pxp.f_existe_parametro(p_tabla, 'unidad') THEN
                SELECT id_unidad_medida
                INTO v_id_unidad_medida
                FROM param.tunidad_medida
                WHERE LOWER(codigo) = lower(v_parametros.unidad);

                IF COALESCE(v_id_unidad_medida,0) = 0 THEN
                    RAISE EXCEPTION 'Unidad de Medida no encontrada para el activo: %. (Fila %)', v_parametros.denominacion, v_parametros.item;
                END IF;
            END IF;

            --Local (id_ubicacion)
            v_id_ubicacion = NULL;
            IF pxp.f_existe_parametro(p_tabla, 'local') THEN
                select id_ubicacion
                into v_id_ubicacion
                from kaf.tubicacion
                where LOWER(codigo) = LOWER(TRIM(v_parametros.local));

                --Inicio #ETR-3058: adicion de excepcion cuando no haya Local
                IF COALESCE(v_id_ubicacion, 0) = 0 THEN
                    RAISE EXCEPTION 'Local no encontrado: %, para el activo: %. (Fila %)', v_parametros.local, v_parametros.denominacion, v_parametros.item;
                END IF;
                --Fin #ETR-3058

            END IF;

            --Responsable (id_funcionario)
            v_id_funcionario = null;
            IF pxp.f_existe_parametro(p_tabla, 'responsable') THEN

                SELECT f.id_funcionario
                INTO v_id_funcionario
                FROM segu.tusuario u
                INNER JOIN orga.tfuncionario f
                ON f.id_persona = u.id_persona
                WHERE LOWER(u.cuenta) = LOWER(TRIM(v_parametros.responsable));

                IF COALESCE(v_id_funcionario, 0) = 0 THEN
                    RAISE EXCEPTION 'Responsable del activo no encontrado: %, para el activo: %. (Fila %)', v_parametros.responsable, v_parametros.denominacion, v_parametros.item;
                END IF;

            END IF;

            --Grupo AE (id_grupo): si tiene activo fijo relacionado, lo obtiene de su activo previamente creado
            v_id_grupo_ae = NULL;
            IF pxp.f_existe_parametro(p_tabla, 'codigo_af') THEN
                SELECT id_grupo
                INTO v_id_grupo_ae
                FROM kaf.tactivo_fijo
                WHERE codigo = TRIM(v_parametros.codigo_af);
            ELSE
                IF pxp.f_existe_parametro(p_tabla, 'grupo_ae') THEN
                    SELECT id_grupo
                    INTO v_id_grupo_ae
                    FROM kaf.tgrupo
                    WHERE tipo = 'grupo'
                    AND (LOWER(codigo) = LOWER(TRIM(v_parametros.grupo_ae)) OR LOWER(codigo) = '0' || LOWER(TRIM(v_parametros.grupo_ae)));
                END IF;
            END IF;

            --Clasif AE (id_grupo_clasif): si tiene activo fijo relacionado, lo obtiene de su activo previamente creado
            v_id_grupo_clasif = NULL;
            IF pxp.f_existe_parametro(p_tabla, 'codigo_af') THEN
                SELECT id_grupo
                INTO v_id_grupo_clasif
                FROM kaf.tactivo_fijo
                WHERE codigo = TRIM(v_parametros.codigo_af);
            ELSE
                IF pxp.f_existe_parametro(p_tabla, 'clasificacion_ae') THEN
                    SELECT id_grupo
                    INTO v_id_grupo_clasif
                    FROM kaf.tgrupo
                    WHERE tipo = 'clasificacion'
                    AND (LOWER(codigo) = LOWER(TRIM(v_parametros.clasificacion_ae)) OR LOWER(codigo) = '0' || LOWER(TRIM(v_parametros.clasificacion_ae)));
                END IF;
            END IF;
            --Fin #38

            --Inicio #62
            IF v_tipo = 'af_almacen' THEN
                SELECT id_almacen
                INTO v_id_almacen
                FROM alm.talmacen
                WHERE TRIM(UPPER(codigo)) = TRIM(UPPER(v_parametros.codigo));

                IF v_id_almacen IS NULL THEN
                    RAISE EXCEPTION 'Código de almacén no encontrado: %, para el activo (Fila %)', v_parametros.codigo, v_parametros.item;
                END IF;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'fecha_ini_dep') THEN
                v_fecha_ini_dep = v_parametros.fecha_ini_dep;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'denominacion') THEN
                v_denominacion = v_parametros.denominacion;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'ubicacion') THEN
                v_ubicacion = v_parametros.ubicacion;
            END IF;

            IF pxp.f_existe_parametro(p_tabla, 'fecha_compra') THEN
                v_fecha_compra = v_parametros.fecha_compra;
            END IF;

            --Fin #62

            ------------
            --Inserción
            ------------
            IF v_parametros.opcion = 'porcentaje' THEN
                v_porcentaje = v_parametros.porcentaje;
				v_importe = v_monto_neto * v_parametros.porcentaje / 100; --#46
            END IF;

            IF v_parametros.opcion = 'importe' THEN
                v_porcentaje = v_monto * 100 / v_monto_neto;  --#46
                v_importe = v_monto; --#46
            END IF;

            INSERT INTO kaf.tmovimiento_af_especial(
            id_activo_fijo,
            id_movimiento_af,
            fecha_ini_dep,
            importe,
            vida_util,
            id_clasificacion,
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
            --Inicio #38
            nro_serie,
            marca,
            descripcion,
            cantidad_det,
            id_unidad_medida,
            ubicacion,
            id_ubicacion,
            id_funcionario,
            fecha_compra,
            id_grupo,
            id_grupo_clasif,
            observaciones
            --Fin #38
            , costo_orig
            ) VALUES (
            v_id_activo_fijo,
            v_parametros.id_movimiento_af,
            v_fecha_ini_dep, --#62
            v_importe,
            v_vida_util,
            v_id_clasificacion,
            'activo',
            v_id_centro_costo,
            v_denominacion, --#62
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
            v_id_almacen,
            --Inicio #38
            v_nro_serie,
            v_marca,
            v_parametros.descripcion,
            v_parametros.cantidad_det,
            v_id_unidad_medida,
            v_ubicacion, --#62
            v_id_ubicacion,
            v_id_funcionario,
            v_fecha_compra, --#62
            v_id_grupo_ae,
            v_id_grupo_clasif,
            NULL
            --Fin #38
            ,v_costo_orig
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
$body$
LANGUAGE 'plpgsql'
VOLATILE
COST 100;