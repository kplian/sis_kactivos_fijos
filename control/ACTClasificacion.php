<?php
/**
*@package pXP
*@file gen-ACTClasificacion.php
*@author  (admin)
*@date 09-11-2015 01:22:17
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

class ACTClasificacion extends ACTbase{    
			
	function listarClasificacion(){
		$this->objParam->defecto('ordenacion','id_clasificacion');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_clasificacion_fk')!=''){
			$this->objParam->addFiltro("claf.id_clasificacion_fk = ".$this->objParam->getParametro('id_clasificacion_fk'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODClasificacion','listarClasificacion');
		} else{
			$this->objFunc=$this->create('MODClasificacion');
			$this->res=$this->objFunc->listarClasificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
				
	function insertarClasificacion(){
		$this->objFunc=$this->create('MODClasificacion');	
		if($this->objParam->insertar('id_clasificacion')){
			$this->res=$this->objFunc->insertarClasificacion($this->objParam);			
		} else{			
			$this->res=$this->objFunc->modificarClasificacion($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
						
	function eliminarClasificacion(){
		$this->objFunc=$this->create('MODClasificacion');	
		$this->res=$this->objFunc->eliminarClasificacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarClasificacionArb(){
		$this->objParam->defecto('ordenacion','id_clasificacion');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_clasificacion')!=''){
			if($this->objParam->getParametro('id_clasificacion')=='null'){
				$this->objParam->addFiltro("claf.id_clasificacion_fk is null ");
			} else {
				$this->objParam->addFiltro("claf.id_clasificacion_fk = ".$this->objParam->getParametro('id_clasificacion'));	
			}
		} else {
			$this->objParam->addFiltro("claf.id_clasificacion_fk is null ");
		}

		$this->objFunc=$this->create('MODClasificacion');
		$this->res=$this->objFunc->listarClasificacionArb($this->objParam);

		$this->res->setTipoRespuestaArbol();
		$arreglo=array();
		$arreglo_valores=array();

		//para cambiar un valor por otro en una variable
		/*array_push($arreglo_valores,array('variable'=>'checked','val_ant'=>'true','val_nue'=>true));
		array_push($arreglo_valores,array('variable'=>'checked','val_ant'=>'false','val_nue'=>false));
		$this->res->setValores($arreglo_valores);*/

		array_push($arreglo, array('nombre' => 'id', 'valor' => 'id_clasificacion'));
        array_push($arreglo, array('nombre' => 'id_p', 'valor' => 'id_clasificacion_fk'));
        array_push($arreglo, array('nombre' => 'text', 'valores' => '[#codigo_final#]-#nombre#'));
        array_push($arreglo, array('nombre' => 'cls', 'valor' => 'descripcion'));
        array_push($arreglo, array('nombre' => 'qtip', 'valores' => '<b>#codigo_final#</b><br/>#nombre# #descripcion#'));
	
        /*Estas funciones definen reglas para los nodos en funcion a los tipo de nodos que contenga cada uno*/
        $this->res->addNivelArbol('tipo_nodo', 'raiz', array('leaf' => false, 'draggable' => true, 'allowDelete' => true, 'allowEdit' => true, 'cls' => 'folder', 'tipo_nodo' => 'raiz', 'icon' => '../../../lib/imagenes/a_form_edit.png'), $arreglo,$arreglo_valores);
        $this->res->addNivelArbol('tipo_nodo', 'hijo', array('leaf' => false, 'draggable' => true, 'allowDelete' => true, 'allowEdit' => true, 'tipo_nodo' => 'hijo', 'icon' => '../../../lib/imagenes/a_form_edit.png'), $arreglo,$arreglo_valores);
        
        echo $this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarClasificacionTree(){
		$this->objParam->defecto('ordenacion','orden');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODClasificacion','listarClasificacionTree');
		} else{
			$this->objFunc=$this->create('MODClasificacion');
			$this->res=$this->objFunc->listarClasificacionTree($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
			
}

?>