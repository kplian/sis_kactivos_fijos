CREATE OR REPLACE FUNCTION kaf.f_insercion_movimiento_af (
  p_id_usuario integer,
  p_parametros public.hstore
)
RETURNS integer AS
$body$
/*
Autor: RCM
Fecha: 03/08/2017
Descripción: Función para crear un nuevo movimiento
*/
DECLARE

    v_nombre_funcion		varchar;
    v_resp					varchar;
    v_registros             record;
    v_id_cat_estado_fun     integer;
    v_id_movimiento_af      integer;
    v_aux                   record;

BEGIN

    --Nombre de la función
    v_nombre_funcion = 'kaf.f_insercion_movimiento_af';

    select 
    mov.estado,
    mov.codigo,
    cat.codigo as codigo_movimiento,
    mov.id_depto
    into 
    v_registros
    from kaf.tmovimiento mov
    inner join  param.tcatalogo cat on cat.id_catalogo = mov.id_cat_movimiento
    where mov.id_movimiento = (p_parametros->'id_movimiento')::integer;
        
            
    if not kaf.f_validar_ins_mov_af((p_parametros->'id_movimiento')::integer,(p_parametros->'id_activo_fijo')::integer) then
       raise exception 'Error al validar activo fijo';
    end if;
    
    if v_registros.estado != 'borrador' THEN
       raise exception 'Solo puede insertar activos en movimientos en borrador';
    end if;

    --Obtiene estado funcional del activo fijo
    select
    id_cat_estado_fun
    into
    v_id_cat_estado_fun
    from kaf.tactivo_fijo
    where id_activo_fijo = (p_parametros->'id_activo_fijo')::integer;
            
    --Verificamos que el activo no esté duplicado
    if exists(select 1 
            from kaf.tmovimiento_af maf 
            where maf.id_movimiento = (p_parametros->'id_movimiento')::integer 
            and  maf.id_activo_fijo = (p_parametros->'id_activo_fijo')::integer 
            and maf.estado_reg = 'activo') then

        for v_aux in select * from kaf.tmovimiento_af maf 
            where maf.id_movimiento = (p_parametros->'id_movimiento')::integer loop
            raise notice '%',v_aux.id_activo_fijo;
        end loop;

         raise exception 'El activo ya se encuentra registrado en el movimiento actual';
    end if;

    --Inserción del registro
    insert into kaf.tmovimiento_af(
        id_movimiento,
        id_activo_fijo,
        id_cat_estado_fun,
        id_movimiento_motivo,
        estado_reg,
        importe,
        vida_util,
        fecha_reg,
        usuario_ai,
        id_usuario_reg,
        id_usuario_ai,
        id_usuario_mod,
        fecha_mod,
        depreciacion_acum
    ) values(
        (p_parametros->'id_movimiento')::integer,
        (p_parametros->'id_activo_fijo')::integer,
        v_id_cat_estado_fun,
        (p_parametros->'id_movimiento_motivo')::integer,
        'activo',
        (p_parametros->'importe')::numeric,
        (p_parametros->'vida_util')::integer,
        now(),
        (p_parametros->'_nombre_usuario_ai')::varchar,
        p_id_usuario,
        (p_parametros->'_id_usuario_ai')::integer,
        null,
        null,
        (p_parametros->'depreciacion_acum')::numeric
    ) returning id_movimiento_af into v_id_movimiento_af;
    
    
    ------------
	--Respuesta
    ------------
    return v_id_movimiento_af;

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