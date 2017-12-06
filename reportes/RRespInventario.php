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
    var $tipo;
	
	function getDataSource(){
		return  $this->datos_detalle;		
	}

    function setOficina($val){
        $this->oficina = $val;
        if($val==''||$val=='%'){
            $this->oficina = 'todos';
        }
    }

    function setTipo($val){
        $this->tipo = $val;
    }
	
	function datosHeader ($data) {

		$this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-10;
        $this->dataMaster = $data[0];
		$this->datos_detalle = $data;
        //var_dump($this->dataMaster);exit;
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

        if($this->tipo=='lug' || $this->tipo=='lug_fun'){
            //Responsable
            $this->SetFont('', 'B');
            $this->Cell(45, $height,'LUGAR DE ASIGNACIÓN:', "", 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('', '');
            $this->Cell($w = 100,$h = $hGlobal, $txt = $this->oficina, $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->SetFont('', 'B');

            //Lugar
            $this->SetFont('', 'B');
            $this->Cell(25, $height,'DEPTO.:', "", 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('', '');
            $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster['desc_depto'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        } else {
            //Responsable
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
             
            //Cargo
            $this->SetFont('', 'B');
            $this->Cell(35, $height,"CARGO:", "", 0, 'L', false, '', 0, false, 'T', 'C');
            $this->SetFont('', '');
            $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster['cargo'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

            //Depto
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
        }


        $this->Ln();
        $this->SetFont('', 'B');
        $this->SetFont('', '');
        $this->firstPage++;
    }

   
    function generarReporte() {
   	      $this->setFontSubsetting(false);
		  $this->AddPage();
		  
		  $this->SetFontSize(7);

          if($this->tipo=='lug' || $this->tipo=='lug_fun'){
            $this->SetY(42);
          } else {
            $this->SetY(51);
          }

		 foreach ($this->getDataSource() as $datarow) {
			$this->tablealigns=array('R','C','L','L','C','L','L','L','L');
	        $this->tablenumbers=array(0,0,0,0,0,0,0,0,0);
	        $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
            $this->tabletextcolor=array();
			
            if($this->tipo=='lug' || $this->tipo=='lug_fun') {
                $RowArray = array(
                        's0'  => $i+1,
                        's1' => $datarow['codigo'],   
                        's2' => $datarow['descripcion'],
                        's3' => date("d/m/Y",strtotime($datarow['fecha_asignacion'])),
                        's4' => '',
                        's5' => '',
                        's6' => $datarow['ubicacion'],
                        's7' => $datarow['responsable'],
                        's8' => ''
                        );
            } else {
                $RowArray = array(
                        's0'  => $i+1,
                        's1' => $datarow['codigo'],   
                        's2' => $datarow['descripcion'],
                        's3' => date("d/m/Y",strtotime($datarow['fecha_asignacion'])),
                        's4' => '',
                        's5' => '',
                        's6' => $datarow['ubicacion'],
                        's7' => $datarow['desc_oficina'],
                        's8' => ''
                        );    
            }

			
            $i++;
			
			$this-> MultiRow($RowArray,false,1);
			$this->revisarfinPagina();
			
        }
       $this->Ln();
       $this->setFont('helvetica', 'B', 10);
       $this->Cell(15, 5, "(1)  ", 0, 0, 'L', false, '', 0, false, 'T', 'C');
       $this->Cell(100, 5,"Bueno, Malo, Regular", 0, 0, 'L', false, '', 0, false, 'T', 'C');
       $this->Ln();
       $this->Cell(15, 5, "(2)  ", 0, 0, 'L', false, '', 0, false, 'T', 'C');
       $this->Cell(100, 5,"SI, NO", 0, 0, 'L', false, '', 0, false, 'T', 'C');

    } 
   
   function generarCabecera(){
    	
		$this->SetFontSize(9);
        $this->SetFont('', 'B');
        $this->tablewidthsHD=array(8,25,51,25,25,25,30,43,50);
        $this->tablealignsHD=array('C','C','C','C','C','C','C','C','C');
        $this->tablenumbersHD=array(0,0,0,0,0,0,0,0,0);
        $this->tablebordersHD=array('LRTB','LRTB','LRTB','LRTB','LRTB','LRTB','LRTB','LRTB','LRTB');
        $this->tabletextcolorHD=array();

        if($this->tipo=='lug' || $this->tipo=='lug_fun'){
            $RowArray = array(
                    's0'  => 'Nro',
                    's1' => 'Código',   
                    's2' => 'Descripción',
                    's3' => 'Fecha Asig.',
                    's4' => 'Estado '."\n".'del Activo (1)',
                    's5' => 'Verificación'."\n".' Física (2)',
                    's6' => 'Ubicación Física',
                    's7' => 'Responsable',
                    's8' => 'Observaciones'
            );
        } else {
            $RowArray = array(
            		's0'  => 'Nro',
            		's1' => 'Código',   
                    's2' => 'Descripción',
                    's3' => 'Fecha Asig.',
                    's4' => 'Estado '."\n".'del Activo (1)',
                    's5' => 'Verificación'."\n".' Física (2)',
                    's6' => 'Ubicación Física',
                    's7' => 'Oficina  Asignada',
                    's8' => 'Observaciones'
            );
        }

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