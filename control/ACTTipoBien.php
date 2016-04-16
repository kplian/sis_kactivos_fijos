<?php
/**
*@package pXP
*@file gen-ACTTipoBien.php
*@author  (admin)
*@date 16-04-2016 10:00:40
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTTipoBien extends ACTbase{    
			
	function listarTipoBien(){
		$this->objParam->defecto('ordenacion','id_tipo_bien');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODTipoBien','listarTipoBien');
		} else{
			$this->objFunc=$this->create('MODTipoBien');
			
			$this->res=$this->objFunc->listarTipoBien($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarTipoBien(){
		$this->objFunc=$this->create('MODTipoBien');	
		if($this->objParam->insertar('id_tipo_bien')){
			$this->res=$this->objFunc->insertarTipoBien($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarTipoBien($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarTipoBien(){
			$this->objFunc=$this->create('MODTipoBien');	
		$this->res=$this->objFunc->eliminarTipoBien($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>