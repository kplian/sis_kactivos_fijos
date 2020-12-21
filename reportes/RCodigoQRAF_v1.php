<?php
/*
 * para imrpesora Zebra TPL 2844
 * Autor RCM
 * Fecha: 21/07/2017
 * Descripcion para cambiar la calse que se ejecuta el momento de imprimir modificar la variable global kaf_clase_reporte_codigo en PXP

 Formato QR:

 	id_activo_fijo,
 	codigo,
 	denominacion,
 	depto,
 	empleado

 *
 ***************************************************************************
 ISSUE  	SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        	KAF       ETR           21/07/2017  RCM         Creación del archivo
 #AF-11 	KAF       ETR           24/08/2020  RCM         Adición de Nro. de serie en el código QR
 #ETR-2116	KAF 	  ETR 			11/12/2020	RCM 		Modificación de formato de reporte de etiqueta
***************************************************************************
 * */
header('Content-Type: text/html; charset=utf-8');

class RCodigoQRAF_v1 extends  ReportePDF {
	var $datos_titulo;
	var $datos_detalle;
	var $ancho_hoja;
	var $id_activo_fijo;
	var $codigo;
	var $codigo_ant;

	var $denominacion;
	var $nombre_depto;
	var $nombre_entidad;
	var $codigo_qr;
	var $cod;
	var $tipo;

	function datosHeader ( $tipo, $detalle ) {
		$this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-2;
		$this->datos_detalle = $detalle;
		$this->datos_titulo = $totales;
		$this->datos_entidad = $dataEmpresa;
		$this->datos_gestion = $gestion;
		$this->subtotal = 0;
		$this->tipo = $tipo;

		if($tipo == 'unico'){
			//para imprimir un solo codigo
			$this->cod = array
						(
							//'id'  => $detalle['id_activo_fijo'],//#ETR-2116
						    'cod' => $detalle['codigo'],
						    'denominacion' => $detalle['denominacion'],//#ETR-2116
						    'serie' => $detalle['nro_serie'] //B02
						);

			//formatea el codigo con el conteido requerido
			$this->codigo_qr = json_encode($this->cod);
		}
		else{
			// para imprimir varios codigos
			$this->detalle = $detalle;
		}

		$this->SetMargins(1, 1, 1, true);
		$this->SetAutoPageBreak(false, 0.1);

	}

	function Header() {}
	function Footer() {}

    function generarReporte() {
		$this->setFontSubsetting(false);

		$style = array(
		    'border' => 0,
		    'vpadding' => 'auto',
		    'hpadding' => 'auto',
		    'fgcolor' => array(0,0,0),
		    'bgcolor' => false, //array(255,255,255)
		    'module_width' => 4, // width of a single module in points
		    'module_height' => 4 // height of a single module in points
		);

		if($this->tipo == 'unico'){
			$this->imprimirCodigo($style);
		}
		else{
			//imprime varios codigos ....
			$vv=0;
			foreach ($this->detalle as $val) {
				$this->cod = array
							(
								//'id'  => $val['id_activo_fijo'],//#ETR-2116
								'cod' => $val['codigo'],
								'denominacion' => $val['denominacion'], //#ETR-2116
								'serie' => $detalle['nro_serie'] //B02
						 	);

				//formatea el codigo con el conteido requrido
				$this->codigo_qr = json_encode($this->cod);
				$this->imprimirCodigo($style);
			}
		}
	}

   function imprimirCodigo($style){
	    $this->AddPage();
   	    $this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,73,73, $style,'T',true);
   	    $this->Ln();
   	    $this->SetFont('','B',20);
   	    $this->SetXY(2,2);//ETR-2116
   	    $this->cell(73, 145, $this->cod['cod'], 0, 1, 'C',false,'',0); //ETR-2116

   	    //Inicio #AF-11
		$this->SetFont('','',10);
		$this->SetXY(80,8);
		$this->Image(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO'], 110, 5, 65, 0,'','','C'); //ETR-2116
		//$this->cell(75, 20, 'ACTIVOS FIJOS', 0, 1, 'C');
		//$this->SetFont('','B',20);
		//$this->SetXY(80,20);
		//$this->cell(75, 5, $this->cod['cod'], 0, 1, 'C',false,'',0);
		$this->SetXY(80,50);
		$this->SetFont('','',10);

		$fila=30;
		$maxLength=140;

		//Descripcion
		$this->SetFont('','B',20);
		$maxLengthLinea=28;
		$x=65;
		$y=$fila;

		//$this->cod['denominacion'] = $this->cod['desc'].'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make';
		//$this->cod['denominacion'] = "GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO GARAJE ORURO ";
		//$this->cod['serie'] = 'SDF-SDF-34-SDFSD-454545';

		$codAux = substr($this->cod['denominacion'],0,$maxLength);
		if(strlen($this->cod['denominacion'])>$maxLength){
			$codAux = substr($this->cod['denominacion'],0,$maxLength-4).'...';
		}

		while (strlen($codAux)>0) {
			$tmp = mb_substr($codAux, 0, $maxLengthLinea, 'UTF-8');
			$this->Text($x+10, $y, strtoupper($tmp), false, false, true, 0, 5,'C',false,'',0);
			$codAux = mb_substr($codAux, $maxLengthLinea, $maxLength, 'UTF-8');
			$y=$y+7;
		}

		//Nro Serie //ETR-2116
		$this->SetXY(70,30);
		$this->SetFont('','B',14);
		$serie = $this->cod['serie'];
		if(strlen($this->cod['serie'])>=30){
			$serie=substr($this->cod['serie'],0,30).'...';
		}

		$this->cell(130, 85, 'SERIE: '.$serie, 0, 1, 'C',false,'',0);
		$fila+=10;
		$maxLength-=10;
		//Fin #AF-11

   }

}

?>