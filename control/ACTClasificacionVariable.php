<?php
/**
*@package pXP
*@file gen-ACTClasificacionVariable.php
*@author  (admin)
*@date 27-06-2017 09:34:29
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTClasificacionVariable extends ACTbase{    
			
	function listarClasificacionVariable(){
		$this->objParam->defecto('ordenacion','id_clasificacion_variable');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_clasificacion')!=''){
			$this->objParam->addFiltro("clavar.id_clasificacion = ".$this->objParam->getParametro('id_clasificacion'));
		}

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("clavar.id_clasificacion_variable not in (
    				select id_clasificacion_variable
    				from kaf.tactivo_fijo_caract
    				where id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo').")
					");
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODClasificacionVariable','listarClasificacionVariable');
		} else{
			$this->objFunc=$this->create('MODClasificacionVariable');
			
			$this->res=$this->objFunc->listarClasificacionVariable($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarClasificacionVariable(){
		$this->objFunc=$this->create('MODClasificacionVariable');	
		if($this->objParam->insertar('id_clasificacion_variable')){
			$this->res=$this->objFunc->insertarClasificacionVariable($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarClasificacionVariable($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarClasificacionVariable(){
			$this->objFunc=$this->create('MODClasificacionVariable');	
		$this->res=$this->objFunc->eliminarClasificacionVariable($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>