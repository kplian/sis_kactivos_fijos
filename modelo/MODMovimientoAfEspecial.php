<?php
/**
*@package pXP
*@file gen-MODMovimientoAfEspecial.php
*@author  (admin)
*@date 23-06-2017 08:21:47
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODMovimientoAfEspecial extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_especial_sel';
		$this->transaccion='SKA_MOVESP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_especial','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('importe','numeric');
		$this->captura('id_movimiento_af','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo_afv','varchar');
		$this->captura('tipo_afv','varchar');
		$this->captura('monto_vigente_real_afv','numeric');
		$this->captura('codigo','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('monto_vigente_real','numeric');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOVESP_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('cod_movimiento','cod_movimiento','varchar');
		$this->setParametro('id_activo_fijo_det','id_activo_fijo_det','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOVESP_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_especial','id_movimiento_af_especial','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('cod_movimiento','cod_movimiento','varchar');
		$this->setParametro('id_activo_fijo_det','id_activo_fijo_det','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOVESP_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_especial','id_movimiento_af_especial','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarMovimientoAfEspecialPorActivo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOVESPAF_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>