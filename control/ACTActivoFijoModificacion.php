<?php
/**
*@package pXP
*@file gen-ACTActivoFijoModificacion.php
*@author  (admin)
*@date 23-08-2017 14:14:25
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTActivoFijoModificacion extends ACTbase{    
			
	function listarActivoFijoModificacion(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_modificacion');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("kafmod.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoModificacion','listarActivoFijoModificacion');
		} else{
			$this->objFunc=$this->create('MODActivoFijoModificacion');
			
			$this->res=$this->objFunc->listarActivoFijoModificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarActivoFijoModificacion(){
		$this->objFunc=$this->create('MODActivoFijoModificacion');	
		if($this->objParam->insertar('id_activo_fijo_modificacion')){
			$this->res=$this->objFunc->insertarActivoFijoModificacion($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarActivoFijoModificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarActivoFijoModificacion(){
			$this->objFunc=$this->create('MODActivoFijoModificacion');	
		$this->res=$this->objFunc->eliminarActivoFijoModificacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>