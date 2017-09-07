<?php
/**
*@package pXP
*@file gen-MODActivoFijoModificacion.php
*@author  (admin)
*@date 23-08-2017 14:14:25
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijoModificacion extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarActivoFijoModificacion(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_modificacion_sel';
		$this->transaccion='SKA_KAFMOD_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_modificacion','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_oficina','int4');
		$this->captura('id_oficina_ant','int4');
		$this->captura('ubicacion','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('ubicacion_ant','varchar');
		$this->captura('observaciones','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('desc_oficina','text');
		$this->captura('desc_oficina_ant','text');
		$this->captura('tipo','int4');
		$this->captura('desc_tipo','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarActivoFijoModificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_modificacion_ime';
		$this->transaccion='SKA_KAFMOD_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_oficina_ant','id_oficina_ant','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('ubicacion_ant','ubicacion_ant','varchar');
		$this->setParametro('observaciones','observaciones','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarActivoFijoModificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_modificacion_ime';
		$this->transaccion='SKA_KAFMOD_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_modificacion','id_activo_fijo_modificacion','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_oficina_ant','id_oficina_ant','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('ubicacion_ant','ubicacion_ant','varchar');
		$this->setParametro('observaciones','observaciones','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarActivoFijoModificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_modificacion_ime';
		$this->transaccion='SKA_KAFMOD_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_modificacion','id_activo_fijo_modificacion','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>