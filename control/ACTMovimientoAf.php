<?php
/**
*@package pXP
*@file gen-ACTMovimientoAf.php
*@author  (admin)
*@date 18-03-2016 05:34:15
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     KAF       ETR           21/01/2019  RCM         Opción para traspasar valores de un activo fijo a otro
***************************************************************************
*/

class ACTMovimientoAf extends ACTbase{

	function listarMovimientoAf(){
		$this->objParam->defecto('ordenacion','id_movimiento_af');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento')!=''){
			$this->objParam->addFiltro("movaf.id_movimiento = ".$this->objParam->getParametro('id_movimiento'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAf','listarMovimientoAf');
		} else{
			$this->objFunc=$this->create('MODMovimientoAf');

			$this->res=$this->objFunc->listarMovimientoAf($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarMovimientoAf(){
		$this->objFunc=$this->create('MODMovimientoAf');
		if($this->objParam->insertar('id_movimiento_af')){
			$this->res=$this->objFunc->insertarMovimientoAf($this->objParam);
		} else{
			$this->res=$this->objFunc->modificarMovimientoAf($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarMovimientoAf(){
			$this->objFunc=$this->create('MODMovimientoAf');
		$this->res=$this->objFunc->eliminarMovimientoAf($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	//Inicio #2
	function obtenerSaldoDistribucion(){
		$this->objFunc = $this->create('MODMovimientoAf');
		$this->res = $this->objFunc->obtenerSaldoDistribucion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function obtenerMonedaMovEsp(){
		$this->objFunc = $this->create('MODMovimientoAf');
		$this->res = $this->objFunc->obtenerMonedaMovEsp($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #2

}

?>