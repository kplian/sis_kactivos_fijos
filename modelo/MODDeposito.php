<?php
/**
*@package pXP
*@file gen-MODDeposito.php
*@author  (admin)
*@date 09-11-2015 03:27:12
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODDeposito extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarDeposito(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_deposito_sel';
		$this->transaccion='SKA_DEPAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_deposito','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('codigo','varchar');
		$this->captura('nombre','varchar');
		$this->captura('id_depto','int4');
		$this->captura('id_funcionario','int4');
		$this->captura('id_oficina','int4');
		$this->captura('ubicacion','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('depto_cod','varchar');
		$this->captura('depto','varchar');
		$this->captura('funcionario','text');
		$this->captura('oficina_cod','varchar');
		$this->captura('oficina','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarDeposito(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_deposito_ime';
		$this->transaccion='SKA_DEPAF_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_usuario_ai','id_usuario_ai','int4');
		$this->setParametro('nombre_usuario_ai','nombre_usuario_ai','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarDeposito(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_deposito_ime';
		$this->transaccion='SKA_DEPAF_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_usuario_ai','id_usuario_ai','int4');
		$this->setParametro('nombre_usuario_ai','nombre_usuario_ai','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarDeposito(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_deposito_ime';
		$this->transaccion='SKA_DEPAF_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_deposito','id_deposito','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>