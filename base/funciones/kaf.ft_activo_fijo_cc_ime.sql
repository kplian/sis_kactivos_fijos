CREATE OR REPLACE FUNCTION kaf.ft_activo_fijo_cc_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Activos Fijos
 FUNCION: 		kaf.ft_activo_fijo_cc_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tactivo_fijo_cc'
 AUTOR: 		 (admin)
 FECHA:	        11-05-2019 07:14:58
 COMENTARIOS:
 ***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #16    KAF       ETR           18/06/2019  RCM         Inclusión procedimiento para completar prorrateo con CC por defecto por AF
***************************************************************************/

DECLARE

	v_nro_requerimiento    	integer;
	v_parametros           	record;
	v_id_requerimiento     	integer;
	v_resp		            varchar;
	v_nombre_funcion        text;
	v_mensaje_error         text;
	v_id_activo_fijo_cc 	integer;
	v_horas					numeric;


    v_id_activo_fijo	integer;
    v_id_tipo_cc		integer;
    v_gestion			integer;
    v_mes				integer;
    v_id_gestion 		integer;
    v_id_cc				integer;
    v_mensaje			text;
    v_id_periodo		integer;
    v_registros			record;
    v_codigo_activo		varchar;
    v_tope_mensual      numeric;
    v_resp_fun          varchar;
    v_tope_mensual      numeric;

BEGIN

    v_nombre_funcion = 'kaf.ft_activo_fijo_cc_ime';
    v_parametros = pxp.f_get_record(p_tabla);

	/*********************************
 	#TRANSACCION:  'SKA_AFCCOSTO_INS'
 	#DESCRIPCION:	Insercion de registros
 	#AUTOR:		admin
 	#FECHA:		11-05-2019 07:14:58
	***********************************/
	if(p_transaccion='SKA_AFCCOSTO_INS')then

        begin

            --Obtención del tope mensual
            v_tope_mensual = pxp.f_get_variable_global('kaf_activo_fijo_cc')::numeric;

            --Obtención del total de horas
            select sum(cantidad_horas)
            into v_horas
            from kaf.tactivo_fijo_cc
            where id_activo_fijo=v_parametros.id_activo_fijo
            and estado_reg='activo';

        	if (v_horas + v_parametros.cantidad_horas) > v_tope_mensual then
            	raise exception 'Esta ingresando % horas y ya se tiene registrado % horas.El maximo para el activo es de %', v_parametros.cantidad_horas, v_horas, v_tope_mensual;
            end if;


    --if ya existe la relacion de activo-centroCosto
    		if(v_parametros.mes is NULL) THEN
            	v_gestion:=(select extract (year from now()::date))::integer;
                v_mes:=(select extract (month from now()::date))::integer;
            else
                v_gestion:=(select extract (year from v_parametros.mes))::integer;
                v_mes:=(select extract (month from v_parametros.mes))::integer;
            end if;

            if exists (select 1 from kaf.tactivo_fijo_cc where id_activo_fijo=v_parametros.id_activo_fijo
            and id_centro_costo=v_parametros.id_centro_costo and extract (month from mes)=v_mes
            and extract (year from mes)=v_gestion and estado_reg='activo'
            ) then
               raise exception 'Los datos para el activo %, y centro de costo %  ya existen',v_parametros.id_activo_fijo,v_parametros.id_centro_costo;
            end if;

        	--Sentencia de la insercion
        	insert into kaf.tactivo_fijo_cc(
			id_activo_fijo,
            id_centro_costo,
            mes,
			cantidad_horas,
			estado_reg,
			id_usuario_ai,
			usuario_ai,
			fecha_reg,
			id_usuario_reg,
			fecha_mod,
			id_usuario_mod

          	) values(
            v_parametros.id_activo_fijo,
            v_parametros.id_centro_costo,
			v_parametros.mes,
			v_parametros.cantidad_horas,
			'activo',
			v_parametros._id_usuario_ai,
			v_parametros._nombre_usuario_ai,
			now(),
			p_id_usuario,
			null,
			null
			)RETURNING id_activo_fijo_cc into v_id_activo_fijo_cc;

			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Centro de Costo almacenado(a) con exito (id_activo_fijo_cc'||v_id_activo_fijo_cc||')');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_cc',v_id_activo_fijo_cc::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_AFCCOSTO_MOD'
 	#DESCRIPCION:	Modificacion de registros
 	#AUTOR:		admin
 	#FECHA:		11-05-2019 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCCOSTO_MOD')then

		begin

            --Obtención del tope mensual
            v_tope_mensual = pxp.f_get_variable_global('kaf_activo_fijo_cc')::numeric;

            select sum(cantidad_horas)
            into v_horas
            from kaf.tactivo_fijo_cc
            where id_activo_fijo=v_parametros.id_activo_fijo
            and estado_reg='activo';

         --raise exception 'a%,b%, c%',v_horas,(select cantidad_horas from kaf.tactivo_fijo_cc where id_activo_fijo_cc=v_parametros.id_activo_fijo_cc  ), v_parametros.cantidad_horas;
            if((v_horas-(select cantidad_horas from kaf.tactivo_fijo_cc where id_activo_fijo_cc=v_parametros.id_activo_fijo_cc  ) + v_parametros.cantidad_horas) > v_tope_mensual) then
        	   raise exception 'Esta ingresando % horas y ya se tiene registrado % horas adicional a este registro.El maximo para el Activo es de %',v_parametros.cantidad_horas,(v_horas-(select cantidad_horas from kaf.tactivo_fijo_cc where id_activo_fijo_cc=v_parametros.id_activo_fijo_cc  )), v_tope_mensual;
        	end if;

        --if ya existe la relacion de activo-centroCosto
    		if(v_parametros.mes is NULL) THEN
            	v_gestion:=(select extract (year from now()::date))::integer;
                v_mes:=(select extract (month from now()::date))::integer;
            else
                v_gestion:=(select extract (year from v_parametros.mes))::integer;
                v_mes:=(select extract (month from v_parametros.mes))::integer;
            end if;

            if exists (select 1 from kaf.tactivo_fijo_cc where id_activo_fijo=v_parametros.id_activo_fijo
                        and id_centro_costo=v_parametros.id_centro_costo and extract (month from mes)=v_mes
                        and extract (year from mes)=v_gestion
                        and id_activo_fijo_cc!=v_parametros.id_activo_fijo_cc) then
               raise exception 'Los datos para el activo %, y centro de costo %  ya existen',v_parametros.id_activo_fijo,v_parametros.id_centro_costo;
            end if;

			--Sentencia de la modificacion
			update kaf.tactivo_fijo_cc set
			id_activo_fijo = v_parametros.id_activo_fijo,
            id_centro_costo = v_parametros.id_centro_costo,
            mes = v_parametros.mes,
			cantidad_horas = v_parametros.cantidad_horas,
			fecha_mod = now(),
			id_usuario_mod = p_id_usuario,
			id_usuario_ai = v_parametros._id_usuario_ai,
			usuario_ai = v_parametros._nombre_usuario_ai
			where id_activo_fijo_cc=v_parametros.id_activo_fijo_cc;

			--Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Centro de Costo modificado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_cc',v_parametros.id_activo_fijo_cc::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

	/*********************************
 	#TRANSACCION:  'SKA_AFCCOSTO_ELI'
 	#DESCRIPCION:	Eliminacion de registros
 	#AUTOR:		admin
 	#FECHA:		10-05-2019 07:14:58
	***********************************/

	elsif(p_transaccion='SKA_AFCCOSTO_ELI')then

		begin
			--Sentencia de la eliminacion
			update kaf.tactivo_fijo_cc
            set estado_reg='inactivo'
            where id_activo_fijo_cc=v_parametros.id_activo_fijo_cc;

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Centro de Costo eliminado(a)');
            v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_cc',v_parametros.id_activo_fijo_cc::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

    /*********************************
 	#TRANSACCION:  'SKA_AFCCOSTO_IMP'
 	#DESCRIPCION:	Insercion de detalle de valoración del activo fijo
 	#AUTOR:
 	#FECHA:			17/05/2019
	***********************************/

	elsif(p_transaccion='SKA_AFCCOSTO_IMP')then

        begin
			v_mensaje:='';

             --Obtención del tope mensual
            v_tope_mensual = pxp.f_get_variable_global('kaf_activo_fijo_cc')::numeric;

			if (v_parametros.nombre_archivo not in (select distinct nombre_archivo from kaf.tactivo_fijo_cc_log)) then
               delete from kaf.tactivo_fijo_cc_log;
            end if;

            --Obtención id_proyecto
        	select id_activo_fijo
        	into v_id_activo_fijo
        	from kaf.tactivo_fijo
        	where codigo = trim(v_parametros.activo_fijo)
            and estado_reg='activo'
            ;

        	if v_id_activo_fijo is null then
        		v_mensaje:=v_mensaje||'Activo Fijo inexistente o inactivo'||v_parametros.activo_fijo||', ';
        	end if;

        	--Obtención del tipo de centro de costo
			select tcc.id_tipo_cc
			into v_id_tipo_cc
			from param.ttipo_cc tcc
			where tcc.codigo = trim(v_parametros.centro_costo);

			if v_id_tipo_cc is not null then
        		if(v_parametros.mes is NULL) THEN
                	v_gestion:=(select extract (year from now()::date))::integer;
                    v_mes:=(select extract (month from now()::date))::integer;
                else
                    v_gestion:=(select extract (year from v_parametros.mes))::integer;
                    v_mes:=(select extract (month from v_parametros.mes))::integer;
                end if;

                v_id_gestion:=(select id_gestion from param.tgestion where gestion=v_gestion);
                v_id_cc:=(select id_centro_costo from param.tcentro_costo where  id_tipo_cc=v_id_tipo_cc and id_gestion=v_id_gestion and estado_reg='activo');

                if v_id_cc is null then
                    v_mensaje:=v_mensaje|| 'Centro de Costo ' ||v_parametros.centro_costo||' no definido o inactivo, ';
                end if;

            else
                v_mensaje:=v_mensaje|| 'Centro de Costo ' ||v_parametros.centro_costo||' no definido o inactivo, ';
            end if;

	        if (((select coalesce(sum(cantidad_horas),0) from kaf.tactivo_fijo_cc where id_activo_fijo=v_id_activo_fijo and estado_reg='activo')+ coalesce(v_parametros.cantidad_horas,0)) > v_tope_mensual) then
               v_mensaje:=v_mensaje|| 'La cantidad de horas a subir mas las ya registradas, para '||v_parametros.activo_fijo||' supera el maximo permitido (' || v_tope_mensual || ')';
              -- raise exception 'La cantidad de horas para %, supera el maximo permitido (720)', v_parametros.activo_fijo;
            end if;

            --if ya existe la relacion de activo-centroCosto
            if exists (select 1 from kaf.tactivo_fijo_cc where id_activo_fijo=v_id_activo_fijo
            and id_centro_costo=v_id_cc and extract (month from mes)=v_mes
            and extract (year from mes)=v_gestion and estado_reg='activo'
            ) then
               v_mensaje:=v_mensaje|| 'Los datos para el activo '||v_parametros.activo_fijo||' centro de costo '||v_parametros.centro_costo||' y mes ya existen' ;
            end if;



            if(v_mensaje!='') then
            	insert into kaf.tactivo_fijo_cc_log
                (activo_fijo,centro_costo,
                cantidad_horas,
                mes,
                detalle,
                nombre_archivo)
                values (v_parametros.activo_fijo,
                v_parametros.centro_costo,
                v_parametros.cantidad_horas,
                v_parametros.mes,
                v_mensaje,
                v_parametros.nombre_archivo)  RETURNING id_activo_fijo_cc_log into v_id_activo_fijo_cc;

                --verificar que activos fijos que tengan alguna asignacion (en el mes del archivo) no completaron las 720 horas
                for v_registros in (select id_activo_fijo, sum(cantidad_horas) as cantidad_horas
                                    from kaf.tactivo_fijo_cc
                                    where extract (month from mes)=v_mes
            						and extract (year from mes)=v_gestion
                                    and estado_reg='activo'
                                    group by id_activo_fijo
                                    having sum(cantidad_horas) < v_tope_mensual) loop

                    v_codigo_activo := (select codigo from kaf.tactivo_fijo where id_activo_fijo=v_registros.id_activo_fijo );
                	v_mensaje:=('- Activo: ' ||v_codigo_activo || ' solo tiene '|| v_registros.cantidad_horas || ' horas asignadas. Debe completar a ' || v_tope_mensual || ' para el periodo '||v_mes);

                    if not exists (select 1 from kaf.tactivo_fijo_cc_log where activo_fijo=v_codigo_activo and detalle=v_mensaje) then
                      insert into kaf.tactivo_fijo_cc_log
                            (activo_fijo,centro_costo,
                            cantidad_horas,
                            mes,
                            detalle,
                            nombre_archivo)
                            values (v_codigo_activo,
                            '-',
                            v_registros.cantidad_horas,
                            v_parametros.mes,
                            v_mensaje,
                            v_parametros.nombre_archivo)  RETURNING id_activo_fijo_cc_log into v_id_activo_fijo_cc;
                    end if;
                end loop;

            else


                --Insert
                insert into kaf.tactivo_fijo_cc(
                id_activo_fijo,
                id_centro_costo,
                cantidad_horas,
                mes,
                estado_reg,
                id_usuario_ai,
                fecha_reg,
                usuario_ai,
                id_usuario_reg,
                fecha_mod,
                id_usuario_mod
                ) values(
                v_id_activo_fijo,
                v_id_cc,
                v_parametros.cantidad_horas,
                v_parametros.mes,
                'activo',
                v_parametros._id_usuario_ai,
                now(),
                v_parametros._nombre_usuario_ai,
                p_id_usuario,
                null,
                null
                ) RETURNING id_activo_fijo_cc into v_id_activo_fijo_cc;
			end if;
			--Definicion de la respuesta
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Detalle almacenado(a) con exito (id_activo_fijo_cc'||v_id_activo_fijo_cc||')');
			v_resp = pxp.f_agrega_clave(v_resp,'id_activo_fijo_cc',v_id_activo_fijo_cc::varchar);

            --Devuelve la respuesta
            return v_resp;

		end;

    --Inicio #16
    /*********************************
    #TRANSACCION:  'SKA_AFCCPROC_MOD'
    #DESCRIPCION:   Completa el prorrateo por el total de horas al mes por CC defecto de cada activo fijo
    #AUTOR:         RCM
    #FECHA:         18/06/2019
    ***********************************/

    ELSIF (p_transaccion = 'SKA_AFCCPROC_MOD') THEN

        BEGIN

            --Llama a la función para generar el prorrateo mensual faltante
            v_resp_fun = kaf.f_generar_prorrateo_mensual_cc(p_id_usuario, v_parametros.fecha);

            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Prorrateo mensual completado: ' || v_parametros.fecha::varchar);
            v_resp = pxp.f_agrega_clave(v_resp,'fecha',v_parametros.fecha::varchar);

            --Devuelve la respuesta
            RETURN v_resp;

        END;
    --Fin #16

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