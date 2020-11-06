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
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           21/07/2017  RCM         Creación del archivo
 #AF-11 KAF       ETR           24/08/2020  RCM         Adición de Nro. de serie en el código QR
***************************************************************************
 * */
class RCodigoQRAF_v1 extends  ReportePDF {
	var $datos_titulo;
	var $datos_detalle;
	var $ancho_hoja;
	var $gerencia;
	var $numeracion;
	var $ancho_sin_totales;
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
							'id'  => $detalle['id_activo_fijo'],
						    'cod' => $detalle['codigo'],
						    'desc' => $detalle['descripcion'],
						    'serie' => $detalle['nro_serie'] //B02
						);

			//formatea el codigo con el conteido requrido
			$this->codigo_qr = json_encode($this->cod);
		}
		else{
			// para imprimir varios codigos
			$this->detalle = $detalle;
		}

		$this->SetMargins(1, 1, 1, true);
		$this->SetAutoPageBreak(false,0.1);

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
			foreach ($this->detalle as $val) {

				$this->cod = array
							(
								'id'  => $val['id_activo_fijo'],
								'cod' => $val['codigo'],
								'desc' => $val['descripcion'],
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
   	    $this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,80,0, $style,'T',true);

   	    //Inicio #AF-11
		$this->SetFont('','',10);
		$this->SetXY(80,8);
		$this->Image(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO'], 105, 5, 25, 0,'','','C');
		$this->cell(75, 20, 'ACTIVOS FIJOS', 0, 1, 'C');
		$this->SetFont('','B',20);
		$this->SetXY(80,20);
		$this->cell(75, 5, $this->cod['cod'], 0, 1, 'C',false,'',0);
		$this->SetFont('','',15);
		$this->SetXY(80,30);
		$this->SetFont('','',10);

		$fila=30;
		$maxLength=133;

		$serie = $this->cod['serie'];
		if(strlen($this->cod['serie'])>=30){
			$serie=substr($this->cod['serie'],0,30).'...';
		}

		if($this->cod['serie']!='') {
			$this->cell(75, 5, 'N°Serie: '.$serie, 0, 1, 'C',false,'',0);
			$fila+=10;
			$maxLength-=10;
		}

		//Descripcion
		$this->SetFont('','B',15);
		$maxLengthLinea=22;
		$x=80;
		$y=$fila;
		$codAux = substr($this->cod['desc'],0,$maxLength);
		if(strlen($this->cod['desc'])>$maxLength){
			$codAux = substr($this->cod['desc'],0,$maxLength-4).'...';
		}

		while (strlen($codAux)>0) {
			$tmp = substr($codAux, 0, $maxLengthLinea);
			$this->Text($x, $y, strtoupper($tmp), false, false, true, 0, 5,'C',false,'',0);
			$codAux = substr($codAux, $maxLengthLinea,$maxLength);
			$y=$y+7;
		}
		//Fin #AF-11

   }

}

?>