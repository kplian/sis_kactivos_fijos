<?php
/**
*@package pXP
*@file gen-MODActivoFijo.php
*@author  (admin)
*@date 04-09-2015 03:11:50
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarActivoFijo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_ACTIVO_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('monto_compra_mon_orig','numeric');
		$this->captura('id_persona','int4');
		$this->captura('monto_compra','numeric');
		$this->captura('fecha_ini_dep','date');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('documento','varchar');
		$this->captura('monto_vigente','numeric');
		$this->captura('observaciones','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('id_depto','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('vida_util_restante','int4');
		$this->captura('id_funcionario','int4');
		$this->captura('denominacion','varchar');
		$this->captura('id_cat_estado_fun','int4');
		$this->captura('id_moneda','int4');
		$this->captura('id_moneda_orig','int4');
		$this->captura('depreciacion_acum_ant','numeric');
		$this->captura('codigo','varchar');
		$this->captura('foto','varchar');
		$this->captura('monto_actualiz','numeric');
		$this->captura('estado','varchar');
		$this->captura('vida_util','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
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
			
	function insertarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_ACTIVO_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('monto_compra_mon_orig','monto_compra_mon_orig','numeric');
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('vida_util_restante','vida_util_restante','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('vida_util','vida_util','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_ACTIVO_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('monto_compra_mon_orig','monto_compra_mon_orig','numeric');
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('vida_util_restante','vida_util_restante','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('depreciacion_acum_ant','depreciacion_acum_ant','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('monto_actualiz','monto_actualiz','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('vida_util','vida_util','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_ACTIVO_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>