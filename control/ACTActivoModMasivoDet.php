<?php
/****************************************************************************************
*@package pXP
*@file gen-ACTActivoModMasivoDet.php
*@author  (rchumacero)
*@date 09-12-2020 20:36:35
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo

 HISTORIAL DE MODIFICACIONES:
 #ISSUE                FECHA                AUTOR                DESCRIPCION
  #0                09-12-2020 20:36:35    rchumacero             Creacion
  #
*****************************************************************************************/

class ACTActivoModMasivoDet extends ACTbase{

    function listarActivoModMasivoDet(){
		$this->objParam->defecto('ordenacion','id_activo_mod_masivo_det');
        $this->objParam->defecto('dir_ordenacion','asc');

        if($this->objParam->getParametro('id_activo_mod_masivo')!=''){
            $this->objParam->addFiltro("amd.id_activo_mod_masivo = ".$this->objParam->getParametro('id_activo_mod_masivo'));
        }

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODActivoModMasivoDet','listarActivoModMasivoDet');
        } else{
        	$this->objFunc=$this->create('MODActivoModMasivoDet');

        	$this->res=$this->objFunc->listarActivoModMasivoDet($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarActivoModMasivoDet(){
        $this->objFunc=$this->create('MODActivoModMasivoDet');
        if($this->objParam->insertar('id_activo_mod_masivo_det')){
            $this->res=$this->objFunc->insertarActivoModMasivoDet($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarActivoModMasivoDet($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarActivoModMasivoDet(){
        	$this->objFunc=$this->create('MODActivoModMasivoDet');
        $this->res=$this->objFunc->eliminarActivoModMasivoDet($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

}

?>