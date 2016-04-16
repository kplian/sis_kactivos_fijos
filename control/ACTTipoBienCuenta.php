<?php
/**
*@package pXP
*@file gen-ACTTipoBienCuenta.php
*@author  (admin)
*@date 16-04-2016 10:01:08
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTTipoBienCuenta extends ACTbase{    
			
	function listarTipoBienCuenta(){
		$this->objParam->defecto('ordenacion','id_tipo_bien_cuenta');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_tipo_bien')!=''){
			$this->objParam->addFiltro("biecue.id_tipo_bien = ".$this->objParam->getParametro('id_tipo_bien'));	
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODTipoBienCuenta','listarTipoBienCuenta');
		} else{
			$this->objFunc=$this->create('MODTipoBienCuenta');
			
			$this->res=$this->objFunc->listarTipoBienCuenta($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarTipoBienCuenta(){
		$this->objFunc=$this->create('MODTipoBienCuenta');	
		if($this->objParam->insertar('id_tipo_bien_cuenta')){
			$this->res=$this->objFunc->insertarTipoBienCuenta($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarTipoBienCuenta($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarTipoBienCuenta(){
			$this->objFunc=$this->create('MODTipoBienCuenta');	
		$this->res=$this->objFunc->eliminarTipoBienCuenta($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>