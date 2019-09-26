<?php
/*
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #26    KAF       ETR           22/08/2019  RCM         Reporte Origen de Altas
 #29    KAF       ETR           23/09/2019  RCM         Corrección reportes
***************************************************************************
*/
class RAltaOrigenXls
{
	private $objParam;
	public  $url_archivo;
	private $docexcel;
	private $dataSetMaster;
	private $dataSet;

	function __construct(CTParametro $objParam){
		$this->objParam = $objParam;
		$this->url_archivo = "../../../reportes_generados/".$this->objParam->getParametro('nombre_archivo');
		set_time_limit(400);
		$cacheMethod = PHPExcel_CachedObjectStorageFactory:: cache_to_phpTemp;
		$cacheSettings = array('memoryCacheSize'  => '10MB');
		PHPExcel_Settings::setCacheStorageMethod($cacheMethod, $cacheSettings);
		$this->docexcel = new PHPExcel();
		$this->docexcel->getProperties()->setCreator("PXP")
							 ->setLastModifiedBy("PXP")
							 ->setTitle($this->objParam->getParametro('titulo_archivo'))
							 ->setSubject($this->objParam->getParametro('titulo_archivo'))
							 ->setDescription('Reporte "'.$this->objParam->getParametro('titulo_archivo').'", generado por el framework PXP')
							 ->setKeywords("office 2007 openxml php")
							 ->setCategory("Report File");

		$this->docexcel->setActiveSheetIndex(0);
		$this->docexcel->getActiveSheet()->setTitle($this->objParam->getParametro('titulo_archivo'));
		$this->initializeColumnWidth($this->docexcel->getActiveSheet());
		$this->printerConfiguration();
	}

	function setMaster($data) {
		$this->dataSetMaster = $data;
	}

	function setData($data) {
		$this->dataSet = $data;
	}

	function generarReporte() {
		$sheet=$this->docexcel->setActiveSheetIndex(0);
		$this->imprimeTitulo($sheet);
		$this->mainBox($sheet);
		$this->firmas($sheet);
		//Set active sheet index to the first sheet, so Excel opens this as the first sheet
		$this->docexcel->setActiveSheetIndex(0);
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);
	}

	function imprimeTitulo($sheet) {
		$sheet->setCellValueByColumnAndRow(0,1,$this->objParam->getParametro('titulo_rep'));

		//Título Principal
		$titulo1 = "ALTAS POR ORIGEN DE ACTIVACIÓN";
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,16,'Arial');
		$sheet->mergeCells('A1:H1');

		//Título 2
		$titulo2 = " Del   " . $this->objParam->getParametro('fecha_desde') . ' Al '. $this->objParam->getParametro('fecha_hasta');
		$this->cell($sheet,$titulo2,'A2',0,2,"center",true,$this->tam_letra_subtitulo,'Arial');
		$sheet->mergeCells('A2:H2');

		$titulo3="(Expresado en " . $this->objParam->getParametro('desc_moneda') .")";
		$this->cell($sheet,$titulo3,'A3',0,3,"center",true,$this->tam_letra_subtitulo,'Arial');
		$sheet->mergeCells('A3:H3');

		//Logo
		$objDrawing = new PHPExcel_Worksheet_Drawing();
		$objDrawing->setName('Logo');
		$objDrawing->setDescription('Logo');
		$objDrawing->setPath(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO']);
		$objDrawing->setHeight(50);
		$objDrawing->setWorksheet($this->docexcel->setActiveSheetIndex(0));

		$this->fila = 5;
	}


	function cell($sheet,$texto,$cell,$x,$y,$align="left",$bold=true,$size=10,$name='Arial',$wrap=false,$border=false,$valign='center',$number=false){
		$sheet->getStyle($cell)->getFont()->applyFromArray(array('bold'=>$bold,'size'=>$size,'name'=>$name));
		//Alineación horizontal
		if($align=='left'){
			$sheet->getStyle($cell)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_LEFT);
		} else if($align=='right'){
			$sheet->getStyle($cell)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
		} else if($align=='center'){
			$sheet->getStyle($cell)->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_CENTER);
		}
		//Alineación vertical
		if($valign=='center'){
			$sheet->getStyle($cell)->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_CENTER);
		} else if($valign=='top'){
			$sheet->getStyle($cell)->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_TOP);
		} else if($valign=='bottom'){
			$sheet->getStyle($cell)->getAlignment()->setVertical(PHPExcel_Style_Alignment::VERTICAL_BOTTOM);
		}
		//Rendereo del texto
		$sheet->setCellValueByColumnAndRow($x,$y,$texto);

		//Wrap texto
		if($wrap==true){
			$sheet->getStyle($cell)->getAlignment()->setWrapText(true);
		}

		//Border
		if($border==true){
			$styleArray = array(
			    'borders' => array(
			        'outline' => array(
			            'style' => PHPExcel_Style_Border::BORDER_THIN//PHPExcel_Style_Border::BORDER_THICK
			        ),
			    ),
			);

			$sheet->getStyle($cell)->applyFromArray($styleArray);
		}

		if($number==true){
			$sheet->getStyle($cell)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_00);
		}
	}

	function mainBox($sheet){
		//Cabecera caja
		$f = $this->fila;

		$this->cell($sheet, 'TIPO', 						"A$f", 0, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'CÓDIGO', 						"B$f", 1, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DENOMINACIÓN', 				"C$f", 2, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'ESTADO', 						"D$f", 3, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'FECHA INI. DEP.', 				"E$f", 4, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR ACTUALIZ.', 				"F$f", 5, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		//Inicio #29: se quita columna dep. acum. inicial
		//$this->cell($sheet, 'DEP. ACUM. INICIAL', 			"G$f", 6, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VIDA ÚTIL ORIG. (MESES)',		"G$f", 6, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'NRO. TRÁMITE', 				"H$f", 7, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DESCRIPCIÓN MOVIMIENTO ALTA', 	"I$f", 8, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		//Fin #29
		$this->fila++;

		//////////////////
		//Detalle de datos
		//////////////////

		//Estilos
		$count = count($this->dataSet) +5;
		$sheet->getStyle("L5:M$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
		$sheet->getStyle("P5:W$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);


		//Renderiza los datos
		$sheet->fromArray(
		    $this->dataSet,  // The data to set
		    NULL,        	 // Array values with this value will not be set
		    'A'.$this->fila  // Top left coordinate of the worksheet range where
		                     //    we want to set these values (default is A1)
		);

		//Definición del rango total de filas
		$range = count($this->dataSet) + 6;

		//Totales
		$this->cell($sheet, 'TOTALES', "C$range", 2, $range, "right", true, $this->tam_letra_detalle, 'Arial', true, false);

		//Sólo calcula os totales si hay datos
		if($range > 6){
			$formula = "=SUM(F" . $this->fila . ":F" . ($range - 1) . ")";
			$this->cell($sheet, $formula, "F$range", 5, $range, "right", true, $this->tam_letra_detalle, 'Arial', true, false);
			//Inicio #29
			//$formula = "=SUM(G" . $this->fila . ":G" . ($range - 1) . ")";
			//$this->cell($sheet, $formula, "G$range", 6, $range, "right", true, $this->tam_letra_detalle, 'Arial', true, false);
			//Fin #29
		}

		//Actualización variables
		$this->fila = $f + 6;
	}

	function cellBorder($sheet,$range,$type='normal'){
		if($type=="normal"){
			$styleArray = array(
			    'borders' => array(
			        'outline' => array(
			            'style' => PHPExcel_Style_Border::BORDER_THIN //PHPExcel_Style_Border::BORDER_THICK,
			        ),
			    ),
			);
		} else if($type=='vertical'){
			$styleArray = array(
			    'borders' => array(
			        'vertical' => array(
			            'style' => PHPExcel_Style_Border::BORDER_THIN //PHPExcel_Style_Border::BORDER_THICK,
			        ),
			    ),
			);
		}

		$sheet->getStyle($range)->applyFromArray($styleArray);
	}

	function printerConfiguration(){
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_LANDSCAPE);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_LETTER);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setFitToWidth(1);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setFitToHeight(0);

	}

	function firmas($sheet){
		/*$f=$this->fila;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);
		$f++;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);*/
	}

	function initializeColumnWidth($sheet){
		$sheet->getColumnDimension('A')->setWidth(20);
		$sheet->getColumnDimension('B')->setWidth(20);
		$sheet->getColumnDimension('C')->setWidth(50);
		$sheet->getColumnDimension('D')->setWidth(15);
		$sheet->getColumnDimension('E')->setWidth(15);
		$sheet->getColumnDimension('F')->setWidth(20);
		//Inicio #29
		//$sheet->getColumnDimension('G')->setWidth(20);
		$sheet->getColumnDimension('G')->setWidth(20);
		$sheet->getColumnDimension('H')->setWidth(20);
		$sheet->getColumnDimension('I')->setWidth(50);
		$sheet->getColumnDimension('J')->setWidth(0);
		$sheet->getColumnDimension('K')->setWidth(0);
		$sheet->getColumnDimension('L')->setWidth(0);
		$sheet->getColumnDimension('M')->setWidth(0);
		$sheet->getColumnDimension('N')->setWidth(0);
		//Fin #29
	}

}
?>