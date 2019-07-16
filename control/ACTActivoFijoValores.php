<?php
/**
*@package pXP
*@file gen-ACTActivoFijoValores.php
*@author  (admin)
*@date 04-05-2016 03:02:26
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2    KAF       ETR           11/01/2019  RCM         Actualización de listado detalle depreciación interfaz
 ***************************************************************************/
class ACTActivoFijoValores extends ACTbase{

	function listarActivoFijoValores(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("actval.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda_dep')!=''){
			$this->objParam->addFiltro("actval.id_moneda_dep = ".$this->objParam->getParametro('id_moneda_dep'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("actval.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoValores','listarActivoFijoValores');
		} else{
			$this->objFunc=$this->create('MODActivoFijoValores');

			$this->res=$this->objFunc->listarActivoFijoValores($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarActivoFijoValores(){
		$this->objFunc=$this->create('MODActivoFijoValores');
		if($this->objParam->insertar('id_activo_fijo_valor')){
			$this->res=$this->objFunc->insertarActivoFijoValores($this->objParam);
		} else{
			$this->res=$this->objFunc->modificarActivoFijoValores($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarActivoFijoValores(){
			$this->objFunc=$this->create('MODActivoFijoValores');
		$this->res=$this->objFunc->eliminarActivoFijoValores($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarActivoFijoValoresArb(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("actval.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("actval.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('fecha')!=''){
			$this->objParam->addFiltro("date_trunc(''month'',mdep.fecha) = date_trunc(''month'',''".$this->objParam->getParametro('fecha')."''::date)");
		}

		$this->objFunc=$this->create('MODActivoFijoValores');
		$this->res=$this->objFunc->listarActivoFijoValoresArb($this->objParam);

		$this->res->setTipoRespuestaArbol();
		$arreglo=array();
		$arreglo_valores=array();

		array_push($arreglo, array('nombre' => 'id', 'valor' => 'id_activo_fijo_valor'));
        array_push($arreglo, array('nombre' => 'id_p', 'valor' => 'id_activo_fijo'));
        array_push($arreglo, array('nombre' => 'text', 'valores' => '[#codigo#]-#tipo#: #valor_neto#'));
        array_push($arreglo, array('nombre' => 'cls', 'valor' => 'tipo'));

        /*Estas funciones definen reglas para los nodos en funcion a los tipo de nodos que contenga cada uno*/
        $this->res->addNivelArbol('tipo_nodo', 'raiz', array('leaf' => false, 'draggable' => true, 'allowDelete' => true, 'allowEdit' => true, 'cls' => 'folder', 'tipo_nodo' => 'raiz', 'icon' => '../../../lib/imagenes/a_form_edit.png'), $arreglo,$arreglo_valores);
        $this->res->addNivelArbol('tipo_nodo', 'hijo', array('leaf' => true, 'draggable' => true, 'allowDelete' => true, 'allowEdit' => true, 'tipo_nodo' => 'hijo', 'icon' => '../../../lib/imagenes/a_form_edit.png'), $arreglo,$arreglo_valores);

        echo $this->res->imprimirRespuesta($this->res->generarJson());
	}

	//Inicio #2: Actualización listado detalle depreciación interfaz
	function listarAfvUltDep(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("dep.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("dep.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoValores','listarAfvUltDep');
		} else{
			$this->objFunc=$this->create('MODActivoFijoValores');

			$this->res=$this->objFunc->listarAfvUltDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarAfvUltVal(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afv.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("afv.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoValores','listarAfvUltVal');
		} else{
			$this->objFunc=$this->create('MODActivoFijoValores');

			$this->res=$this->objFunc->listarAfvUltVal($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #2

}

?>