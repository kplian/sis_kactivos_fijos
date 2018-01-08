<?php
/**
*@package pXP
*@file MODReportes.php
*@author  RCM
*@date 27/07/2017
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODReportes extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function reporteKardex(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_KARD_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','integer');
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_desde','fecha_desde','date');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_estado_mov','af_estado_mov','varchar');
				
		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
		$this->captura('denominacion','VARCHAR');
		$this->captura('fecha_compra','DATE');
		$this->captura('fecha_ini_dep','DATE');
		$this->captura('estado','VARCHAR');
		$this->captura('vida_util_original','INTEGER');
		$this->captura('porcentaje_dep','INTEGER');
		$this->captura('ubicacion','VARCHAR');
		$this->captura('monto_compra_orig','NUMERIC');
		$this->captura('moneda','VARCHAR');
		$this->captura('nro_cbte_asociado','VARCHAR');
		$this->captura('fecha_cbte_asociado','DATE');
		$this->captura('cod_clasif','VARCHAR');
		$this->captura('desc_clasif','VARCHAR');
		$this->captura('metodo_dep','VARCHAR');
		$this->captura('ufv_fecha_compra','NUMERIC');
		$this->captura('responsable','TEXT');
		$this->captura('cargo','VARCHAR');
		$this->captura('fecha_mov','DATE');
		$this->captura('num_tramite','VARCHAR');
		$this->captura('desc_mov','VARCHAR');
		$this->captura('codigo_mov','VARCHAR');
		$this->captura('ufv_mov','NUMERIC');
		$this->captura('id_activo_fijo','INTEGER');
		$this->captura('id_movimiento','INTEGER');
		$this->captura('monto_vigente_orig_100','NUMERIC');
		$this->captura('monto_vigente_orig','NUMERIC');
		$this->captura('monto_vigente_ant','NUMERIC');
		$this->captura('actualiz_monto_vigente','NUMERIC');
		$this->captura('monto_actualiz','NUMERIC');
		$this->captura('vida_util_usada','INTEGER');
		$this->captura('vida_util','INTEGER');
		$this->captura('dep_acum_gest_ant','NUMERIC');
		$this->captura('act_dep_gest_ant','NUMERIC');
		$this->captura('depreciacion_per','NUMERIC');
		$this->captura('depreciacion_acum','NUMERIC');
		$this->captura('monto_vigente','NUMERIC');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function reporteGralAF(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_GRALAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('reporte','reporte','varchar');
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_desde','fecha_desde','date');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_estado_mov','af_estado_mov','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
		$this->captura('denominacion','VARCHAR');
		$this->captura('descripcion','VARCHAR');
		$this->captura('fecha_ini_dep','DATE');
		//$this->captura('monto_compra_orig_100','numeric');
		//$this->captura('monto_compra_orig','numeric');
		$this->captura('ubicacion','varchar');
		$this->captura('responsable','text');
		$this->captura('monto_vigente_orig_100','NUMERIC');
		$this->captura('monto_vigente_orig','NUMERIC');
		$this->captura('monto_vigente_ant','NUMERIC');
		$this->captura('actualiz_monto_vigente','NUMERIC');
		$this->captura('monto_actualiz','NUMERIC');
		$this->captura('vida_util_usada','INTEGER');
		$this->captura('vida_util','INTEGER');
		$this->captura('dep_acum_gest_ant','NUMERIC');
		$this->captura('act_dep_gest_ant','NUMERIC');
		$this->captura('depreciacion_per','NUMERIC');
		$this->captura('depreciacion_acum','NUMERIC');
		$this->captura('monto_vigente','NUMERIC');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarDepreciacionDeptoFechas(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_DEPDEPTO_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('deptos','deptos','varchar');
				
		//Definicion de la lista del resultado del query
		$this->captura('id_depto','INTEGER');
		$this->captura('desc_depto','text');
		$this->captura('fecha_max_dep','date');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepAsignados(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RASIG_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		//se adiciona estos parametros para obtener el lugar del reporte
		$this->setParametro('id_lugar','id_lugar','int4');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('tipo','tipo','varchar');

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
		$this->captura('lugar','VARCHAR');
        $this->captura('desc_clasificacion','VARCHAR');
        $this->captura('denominacion','VARCHAR');
        $this->captura('descripcion','VARCHAR');
        $this->captura('estado','VARCHAR');
        $this->captura('observaciones','VARCHAR');
        $this->captura('ubicacion','VARCHAR');
        $this->captura('fecha_asignacion','date');
        $this->captura('desc_oficina','VARCHAR');
        $this->captura('responsable','text');
        $this->captura('cargo','varchar');
        $this->captura('desc_depto','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepEnDeposito(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RENDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		/*$this->setParametro('reporte','reporte','varchar');
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_desde','fecha_desde','date');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_estado_mov','af_estado_mov','varchar');*/

		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
        $this->captura('desc_clasificacion','VARCHAR');
        $this->captura('denominacion','VARCHAR');
        $this->captura('descripcion','VARCHAR');
        $this->captura('estado','VARCHAR');
        $this->captura('observaciones','VARCHAR');
        $this->captura('ubicacion','VARCHAR');
        $this->captura('fecha_asignacion','date');
        $this->captura('desc_oficina','VARCHAR');
        $this->captura('responsable','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepSinAsignar(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RSINASIG_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('reporte','reporte','varchar');
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_desde','fecha_desde','date');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_estado_mov','af_estado_mov','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
        $this->captura('desc_clasificacion','VARCHAR');
        $this->captura('denominacion','VARCHAR');
        $this->captura('descripcion','VARCHAR');
        $this->captura('estado','VARCHAR');
        $this->captura('observaciones','VARCHAR');
        $this->captura('ubicacion','VARCHAR');
        $this->captura('fecha_asignacion','date');
        $this->captura('desc_oficina','VARCHAR');
        $this->captura('responsable','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepDetalleDep(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RDETDEP_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		
		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('reporte','reporte','varchar');
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_desde','fecha_desde','date');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_estado_mov','af_estado_mov','varchar');
        $this->setParametro('id_movimiento','id_movimiento','int4');

		//Definicion de la lista del resultado del query
		$this->captura('id_moneda_dep','INTEGER');
		$this->captura('desc_moneda','VARCHAR');		
		$this->captura('gestion_final','INTEGER');
        $this->captura('tipo','varchar');
        $this->captura('nombre_raiz','varchar');
        $this->captura('fecha_ini_dep','DATE');
        $this->captura('id_movimiento','INTEGER');
        $this->captura('id_movimiento_af','INTEGER');
        $this->captura('id_activo_fijo_valor','INTEGER');
        $this->captura('id_activo_fijo','INTEGER');
        $this->captura('codigo','varchar');
        $this->captura('id_clasificacion','INTEGER');
        $this->captura('descripcion','varchar');
        $this->captura('monto_vigente_orig','NUMERIC');
        $this->captura('monto_vigente_inicial','NUMERIC');
        $this->captura('monto_vigente_final','NUMERIC');
        $this->captura('monto_actualiz_inicial','NUMERIC');
        $this->captura('monto_actualiz_final','NUMERIC');
        $this->captura('depreciacion_acum_inicial','NUMERIC');
        $this->captura('depreciacion_acum_final','NUMERIC'); 
        $this->captura('aitb_activo','NUMERIC');
        $this->captura('aitb_depreciacion_acumulada','NUMERIC');
        $this->captura('vida_util_orig','INTEGER');
        $this->captura('vida_util_inicial','INTEGER');
        $this->captura('vida_util_final','INTEGER');
        $this->captura('vida_util_trans','INTEGER');  
        $this->captura('codigo_raiz','varchar');
        $this->captura('id_clasificacion_raiz','INTEGER');
		$this->captura('depreciacion_per_final','NUMERIC'); 
        $this->captura('depreciacion_per_actualiz_final','NUMERIC'); 

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepDepreciacion(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RDEPREC_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		
		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_deprec','af_deprec','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('codigo','varchar(50)');
        $this->captura('denominacion','varchar(500)');
        $this->captura('fecha_ini_dep','date');
        $this->captura('monto_vigente_orig_100','numeric(18,2)');
        $this->captura('monto_vigente_orig','numeric(18,2)');
        $this->captura('inc_actualiz','numeric(18,2)');
        $this->captura('monto_actualiz','numeric(18,2)');
        $this->captura('vida_util_orig','integer');
        $this->captura('vida_util','integer');
        $this->captura('depreciacion_acum_gest_ant','numeric(18,2)');
        $this->captura('depreciacion_acum_actualiz_gest_ant','numeric(18,2)');
        $this->captura('depreciacion_per','numeric(18,2)');
        $this->captura('depreciacion_acum','numeric(18,2)');
        $this->captura('monto_vigente','numeric(18,2)');
        $this->captura('nivel','integer');
        $this->captura('orden','bigint');
        $this->captura('tipo','varchar(10)');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//echo $this->consulta;exit;
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>