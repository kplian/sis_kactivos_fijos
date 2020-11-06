<?php
/**
*@package pXP
*@file ACTReportes.php
*@author  RCM
*@date 27/07/2017
*@description Genera los reportes generales

****************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #0 	KAF 	  ETR 			27/07/2017  RCM 		Creación del archivo
 #20    KAF       ETR           03/08/2019  RCM         Reporte Activos Fijos con Distribución de Valores
 #25 	KAF 	  ETR 			05/08/2019  RCM 		Adición reporte 2 Form.605
 #24 	KAF 	  ETR 			12/08/2019  RCM 		Adición reporte 1 Inventarion Detallado
 #17    KAF       ETR           14/08/2019  RCM         Adición método para Reporte Impuestos a la Propiedad e Inmuebles
 #19    KAF       ETR           14/08/2019  RCM         Adición método para Reporte Impuestos de Vehículos
 #26    KAF       ETR           22/08/2019  RCM         Adición método para Reporte Altas por Origen
 #23    KAF       ETR           23/08/2019  RCM         Adición método para Reporte Comparación Activos Fijos y Contabilidad
 #58	KAF 	  ETR 			21/04/2020  RCM 		Consulta para reporte anual de depreciación
 #70	KAF 	  ETR 			07/08/2020  RCM 		Consulta para reporte anual de depreciación apuntando a tabla preprocesada
 #AF-13	KAF 	  ETR 			18/10/2020  RCM 		Reporte de Saldos a una fecha
****************************************************************************
*/
require_once(dirname(__FILE__).'/../../pxp/pxpReport/DataSource.php');
require_once(dirname(__FILE__).'/../reportes/RKardexAFxls.php');
require_once(dirname(__FILE__).'/../reportes/RReporteGralAFXls.php');
require_once(dirname(__FILE__).'/../reportes/RRespInventario.php');
require_once(dirname(__FILE__).'/../reportes/RDetalleDepreciacion.php');
require_once(dirname(__FILE__).'/../reportes/RDetalleDepreciacionXls.php');
require_once(dirname(__FILE__).'/../reportes/RForm605xls.php'); //#25
require_once(dirname(__FILE__).'/../reportes/RInventarioDetalladoXls.php'); //#24
require_once(dirname(__FILE__).'/../reportes/RImpuestosPropiedadXls.php'); //#17
require_once(dirname(__FILE__).'/../reportes/RImpuestosVehiculosXls.php'); //#19
require_once(dirname(__FILE__).'/../reportes/RAfDistValoresXls.php'); //#20
require_once(dirname(__FILE__).'/../reportes/RAltaOrigenXls.php'); //#26
require_once(dirname(__FILE__).'/../reportes/RComparacionAfContaXls.php'); //#23
require_once(dirname(__FILE__).'/../reportes/RDetalleDepreciacionAnualXls.php');//#58
require_once(dirname(__FILE__).'/../reportes/RSaldoAfXls.php');//#AF-13

class ACTReportes extends ACTbase {

	function reporteKardexAF(){
		$this->objParam->defecto('ordenacion','fecha_mov');
		$this->objParam->defecto('dir_ordenacion','asc');

		//Verifica si la petición es para elk reporte en excel o de grilla
		if($this->objParam->getParametro('tipo_salida')=='reporte'){
			$this->objFunc=$this->create('MODReportes');
			//$datos=$this->objFunc->reporteKardex($this->objParam);
			$this->reporteKardexAFXls($datos);
		} else {
			if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
				$this->objReporte = new Reporte($this->objParam,$this);
				$this->res = $this->objReporte->generarReporteListado('MODReportes','reporteKardex');
			} else{
				$this->objFunc=$this->create('MODReportes');
				$this->res=$this->objFunc->reporteKardex($this->objParam);
			}
			$this->res->imprimirRespuesta($this->res->generarJson());
		}

	}

	function reporteKardexAFXls(){
		$nombreArchivo = uniqid(md5(session_id()).'KardexAF').'.xls';

		//Recuperar datos
		$this->objFunc = $this->create('MODReportes');
		$repDatos = $this->objFunc->reporteKardex($this->objParam);

		$dataSource = $repDatos;

		//Parámetros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Kardex Activos Fijos';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		//Generación de reporte
		$reporte = new RKardexAFxls($this->objParam);
		$reporte->setDataSet($dataSource->getDatos());
		$reporte->datosHeader($dataSource->getDatos(), $this->objParam->getParametro('id_entrega'));
  	    $reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function ReporteGralAF(){
		$this->definirFiltros();
		//Verifica si la petición es para elk reporte en excel o de grilla
		if($this->objParam->getParametro('tipo_salida')=='reporte'){
			$this->objFunc=$this->create('MODReportes');
			$datos=$this->objFunc->reporteGralAF($this->objParam);
			$this->reporteGralAFXls($datos);
		} else {
			if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
				$this->objReporte = new Reporte($this->objParam,$this);
				$metodo=$this->objParam->getParametro('rep_metodo_list');
				$this->res = $this->objReporte->generarReporteListado('MODReportes',$metodo);
			} else {
				$this->objFunc=$this->create('MODReportes');

				eval('$this->res=$this->objFunc->'.$this->objParam->getParametro('rep_metodo_list').'($this->objParam);');



				//$this->res=$this->objFunc->reporteGralAF($this->objParam);
			}
			$this->res->imprimirRespuesta($this->res->generarJson());
		}

	}

	function reporteGralAFXls($datos){
		$nombreArchivo = uniqid(md5(session_id()).'ReporteGralAF').'.xls';

		//Recuperar datos
		$this->objFunc = $this->create('MODReportes');

		//Parámetros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Reporte Activos Fijos';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		//Generación de reporte
		$reporte = new RReporteGralAFXls($this->objParam);
		$reporte->setTipoReporte($this->objParam->getParametro('reporte'));
		$reporte->setTituloReporte($this->objParam->getParametro('titulo_reporte'));
		$reporte->setMoneda($this->objParam->getParametro('desc_moneda'));
		$reporte->setDataSet($datos->getDatos());

  	    $reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function listarDepreciacionDeptoFechas(){
		$this->objParam->defecto('ordenacion','id_depto');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODReportes','listarDepreciacionDeptoFechas');
		} else {
			$this->objFunc=$this->create('MODReportes');
			$this->res=$this->objFunc->listarDepreciacionDeptoFechas($this->objParam);
		}

		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarRepDepreciacion(){
		$this->definirFiltros();

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			//$this->res = $this->objReporte->generarReporteListado('MODReportes','listarRepDepreciacionExportar'); //#33
			$this->res = $this->objReporte->generarReporteListado('MODReportes','listarRepDepreciacionOpt');
		} else {
			$this->objFunc=$this->create('MODReportes');
			//$this->res=$this->objFunc->listarRepDepreciacion($this->objParam); //#33
			$this->res=$this->objFunc->listarRepDepreciacionOpt($this->objParam);
		}

		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarRepDepreciacionPDF(){
		$this->definirFiltros();

		$this->objFunc=$this->create('MODReportes');
		$data=$this->objFunc->listarRepDepreciacion($this->objParam);
		if($data->getTipo() == 'EXITO'){
			return $data;
		}
        else{
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}

	}

	function definirFiltros() {
		$this->objParam->defecto('ordenacion','codigo');
		$this->objParam->defecto('dir_ordenacion','asc');

		//Filtros generales
		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}
		if($this->objParam->getParametro('id_clasificacion')!=''){
			$this->objParam->addFiltro("afij.id_clasificacion in (
					WITH RECURSIVE t(id,id_fk) AS (
    				SELECT l.id_clasificacion,l.id_clasificacion_fk
    				FROM kaf.tclasificacion l
    				WHERE l.id_clasificacion = ".$this->objParam->getParametro('id_clasificacion')."
    				UNION ALL
    				SELECT l.id_clasificacion,l.id_clasificacion_fk
    				FROM kaf.tclasificacion l, t
    				WHERE l.id_clasificacion_fk = t.id
					)
					SELECT id
					FROM t)");
		}
		if($this->objParam->getParametro('denominacion')!=''){
			$this->objParam->addFiltro("afij.denominacion ilike ''%".$this->objParam->getParametro('denominacion')."%''");
		}
		if($this->objParam->getParametro('fecha_compra')!=''){
			$this->objParam->addFiltro("afij.fecha_compra >= ''".$this->objParam->getParametro('fecha_compra')."''");
		}
		if($this->objParam->getParametro('fecha_ini_dep')!=''){
			$this->objParam->addFiltro("afij.fecha_ini_dep = ''".$this->objParam->getParametro('fecha_ini_dep')."''");
		}
		if($this->objParam->getParametro('estado')!=''){
			$this->objParam->addFiltro("afij.estado = ''".$this->objParam->getParametro('estado')."''");
		}
		if($this->objParam->getParametro('id_centro_costo')!=''){
			$this->objParam->addFiltro("afij.id_centro_costo in (
					WITH RECURSIVE t(id,id_fk) AS (
    				SELECT l.id_uo_hijo,l.id_uo_padre
    				FROM orga.testructura_uo l
    				WHERE l.id_uo_hijo = ".$this->objParam->getParametro('id_uo')."
    				UNION ALL
    				SELECT l.id_uo_hijo,l.id_uo_padre
    				FROM orga.testructura_uo l, t
    				WHERE l.id_uo_padre = t.id
					)
					SELECT id
					FROM t)");
		}
		if($this->objParam->getParametro('ubicacion')!=''){
			$this->objParam->addFiltro("afij.ubicacion ilike ''%".$this->objParam->getParametro('ubicacion')."%''");
		}
		if($this->objParam->getParametro('id_oficina')!=''){
			$this->objParam->addFiltro("afij.id_oficina = ".$this->objParam->getParametro('id_oficina'));
		}
		if($this->objParam->getParametro('id_funcionario')!=''){
			$this->objParam->addFiltro("afij.id_funcionario = ''".$this->objParam->getParametro('id_funcionario')."''");
		}
		if($this->objParam->getParametro('id_uo')!=''){
			$this->objParam->addFiltro("uo.id_uo in (
					WITH RECURSIVE t(id,id_fk) AS (
    				SELECT l.id_uo_hijo,l.id_uo_padre
    				FROM orga.testructura_uo l
    				WHERE l.id_uo_hijo = ".$this->objParam->getParametro('id_uo')."
    				UNION ALL
    				SELECT l.id_uo_hijo,l.id_uo_padre
    				FROM orga.testructura_uo l, t
    				WHERE l.id_uo_padre = t.id
					)
					SELECT id
					FROM t)");
		}
		if($this->objParam->getParametro('id_funcionario_compra')!=''){

		}
		if($this->objParam->getParametro('id_lugar')!=''){

		}
		if($this->objParam->getParametro('af_transito')!=''){
			if($this->objParam->getParametro('af_transito')=='tra'){
				$this->objParam->addFiltro("afij.estado = ''transito''");
			} else if($this->objParam->getParametro('af_transito')=='af') {
				$this->objParam->addFiltro("afij.estado != ''transito''");
			}
		}
		if($this->objParam->getParametro('af_tangible')!=''&&$this->objParam->getParametro('af_tangible')!='ambos'){
			$this->objParam->addFiltro("cla.tipo_activo = ''".$this->objParam->getParametro('af_tangible')."''");
		}
		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto'));
		}
		if($this->objParam->getParametro('id_deposito')!=''){
			$this->objParam->addFiltro("afij.id_deposito = ".$this->objParam->getParametro('id_deposito'));
		}
		if($this->objParam->getParametro('monto_inf')!=''){
			$this->objParam->addFiltro("afij.monto_compra >= ".$this->objParam->getParametro('monto_inf'));
		}
		if($this->objParam->getParametro('monto_sup')!=''){
			$this->objParam->addFiltro("afij.monto_compra <= ".$this->objParam->getParametro('monto_sup'));
		}
		if($this->objParam->getParametro('fecha_compra_max')!=''){
			$this->objParam->addFiltro("afij.fecha_compra <= ''".$this->objParam->getParametro('fecha_compra_max')."''");
		}
		if($this->objParam->getParametro('nro_cbte_asociado')!=''){
			$this->objParam->addFiltro("afij.nro_cbte_asociado ilike ''%".$this->objParam->getParametro('nro_cbte_asociado')."%''");
		}
		if($this->objParam->getParametro('id_lugar')!=''){
			$this->objParam->addFiltro("afij.id_oficina in (select id_oficina from orga.toficina where id_lugar = ".$this->objParam->getParametro('id_lugar').")");
		}
		if($this->objParam->getParametro('id_ubicacion')!=''){
			$this->objParam->addFiltro("afij.id_ubicacion = ".$this->objParam->getParametro('id_ubicacion'));
		}
		//Inicio #25
		if($this->objParam->getParametro('id_activo_fijo_multi')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo IN (" . $this->objParam->getParametro('id_activo_fijo_multi').")");
		}
		//Fin #25

		//Inicio #26
		if($this->objParam->getParametro('tipo_activacion')!=''){
			if($this->objParam->getParametro('tipo_activacion')!='todos')
			$this->objParam->addFiltro("afij.cod_tipo = ''" . $this->objParam->getParametro('tipo_activacion')."''");
		}
		//Fin #26
	}

	function ReporteRespInventario(){
		$nombreArchivo = 'RespInventario'.uniqid(md5(session_id())).'.pdf';

		$this->definirFiltros();

		$this->objFunc=$this->create('MODReportes');
		$dataSource=$this->objFunc->listarRepAsignados($this->objParam);

		//parametros basicos
		$orientacion = 'L';
		$titulo = 'Responsable-Inventario';

        $width = 160;
        $height = 80;

		$this->objParam->addParametro('orientacion',$orientacion);
		//$this->objParam->addParametro('tamano',array($width, $height));
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$clsRep = $dataSource->getDatos();
		$reporte = new RRespInventario($this->objParam);

		$reporte->setOficina($this->objParam->getParametro('nombre_oficina'));
		$reporte->setTipo($this->objParam->getParametro('tipo'));
		$reporte->datosHeader($dataSource->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function ReporteDetalleDepreciacion(){
		$nombreArchivo = 'DetalleDepreciacion'.uniqid(md5(session_id())).'.pdf';
		$obj = $this->listarRepDepreciacionPDF();

		$dataMaestro = $obj->getDatos();

		//parametros basicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Consolidado';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		//Instancia la clase de pdf
		$reporte = new RDetalleDepreciacion($this->objParam);
		$reporte->datosHeader($obj->getDatos(),$obj->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');
		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	/*function ReporteForm605(){
		$this->objParam->defecto('ordenacion','af.codigo');
		$this->objParam->defecto('dir_ordenacion','asc');
		//Verifica si la petición es para elk reporte en excel o de grilla
		//$this->objFunc=$this->create('MODReportes');
		$this->ReporteForm605Xls();

	}*/

	//Inicio #25
	function listarForm605(){
		$this->definirFiltros();
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarForm605($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

	function ReporteForm605Xls(){
		$this->objParam->defecto('ordenacion', 'afij.codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('Form605' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarForm605($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Formulario 605';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RForm605xls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #25


	function generarReporteDetalleDepreciacion() {
		$nombreArchivo = uniqid('RDetalleDepreciacionXls'.md5(session_id())).'.xls';
		//$dataSourceMaster = $this->obtenerMovimientoID();
		$dataSource = $this->obtenerDetalleDepreciacion();

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Detalle Dep.';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RDetalleDepreciacionXls($this->objParam);
		$reporte->setMaster($dataSourceMaster);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function obtenerDetalleDepreciacion(){
		$this->definirFiltros();
		$this->objFunc=$this->create('MODReportes');
		//$data = $this->objFunc->listarRepDepreciacion($this->objParam);
		$data = $this->objFunc->listarRepDepreciacionOpt($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

    function generarReporteDetalleDepreciacion2(){
		$nombreArchivo = uniqid('RDetalleDepreciacionXls'.md5(session_id())).'.xls';
		//$dataSourceMaster = $this->obtenerMovimientoID();
		$dataSource = $this->obtenerDetalleDepreciacion2();

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Detalle Dep.';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RDetalleDepreciacionXls($this->objParam);
		$reporte->setMaster($dataSourceMaster);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function obtenerDetalleDepreciacion2(){
		$this->definirFiltros();
		$this->objFunc=$this->create('MODReportes');
		$data = $this->objFunc->listarRepDepreciacionExportarPreProc($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

    //Inicio #20
    function reporteAfDistValores(){
		$this->objParam->defecto('ordenacion','mov.fecha_mov');
		$this->objParam->defecto('dir_ordenacion','desc');

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("mdep1.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODReportes','reporteAfDistValores');
		} else{
			$this->objFunc=$this->create('MODReportes');
			$this->res=$this->objFunc->reporteAfDistValores($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());

	}

	function reporteAfDistValoresDetalle(){
		$this->objParam->defecto('ordenacion','mov.fecha_mov');
		$this->objParam->defecto('dir_ordenacion','desc');

		if($this->objParam->getParametro('id_movimiento_af')!=''){
			$this->objParam->addFiltro("mafe.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("mdep1.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODReportes','reporteAfDistValoresDetalle');
		} else{
			$this->objFunc=$this->create('MODReportes');
			$this->res=$this->objFunc->reporteAfDistValoresDetalle($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());

	}

	function ReporteAfDistValoresXls(){
		$this->objParam->defecto('ordenacion', 'afij.codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$nombreArchivo = uniqid('AfDistValores' . md5(session_id())) . '.xls';

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("mdep1.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->reporteAfDistValoresDetalle($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'AF DIST VALORES';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RAfDistValoresXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #20

	//Inicio #24
	function listarInventarioDetallado(){
		$this->definirFiltros();
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarInventarioDetallado($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

	function ReporteInventarioDetalladoXls(){
		$this->objParam->defecto('ordenacion', 'afij.codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('InvDetallado' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarInventarioDetallado($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'INVENTARIO DETALLADO';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RInventarioDetalladoXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #24

	//Inicio #17
	function listarImpuestosPropiedad(){
		$this->definirFiltros();
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarImpuestosPropiedad($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

	function ReporteImpuestosPropiedadXls(){
		$this->objParam->defecto('ordenacion', 'orden');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('ImpProp' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarImpuestosPropiedad($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'IMPUESTOS A LA PROPIEDAD';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RImpuestosPropiedadXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #17

	//Inicio #19
	function listarImpuestosVehiculos(){
		$this->definirFiltros();
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarImpuestosVehiculos($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

	function ReporteImpuestosVehiculosXls(){
		$this->objParam->defecto('ordenacion', 'codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('ImpProp' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarImpuestosVehiculos($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'IMPUESTOS A LA PROPIEDAD';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RImpuestosVehiculosXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #19

	//Inicio #26
	function listarAltaOrigen(){
		$this->definirFiltros();
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarAltaOrigen($this->objParam);

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

	function ReporteAltaOrigenXls(){
		$this->objParam->defecto('ordenacion', 'codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('AltaOrigen' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarAltaOrigen($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'ORIGEN DE ALTAS';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RAltaOrigenXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #26

	//Inicio #23
	function ReporteComparacionAfContaXls(){
		$this->objParam->defecto('ordenacion', 'codigo');
		$this->objParam->defecto('dir_ordenacion', 'asc');

		$this->definirFiltros();

		$nombreArchivo = uniqid('CompAfConta' . md5(session_id())) . '.xls';
		$this->objFunc = $this->create('MODReportes');
		$dataSource = $this->objFunc->listarComparacionAfConta($this->objParam);

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Comparación Saldos Depreciación';

		$this->objParam->addParametro('orientacion', $orientacion);
		$this->objParam->addParametro('tamano', $tamano);
		$this->objParam->addParametro('titulo_archivo', $titulo);
		$this->objParam->addParametro('nombre_archivo', $nombreArchivo);

		$reporte = new RComparacionAfContaXls($this->objParam);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO', 'Reporte.php', 'Reporte generado', 'Se generó con éxito el reporte: ' . $nombreArchivo, 'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}
	//Fin #23

	//Inicio #58
	function generarReporteDeprecAnual(){
		$nombreArchivo = uniqid('RDepreciacionAnualXls'.md5(session_id())).'.xls';

		$dataSource = $this->obtenerDeprecAnual();

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Detalle Dep.Anual';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RDetalleDepreciacionAnualXls($this->objParam);
		$reporte->setMaster($dataSourceMaster);
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function obtenerDeprecAnual(){
		$this->definirFiltros();
		$this->objFunc=$this->create('MODReportes');
		//$data = $this->objFunc->listarReporteDeprecAnual($this->objParam);
		$data = $this->objFunc->listarReporteDeprecAnualGenerado($this->objParam); //#70

		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }
	//Fin #58

	//Inicio #58
	function generarReporteSaldoAf(){
		$nombreArchivo = 'SaldoAf.xls';
		$dataSource = $this->listarReporteSaldoAf();

		//Parámetros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Consolidado';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RSaldoAfXls($this->objParam);
		$reporte->setData($dataSource->datos);
		$reporte->generarReporte();

		$this->mensajeExito = new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function listarReporteSaldoAf(){
		$this->objFunc = $this->create('MODReportes');
		$data = $this->objFunc->listarReporteSaldoAf($this->objParam);

		if($data->getTipo() == 'EXITO') {
			return $data;
		}
        else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

}
?>