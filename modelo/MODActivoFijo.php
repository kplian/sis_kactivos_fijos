<?php
/**
*@package pXP
*@file gen-MODActivoFijo.php
*@author  (admin)
*@date 29-10-2015 03:18:45
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijo extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarActivoFijo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_AFIJ_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_persona','int4');
		$this->captura('cantidad_revaloriz','int4');
		$this->captura('foto','varchar');
		$this->captura('id_proveedor','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('monto_vigente','numeric');
		$this->captura('id_cat_estado_fun','int4');
		$this->captura('ubicacion','varchar');
		$this->captura('vida_util','int4');
		$this->captura('documento','varchar');
		$this->captura('observaciones','varchar');
		$this->captura('fecha_ult_dep','date');
		$this->captura('monto_rescate','numeric');
		$this->captura('denominacion','varchar');
		$this->captura('id_funcionario','int4');
		$this->captura('id_deposito','int4');
		$this->captura('monto_compra','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('codigo','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('id_moneda_orig','int4');
		$this->captura('fecha_ini_dep','date');
		$this->captura('id_cat_estado_compra','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('vida_util_original','int4');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('estado','varchar');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('id_oficina','int4');
		$this->captura('id_depto','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('persona','text');
		$this->captura('desc_proveedor','varchar');
		$this->captura('estado_fun','varchar');
		$this->captura('estado_compra','varchar');
		$this->captura('clasificacion','text');
		$this->captura('centro_costo','text');
		$this->captura('oficina','text');
		$this->captura('depto','text');
		$this->captura('funcionario','text');
		$this->captura('deposito','varchar');
		$this->captura('deposito_cod','varchar');
		$this->captura('desc_moneda_orig','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('cantidad_revaloriz','cantidad_revaloriz','int4');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('id_cat_estado_compra','id_cat_estado_compra','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('vida_util_original','vida_util_original','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_depto','id_depto','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('cantidad_revaloriz','cantidad_revaloriz','int4');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('id_cat_estado_compra','id_cat_estado_compra','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('vida_util_original','vida_util_original','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_depto','id_depto','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function codificarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFCOD_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function seleccionarActivosFijos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_IDAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
				
		//Definicion de la lista del resultado del query
		$this->captura('ids','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>