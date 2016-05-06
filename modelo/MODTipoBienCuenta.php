<?php
/**
*@package pXP
*@file gen-MODTipoBienCuenta.php
*@author  (admin)
*@date 16-04-2016 10:01:08
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODTipoBienCuenta extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarTipoBienCuenta(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_tipo_bien_cuenta_sel';
		$this->transaccion='SKA_BIECUE_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_tipo_bien_cuenta','int4');
		$this->captura('id_tipo_cuenta','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_tipo_bien','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo_bien','varchar');
		$this->captura('desc_bien','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarTipoBienCuenta(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_bien_cuenta_ime';
		$this->transaccion='SKA_BIECUE_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_cuenta','id_tipo_cuenta','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_tipo_bien','id_tipo_bien','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarTipoBienCuenta(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_bien_cuenta_ime';
		$this->transaccion='SKA_BIECUE_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_bien_cuenta','id_tipo_bien_cuenta','int4');
		$this->setParametro('id_tipo_cuenta','id_tipo_cuenta','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_tipo_bien','id_tipo_bien','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarTipoBienCuenta(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_bien_cuenta_ime';
		$this->transaccion='SKA_BIECUE_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_bien_cuenta','id_tipo_bien_cuenta','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>