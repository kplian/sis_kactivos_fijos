<?php
/**
*@package pXP
*@file gen-ACTClasificacionCuentaMotivo.php
*@author  (admin)
*@date 15-08-2017 17:28:50
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTClasificacionCuentaMotivo extends ACTbase{    
			
	function listarClasificacionCuentaMotivo(){
		$this->objParam->defecto('ordenacion','id_clasificacion_cuenta_motivo');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento_motivo')!=''){
			$this->objParam->addFiltro("clacue.id_movimiento_motivo = ".$this->objParam->getParametro('id_movimiento_motivo'));
		}		

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODClasificacionCuentaMotivo','listarClasificacionCuentaMotivo');
		} else{
			$this->objFunc=$this->create('MODClasificacionCuentaMotivo');
			
			$this->res=$this->objFunc->listarClasificacionCuentaMotivo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarClasificacionCuentaMotivo(){
		$this->objFunc=$this->create('MODClasificacionCuentaMotivo');	
		if($this->objParam->insertar('id_clasificacion_cuenta_motivo')){
			$this->res=$this->objFunc->insertarClasificacionCuentaMotivo($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarClasificacionCuentaMotivo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarClasificacionCuentaMotivo(){
			$this->objFunc=$this->create('MODClasificacionCuentaMotivo');	
		$this->res=$this->objFunc->eliminarClasificacionCuentaMotivo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>