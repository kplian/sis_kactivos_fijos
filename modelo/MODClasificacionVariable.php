<?php
/**
*@package pXP
*@file gen-MODClasificacionVariable.php
*@author  (admin)
*@date 27-06-2017 09:34:29
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #18    KAF       ETR           15/07/2019  RCM         Inclusión de expresión regular como máscara para validación
***************************************************************************
*/

class MODClasificacionVariable extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarClasificacionVariable(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_clasificacion_variable_sel';
		$this->transaccion='SKA_CLAVAR_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_clasificacion_variable','int4');
		$this->captura('id_clasificacion','int4');
		$this->captura('nombre','varchar');
		$this->captura('tipo_dato','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('obligatorio','varchar');
		$this->captura('orden_var','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('regex','varchar'); //#18 se agrega columna
		$this->captura('regex_ejemplo','varchar'); //#18 se agrega columna

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarClasificacionVariable(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_variable_ime';
		$this->transaccion='SKA_CLAVAR_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('tipo_dato','tipo_dato','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('obligatorio','obligatorio','varchar');
		$this->setParametro('orden_var','orden_var','int4');
		$this->setParametro('regex','regex','varchar'); //#18 se agrega columna
		$this->setParametro('regex_ejemplo','regex_ejemplo','varchar'); //#18 se agrega columna

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarClasificacionVariable(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_variable_ime';
		$this->transaccion='SKA_CLAVAR_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion_variable','id_clasificacion_variable','int4');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('tipo_dato','tipo_dato','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('obligatorio','obligatorio','varchar');
		$this->setParametro('orden_var','orden_var','int4');
		$this->setParametro('regex','regex','varchar'); //#18 se agrega columna
		$this->setParametro('regex_ejemplo','regex_ejemplo','varchar'); //#18 se agrega columna

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarClasificacionVariable(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_variable_ime';
		$this->transaccion='SKA_CLAVAR_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion_variable','id_clasificacion_variable','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

}
?>