CREATE OR REPLACE FUNCTION kaf.ft_clasificacion_ime (
  p_administrador integer,
  p_id_usuario integer,
  p_tabla varchar,
  p_transaccion varchar
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:       Sistema de Activos Fijos - K
 FUNCION:       kaf.ft_clasificacion_ime
 DESCRIPCION:   Funcion que gestiona las operaciones basicas (inserciones, modificaciones, eliminaciones de la tabla 'kaf.tclasificacion'
 AUTOR:          (admin)
 FECHA:         09-11-2015 01:22:17
 COMENTARIOS:   
***************************************************************************
 HISTORIAL DE MODIFICACIONES:

 DESCRIPCION:   
 AUTOR:         
 FECHA:     
***************************************************************************/

DECLARE

    v_nro_requerimiento     integer;
    v_parametros            record;
    v_id_requerimiento      integer;
    v_resp                  varchar;
    v_nombre_funcion        text;
    v_mensaje_error         text;
    v_id_clasificacion      integer;
    v_codigo                varchar;
    v_sep                   varchar;   
    v_nivel                 integer;
    v_rec                   record;
    v_cod_fin               varchar;
    v_ins                   boolean;
    v_id_clasificacion_fk   integer;
    v_sql                   varchar;
    v_tmp                   varchar;
                
BEGIN

    v_nombre_funcion = 'kaf.ft_clasificacion_ime';
    v_parametros = pxp.f_get_record(p_tabla);
    v_sep = '.';

    /*********************************    
    #TRANSACCION:  'SKA_CLAF_INS'
    #DESCRIPCION:   Insercion de registros
    #AUTOR:     admin   
    #FECHA:     09-11-2015 01:22:17
    ***********************************/

    if(p_transaccion='SKA_CLAF_INS')then
                    
        begin

            --Obtiene el código del padre
            v_codigo = v_parametros.codigo;
            v_cod_fin = upper(v_codigo);

            if v_parametros.id_clasificacion_fk <> '' then
                v_cod_fin = kaf.f_get_codigo_clasificacion_rec(v_parametros.id_clasificacion_fk::integer)||v_sep||upper(v_codigo);
            end if;

            --Verifica que el nuevo código no exista
            if exists(select 1 from kaf.tclasificacion
                        where codigo_completo_tmp = v_cod_fin)then
                raise exception 'Código existente: %',v_cod_fin;
            end if;

            --Verifica el padre
            if v_parametros.id_clasificacion_fk = 'id' or v_parametros.id_clasificacion_fk = '' then
                v_id_clasificacion_fk = null;
            else 
                v_id_clasificacion_fk = v_parametros.id_clasificacion_fk::integer;
            end if;

            --Sentencia de la insercion
            insert into kaf.tclasificacion(
                id_clasificacion_fk,
                id_cat_metodo_dep,
                id_concepto_ingas,
                codigo,
                nombre,
                vida_util,
                correlativo_act,
                monto_residual,
                tipo,
                final,
                icono,
                id_usuario_reg,
                id_usuario_mod,
                fecha_reg,
                fecha_mod,
                estado_reg,
                id_usuario_ai,
                usuario_ai,
                descripcion,
                tipo_activo,
                depreciable,
                contabilizar,
                codigo_completo_tmp
            ) values(
                v_id_clasificacion_fk,
                v_parametros.id_cat_metodo_dep,
                v_parametros.id_concepto_ingas,
                upper(v_codigo),
                upper(v_parametros.nombre),
                v_parametros.vida_util,
                0,
                v_parametros.monto_residual,
                v_parametros.tipo,
                v_parametros.final,
                v_parametros.icono,
                p_id_usuario,
                null,
                now(),
                null,
                'activo',
                null,
                null,
                upper(v_parametros.descripcion),
                v_parametros.tipo_activo,
                v_parametros.depreciable,
                v_parametros.contabilizar,
                v_cod_fin

            )RETURNING id_clasificacion into v_id_clasificacion;

            --Excepcion CBOL, replica de la clasificacion
            v_ins=true;
            if pxp.f_get_variable_global('kaf_clasif_replicar') = 'true' then
                v_nivel = length(regexp_replace(v_codigo, '[^\.]', '', 'g'))+1;
                if v_nivel = 3 or v_nivel = 4 then
                    for v_rec in (select * from kaf.tclasificacion 
                                where length(regexp_replace(codigo, '[^\.]', '', 'g'))+1 = v_nivel-1) loop
                        if not exists(select 1 from kaf.tclasificacion where codigo = v_rec.codigo||'.'||v_parametros.codigo) then

                            --Verifica el nivel para hacer la insercion
                            if v_nivel = 4 then
                                if substring(v_rec.codigo from length(v_rec.codigo)-3 for 4) != v_cod_fin then
                                    v_ins = false;
                                end if;
                            end if;


                            if v_ins then
                                insert into kaf.tclasificacion(
                                    id_clasificacion_fk,
                                    id_cat_metodo_dep,
                                    id_concepto_ingas,
                                    codigo,
                                    nombre,
                                    vida_util,
                                    correlativo_act,
                                    monto_residual,
                                    tipo,
                                    final,
                                    icono,
                                    id_usuario_reg,
                                    id_usuario_mod,
                                    fecha_reg,
                                    fecha_mod,
                                    estado_reg,
                                    id_usuario_ai,
                                    usuario_ai,
                                    descripcion,
                                    tipo_activo,
                                    depreciable,
                                    contabilizar,
                                    codigo_completo_tmp
                                ) values(
                                    v_rec.id_clasificacion,
                                    v_parametros.id_cat_metodo_dep,
                                    v_parametros.id_concepto_ingas,
                                    upper(v_rec.codigo||'.'||v_parametros.codigo),
                                    upper(v_parametros.nombre),
                                    v_parametros.vida_util,
                                    0,
                                    v_parametros.monto_residual,
                                    v_parametros.tipo,
                                    v_parametros.final,
                                    v_parametros.icono,
                                    p_id_usuario,
                                    null,
                                    now(),
                                    null,
                                    'activo',
                                    null,
                                    null,
                                    upper(v_parametros.descripcion),
                                    v_parametros.tipo_activo,
                                    v_parametros.depreciable,
                                    v_parametros.contabilizar,
                                    v_parametros.codigo_completo_tmp
                                );
                            end if;
                            v_ins = true;
                            
                        end if;
                    end loop;
                end if;
            end if;
            
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación almacenado(a) con exito (id_clasificacion'||v_id_clasificacion||')'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_id_clasificacion::varchar);

            --Devuelve la respuesta
            return v_resp;

        end;

    /*********************************    
    #TRANSACCION:  'SKA_CLAF_MOD'
    #DESCRIPCION:   Modificacion de registros
    #AUTOR:     admin   
    #FECHA:     09-11-2015 01:22:17
    ***********************************/

    elsif(p_transaccion='SKA_CLAF_MOD')then

        begin
        
            --Verifica si existen activos registrados en la clasificacion a modificar o en alguna de sus ramas
            create temp table tt_clasif_activos(
            id_activo_fijo integer
            ) on commit drop;
            
            v_tmp = kaf.f_get_id_clasificaciones(v_parametros.id_clasificacion,'hijos');
                    
            v_sql = 'insert into tt_clasif_activos
                    select af.id_activo_fijo
                    from kaf.tactivo_fijo af
                    where coalesce(af.codigo,'''') != ''''
                    and af.id_clasificacion in ('||v_tmp||')';
                    
            execute(v_sql);
            
            if exists(select 1 from tt_clasif_activos) then
                raise exception 'No es posible realizar ninguna modificación porque existen activos fijos registrados con esta clasificación';
            end if;
            
            --Obtiene el código del padre
            v_codigo = v_parametros.codigo;
            v_cod_fin = upper(v_codigo);
            if v_parametros.id_clasificacion_fk != '' then
                v_cod_fin = kaf.f_get_codigo_clasificacion_rec(v_parametros.id_clasificacion_fk::integer)||v_sep||upper(v_codigo);
            end if;

            --Verifica que el nuevo código no exista
            if exists(select 1 from kaf.tclasificacion
                        where codigo_completo_tmp = v_cod_fin
                        and id_clasificacion != v_parametros.id_clasificacion)then
                raise exception 'Código existente: %',v_cod_fin;
            end if;

            --Verifica el padre
            if v_parametros.id_clasificacion_fk = 'id' or v_parametros.id_clasificacion_fk = '' then
                v_id_clasificacion_fk = null;
            else 
                v_id_clasificacion_fk = v_parametros.id_clasificacion_fk::integer;
            end if;
            
            --Sentencia de la modificacion
            update kaf.tclasificacion set
                id_clasificacion_fk = v_id_clasificacion_fk,
                id_cat_metodo_dep = v_parametros.id_cat_metodo_dep,
                id_concepto_ingas = v_parametros.id_concepto_ingas,
                codigo  = v_codigo,
                nombre = upper(v_parametros.nombre),
                vida_util = v_parametros.vida_util,
                correlativo_act = v_parametros.correlativo_act,
                monto_residual = v_parametros.monto_residual,
                tipo = v_parametros.tipo,
                final = v_parametros.final,
                icono = v_parametros.icono,
                id_usuario_mod = p_id_usuario,
                fecha_mod = now(),
                estado_reg = 'activo',
                --id_usuario_ai = v_parametros.id_usuario_ai,
                --usuario_ai = v_parametros.usuario_ai,
                descripcion = upper(v_parametros.descripcion),
                tipo_activo = v_parametros.tipo_activo,
                depreciable = v_parametros.depreciable,
                contabilizar = v_parametros.contabilizar,
                codigo_completo_tmp = v_cod_fin
            where id_clasificacion=v_parametros.id_clasificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación modificado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
               
            --Devuelve la respuesta
            return v_resp;
            
        end;

    /*********************************    
    #TRANSACCION:  'SKA_CLAF_ELI'
    #DESCRIPCION:   Eliminacion de registros
    #AUTOR:     admin   
    #FECHA:     09-11-2015 01:22:17
    ***********************************/

    elsif(p_transaccion='SKA_CLAF_ELI')then

        begin
            --Sentencia de la eliminacion
            delete from kaf.tclasificacion
            where id_clasificacion=v_parametros.id_clasificacion;
               
            --Definicion de la respuesta
            v_resp = pxp.f_agrega_clave(v_resp,'mensaje','Clasificación eliminado(a)'); 
            v_resp = pxp.f_agrega_clave(v_resp,'id_clasificacion',v_parametros.id_clasificacion::varchar);
              
            --Devuelve la respuesta
            return v_resp;

        end;
         
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