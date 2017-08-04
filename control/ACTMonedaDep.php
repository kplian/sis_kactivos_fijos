<?php
/**
*@package pXP
*@file gen-ACTMonedaDep.php
*@author  (admin)
*@date 20-04-2017 10:18:50
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTMonedaDep extends ACTbase{    
			
	function listarMonedaDep(){
		$this->objParam->defecto('ordenacion','id_moneda_dep');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMonedaDep','listarMonedaDep');
		} else{
			$this->objFunc=$this->create('MODMonedaDep');
			
			$this->res=$this->objFunc->listarMonedaDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarMonedaDep(){
		$this->objFunc=$this->create('MODMonedaDep');	
		if($this->objParam->insertar('id_moneda_dep')){
			$this->res=$this->objFunc->insertarMonedaDep($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarMonedaDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarMonedaDep(){
			$this->objFunc=$this->create('MODMonedaDep');	
		$this->res=$this->objFunc->eliminarMonedaDep($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>