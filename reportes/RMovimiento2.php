<?php
// Extend the TCPDF class to create custom MultiRow
/*
 * Autor RAC
 * Fecha: 16/03/2017
 ****************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-41     KAF       ETR           01/03/2021  RCM         Modificación de Columnas para el caso de Altas
************************************************************************** 
 * */
class RMovimiento2 extends ReportePDF {
    var $dataMaster;
    var $datos_detalle;
    var $ancho_hoja;
    var $gerencia;
    var $numeracion;
    var $ancho_sin_totales;
    var $tipoMov;
    var $posY;
    
    function getDataSource(){
        return  $this->datos_detalle;       
    }
    
    function datosHeader  ( $maestro, $detalle ) {
        $this->ancho_hoja = $this->getPageWidth()-PDF_MARGIN_LEFT-PDF_MARGIN_RIGHT-10;
        $this->datos_detalle = $detalle;
        $this->dataMaster = $maestro;   
        $this->tipoMov = $this->dataMaster[0]['cod_movimiento']; 
        
        if($this->tipoMov=='asig'||$tipo=='devol'){
            $this->SetMargins(7, 55, 5);
        } 
        else if ($this->tipoMov=='deprec'){
            $this->SetMargins(7, 53, 5);
         }
        else{
            $this->SetMargins(7, 52, 5);
        }   
    }
    
    function Header() {
        $height = 6;
        $midHeight = 9;
        $longHeight = 18;

        $x = $this->GetX();
        $y = $this->GetY();
        $this->SetXY($x, $y);
       
        //$this->Image(dirname(__FILE__).'/../../lib/'.$_SESSION['_DIR_LOGO'], 10,5,35,20);
        //$this->Image(dirname(__FILE__).'/../../lib/imagenes/logos/logo.jpg', 10,5,35,16);
        $this->Image(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO'], 10,5,35,16);

        $this->SetFontSize(12);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
       
        $this->Cell(168, $midHeight, 'FORMULARIO DE '.strtoupper($this->dataMaster[0]['movimiento']).' DE ACTIVOS FIJOS', 'LRT', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->tipoMov = $this->dataMaster[0]['cod_movimiento']; 

        $x = $this->GetX();
        $y = $this->GetY();
        $this->Ln();
        $this->SetFontSize(10);
        $this->SetFont('', 'B');
        $this->Cell(53, $midHeight, '', 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');
        $this->Cell(168, $midHeight, strtoupper($this->dataMaster[0]['depto']), 'LRB', 0, 'C', false, '', 0, false, 'T', 'C');

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
            $this->Ln(2);
            if($tipo=='asig'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Responsable:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['responsable'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->SetFont('', 'B');

                //Ciudad
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Ciudad:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['lugar'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                 
                //Custodio
                $this->SetFont('', 'B');
                $lblCust='Custodio:';

                $this->Cell(35, $height,$lblCust, "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['custodio'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

                //Oficina
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Oficina:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['oficina'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                
                //Dirección
                $this->SetFont('', 'B');
                $this->Cell(135, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->Cell(25, $height,'Dirección:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->MultiCell($w = 100, $h = $hGlobal, $txt = $this->cortar_texto($this->dataMaster[0]['direccion'],165), $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);
                $this->Cell(135, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
            } else if($tipo=='devol'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Responsable:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['responsable'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->SetFont('', 'B');
                 $this->SetFont('', 'B');
                $lblCust='Custodio:';
                $this->Cell(35, $height,$lblCust, "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['custodio'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->Ln(0.4);
                
                
            } else if ($tipo=='deprec'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Depreciación hasta:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['fecha_hasta'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            } else if ($tipo=='actua'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Actualización hasta:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['fecha_hasta'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
            }else if($tipo=='transf'){
                $this->Ln();
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Origen:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['responsable'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                $this->SetFont('', 'B');

                //Ciudad
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Ciudad:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['lugar'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                 
                //Custodio
                $this->SetFont('', 'B');
                $this->Cell(35, $height,'Destino:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['responsable_dest'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');

                //Oficina
                $this->SetFont('', 'B');
                $this->Cell(25, $height,'Oficina:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['oficina'], $border = 0, $ln = 1, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                
                //Dirección
                $this->SetFont('', 'B');
                $this->Cell(135, $height,'', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->Cell(25, $height,'Dirección:', "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->MultiCell($w = 100, $h = $hGlobal, $txt = $this->cortar_texto($this->dataMaster[0]['direccion'],165), $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);

                //Custodio
                $this->SetFont('', 'B');
                $lblCust='Custodio:';
                $this->Cell(35, $height,$lblCust, "", 0, 'L', false, '', 0, false, 'T', 'C');
                $this->SetFont('', '');
                $this->Cell($w = 100,$h = $hGlobal, $txt = $this->dataMaster[0]['custodio'], $border = 0, $ln = 0, $align = 'L', $fill = false, $link = '', $stretch = 0, $ignore_min_height = false, $calign = 'T', $valign = 'M');
                
            } else if($tipo=='alta'){
                
            }

            //Estado
            $this->Ln();
            $this->SetFont('', 'B');
            $this->SetFont('', '');
            
            //Glosa
            $this->SetFont('', 'B');
            $this->Cell($width2+8, $height,'Glosa:', "", 0, 'L', false, '', 0, false, 'T', 'C');
            $this->Ln();
            $this->SetFont('', '');
            $this->MultiCell($w = 0, $h = $hLong, $txt = $this->cortar_texto($this->dataMaster[0]['glosa'],495), $border = 0, $align = 'L', $fill = false, $ln = 1, $x = '', $y = '', $reseth = true, $stretch = 0, $ishtml = false, $autopadding = true, $maxh = $hMedium, $valign = 'M', $fitcell = false);
            $this->firstPage++;
            
            $this->posY = $this->GetY();


    }

    function Firmas() {
        $this->SetFontSize(7);
        
        $_firma100='';
        $_firma110='';//$this->dataMaster[0]['responsable_depto']; --#AF-41
        $_firma111='';//'RESPONSABLE ACTIVOS FIJOS'; --#AF-41
        
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
          
          $this->SetFontSize(7);

          //Definición de la fila donde empezar a desplegar los datos
          if($this->tipoMov=='asig'){
            $this->SetY($this->posY+4.2);
          } else if($this->tipoMov=='devol'){
           $this->SetY($this->posY+4.2);
          } else if($this->tipoMov=='transf'){
            $this->SetY($this->posY+4.2);
          } else if($this->tipoMov=='alta'){
            $this->SetY($this->posY+4.2);
          } else if($this->tipoMov=='retiro'){
            $this->SetY($this->posY+4.2);
          } else if($this->tipoMov=='deprec'){
            $this->SetY($this->posY+8.2);
          } else {
            $this->SetY($this->posY+8.2);
          }

         $totalAF = 0;
         $totalCompra = 0;
         $i = 0;

		 foreach ($this->getDataSource() as $datarow) {
            if($tipo=='baja'){
               
              $this->tablealigns=array('L','L','L','L','L','L','L');
              $this->tablenumbers=array(0,0,0,0,0,0,0);
              $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
              $this->tabletextcolor=array();
              $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['descripcion'],        
                            's3' => $datarow['marca'],
                            's4' => $datarow['nro_serie'],            
                            's5' => $datarow['estado_fun'],
                            's6' => $datarow['motivo']);
                
                
            } else if($tipo=='reval'){
               
                
                $this->tablealigns=array('L','L','L','L','L','L','R','R','L');
                $this->tablenumbers=array(0,0,0,0,0,0,1,1);
                $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
                $this->tabletextcolor=array();
                
                $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['descripcion'],       
                            's4' => $datarow['marca'],
                            's5' => $datarow['nro_serie'],
                            's6' => $datarow['estado_fun'] ,  
                            's7' => $datarow['vida_util'] , 
                            's8' => $datarow['importe'] 
                            );
                

            } else if($tipo=='deprec'||$tipo=='actua'){
               
                
                $this->tablealigns=array('L','L','L','L','L','L','L');
                $this->tablenumbers=array(0,0,0,0,0,0,0);
                $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
                $this->tabletextcolor=array();
                
                $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['descripcion'],       
                            's4' => $datarow['marca'],
                            's5' => $datarow['nro_serie'],
                            's6' => $datarow['estado_fun'] ,  
                            's7' => $datarow['monto_compra'] , 
                            's8' => $datarow['importe']  
                            );
                

            } else if($tipo=='asig'||$tipo=='devol'){
                    
                            
                $this->tablealigns=array('L','L','L','L','L','L','L');
                $this->tablenumbers=array(0,0,0,0,0,0,0);
                $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
                $this->tabletextcolor=array();
                
                $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['denominacion'],
                            's3' => $datarow['descripcion'],
                            's4' => $datarow['estado_fun'] ,           
                            's5' => ''
                            );
                
                
            } else if($tipo=='transf'){
                    
                            
                $this->tablealigns=array('L','L','L','L','L','L','L');
                $this->tablenumbers=array(0,0,0,0,0,0,0);
                $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
                $this->tabletextcolor=array();
                
                $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['denominacion'],
                            's3' => $datarow['descripcion'],
                            's4' => $datarow['estado_fun'] ,           
                            's5' => $datarow['observaciones']
                            );
                
                
            } else if($tipo=='alta'){
                    
                $this->tablealigns = array('L', 'L', 'L', 'L', 'C', 'C', 'R'); //#AF-41
                $this->tablenumbers = array(0, 0, 0, 0, 0, 0, 1);
                $this->tableborders = array('RLTB', 'RLTB', 'RLTB', 'RLTB', 'RLTB', 'RLTB', 'RLTB');
                $this->tabletextcolor = array();
                //totales de montos
                $totalAF += $datarow['monto_compra_orig'];
                $totalCompra += $datarow['monto_compra_orig_100'];

                //Inicio #AF-41
                /*$RowArray = array(
                            's0' => $i+1,
                            's1' => $datarow['codigo'],
                            's2' => $datarow['desc_clasificacion'],
                            's3' => $datarow['denominacion'],
                            's4' => $datarow['vida_util_original'],//#AF-41
                            's5' => date("d/m/Y",strtotime($datarow['fecha_ini_dep'])),
                            's6' => $datarow['monto_compra_orig'],
                            's7' => $datarow['monto_compra_orig_100'],
                            's8' => $datarow['nro_cbte_asociado'],
                            's9' => ''
                            );*/

                $RowArray = array(
                            's0' => $i+1,
                            's1' => $datarow['codigo'],
                            's2' => $datarow['desc_clasificacion'],
                            's3' => $datarow['denominacion'],
                            's4' => $datarow['vida_util_original'],//#AF-41
                            's5' => date("d/m/Y",strtotime($datarow['fecha_ini_dep'])),
                            's6' => $datarow['monto_compra_orig']
                            );
                //FIn #AF-41
                
            }  else if($tipo=='retiro'){
                    
                            
                $this->tablealigns=array('L','L','L','L','L','L','L');
                $this->tablenumbers=array(0,0,0,0,0,0,0);
                $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
                $this->tabletextcolor=array();
                
                $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['denominacion'],
                            's3' => $datarow['descripcion'],
                            's4' => $datarow['estado_fun'] ,           
                            's5' => $datarow['observaciones']
                            );
                
                
            } else {
              $this->tablealigns=array('L','L','L','L','L','L','L');
              $this->tablenumbers=array(0,0,0,0,0,0,0);
              $this->tableborders=array('RLTB','RLTB','RLTB','RLTB','RLTB','RLTB','RLTB');
              $this->tabletextcolor=array();
              $RowArray = array(
                            's0'  => $i+1,
                            's1' => $datarow['codigo'],   
                            's2' => $datarow['descripcion'],   
                            's3' => $datarow['tipo_activo'],       
                            's4' => $datarow['marca'],
                            's5' => $datarow['nro_serie'],
                            's6' => $datarow['fecha_compra'] ,           
                            's7' => $datarow['estado_fun']
                            );
                
                
            }
            $i++;
            
            $this-> MultiRow($RowArray,false,1);
            $this->revisarfinPagina();
            
        }
        if($tipo=='alta'){
            $this->tablealigns=array('L','L','L','L','L','C','R','R','L','L');
            $this->tablenumbers=array(0,0,0,0,0,0,1,0,0,0);
            $this->tableborders=array('','','','','','RLTB','RLTB','','','');
            $this->tabletextcolor=array();
            $RowArray = array(
                's0'  => '',
                's1' => '',
                's2' => '',
                's3' => '',
                's4' => '',
                's5' => 'TOTALES', //#AF-41
                's6' => $totalAF //#AF-41
            );

            $this-> MultiRow($RowArray,false,1);
        }
        $this->Ln(10);  
        
        $this->Firmas();
        
   } 
   
   function generarCabecera($tipo){
		//armca caecera de la tabla
		$this->SetFontSize(9);
        $this->SetFont('', 'B');
        ///////////////////////////////////////
        if($tipo=='baja'){
            
              $this->tablewidthsHD=array(10,35,100,70,50,20,20);              
              $this->tablealignsHD=array('C','C','C','C','C','C','C');
              $this->tablenumbersHD=array(0,0,0,0,0,0,0);
              $this->tablebordersHD=array('TB','TB','TB','TB','TB','TB','TB');
              $this->tabletextcolorHD=array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Descripcion',        
                            's3' => 'Marca',
                            's4' => 'Nro. Serie',            
                            's5' => 'Estado Fun.',
                            's6' => 'Motivo');
            

        } else if($tipo=='reval'){
            
              $this->tablewidthsHD=array(8,35,90,35,25,20,20,20);
              $this->tablealignsHD=array('C','C','C','C','C','C','C');
              $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
              $this->tablebordersHD=array('TB','TB','TB','TB','TB','TB','TB','TB');
              $this->tabletextcolorHD=array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Descripcion',        
                            's3' => 'Marca',
                            's4' => 'Nro. Serie',            
                            's5' => 'Estado Fun.',
                            's6' => 'Inc.Vida Util',
                            's7' => 'Inc.Valor')  ;

        } else if($tipo=='deprec'||$tipo=='actua'){
            
              $this->tablewidthsHD=array(8,35,102,35,25,20,20,20);
              $this->tablealignsHD=array('C','C','C','C','C','C','C');
              $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
              $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TB','TB','TBR');
              $this->tabletextcolorHD=array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Descripcion',        
                            's3' => 'Marca',
                            's4' => 'Nro. Serie',            
                            's5' => 'Estado Fun.',
                            's6' => 'Imp. Compral',
                            's7' => 'Imp. Vigente');
                
        } else if($tipo=='asig'||$tipo=='devol'){
                
              $this->tablewidthsHD=array(8,25,59,90,26,57);
               //$this->tablewidths=array(8,31,84.5,34,32.5,26.5,18,20.5);
              $this->tablealignsHD=array('C','C','C','C','C','C','C','C');
              $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
              $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TBR');
              $this->tabletextcolorHD=array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Denominación',
                            's3' => 'Descripción',
                            //'s3' => 'Marca',
                            //'s4' => 'Nro. Serie',            
                            's4' => 'Estado Fun.',           
                            's5' => 'Observaciones');
            
            
            
        } else if($tipo=='transf'){
            $this->tablewidthsHD=array(8,25,59,90,26,57);
            //$this->tablewidths=array(8,31,84.5,34,32.5,26.5,18,20.5);
            $this->tablealignsHD=array('C','C','C','C','C','C','C','C');
            $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
            $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TBR');
            $this->tabletextcolorHD=array();
            $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Denominación',
                            's3' => 'Descripción',
                            's4' => 'Estado Fun.',           
                            's5' => 'Observaciones');
            
            
            
        }  else if($tipo=='alta'){
                
              $this->tablewidthsHD = array(8, 23, 60, 90, 25, 25, 33); //#AF-41
              $this->tablealignsHD = array('C', 'C', 'C', 'C', 'C', 'C', 'C');
              $this->tablenumbersHD = array(0, 0, 0, 0, 0, 0, 0);
              $this->tablenumbers = array(0, 0, 0, 0, 0, 0, 0);
              $this->tablebordersHD = array('LTBR', 'LTBR', 'LTBR', 'LTBR', 'LTBR', 'LTBR', 'LTBR');
              $this->tabletextcolorHD = array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',
                            's2' => 'Clasificación',
                            's3' => 'Denominación',
                            's4' => 'Vida Útil Orig.',//#AF-41
                            's5' => 'Fecha Ini.Dep.',           
                            's6' => 'Valor AF Bs.'
                        );
            
            
            
        } else if($tipo=='retiro'){
                
            $this->tablewidthsHD=array(8,25,50,90,26,57);
               //$this->tablewidths=array(8,31,84.5,34,32.5,26.5,18,20.5);
              $this->tablealignsHD=array('C','C','C','C','C','C','C','C');
              $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
              $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TBR');
              $this->tabletextcolorHD=array();
              $RowArray = array(
                            's0'  => 'Nro',
                            's1' => 'Código',   
                            's2' => 'Denominación',
                            's3' => 'Descripción',
                            's4' => 'Estado Fun.',           
                            's5' => 'Observaciones');
            
        } else {
            
            $this->tablewidthsHD=array(8,31,94,34,32.5,26.5,18,20.5);
            $this->tablealignsHD=array('C','C','C','C','C','C','C','C');
            $this->tablenumbersHD=array(0,0,0,0,0,0,0,0);
            $this->tablebordersHD=array('LTB','TB','TB','TB','TB','TB','TB','TBR');
            $this->tabletextcolorHD=array();
            
            $RowArray = array(
                        's0'  => 'Nro',
                        's1' => 'Código',   
                        's2' => 'Descripcion',        
                        's3' => 'Tipo de Activo',
                        's4' => 'Marca',            
                        's5' => 'Nro. Serie',
                        's6' => 'Fecha Compra',
                        's7' => 'Estado Fun.');

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