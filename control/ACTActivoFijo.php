<?php
/**
*@package pXP
*@file gen-ACTActivoFijo.php
*@author  (admin)
*@date 29-10-2015 03:18:45
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTActivoFijo extends ACTbase{    
			
	function listarActivoFijo(){
		$this->objParam->defecto('ordenacion','id_activo_fijo');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('col_filter_panel')!=''){
			$colFilter = $this->objParam->getParametro('col_filter_panel');
			if($colFilter=='id_depto'){
				$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_filter_panel'));
			} else if($colFilter=='id_clasificacion'){
				$this->objParam->addFiltro("afij.id_clasificacion in (
					WITH RECURSIVE t(id,id_fk,nombre,n) AS (
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
    				FROM alm.tclasificacion l
    				WHERE l.id_clasificacion = ".$this->objParam->getParametro('id_filter_panel')."
    				UNION ALL
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
    				FROM alm.tclasificacion l, t
    				WHERE l.id_clasificacion_fk = t.id
					)
					SELECT id
					FROM t)");

			} else if($colFilter=='id_oficina'){
				$this->objParam->addFiltro("afij.id_oficina = ".$this->objParam->getParametro('id_filter_panel'));
			}
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijo','listarActivoFijo');
		} else{
			$this->objFunc=$this->create('MODActivoFijo');
			
			$this->res=$this->objFunc->listarActivoFijo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarActivoFijo(){
		$this->objFunc=$this->create('MODActivoFijo');	
		if($this->objParam->insertar('id_activo_fijo')){
			$this->res=$this->objFunc->insertarActivoFijo($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarActivoFijo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarActivoFijo(){
			$this->objFunc=$this->create('MODActivoFijo');	
		$this->res=$this->objFunc->eliminarActivoFijo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>