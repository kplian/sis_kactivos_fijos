<?php
/**
*@package pXP
*@file MODReportes.php
*@author  RCM
*@date 27/07/2017
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/
/***************************************************************************
 ISSUE  	SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #9     	KAF       ETR           10/05/2019  RCM         Inclusión de nuevas columnas en método de reporte detalle depreciación
 #20    	KAF       ETR           03/08/2019  RCM         Reporte Activos Fijos con Distribución de Valores
 #25 		KAF 	  ETR 			05/08/2019  RCM 		Adición reporte 2 Form.605
 #24 		KAF 	  ETR 			12/08/2019  RCM 		Adición método para Reporte Inventario Detallado
 #17    	KAF       ETR           14/08/2019  RCM         Adición método para Reporte Impuestos a la Propiedad e Inmuebles
 #19    	KAF       ETR           14/08/2019  RCM         Adición método para Reporte Impuestos de Vehículos
 #26    	KAF       ETR           16/08/2019  RCM         Adición método para Reporte Altas por Origen
 #23    	KAF       ETR           23/08/2019  RCM         Adición método para Reporte Comparación Activos Fijos y Contabilidad
 #31    	KAF       ETR           17/09/2019  RCM         Adición en el reporte detalle depreciación de las columnas de anexos 1 (cbte. 2) y 2 (cbte. 4)
 #29    	KAF       ETR           20/09/2019  RCM         Corrección reportes
 #42		KAF 	  ETR 			13/12/2019  RCM 		Modificación de parámetro para reporte
 #58		KAF 	  ETR 			21/04/2020  RCM 		Consulta para reporte anual de depreciación
 #70		KAF 	  ETR 			30/07/2020  RCM 		Adición de columna para consulta, ajustes en base a revisión
 #BB03		KAF 	  ETR 			08/09/2020  RCM 		Corrección tipo de dato, integer por numeric
 #AF-13		KAF 	  ETR 			18/10/2020  RCM 		Reporte de Saldos a una fecha
 #ETR-1717  KAF       ETR           10/11/2020  RCM         Cambio en la generación de cbte. de igualización considerando todas las monedas
***************************************************************************/
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
		$this->setParametro('id_moneda_dep','id_moneda_dep','integer'); //#42

		//Definicion de la lista del resultado del query
		$this->captura('codigo','VARCHAR');
		$this->captura('codigo_ant','VARCHAR');
		$this->captura('denominacion','VARCHAR');
		$this->captura('fecha_compra','DATE');
		$this->captura('fecha_ini_dep','DATE');
		$this->captura('estado','VARCHAR');
		$this->captura('vida_util_original','INTEGER');
		$this->captura('porcentaje_dep','INTEGER');
		$this->captura('ubicacion','VARCHAR');
		$this->captura('monto_compra_orig','NUMERIC');
		$this->captura('moneda','VARCHAR');
		//$this->captura('nro_cbte_asociado','VARCHAR');
		//$this->captura('fecha_cbte_asociado','DATE');
		//$this->captura('cod_clasif','VARCHAR');
		$this->captura('desc_clasif','VARCHAR');
		$this->captura('metodo_dep','VARCHAR');
		//$this->captura('ufv_fecha_compra','NUMERIC');
		$this->captura('responsable','TEXT');
		$this->captura('cargo','VARCHAR');
		$this->captura('fecha_mov','DATE');
		$this->captura('num_tramite','VARCHAR');
		$this->captura('desc_mov','VARCHAR');
		$this->captura('codigo_mov','VARCHAR');
		//$this->captura('ufv_mov','NUMERIC');
		$this->captura('id_activo_fijo','INTEGER');
		$this->captura('id_movimiento','INTEGER');

		$this->captura('tipo_cambio_ini','NUMERIC');
		$this->captura('tipo_cambio_fin','NUMERIC');
		$this->captura('factor','NUMERIC');
		$this->captura('fecha_dep','text');

		$this->captura('monto_actualiz_ant','NUMERIC');
		$this->captura('inc_monto_actualiz','NUMERIC');
		$this->captura('monto_actualiz','NUMERIC');
		$this->captura('vida_util_ant','integer');
		$this->captura('depreciacion_acum_ant','NUMERIC');
		$this->captura('inc_dep_acum','NUMERIC');
		$this->captura('depreciacion_acum_actualiz','NUMERIC');
		$this->captura('depreciacion','NUMERIC');
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
		///////////////////////////////////////////////////////////////////////////////////
		//OJO: Si se modifica este método, también cambiar : listarRepDepreciacionExportar
		///////////////////////////////////////////////////////////////////////////////////

		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RDEPREC_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		//$this->setCount(false);

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_deprec','af_deprec','varchar');
		$this->setParametro('tipoReporte','tipo_reporte','varchar');
		$this->setParametro('tipo_reporte','tipoReporte','varchar');
		$this->setParametro('id_moneda_dep','id_moneda_dep','integer'); //#25 se aumenta por corrección de nombre de parámetro

		//Definicion de la lista del resultado del query
		$this->captura('numero','bigint');
		$this->captura('codigo','varchar');
        $this->captura('codigo_ant','varchar');
        $this->captura('denominacion','varchar');
        $this->captura('fecha_ini_dep','date');
        $this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
        $this->captura('codigo_tcc','varchar');
        $this->captura('nro_serie','varchar');
		$this->captura('desc_ubicacion','varchar');
        $this->captura('responsable','text');
        $this->captura('monto_vigente_orig_100','numeric');
        $this->captura('monto_vigente_orig','numeric');
        $this->captura('af_altas','numeric');
        $this->captura('af_bajas','numeric');
        $this->captura('af_traspasos','numeric');
        $this->captura('inc_actualiz','numeric');
        $this->captura('monto_actualiz','numeric');//*****
        $this->captura('vida_util_orig','integer');
        $this->captura('vida_util','integer');
        $this->captura('vida_util_usada','integer');
        $this->captura('depreciacion_acum_gest_ant','numeric');
        $this->captura('depreciacion_acum_actualiz_gest_ant','numeric');
        $this->captura('depreciacion','numeric');
        $this->captura('depreciacion_acum_bajas','numeric');
        $this->captura('depreciacion_acum_traspasos','numeric');
        $this->captura('depreciacion_acum','numeric');//******
        $this->captura('depreciacion_per','numeric');
        $this->captura('monto_vigente','numeric');

        //Inicio #31
		$this->captura('aitb_dep_acum','numeric');
		$this->captura('aitb_dep','numeric');
		$this->captura('aitb_dep_acum_anual','numeric');
		$this->captura('aitb_dep_anual','numeric');
        //Fin #31

        //$this->captura('afecta_concesion','varchar');
		$this->captura('cuenta_activo','text');
		$this->captura('cuenta_dep_acum','text');
		$this->captura('cuenta_deprec','text');

        $this->captura('desc_grupo','varchar');
        $this->captura('desc_grupo_clasif','varchar');
        $this->captura('cuenta_dep_acum_dos','text');
        $this->captura('bk_codigo','varchar');

        //Inicio #9: Inclusión de nuevas columnas en método de reporte detalle depreciación
		$this->captura('cc1', 'varchar(50)');
		$this->captura('dep_mes_cc1', 'numeric(24,2)');
		$this->captura('cc2', 'varchar(50)');
		$this->captura('dep_mes_cc2', 'numeric(24,2)');
		$this->captura('cc3', 'varchar(50)');
		$this->captura('dep_mes_cc3', 'numeric(24,2)');
		$this->captura('cc4', 'varchar(50)');
		$this->captura('dep_mes_cc4', 'numeric(24,2)');
		$this->captura('cc5', 'varchar(50)');
		$this->captura('dep_mes_cc5', 'numeric(24,2)');
		$this->captura('cc6', 'varchar(50)');
		$this->captura('dep_mes_cc6', 'numeric(24,2)');
		$this->captura('cc7', 'varchar(50)');
		$this->captura('dep_mes_cc7', 'numeric(24,2)');
		$this->captura('cc8', 'varchar(50)');
		$this->captura('dep_mes_cc8', 'numeric(24,2)');
		$this->captura('cc9', 'varchar(50)');
		$this->captura('dep_mes_cc9', 'numeric(24,2)');
		$this->captura('cc10', 'varchar(50)');
		$this->captura('dep_mes_cc10', 'numeric(24,2)');

		$this->captura('id_activo_fijo','integer');
        $this->captura('nivel','integer');
        $this->captura('orden','bigint');
        $this->captura('tipo','varchar(10)');
		//Fin #9

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();


		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepDepreciacionExportar(){
		///////////////////////////////////////////////////////////////////////////
		//OJO: Si se modifica este método, también cambiar : listarRepDepreciacion
		///////////////////////////////////////////////////////////////////////////

		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RDEPREC_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_deprec','af_deprec','varchar');
		$this->setParametro('tipoReporte','tipo_reporte','varchar');
		$this->setParametro('tipo_reporte','tipoReporte','varchar');
		$this->setParametro('id_moneda_dep','id_moneda_dep','integer'); //#25 se aumenta por corrección de nombre de parámetro

		//Definicion de la lista del resultado del query
		$this->captura('numero','bigint');
		$this->captura('codigo','varchar');
        $this->captura('codigo_ant','varchar');
        $this->captura('denominacion','varchar');
        $this->captura('fecha_ini_dep','date');
        $this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
        $this->captura('codigo_tcc','varchar');
        $this->captura('nro_serie','varchar');
		$this->captura('desc_ubicacion','varchar');
        $this->captura('responsable','text');
        $this->captura('monto_vigente_orig_100','numeric');
        $this->captura('monto_vigente_orig','numeric');
        $this->captura('af_altas','numeric');
        $this->captura('af_bajas','numeric');
        $this->captura('af_traspasos','numeric');
        $this->captura('inc_actualiz','numeric');
        $this->captura('monto_actualiz','numeric');//*****
        $this->captura('vida_util_orig','integer');
        $this->captura('vida_util','integer');
        $this->captura('vida_util_usada','integer');
        $this->captura('depreciacion_acum_gest_ant','numeric');
        $this->captura('depreciacion_acum_actualiz_gest_ant','numeric');
        $this->captura('depreciacion','numeric');
        $this->captura('depreciacion_acum_bajas','numeric');
        $this->captura('depreciacion_acum_traspasos','numeric');
        $this->captura('depreciacion_acum','numeric');//******
        $this->captura('depreciacion_per','numeric');
        $this->captura('monto_vigente','numeric');

        //Inicio #31
		$this->captura('aitb_dep_acum','numeric');
		$this->captura('aitb_dep','numeric');
		$this->captura('aitb_dep_acum_anual','numeric');
		$this->captura('aitb_dep_anual','numeric');
        //Fin #31

        //$this->captura('afecta_concesion','varchar');
		$this->captura('cuenta_activo','text');
		$this->captura('cuenta_dep_acum','text');
		$this->captura('cuenta_deprec','text');

        $this->captura('desc_grupo','varchar');
        $this->captura('desc_grupo_clasif','varchar');
        $this->captura('cuenta_dep_acum_dos','text');
        $this->captura('bk_codigo','varchar');

        //Inicio #9: Inclusión de nuevas columnas en método de reporte detalle depreciación
		$this->captura('cc1', 'varchar(50)');
		$this->captura('dep_mes_cc1', 'numeric(24,2)');
		$this->captura('cc2', 'varchar(50)');
		$this->captura('dep_mes_cc2', 'numeric(24,2)');
		$this->captura('cc3', 'varchar(50)');
		$this->captura('dep_mes_cc3', 'numeric(24,2)');
		$this->captura('cc4', 'varchar(50)');
		$this->captura('dep_mes_cc4', 'numeric(24,2)');
		$this->captura('cc5', 'varchar(50)');
		$this->captura('dep_mes_cc5', 'numeric(24,2)');
		$this->captura('cc6', 'varchar(50)');
		$this->captura('dep_mes_cc6', 'numeric(24,2)');
		$this->captura('cc7', 'varchar(50)');
		$this->captura('dep_mes_cc7', 'numeric(24,2)');
		$this->captura('cc8', 'varchar(50)');
		$this->captura('dep_mes_cc8', 'numeric(24,2)');
		$this->captura('cc9', 'varchar(50)');
		$this->captura('dep_mes_cc9', 'numeric(24,2)');
		$this->captura('cc10', 'varchar(50)');
		$this->captura('dep_mes_cc10', 'numeric(24,2)');

		$this->captura('id_activo_fijo','integer');
        $this->captura('nivel','integer');
        $this->captura('orden','bigint');
        $this->captura('tipo','varchar(10)');
		//Fin #9

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();


		//Devuelve la respuesta
		return $this->respuesta;
	}

	//#Inicio #25
	function listarForm605(){
		//Definicion de variables para ejecucion del procedimientp
		/*$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_FRM605_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('gestion','gestion','varchar');
		$this->setParametro('id_activo_fijo_multi','id_activo_fijo_multi','varchar');

		//Definicion de la lista del resultado del query
        $this->captura('codigo', 'varchar');
        $this->captura('nro_cuenta', 'varchar');
        $this->captura('denominacion', 'varchar');
        $this->captura('unidad_medida', 'varchar');
        $this->captura('cantidad_af', 'integer');
        $this->captura('inventario_final', 'numeric');
        $this->captura('inventario_bajas', 'numeric');
        $this->captura('nombre_con_unidad', 'varchar');
        $this->captura('codigo_moneda', 'varchar');
        $this->captura('desc_moneda', 'varchar');*/

        //Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_FORM605V2_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('gestion','gestion','varchar');
		$this->setParametro('id_activo_fijo_multi','id_activo_fijo_multi','varchar');

		//Definicion de la lista del resultado del query
        $this->captura('codigo', 'varchar');
        $this->captura('nro_cuenta', 'text');
        $this->captura('denominacion', 'varchar');
        $this->captura('unidad_medida', 'varchar');
        $this->captura('cantidad_af', 'integer');
        $this->captura('inventario_final', 'numeric');
        $this->captura('inventario_bajas', 'numeric');
        $this->captura('nombre_con_unidad', 'varchar');
        $this->captura('codigo_moneda', 'varchar');
        $this->captura('desc_moneda', 'varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #25

	function listadoActivosFijos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af_2';
		$this->transaccion='SKA_LISAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		$this->setParametro('tipo_salida','tipo_salida','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('codigo','varchar');
		$this->captura('codigo_ant','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('desc_clasificacion','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('fecha_ini_dep','date');
		$this->captura('vida_util_original','integer');
		$this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
		$this->captura('estado','varchar');
		$this->captura('monto_compra_orig','numeric');
		$this->captura('codigo_tcc','varchar');
		$this->captura('desc_funcionario2','text');
		$this->captura('fecha_asignacion','date');
		$this->captura('desc_ubicacion','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarRepDepreciacionExportarPreProc(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_DEDEPRE_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_deprec','af_deprec','varchar');
		$this->setParametro('tipoReporte','tipo_reporte','varchar');
		$this->setParametro('tipo_reporte','tipoReporte','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('numero','bigint');
		$this->captura('codigo','varchar');
        $this->captura('codigo_ant','varchar');
        $this->captura('denominacion','varchar');
        $this->captura('fecha_ini_dep','date');
        $this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
        $this->captura('codigo_tcc','varchar');
        $this->captura('nro_serie','varchar');
		$this->captura('desc_ubicacion','varchar');
        $this->captura('responsable','text');
        $this->captura('monto_vigente_orig_100','numeric');
        $this->captura('monto_vigente_orig','numeric');
        $this->captura('af_altas','numeric');
        $this->captura('af_bajas','numeric');
        $this->captura('af_traspasos','numeric');
        $this->captura('inc_actualiz','numeric');
        $this->captura('monto_actualiz','numeric');
        $this->captura('vida_util_orig','integer');
        $this->captura('vida_util_usada','integer');
        $this->captura('vida_util','integer');
        $this->captura('depreciacion_acum_gest_ant','numeric');
        $this->captura('depreciacion_acum_actualiz_gest_ant','numeric');
        $this->captura('depreciacion','numeric');
        $this->captura('depreciacion_acum_bajas','numeric');
        $this->captura('depreciacion_acum_traspasos','numeric');
        $this->captura('depreciacion_acum','numeric');
        $this->captura('depreciacion_per','numeric');
        $this->captura('monto_vigente','numeric');
        //$this->captura('afecta_concesion','varchar');
		$this->captura('cuenta_activo','text');
		$this->captura('cuenta_dep_acum','text');
		$this->captura('cuenta_deprec','text');

        $this->captura('desc_grupo','varchar');
        $this->captura('desc_grupo_clasif','varchar');
        $this->captura('cuenta_dep_acum_dos','text');
		$this->captura('id_activo_fijo','integer');
        $this->captura('nivel','integer');
        $this->captura('orden','bigint');
        $this->captura('tipo','varchar(10)');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	//Inicio #20
	function reporteAfDistValores() {
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_REAFDVCAB_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		//Define los parametros para la funcion
        $this->captura('id_movimiento_af', 'integer');
        $this->captura('id_activo_fijo', 'integer');
		$this->captura('id_movimiento', 'integer');
		$this->captura('id_moneda', 'integer');
		$this->captura('id_movimiento_af_dep', 'integer');
		$this->captura('codigo', 'varchar');
		$this->captura('denominacion', 'varchar');
		$this->captura('num_tramite', 'varchar');
		$this->captura('fecha_mov', 'date');
		$this->captura('estado', 'varchar');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion_acum','numeric');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function reporteAfDistValoresDetalle() {
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_REAFDVDET_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		//Define los parametros para la funcion
		$this->captura('fecha_mov','date');
		$this->captura('codigo_activo_origen','varchar');
		$this->captura('denominacion_activo_origen','varchar');
		$this->captura('num_tramite','varchar');
		$this->captura('monto_actualiz_orig','numeric');
		$this->captura('depreciacion_acum_orig','numeric');
		$this->captura('tipo','varchar');
		$this->captura('codigo_activo_dest','varchar');
		$this->captura('denominacion_activo_dest','varchar');
		$this->captura('estado_af','varchar');
		$this->captura('codigo_almacen','varchar');
		$this->captura('nombre_almacen','varchar');
		$this->captura('porcentaje','numeric');
		$this->captura('monto_actualiz','numeric');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('id_movimiento_af_especial','integer');
		$this->captura('id_movimiento_af','integer');
		$this->captura('id_moneda','integer');
		$this->captura('glosa','varchar');
		$this->captura('estado','varchar');
		$this->captura('fecha','date');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #20

	//Inicio #24
	function listarInventarioDetallado(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_INVDETGC_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida', 'tipo_salida', 'varchar');
		$this->setParametro('id_moneda', 'id_moneda', 'integer');
		$this->setParametro('denominacion', 'denominacion', 'varchar');
		$this->setParametro('fecha_hasta', 'fecha_hasta', 'date');
		$this->setParametro('id_activo_fijo_multi', 'id_activo_fijo_multi', 'varchar');

		//Definicion de la lista del resultado del query
		$this->captura('nro_cuenta', 'VARCHAR');
		$this->captura('codigo', 'VARCHAR');
		$this->captura('fecha_ini_dep', 'DATE');
		$this->captura('denominacion', 'VARCHAR');
		$this->captura('monto_actualiz', 'NUMERIC');
		$this->captura('depreciacion_acum', 'NUMERIC');
		$this->captura('valor_actual', 'NUMERIC');
		$this->captura('codigo_moneda', 'VARCHAR');
		$this->captura('desc_moneda', 'VARCHAR');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #24

	//Inicio #17
	function listarImpuestosPropiedad(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_RIMPPROP_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida', 'tipo_salida', 'varchar');
		$this->setParametro('id_moneda', 'id_moneda', 'integer');
		$this->setParametro('fecha_hasta', 'fecha_hasta', 'date');

		//Definicion de la lista del resultado del query
		$this->captura('ubicacion', 'VARCHAR');
		$this->captura('clasificacion', 'VARCHAR');
		$this->captura('moneda', 'VARCHAR');
		$this->captura('valor_actualiz_gest_ant', 'NUMERIC');
		$this->captura('deprec_acum_gest_ant', 'NUMERIC');
		$this->captura('valor_actualiz', 'NUMERIC');
		$this->captura('deprec_sin_actualiz', 'NUMERIC');
		$this->captura('deprec_acum', 'NUMERIC');
		$this->captura('valor_neto', 'NUMERIC');
		$this->captura('orden', 'INTEGER');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #17

	//Inicio #19
	function listarImpuestosVehiculos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_RIMPVEH_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida', 'tipo_salida', 'varchar');
		$this->setParametro('id_moneda', 'id_moneda', 'integer');
		$this->setParametro('fecha_hasta', 'fecha_hasta', 'date');

		//Definicion de la lista del resultado del query
		$this->captura('codigo', 'varchar');
		$this->captura('ubicacion', 'varchar');
		$this->captura('clasificacion', 'varchar');
		$this->captura('moneda', 'varchar');
		$this->captura('denominacion', 'varchar');
		$this->captura('placa', 'varchar');
		$this->captura('radicatoria', 'varchar');
		$this->captura('fecha_ini_dep', 'date');
		$this->captura('valor_actualiz_gest_ant', 'numeric');
		$this->captura('deprec_acum_gest_ant', 'numeric');
		$this->captura('valor_actualiz', 'numeric');
		$this->captura('deprec_per', 'numeric');
		$this->captura('deprec_acum', 'numeric');
		$this->captura('valor_neto', 'numeric');
		$this->captura('codigo_ant', 'varchar');
		$this->captura('bk_codigo', 'varchar');
		$this->captura('local', 'varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #19

	//Inicio #26
	function listarAltaOrigen(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_RALORIG_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida', 'tipo_salida', 'varchar');
		$this->setParametro('id_moneda', 'id_moneda', 'integer');
		$this->setParametro('fecha_desde', 'fecha_desde', 'date');
		$this->setParametro('fecha_hasta', 'fecha_hasta', 'date');

		//Definicion de la lista del resultado del query
		$this->captura('tipo', 'text');
		$this->captura('codigo', 'varchar');
		$this->captura('denominacion', 'varchar');
		$this->captura('estado', 'varchar');
		$this->captura('fecha_ini_dep', 'date');
		$this->captura('monto_activo', 'numeric');
		//$this->captura('dep_acum_inicial', 'numeric'); //#29
		$this->captura('vida_util_orig', 'integer');
		$this->captura('nro_tramite', 'varchar');
		$this->captura('descripcion', 'text');//#29
		$this->captura('id_moneda', 'integer');
		$this->captura('id_estado_wf', 'integer');
		$this->captura('identificador', 'integer');
		$this->captura('tabla', 'text');
		$this->captura('cod_tipo', 'text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #26

	//Inicio #23
	function listarComparacionAfConta(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_2';
		$this->transaccion = 'SKA_RCOMPAFCT_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('fecha', 'fecha', 'date');
		$this->setParametro('id_movimiento', 'id_movimiento', 'integer');

		//Definicion de la lista del resultado del query
		$this->captura('fecha', 'date');
		$this->captura('nro_cuenta', 'varchar');
		$this->captura('nombre_cuenta', 'varchar');
		$this->captura('saldo_af', 'numeric');
		$this->captura('saldo_conta', 'numeric');
		$this->captura('diferencia_af_conta', 'numeric');
		$this->captura('id_int_comprobante', 'integer');
		$this->captura('id_usuario_reg', 'integer');
		$this->captura('fecha_reg', 'timestamp');
		$this->captura('estado_reg', 'varchar');
		$this->captura('id_movimiento', 'integer');
		$this->captura('id_cuenta', 'integer');
		$this->captura('codigo', 'varchar'); //#ETR-1717

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #23

	//Inicio #33
	function listarRepDepreciacionOpt(){
		///////////////////////////////////////////////////////////////////////////////////
		//OJO: Si se modifica este método, también cambiar : listarRepDepreciacionExportar
		///////////////////////////////////////////////////////////////////////////////////

		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af';
		$this->transaccion='SKA_RDEPRECV2_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		//$this->setCount(false);

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');
		$this->setParametro('af_deprec','af_deprec','varchar');
		$this->setParametro('tipoReporte','tipo_reporte','varchar');
		$this->setParametro('tipo_reporte','tipoReporte','varchar');
		$this->setParametro('id_moneda_dep','id_moneda_dep','integer'); //#25 se aumenta por corrección de nombre de parámetro

		//Definicion de la lista del resultado del query
		$this->captura('numero','bigint');
		$this->captura('codigo','varchar');
        $this->captura('codigo_ant','varchar');
        $this->captura('denominacion','varchar');
        $this->captura('fecha_ini_dep','date');
        $this->captura('cantidad_af','integer');
		$this->captura('desc_unidad_medida','varchar');
        $this->captura('codigo_tcc','varchar');
        $this->captura('nro_serie','varchar');
		$this->captura('desc_ubicacion','varchar');
        $this->captura('responsable','text');
        $this->captura('monto_vigente_orig_100','numeric');
        $this->captura('monto_vigente_orig','numeric');
        $this->captura('af_altas','numeric');
        $this->captura('af_bajas','numeric');
        $this->captura('af_traspasos','numeric');
        $this->captura('inc_actualiz','numeric');
        $this->captura('monto_actualiz','numeric');//*****
        $this->captura('vida_util_orig','integer');
        $this->captura('vida_util','integer');
        $this->captura('vida_util_usada','integer');
        $this->captura('depreciacion_acum_gest_ant','numeric');
        $this->captura('depreciacion_acum_actualiz_gest_ant','numeric');
        $this->captura('depreciacion','numeric');
        $this->captura('depreciacion_acum_bajas','numeric');
        $this->captura('depreciacion_acum_traspasos','numeric');
        $this->captura('depreciacion_acum','numeric');//******
        $this->captura('depreciacion_per','numeric');
        $this->captura('monto_vigente','numeric');

        //Inicio #31
		$this->captura('aitb_dep_acum','numeric');
		$this->captura('aitb_dep','numeric');
		$this->captura('aitb_dep_acum_anual','numeric');
		$this->captura('aitb_dep_anual','numeric');
        //Fin #31

        //$this->captura('afecta_concesion','varchar');
		$this->captura('cuenta_activo','text');
		$this->captura('cuenta_dep_acum','text');
		$this->captura('cuenta_deprec','text');

        $this->captura('desc_grupo','varchar');
        $this->captura('desc_grupo_clasif','varchar');
        $this->captura('cuenta_dep_acum_dos','text');
        $this->captura('bk_codigo','varchar');

        //Inicio #9: Inclusión de nuevas columnas en método de reporte detalle depreciación
		$this->captura('cc1', 'varchar(50)');
		$this->captura('dep_mes_cc1', 'numeric(24,2)');
		$this->captura('cc2', 'varchar(50)');
		$this->captura('dep_mes_cc2', 'numeric(24,2)');
		$this->captura('cc3', 'varchar(50)');
		$this->captura('dep_mes_cc3', 'numeric(24,2)');
		$this->captura('cc4', 'varchar(50)');
		$this->captura('dep_mes_cc4', 'numeric(24,2)');
		$this->captura('cc5', 'varchar(50)');
		$this->captura('dep_mes_cc5', 'numeric(24,2)');
		$this->captura('cc6', 'varchar(50)');
		$this->captura('dep_mes_cc6', 'numeric(24,2)');
		$this->captura('cc7', 'varchar(50)');
		$this->captura('dep_mes_cc7', 'numeric(24,2)');
		$this->captura('cc8', 'varchar(50)');
		$this->captura('dep_mes_cc8', 'numeric(24,2)');
		$this->captura('cc9', 'varchar(50)');
		$this->captura('dep_mes_cc9', 'numeric(24,2)');
		$this->captura('cc10', 'varchar(50)');
		$this->captura('dep_mes_cc10', 'numeric(24,2)');

		$this->captura('id_activo_fijo','integer');
        $this->captura('nivel','integer');
        $this->captura('orden','bigint');
        $this->captura('tipo','varchar(10)');
		//Fin #9

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();


		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #33

	//Inicio #58
	function listarReporteDeprecAnual(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af_2';
		$this->transaccion='SKA_RDEPRECANUAL_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		if($this->objParam->getParametro('tipo_salida')!='grid'){
			$this->setCount(false);
		}

		//Define los parametros para la funcion
		$this->setParametro('tipo_salida','tipo_salida','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');

		//Definicion de la lista del resultado del query
		$this->captura('numero', 'BIGINT');
		$this->captura('codigo', 'VARCHAR');
		$this->captura('codigo_sap', 'VARCHAR');
		$this->captura('denominacion', 'VARCHAR');
		$this->captura('fecha_ini_dep', 'DATE');
		$this->captura('cantidad_af', 'INTEGER');
		$this->captura('unidad_medida', 'VARCHAR');
		$this->captura('cc', 'VARCHAR');
		$this->captura('nro_serie', 'VARCHAR');
		$this->captura('lugar', 'VARCHAR');
		$this->captura('responsable', 'TEXT');
		$this->captura('valor_compra', 'NUMERIC');
		$this->captura('valor_inicial', 'NUMERIC');
		$this->captura('valor_mes_ant', 'NUMERIC');
		$this->captura('altas', 'NUMERIC');
		$this->captura('bajas', 'NUMERIC');
		$this->captura('traspasos', 'NUMERIC');
		$this->captura('inc_actualiz', 'NUMERIC');
		$this->captura('valor_actualiz', 'NUMERIC');
		$this->captura('vida_util_orig', 'INTEGER');
		$this->captura('vida_util_transc', 'INTEGER');
		$this->captura('vida_util', 'INTEGER');
		$this->captura('depreciacion_acum_gest_ant', 'NUMERIC');
		$this->captura('depreciacion_acum_mes_ant', 'NUMERIC'); //#70
		$this->captura('inc_actualiz_dep_acum', 'NUMERIC');
		$this->captura('depreciacion', 'NUMERIC');
		$this->captura('dep_acum_bajas', 'NUMERIC');
		$this->captura('dep_acum_tras', 'INTEGER');
		$this->captura('depreciacion_acum', 'NUMERIC');
		//$this->captura('depreciacion_per', 'NUMERIC'); //#70
		$this->captura('monto_vigente', 'NUMERIC');
		$this->captura('aitb_dep_mes', 'NUMERIC'); //#70
		$this->captura('aitb_af_ene', 'NUMERIC');
		$this->captura('aitb_af_feb', 'NUMERIC');
		$this->captura('aitb_af_mar', 'NUMERIC');
		$this->captura('aitb_af_abr', 'NUMERIC');
		$this->captura('aitb_af_may', 'NUMERIC');
		$this->captura('aitb_af_jun', 'NUMERIC');
		$this->captura('aitb_af_jul', 'NUMERIC');
		$this->captura('aitb_af_ago', 'NUMERIC');
		$this->captura('aitb_af_sep', 'NUMERIC');
		$this->captura('aitb_af_oct', 'NUMERIC');
		$this->captura('aitb_af_nov', 'NUMERIC');
		$this->captura('aitb_af_dic', 'NUMERIC');
		$this->captura('total_aitb_af', 'NUMERIC');
		$this->captura('aitb_dep_acum_ene', 'NUMERIC');
		$this->captura('aitb_dep_acum_feb', 'NUMERIC');
		$this->captura('aitb_dep_acum_mar', 'NUMERIC');
		$this->captura('aitb_dep_acum_abr', 'NUMERIC');
		$this->captura('aitb_dep_acum_may', 'NUMERIC');
		$this->captura('aitb_dep_acum_jun', 'NUMERIC');
		$this->captura('aitb_dep_acum_jul', 'NUMERIC');
		$this->captura('aitb_dep_acum_ago', 'NUMERIC');
		$this->captura('aitb_dep_acum_sep', 'NUMERIC');
		$this->captura('aitb_dep_acum_oct', 'NUMERIC');
		$this->captura('aitb_dep_acum_nov', 'NUMERIC');
		$this->captura('aitb_dep_acum_dic', 'NUMERIC');
		$this->captura('total_aitb_dep_acum', 'NUMERIC');
		$this->captura('dep_ene', 'NUMERIC');
		$this->captura('dep_feb', 'NUMERIC');
		$this->captura('dep_mar', 'NUMERIC');
		$this->captura('dep_abr', 'NUMERIC');

		$this->captura('dep_may', 'NUMERIC');
		$this->captura('dep_jun', 'NUMERIC');
		$this->captura('dep_jul', 'NUMERIC');
		$this->captura('dep_ago', 'NUMERIC');
		$this->captura('dep_sep', 'NUMERIC');
		$this->captura('dep_oct', 'NUMERIC');
		$this->captura('dep_nov', 'NUMERIC');
		$this->captura('dep_dic', 'NUMERIC');
		$this->captura('total_dep', 'NUMERIC');
		$this->captura('aitb_dep_ene', 'NUMERIC');
		$this->captura('aitb_dep_feb', 'NUMERIC');
		$this->captura('aitb_dep_mar', 'NUMERIC');
		$this->captura('aitb_dep_abr', 'NUMERIC');
		$this->captura('aitb_dep_may', 'NUMERIC');
		$this->captura('aitb_dep_jun', 'NUMERIC');
		$this->captura('aitb_dep_jul', 'NUMERIC');
		$this->captura('aitb_dep_ago', 'NUMERIC');
		$this->captura('aitb_dep_sep', 'NUMERIC');
		$this->captura('aitb_dep_oct', 'NUMERIC');
		$this->captura('aitb_dep_nov', 'NUMERIC');
		$this->captura('aitb_dep_dic', 'NUMERIC');
		$this->captura('total_aitb_dep', 'NUMERIC');
		$this->captura('cuenta_activo', 'VARCHAR');
		$this->captura('cuenta_dep_acum', 'VARCHAR');
		$this->captura('cuenta_deprec', 'VARCHAR');
		$this->captura('desc_grupo', 'VARCHAR');
		$this->captura('desc_grupo_clasif', 'VARCHAR');
		//Inicio #70
		$this->captura('cuenta_dep_acum_dos','text');
        $this->captura('bk_codigo','varchar');
        //Fin #70
		$this->captura('tipo', 'VARCHAR');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #58

	//Inicio #70
	function listarReporteDeprecAnualGenerado(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.f_reportes_af_3';
		$this->transaccion='SKA_RDEPANUALGEN_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_moneda','id_moneda','integer');

		//Definicion de la lista del resultado del query
		$this->captura('numero', 'BIGINT');
		$this->captura('codigo', 'VARCHAR');
		$this->captura('codigo_sap', 'VARCHAR');
		$this->captura('denominacion', 'VARCHAR');
		$this->captura('fecha_ini_dep', 'DATE');
		$this->captura('cantidad_af', 'INTEGER');
		$this->captura('unidad_medida', 'VARCHAR');
		$this->captura('cc', 'VARCHAR');
		$this->captura('nro_serie', 'VARCHAR');
		$this->captura('lugar', 'VARCHAR');
		$this->captura('responsable', 'TEXT');

		$this->captura('vida_util_orig', 'INTEGER');
		$this->captura('vida_util_transc', 'INTEGER');
		$this->captura('vida_util', 'INTEGER');


		$this->captura('valor_compra', 'NUMERIC');
		$this->captura('valor_inicial', 'NUMERIC');
		$this->captura('valor_mes_ant', 'NUMERIC');
		$this->captura('altas', 'NUMERIC');
		$this->captura('bajas', 'NUMERIC');
		$this->captura('traspasos', 'NUMERIC');
		$this->captura('inc_actualiz', 'NUMERIC');
		$this->captura('valor_actualiz', 'NUMERIC');

		$this->captura('depreciacion_acum_gest_ant', 'NUMERIC');

		$this->captura('depreciacion_acum_mes_ant', 'NUMERIC');

		$this->captura('dep_acum_bajas', 'NUMERIC');
		$this->captura('dep_acum_tras', 'NUMERIC'); //#BB03

		$this->captura('inc_actualiz_dep_acum', 'NUMERIC');
		$this->captura('depreciacion', 'NUMERIC');

		$this->captura('depreciacion_acum', 'NUMERIC');
		$this->captura('monto_vigente', 'NUMERIC');
		$this->captura('aitb_dep_mes', 'NUMERIC');
		$this->captura('aitb_af_ene', 'NUMERIC');
		$this->captura('aitb_af_feb', 'NUMERIC');
		$this->captura('aitb_af_mar', 'NUMERIC');
		$this->captura('aitb_af_abr', 'NUMERIC');
		$this->captura('aitb_af_may', 'NUMERIC');
		$this->captura('aitb_af_jun', 'NUMERIC');
		$this->captura('aitb_af_jul', 'NUMERIC');
		$this->captura('aitb_af_ago', 'NUMERIC');
		$this->captura('aitb_af_sep', 'NUMERIC');
		$this->captura('aitb_af_oct', 'NUMERIC');
		$this->captura('aitb_af_nov', 'NUMERIC');
		$this->captura('aitb_af_dic', 'NUMERIC');
		$this->captura('total_aitb_af', 'NUMERIC');
		$this->captura('aitb_dep_acum_ene', 'NUMERIC');
		$this->captura('aitb_dep_acum_feb', 'NUMERIC');
		$this->captura('aitb_dep_acum_mar', 'NUMERIC');
		$this->captura('aitb_dep_acum_abr', 'NUMERIC');
		$this->captura('aitb_dep_acum_may', 'NUMERIC');
		$this->captura('aitb_dep_acum_jun', 'NUMERIC');
		$this->captura('aitb_dep_acum_jul', 'NUMERIC');
		$this->captura('aitb_dep_acum_ago', 'NUMERIC');
		$this->captura('aitb_dep_acum_sep', 'NUMERIC');
		$this->captura('aitb_dep_acum_oct', 'NUMERIC');
		$this->captura('aitb_dep_acum_nov', 'NUMERIC');
		$this->captura('aitb_dep_acum_dic', 'NUMERIC');
		$this->captura('total_aitb_dep_acum', 'NUMERIC');
		$this->captura('dep_ene', 'NUMERIC');
		$this->captura('dep_feb', 'NUMERIC');
		$this->captura('dep_mar', 'NUMERIC');
		$this->captura('dep_abr', 'NUMERIC');

		$this->captura('dep_may', 'NUMERIC');
		$this->captura('dep_jun', 'NUMERIC');
		$this->captura('dep_jul', 'NUMERIC');
		$this->captura('dep_ago', 'NUMERIC');
		$this->captura('dep_sep', 'NUMERIC');
		$this->captura('dep_oct', 'NUMERIC');
		$this->captura('dep_nov', 'NUMERIC');
		$this->captura('dep_dic', 'NUMERIC');
		$this->captura('total_dep', 'NUMERIC');
		$this->captura('aitb_dep_ene', 'NUMERIC');
		$this->captura('aitb_dep_feb', 'NUMERIC');
		$this->captura('aitb_dep_mar', 'NUMERIC');
		$this->captura('aitb_dep_abr', 'NUMERIC');
		$this->captura('aitb_dep_may', 'NUMERIC');
		$this->captura('aitb_dep_jun', 'NUMERIC');
		$this->captura('aitb_dep_jul', 'NUMERIC');
		$this->captura('aitb_dep_ago', 'NUMERIC');
		$this->captura('aitb_dep_sep', 'NUMERIC');
		$this->captura('aitb_dep_oct', 'NUMERIC');
		$this->captura('aitb_dep_nov', 'NUMERIC');
		$this->captura('aitb_dep_dic', 'NUMERIC');
		$this->captura('total_aitb_dep', 'NUMERIC');
		$this->captura('cuenta_activo', 'VARCHAR');
		$this->captura('cuenta_dep_acum', 'VARCHAR');
		$this->captura('cuenta_deprec', 'VARCHAR');
		$this->captura('desc_grupo', 'VARCHAR');
		$this->captura('desc_grupo_clasif', 'VARCHAR');
		$this->captura('cuenta_dep_acum_dos','TEXT');
        $this->captura('bk_codigo','VARCHAR');
		$this->captura('tipo', 'VARCHAR');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
	//Fin #70

	//Inicio #AF-13
	function listarReporteSaldoAf(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento = 'kaf.f_reportes_af_3';
		$this->transaccion = 'SKA_RSALDAF_SEL';
		$this->tipo_procedimiento = 'SEL';//tipo de transaccion
		$this->setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('fecha','fecha','date');

		//Definicion de la lista del resultado del query
		$this->captura('codigo', 'VARCHAR');
		$this->captura('codigo_sap', 'VARCHAR');
		$this->captura('denominacion', 'VARCHAR');
		$this->captura('vida_util', 'INTEGER');

		$this->captura('val_actualiz_bs', 'NUMERIC');
		$this->captura('dep_acum_bs', 'NUMERIC');
		$this->captura('dep_per_bs', 'NUMERIC');
		$this->captura('val_neto_bs', 'NUMERIC');

		$this->captura('val_actualiz_ufv', 'NUMERIC');
		$this->captura('dep_acum_ufv', 'NUMERIC');
		$this->captura('dep_per_ufv', 'NUMERIC');
		$this->captura('val_neto_ufv', 'NUMERIC');

		$this->captura('test_val_actualiz', 'NUMERIC');
		$this->captura('test_dep_acum', 'NUMERIC');
		$this->captura('test_dep_per', 'NUMERIC');
		$this->captura('test_val_neto', 'NUMERIC');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

}
?>