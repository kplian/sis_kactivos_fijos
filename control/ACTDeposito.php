<?php
/**
*@package pXP
*@file gen-ACTDeposito.php
*@author  (admin)
*@date 09-11-2015 03:27:12
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTDeposito extends ACTbase{    
			
	function listarDeposito(){
		$this->objParam->defecto('ordenacion','id_deposito');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("depaf.id_depto = ".$this->objParam->getParametro('id_depto'));	
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODDeposito','listarDeposito');
		} else{
			$this->objFunc=$this->create('MODDeposito');
			
			$this->res=$this->objFunc->listarDeposito($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarDeposito(){
		$this->objFunc=$this->create('MODDeposito');	
		if($this->objParam->insertar('id_deposito')){
			$this->res=$this->objFunc->insertarDeposito($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarDeposito($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarDeposito(){
			$this->objFunc=$this->create('MODDeposito');	
		$this->res=$this->objFunc->eliminarDeposito($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>