--------------- SQL ---------------

CREATE OR REPLACE FUNCTION kaf.ft_movimiento_af_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_movimiento_af_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tmovimiento_af'
 AUTOR: 		 (admin)
 FECHA:	        18-03-2016 05:34:15
 COMENTARIOS:
***************************************************************************
 ISSUE  SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
 #2     KAF     ETR         23/01/2019  RCM     Se corrige la eliminación
 #39    KAF     ETR         22/11/2019  RCM     Importación plantillas excel Distribución de Valores
 #46	KAF		ETR			20.02.2020	MZM		Adicion de trim en codigo_af 
***************************************************************************/

DECLARE

	v_nro_requerimiento     integer;
	v_parametros            record;
	v_id_requerimiento      integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_movimiento_af      integer;
	v_id_cat_estado_fun	    integer;
    v_registros		        record;
    v_registros_mov         record;
    v_id_moneda_base        integer;
    v_id_mov_esp            integer;
    v_monto_actualiz        numeric;
    v_monto_actualiz_usado2 numeric;
    v_monto                 numeric;
    v_monto_actualiz_usado  numeric;
    v_saldo                 numeric;
    v_id_moneda_mov_esp     integer;--#2
    v_codigo_moneda         varchar;--#2
    v_id_activo_fijo        INTEGER; --#39

BEGIN

  v_nombre_funcion = 'kaf.ft_movimiento_af_ime';
  v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_MOVAF_INS'
 	#DESCRIPCION:	Insercion de registros, validaciones de estado y cantidad
 	#AUTOR:		admin ,RAC
 	#FECHA:		18-03-2016, 23/03/2017
	***********************************/

	if(p_transaccion='SKA_MOVAF_INS')then

      begin

        --Se setea los datos para llamar a la función de inserción
        select
        coalesce(v_parametros.id_movimiento,null) as id_movimiento,
        coalesce(v_parametros.id_activo_fijo,null) as id_activo_fijo,
        coalesce(v_parametros.id_movimiento_motivo,null) as id_movimiento_motivo,
        coalesce(v_parametros.importe,null) as importe,
        coalesce(v_parametros.vida_util,null) as vida_util,
        coalesce(v_parametros._nombre_usuario_ai,null) as _nombre_usuario_ai,
        coalesce(v_parametros._id_usuario_ai,null) as _id_usuario_ai,
        coalesce(v_parametros.depreciacion_acum,null) as depreciacion_acum,
        coalesce(v_parametros.importe_ant,null) as importe_ant,
        coalesce(v_parametros.vida_util_ant,null) as vida_util_ant
        into v_registros;

        --Inserción del movimiento
        v_id_movimiento_af = kaf.f_insercion_movimiento_af(p_id_usuario, hstore(v_registros));

		--Definicion de la respuesta
		v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento almacenado(a) con exito (id_movimiento_af'||v_id_movimiento_af||')');
        v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_id_movimiento_af::varchar);

        --Devuelve la respuesta
        return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MOVAF_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_MOD')then

		begin

            select
              mov.estado,
              mov.codigo
             INTO
              v_registros
            from kaf.tmovimiento mov
            where mov.id_movimiento = v_parametros.id_movimiento;

            IF v_registros.estado != 'borrador' THEN
               raise exception 'Solo puede modificar acctivos en movimientos en borrador';
            END IF;


            --Obtiene estado funcional del activo fijo
        	select
        	id_cat_estado_fun
        	into
        	v_id_cat_estado_fun
        	from kaf.tactivo_fijo
        	where id_activo_fijo = v_parametros.id_activo_fijo;

           --  verificamos que el activo no este duplicado

            IF EXISTS(SELECT 1
                      from kaf.tmovimiento_af maf
                      where     maf.id_movimiento =  v_parametros.id_movimiento
                           and  maf.id_activo_fijo = v_parametros.id_activo_fijo
                           and maf.estado_reg = 'activo'  and maf.id_movimiento_af != v_parametros.id_movimiento_af) THEN
                 raise exception 'El activo ya se encuentre registro para este movimiento';
            END IF;

            IF not kaf.f_validar_ins_mov_af(v_parametros.id_movimiento,v_parametros.id_activo_fijo) THEN
               raise exception 'ERROR al validar activos';
            END IF;

            --Se obtiene la moneda base
            v_id_moneda_base  = param.f_get_moneda_base();

			--Sentencia de la modificacion
			update kaf.tmovimiento_af set
                id_movimiento = v_parametros.id_movimiento,
                id_activo_fijo = v_parametros.id_activo_fijo,
                id_cat_estado_fun = v_id_cat_estado_fun,
                id_movimiento_motivo = v_parametros.id_movimiento_motivo,
                importe = v_parametros.importe,
                vida_util = v_parametros.vida_util,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                id_usuario_ai = v_parametros._id_usuario_ai,
                usuario_ai = v_parametros._nombre_usuario_ai,
                depreciacion_acum = v_parametros.depreciacion_acum,
                id_moneda = v_id_moneda_base,
                importe_ant = v_parametros.importe_ant,
                vida_util_ant = v_parametros.vida_util_ant
			where id_movimiento_af=v_parametros.id_movimiento_af;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_MOVAF_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		18-03-2016 05:34:15
	***********************************/

	elsif(p_transaccion='SKA_MOVAF_ELI')then

		begin

            select
              mov.estado,
              mov.codigo
             INTO
              v_registros
            from kaf.tmovimiento mov
            inner join kaf.tmovimiento_af maf on maf.id_movimiento = mov.id_movimiento
            where maf.id_movimiento_af = v_parametros.id_movimiento_af;

            IF v_registros.estado != 'borrador' THEN
               raise exception 'Solo puede retirar activos en movimientos en borrador';
            END IF;

            --#2 inicio
            --Elimina el detalle en movimiento especial si es que tuviera
            delete from kaf.tmovimiento_af_especial
            where id_movimiento_af = v_parametros.id_movimiento_af;
            --#2 fin

			--Sentencia de la eliminacion
			delete from kaf.tmovimiento_af
            where id_movimiento_af = v_parametros.id_movimiento_af;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle Movimiento eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_movimiento_af',v_parametros.id_movimiento_af::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

    --#2 inicio
    /*********************************
    #TRANSACCION:  'SKA_MOVAFSAL_LIS'
    #DESCRIPCION:   Saldo utilizado en Distribución de Valores
    #AUTOR:         RCM
    #FECHA:         28/05/2019
    ***********************************/
    elsif (p_transaccion = 'SKA_MOVAFSAL_LIS') then

        begin

            v_id_mov_esp = null;
            if pxp.f_existe_parametro(p_tabla, 'id_movimiento_af_especial') then
                v_id_mov_esp = v_parametros.id_movimiento_af_especial;
            end if;

            --Obtención de importes del activo origen
            select coalesce(importe, 0)
            into v_monto_actualiz
            from kaf.tmovimiento_af
            where id_movimiento_af = v_parametros.id_movimiento_af;

            --Obtiene el saldo utilizado
            select coalesce(sum(importe), 0), coalesce(v_monto_actualiz * sum(porcentaje) / 100, 0)
            into v_monto_actualiz_usado, v_monto_actualiz_usado2
            from kaf.tmovimiento_af_especial mafe
            where mafe.id_movimiento_af = v_parametros.id_movimiento_af
            and (v_id_mov_esp is null or mafe.id_movimiento_af_especial <> v_id_mov_esp);

            if v_monto_actualiz_usado2 = 0 and v_monto_actualiz_usado = 0 then
                v_saldo = v_monto_actualiz;
            else
                v_saldo = v_monto_actualiz - v_monto_actualiz_usado;
            end if;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Saldo obtenido)');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af', v_parametros.id_movimiento_af::varchar);
            v_resp = pxp.f_agrega_clave(v_resp, 'saldo', v_saldo::varchar);

            --Devuelve la respuesta
            return v_resp;

        end;

    /*********************************
    #TRANSACCION:  'SKA_MONESP_LIS'
    #DESCRIPCION:   Obtiene la moneda definida para los movimientos especiales
    #AUTOR:         RCM
    #FECHA:         30/05/2019
    ***********************************/
    elsif (p_transaccion = 'SKA_MONESP_LIS') then

        begin

            select
            id_moneda, codigo
            into
            v_id_moneda_mov_esp, v_codigo_moneda
            from param.tmoneda
            where lower(codigo) = lower(pxp.f_get_variable_global('kaf_mov_especial_moneda'));

            if coalesce(v_id_moneda_mov_esp, 0) = 0 then
                raise exception 'No está parametrizada la variable global de la Moneda para la Distribución de Valores (kaf_mov_especial_moneda)';
            end if;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Moneda para movimientos especiales obtenida');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_moneda', v_id_moneda_mov_esp::varchar);
            v_resp = pxp.f_agrega_clave(v_resp, 'codigo', v_codigo_moneda::varchar);

            --Devuelve la respuesta
            return v_resp;

        end;
    --#2 fin

    --Inicio #39
    /*********************************
    #TRANSACCION:  'SKA_MOVAFMAS_ELI'
    #DESCRIPCION:   Eliminacion de registros
    #AUTOR:         admin
    #FECHA:         22/11/2019
    ***********************************/
    ELSIF (p_transaccion = 'SKA_MOVAFMAS_ELI') THEN

        BEGIN

            SELECT mov.estado, mov.codigo
            INTO
            v_registros
            FROM kaf.tmovimiento mov
            WHERE mov.id_movimiento = v_parametros.id_movimiento;

            IF v_registros.estado != 'borrador' THEN
               RAISE EXCEPTION 'Solo puede eliminar los registros de movimientos en borrador';
            END IF;

            --Elimina el detalle en movimiento especial si es que tuviera
            DELETE
            FROM kaf.tmovimiento_af_especial mesp
            USING kaf.tmovimiento_af maf
            WHERE mesp.id_movimiento_af = maf.id_movimiento_af
            AND maf.id_movimiento = v_parametros.id_movimiento;

            --Sentencia de la eliminacion
            DELETE FROM kaf.tmovimiento_af
            WHERE id_movimiento = v_parametros.id_movimiento;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Registros del movimiento eliminados');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento', v_parametros.id_movimiento::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;

    /*********************************
    #TRANSACCION:  'SKA_MOVAFMAS_INS'
    #DESCRIPCION:   Importación de activos fijos desde plantilla
    #AUTOR:         RCM
    #FECHA:         24/11/2019
    ***********************************/
    ELSIF(p_transaccion = 'SKA_MOVAFMAS_INS') THEN

        BEGIN

            --Obtiene el ID_ACTIVO_FIJO
            SELECT id_activo_fijo
            INTO v_id_activo_fijo
            FROM kaf.tactivo_fijo
            WHERE codigo = trim( v_parametros.codigo_activo); --#46

            IF v_id_activo_fijo IS NULL THEN
                RAISE EXCEPTION 'Activo fijo inexistente: %',v_parametros.codigo_activo;
            END IF;

            --Se setea los datos para llamar a la función de inserción
            SELECT
            COALESCE(v_parametros.id_movimiento, NULL) AS id_movimiento,
            COALESCE(v_id_activo_fijo, NULL) AS id_activo_fijo,
            NULL AS id_movimiento_motivo,
            NULL AS importe,
            NULL AS vida_util,
            NULL AS _nombre_usuario_ai,
            NULL AS _id_usuario_ai,
            NULL AS depreciacion_acum,
            NULL AS importe_ant,
            NULL AS vida_util_ant
            INTO v_registros;

            --Inserción del movimiento
            v_id_movimiento_af = kaf.f_insercion_movimiento_af(p_id_usuario, hstore(v_registros));

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp, 'mensaje', 'Inserción de movimiento af (id_movimiento_af: ' || v_id_movimiento_af || ')');
            v_resp = pxp.f_agrega_clave(v_resp, 'id_movimiento_af', v_id_movimiento_af::varchar);

            --Devuelve la respuesta
            return v_resp;

        END;

    --Fin #39

	else

    	raise exception 'Transaccion inexistente: %',p_transaccion;

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
COST 100;