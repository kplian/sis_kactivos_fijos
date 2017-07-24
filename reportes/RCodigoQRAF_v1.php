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
			$this->cod = array('id'  => $detalle['id_activo_fijo'],
					     'cod' => $detalle['codigo'],
					     'desc' => $detalle['denominacion']);
			
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
				
				$this->cod = array('id'  => $val['id_activo_fijo'],
						     'cod' => $val['codigo'],
						     'desc' => $val['denominacion']);
				
				//formatea el codigo con el conteido requrido
				$this->codigo_qr = json_encode($this->cod);
				$this->imprimirCodigo($style);
				
				
			}
		}
	} 
   
   function imprimirCodigo($style){
   	
	    $this->AddPage();
   	    $this->write2DBarcode($this->codigo_qr, 'QRCODE,L', 1, 1,80,0, $style,'T',true);
		$this->SetFont('','',20);
		$this->SetXY(80,5);
		$this->cell(75, 5, 'Activos Fijos', 0, 1, 'C');
		$this->Image(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO'], 105, 15, 25, 0,'','','C');
		$this->SetFont('','B',25);
		$this->SetXY(80,25);
		$this->cell(75, 5, $this->cod['cod'], 0, 1, 'C',false,'',0);
		$this->SetFont('','',20);
		$this->SetXY(80,38);
		//Descripcion
		$maxLength=80;
		$maxLengthLinea=16;
		$x=80;
		$y=38;
		$codAux = substr($this->cod['desc'],0,$maxLength);
		if(strlen($this->cod['desc'])>$maxLength){
			$codAux = substr($this->cod['desc'],0,$maxLength-4).'...';
		}
		while (strlen($codAux)>0) {
			$tmp = substr($codAux, 0, $maxLengthLinea);
			$this->Text($x, $y, strtoupper($tmp), false, false, true, 0, 5,'',false,'',0);
			$codAux = substr($codAux, $maxLengthLinea,$maxLength);
			$y=$y+7;
		}

		

		//$this->Text(80, 43, $tt, false, false, true, 0,5,'',false,'',0);
		//$this->MultiCell(70, 5, $this->cod['desc'], 0, '', false, 0, 0, 0, true, 0, false, true, 0, 'T', false);
		/*$this->Text(80, 20, $this->cod['emp'], false, false, true, 0,0,'',false,'',2);
		$this->ln(5);
		$this->SetFont('','',22);	
		$this->Text(80, 17, $this->cod['cod'], false, false, true, 0,5,'',false,'',2);
		$this->Text(80, 26, $this->cod['cod_ant'], false, false, true, 0,5,'',false,'',2);
		$this->Text(80, 36, substr($this->cod['desc'], 0, 50), false, false, true, 0,5,'',false,'',2);*/
		 
   	
   }
 
}

?>