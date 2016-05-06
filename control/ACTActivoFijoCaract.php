<?php
/**
*@package pXP
*@file gen-ACTActivoFijoCaract.php
*@author  (admin)
*@date 17-04-2016 07:14:58
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTActivoFijoCaract extends ACTbase{    
			
	function listarActivoFijoCaract(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_caract');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afcaract.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));	
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoCaract','listarActivoFijoCaract');
		} else{
			$this->objFunc=$this->create('MODActivoFijoCaract');
			
			$this->res=$this->objFunc->listarActivoFijoCaract($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarActivoFijoCaract(){
		$this->objFunc=$this->create('MODActivoFijoCaract');	
		if($this->objParam->insertar('id_activo_fijo_caract')){
			$this->res=$this->objFunc->insertarActivoFijoCaract($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarActivoFijoCaract($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarActivoFijoCaract(){
			$this->objFunc=$this->create('MODActivoFijoCaract');	
		$this->res=$this->objFunc->eliminarActivoFijoCaract($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarCaractFiltro(){
		$this->objParam->defecto('ordenacion','clave');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoCaract','listarCaractFiltro');
		} else{
			$this->objFunc=$this->create('MODActivoFijoCaract');
			
			$this->res=$this->objFunc->listarCaractFiltro($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>