<?php
/****************************************************************************************
*@package pXP
*@file ACTActivoModMasivoDetOriginal.php
*@author (rchumacero)
*@date 10-12-2020 03:43:46
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*****************************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
*****************************************************************************************/

class ACTActivoModMasivoDetOriginal extends ACTbase{

    function listarActivoModMasivoDetOriginal(){
		$this->objParam->defecto('ordenacion','id_activo_mod_masivo_det_original');
        $this->objParam->defecto('dir_ordenacion','asc');

        if($this->objParam->getParametro('id_activo_mod_masivo_det')!=''){
            $this->objParam->addFiltro("mador.id_activo_mod_masivo_det = ".$this->objParam->getParametro('id_activo_mod_masivo_det'));
        }

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODActivoModMasivoDetOriginal','listarActivoModMasivoDetOriginal');
        } else{
        	$this->objFunc=$this->create('MODActivoModMasivoDetOriginal');

        	$this->res=$this->objFunc->listarActivoModMasivoDetOriginal($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarActivoModMasivoDetOriginal(){
        $this->objFunc=$this->create('MODActivoModMasivoDetOriginal');
        if($this->objParam->insertar('id_activo_mod_masivo_det_original')){
            $this->res=$this->objFunc->insertarActivoModMasivoDetOriginal($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarActivoModMasivoDetOriginal($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarActivoModMasivoDetOriginal(){
        	$this->objFunc=$this->create('MODActivoModMasivoDetOriginal');
        $this->res=$this->objFunc->eliminarActivoModMasivoDetOriginal($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

}

?>