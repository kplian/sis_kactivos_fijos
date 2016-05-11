<?php
/**
*@package pXP
*@file gen-MODMovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODMovimientoAfDep extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_MAFDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_dep','int4');
		$this->captura('vida_util','int4');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('depreciacion_per_actualiz','numeric');
		$this->captura('id_movimiento_af','int4');
		$this->captura('vida_util_ant','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('monto_vigente_ant','numeric');
		$this->captura('depreciacion_acum_actualiz','numeric');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('factor','numeric');
		$this->captura('depreciacion_per','numeric');
		$this->captura('depreciacion','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('depreciacion_per_ant','numeric');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion_acum_ant','numeric');
		$this->captura('id_usuario_reg','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('depreciacion_per_actualiz','depreciacion_per_actualiz','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('vida_util_ant','vida_util_ant','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_vigente_ant','monto_vigente_ant','numeric');
		$this->setParametro('depreciacion_acum_actualiz','depreciacion_acum_actualiz','numeric');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('factor','factor','numeric');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('depreciacion','depreciacion','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_per_ant','depreciacion_per_ant','numeric');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_dep','id_movimiento_af_dep','int4');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('tipo_cambio_ini','tipo_cambio_ini','numeric');
		$this->setParametro('depreciacion_per_actualiz','depreciacion_per_actualiz','numeric');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('vida_util_ant','vida_util_ant','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('monto_vigente_ant','monto_vigente_ant','numeric');
		$this->setParametro('depreciacion_acum_actualiz','depreciacion_acum_actualiz','numeric');
		$this->setParametro('tipo_cambio_fin','tipo_cambio_fin','numeric');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('factor','factor','numeric');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('depreciacion','depreciacion','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_per_ant','depreciacion_per_ant','numeric');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarMovimientoAfDep(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_dep_ime';
		$this->transaccion='SKA_MAFDEP_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento_af_dep','id_movimiento_af_dep','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarMovimientoAfDepRes(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_MAFDEPRES_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento_af_dep','int4');
		$this->captura('id_movimiento_af','int4');
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('fecha','date');
		$this->captura('depreciacion_acum_ant','numeric');
		$this->captura('depreciacion_per_ant','numeric');
		$this->captura('monto_vigente_ant','numeric');
		$this->captura('vida_util_ant','int4');
		$this->captura('depreciacion_acum_actualiz','numeric');
		$this->captura('depreciacion_per_actualiz','numeric');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('depreciacion_per','numeric');
		$this->captura('monto_vigente','numeric');
		$this->captura('vida_util','int4');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('factor','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarMovimientoAfDepResCab(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_af_dep_sel';
		$this->transaccion='SKA_RESCAB_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo_valor','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('estado','varchar');
		$this->captura('principal','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('monto_rescate','numeric');
		$this->captura('tipo_cambio_ini','numeric');
		$this->captura('estado_reg','varchar');
		$this->captura('tipo','varchar');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('fecha_ult_dep','date');
		$this->captura('fecha_ini_dep','date');
		$this->captura('monto_vigente_orig','numeric');
		$this->captura('vida_util','int4');
		$this->captura('vida_util_orig','int4');
		$this->captura('id_movimiento_af','int4');
		$this->captura('tipo_cambio_fin','numeric');
		$this->captura('codigo','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>