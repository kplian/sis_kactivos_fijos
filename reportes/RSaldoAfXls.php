<?php
/**
*@package pXP
*@file RSaldoAfXls.php
*@author  RCM
*@date 19/10/2020
*@description Reporte de Saldos y comparación BS y UFV
*/
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #AF-13  KAF       ETR           19/10/2020  RCM         Creación del archivo
 ***************************************************************************/
class RSaldoAfXls
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
		$titulo1 = "SALDO ACTIVOS FIJOS";
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,13,'Arial');//#55
		$sheet->mergeCells('A1:F1');

		//Título 1
		$titulo2 = "COMPARACIÓN BOLIVIANOS - UNIDAD DE FOMENTO A LA VIVIENDA";
		$this->cell($sheet,$titulo2,'A2',0,2,"center",true,$this->tam_letra_titulo,'Arial');//#55
		$sheet->mergeCells('A2:F2');

		//Título 2
		$titulo3 = "Al ".date("d/m/Y",strtotime($this->objParam->getParametro('fecha')));
		$this->cell($sheet,$titulo3,'A3',0,3,"center",true,$this->tam_letra_subtitulo,'Arial');//#55
		$sheet->mergeCells('A3:F3');

		//Logo
		$objDrawing = new PHPExcel_Worksheet_Drawing();
		$objDrawing->setName('Logo');
		$objDrawing->setDescription('Logo');
		$objDrawing->setPath(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO']);
		$objDrawing->setHeight(50);
		$objDrawing->setWorksheet($this->docexcel->setActiveSheetIndex(0));

		$this->fila = 5;
	}


	function cell($sheet,$texto,$cell,$x,$y,$align="left",$bold=true,$size=10,$name='Arial',$wrap=false,$border=false,$valign='center',$number=false){ //#55
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

		$this->cell($sheet,'BOLIVIANOS',						"E".($f -1), 4, ($f - 1),"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'UNIDAD DE FOMENTO A LA VIVIENDA',	"I".($f -1), 8, ($f - 1),"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'COMPROBACIÓN TIPO DE CAMBIO',		"M".($f -1), 12, ($f - 1),"center",true,$this->tam_letra_detalle,'Arial',true,true);

		$sheet->mergeCells('E'.($f -1).':H'.($f -1));
		$sheet->mergeCells('I'.($f -1).':L'.($f -1));
		$sheet->mergeCells('M'.($f -1).':P'.($f -1));

		$this->cell($sheet, 'CODIGO',					"A$f", 0,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'CODIGO SAP',				"B$f", 1,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DENOMINACION',				"C$f", 2,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VIDA UTIL RESTANTE',		"D$f", 3,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR ACTUALIZADO',		"E$f", 4,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION ACUMULADA',	"F$f", 5,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION DEL PERIODO',	"G$f", 6,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR NETO',				"H$f", 7,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR ACTUALIZADO',		"I$f", 8,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION ACUMULADA',	"J$f", 9,  $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION DEL PERIODO',	"K$f", 10, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR NETO',				"L$f", 11, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR ACTUALIZADO',		"M$f", 12, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION ACUMULADA',	"N$f", 13, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'DEPRECIACION DEL PERIODO',	"O$f", 14, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);
		$this->cell($sheet, 'VALOR NETO',				"P$f", 15, $f, "center", true, $this->tam_letra_detalle, 'Arial', true, true);

		$this->fila++;

		//Renderiza los datos
		$sheet->fromArray(
		    $this->dataSet, // The data to set
		    NULL,        	// Array values with this value will not be set
		    'A6'         	// Top left coordinate of the worksheet range where we want to set these values (default is A1)
		);

		//Coloreado de las columnas
		$sheet->getStyle('A5:D5')->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#0000FF')
		        )
		    )
		);

		$sheet->getStyle('E4:H5')->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#FF7F50')
		        )
		    )
		);

		$sheet->getStyle('I4:L5')->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#00BFFF')
		        )
		    )
		);

		$sheet->getStyle('M4:P5')->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#483D8B')
		        )
		    )
		);

		$range = count($this->dataSet)+6;
		$sheet->getStyle('M6:P'.$range)->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#7FFFD4')
		        )
		    )
		);


		$this->fila=$f+6;
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
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);//#55
		$f++;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);*///#55
	}

	function initializeColumnWidth($sheet){
		$sheet->getColumnDimension('A')->setWidth(25);
		$sheet->getColumnDimension('B')->setWidth(25);
		$sheet->getColumnDimension('C')->setWidth(40);
		$sheet->getColumnDimension('D')->setWidth(25);
		$sheet->getColumnDimension('E')->setWidth(25);
		$sheet->getColumnDimension('F')->setWidth(25);
		$sheet->getColumnDimension('G')->setWidth(25);
		$sheet->getColumnDimension('H')->setWidth(25);
		$sheet->getColumnDimension('I')->setWidth(25);
		$sheet->getColumnDimension('J')->setWidth(25);
		$sheet->getColumnDimension('K')->setWidth(25);
		$sheet->getColumnDimension('L')->setWidth(25);
		$sheet->getColumnDimension('M')->setWidth(25);
		$sheet->getColumnDimension('N')->setWidth(25);
		$sheet->getColumnDimension('O')->setWidth(25);
		$sheet->getColumnDimension('P')->setWidth(25);
	}

}
?>