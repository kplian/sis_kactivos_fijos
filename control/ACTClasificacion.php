<?php
/**
*@package pXP
*@file gen-ACTClasificacion.php
*@author  (admin)
*@date 09-11-2015 01:22:17
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTClasificacion extends ACTbase{    
			
	function listarClasificacion(){
		$this->objParam->defecto('ordenacion','id_clasificacion');
		$this->objParam->defecto('ordenacion','id_clasificacion');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODClasificacion','listarClasificacion');
		} else{
			$this->objFunc=$this->create('MODClasificacion');
			
			$this->res=$this->objFunc->listarClasificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarClasificacion(){
		$this->objFunc=$this->create('MODClasificacion');	
		if($this->objParam->insertar('id_clasificacion')){
			$this->res=$this->objFunc->insertarClasificacion($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarClasificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarClasificacion(){
			$this->objFunc=$this->create('MODClasificacion');	
		$this->res=$this->objFunc->eliminarClasificacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>