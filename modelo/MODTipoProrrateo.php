<?php
/**
*@package pXP
*@file gen-MODTipoProrrateo.php
*@author  (admin)
*@date 02-05-2017 08:30:44
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODTipoProrrateo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarTipoProrrateo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_tipo_prorrateo_sel';
		$this->transaccion='SKA_TIPR_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_tipo_prorrateo','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_ot','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_tipo_cc','int4');
		$this->captura('id_proyecto','int4');
		$this->captura('factor','numeric');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		
		$this->captura('desc_tipo_cc','varchar');
		$this->captura('desc_ot','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarTipoProrrateo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_prorrateo_ime';
		$this->transaccion='SKA_TIPR_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_ot','id_ot','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_tipo_cc','id_tipo_cc','int4');
		$this->setParametro('id_proyecto','id_proyecto','int4');
		$this->setParametro('factor','factor','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarTipoProrrateo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_prorrateo_ime';
		$this->transaccion='SKA_TIPR_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_prorrateo','id_tipo_prorrateo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_ot','id_ot','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_tipo_cc','id_tipo_cc','int4');
		$this->setParametro('id_proyecto','id_proyecto','int4');
		$this->setParametro('factor','factor','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarTipoProrrateo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_tipo_prorrateo_ime';
		$this->transaccion='SKA_TIPR_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_tipo_prorrateo','id_tipo_prorrateo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>