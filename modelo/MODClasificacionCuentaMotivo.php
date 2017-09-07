<?php
/**
*@package pXP
*@file gen-MODClasificacionCuentaMotivo.php
*@author  (admin)
*@date 15-08-2017 17:28:50
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODClasificacionCuentaMotivo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarClasificacionCuentaMotivo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_clasificacion_cuenta_motivo_sel';
		$this->transaccion='SKA_CLACUE_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_clasificacion_cuenta_motivo','int4');
		$this->captura('id_movimiento_motivo','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('desc_clasificacion','text');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarClasificacionCuentaMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_cuenta_motivo_ime';
		$this->transaccion='SKA_CLACUE_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarClasificacionCuentaMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_cuenta_motivo_ime';
		$this->transaccion='SKA_CLACUE_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion_cuenta_motivo','id_clasificacion_cuenta_motivo','int4');
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarClasificacionCuentaMotivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_cuenta_motivo_ime';
		$this->transaccion='SKA_CLACUE_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion_cuenta_motivo','id_clasificacion_cuenta_motivo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>