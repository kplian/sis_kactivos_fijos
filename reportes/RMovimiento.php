<?php
require_once dirname(__FILE__) . '/../../pxp/pxpReport/Report.php';

class CustomReport extends TCPDF {

	private $dataSource;
    public $headerFirstPage=true;
    public $dataMaster;
    public $firstPage=0;
    public $tipoMov='';
    public $posY;

    public function setDataDetalle($dataSource) {
        $this->dataSource = $dataSource;
    }
	
	public function setDataMaster($maestro){
         $this->dataMaster = $maestro;
    }
	
    public function getDataSource() {
        return $this->dataSource;
    }


    public function getDataMaster(){
        return $this->dataMaster;
    }
	
	
    public function getTipoMov(){
        return $this->tipoMov;
    }

    public function getPosY(){
        return $this->posY;
    }


    public function Header() {
        /*
            CABECERA PRINCIPAL
        */

        $height = 6;
        $midHeight = 9;
        $longHeight = 18;

        $x = $this->GetX();
        $y = $this->GetY();
        $this->SetXY($x, $y);

        $dataSource = $this->getDataSource();

        $this->Image(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO'], 28, 8, 17);

        $this->SetFontSize(12);
        $this->SetFont('', 'B');
        $this->Cell(44, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
       
        $this->Cell(168, $midHeight, 'FORMULARIO DE '.strtoupper($this->dataMaster[0]['movimiento']).' DE ACTIVOS FIJOS', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->tipoMov = $this->dataMaster[0]['cod_movimiento']; 

        $x = $this->GetX();
        $y = $this->GetY();
        $this->Ln();
        $this->SetFontSize(10);
        $this->SetFont('', 'B');
        $this->Cell(44, $midHeight, '', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(168, $midHeight, strtoupper($this->dataMaster[0]['depto']), 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetFontSize(7);

        $width1 = 15;
        $width2 = 25;
        $this->SetXY($x, $y);

        $this->SetFont('', '');
        $this->Cell(44, $longHeight, '', 1, 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetXY($x, $y);
        $this->setCellPaddings(2);
        $this->Cell($width1-4, $height, 'FORM:', "B", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->Cell($width2+8, $height,$this->dataMaster[0]['formulario'], "B", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        $this->Cell($width1-4, $height, 'FECHA:', "B", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->Cell($width2+8, $height,$this->dataMaster[0]['fecha_mov'], "B", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        $this->Cell($width1-4, $height, 'PAGINA:', "B", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->Cell($w = $width2, $h = $height, $txt = $this->getAliasNumPage() . ' de ' . $this->getAliasNbPages(), $border = "B", $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        $this->setCellPaddings(2);

        /*
            CAMPOS CABECERA
        */
        $this->fieldsHeader($this->tipoMov);

        $this->columnsGrid($this->tipoMov);

        /*
            TITULOS COLUMNAS
        */
    }

    public function Footer() {
        $this->SetFontSize(8);
        
        $_firma100='';
        $_firma110=$this->dataMaster[0]['responsable_depto'];
        $_firma111='RESPONSABLE ACTIVOS FIJOS';
        
        $_firma200='';
        $_firma210='';
        $_firma211='';

        $_firma300='';
        $_firma310='';
        $_firma311='';

        $_firma400='';
        $_firma410='';
        $_firma411='';

        if($this->tipoMov=='asig'){
            $_firma100=$this->dataMaster[0]['responsable_depto'];
            $_firma110='RESPONSABLE ACTIVOS FIJOS';
            $_firma111='ENTREGUÉ CONFORME';
            
            $_firma200=strtoupper($this->dataMaster[0]['responsable']);
            $_firma210=strtoupper($this->dataMaster[0]['nombre_cargo']);
            $_firma211='RECIBÍ CONFORME';

            if($this->dataMaster[0]['custodio']!=''){
                $_firma300=strtoupper($this->dataMaster[0]['custodio']);
                $_firma310='CI. '.strtoupper($this->dataMaster[0]['ci_custodio']);
                $_firma311='CUSTODIO';    
            }

        }
		
		
		
		
		 if($this->tipoMov=='transf'){
            $_firma100=$this->dataMaster[0]['responsable_depto'];
            $_firma110='RESPONSABLE ACTIVOS FIJOS';
            $_firma111='SUPERVISOR';
            
            $_firma200=strtoupper($this->dataMaster[0]['responsable']);
            $_firma210=strtoupper($this->dataMaster[0]['nombre_cargo']);
            $_firma211='ENTREGUE CONFORME';

            
            $_firma300=strtoupper($this->dataMaster[0]['responsable_dest']);
            $_firma310=strtoupper($this->dataMaster[0]['nombre_cargo_dest']);
            $_firma311='RECIBÍ CONFORME';    
            

        }


        $this->Cell(63, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LRT', 1, 'C', false, '', 0, false, 'T', 'C');
         
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 1, 'C', false, '', 0, false, 'T', 'C');
        
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', 'LR', 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(63, $midHeight, $_firma100, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma200, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma300, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma400, 'LR', 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(63, $midHeight, $_firma110, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma210, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma310, 'LR', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma410, 'LR', 1, 'C', false, '', 0, false, 'T', 'C');
        
        $this->Cell(63, $midHeight, $_firma111, 'LRBT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma211, 'LRBT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma311, 'LRBT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma411, 'LRBT', 1, 'C', false, '', 0, false, 'T', 'C');

    }

    public function fieldsHeader($tipo){
        if($this->firstPage==0){
            $this->SetFontSize(10);
            if($tipo=='asig'||$tipo=='devol'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Responsable:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['responsable'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Custodio:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['custodio'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Oficina:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['oficina'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Direccion:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['direccion'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            } else if ($tipo=='deprec'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Depreciacion hasta:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['fecha_hasta'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            }

            //Estado
            $this->Ln();
            $this->SetFont('', 'B');
            $this->Cell($width2+18, $height,'Estado:', "", 0, 'L', false, '', 0, false, 'T', 'C');
            //$this->Ln();
            $this->SetFont('', '');
            $this->MultiCell($w = 0, $h = $hLong, $txt = $this->dataMaster[0]['estado'], $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);

            //Glosa
            //$this->Ln();
            $this->SetFont('', 'B');
            $this->Cell($width2+8, $height,'Glosa:', "", 0, 'L', false, '', 0, false, 'T', 'C');
            $this->Ln();
            $this->SetFont('', '');
            $this->MultiCell($w = 0, $h = $hLong, $txt = $this->dataMaster[0]['glosa'], $border = 0, $align = 'L', $fill = false, $ln = 0, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);
            $this->firstPage++;
            //$this->Ln();   
        }
    }

    public function columnsGrid($tipo){
        $this->Ln();    
        if($tipo=='baja'){
            $this->SetFontSize(7);
            $this->SetFont('', 'B');
            $this->Cell($w = 10,$h = $hGlobal, $txt = 'Nro.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 35, $h = $hGlobal, $txt = 'Código', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 100, $h = $hGlobal, $txt = 'Descripcion', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 70, $h = $hGlobal, $txt = 'Marca', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 50, $h = $hGlobal, $txt = 'Nro. Serie', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20, $h = $hGlobal, $txt = 'Estado Fun.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 90, $h = $hGlobal, $txt = 'Motivo', $border = 1, $ln = 1, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

        } else if($tipo=='reval'){
            $this->SetFontSize(7);
            $this->SetFont('', 'B');
            $this->Cell($w = 10,$h = $hGlobal, $txt = 'Nro.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 35, $h = $hGlobal, $txt = 'Código', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 100, $h = $hGlobal, $txt = 'Descripcion', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 70, $h = $hGlobal, $txt = 'Marca', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 50, $h = $hGlobal, $txt = 'Nro. Serie', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20, $h = $hGlobal, $txt = 'Estado Fun.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20, $h = $hGlobal, $txt = 'Inc.Vida Util', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20, $h = $hGlobal, $txt = 'Inc.Valor', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 50, $h = $hGlobal, $txt = 'Observaciones', $border = 1, $ln = 1, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

        } else if($tipo=='deprec'){
            $this->SetFontSize(7);
            $this->SetFont('', 'B');
            $this->Cell($w = 10,$h = $hGlobal, $txt = 'Nro.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 35, $h = $hGlobal, $txt = 'Código', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 100, $h = $hGlobal, $txt = 'Descripcion', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 70, $h = $hGlobal, $txt = 'Marca', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 50, $h = $hGlobal, $txt = 'Nro. Serie', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20, $h = $hGlobal, $txt = 'Estado Fun.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 90, $h = $hGlobal, $txt = 'Observaciones', $border = 1, $ln = 1, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

        } else if($tipo=='asig'||$tipo=='devol'){
            $this->SetFontSize(7);
            $this->SetFont('', 'B');
            $this->Cell($w = $this->RD3(35),$h = $hGlobal, $txt = 'Nro.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(100), $h = $hGlobal, $txt = 'Código', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(300), $h = $hGlobal, $txt = 'Descripcion', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(70), $h = $hGlobal, $txt = 'Marca', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(50), $h = $hGlobal, $txt = 'Nro. Serie', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(70), $h = $hGlobal, $txt = 'Estado Fun.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = $this->RD3(300), $h = $hGlobal, $txt = 'Observaciones', $border = 1, $ln = 1, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
			
			
			// $this->anchors= array(35,100,300,70,50,70,300);
      
           // $this->anchors= array(28,110,300,120,115,95,62,73);
            
        } else {
            //Alta, transf
            $this->SetFontSize(7);
            $this->SetFont('', 'B');
            $this->Cell($w = 8,$h = $hGlobal, $txt = 'Nro.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 31, $h = $hGlobal, $txt = 'Código', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 84.5, $h = $hGlobal, $txt = 'Descripcion', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 34, $h = $hGlobal, $txt = 'Tipo de Activo', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 32.5, $h = $hGlobal, $txt = 'Marca', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 26.5, $h = $hGlobal, $txt = 'Nro. Serie', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 18, $h = $hGlobal, $txt = 'Fecha Compra', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            $this->Cell($w = 20.5, $h = $hGlobal, $txt = 'Estado Fun.', $border = 1, $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            

            $this->Ln();    
        }
        $this->posY = $this->GetY();

    }

    function RD3($width){
    	
		// 35 - 10
		//125   35
		//355   100
		// x ---$widt
		
		
		/*   
		 *   34   -> 120
		 *  X       -> width 
		 *   
		 * */
    	return   round(($width*34)/120, 0); 
    }

    public function array_unshift_assoc(&$arr, $key, $val)
    {
        $arr = array_reverse($arr, true);
        $arr[$key] = $val;
        return array_reverse($arr, true);
    } 

    public function MultiRow($pMatriz,$pWidth,$pAlign,$pVisible=array(),$pConNumeracion=1) {
        // MultiCell($w, $h, $txt, $border=0, $align='J', $fill=0, $ln=1, $x='', $y='', $reseth=true, $stretch=0)
        $page_start = $this->getPage();
        $y_start = $this->GetY();
        
        //Obtiene el total de filas 
        $totalFilas=count($pMatriz)-1;
        //var_dump($pMatriz);exit;
        //echo $totalFilas;exit;
        $fila=0;
        
        foreach ($pMatriz as $row) {
            //Obtiene el alto máximo de la celda de toda la fila
            $i=0;
            $nb=0;
            
            $x=$this->getX();
            $y=$this->getY();
            //var_dump($this->array_unshift_assoc($fila,'nro',$fila));exit;
            foreach ($row as $value) {
                $nb=max($nb,$this->getNumLines($value,$pWidth[$i]));
                $i++;
            }
            //Define el alto máximo
            $alto=3*$nb;
            $j=0;
            $tmp=$fila+1;
            $row=$this->array_unshift_assoc($row,'nro',$tmp);
            //Dibuja la fila
            foreach ($row as $value) {
                if($i>0){
                    $this->setXY($x,$y);
                }
                
                //Verificación de borde
                if($fila==$totalFilas){
                    if($value==''){
                        $borde='LRB';
                    } else{
                        $borde='LRTB';
                    }
                } else{
                    if($value==''){
                        $borde='LR';
                    } else{
                        $borde='LRT';
                    }
                }
                // MultiCell($w, $h, $txt, $border=0, $align='J', $fill=0, $ln=1, $x='', $y='', $reseth=true, $stretch=0)
                $this->MultiCell($pWidth[$j], $alto, $value, $borde, $pAlign[$j], 0, 0, '', '', true, 0);
                $j++;
                $x=$this->getX();
                //$this->Ln();  
            }
            $this->Ln();
            $fila++;
        }

    }

}

class RMovimiento extends Report {
    public $pdf;
    public $dd=array();
    public $anchors=array();
    public $aligns=array();
    public $html;

    public function specificArray($tipo){
        $auxArray=array();
        $i=0;

        foreach ($this->pdf->getDataSource() as $datarow) {
            if($tipo=='baja'){
                $auxArray[$i][]=$i+1;
                $auxArray[$i][]=$datarow['codigo'];
                $auxArray[$i][]=$datarow['descripcion'];
                $auxArray[$i][]=$datarow['marca'];
                $auxArray[$i][]=$datarow['nro_serie'];
                $auxArray[$i][]=$datarow['estado_fun'];
                $auxArray[$i][]=$datarow['motivo'];
            } else if($tipo=='reval'){
                $auxArray[$i][]=$i+1;
                $auxArray[$i][]=$datarow['codigo'];
                $auxArray[$i][]=$datarow['descripcion'];
                $auxArray[$i][]=$datarow['marca'];
                $auxArray[$i][]=$datarow['nro_serie'];
                $auxArray[$i][]=$datarow['estado_fun'];
                $auxArray[$i][]=$datarow['vida_util'];
                $auxArray[$i][]=$datarow['importe'];
                $auxArray[$i][]=' ';

            } else if($tipo=='deprec'){
                $auxArray[$i][]=$i+1;
                $auxArray[$i][]=$datarow['codigo'];
                $auxArray[$i][]=$datarow['descripcion'];
                $auxArray[$i][]=$datarow['marca'];
                $auxArray[$i][]=$datarow['nro_serie'];
                $auxArray[$i][]=$datarow['estado_fun'];
                $auxArray[$i][]=' ';

            } else if($tipo=='asig'||$tipo=='devol'){
                $auxArray[$i][]=$i+1;
                $auxArray[$i][]=$datarow['codigo'];
                $auxArray[$i][]=$datarow['descripcion'];
                $auxArray[$i][]=$datarow['marca'];
                $auxArray[$i][]=$datarow['nro_serie'];
                $auxArray[$i][]=$datarow['estado_fun'];
                $auxArray[$i][]=' ';
            } else {
                //Alta
                $num=$i+1;
                $auxArray[$i][]='  '.$num;
                $auxArray[$i][]='  '.$datarow['codigo'];
                $auxArray[$i][]='  '.$datarow['descripcion'];
                $auxArray[$i][]='  '.$datarow['tipo_activo'];
                $auxArray[$i][]='  '.$datarow['marca'];
                $auxArray[$i][]='  '.$datarow['nro_serie'];
                $auxArray[$i][]='  '.$datarow['fecha_compra'];
                //$auxArray[$i][]='  '.$datarow['monto_compra'];
                $auxArray[$i][]='  '.$datarow['estado_fun'];
            }
            $i++;
        }

        $this->dd=$auxArray;

        if($tipo=='baja'){
            $this->anchors= array(35,125,35,70,50,70,318);
            $this->aligns= array('L','L','L','L');

        } else if($tipo=='reval'){
            $this->anchors= array(35,125,355,70,50,70,70,70,178);
            $this->aligns= array('L','L','L','C','R','L');

        } else if($tipo=='deprec'){
            $this->anchors= array(35,125,355,70,50,70,318);
            $this->aligns= array('L','L','L','L');

        } else if($tipo=='asig'||$tipo=='devol'){           
			
			$this->anchors= array(35,100,300,70,50,70,300);
            $this->aligns= array('L','L','L','L');
        } else {
            //Alta
            //$this->anchors= array(10,35,100,20,90);
            $this->anchors= array(28,110,300,120,115,95,62,73);
            $this->aligns= array('L','L','C','L');
        }
       
    }

    function write($fileName){
        $this->pdf = new CustomReport('landscape', PDF_UNIT, "LETTER", true, 'UTF-8', false);
        
        $this->pdf->setDataDetalle($this->getDataSource());
		$this->pdf->setDataMaster($this->getDataMaster());
        
        $dataSource = $this->getDataSource();
        $this->pdf->SetCreator(PDF_CREATOR);
        $this->pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);
        $this->pdf->SetMargins(PDF_MARGIN_LEFT, 30, PDF_MARGIN_RIGHT);
        $this->pdf->SetHeaderMargin(7);
        $this->pdf->SetFooterMargin(30);

        //set auto page breaks
        $this->pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);

        //set image scale factor
        $this->pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);

        // add a page
        $this->pdf->AddPage();

        $this->pdf->SetFontSize(7.5);
        //$this->pdf->SetFont('', 'B');
        

        //DETALLE REPORTE
        $count = 1;
        /*if($this->pdf->getTipoMov()=='asig'||$this->pdf->getTipoMov()=='devol'){
            $this->pdf->SetY(54.8);
        } else {
            $this->pdf->SetY(50.4);    
        }*/
        $this->pdf->SetY($this->pdf->getPosY());
        
        $this->specificArray($this->pdf->getTipoMov());
        //$this->pdf->MultiRow($this->dd,$this->anchors,$this->aligns);
        $this->htmlTable();
        $this->pdf->writeHTML($this->html,true,false,false,false);
        $this->pdf->Output($fileName, 'F');
    }

    public function htmlTable(){
        $this->html= '<table border="0.7">';
        foreach ($this->dd as $datarow) {
            $this->html.='<tr>';
            for($i=0;$i<count($datarow);$i++){
                $this->html.='<td width="'.$this->anchors[$i].'">'.$datarow[$i].'</td>';
            }
            $this->html.='</tr>';
        }
        
        $this->html.= '</table>';
    }
	
}

?>
