<?php
/**
*@package pXP
*@file gen-ACTActivoFijoCc.php
*@author  (admin)
*@date 10-05-2019 11:14:58
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
/***************************************************************************
#ISSUE	SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #16	KAF		ETR 		18/06/2019	RCM		Inclusión procedimiento para completar prorrateo con CC por defecto por AF
***************************************************************************/
include_once(dirname(__FILE__).'/../../lib/lib_general/ExcelInput.php');
require_once(dirname(__FILE__).'/../reportes/RLogActivoFijoCcXls.php');
class ACTActivoFijoCc extends ACTbase{

	function listarActivoFijoCc(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_cc');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afccosto.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijoCc','listarActivoFijoCc');
		} else{
			$this->objFunc=$this->create('MODActivoFijoCc');

			$this->res=$this->objFunc->listarActivoFijoCc($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarActivoFijoCc(){
		$this->objFunc=$this->create('MODActivoFijoCc');
		if($this->objParam->insertar('id_activo_fijo_cc')){
			$this->res=$this->objFunc->insertarActivoFijoCc($this->objParam);
		} else{
			$this->res=$this->objFunc->modificarActivoFijoCc($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarActivoFijoCc(){
		$this->objFunc=$this->create('MODActivoFijoCc');
		$this->res=$this->objFunc->eliminarActivoFijoCc($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function ImportarCentroCosto(){
		$arregloFiles = $this->objParam->getArregloFiles();
        $ext = pathinfo($arregloFiles['archivo']['name']);
        $extension = $ext['extension'];
        $error = 'no';
        $mensaje_completo = '';
        $cc=array();

        if(isset($arregloFiles['archivo']) && is_uploaded_file($arregloFiles['archivo']['tmp_name'])) {
            if (!in_array($extension, array('xls', 'xlsx', 'XLS', 'XLSX'))) {
                $mensaje_completo = "La extensión del archivo debe ser XLS o XLSX";
                $error = 'error_fatal';
            } else {
            	$archivoExcel = new ExcelInput($arregloFiles['archivo']['tmp_name'], 'SUBIRCC');
                $archivoExcel->recuperarColumnasExcel();
                $arrayArchivo = $archivoExcel->leerColumnasArchivoExcel();

                //Recorre todo el archivo fila a fila
                $cont=0;
				$nombre_arc=$arregloFiles['archivo']['tmp_name'];
                foreach ($arrayArchivo as $fila) {
                	//if($cont>0){
	                	//Guarda el registro del activo
						$this->objParam->addParametro('activo_fijo',$fila['activo_fijo']);
						$this->objParam->addParametro('mes',$fila['mes']);
						$this->objParam->addParametro('centro_costo',$fila['centro_costo']);
						$this->objParam->addParametro('cantidad_horas',$fila['cantidad_horas']);
						$this->objParam->addParametro('nombre_archivo',$nombre_arc);
						//Guarda el Activo Fijo en la tabla Proyecto Activo
						$this->objFunc = $this->create('MODActivoFijoCc');
	                    $this->res = $this->objFunc->ImportarCentroCosto($this->objParam);
	                   // var_dump($this->res);exit;
	                    if ($this->res->getTipo() == 'ERROR') {
	                    	$this->res->imprimirRespuesta($this->res->generarJson());
				            exit;

	                        $error = 'error';
	                        $mensaje_completo = "Error al guardar el fila en tabla :  " . $this->res->getMensajeTec();
	                        break;
	                    }

                	}
            }
        } else {
            $mensaje_completo = "No se subio el archivo";
            $error = 'error_fatal';
        }



        if ($error == 'error_fatal') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTActivoFijoCc.php',$mensaje_completo,
                $mensaje_completo,'control');
            //si no es error fatal proceso el archivo
        }

        if ($error == 'error') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTActivoFijoCc.php','Ocurrieron los siguientes errores : ' . $mensaje_completo,
                $mensaje_completo,'control');

        } else if ($error == 'no') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('EXITO','ACTActivoFijoCc.php','El archivo fue ejecutado con éxito',
                'El archivo fue ejecutado con éxito','control');
        }

        //devolver respuesta
        $this->mensajeRes->imprimirRespuesta($this->mensajeRes->generarJson());

	}

	function listarLogActivoFijoCc(){
		$this->objParam->defecto('ordenacion','detalle');
		$this->objParam->defecto('dir_ordenacion','desc');


			$this->objFunc=$this->create('MODActivoFijoCc');

			$this->res=$this->objFunc->listarLogActivoFijoCc($this->objParam);

		$this->res->imprimirRespuesta($this->res->generarJson());
	}


		function RLogAFCCXls() {
		$this->objFun=$this->create('MODActivoFijoCc');
		$this->res = $this->objFun->listarLogActivoFijoCc();
		if($this->res->getTipo()=='ERROR'){
			$this->res->imprimirRespuesta($this->res->generarJson());
			exit;
		}
		$titulo ='Cbtes';
		$nombreArchivo=uniqid(md5(session_id()).$titulo);
		$nombreArchivo.='.xls';
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$this->objParam->addParametro('datos',$this->res->datos);
		$this->objReporteFormato=new RLogAFCCXls($this->objParam);
		$this->objReporteFormato->generarDatos();
		$this->objReporteFormato->generarReporte();
		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se genero con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());
	}

	//Inicio #16
	function completarProrrateoCC(){
		$this->objFunc=$this->create('MODActivoFijoCc');
		$this->res=$this->objFunc->completarProrrateoCC($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #16

}
?>