<?php
class RDepreciacionMensualXls
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
		//$this->detalleResumen($sheet);
		//$this->detalle($sheet);
		$this->firmas($sheet);
		//Set active sheet index to the first sheet, so Excel opens this as the first sheet
		$this->docexcel->setActiveSheetIndex(0);
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);		
	}

	function imprimeTitulo($sheet) {
		$sheet->setCellValueByColumnAndRow(0,1,$this->objParam->getParametro('titulo_rep'));
		
		//Título Principal
		$titulo1 = "DEPRECIACIÓN ACTIVOS FIJOS";
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,16,Arial);
		$sheet->mergeCells('A1:W1');

		//Título 1
		$titulo1 = "(Expresado en Bolivianos)";
		$this->cell($sheet,$titulo1,'A2',0,2,"center",true,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A2:W2');
		
		//Título 2
		/*$fecha_hasta = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
		$titulo2 = "Depto.: ";
		$this->cell($sheet,$titulo2.$this->paramDepto,'A3',0,3,"center",true,$this->tam_letra_subtitulo,Arial);
		$sheet->mergeCells('A3:W3');*/
		
		//Título 3
		$titulo3="";
		$this->cell($sheet,$titulo3,'A4',0,4,"center",true,$this->tam_letra_subtitulo,Arial);
		$sheet->mergeCells('A4:W4');

		//Logo
		$objDrawing = new PHPExcel_Worksheet_Drawing();
		$objDrawing->setName('Logo');
		$objDrawing->setDescription('Logo');
		$objDrawing->setPath(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO']);
		$objDrawing->setHeight(50);
		$objDrawing->setWorksheet($this->docexcel->setActiveSheetIndex(0));

		$this->cell($sheet,'Nro. Trámite: ','A5',0,5,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['num_tramite'],'C5',2,5,"left",false,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A5:B5');
		$sheet->mergeCells('C5:H5');
		$this->cell($sheet,'Fecha Movimiento: ','A6',0,6,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['fecha_mov'],'C6',2,6,"left",false,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A6:B6');
		$sheet->mergeCells('C6:H6');
		$this->cell($sheet,'Depto.: ','A7',0,7,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['depto'],'C7',2,7,"left",false,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A7:B7');
		$sheet->mergeCells('C7:H7');
		$this->cell($sheet,'Glosa: ','A8',0,8,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['glosa'],'C8',2,8,"left",false,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A8:B8');
		$sheet->mergeCells('C8:H8');
		$this->cell($sheet,'Estado: ','A9',0,9,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['estado'],'C9',2,9,"left",false,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A9:B9');
		$sheet->mergeCells('C9:H9');
		$this->cell($sheet,'FECHA HASTA: ','A10',0,10,"right",true,$this->tam_letra_titulo,Arial);
		$this->cell($sheet,$this->dataSetMaster[0]['fecha_hasta'],'C10',2,10,"left",true,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A10:B10');
		$sheet->mergeCells('C10:H10');

		$this->fila = 11;
	}


	function cell($sheet,$texto,$cell,$x,$y,$align="left",$bold=true,$size=10,$name=Arial,$wrap=false,$border=false,$valign='center',$number=false){
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
		$this->cell($sheet,'Nro.'						,"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Código'						,"B$f",1,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Código SAP'					,"C$f",2,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Denominación'				,"D$f",3,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Fecha Ini.Dep.'				,"E$f",4,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Cantidad'					,"F$f",5,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Unidad de Medida'			,"G$f",6,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Centro de Costo'			,"H$f",7,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Nro. Serie'					,"I$f",8,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Lugar'						,"J$f",9,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Responsable Actual'			,"K$f",10,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Compra'				,"L$f",11,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Costo'						,"M$f",12,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Vida Útil Original (meses)'	,"N$f",13,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Vida Útil Residual (meses)'	,"O$f",14,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Inc.x Actualiz.'			,"P$f",15,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Actualiz.'			,"Q$f",16,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Acum. Gest.Ant.'		,"R$f",17,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Actualiz. Dep.Gest. Ant.'	,"S$f",18,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Depreciación Gestión'		,"T$f",19,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Depreciación Mensual'		,"U$f",20,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Depreciación Acum.'			,"V$f",21,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Activo'				,"W$f",22,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Desde'						,"X$f",23,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Hasta'						,"Y$f",24,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);

		$this->fila++;
		//////////////////
		//Detalle de datos
		//////////////////
		//Array totalizador


		//Estilos
		$count = count($this->dataSet) + 11;
		$sheet->getStyle("L11:M$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
		$sheet->getStyle("P11:W$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
		  

		//Renderiza los datos
		$sheet->fromArray(
		    $this->dataSet,  // The data to set
		    NULL,        // Array values with this value will not be set
		    'A12'         // Top left coordinate of the worksheet range where
		                 //    we want to set these values (default is A1)
		);


		/*$arrayTotal = array(
		 	'total'=>0
		);

		for ($fil=0; $fil < count($this->dataSet); $fil++) {
			$f++;
			//Fecha
			$fecha='';
			if($this->dataSet[$fil]['fecha_ini_dep']!=''){
				$fecha=date("d/m/Y",strtotime($this->dataSet[$fil]['fecha_ini_dep']));
			}
			$this->cell($sheet,$fil+1,"A$f",0,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['codigo'],"C$f",2,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['ci'],"D$f",3,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['total'],"E$f",4,$f,"right",false,$this->tam_letra_detalle,Arial,true,true,'center',true);
			$this->cell($sheet,$this->dataSet[$fil]['total_excento'],"F$f",5,$f,"right",false,$this->tam_letra_detalle,Arial,true,true,'center',true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['desc_funcionario2'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$range_sum='=E'.($f).'+F'.($f);
			//echo $range_sum;exit;
			$this->cell($sheet,$range_sum,"G$f",6,$f,"right",false,$this->tam_letra_detalle,Arial,true,true,'center',true);

			//Actualiza los totales
			$arrayTotal['total']+=$this->dataSet[$fil]['total'];

		}

		//Borde a la caja
		$this->cellBorder($sheet,"A".$this->fila.":E$f",'vertical');
		$this->cellBorder($sheet,"E".$this->fila.":E$f");

		//Totales
		$f++;
		$this->cell($sheet,'TOTAL BS.',"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$sheet->mergeCells("A$f:D$f");
		$this->cellBorder($sheet,"A$f:D$f");


		$range_sum='=SUM(E'.($this->fila+1).':E'.($f-1).')';
		$this->cell($sheet,$range_sum,"E$f",4,$f,"right",true,$this->tam_letra_detalle,Arial,true,true,'center',true);
		$range_sum='=SUM(F'.($this->fila+1).':F'.($f-1).')';
		$this->cell($sheet,$range_sum,"F$f",5,$f,"right",true,$this->tam_letra_detalle,Arial,true,true,'center',true);
		$range_sum='=SUM(G'.($this->fila+1).':G'.($f-1).')';
		$this->cell($sheet,$range_sum,"G$f",6,$f,"right",true,$this->tam_letra_detalle,Arial,true,true,'center',true);
		*/

		//Actualización variables
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
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);
		$f++;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);*/
	}

	function initializeColumnWidth($sheet){
		$sheet->getColumnDimension('A')->setWidth(8);
		$sheet->getColumnDimension('B')->setWidth(25);
		$sheet->getColumnDimension('C')->setWidth(15);
		$sheet->getColumnDimension('D')->setWidth(40);
		$sheet->getColumnDimension('E')->setWidth(15);
		$sheet->getColumnDimension('F')->setWidth(10);
		$sheet->getColumnDimension('G')->setWidth(20);
		$sheet->getColumnDimension('H')->setWidth(15);
		$sheet->getColumnDimension('I')->setWidth(15);
		$sheet->getColumnDimension('J')->setWidth(20);
		$sheet->getColumnDimension('K')->setWidth(30);
		$sheet->getColumnDimension('L')->setWidth(15);
		$sheet->getColumnDimension('M')->setWidth(15);
		$sheet->getColumnDimension('N')->setWidth(10);
		$sheet->getColumnDimension('O')->setWidth(10);
		$sheet->getColumnDimension('P')->setWidth(15);
		$sheet->getColumnDimension('Q')->setWidth(15);
		$sheet->getColumnDimension('R')->setWidth(15);
		$sheet->getColumnDimension('S')->setWidth(15);
		$sheet->getColumnDimension('T')->setWidth(15);
		$sheet->getColumnDimension('U')->setWidth(15);
		$sheet->getColumnDimension('V')->setWidth(15);
		$sheet->getColumnDimension('W')->setWidth(15);
		$sheet->getColumnDimension('X')->setWidth(15);
		$sheet->getColumnDimension('Y')->setWidth(15);
	}

}
?>