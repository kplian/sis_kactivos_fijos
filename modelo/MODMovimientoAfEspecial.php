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
 #38    KAF     ETR         11-12-2019  RCM     Reingeniería importación de plantilla para movimientos especiales
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
		//Inicio #39
		$this->captura('nro_serie','varchar');
		$this->captura('marca','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('cantidad_det','numeric');
		$this->captura('id_unidad_medida','integer');
		$this->captura('ubicacion','varchar');
		$this->captura('id_ubicacion','integer');
		$this->captura('id_funcionario','integer');
		$this->captura('fecha_compra','date');
		$this->captura('id_moneda','integer');
		$this->captura('id_grupo','integer');
		$this->captura('id_grupo_clasif','integer');
		$this->captura('observaciones','varchar');

		$this->captura('desc_unmed','varchar');
		$this->captura('desc_ubicacion','varchar');
		$this->captura('responsable','text');
		$this->captura('moneda','varchar');
		$this->captura('desc_grupo_ae','text');
		$this->captura('desc_clasif_ae','text');

		//Fin #39

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

		//Inicio #39
		$this->setParametro('nro_serie', 'nro_serie','varchar');
		$this->setParametro('marca', 'marca','varchar');
		$this->setParametro('descripcion', 'descripcion','varchar');
		$this->setParametro('cantidad_det', 'cantidad_det','numeric');
		$this->setParametro('id_unidad_medida', 'id_unidad_medida','integer');
		$this->setParametro('ubicacion', 'ubicacion','varchar');
		$this->setParametro('id_ubicacion', 'id_ubicacion','integer');
		$this->setParametro('id_funcionario', 'id_funcionario','integer');
		$this->setParametro('fecha_compra', 'fecha_compra','date');
		$this->setParametro('id_moneda', 'id_moneda','integer');
		$this->setParametro('id_grupo', 'id_grupo','integer');
		$this->setParametro('id_grupo_clasif', 'id_grupo_clasif','integer');
		$this->setParametro('observaciones', 'observaciones','varchar');
		//Fin #39

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

		//Inicio #39
		$this->setParametro('nro_serie', 'nro_serie','varchar');
		$this->setParametro('marca', 'marca','varchar');
		$this->setParametro('descripcion', 'descripcion','varchar');
		$this->setParametro('cantidad_det', 'cantidad_det','numeric');
		$this->setParametro('id_unidad_medida', 'id_unidad_medida','integer');
		$this->setParametro('ubicacion', 'ubicacion','varchar');
		$this->setParametro('id_ubicacion', 'id_ubicacion','integer');
		$this->setParametro('id_funcionario', 'id_funcionario','integer');
		$this->setParametro('fecha_compra', 'fecha_compra','date');
		$this->setParametro('id_moneda', 'id_moneda','integer');
		$this->setParametro('id_grupo', 'id_grupo','integer');
		$this->setParametro('id_grupo_clasif', 'id_grupo_clasif','integer');
		$this->setParametro('observaciones', 'observaciones','varchar');
		//Fin #39

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

	function insertarMovimientoAfEspecialImportar(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_af_especial_ime';
		$this->transaccion='SKA_MOAFESMAS_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_activo_fijo_valor','id_activo_fijo_valor','int4');
		$this->setParametro('id_movimiento_af','id_movimiento_af','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('importe','importe','numeric');
		$this->setParametro('id_activo_fijo_creado','id_activo_fijo_creado','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('porcentaje','porcentaje','numeric');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('opcion','opcion','varchar');
		$this->setParametro('codigo_af','codigo_af','varchar');
		$this->setParametro('vida_util_anios','vida_util_anios','int4');
		$this->setParametro('clasificacion','clasificacion','varchar');
		$this->setParametro('centro_costo','centro_costo','varchar');
		$this->setParametro('almacen','almacen','varchar');
		$this->setParametro('item','item','integer');
		$this->setParametro('codigo_af_rel','codigo_af_rel','varchar'); //#38
		//Inicio #39
		$this->setParametro('nro_serie', 'nro_serie','varchar');
		$this->setParametro('marca', 'marca','varchar');
		$this->setParametro('descripcion', 'descripcion','varchar');
		$this->setParametro('cantidad_det', 'cantidad_det','numeric');
		$this->setParametro('unidad', 'unidad','varchar');
		$this->setParametro('ubicacion', 'ubicacion','varchar');
		$this->setParametro('local', 'local','varchar');
		$this->setParametro('responsable', 'responsable','varchar');
		$this->setParametro('fecha_compra', 'fecha_compra','date');
		$this->setParametro('moneda', 'moneda','varchar');
		$this->setParametro('grupo_ae', 'grupo_ae','varchar');
		$this->setParametro('clasificacion_ae', 'clasificacion_ae','varchar');
		//Fin #39

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

}
?>