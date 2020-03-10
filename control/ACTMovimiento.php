<?php
/**
*@package pXP
*@file gen-ACTMovimiento.php
*@author  (admin)
*@date 22-10-2015 20:42:41
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo

/***************************************************************************
#ISSUE   SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
         KAF     ETR         22-10-2015  RCM     Creación del archivo
 #39     KAF     ETR         22-11-2019  RCM     Reporte detalle depreciación, incluir traspasos
 #38     KAF     ETR         11-12-2019  RCM     Reingeniería importación de plantilla para movimientos especiales
**************************************************************************
*/
require_once(dirname(__FILE__).'/../../pxp/pxpReport/ReportWriter.php');
require_once(dirname(__FILE__).'/../reportes/RMovimiento2.php');
require_once(dirname(__FILE__).'/../reportes/RMovimientoUpdate.php');
require_once(dirname(__FILE__).'/../../pxp/pxpReport/DataSource.php');
require_once(dirname(__FILE__).'/../reportes/RDetalleDepXls.php');
require_once(dirname(__FILE__).'/../reportes/RAsig_Trans_DevAFXls.php');
require_once(dirname(__FILE__).'/../reportes/RDepreciacionMensualXls.php');
include_once(dirname(__FILE__).'/../../lib/lib_general/ExcelInput.php'); //#39

class ACTMovimiento extends ACTbase{

	function listarMovimiento(){
		$this->objParam->defecto('ordenacion','id_movimiento');
		$this->objParam->defecto('dir_ordenacion','desc');

		if($this->objParam->getParametro('cod_movimiento')!=''){
			if($this->objParam->getParametro('cod_movimiento')!='%'){
				$arrFilter = explode(',', $this->objParam->getParametro('cod_movimiento'));
				$filter="(";
				foreach ($arrFilter as $key => $fil) {
					$filter.="''".$fil."''".",";
				}
				$filter = substr($filter, 0, strlen($filter)-1).")";
				$this->objParam->addFiltro("cat.codigo in ".$filter);
			}
		}

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("id_movimiento  in (select id_movimiento from kaf.tmovimiento_af  maf where maf.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo').")");
		}

		if($this->objParam->getParametro('id_movimiento')!=''){
			$this->objParam->addFiltro("id_movimiento = ".$this->objParam->getParametro('id_movimiento'));
		}

		if($this->objParam->getParametro('historico')=='no'){
                        $this->objParam->addFiltro("estado <> ''finalizado''");
                }


		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimiento','listarMovimiento');
		} else{
			$this->objFunc=$this->create('MODMovimiento');

			$this->res=$this->objFunc->listarMovimiento($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarMovimiento(){
		$this->objFunc=$this->create('MODMovimiento');
		if($this->objParam->insertar('id_movimiento')){
			$this->res=$this->objFunc->insertarMovimiento($this->objParam);
		} else{
		$this->res=$this->objFunc->modificarMovimiento($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarMovimiento(){
		$this->objFunc=$this->create('MODMovimiento');
		$this->res=$this->objFunc->eliminarMovimiento($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function generarDetMovimiento(){
		$this->objFunc=$this->create('MODMovimiento');
		$this->res=$this->objFunc->generarDetMovimiento($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarReporteMovimientoMaestro(){
		$this->objFunc=$this->create('MODMovimiento');
		$cbteHeader=$this->objFunc->listarReporteMovimientoMaestro($this->objParam);
		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}

	}

	function listarReporteMovimientoDetalle(){
		$this->objFunc=$this->create('MODMovimiento');
		$cbteHeader=$this->objFunc->listarReporteMovimientoDetalle($this->objParam);
		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}

	}

	 function generarReporteMovimiento(){
	    $nombreArchivo = 'Movimientos'.uniqid(md5(session_id())).'.pdf';

		$obj = $this->listarReporteMovimientoMaestro();
		$objDetalle = $this->listarReporteMovimientoDetalle();

		$dataMaestro = $obj->getDatos();
        $dataDetalle = $objDetalle->getDatos();


		//parametros basicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Consolidado';


		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		//Instancia la clase de pdf
		$reporte = new RMovimiento2($this->objParam);
		$reporte->datosHeader($obj->getDatos(),  $objDetalle->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');
		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}


	function generarReporteMovimiento_bk(){
		$obj = $this->listarReporteMovimientoMaestro();
		$objDetalle = $this->listarReporteMovimientoDetalle();

		$dataMaestro = $obj->getDatos();
        $dataDetalle = $objDetalle->getDatos();



		$reporte = new RMovimiento();
		$reporte->setDataMaster($dataMaestro);
		$reporte->setDataDetalle($dataDetalle);
		$nombreArchivo = 'movimiento_af.pdf';

		$reportWriter = new ReportWriter($reporte, dirname(__FILE__) . '/../../reportes_generados/' . $nombreArchivo);
		$reportWriter->writeReport(ReportWriter::PDF);
		$mensajeExito = new Mensaje();
		$mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->res = $mensajeExito;
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function siguienteEstadoMovimiento(){
        $this->objFunc=$this->create('MODMovimiento');

        $this->objParam->addParametro('id_funcionario_usu',$_SESSION["ss_id_funcionario"]);

        $this->res=$this->objFunc->siguienteEstadoMovimiento($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function anteriorEstadoMovimiento(){
        $this->objFunc=$this->create('MODMovimiento');
        $this->objParam->addParametro('id_funcionario_usu',$_SESSION["ss_id_funcionario"]);
        $this->res=$this->objFunc->anteriorEstadoMovimiento($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }



   function recuperarDetalleDep(){
		$this->objFunc = $this->create('MODMovimiento');
		$cbteHeader = $this->objFunc->listarDatalleDepreciaconReporte($this->objParam);
		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}
    }

	function generarReporteDepreciacion(){

		$nombreArchivo = uniqid(md5(session_id()).'RDetalleDepXls').'.xls';
		$dataSource = $this->recuperarDetalleDep();
		//parametros basicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Consolidado';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RDetalleDepXls($this->objParam);
		$reporte->datosHeader($dataSource->getDatos(), $this->objParam->getParametro('id_movimiento'));
		$reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

	}

	function generarMovimientoRapido(){
		$this->objFunc=$this->create('MODMovimiento');
		$this->res=$this->objFunc->generarMovimientoRapido($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function generarReporteAsig_Trans_DevAFXls(){

		$nombreArchivo = uniqid(md5(session_id()).'RAsig_Trans_DevAFXls').'.xls';

		$obj = $this->listarReporteMovimientoMaestro();
		$objDetalle = $this->listarReporteMovimientoDetalle();

		$dataMaestro = $obj->getDatos();
		$dataDetalle = $objDetalle->getDatos();

		//parametros basicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'AsignacionAF';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);


		$reporte = new RAsig_Trans_DevAFXls($this->objParam);
		$reporte->datosHeader($dataMaestro, $dataDetalle);
		$reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

	}

    function generarReporteMovimientoUpdate(){
        $nombreArchivo = 'Movimientos'.uniqid(md5(session_id())).'.pdf';

        $obj = $this->listarReporteMovimientoMaestro();
        $objDetalle = $this->listarReporteMovimientoDetalle();

        $dataMaestro = $obj->getDatos();
        $dataDetalle = $objDetalle->getDatos();


        //parametros basicos
        $tamano = 'LETTER';
        $orientacion = 'L';
        $titulo = 'Consolidado';


        $this->objParam->addParametro('orientacion',$orientacion);
        $this->objParam->addParametro('tamano',$tamano);
        $this->objParam->addParametro('titulo_archivo',$titulo);
        $this->objParam->addParametro('nombre_archivo',$nombreArchivo);

        //Instancia la clase de pdf
        $reporte = new RMovimientoUpdate($this->objParam);
        $reporte->datosHeader($obj->getDatos(),  $objDetalle->getDatos());
        $reporte->generarReporte();
        $reporte->output($reporte->url_archivo,'F');
        $this->mensajeExito=new Mensaje();
        $this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
        $this->mensajeExito->setArchivoGenerado($nombreArchivo);
        $this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
    }

    function generarReporteDepreciacionMensual(){
		$nombreArchivo = uniqid('RDepreciacionMensualXls'.md5(session_id())).'.xls';
		$dataSourceMaster = $this->obtenerMovimientoID();
		$dataSource = $this->detalleDepreciacionMensual();

		//Parametros básicos
		$tamano = 'LETTER';
		$orientacion = 'L';
		$titulo = 'Detalle Dep.';

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',$tamano);
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$reporte = new RDepreciacionMensualXls($this->objParam);
		$reporte->setMaster($dataSourceMaster->getDatos());
		$reporte->setData($dataSource->getDatos());
		$reporte->generarReporte();

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	function detalleDepreciacionMensual(){
		$this->objFunc = $this->create('MODMovimientoAfDep');
		$data = $this->objFunc->listarDepreciacionMensual($this->objParam);
		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

    function obtenerMovimientoID(){
		$this->objFunc = $this->create('MODMovimiento');
		$data = $this->objFunc->obtenerMovimientoID($this->objParam);
		if($data->getTipo() == 'EXITO'){
			return $data;
		} else {
		    $data->imprimirRespuesta($data->generarJson());
			exit;
		}
    }

    //Inicio #39
    function ImportarDvalAF() {
		$arregloFiles = $this->objParam->getArregloFiles();
        $ext = pathinfo($arregloFiles['archivo']['name']);
        $extension = $ext['extension'];
        $error = 'no';
        $mensaje_completo = '';
        $cod_af_origen = array();
        $ids_movimiento_af = array();

        if(isset($arregloFiles['archivo']) && is_uploaded_file($arregloFiles['archivo']['tmp_name'])) {

            if (!in_array($extension, array('xls', 'xlsx', 'XLS', 'XLSX'))) {

                $mensaje_completo = "La extensión del archivo debe ser XLS o XLSX";
                $error = 'error_fatal';

            } else {

            	$archivoExcel = new ExcelInput($arregloFiles['archivo']['tmp_name'], 'AF-DVALAF');
                $archivoExcel->recuperarColumnasExcel();
                $arrayArchivo = $archivoExcel->leerColumnasArchivoExcel();

                //Elimina los registros de distribución de valores
                $this->objFunc = $this->create('MODMovimientoAf');
                $this->res = $this->objFunc->eliminarMovimientoAfDVal($this->objParam);

                if ($this->res->getTipo() == 'ERROR') {
                	$this->res->imprimirRespuesta($this->res->generarJson());
		            exit;
                }

                //Recorre todo el archivo XLS fila a fila
                $cont = 0;

                //Inicio #38
                foreach ($arrayArchivo as $fila) {

                	if ($cont > 0) {
	                	//Guarda el registro del activo
	                	$this->objParam->addParametro('item', $fila['item']);
						$this->objParam->addParametro('tipo', $fila['tipo_dval']);
						$this->objParam->addParametro('opcion', 'importe');
						$this->objParam->addParametro('porcentaje', 0);
						//$this->objParam->addParametro('importe', $fila['']);
						$this->objParam->addParametro('clasificacion', $fila['clasificacion']);
						$this->objParam->addParametro('denominacion', $fila['denominacion']);
						$this->objParam->addParametro('vida_util_anios', $fila['vida_util_anios']);
						$this->objParam->addParametro('fecha_ini_dep', $fila['fecha_ini_dep']);
						$this->objParam->addParametro('centro_costo', $fila['centro_costo']);
						$this->objParam->addParametro('codigo_almacen', $fila['codigo_almacen']);
						$this->objParam->addParametro('codigo_activo', $fila['codigo_activo']);

						$this->objParam->addParametro('nro_serie', $fila['nro_serie']);
						$this->objParam->addParametro('marca', $fila['marca']);
						$this->objParam->addParametro('descripcion', $fila['descripcion']);
						$this->objParam->addParametro('cantidad_det', $fila['cantidad']);
						$this->objParam->addParametro('unidad', $fila['unidad']);
						$this->objParam->addParametro('ubicacion', $fila['ubicacion']);
						$this->objParam->addParametro('local', $fila['local']);
						$this->objParam->addParametro('responsable', $fila['responsable']);
						$this->objParam->addParametro('fecha_compra', $fila['fecha_compra']);
						$this->objParam->addParametro('moneda', $fila['moneda']);
						$this->objParam->addParametro('grupo_ae', $fila['grupo_ae']);
						$this->objParam->addParametro('clasificacion_ae', $fila['clasificacion_ae']);
						$this->objParam->addParametro('observaciones', $fila['pedido']);
						$this->objParam->addParametro('codigo_af_rel', $fila['codigo_af_rel']);
						$this->objParam->addParametro('codigo_af', $fila['codigo_activo']);


						//Recorre todos los AFs del array y Guarda registro en movimiento af (kaf.tmovimiento9_af)
						$cont_af = 1;
						foreach ($cod_af_origen as $valor) {
							$idMovimientoAf = false;
							//Verificando si es que ya fue registrado previamente
							$idMovimientoAf = array_search($valor, $ids_movimiento_af);

							//Si no existe registra en movimiento af
							if(!$idMovimientoAf && trim($fila["activo_fijo_$cont_af"]) != '') {
								//Registra sólo si tiene un importe
								$this->objParam->addParametro('codigo_activo', $valor);
								$this->objFunc = $this->create('MODMovimientoAf');
	                    		$this->res = $this->objFunc->insertarMovimientoAfImp($this->objParam);

	                    		//Verifica si se produjo algún error
								if ($this->res->getTipo() == 'ERROR') {
			                    	$this->res->imprimirRespuesta($this->res->generarJson());
						            exit;

			                    } else {

			                    	//Recupera el ID MOVIMIENTO AF resultado
			                    	$dat = $this->res->getDatos();
			                    	$idMovimientoAf = $dat['id_movimiento_af'];
			                    	$this->objParam->addParametro('id_movimiento_af', $idMovimientoAf);
			                    	$ids_movimiento_af[$idMovimientoAf] = $valor;

			                    	//Guarda el detalle
			                    	$this->objParam->addParametro('importe', $fila["activo_fijo_$cont_af"]);
                    				$this->objFunc = $this->create('MODMovimientoAfEspecial');
                    				$this->res = $this->objFunc->insertarMovimientoAfEspecialImportar($this->objParam);

			                    	if ($this->res->getTipo() == 'ERROR') {
				                    	$this->res->imprimirRespuesta($this->res->generarJson());
							            exit;
				                    }
			                    }

							} else if($idMovimientoAf && trim($fila["activo_fijo_$cont_af"]) != '') {

								//Guarda el detalle
		                    	$this->objParam->addParametro('importe', $fila["activo_fijo_$cont_af"]);
		                    	$this->objParam->addParametro('id_movimiento_af', $idMovimientoAf); // #38
                				$this->objFunc = $this->create('MODMovimientoAfEspecial');
                				$this->res = $this->objFunc->insertarMovimientoAfEspecialImportar($this->objParam);

		                    	if ($this->res->getTipo() == 'ERROR') {
			                    	$this->res->imprimirRespuesta($this->res->generarJson());
						            exit;
			                    }

							}
							$cont_af++;
						}

                	} else {

                		//Obtiene los códigos de los activos fijos
                		for ($i = 0; $i < 50; $i ++) {

                			if ($fila["activo_fijo_$i"] != '') {
	                			//Guarda los códigos de los activos fijos en variable local
	                    		$cod_af_origen[$i] = $fila["activo_fijo_$i"];
                			}
                    	}
                	}

                	$cont++;
                }
                //Fin #38
            }
        } else {
            $mensaje_completo = "No se subio el archivo";
            $error = 'error_fatal';
        }


        if ($error == 'error_fatal') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTMovimiento.php',$mensaje_completo,
                $mensaje_completo,'control');
            //si no es error fatal proceso el archivo
        }

        if ($error == 'error') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTMovimiento.php','Ocurrieron los siguientes errores : ' . $mensaje_completo,
                $mensaje_completo,'control');

        } else if ($error == 'no') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('EXITO','ACTMovimiento.php','El archivo fue ejecutado con éxito',
                'El archivo fue ejecutado con éxito','control');
        }

        //devolver respuesta
        $this->mensajeRes->imprimirRespuesta($this->mensajeRes->generarJson());

	}
    //Fin #39

}

?>
