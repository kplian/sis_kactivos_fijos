<?php
/**
*@package pXP
*@file gen-MODActivoFijoValores.php
*@author  (admin)
*@date 04-05-2016 03:02:26
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijoValores extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
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
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>