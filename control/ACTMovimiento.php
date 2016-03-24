<?php
/**
*@package pXP
*@file gen-ACTMovimiento.php
*@author  (admin)
*@date 22-10-2015 20:42:41
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
require_once(dirname(__FILE__).'/../../pxp/pxpReport/ReportWriter.php');
require_once (dirname(__FILE__) . '/../reportes/RMovimiento.php');
require_once(dirname(__FILE__).'/../../pxp/pxpReport/DataSource.php');

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

	function listarReporteMovimiento(){
		$this->objParam->defecto('ordenacion','id_movimiento');
		$this->objParam->defecto('dir_ordenacion','asc');

		$this->objFunc=$this->create('MODMovimiento');
		$this->res=$this->objFunc->listarReporteMovimiento($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function generarReporteMovimiento(){
		$idMovimiento = $this->objParam->getParametro('id_movimiento');
		$this->objParam->addParametroConsulta('filtro', ' mov.id_movimiento = ' . $idMovimiento);
		$this->objFunc=$this->create('MODMovimiento');
		$obj = $this->objFunc->listarReporteMovimiento($this->objParam);
		$data = $obj->getDatos();

		//var_dump($data);exit;

		$dataSource = new DataSource();
		$dataSource->setDataSet($data);

		$reporte = new RMovimiento();
		$reporte->setDataSource($dataSource);
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
			
}

?>