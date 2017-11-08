<?php
class RAsig_Trans_DevAFXls
{
    private $docexcel;
    private $objWriter;
    private $nombre_archivo;
    private $hoja;
    private $columnas=array();
    private $fila;
    private $equivalencias=array();

    private $indice, $m_fila, $titulo;
    private $swEncabezado=0; //variable que define si ya se imprimi� el encabezado
    private $objParam;
    public  $url_archivo;

    var $datos_titulo;
    var $datos_detalle;
    var $ancho_hoja;
    var $gerencia;
    var $numeracion;
    var $ancho_sin_totales;
    var $cantidad_columnas_estaticas;
    var $s1;
    var $t1;
    var $tg1;
    var $total;
    var $datos_entidad;
    var $datos_periodo;
    var $ult_codigo_partida;
    var $ult_concepto;
    var $cont_detalle = 0;
    var $cont_clas = 0;
    var $cont_tipo = 0;
    var $cont_ges = 0;



    function __construct(CTParametro $objParam){
        $this->objParam = $objParam;
        $this->url_archivo = "../../../reportes_generados/".$this->objParam->getParametro('nombre_archivo');
        //ini_set('memory_limit','512M');
        set_time_limit(400);
        $cacheMethod = PHPExcel_CachedObjectStorageFactory:: cache_to_phpTemp;
        $cacheSettings = array('memoryCacheSize'  => '10MB');
        PHPExcel_Settings::setCacheStorageMethod($cacheMethod, $cacheSettings);

        $this->docexcel = new PHPExcel();
        /*$this->docexcel->getProperties()->setCreator("PXP")
            ->setLastModifiedBy("PXP")
            ->setTitle($this->objParam->getParametro('titulo_archivo'))
            ->setSubject($this->objParam->getParametro('titulo_archivo'))
            ->setDescription('Reporte "'.$this->objParam->getParametro('titulo_archivo').'", generado por el framework PXP')
            ->setKeywords("office 2007 openxml php")
            ->setCategory("Report File");

        $this->docexcel->setActiveSheetIndex(0);

        $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));*/



        $objReader = PHPExcel_IOFactory::createReader('Excel2007');
        //$this->docexcel = $objReader->load(dirname(__FILE__)."/Asignacion.xlsx");
        $this->docexcel->setActiveSheetIndex(0);
        $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));
        //$this->docexcel->getActiveSheet()->SetCellValue('B11', 'Hola mundo');

        /*$this->equivalencias=array(0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
            9=>'J',10=>'K',11=>'L',12=>'M',13=>'N',14=>'O',15=>'P',16=>'Q',17=>'R',
            18=>'S',19=>'T',20=>'U',21=>'V',22=>'W',23=>'X',24=>'Y',25=>'Z',
            26=>'AA',27=>'AB',28=>'AC',29=>'AD',30=>'AE',31=>'AF',32=>'AG',33=>'AH',
            34=>'AI',35=>'AJ',36=>'AK',37=>'AL',38=>'AM',39=>'AN',40=>'AO',41=>'AP',
            42=>'AQ',43=>'AR',44=>'AS',45=>'AT',46=>'AU',47=>'AV',48=>'AW',49=>'AX',
            50=>'AY',51=>'AZ',
            52=>'BA',53=>'BB',54=>'BC',55=>'BD',56=>'BE',57=>'BF',58=>'BG',59=>'BH',
            60=>'BI',61=>'BJ',62=>'BK',63=>'BL',64=>'BM',65=>'BN',66=>'BO',67=>'BP',
            68=>'BQ',69=>'BR',70=>'BS',71=>'BT',72=>'BU',73=>'BV',74=>'BW',75=>'BX',
            76=>'BY',77=>'BZ');*/

    }

    function datosHeader ( $maestro, $detalle) {
        $this->datos_maestro = $maestro;
        $this->datos_detalle = $detalle;

        /*var_dump($this->datos_maestro);
        var_dump($this->datos_detalle);exit;*/
    }



    function generarReporte(){


        /*$this->imprimeTitulo($this->docexcel->setActiveSheetIndex(0));
        $this->imprimeDatos();*/

        $objReader = PHPExcel_IOFactory::createReader('Excel2007');
        if($this->datos_maestro[0]['cod_movimiento'] == 'asig'){


            $this->docexcel = $objReader->load(dirname(__FILE__)."/Asignacion.xlsx");

            $this->docexcel->setActiveSheetIndex(0);

            $this->docexcel->getActiveSheet()->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
            $this->docexcel->getActiveSheet()->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_A4);
            $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


            $this->docexcel->getActiveSheet()->SetCellValue('H1', $this->datos_maestro[0]['num_tramite']);
            $this->docexcel->getActiveSheet()->SetCellValue('H2', date_format(date_create($this->datos_maestro[0]['fecha_mov']),'d/m/y'));
            $this->docexcel->getActiveSheet()->SetCellValue('H3', '1/1');
            $this->docexcel->getActiveSheet()->SetCellValue('C5',  $this->datos_maestro[0]['responsable']);
            $this->docexcel->getActiveSheet()->SetCellValue('C6',  $this->datos_maestro[0]['lugar']);
            $this->docexcel->getActiveSheet()->SetCellValue('C7',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('C8',  $this->datos_maestro[0]['direccion']);
            $this->docexcel->getActiveSheet()->SetCellValue('F6',  mb_strtoupper($this->datos_maestro[0]['glosa']));

            $i = 11;
            $cont = 1;

            /*$styleArray = array(
                'borders' => array(
                    'inside' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    )
                )
            );
            $this->docexcel->getDefaultStyle()->applyFromArray($styleArray);*/

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN/*,
                        'color' => array('argb' => 'FFFF0000'),*/
                    ),
                ),
            );
            $limit = count($this->datos_detalle);
            $fin = (11+$limit)-1;
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->applyFromArray($styleArray);
            //$this->docexcel->getActiveSheet()->setShowGridlines(true);
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->insertNewRowBefore(12, $limit-1);
            $this->docexcel->getActiveSheet()->mergeCells('G10:H10');
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B10')->getAlignment()->applyFromArray(
                    array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
                );
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$i,$cont);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(2,$i,$detalle['codigo']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$i,$detalle['denominacion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$i,$detalle['descripcion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(5,$i,$detalle['estado_fun']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$i,'');
                $i++;
                $cont++;
            }

            $this->docexcel->getActiveSheet()->getRowDimension($i+1)->setRowHeight(50);

            /*$pie = $fin+2;
            $this->docexcel->getActiveSheet()->getStyle('B'.($pie).':H'.($pie+3))->applyFromArray($styleArray);
            //$this->docexcel->getActiveSheet()->getStyle('B'.($fin+1).':H'.($fin+5))->getAlignment()->setWrapText(true);
            //$this->docexcel->getActiveSheet(0)->getColumnDimensionByColumn(1)->setAutoSize(true);
            $this->docexcel->getActiveSheet()->mergeCells('B'.$pie.':D'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$pie,'');
            //$this->docexcel->getActiveSheet(0)->getColumnDimensionByColumn(4)->setAutoSize(true);
            $this->docexcel->getActiveSheet()->mergeCells('E'.$pie.':F'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$pie,'');
            //$this->docexcel->getActiveSheet(0)->getColumnDimensionByColumn(6)->setAutoSize(true);
            $this->docexcel->getActiveSheet()->mergeCells('G'.$pie.':H'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$pie,'');

            $pie ++;
            $this->docexcel->getActiveSheet()->mergeCells('B'.$pie.':D'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$pie,$detalle['responsable_depto']);
            $this->docexcel->getActiveSheet()->mergeCells('E'.$pie.':F'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$pie,'HERLAN ROJAS');
            $this->docexcel->getActiveSheet()->mergeCells('G'.$pie.':H'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$pie,'');

            $pie ++;
            $this->docexcel->getActiveSheet()->getStyle('B'.$pie)->getAlignment()->applyFromArray(
                array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
            );
            $this->docexcel->getActiveSheet()->getStyle('E'.$pie)->getAlignment()->applyFromArray(
                array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
            );
            $this->docexcel->getActiveSheet()->getStyle('G'.$pie)->getAlignment()->applyFromArray(
                array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
            );
            $this->docexcel->getActiveSheet()->mergeCells('B'.$pie.':D'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$pie,'JEFE DE ACTIVOS FIJOS');
            $this->docexcel->getActiveSheet()->mergeCells('E'.$pie.':F'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$pie,'AUXILIAR DE ACTIVOS FIJOS');
            $this->docexcel->getActiveSheet()->mergeCells('G'.$pie.':H'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$pie,'');

            $pie ++;
            $this->docexcel->getActiveSheet()->mergeCells('B'.$pie.':D'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$pie,'RESPONSABLE');
            $this->docexcel->getActiveSheet()->mergeCells('E'.$pie.':F'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$pie,'RECIBI CONFORME');
            $this->docexcel->getActiveSheet()->mergeCells('G'.$pie.':H'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$pie,'* CUSTODIO');

            $pie = $pie + 2;
            $this->docexcel->getActiveSheet()->mergeCells('B'.$pie.':H'.$pie);
            $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$pie,'* Esta casilla sera firmada por personal que trabaja en la empresa pero no figura en las planillas de BOA');*/


        }else if($this->datos_maestro[0]['cod_movimiento'] == 'transf'){
            $this->docexcel = $objReader->load(dirname(__FILE__)."/Transferencia.xlsx");

            $this->docexcel->setActiveSheetIndex(0);
            $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


            $this->docexcel->getActiveSheet()->SetCellValue('H1', $this->datos_maestro[0]['num_tramite']);
            $this->docexcel->getActiveSheet()->SetCellValue('H2', date_format(date_create($this->datos_maestro[0]['fecha_mov']),'d/m/y'));
            $this->docexcel->getActiveSheet()->SetCellValue('H3', '1/1');
            $this->docexcel->getActiveSheet()->SetCellValue('C5',  $this->datos_maestro[0]['desc_funcionario2']);
            $this->docexcel->getActiveSheet()->SetCellValue('F5',  $this->datos_maestro[0]['funcionario_dest']);
            $this->docexcel->getActiveSheet()->SetCellValue('C6',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('C7',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('C8',  $this->datos_maestro[0]['direccion']);
            $this->docexcel->getActiveSheet()->SetCellValue('F6',  mb_strtoupper($this->datos_maestro[0]['glosa']));

            $i = 11;
            $cont = 1;

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN/*,
                        'color' => array('argb' => 'FFFF0000'),*/
                    ),
                ),
            );
            $limit = count($this->datos_detalle);
            $fin = (11+$limit)-1;
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->applyFromArray($styleArray);
            //$this->docexcel->getActiveSheet()->setShowGridlines(true);
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->insertNewRowBefore(12, $limit-1);
            $this->docexcel->getActiveSheet()->mergeCells('G10:H10');
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B10')->getAlignment()->applyFromArray(
                    array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
                );
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$i,$cont);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(2,$i,$detalle['codigo']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$i,$detalle['denominacion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$i,$detalle['descripcion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(5,$i,$detalle['estado_fun']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$i,'');
                $i++;
                $cont++;
            }

        }else if($this->datos_maestro[0]['cod_movimiento'] == 'devol'){
            $this->docexcel = $objReader->load(dirname(__FILE__)."/Devolucion.xlsx");

            $this->docexcel->setActiveSheetIndex(0);
            $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


            $this->docexcel->getActiveSheet()->SetCellValue('H1', $this->datos_maestro[0]['num_tramite']);
            $this->docexcel->getActiveSheet()->SetCellValue('H2', date_format(date_create($this->datos_maestro[0]['fecha_mov']),'d/m/y'));
            $this->docexcel->getActiveSheet()->SetCellValue('H3', '1/1');
            $this->docexcel->getActiveSheet()->SetCellValue('C5',  $this->datos_maestro[0]['responsable']);
            $this->docexcel->getActiveSheet()->SetCellValue('C6',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('C7',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('C8',  $this->datos_maestro[0]['direccion']);
            $this->docexcel->getActiveSheet()->SetCellValue('F6',  mb_strtoupper($this->datos_maestro[0]['glosa']));

            $i = 11;
            $cont = 1;

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN/*,
                        'color' => array('argb' => 'FFFF0000'),*/
                    ),
                ),
            );

            $limit = count($this->datos_detalle);
            $fin = (11+$limit)-1;
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->applyFromArray($styleArray);
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->insertNewRowBefore(12, $limit-1);
            $this->docexcel->getActiveSheet()->mergeCells('G10:H10');
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B10')->getAlignment()->applyFromArray(
                    array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
                );
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$i,$cont);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(2,$i,$detalle['codigo']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$i,$detalle['denominacion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$i,$detalle['descripcion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(5,$i,$detalle['estado_fun']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$i,'');
                $i++;
                $cont++;
            }
        }


       /* header('Content-Type: application/vnd.openxmlformatsofficedocument.spreadsheetml.sheet');
        header('Content-Disposition:attachment;filename="'.$this->url_archivo.'"');
        header('Cache-Control:max-age=0');*/

        //$this->docexcel->setActiveSheetIndex(0);
        $this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
        $this->objWriter->save($this->url_archivo);


    }

    /*function currencyFormat($currency) {
        if($currency == 'THB'):
            $currencyFormat = "#,#0.## \à¸¿;[Red]-#,#0.## \à¸¿";
        else:
            $currencyFormat = "#,#0.## \$;[Red]-#,#0.## \$";
        endif;
        return $currencyFormat;
    }*/


}

?>