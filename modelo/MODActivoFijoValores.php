<?php
/**
*@package pXP
*@file gen-MODActivoFijoValores.php
*@author  (admin)
*@date 04-05-2016 03:02:26
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           11/01/2019  RCM         Actualización de listado detalle depreciación interfaz
 #40    KAF       ETR           05/12/2019  RCM         Adición de campos faltantes
 #70    KAF       ETR           03/08/2020  RCM         Adición de fecha para TC ini de la primera depreciación
 ***************************************************************************/
class MODActivoFijoValores extends MODbase{

	function __construct(CTParametro $pParam){		parent::__construct($pParam);
	}

	function listarActivoFijoValores(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_valores_sel';
		$this->transaccion='SKA_ACTVAL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

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
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo','varchar');
		$this->captura('fecha_fin','date');
		$this->captura('monto_vigente_orig_100','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('desc_moneda','varchar');
		$this->captura('monto_vigente_actualiz_inicial', 'numeric');
        $this->captura('depreciacion_acum_inicial', 'numeric');
        $this->captura('depreciacion_per_inicial', 'numeric');
        $this->captura('importe_modif', 'numeric');
        $this->captura('importe_modif_sin_act', 'numeric');
        $this->captura('fecha_tc_ini_dep', 'date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarActivoFijoValores(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_valores_ime';
		$this->transaccion='SKA_ACTVAL_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('principal','principal','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('monto_vigente_orig','monto_vigente_orig','numeric');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('vida_util_orig','vida_util_orig','int4');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('monto_vigente_orig_100','monto_vigente_orig_100','numeric');
		$this->setParametro('fecha_tc_ini_dep','fecha_tc_ini_dep','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarActivoFijoValores(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_valores_ime';
		$this->transaccion='SKA_ACTVAL_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('principal','principal','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('monto_vigente_orig','monto_vigente_orig','numeric');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('vida_util_orig','vida_util_orig','int4');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('monto_vigente_orig_100','monto_vigente_orig_100','numeric');
		$this->setParametro('fecha_tc_ini_dep','fecha_tc_ini_dep','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarActivoFijoValores(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_valores_ime';
		$this->transaccion='SKA_ACTVAL_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarActivoFijoValoresArb(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_valores_sel';
		$this->transaccion='SKA_ACTVAL_ARB';
		$this->setCount(false);
		$this->tipo_procedimiento='SEL';//tipo de transaccion

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
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo','varchar');
		$this->captura('fecha_fin','date');
		$this->captura('tipo_nodo','varchar');
		$this->captura('monto_vigente_real','numeric');
		$this->captura('monto_vigente_orig_100','numeric');
		$this->captura('valor_neto','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarAfvUltDep(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_valores_sel';
		$this->transaccion='SKA_AFULTDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','integer');
		$this->captura('id_activo_fijo_valor','integer');
		$this->captura('codigo','varchar');
		$this->captura('fecha_max','date');
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

	//Inicio #2: Actualización listado detalle depreciación interfaz
	function listarAfvUltVal(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_valores_sel';
		$this->transaccion='SKA_AFULTVAL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','integer');
		$this->captura('codigo','varchar');
		$this->captura('fecha_max','date');
		$this->captura('id_moneda','integer');
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

}
?>