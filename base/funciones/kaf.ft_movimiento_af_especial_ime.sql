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
            id_almacen
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
            v_parametros.id_almacen
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
            id_almacen = v_parametros.id_almacen
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
			--Sentencia de la eliminacion
			DELETE FROM kaf.tmovimiento_af_especial
            WHERE id_movimiento_af_especial = v_parametros.id_movimiento_af_especial;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Movimiento Especial eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af_especial', v_parametros.id_movimiento_af_especial::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

		END;

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