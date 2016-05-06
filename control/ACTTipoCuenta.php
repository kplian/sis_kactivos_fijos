<?php
/**
*@package pXP
*@file gen-ACTTipoCuenta.php
*@author  (admin)
*@date 16-04-2016 10:01:04
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTTipoCuenta extends ACTbase{    
			
	function listarTipoCuenta(){
		$this->objParam->defecto('ordenacion','id_tipo_cuenta');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODTipoCuenta','listarTipoCuenta');
		} else{
			$this->objFunc=$this->create('MODTipoCuenta');
			
			$this->res=$this->objFunc->listarTipoCuenta($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarTipoCuenta(){
		$this->objFunc=$this->create('MODTipoCuenta');	
		if($this->objParam->insertar('id_tipo_cuenta')){
			$this->res=$this->objFunc->insertarTipoCuenta($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarTipoCuenta($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarTipoCuenta(){
			$this->objFunc=$this->create('MODTipoCuenta');	
		$this->res=$this->objFunc->eliminarTipoCuenta($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>