<?php
/**
*@package pXP
*@file gen-ACTMonedaDep.php
*@author  (admin)
*@date 20-04-2017 10:18:50
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           20/04/2017  RCM         Creación del archivo
 #35    KAF       ETR           27/12/2019  RCM         Creación método para encontrar id_moneda_dep a partir de una moneda
***************************************************************************
*/

class ACTMonedaDep extends ACTbase{

	function listarMonedaDep(){
		$this->objParam->defecto('ordenacion','id_moneda_dep');

		$this->objParam->defecto('dir_ordenacion','asc');
		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMonedaDep','listarMonedaDep');
		} else{
			$this->objFunc=$this->create('MODMonedaDep');

			$this->res=$this->objFunc->listarMonedaDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarMonedaDep(){
		$this->objFunc=$this->create('MODMonedaDep');
		if($this->objParam->insertar('id_moneda_dep')){
			$this->res=$this->objFunc->insertarMonedaDep($this->objParam);
		} else{
			$this->res=$this->objFunc->modificarMonedaDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarMonedaDep(){
		$this->objFunc=$this->create('MODMonedaDep');
		$this->res=$this->objFunc->eliminarMonedaDep($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	//Inicio #35
	function obtenerMonedaDep(){
		$this->objFunc=$this->create('MODMonedaDep');
		$this->res=$this->objFunc->obtenerMonedaDep($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//fin #35

}

?>