<?php
/**
*@package pXP
*@file gen-MODMovimientoAfEspecial.php
*@author  (rchumacero)
*@date 22-05-2019 21:34:37
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/
/***************************************************************************
#ISSUE	SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #2		KAF		ETR 		22-05-2019	RCM		Control para la distribución de valores (Creación)
***************************************************************************/
class MODMovimientoAfEspecial extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_especial_sel';
		$this->transaccion='SKA_MOAFES_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_especial','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('id_movimiento_af','int4');
		$this->captura('fecha_ini_dep','date');
		$this->captura('importe','numeric');
		$this->captura('vida_util','int4');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_activo_fijo_creado','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_centro_costo','int4');
		$this->captura('denominacion','varchar');
		$this->captura('porcentaje','numeric');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo','varchar');
		$this->captura('clasificacion','text');
		$this->captura('codigo_cc','text');
		$this->captura('tipo','varchar');
		$this->captura('denominacion_af','varchar');
		$this->captura('opcion','varchar');
		$this->captura('id_almacen','integer');
		$this->captura('desc_almacen','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOAFES_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_activo_fijo_creado','id_activo_fijo_creado','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('porcentaje','porcentaje','numeric');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('opcion','opcion','varchar');
		$this->setParametro('id_almacen','id_almacen','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOAFES_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_especial','id_movimiento_af_especial','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_activo_fijo_creado','id_activo_fijo_creado','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('porcentaje','porcentaje','numeric');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('opcion','opcion','varchar');
		$this->setParametro('id_almacen','id_almacen','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarMovimientoAfEspecial(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOAFES_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_especial','id_movimiento_af_especial','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

}
?>