<?php
/**
*@package pXP
*@file gen-ACTMovimientoTipo.php
*@author  (admin)
*@date 23-03-2016 05:18:37
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTMovimientoTipo extends ACTbase{    
			
	function listarMovimientoTipo(){
		$this->objParam->defecto('ordenacion','id_movimiento_tipo');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoTipo','listarMovimientoTipo');
		} else{
			$this->objFunc=$this->create('MODMovimientoTipo');
			
			$this->res=$this->objFunc->listarMovimientoTipo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarMovimientoTipo(){
		$this->objFunc=$this->create('MODMovimientoTipo');	
		if($this->objParam->insertar('id_movimiento_tipo')){
			$this->res=$this->objFunc->insertarMovimientoTipo($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarMovimientoTipo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarMovimientoTipo(){
			$this->objFunc=$this->create('MODMovimientoTipo');	
		$this->res=$this->objFunc->eliminarMovimientoTipo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>