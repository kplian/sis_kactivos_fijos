<?php
/**
*@package pXP
*@file gen-MODMovimientoAf.php
*@author  (admin)
*@date 18-03-2016 05:34:15
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           21/01/2019  RCM         Opción para traspasar valores de un activo fijo a otro
***************************************************************************
*/
class MODMovimientoAf extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarMovimientoAf(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_sel';
		$this->transaccion='SKA_MOVAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af','int4');
		$this->captura('id_movimiento','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_cat_estado_fun','int4');
		$this->captura('id_movimiento_motivo','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('importe','numeric');
		$this->captura('respuesta','text');
		$this->captura('vida_util','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('cod_af','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('estado_fun','varchar');
		$this->captura('motivo','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('monto_vigente_real_af','numeric');
        $this->captura('vida_util_real_af','int4');
        $this->captura('fecha_ult_dep_real_af','date');
        $this->captura('depreciacion_acum_real_af','numeric');
        $this->captura('depreciacion_per_real_af','numeric');
        $this->captura('desc_moneda_orig','varchar');
        $this->captura('monto_compra','numeric');
        $this->captura('vida_util_af','int4');
        $this->captura('fecha_ini_dep','date');
        $this->captura('depreciacion_acum','numeric');
        $this->captura('importe_ant','numeric');
        $this->captura('vida_util_ant','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarMovimientoAf(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_ime';
		$this->transaccion='SKA_MOVAF_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('respuesta','respuesta','text');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('importe_ant','importe_ant','numeric');
		$this->setParametro('vida_util_ant','vida_util_ant','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarMovimientoAf(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_ime';
		$this->transaccion='SKA_MOVAF_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('respuesta','respuesta','text');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('importe_ant','importe_ant','numeric');
		$this->setParametro('vida_util_ant','vida_util_ant','integer');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarMovimientoAf(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_ime';
		$this->transaccion='SKA_MOVAF_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Inicio #2
	function obtenerSaldoDistribucion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'kaf.ft_movimiento_af_ime';
		$this->transaccion = 'SKA_MOVAFSAL_LIS';
		$this->tipo_procedimiento = 'IME';

		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('id_movimiento_af_especial','id_movimiento_af_especial','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function obtenerMonedaMovEsp(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento = 'kaf.ft_movimiento_af_ime';
		$this->transaccion = 'SKA_MONESP_LIS';
		$this->tipo_procedimiento = 'IME';

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}


	//Fin #2

}
?>