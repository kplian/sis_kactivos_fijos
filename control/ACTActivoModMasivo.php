<?php
/****************************************************************************************
*@package pXP
*@file gen-ACTActivoModMasivo.php
*@author  (rchumacero)
*@date 09-12-2020 20:34:43
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*****************************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
 #ETR-2778  KAF       ETR           02/02/2021  RCM         Adición de campos para modificación de AFVs
*****************************************************************************************/
include_once(dirname(__FILE__).'/../../lib/lib_general/ExcelInput.php');

class ACTActivoModMasivo extends ACTbase{

    function listarActivoModMasivo(){
		$this->objParam->defecto('ordenacion','id_activo_mod_masivo');
        $this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
            $this->objReporte = new Reporte($this->objParam,$this);
            $this->res = $this->objReporte->generarReporteListado('MODActivoModMasivo','listarActivoModMasivo');
        } else{
        	$this->objFunc=$this->create('MODActivoModMasivo');

        	$this->res=$this->objFunc->listarActivoModMasivo($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function insertarActivoModMasivo(){
        $this->objFunc=$this->create('MODActivoModMasivo');
        if($this->objParam->insertar('id_activo_mod_masivo')){
            $this->res=$this->objFunc->insertarActivoModMasivo($this->objParam);
        } else{
            $this->res=$this->objFunc->modificarActivoModMasivo($this->objParam);
        }
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function eliminarActivoModMasivo(){
        $this->objFunc=$this->create('MODActivoModMasivo');
        $this->res=$this->objFunc->eliminarActivoModMasivo($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function ImportarDatosActualizacion() {
        $arregloFiles = $this->objParam->getArregloFiles();
        $ext = pathinfo($arregloFiles['archivo']['name']);
        $extension = $ext['extension'];
        $error = 'no';
        $mensaje_completo = '';
        $cc = array();

        if(isset($arregloFiles['archivo']) && is_uploaded_file($arregloFiles['archivo']['tmp_name'])) {
            if (!in_array($extension, array('xls', 'xlsx', 'XLS', 'XLSX'))) {
                $mensaje_completo = "La extensión del archivo debe ser XLS o XLSX";
                $error = 'error_fatal';
            } else {
                $archivoExcel = new ExcelInput($arregloFiles['archivo']['tmp_name'], 'AF-DATAUPD');
                $archivoExcel->recuperarColumnasExcel();
                $arrayArchivo = $archivoExcel->leerColumnasArchivoExcel();

                //Elimina los registros previos
                $this->objFunc = $this->create('MODActivoModMasivoDet');
                $this->res = $this->objFunc->eliminarRegistrosExistentes($this->objParam);

                if ($this->res->getTipo() == 'ERROR') {
                    $this->res->imprimirRespuesta($this->res->generarJson());
                    exit;
                }

                //Recorre todo el archivo fila a fila
                $cont = 1;
                foreach ($arrayArchivo as $fila) {
                    //Setea los parámetros enviados
                    $this->objParam->addParametro('codigo', $fila['codigo']);
                    $this->objParam->addParametro('nro_serie', $fila['nro_serie']);
                    $this->objParam->addParametro('marca', $fila['marca']);
                    $this->objParam->addParametro('denominacion', $fila['denominacion']);
                    $this->objParam->addParametro('descripcion', $fila['descripcion']);
                    $this->objParam->addParametro('unidad_medida', $fila['unidad_medida']);
                    $this->objParam->addParametro('observaciones', $fila['observaciones']);
                    $this->objParam->addParametro('ubicacion', $fila['ubicacion']);
                    $this->objParam->addParametro('local', $fila['local']);
                    $this->objParam->addParametro('responsable', $fila['responsable']);
                    $this->objParam->addParametro('proveedor', $fila['proveedor']);
                    $this->objParam->addParametro('fecha_compra', $fila['fecha_compra']);
                    $this->objParam->addParametro('documento', $fila['documento']);
                    $this->objParam->addParametro('cbte_asociado', $fila['cbte_asociado']);
                    $this->objParam->addParametro('fecha_cbte_asociado', $fila['fecha_cbte_asociado']);
                    $this->objParam->addParametro('grupo_ae', $fila['grupo_ae']);
                    $this->objParam->addParametro('clasificador_ae', $fila['clasificador_ae']);
                    $this->objParam->addParametro('centro_costo', $fila['centro_costo']);

                    //Inicio #ETR-2778
                    $this->objParam->addParametro('bs_valor_compra', $fila['bs_valor_compra']);
                    $this->objParam->addParametro('bs_valor_inicial', $fila['bs_valor_inicial']);
                    $this->objParam->addParametro('bs_fecha_ini_dep', $fila['bs_fecha_ini_dep']);
                    $this->objParam->addParametro('bs_vutil_orig', $fila['bs_vutil_orig']);
                    $this->objParam->addParametro('bs_vutil', $fila['bs_vutil']);
                    $this->objParam->addParametro('bs_fult_dep', $fila['bs_fult_dep']);
                    $this->objParam->addParametro('bs_fecha_fin', $fila['bs_fecha_fin']);
                    $this->objParam->addParametro('bs_val_resc', $fila['bs_val_resc']);
                    $this->objParam->addParametro('bs_vact_ini', $fila['bs_vact_ini']);
                    $this->objParam->addParametro('bs_dacum_ini', $fila['bs_dacum_ini']);
                    $this->objParam->addParametro('bs_dper_ini', $fila['bs_dper_ini']);
                    $this->objParam->addParametro('bs_inc', $fila['bs_inc']);
                    $this->objParam->addParametro('bs_inc_sact', $fila['bs_inc_sact']);
                    $this->objParam->addParametro('bs_fechaufv_ini', $fila['bs_fechaufv_ini']);
                    $this->objParam->addParametro('usd_valor_compra', $fila['usd_valor_compra']);
                    $this->objParam->addParametro('usd_valor_inicial', $fila['usd_valor_inicial']);
                    $this->objParam->addParametro('usd_fecha_ini_dep', $fila['usd_fecha_ini_dep']);
                    $this->objParam->addParametro('usd_vutil_orig', $fila['usd_vutil_orig']);
                    $this->objParam->addParametro('usd_vutil', $fila['usd_vutil']);
                    $this->objParam->addParametro('usd_fult_dep', $fila['usd_fult_dep']);
                    $this->objParam->addParametro('usd_fecha_fin', $fila['usd_fecha_fin']);
                    $this->objParam->addParametro('usd_val_resc', $fila['usd_val_resc']);
                    $this->objParam->addParametro('usd_vact_ini', $fila['usd_vact_ini']);
                    $this->objParam->addParametro('usd_dacum_ini', $fila['usd_dacum_ini']);
                    $this->objParam->addParametro('usd_dper_ini', $fila['usd_dper_ini']);
                    $this->objParam->addParametro('usd_inc', $fila['usd_inc']);
                    $this->objParam->addParametro('usd_inc_sact', $fila['usd_inc_sact']);
                    $this->objParam->addParametro('usd_fecha_ufv_ini', $fila['usd_fecha_ufv_ini']);
                    $this->objParam->addParametro('ufv_valor_compra', $fila['ufv_valor_compra']);
                    $this->objParam->addParametro('ufv_valor_inicial', $fila['ufv_valor_inicial']);
                    $this->objParam->addParametro('ufv_fecha_ini_dep', $fila['ufv_fecha_ini_dep']);
                    $this->objParam->addParametro('ufv_vutil_orig', $fila['ufv_vutil_orig']);
                    $this->objParam->addParametro('ufv_vutil', $fila['ufv_vutil']);
                    $this->objParam->addParametro('ufv_fult_dep', $fila['ufv_fult_dep']);
                    $this->objParam->addParametro('ufv_fecha_fin', $fila['ufv_fecha_fin']);
                    $this->objParam->addParametro('ufv_val_resc', $fila['ufv_val_resc']);
                    $this->objParam->addParametro('ufv_vact_ini', $fila['ufv_vact_ini']);
                    $this->objParam->addParametro('ufv_dacum_ini', $fila['ufv_dacum_ini']);
                    $this->objParam->addParametro('ufv_dper_ini', $fila['ufv_dper_ini']);
                    $this->objParam->addParametro('ufv_inc', $fila['ufv_inc']);
                    $this->objParam->addParametro('ufv_inc_sact', $fila['ufv_inc_sact']);
                    $this->objParam->addParametro('ufv_fecha_ufv_ini', $fila['ufv_fecha_ufv_ini']);
                    //Fin #ETR-2778

                    $this->objParam->addParametro('fila', $cont);

                    //Guarda el registro nuevo
                    $this->objFunc = $this->create('MODActivoModMasivoDet');
                    $this->res = $this->objFunc->insertarActivoModMasivoDet($this->objParam);

                    if ($this->res->getTipo() == 'ERROR') {
                        $this->res->imprimirRespuesta($this->res->generarJson());
                        exit;
                    }

                    $cont++;
                }
            }
        } else {
            $mensaje_completo = "Se produjo un problema al subir el archivo";
            $error = 'error_fatal';
        }

        if ($error == 'error_fatal') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTActivoModMasivo.php',$mensaje_completo,
                $mensaje_completo,'control');
            //si no es error fatal proceso el archivo
        }

        if ($error == 'error') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('ERROR','ACTActivoModMasivo.php','Ocurrieron los siguientes errores : ' . $mensaje_completo,
                $mensaje_completo,'control');

        } else if ($error == 'no') {
            $this->mensajeRes=new Mensaje();
            $this->mensajeRes->setMensaje('EXITO','ACTActivoModMasivo.php','El archivo fue ejecutado con éxito',
                'El archivo fue ejecutado con éxito','control');
        }

        //devolver respuesta
        $this->mensajeRes->imprimirRespuesta($this->mensajeRes->generarJson());

    }

    function EjecutarActualizacionDatos() {
        $this->objFunc=$this->create('MODActivoModMasivo');
        $this->res=$this->objFunc->EjecutarActualizacionDatos($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function anteriorEstado(){
        $this->objFunc = $this->create('MODActivoModMasivo');
        $this->objParam->addParametro('id_funcionario_usu', $_SESSION["ss_id_funcionario"]);
        $this->res = $this->objFunc->anteriorEstado($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    function siguienteEstado(){
        $this->objFunc = $this->create('MODActivoModMasivo');
        $this->objParam->addParametro('id_funcionario_usu', $_SESSION["ss_id_funcionario"]);
        $this->res = $this->objFunc->siguienteEstado($this->objParam);
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

}

?>