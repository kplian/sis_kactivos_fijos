<?php
/*
 * Autor: RCM
 * Fecha: 04/11/2017
 * 
 * */
class RRespInventario extends ReportePDF {
	var $dataMaster;
	var $datos_detalle;
	var $ancho_hoja;
	var $gerencia;
	var $numeracion;
	var $ancho_sin_totales;
    var $posY;
    var $oficina;
	
	function getDataSource(){
		return  $this->datos_detalle;		
	}

    function setOficina($val){
        $this->oficina = $val;
        if($val==''||$val=='%'){
            $this->oficina = 'todos';
        }
    }
	
	function datosHeader ($data) {
		$this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-10;
        $this->dataMaster = $data[0];
		$this->datos_detalle = $data;	

		$this->SetMargins(7, 52, 5);
	}
	
	function Header() {
		$height = 6;
        $midHeight = 9;
        $longHeight = 18;

        $x = $this->GetX();
        $y = $this->GetY();
        $this->SetXY($x, $y);
       
		//$this->Image(dirname(__FILE__).'/../../lib/'.$_SESSION['_DIR_LOGO'], 10,5,35,20);
		$this->Image(dirname(__FILE__).'/../../lib/imagenes/logos/logo.jpg', 17,5,35,16);

        $this->SetFontSize(12);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
       
        $this->Cell(168, $midHeight, 'DETALLE DE ACTIVOS FIJOS POR RESPONSABLE - INVENTARIO', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');

        $x = $this->GetX();
        $y = $this->GetY();
        $this->Ln();
        $this->SetFontSize(10);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(168, $midHeight, '', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetFontSize(7);

        $width1 = 15;
        $width2 = 25;
        $this->SetXY($x, $y);

        $this->SetFont('', '');
        $this->Cell(44+17, $longHeight, '', 1, 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetXY($x, $y+3);
        $this->setCellPaddings(2);
        $this->Cell($width1-4, $height, '', "", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->SetFontSize(6);
        $this->Cell($width2+8, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFontSize(7);
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        $this->Cell($width1-4, $height, '', "", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');

        $this->Cell($width2+8, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        $this->Cell($width1-4, $height, '', "", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->Cell($w = $width2, $h = $height, $txt = '', $border = "", $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        $this->setCellPaddings(2);
		
		$this->fieldsHeader();
		$this->generarCabecera();
		
	}

    public function fieldsHeader(){

        $this->SetFontSize(10);
        $this->Ln(5);

        $this->SetFont('', 'B');
        $this->Cell(35, $height,'RESPONSABLE:', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster['responsable'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        $this->SetFont('', 'B');

        //Lugar
        $this->SetFont('', 'B');
        $this->Cell(40, $height,'LUGAR ASIGNACION:', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->Cell($w = 100,$h = $hGlobal, $txt = $this->oficina, $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
         
        //Custodio
        $this->SetFont('', 'B');
        $this->Cell(35, $height,"CARGO:", "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster['cargo'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

        //Oficina
        $this->SetFont('', 'B');
        $this->Cell(40, $height,'DEPTO.:', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->Cell($w = 50,$h = $hGlobal, $txt = $this->dataMaster['desc_depto'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        
        //Dirección
        $this->SetFont('', 'B');
        $this->Cell(135, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->Cell(25, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->MultiCell($w = 100, $h = $hGlobal, $txt ='', $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);
        $this->Cell(135, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');


        //Estado
        $this->Ln();
        $this->SetFont('', 'B');
        $this->SetFont('', '');
        $this->firstPage++;
    }

   
   function generarReporte() {
   	      $this->setFontSubsetting(false);
		  $this->AddPage();
		  
		  $this->SetFontSize(7);

		 foreach ($this->getDataSource() as $datarow) {
			$this->tablealigns=array('R','C','L','L','C','L','L','L');
	        $this->tablenumbers=array(0,0,0,0,0,0,0);
	        $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
            $this->tabletextcolor=array();
			
			$RowArray = array(
            			's0'  => $i+1,
            			's1' => $datarow['codigo'],   
                        's2' => $datarow['descripcion'],
                        's3' => '',
                        's4' => date("d/m/Y",strtotime($datarow['fecha_asignacion'])),
                        's5' => '',
                        's6' => $datarow['desc_oficina'],
                        's7' => '',
                        );
            $i++;
			
			$this-> MultiRow($RowArray,false,1);
			$this->revisarfinPagina();
			
        }
		
   } 
   
   function generarCabecera(){
    	
		$this->SetFontSize(9);
        $this->SetFont('', 'B');
        $this->tablewidthsHD=array(8,25,59,45,20,45,30,45);
        $this->tablealignsHD=array('C','C','C','C','C','C','C','C');
        $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
        $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TBR');
        $this->tabletextcolorHD=array();
        $RowArray = array(
        		's0'  => 'Nro',
        		's1' => 'Código',   
                's2' => 'Descripción',
                's3' => 'Estado (Llenado a Mano)',
                's4' => 'Fecha Asig.',
                's5' => 'Observaciones (Llenado a Mano)',
                's6' => 'Lugar  Asig.',
                's7' => 'Verificación Física (Llenado a Mano)'
        );

		/////////////////////////////////	                         
        $this-> MultiRowHeader($RowArray,false,1);
		$this->tablewidths = $this->tablewidthsHD;
		
    }

   function revisarfinPagina(){
		$dimensions = $this->getPageDimensions();
		$hasBorder = false; //flag for fringe case
		
		$startY = $this->GetY();
		$this->getNumLines($row['cell1data'], 80);
		
		if (($startY + 4 * 3) + $dimensions['bm'] > ($dimensions['hk'])) {
		    if($this->total!= 0){
				$this->AddPage();
			}
		} 
	}
   
  
   
   
 
}
?>