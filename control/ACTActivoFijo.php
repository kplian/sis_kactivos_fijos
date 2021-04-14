<?php
/**
*@package pXP
*@file gen-ACTActivoFijo.php
*@author  (admin)
*@date 29-10-2015 03:18:45
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo

***************************************************************************
 ISSUE  	SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #2     	KAF       ETR           22/05/2019  RCM         Se aumenta consulta para obtener los datos más actuales de los activos fijos
 #18    	KAF       ETR           15/07/2019  RCM         Corrección de filtro por característica
 #ETR-2116	KAF 	  ETR 			11/12/2020	RCM 		Modificación de formato de reporte de etiqueta, adición de parámetro Local
 #ETR-3627	KAF 	  ETR 			12/04/2021	RCM 		Adición de filtro para imprimir por movimiento y por proyecto
***************************************************************************
*/
require_once(dirname(__FILE__).'/../reportes/RCodigoQRAF.php');
require_once(dirname(__FILE__).'/../reportes/RCodigoQRAF_v1.php');
header('Content-Type: text/html; charset=utf-8');

class ACTActivoFijo extends ACTbase{

	function listarActivoFijo(){
		$this->objParam->defecto('ordenacion','id_activo_fijo');
		$this->objParam->defecto('dir_ordenacion','asc');

		//General filter by: depto, clasificacion, oficina, organigrama
		if($this->objParam->getParametro('col_filter_panel')!=''){
			$colFilter = $this->objParam->getParametro('col_filter_panel');
			if($colFilter=='id_depto'){
				$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_filter_panel'));
			} else if($colFilter=='id_clasificacion'){
				$this->objParam->addFiltro("afij.id_clasificacion in (
					WITH RECURSIVE t(id,id_fk,nombre,n) AS (
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
    				FROM kaf.tclasificacion l
    				WHERE l.id_clasificacion = ".$this->objParam->getParametro('id_filter_panel')."
    				UNION ALL
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
    				FROM kaf.tclasificacion l, t
    				WHERE l.id_clasificacion_fk = t.id
					)
					SELECT id
					FROM t)");

			} else if($colFilter=='id_oficina'){
				$this->objParam->addFiltro("afij.id_oficina = ".$this->objParam->getParametro('id_filter_panel'));
			} else if($colFilter=='id_uo'){
				$this->objParam->addFiltro("uo.id_uo in (
					WITH RECURSIVE t(id,id_fk,n) AS (
					SELECT l.id_uo_hijo,l.id_uo_padre,1
					FROM orga.testructura_uo l
					WHERE l.id_uo_hijo = ".$this->objParam->getParametro('id_filter_panel')."
					UNION ALL
					SELECT l.id_uo_hijo,l.id_uo_padre,n+1
					FROM orga.testructura_uo l, t
					WHERE l.id_uo_padre = t.id
					)
					SELECT id
					FROM t)");

			} else if($colFilter=='id_ubicacion'){
				$this->objParam->addFiltro("afij.id_ubicacion = ".$this->objParam->getParametro('id_filter_panel'));
			}

			//Por caracteristicas
			if($this->objParam->getParametro('caractFilter')!=''&&$this->objParam->getParametro('caractValue')!=''){
				$this->objParam->addFiltro("afij.id_activo_fijo in (select id_activo_fijo
																	from kaf.tactivo_fijo_caract acar
																	inner join kaf.tclasificacion_variable cv
																	on cv.id_clasificacion_variable = acar.id_clasificacion_variable
																	where cv.nombre ilike ''%".$this->objParam->getParametro('caractFilter')."%''
																	and acar.valor ilike ''%".$this->objParam->getParametro('caractValue')."%'')"); //#18 Corrección del filtro
			}
		}

		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto'));
		}
		if($this->objParam->getParametro('estado')!=''){
			$this->objParam->addFiltro("afij.estado = ''".$this->objParam->getParametro('estado')."''");
		}

		if($this->objParam->getParametro('depreciable')!=''){
			$this->objParam->addFiltro("cla.depreciable = ''".$this->objParam->getParametro('depreciable')."''");
		}

		if($this->objParam->getParametro('en_deposito')!=''){
			$this->objParam->addFiltro("afij.en_deposito = ''".$this->objParam->getParametro('en_deposito')."''");
		}
		if($this->objParam->getParametro('id_funcionario')!=''){
			$this->objParam->addFiltro("afij.id_funcionario = ".$this->objParam->getParametro('id_funcionario'));
		}

		//Por caracteristicas
		if($this->objParam->getParametro('caractFilter')!=''&&$this->objParam->getParametro('caractValue')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo in (select id_activo_fijo
																from kaf.tactivo_fijo_caract acar
																inner join kaf.tclasificacion_variable cv
																on cv.id_clasificacion_variable = acar.id_clasificacion_variable
																where cv.nombre ilike ''%".$this->objParam->getParametro('caractFilter')."%''
																and acar.valor ilike ''%".$this->objParam->getParametro('caractValue')."%'')"); //#18 Corrección del filtro
		}

		//Si es abierto desde link de otra grilla
		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		//Filtro por movimientos
		//Transferencia, Devolucion
		if($this->objParam->getParametro('codMov')=='transf'||$this->objParam->getParametro('codMov')=='devol'){
			$this->objParam->addFiltro("afij.id_funcionario = ".$this->objParam->getParametro('id_funcionario_mov'));
		}
		//Alta
		if($this->objParam->getParametro('codMov')=='alta'|| $this->objParam->getParametro('codMov')=='baja'|| $this->objParam->getParametro('codMov')=='reval'|| $this->objParam->getParametro('codMov')=='deprec'|| $this->objParam->getParametro('codMov')=='actua'||$this->objParam->getParametro('codMov')=='desuso'||$this->objParam->getParametro('codMov')=='incdec'||$this->objParam->getParametro('codMov')=='tranfdep'){
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto_mov'));
			$this->objParam->addFiltro("afij.estado = "."''".$this->objParam->getParametro('estado_mov')."''");
		}
		if($this->objParam->getParametro('codMov')=='asig'){
			$this->objParam->addFiltro("afij.en_deposito = ''".$this->objParam->getParametro('en_deposito_mov')."''");
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto_mov'));
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

	function codificarActivoFijo(){
		$this->objFunc=$this->create('MODActivoFijo');
		$this->res=$this->objFunc->codificarActivoFijo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function seleccionarActivosFijos(){
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

		$this->objFunc=$this->create('MODActivoFijo');
		$this->res=$this->objFunc->seleccionarActivosFijos($this->objParam);

		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function subirFoto(){
        $this->objFunc=$this->create('MODActivoFijo');
        $this->res=$this->objFunc->SubirFoto();
        $this->res->imprimirRespuesta($this->res->generarJson());
    }

    /*
	 *
	 * Autor: RAC
	 * Fecha: 16/03/2017
	 * Descrip:  Imprime codigo de activo fijos de  uno en uno
	 *
	 *
	 * */

    function recuperarCodigoQR(){
		$this->objFunc = $this->create('MODActivoFijo');
		$cbteHeader = $this->objFunc->recuperarCodigoQR($this->objParam);
		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}

    }


    function impCodigoActivoFijo(){

	    $nombreArchivo = 'CodigoAF'.uniqid(md5(session_id())).'.pdf';
		$dataSource = $this->recuperarCodigoQR();

		//parametros basicos
		$orientacion = 'L';
		$titulo = 'Códigos Activos Fijos';

        $width = 210; //ETR-2116
        $height = 80;

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',array($width, $height));
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);

		$clsRep = $dataSource->getDatos();

		eval('$reporte = new '.$clsRep['v_clase_reporte'].'($this->objParam);');

		$reporte->datosHeader( 'unico', $dataSource->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

	}

    /*
	 *
	 * Autor: RAC
	 * Fecha: 16/03/2017
	 * Descrip:  Imprime codigos de activo fijos dsegun elc riterio de filtro, varios a la vez
	 *
	 *
	 * */

     function recuperarListadoCodigosQR(){
		$this->objFunc = $this->create('MODActivoFijo');
		$cbteHeader = $this->objFunc->recuperarListadoCodigosQR($this->objParam);
		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}

    }

	 function obtenerClaseReporteCodigoQRAF(){
		//crea el objetoFunSeguridad que contiene todos los metodos del sistema de seguridad

		$this->objParam->addParametro('codigo','kaf_clase_reporte_codigo');
		$this->objFunSeguridad=$this->create('sis_seguridad/MODSubsistema');



		$cbteHeader=$this->objFunSeguridad->obtenerVariableGlobal($this->objParam);

		if($cbteHeader->getTipo() == 'EXITO'){
			return $cbteHeader;
		}
        else{
		    $cbteHeader->imprimirRespuesta($cbteHeader->generarJson());
			exit;
		}

	}


    function impVariosCodigoActivoFijo(){

	    $nombreArchivo = 'CodigoAF'.uniqid(md5(session_id())).'.pdf';
		$dataSource = $this->recuperarListadoCodigosQR();

		//recuperar variable global kaf_clase_reporte_codigo
		$clsQr = $this->obtenerClaseReporteCodigoQRAF();
		//parametros basicos

		$orientacion = 'L';
		$titulo = 'Código';

		//$width = 40;
        //$height = 20;

        $width = 160;
        $height = 80;

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',array($width, $height));
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);
		//var_dump($dataSource->getDatos());
		//exit;
		$cls = $clsQr->getDatos();

		//$reporte = new RCodigoQRAF($this->objParam);

		eval('$reporte = new '.$cls['valor'].'($this->objParam);');



		$reporte->datosHeader( 'varios', $dataSource->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');


		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

	}

	function clonarActivoFijo(){
		$this->objFunc=$this->create('MODActivoFijo');
		$this->res=$this->objFunc->clonarActivoFijo($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarActivoFijoFecha(){
		$this->objParam->defecto('ordenacion','id_activo_fijo');
		$this->objParam->defecto('dir_ordenacion','asc');

		//General filter by: depto, clasificacion, oficina, organigrama
		if($this->objParam->getParametro('col_filter_panel')!=''){
			$colFilter = $this->objParam->getParametro('col_filter_panel');
			if($colFilter=='id_depto'){
				$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_filter_panel'));
			} else if($colFilter=='id_clasificacion'){
				$this->objParam->addFiltro("afij.id_clasificacion in (
					WITH RECURSIVE t(id,id_fk,nombre,n) AS (
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
    				FROM kaf.tclasificacion l
    				WHERE l.id_clasificacion = ".$this->objParam->getParametro('id_filter_panel')."
    				UNION ALL
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
    				FROM kaf.tclasificacion l, t
    				WHERE l.id_clasificacion_fk = t.id
					)
					SELECT id
					FROM t)");

			} else if($colFilter=='id_oficina'){
				$this->objParam->addFiltro("afij.id_oficina = ".$this->objParam->getParametro('id_filter_panel'));
			}

			//Por caracteristicas
			if($this->objParam->getParametro('caractFilter')!=''&&$this->objParam->getParametro('caractValue')!=''){
				$this->objParam->addFiltro("afij.id_activo_fijo in (select id_activo_fijo from kaf.tactivo_fijo_caract acar where acar.clave like ''%".$this->objParam->getParametro('caractFilter')."%'' and acar.valor like ''%".$this->objParam->getParametro('caractValue')."%'')");
			}
		}

		if($this->objParam->getParametro('id_depto')!=''){
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto'));
		}
		if($this->objParam->getParametro('estado')!=''){
			$this->objParam->addFiltro("afij.estado = ''".$this->objParam->getParametro('estado')."''");
		}

		if($this->objParam->getParametro('depreciable')!=''){
			$this->objParam->addFiltro("cla.depreciable = ''".$this->objParam->getParametro('depreciable')."''");
		}

		if($this->objParam->getParametro('en_deposito')!=''){
			$this->objParam->addFiltro("afij.en_deposito = ''".$this->objParam->getParametro('en_deposito')."''");
		}
		if($this->objParam->getParametro('id_funcionario')!=''){
			$this->objParam->addFiltro("afij.id_funcionario = ".$this->objParam->getParametro('id_funcionario'));
		}

		//Por caracteristicas
		if($this->objParam->getParametro('caractFilter')!=''&&$this->objParam->getParametro('caractValue')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo in (select id_activo_fijo from kaf.tactivo_fijo_caract acar where acar.clave like ''%".$this->objParam->getParametro('caractFilter')."%'' and acar.valor like ''%".$this->objParam->getParametro('caractValue')."%'')");
		}
		//Inicio #36
		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afij.id_activo_fijo = ''".$this->objParam->getParametro('id_activo_fijo')."''");
		}
		//Fin #36

		//Filtro por movimientos
		//Transferencia, Devolucion
		if($this->objParam->getParametro('codMov')=='transf'||$this->objParam->getParametro('codMov')=='devol'){
			$this->objParam->addFiltro("afij.id_funcionario = ".$this->objParam->getParametro('id_funcionario_mov'));
		}
		//Alta
		if($this->objParam->getParametro('codMov')=='alta'|| $this->objParam->getParametro('codMov')=='baja'|| $this->objParam->getParametro('codMov')=='reval'|| $this->objParam->getParametro('codMov')=='deprec'|| $this->objParam->getParametro('codMov')=='actua'||$this->objParam->getParametro('codMov')=='desuso'||$this->objParam->getParametro('codMov')=='incdec'||$this->objParam->getParametro('codMov')=='tranfdep'){
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto_mov'));
			$this->objParam->addFiltro("afij.estado = "."''".$this->objParam->getParametro('estado_mov')."''");
		}
		if($this->objParam->getParametro('codMov')=='asig'){
			$this->objParam->addFiltro("afij.en_deposito = ''".$this->objParam->getParametro('en_deposito_mov')."''");
			$this->objParam->addFiltro("afij.id_depto = ".$this->objParam->getParametro('id_depto_mov'));
		}



		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijo','listarActivoFijoFecha');
		} else{
			$this->objFunc=$this->create('MODActivoFijo');

			$this->res=$this->objFunc->listarActivoFijoFecha($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function consultaQR(){
		$this->objFunc=$this->create('MODActivoFijo');
		$this->res=$this->objFunc->consultaQR($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function repCodigoQRVarios(){
		$nombreArchivo = 'CodigoAF'.uniqid(md5(session_id())).'.pdf';

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("kaf.id_activo_fijo in (".$this->objParam->getParametro('id_activo_fijo').")");
		}

		if($this->objParam->getParametro('id_clasificacion')!=''){
			$this->objParam->addFiltro("kaf.id_clasificacion in (
					WITH RECURSIVE t(id,id_fk,nombre,n) AS (
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,1
    				FROM kaf.tclasificacion l
    				WHERE l.id_clasificacion = ".$this->objParam->getParametro('id_clasificacion')."
    				UNION ALL
    				SELECT l.id_clasificacion,l.id_clasificacion_fk, l.nombre,n+1
    				FROM kaf.tclasificacion l, t
    				WHERE l.id_clasificacion_fk = t.id
					)
					SELECT id
					FROM t)");
		}

		//Inicio #ETR-2116
		if($this->objParam->getParametro('id_ubicacion')!=''){
			$this->objParam->addFiltro("kaf.id_ubicacion = ".$this->objParam->getParametro('id_ubicacion'));
		}
		//Fin #ETR-2116

		//Inicio #ETR-3627
		if($this->objParam->getParametro('id_movimiento')!='') {
			$this->objParam->addFiltro("kaf.id_activo_fijo in (
					SELECT
					maf.id_activo_fijo
					FROM kaf.tmovimiento_af maf
					WHERE maf.id_movimiento = " . $this->objParam->getParametro('id_movimiento') . "
				)");
		}

		if($this->objParam->getParametro('id_proyecto')!='') {
			$this->objParam->addFiltro("kaf.id_activo_fijo in (
					SELECT
					pa.id_activo_fijo
					FROM pro.tproyecto_activo pa
					WHERE pa.id_proyecto = " . $this->objParam->getParametro('id_proyecto') . "
				)");	
		}
		//Fin #ETR-3627

		$dataSource = $this->listarCodigoQRVarios();
		//parametros basicos
		$orientacion = 'L';
		$titulo = 'Códigos Activos Fijos';

        $width = 210; //ETR-2116
        $height = 80;

		$this->objParam->addParametro('orientacion',$orientacion);
		$this->objParam->addParametro('tamano',array($width, $height));
		$this->objParam->addParametro('titulo_archivo',$titulo);
		$this->objParam->addParametro('nombre_archivo',$nombreArchivo);
		//var_dump($dataSource->getDatos());
		//exit;
		$clsRep = $dataSource->getDatos();

		$reporte = new RCodigoQRAF_v1($this->objParam);


		//eval('$reporte = new '.$clsRep[0]['v_clase_reporte'].'($this->objParam);');

		$reporte->datosHeader( 'varios', $dataSource->getDatos());
		$reporte->generarReporte();
		$reporte->output($reporte->url_archivo,'F');

		$this->mensajeExito=new Mensaje();
		$this->mensajeExito->setMensaje('EXITO','Reporte.php','Reporte generado','Se generó con éxito el reporte: '.$nombreArchivo,'control');
		$this->mensajeExito->setArchivoGenerado($nombreArchivo);
		$this->mensajeExito->imprimirRespuesta($this->mensajeExito->generarJson());

    }

    function listarCodigoQRVarios(){
		$this->objFunc = $this->create('MODActivoFijo');

		$datos = $this->objFunc->listarCodigoQRVarios($this->objParam);

		if($datos->getTipo() == 'EXITO'){
			return $datos;
		} else
		{
		    $datos->imprimirRespuesta($datos->generarJson());
			exit;
		}
	}

	//Inicio #2
	function listarUltimosDatosActivoFijo() {
		$this->objParam->defecto('ordenacion','id_activo_fijo');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_moneda') != '') {
			$this->objParam->addFiltro("afv.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('id_activo_fijo') != '') {
			$this->objParam->addFiltro("afv.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('tipoReporte') == 'excel_grid' || $this->objParam->getParametro('tipoReporte') == 'pdf_grid') {
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODActivoFijo','listarUltimosDatosActivoFijo');
		} else {
			$this->objFunc = $this->create('MODActivoFijo');
			$this->res = $this->objFunc->listarUltimosDatosActivoFijo($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #2

}
?>