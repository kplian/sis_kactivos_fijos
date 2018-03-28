<?php
/*
 * Autor RCM
 * Fecha: 30/11/2017
 * 
 * */
class RDetalleDepreciacion extends ReportePDF {
	var $dataMaster;
	var $datos_detalle;
	var $ancho_hoja;
	var $numeracion;
	var $ancho_sin_totales;
	var $tipoMov;
    var $posY;
    var $fecha;
    var $moneda;
	
	function getDataSource(){
		return  $this->datos_detalle;		
	}

    function setFecha($val){
        $this->fecha = $val;
    }

    function setMoneda($val){
        $this->moneda = $val;
    }
	
	function datosHeader  ( $maestro, $detalle ) {
		$this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-10;
		$this->datos_detalle = $detalle;
		$this->dataMaster = $maestro;	
		$this->tipoMov = $this->dataMaster[0]['cod_movimiento']; 
		
		$this->SetMargins(7, 52, 10);

	}
	
	function Header() {
		$height = 6;
        $midHeight = 9;
        $longHeight = 18;

        $x = $this->GetX();
        $y = $this->GetY();
        $this->SetXY($x, $y);
       
		//$this->Image(dirname(__FILE__).'/../../lib/'.$_SESSION['_DIR_LOGO'], 10,5,35,20);
		$this->Image(dirname(__FILE__).'/../../lib/imagenes/logos/logo.jpg', 10,5,35,16);

        $this->SetFontSize(12);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
       
        $this->Cell(168, $midHeight, 'BOLIVIANA DE AVIACION', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->tipoMov = $this->dataMaster[0]['cod_movimiento']; 

        $x = $this->GetX();
        $y = $this->GetY();
        $this->Ln();
        $this->SetFontSize(10);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(168, $midHeight, 'DETALLE DEPRECIACION DE ACTIVOS FIJOS', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetFontSize(7);

        $width1 = 15;
        $width2 = 25;
        $this->SetXY($x, $y);

        $this->SetFont('', '');
        $this->Cell(44, $longHeight, '', 1, 0, 'C', false, '', 0, false, 'T', 'C');

        $this->SetXY($x, $y+3);
        $this->setCellPaddings(2);
        $this->Cell($width1-4, $height, 'CÓDIGO:', "B", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $this->SetFontSize(6);
        $this->Cell($width2+8, $height,$this->dataMaster[0]['num_tramite'], "B", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->SetFontSize(7);
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        $this->Cell($width1-4, $height, 'FECHA:', "", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        $cab_fecha = date("d/m/Y",strtotime($this->dataMaster[0]['fecha_mov']));
        $this->Cell($width2+8, $height,$cab_fecha, "", 0, 'L', false, '', 0, false, 'T', 'C');
        $this->setCellPaddings(2);
        $this->Ln();
        $this->SetX($x);
        $this->SetFont('', '');
        //$this->Cell($width1-4, $height, 'PAGINA:', "B", 0, '', false, '', 0, false, 'T', 'C');
        $this->Cell($width1-4, $height, '', "", 0, '', false, '', 0, false, 'T', 'C');
        $this->SetFont('', 'B');
        //$this->Cell($w = $width2, $h = $height, $txt = $this->getAliasNumPage() . ' de ' . $this->getAliasNbPages(), $border = "B", $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        $this->Cell($w = $width2, $h = $height, $txt = '', $border = "", $ln = 0, $align = 'C', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
        $this->setCellPaddings(2);
		
		//$this->Ln();
		$this->fieldsHeader($this->tipoMov);
		$this->generarCabecera($this->tipoMov);
		
	}

    public function fieldsHeader($tipo){

        $this->SetFontSize(10);
        $this->Ln(5);

        //Al
        $this->SetFont('', 'B');
        $this->Cell(265, $height,'Al '.$this->fecha, "", 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Ln();
        $this->Cell(265, $height,'(Expresado en '.$this->moneda.')', "", 0, 'C', false, '', 0, false, 'T', 'C');
        $this->SetFont('', '');
        $this->MultiCell($w = 0, $h = $hLong, $txt = $this->cortar_texto($this->dataMaster[0]['glosa'],495), $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);
        $this->firstPage++;
        
        $this->posY = $this->GetY();

    }

	function Firmas() {
		$this->SetFontSize(7);
        
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
                $_firma311='* CUSTODIO';    
            }
        }
		
		
		if($this->tipoMov=='transf'){
            $_firma100=$this->cortar_texto_firma($this->dataMaster[0]['responsable_depto']);
            $_firma110='RESPONSABLE ACTIVOS FIJOS';
            $_firma111='SUPERVISOR';
            
            $_firma200=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['responsable']));
            $_firma210=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['nombre_cargo']));
            $_firma211='ENTREGUE CONFORME';
            
            $_firma300=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['responsable_dest']));
            $_firma310=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['nombre_cargo_dest']));
            $_firma311='RECIBÍ CONFORME';

            if($this->dataMaster[0]['custodio']!=''){
                $_firma400=strtoupper($this->dataMaster[0]['custodio']);
                $_firma410='CI. '.strtoupper($this->dataMaster[0]['ci_custodio']);
                $_firma411='* CUSTODIO';    
            }
        }

        if($this->tipoMov=='devol'){
            $_firma100=$this->dataMaster[0]['responsable_depto'];
            $_firma110='RESPONSABLE ACTIVOS FIJOS';
            $_firma111='RECIBÍ CONFORME';
            
            $_firma200=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['responsable']));
            $_firma210=$this->cortar_texto_firma(strtoupper($this->dataMaster[0]['nombre_cargo']));
            $_firma211='ENTREGUÉ CONFORME';

            if($this->dataMaster[0]['custodio']!=''){
                $_firma300=strtoupper($this->dataMaster[0]['custodio']);
                $_firma310='CI. '.strtoupper($this->dataMaster[0]['ci_custodio']);
                $_firma311='* CUSTODIO';    
            }

        }


        //Bordes
        $border1='';//'LRT';
        $border2='';//'LR';
        $border3='';//'LRBT';

        $this->Cell(64, $midHeight, '', $border1, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border1, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border1, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', $border1, 1, 'C', false, '', 0, false, 'T', 'C');
         
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', $border2, 1, 'C', false, '', 0, false, 'T', 'C');
        
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', $border2, 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, '', $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, '', $border2, 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(64, $midHeight, $_firma100, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma200, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma300, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma400, $border2, 1, 'C', false, '', 0, false, 'T', 'C');

        $this->Cell(64, $midHeight, $_firma110, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma210, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma310, $border2, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma410, $border2, 1, 'C', false, '', 0, false, 'T', 'C');
        
        $this->Cell(64, $midHeight, $_firma111, $border3, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma211, $border3, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(64, $midHeight, $_firma311, $border3, 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(63, $midHeight, $_firma411, $border3, 1, 'C', false, '', 0, false, 'T', 'C');

        //Nota a pie
        $this->Ln(5);
        if($this->tipoMov=='asig'){
            if($this->dataMaster[0]['custodio']!=''){
                $this->Cell(130, $midHeight, '* Esta casilla será firmada por personal que trabaja en la empresa pero no figura en planillas', $border1, 0, 'L', false, '', 0, false, 'T', 'C');
            }
            
        } else if($this->tipoMov=='transf'){
            if($this->dataMaster[0]['custodio']!=''){
                $this->Cell(130, $midHeight, '* Esta casilla será firmada por personal que trabaja en la empresa pero no figura en planillas', $border1, 0, 'L', false, '', 0, false, 'T', 'C');
            }
             
        } else if($this->tipoMov=='devol'){
            if($this->dataMaster[0]['custodio']!=''){
                $this->Cell(130, $midHeight, '* Esta casilla será firmada por personal que trabaja en la empresa pero no figura en planillas', $border1, 0, 'L', false, '', 0, false, 'T', 'C');
            }
            
        }
		
		
	}

    function cortar_texto_firma($texto){
        $lim=39;
        $len = strlen($texto);
        $cad = $texto;
        if($len > $lim){
            $cad = substr($texto, 0, $lim).' ...';
        }
        return $cad;
    }

    function cortar_texto($texto,$lim){
        $len = strlen($texto);
        $cad = $texto;
        if($len > $lim){
            $cad = substr($texto, 0, $lim).' ...';
        } 
        return $cad;
    }
   
   function generarReporte() {
        $this->setFontSubsetting(false);
        $this->AddPage();
        $tipo = $this->tipoMov;

        $this->SetFontSize(6);

        //Definición de la fila donde empezar a desplegar los datos
        $this->SetY($this->posY+12);
        $i=0;
        foreach ($this->getDataSource() as $datarow) {
               
			  $this->tablealigns=array('L','L','L','L','L','L','L','L','L','L','L','L','L','L','L');
		      $this->tablenumbers=array(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		      $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
	          $this->tabletextcolor=array();
			  $RowArray = array(
	            			's0' => $datarow['codigo'],
	            			's1' => $datarow['denominacion'],   
	                        's2' => $datarow['fecha_ini_dep'],        
	                        's3' => $datarow['monto_vigente_orig_100'],
	                        's4' => $datarow['monto_vigente_orig'],            
	                        's5' => $datarow['inc_actualiz'],
                            's6' => $datarow['monto_actualiz'],
                            's7' => $datarow['vida_util_orig'],
                            's8' => $datarow['vida_util'],
                            's9' => $datarow['depreciacion_acum_gest_ant'],
                            's10' => $datarow['depreciacion_acum_actualiz_gest_ant'],
                            's11' => $datarow['depreciacion_per'],
                            's12' => $datarow['depreciacion_acum'],
	                        's13' => $datarow['monto_vigente']);
			
            $i++;
			
			$this-> MultiRow($RowArray,false,1);
			$this->revisarfinPagina();
			
        }
		$this->Ln(10);	
		$this->Firmas();
		
   } 
   
   function generarCabecera($tipo){
		//armca caecera de la tabla
		$this->SetFontSize(7.5);
        $this->SetFont('', 'B');
        $this->Ln(5);
	        
        $this->tablewidthsHD=array(20,35,15,17,17,17,18,18,18,18,18,18,18,18);			  
        $this->tablealignsHD=array('C','C','C','C','C','C','C','C','C','C','C','C','C','C');
        $this->tablenumbersHD=array(0,0,0,0,0,0,0,0,0,0,0,0,0);
        $this->tablebordersHD=array('TB','TB','TB','TB','TB','TB','TB');
        $this->tabletextcolorHD=array();
        $RowArray = array(
        			's0'  => 'Código',
        			's1' => 'Descripción',
                    's2' => 'Inicio Dep.',
                    's3' => 'Compra(100%)',
                    's4' => 'Compra(87%)',
                    's5' => 'Inc.x Actualiz.',
                    's6' => 'Valor Actualiz.',
                    's7' => 'VU. Usada',
                    's8' => 'VU. Residual',
                    's9' => 'Dep.Acum.Gest.Ant.',
                    's10' => 'Act.Deprec.Gest.Ant.',
                    's11' => 'Dep.Gestión',
                    's12' => 'Dep.Acum.',
                    's13' => 'Valor Residual');
	
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