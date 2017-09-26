<?php
/**
*@package pXP
*@file gen-ACTMovimientoAfEspecial.php
*@author  (admin)
*@date 23-06-2017 08:21:47
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTMovimientoAfEspecial extends ACTbase{    
			
	function listarMovimientoAfEspecial(){
		$this->objParam->defecto('ordenacion','id_movimiento_af_especial');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento_af')!=''){
			$this->objParam->addFiltro("movesp.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfEspecial','listarMovimientoAfEspecial');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfEspecial');
			
			$this->res=$this->objFunc->listarMovimientoAfEspecial($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarMovimientoAfEspecial(){
		$this->objFunc=$this->create('MODMovimientoAfEspecial');	
		if($this->objParam->insertar('id_movimiento_af_especial')){
			$this->res=$this->objFunc->insertarMovimientoAfEspecial($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarMovimientoAfEspecial($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarMovimientoAfEspecial(){
		$this->objFunc=$this->create('MODMovimientoAfEspecial');	
		$this->res=$this->objFunc->eliminarMovimientoAfEspecial($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarMovimientoAfEspecialPorActivo(){
		$this->objFunc=$this->create('MODMovimientoAfEspecial');	
		$this->res=$this->objFunc->eliminarMovimientoAfEspecialPorActivo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>