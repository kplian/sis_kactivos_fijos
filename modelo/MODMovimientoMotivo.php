<?php
/**
*@package pXP
*@file gen-MODMovimientoMotivo.php
*@author  (admin)
*@date 18-03-2016 07:25:59
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODMovimientoMotivo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarMovimientoMotivo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_motivo_sel';
		$this->transaccion='SKA_MMOT_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_motivo','int4');
		$this->captura('id_cat_movimiento','int4');
		$this->captura('motivo','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('movimiento','varchar');
		$this->captura('plantilla_cbte','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarMovimientoMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_motivo_ime';
		$this->transaccion='SKA_MMOT_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_cat_movimiento','id_cat_movimiento','int4');
		$this->setParametro('motivo','motivo','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('plantilla_cbte','plantilla_cbte','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarMovimientoMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_motivo_ime';
		$this->transaccion='SKA_MMOT_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');
		$this->setParametro('id_cat_movimiento','id_cat_movimiento','int4');
		$this->setParametro('motivo','motivo','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('plantilla_cbte','plantilla_cbte','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarMovimientoMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_motivo_ime';
		$this->transaccion='SKA_MMOT_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>