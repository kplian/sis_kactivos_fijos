<?php
/**
*@package pXP
*@file gen-ACTActivoFijoValores.php
*@author  (admin)
*@date 04-05-2016 03:02:26
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTActivoFijoValores extends ACTbase{    
			
	function listarActivoFijoValores(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("actval.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));	
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoValores','listarActivoFijoValores');
		} else{
			$this->objFunc=$this->create('MODActivoFijoValores');
			
			$this->res=$this->objFunc->listarActivoFijoValores($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarActivoFijoValores(){
		$this->objFunc=$this->create('MODActivoFijoValores');	
		if($this->objParam->insertar('id_activo_fijo_valor')){
			$this->res=$this->objFunc->insertarActivoFijoValores($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarActivoFijoValores($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarActivoFijoValores(){
			$this->objFunc=$this->create('MODActivoFijoValores');	
		$this->res=$this->objFunc->eliminarActivoFijoValores($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>