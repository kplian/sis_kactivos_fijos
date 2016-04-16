<?php
/**
*@package pXP
*@file gen-ACTMovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTMovimientoAfDep extends ACTbase{    
			
	function listarMovimientoAfDep(){
		$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento_af')!=''){
			$this->objParam->addFiltro("mafdep.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
		}


		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarMovimientoAfDep');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');
			
			$this->res=$this->objFunc->listarMovimientoAfDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarMovimientoAfDep(){
		$this->objFunc=$this->create('MODMovimientoAfDep');	
		if($this->objParam->insertar('id_movimiento_af_dep')){
			$this->res=$this->objFunc->insertarMovimientoAfDep($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarMovimientoAfDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarMovimientoAfDep(){
			$this->objFunc=$this->create('MODMovimientoAfDep');	
		$this->res=$this->objFunc->eliminarMovimientoAfDep($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>