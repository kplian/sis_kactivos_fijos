<?php
/**
*@package pXP
*@file gen-ACTUbicacion.php
*@author  (admin)
*@date 15-06-2018 15:08:40
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTUbicacion extends ACTbase{    
			
	function listarUbicacion(){
		$this->objParam->defecto('ordenacion','id_ubicacion');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODUbicacion','listarUbicacion');
		} else{
			$this->objFunc=$this->create('MODUbicacion');
			
			$this->res=$this->objFunc->listarUbicacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarUbicacion(){
		$this->objFunc=$this->create('MODUbicacion');	
		if($this->objParam->insertar('id_ubicacion')){
			$this->res=$this->objFunc->insertarUbicacion($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarUbicacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarUbicacion(){
			$this->objFunc=$this->create('MODUbicacion');	
		$this->res=$this->objFunc->eliminarUbicacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>