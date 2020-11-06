<?php
// Extend the TCPDF class to create custom MultiRow
/*
 * para imrpesora Zebra TPL 2844
 * Autor RAC
 * Fecha: 16/03/2017
 * Descripcion para cambiar la calse que se ejecuta el momento de imprimir modificar la variable global kaf_clase_reporte_codigo en PXP

 Formato QR:

 	id_activo_fijo,
 	codigo,
 	codigo_anterior,
 	denominacion,
 	depto,
 	empleado

 *
 * */
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           16/03/2017  RAC         Creación del archivo
 #AF-11 KAF       ETR           01/10/2020  RCM         Modificación de impresión incluyendo nuevos campos
 ***************************************************************************/
class RCodigoQRAF extends  ReportePDF {
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
			$this->cod = array('id'  => $detalle['id_activo_fijo'],
					     'cod' => $detalle['codigo'],
					     'cod_ant' => $detalle['codigo_ant'],
					     'desc' => $detalle['denominacion'],
					     'depto' => $detalle['nombre_depto'],
					     'emp' => $detalle['nombre_entidad'],
					     'serie' => $val['nro_serie'] //#AF-11
					 );

			//formatea el codigo con el conteido requrido
			$this->codigo_qr = json_encode($this->cod);
		}
		else{
			// para imprimir varios codigos
			$this->detalle = $detalle;
		}

		$this->SetMargins(1, 1, 1, true);
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

				$this->cod = array('id'  => $val['id_activo_fijo'],
						     'cod' => $val['codigo'],
						     'cod_ant' => $val['codigo_ant'],
						     'desc' => $val['denominacion'],
						     'depto' => $val['nombre_depto'],
						     'emp' => $val['nombre_entidad'],
						     'serie' => $val['nro_serie'] //#AF-11
						 );

				//formatea el codigo con el conteido requrido
				$this->codigo_qr = json_encode($this->cod);
				$this->imprimirCodigo($style);


			}
		}
	}

   function imprimirCodigo($style){
   		echo 'sssssss';exit;
	    $this->AddPage();
   	    $this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,80,0, $style,'T',true);
		$this->SetFont('','B',30);
		$this->Text(80, 5, $this->cod['emp'], false, false, true, 0,0,'',false,'',2);
		$this->ln(5);
		$this->SetFont('','',22);
		$this->Text(80, 17, $this->cod['cod'], false, false, true, 0,5,'',false,'',2);
		$this->Text(80, 26, $this->cod['cod_ant'], false, false, true, 0,5,'',false,'',2);
		$this->Text(80, 36, substr($this->cod['desc'], 0, 50), false, false, true, 0,5,'',false,'',2);


   }

}

/*
 * para imrpesora Zebra TPL 2844
 * Autor RAC
 * Fecha: 16/03/2017
 * Descripcion para cambiar la calse que se ejecuta el momento de imprimir modificar la variable global kaf_clase_reporte_codigo en PXP
 *
 * */

 class RCodigoQRAF2 extends  ReportePDF {
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






	function datosHeader ( $detalle ) {
		$this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-2;
		$this->datos_detalle = $detalle;
		$this->datos_titulo = $totales;
		$this->datos_entidad = $dataEmpresa;
		$this->datos_gestion = $gestion;
		$this->subtotal = 0;


		$this->id_activo_fijo = $detalle['id_activo_fijo'];
	    $this->codigo = $detalle['codigo'];
	    $this->codigo_ant = $detalle['codigo_ant'];
	    $this->denominacion = $detalle['denominacion'];
	    $this->nombre_depto = $detalle['nombre_depto'];
	    $this->nombre_entidad = $detalle['nombre_entidad'];

		//formatea el codigo con el conteido requrido
		$this->codigo_qr = json_encode($detalle);
		$this->SetMargins(1, 1, 1, true);




	}

	function Header() {}
	function Footer() {}

    function generarReporte() {
		$this->setFontSubsetting(false);
       // $this->AddPage('L', $resolution);
		$this->AddPage();
		// set style for barcode
		$style = array(
		    'border' => 0,
		    'vpadding' => 'auto',
		    'hpadding' => 'auto',
		    'fgcolor' => array(0,0,0),
		    'bgcolor' => false, //array(255,255,255)
		    'module_width' => 4, // width of a single module in points
		  'module_height' => 4 // height of a single module in points
		);

		//$this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,160,80, $style);
		$this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,80,0, $style,'T',true);
		$this->SetFont('','B',30);
		$this->Text(80, 5, $this->nombre_entidad, false, false, true, 0,0,'',false,'',2);
		$this->ln(5);
		$this->SetFont('','',22);
		$this->Text(80, 17, $this->codigo, false, false, true, 0,5,'',false,'',2);

	}

}
?>