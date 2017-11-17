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
    private $swEncabezado=0; //variable que define si ya se imprimir el encabezado
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
        $this->docexcel->setActiveSheetIndex(0);
        $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


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
            if(count($this->datos_detalle)==0){
                $i = 13;
            }

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN/*,
                        'color' => array('argb' => 'FFFF0000'),*/
                    ),
                )
            );

            $limit = count($this->datos_detalle);
            $fin = (11+$limit)-1;

            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->applyFromArray($styleArray);
            //$this->docexcel->getActiveSheet()->setShowGridlines(true);
            $this->docexcel->getActiveSheet()->getStyle('B11:H'.$fin)->getAlignment()->setWrapText(true);
            //$this->docexcel->getActiveSheet()->insertNewRowBefore($fin, $limit);
            $this->docexcel->getActiveSheet()->mergeCells('G10:H10');
            $styleArray = array(
                'font'  => array(
                    'bold'  => false,
                    'color' => array('rgb' => '000000'),
                    'size'  => 9,
                    'name'  => 'Verdana'
                ));
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B10')->getAlignment()->applyFromArray(
                    array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
                );

                //$this->docexcel->getActiveSheet()->getStyle('B'.$i.':H'.$i)->applyFromArray($styleArray);
                //$this->docexcel->getActiveSheet()->getStyle('B'.$i)->applyFromArray();
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$i,$cont);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(2,$i,$detalle['codigo']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$i,$detalle['denominacion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$i,$detalle['descripcion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(5,$i,$detalle['estado_fun']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$i,'');
                $i++;
                $cont++;
            }
            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    )
                )
            );

            //$this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);

            $i = $i + 1;

                if($this->datos_maestro[0]['custodio']!=''){
                    $this->docexcel->getActiveSheet()->getStyle('B'.$i.':H'.$i)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':D'.$i);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':F'.$i);
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                }else{
                    $this->docexcel->getActiveSheet()->getStyle('B'.$i.':G'.$i)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':D'.$i);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':G'.$i);
                }


            $this->docexcel->getActiveSheet()->getRowDimension($i)->setRowHeight(50);
            //firmas
            $this->firmas($i+1);

        }else if($this->datos_maestro[0]['cod_movimiento'] == 'transf'){
            $this->docexcel = $objReader->load(dirname(__FILE__)."/Transferencia.xlsx");

            $this->docexcel->setActiveSheetIndex(0);

            $this->docexcel->getActiveSheet()->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
            $this->docexcel->getActiveSheet()->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_A4);
            $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


            $this->docexcel->getActiveSheet()->SetCellValue('H1', $this->datos_maestro[0]['num_tramite']);
            $this->docexcel->getActiveSheet()->SetCellValue('H2', date_format(date_create($this->datos_maestro[0]['fecha_mov']),'d/m/y'));
            $this->docexcel->getActiveSheet()->SetCellValue('H3', '1/1');
            $this->docexcel->getActiveSheet()->SetCellValue('C5',  $this->datos_maestro[0]['responsable']);
            $this->docexcel->getActiveSheet()->SetCellValue('C6',  $this->datos_maestro[0]['lugar_funcionario']);
            $this->docexcel->getActiveSheet()->SetCellValue('C7',  $this->datos_maestro[0]['oficina_funcionario']);
            $this->docexcel->getActiveSheet()->SetCellValue('C8',  $this->datos_maestro[0]['direccion_funcionario']);

            $this->docexcel->getActiveSheet()->SetCellValue('F5',  $this->datos_maestro[0]['responsable_dest']);
            $this->docexcel->getActiveSheet()->SetCellValue('F6',  $this->datos_maestro[0]['lugar']);
            $this->docexcel->getActiveSheet()->SetCellValue('F7',  $this->datos_maestro[0]['oficina']);
            $this->docexcel->getActiveSheet()->SetCellValue('F8',  $this->datos_maestro[0]['direccion']);


            $this->docexcel->getActiveSheet()->SetCellValue('B11',  mb_strtoupper($this->datos_maestro[0]['glosa']));

            $i = 14;
            $cont = 1;
            if(count($this->datos_detalle)==0){
                $i = 16;
            }


            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    ),
                ),
            );

            $limit = count($this->datos_detalle);

            $fin = (14+$limit)-1;


            $this->docexcel->getActiveSheet()->getStyle('B14:H'.$fin)->applyFromArray($styleArray);
            $this->docexcel->getActiveSheet()->getStyle('B14:H'.$fin)->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->mergeCells('G13:H13');
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B13')->getAlignment()->applyFromArray(
                    array('horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,)
                );
                //$this->docexcel->getActiveSheet()->getStyle('B'.$i.':H'.$i)->getAlignment()->setWrapText(true);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$i,$cont);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(2,$i,$detalle['codigo']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$i,$detalle['denominacion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$i,$detalle['descripcion']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(5,$i,$detalle['estado_fun']);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$i,'');
                $i++;
                $cont++;
            }

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    )
                )
            );
            $i = $i + 1;
            if($this->datos_maestro[0]['custodio']!=''){
                $this->docexcel->getActiveSheet()->getStyle('B'.$i.':H'.$i)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':C'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':F'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
            }else{
                $this->docexcel->getActiveSheet()->getStyle('B'.$i.':F'.$i)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':C'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':F'.$i);
            }
            $this->docexcel->getActiveSheet()->getRowDimension($i)->setRowHeight(50);
            //firmas
            $this->firmas($i+1);

        }else if($this->datos_maestro[0]['cod_movimiento'] == 'devol'){
            $this->docexcel = $objReader->load(dirname(__FILE__)."/Devolucion.xlsx");

            $this->docexcel->setActiveSheetIndex(0);

            $this->docexcel->getActiveSheet()->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
            $this->docexcel->getActiveSheet()->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_A4);
            $this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));


            $this->docexcel->getActiveSheet()->SetCellValue('H1', $this->datos_maestro[0]['num_tramite']);
            $this->docexcel->getActiveSheet()->SetCellValue('H2', date_format(date_create($this->datos_maestro[0]['fecha_mov']),'d/m/y'));
            $this->docexcel->getActiveSheet()->SetCellValue('H3', '1/1');
            $this->docexcel->getActiveSheet()->SetCellValue('C5',  $this->datos_maestro[0]['responsable']);
            $this->docexcel->getActiveSheet()->SetCellValue('C6',  $this->datos_maestro[0]['lugar_funcionario']);
            $this->docexcel->getActiveSheet()->SetCellValue('C7',  $this->datos_maestro[0]['oficina_funcionario']);
            $this->docexcel->getActiveSheet()->SetCellValue('C8',  $this->datos_maestro[0]['direccion_funcionario']);


            if($this->datos_maestro[0]['id_funcionario_dest']==null){
                $this->docexcel->getActiveSheet()->SetCellValue('F5', $this->datos_maestro[0]['responsable_depto']);
                $this->docexcel->getActiveSheet()->SetCellValue('F6', $this->datos_maestro[0]['lugar_responsable']);
                $this->docexcel->getActiveSheet()->SetCellValue('F7', $this->datos_maestro[0]['oficina_responsable']);
                $this->docexcel->getActiveSheet()->SetCellValue('F8', $this->datos_maestro[0]['direccion_responsable']);
            }else {
                $this->docexcel->getActiveSheet()->SetCellValue('F5', $this->datos_maestro[0]['responsable_dest']);
                $this->docexcel->getActiveSheet()->SetCellValue('F6', $this->datos_maestro[0]['lugar_destino']);
                $this->docexcel->getActiveSheet()->SetCellValue('F7', $this->datos_maestro[0]['oficina_destino']);
                $this->docexcel->getActiveSheet()->SetCellValue('F8', $this->datos_maestro[0]['direccion']);
            }


            $this->docexcel->getActiveSheet()->SetCellValue('B11',  mb_strtoupper($this->datos_maestro[0]['glosa']));

            $i = 14;
            $cont = 1;
            if(count($this->datos_detalle)==0){
                $i = 16;
            }


            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    ),
                ),
            );

            $limit = count($this->datos_detalle);
            $fin = (14+$limit)-1;

            $this->docexcel->getActiveSheet()->getStyle('B14:H'.$fin)->applyFromArray($styleArray);
            $this->docexcel->getActiveSheet()->getStyle('B14:H'.$fin)->getAlignment()->setWrapText(true);
            $this->docexcel->getActiveSheet()->mergeCells('G13:H13');
            foreach ($this->datos_detalle as $detalle){
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
                $this->docexcel->getActiveSheet()->getStyle('B13')->getAlignment()->applyFromArray(
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
            $i = $i + 1;
            if($this->datos_maestro[0]['custodio']!=''){
                $this->docexcel->getActiveSheet()->getStyle('B'.$i.':H'.$i)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':C'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':F'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('G'.$i.':H'.$i);
            }else{
                $this->docexcel->getActiveSheet()->getStyle('B'.$i.':F'.$i)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$i.':C'.$i);
                $this->docexcel->getActiveSheet()->mergeCells('E'.$i.':F'.$i);
            }
            $this->docexcel->getActiveSheet()->getRowDimension($i)->setRowHeight(50);
            //firmas
            $this->firmas($i+1);
        }

        $this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
        $this->objWriter->save($this->url_archivo);


    }
    function firmas($fila){
        //$this->docexcel->getActiveSheet()->getStyle('B'.$fila.':H'.$fila)->getAlignment()->setWrapText(true);
        $filas = $fila;
        if($this->datos_maestro[0]['cod_movimiento'] == 'transf' || $this->datos_maestro[0]['cod_movimiento'] == 'devol'){
            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    )
                ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER
                )
            );

            //$this->docexcel->getActiveSheet()->getStyle('B'.$filas.':G'.$filas+2)->getAlignment()->setWrapText(true);
            if($this->datos_maestro[0]['custodio']!='') {
                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas+2)->getAlignment()->setWrapText(true);
                if ($this->datos_maestro[0]['id_funcionario_dest'] == null) {

                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, $this->datos_maestro[0]['responsable']);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6, $filas, $this->datos_maestro[0]['custodio']);
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo']));
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6, $filas, 'CI. ' . strtoupper($this->datos_maestro[0]['ci_custodio']));
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$filas,'ENTREGUE CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$filas,'CUSTODIO');
                } else {
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, $this->datos_maestro[0]['responsable']);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, $this->datos_maestro[0]['responsable_dest']);
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6, $filas, $this->datos_maestro[0]['custodio']);
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo']));
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo_dest']));
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6, $filas, 'CI. ' . strtoupper($this->datos_maestro[0]['ci_custodio']));
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$filas,'ENTREGUE CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$filas,'CUSTODIO');
                }
            }else{
                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas+2)->getAlignment()->setWrapText(true);
                if ($this->datos_maestro[0]['id_funcionario_dest'] == null) {
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, $this->datos_maestro[0]['responsable']);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo']));
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'ENTREGUE CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');
                }else{
                    //$this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas+2)->getAlignment()->setWrapText(true);
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, $this->datos_maestro[0]['responsable_depto']);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, $this->datos_maestro[0]['responsable']);
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, $this->datos_maestro[0]['responsable_dest']);
                    $filas = $filas + 1;
                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1, $filas, strtoupper($this->datos_maestro[0]['cargo_jefe']));
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo']));
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4, $filas, strtoupper($this->datos_maestro[0]['nombre_cargo_dest']));
                    $filas = $filas + 1;

                    $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':F'.$filas)->applyFromArray($styleArray);
                    $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':C'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(3,$filas,'ENTREGUE CONFORME');
                    $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                    $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');
                }
            }
        }else{

            $styleArray = array(
                'borders' => array(
                    'allborders' => array(
                        'style' => PHPExcel_Style_Border::BORDER_THIN
                    )
                ),
                'alignment' => array(
                    'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER
                )
            );

            $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':G'.$filas+2)->getAlignment()->setWrapText(true);
            if($this->datos_maestro[0]['custodio']!='') {


                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,$this->datos_maestro[0]['responsable_depto']);

                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,$this->datos_maestro[0]['responsable']);
                $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$filas,$this->datos_maestro[0]['custodio']);
                $filas = $filas + 1;

                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,strtoupper($this->datos_maestro[0]['cargo_jefe']));
                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,strtoupper($this->datos_maestro[0]['nombre_cargo']));
                $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$filas,'CI. ' . strtoupper($this->datos_maestro[0]['ci_custodio']));

                $filas = $filas + 1;
                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':H'.$filas)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':F'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');

                $this->docexcel->getActiveSheet()->mergeCells('G'.$filas.':H'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(6,$filas,'CUSTODIO');
            }else{

                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':G'.$filas)->applyFromArray($styleArray);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,$this->datos_maestro[0]['responsable_depto']);
                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':G'.$filas);

                //$this->docexcel->getActiveSheet()->getStyle('C'.$filas.':F'.$filas)->applyFromArray($styleArray);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,$this->datos_maestro[0]['responsable']);

                $filas = $filas + 1;

                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':G'.$filas)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,strtoupper($this->datos_maestro[0]['cargo_jefe']));
                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':G'.$filas);

                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,strtoupper($this->datos_maestro[0]['nombre_cargo']));
                $filas = $filas + 1;

                $this->docexcel->getActiveSheet()->getStyle('B'.$filas.':G'.$filas)->applyFromArray($styleArray);
                $this->docexcel->getActiveSheet()->mergeCells('B'.$filas.':D'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(1,$filas,'RESPONSABLE');
                $this->docexcel->getActiveSheet()->mergeCells('E'.$filas.':G'.$filas);
                $this->docexcel->setActiveSheetIndex(0)->setCellValueByColumnAndRow(4,$filas,'RECIBI CONFORME');
            }

        }


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