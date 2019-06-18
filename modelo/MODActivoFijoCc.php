<?php
/**
*@package pXP
*@file gen-MODActivoFijoCc.php
*@author  (admin)
*@date 11-05-2019 11:14:58
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/
/***************************************************************************
#ISSUE	SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #16	KAF		ETR 		18/06/2019	RCM		Inclusión procedimiento para completar prorrateo con CC por defecto por AF
***************************************************************************/
class MODActivoFijoCc extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarActivoFijoCc(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_cc_sel';
		$this->transaccion='SKA_AFCCOSTO_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_cc','int4');

		/*
		 * ,
                        .,

                        afccosto.id_usuario_reg,
                        afccosto.estado_reg,
                        afccosto.fecha_reg,
                        afccosto.id_usuario_mod,
                        afccosto.fecha_mod,
                        afccosto.id_usuario_ai,
                        afccosto.usuario_ai,
                        usu1.cuenta as usr_reg,
						usu2.cuenta as usr_mod
		 */
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('mes','date');
		$this->captura('cantidad_horas','numeric');
		$this->captura('id_usuario_reg','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('desc_tipo_cc','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarActivoFijoCc(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_cc_ime';
		$this->transaccion='SKA_AFCCOSTO_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion

		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('mes','mes','date');
		$this->setParametro('cantidad_horas','cantidad_horas','numeric');
		//$this->setParametro('estado_reg','estado_reg','varchar');


		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarActivoFijoCc(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_cc_ime';
		$this->transaccion='SKA_AFCCOSTO_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_cc','id_activo_fijo_cc','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('mes','mes','date');
		$this->setParametro('cantidad_horas','cantidad_horas','numeric');



		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarActivoFijoCc(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_cc_ime';
		$this->transaccion='SKA_AFCCOSTO_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo_cc','id_activo_fijo_cc','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}


	function ImportarCentroCosto(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_cc_ime';
		$this->transaccion='SKA_AFCCOSTO_IMP';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('activo_fijo','activo_fijo','varchar');
		$this->setParametro('mes','mes','date');
		$this->setParametro('centro_costo','centro_costo','varchar');
		$this->setParametro('cantidad_horas','cantidad_horas','numeric');
		$this->setParametro('nombre_archivo','nombre_archivo','varchar');
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarLogActivoFijoCc(){
		//Definicion de variables para ejecucion del procedimientp

		$this->procedimiento='kaf.ft_activo_fijo_cc_sel';
		$this->transaccion='SKA_LOGAFCC_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query

		$this->captura('activo_fijo','varchar');
		$this->captura('centro_costo','varchar');
		$this->captura('mes','date');
		$this->captura('cantidad_horas','numeric');
		$this->captura('detalle','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Inicio #16
	function completarProrrateoCC(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_cc_ime';
		$this->transaccion='SKA_AFCCPROC_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('fecha','fecha','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #16

}
?>