<?php
/**
*@package pXP
*@file gen-ACTMovimientoMotivo.php
*@author  (admin)
*@date 18-03-2016 07:25:59
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTMovimientoMotivo extends ACTbase{    
			
	function listarMovimientoMotivo(){
		$this->objParam->defecto('ordenacion','id_movimiento_motivo');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_cat_movimiento')!=''){
			$this->objParam->addFiltro("mmot.id_cat_movimiento = ".$this->objParam->getParametro('id_cat_movimiento'));	
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoMotivo','listarMovimientoMotivo');
		} else{
			$this->objFunc=$this->create('MODMovimientoMotivo');
			
			$this->res=$this->objFunc->listarMovimientoMotivo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarMovimientoMotivo(){
		$this->objFunc=$this->create('MODMovimientoMotivo');	
		if($this->objParam->insertar('id_movimiento_motivo')){
			$this->res=$this->objFunc->insertarMovimientoMotivo($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarMovimientoMotivo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarMovimientoMotivo(){
			$this->objFunc=$this->create('MODMovimientoMotivo');	
		$this->res=$this->objFunc->eliminarMovimientoMotivo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>