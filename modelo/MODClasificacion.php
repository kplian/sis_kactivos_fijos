<?php
/**
*@package pXP
*@file gen-MODClasificacion.php
*@author  (admin)
*@date 09-11-2015 01:22:17
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODClasificacion extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarClasificacion(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_clasificacion_sel';
		$this->transaccion='SKA_CLAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_clasificacion','int4');
		$this->captura('codigo','varchar');
		$this->captura('nombre','varchar');
		$this->captura('final','varchar');
		$this->captura('estado_reg','varchar');
		$this->captura('id_cat_metodo_dep','int4');
		$this->captura('tipo','varchar');
		$this->captura('id_concepto_ingas','int4');
		$this->captura('monto_residual','numeric');
		$this->captura('icono','varchar');
		$this->captura('id_clasificacion_fk','int4');
		$this->captura('vida_util','int4');
		$this->captura('correlativo_act','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo_met_dep','varchar');
		$this->captura('met_dep','varchar');
		$this->captura('desc_ingas','varchar');
		$this->captura('clasificacion','text');
		$this->captura('descripcion','varchar');
		$this->captura('tipo_activo','varchar');
		$this->captura('depreciable','varchar');
		$this->captura('contabilizar','varchar');
		$this->captura('codigo_final','varchar');
		$this->captura('vida_util_anios','numeric');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarClasificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_ime';
		$this->transaccion='SKA_CLAF_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion_fk','id_clasificacion_fk','varchar');
		$this->setParametro('id_cat_metodo_dep','id_cat_metodo_dep','int4');
		$this->setParametro('id_concepto_ingas','id_concepto_ingas','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('correlativo_act','correlativo_act','varchar');
		$this->setParametro('monto_residual','monto_residual','numeric');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('final','final','varchar');
		$this->setParametro('icono','icono','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('tipo_activo','tipo_activo','varchar');
		$this->setParametro('depreciable','depreciable','varchar');		
		$this->setParametro('contabilizar','contabilizar','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarClasificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_ime';
		$this->transaccion='SKA_CLAF_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_clasificacion_fk','id_clasificacion_fk','varchar');
		$this->setParametro('id_cat_metodo_dep','id_cat_metodo_dep','int4');
		$this->setParametro('id_concepto_ingas','id_concepto_ingas','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nombre','nombre','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('correlativo_act','correlativo_act','integer');
		$this->setParametro('monto_residual','monto_residual','numeric');
		$this->setParametro('tipo','tipo','varchar');
		$this->setParametro('final','final','varchar');
		$this->setParametro('icono','icono','varchar');
		$this->setParametro('descripcion','descripcion','varchar');		
		$this->setParametro('tipo_activo','tipo_activo','varchar');
		$this->setParametro('depreciable','depreciable','varchar');
		$this->setParametro('contabilizar','contabilizar','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarClasificacion(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_clasificacion_ime';
		$this->transaccion='SKA_CLAF_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion','id_clasificacion','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarClasificacionArb(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_clasificacion_sel';
		$this->setCount(false);
		$this->transaccion='SKA_CLAFARB_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_clasificacion','int4');
		$this->captura('codigo','varchar');
		$this->captura('nombre','varchar');
		$this->captura('final','varchar'); //borrar
		$this->captura('estado_reg','varchar');
		$this->captura('id_cat_metodo_dep','int4');
		$this->captura('tipo','varchar');
		$this->captura('id_concepto_ingas','int4');
		$this->captura('monto_residual','numeric');
		$this->captura('icono','varchar');
		$this->captura('id_clasificacion_fk','int4');
		$this->captura('vida_util','int4');
		$this->captura('correlativo_act','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_reg','int4');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('codigo_met_dep','varchar');
		$this->captura('met_dep','varchar');
		$this->captura('desc_ingas','varchar');
		$this->captura('tipo_nodo','varchar');
		$this->captura('checked','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('tipo_activo','varchar');
		$this->captura('depreciable','varchar');
		$this->captura('contabilizar','varchar');
		$this->captura('codigo_final','varchar');
		$this->captura('vida_util_anios','numeric');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarClasificacionTree(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_clasificacion_sel';
		$this->transaccion='SKA_CLAFTREE_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
				
		//Definicion de la lista del resultado del query
		$this->captura('id_clasificacion','int4');
		$this->captura('id_clasificacion_fk','int4');
		$this->captura('clasificacion','varchar');
		$this->captura('nivel','integer');
		$this->captura('tipo_activo','varchar');
		$this->captura('depreciable','varchar');
		$this->captura('vida_util','integer');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>