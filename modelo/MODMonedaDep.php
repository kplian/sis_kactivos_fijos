<?php
/**
*@package pXP
*@file gen-MODMonedaDep.php
*@author  (admin)
*@date 20-04-2017 10:18:50
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           20/04/2017  RCM         Creación del archivo
 #35    KAF       ETR           27/12/2019  RCM         Creación método para encontrar id_moneda_dep a partir de una moneda
***************************************************************************
*/

class MODMonedaDep extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarMonedaDep(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_moneda_dep_sel';
		$this->transaccion='SKA_MOD_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_moneda_dep','int4');
		$this->captura('id_moneda_act','int4');
		$this->captura('actualizar','varchar');
		$this->captura('contabilizar','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('id_moneda','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');

		$this->captura('desc_moneda','varchar');
		$this->captura('desc_moneda_act','varchar');
		$this->captura('descripcion','varchar');



		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarMonedaDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_moneda_dep_ime';
		$this->transaccion='SKA_MOD_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_moneda_act','id_moneda_act','int4');
		$this->setParametro('actualizar','actualizar','varchar');
		$this->setParametro('contabilizar','contabilizar','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('descripcion','descripcion','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarMonedaDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_moneda_dep_ime';
		$this->transaccion='SKA_MOD_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_moneda_dep','id_moneda_dep','int4');
		$this->setParametro('id_moneda_act','id_moneda_act','int4');
		$this->setParametro('actualizar','actualizar','varchar');
		$this->setParametro('contabilizar','contabilizar','varchar');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('descripcion','descripcion','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarMonedaDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_moneda_dep_ime';
		$this->transaccion='SKA_MOD_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_moneda_dep','id_moneda_dep','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Inicio #35
	function obtenerMonedaDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'kaf.ft_moneda_dep_ime';
		$this->transaccion = 'SKA_MODMON_GET';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_moneda_', 'id_moneda', 'int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #35

}
?>