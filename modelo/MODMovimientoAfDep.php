<?php
/**
*@package pXP
*@file gen-MODMovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/
/***************************************************************************
 ISSUE  SIS     EMPRESA     FECHA       AUTOR       DESCRIPCION
 #2     KAF     ETR         11/01/2019  RCM         Actualización de listado detalle depreciación interfaz
 #35    KAF     ETR         11/10/2019  RCM     	Adición de botón para procesar Detalle Depreciación
 ***************************************************************************/
class MODMovimientoAfDep extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_MAFDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_dep','bigint');
		$this->captura('vida_util','int4');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('depreciacion_per_actualiz','numeric');
		$this->captura('id_movimiento_af','int4');
		$this->captura('vida_util_ant','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('monto_vigente_ant','numeric');
		$this->captura('depreciacion_acum_actualiz','numeric');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('factor','numeric');
		$this->captura('depreciacion_per','numeric');
		$this->captura('depreciacion','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('depreciacion_per_ant','numeric');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion_acum_ant','numeric');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('depreciacion_per_actualiz','depreciacion_per_actualiz','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('vida_util_ant','vida_util_ant','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_vigente_ant','monto_vigente_ant','numeric');
		$this->setParametro('depreciacion_acum_actualiz','depreciacion_acum_actualiz','numeric');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('factor','factor','numeric');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('depreciacion','depreciacion','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_per_ant','depreciacion_per_ant','numeric');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_dep','id_movimiento_af_dep','bigint');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('depreciacion_per_actualiz','depreciacion_per_actualiz','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('vida_util_ant','vida_util_ant','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_vigente_ant','monto_vigente_ant','numeric');
		$this->setParametro('depreciacion_acum_actualiz','depreciacion_acum_actualiz','numeric');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('factor','factor','numeric');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('depreciacion','depreciacion','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_per_ant','depreciacion_per_ant','numeric');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_dep','id_movimiento_af_dep','bigint');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarMovimientoAfDepRes(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_MAFDEPRES_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_dep','bigint');
		$this->captura('id_movimiento_af','int4');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('fecha','date');
		$this->captura('depreciacion_acum_ant','numeric');
		$this->captura('depreciacion_per_ant','numeric');
		$this->captura('monto_actualiz_ant','numeric');
		$this->captura('vida_util_ant','int4');
		$this->captura('depreciacion_acum_actualiz','numeric');
		$this->captura('depreciacion_per_actualiz','numeric');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('depreciacion_per','numeric');
		$this->captura('monto_vigente','numeric');
		$this->captura('vida_util','int4');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('factor','numeric');
		$this->captura('inc_monto_actualiz','numeric');
		$this->captura('inc_depreciacion_acum_actualiz','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarMovimientoAfDepResCab(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_RESCAB_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->capturaCount('total_monto_actualiz_real','numeric');
		$this->capturaCount('total_depreciacion_acum_real','numeric');
		$this->capturaCount('total_monto_vigente_real','numeric');


		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('estado','varchar');
		$this->captura('principal','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('monto_rescate','numeric');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('estado_reg','varchar');
		$this->captura('tipo','varchar');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('fecha_ult_dep','date');
		$this->captura('fecha_ini_dep','date');
		$this->captura('monto_vigente_orig','numeric');
		$this->captura('vida_util','int4');
		$this->captura('vida_util_orig','int4');
		$this->captura('id_movimiento_af','int4');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('codigo','varchar');

		$this->captura('monto_vigente_real','numeric');
		$this->captura('vida_util_real','integer');
		$this->captura('depreciacion_acum_ant_real','numeric');
		$this->captura('depreciacion_acum_real','numeric');
		$this->captura('depreciacion_per_real','numeric');

		$this->captura('monto_actualiz_real','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('id_moneda_dep','int4');
		$this->captura('desc_moneda','varchar');



		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

    function listarMovimientoAfDepResCabPr(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_RESCABPR_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_activo_fijo','id_activo_fijo','integer');


		$this->capturaCount('total_monto_actualiz_real','numeric');
		$this->capturaCount('total_depreciacion_acum_real','numeric');
		$this->capturaCount('total_monto_vigente_real','numeric');
		$this->capturaCount('max_vida_util_real','integer');

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('estado','varchar');
		$this->captura('principal','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('monto_rescate','numeric');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('estado_reg','varchar');
		$this->captura('tipo','varchar');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('fecha_ult_dep','date');
		$this->captura('fecha_ini_dep','date');
		$this->captura('monto_vigente_orig','numeric');
		$this->captura('vida_util','int4');
		$this->captura('vida_util_orig','int4');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('codigo','varchar');
		$this->captura('monto_vigente_real','numeric');
		$this->captura('vida_util_real','integer');
		$this->captura('depreciacion_acum_real','numeric');
		$this->captura('depreciacion_per_real','numeric');
		$this->captura('depreciacion_acum_ant_real','numeric');
		$this->captura('monto_actualiz_real','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('id_moneda_dep','int4');
		$this->captura('desc_moneda','varchar');
		$this->captura('fecha_fin','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarDepreciacionMensual(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_RDEPMEN_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		$this->setParametro('id_movimiento','id_movimiento','integer');
		$this->setParametro('id_moneda','id_moneda','integer');

		//Definicion de la lista del resultado del query
		$this->captura('numero','bigint');
		$this->captura('codigo','varchar');
		$this->captura('codigo_ant','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('fecha_ini_dep','text');
		$this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
		$this->captura('codigo_tcc','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('ubicacion','varchar');//10
		$this->captura('desc_funcionario','text');
		$this->captura('monto_vigente_orig_100','numeric');
        $this->captura('monto_vigente_orig','numeric');
        $this->captura('af_altas','numeric');
        $this->captura('af_bajas','numeric');
        $this->captura('af_traspasos','numeric');
        $this->captura('inc_valor_actualiz','numeric');
		$this->captura('valor_actualiz','numeric');
        $this->captura('vida_util','integer');
        $this->captura('vida_util_orig','integer');
		$this->captura('dep_acum_gestant','numeric');
		$this->captura('actualiz_dep_gest_ant','numeric');
		$this->captura('depreciacion_mensual','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('depreciacion_acum_bajas','numeric');
		$this->captura('depreciacion_acum_traspasos','numeric');
		$this->captura('depreciacion_gestion','numeric');
		$this->captura('valor_activo','numeric');
		$this->captura('inc_actualiz','numeric');//20
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('tipo_cambio_fin','numeric');//30
		$this->captura('fecha_ini','date');
		$this->captura('fecha_fin','date');
		$this->captura('cuenta_activo','text');
		$this->captura('cuenta_dep_acum','text');
		$this->captura('cuenta_deprec','text');//35

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Inicio #2: Actualización listado detalle depreciación interfaz
	function listarDeprecFormato(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_LISDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','integer');
		$this->captura('id_activo_fijo_valor','integer');
		$this->captura('codigo','varchar');
		$this->captura('fecha','date');
		$this->captura('id_moneda','integer');
		$this->captura('valor_vigente_actualiz','numeric');
		$this->captura('inc_actualiz','numeric');
		$this->captura('valor_actualiz','numeric');
		$this->captura('vida_util_ant','integer');
		$this->captura('dep_acum_ant','numeric');
		$this->captura('inc_actualiz_dep_acum','numeric');
		$this->captura('dep_acum_ant_actualiz','numeric');
		$this->captura('dep_mes','numeric');
		$this->captura('dep_periodo','numeric');
		$this->captura('dep_acum','numeric');
		$this->captura('valor_neto','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarDeprecFormatoTotales(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_LISDEPTOT_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','integer');
		$this->captura('codigo','varchar');
		$this->captura('id_moneda','integer');
		$this->captura('fecha','date');
		$this->captura('vida_util_ant','integer');
		$this->captura('dep_periodo','numeric');
		$this->captura('dep_acum','numeric');
		$this->captura('valor_neto','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #2

	//Inicio #35
	function procesarDetalleDepreciacion() {
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'kaf.ft_movimiento_af_dep_ime';
		$this->transaccion = 'SKA_PRODETDEP_INS';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento', 'id_movimiento', 'int');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function verificarProcesarDetalleDepreciacion() {
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'kaf.ft_movimiento_af_dep_ime';
		$this->transaccion = 'SKA_PRODETDEP_VER';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento', 'id_movimiento', 'int');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #35

}
?>