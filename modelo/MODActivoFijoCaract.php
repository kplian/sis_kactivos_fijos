<?php
/**
*@package pXP
*@file gen-MODActivoFijoCaract.php
*@author  (admin)
*@date 17-04-2016 07:14:58
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijoCaract extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarActivoFijoCaract(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_caract_sel';
		$this->transaccion='SKA_AFCARACT_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_caract','int4');
		$this->captura('clave','varchar');
		$this->captura('valor','varchar');
		$this->captura('id_activo_fijo','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('id_clasificacion_variable','int4');
		$this->captura('nombre_variable','varchar');
		$this->captura('tipo_dato','varchar');
		$this->captura('obligatorio','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarActivoFijoCaract(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_caract_ime';
		$this->transaccion='SKA_AFCARACT_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('clave','clave','varchar');
		$this->setParametro('valor','valor','varchar');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_clasificacion_variable','id_clasificacion_variable','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarActivoFijoCaract(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_caract_ime';
		$this->transaccion='SKA_AFCARACT_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_caract','id_activo_fijo_caract','int4');
		$this->setParametro('clave','clave','varchar');
		$this->setParametro('valor','valor','varchar');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_clasificacion_variable','id_clasificacion_variable','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarActivoFijoCaract(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_caract_ime';
		$this->transaccion='SKA_AFCARACT_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_caract','id_activo_fijo_caract','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarCaractFiltro(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_caract_sel';
		$this->transaccion='SKA_CARALL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del quotemeta(str)																																									uery
		$this->captura('clave','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>