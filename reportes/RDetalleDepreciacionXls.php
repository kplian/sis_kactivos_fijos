<?php
/**
*@package pXP
*@file RDetalleDepreciacionXls.php
*@author  RCM
*@date 27/07/2017
*@description Reporte Detalle de Depreciación
*/
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #9     KAF       ETR           10/05/2019  RCM         Inclusión de nuevas columnas en método de reporte detalle depreciación
 #55    KAF       ETR           01/08/2019  RCM         Corrección por actualización de PHP 7. Se cambia el string Arial por cadena 'Arial'
 #22	KAF 	  ETR 			13/09/2019	RCM 		Generar reporte con opción de agrupadores o no
 #31    KAF       ETR           17/09/2019  RCM         Adición en el reporte detalle depreciación de las columnas de anexos 1 (cbte. 2) y 2 (cbte. 4)
****************************************************************************
*/
class RDetalleDepreciacionXls
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
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,16,'Arial');//#55
		$sheet->mergeCells('A1:W1');

		//Título 1
		$titulo1 = "Al ".date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
		$this->cell($sheet,$titulo1,'A2',0,2,"center",true,$this->tam_letra_titulo,'Arial');//#55
		$sheet->mergeCells('A2:W2');

		//Título 2
		/*$fecha_hasta = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
		$titulo2 = "Depto.: ";
		$this->cell($sheet,$titulo2.$this->paramDepto,'A3',0,3,"center",true,$this->tam_letra_subtitulo,'Arial');//#55
		$sheet->mergeCells('A3:W3');*/

		//Título 3
		$titulo3="(Expresado en ".$this->objParam->getParametro('desc_moneda').")";//#22
		$this->cell($sheet,$titulo3,'A3',0,3,"center",true,$this->tam_letra_subtitulo,'Arial');//#55
		$sheet->mergeCells('A3:W3');

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
		$this->cell($sheet,'Nro.'						,"A$f" ,0, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Código'						,"B$f" ,1, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Código SAP'					,"C$f" ,2, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Denominación'				,"D$f" ,3, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Fecha Ini.Dep.'				,"E$f" ,4, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cantidad'					,"F$f" ,5, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Unidad de Medida'			,"G$f" ,6, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Centro de Costo'			,"H$f" ,7, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Nro. Serie'					,"I$f" ,8, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Lugar'						,"J$f" ,9, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Responsable Actual'			,"K$f" ,10,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Compra'				,"L$f" ,11,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Inicial'				,"M$f" ,12,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Altas'						,"N$f" ,13,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Bajas'						,"O$f" ,14,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Traspasos'					,"P$f" ,15,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Inc.x Actualiz.'			,"Q$f" ,16,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//Q->N//#55
		$this->cell($sheet,'Valor Actualiz.'			,"R$f" ,17,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//Q->N//#55
		$this->cell($sheet,'Vida Útil Original (meses)'	,"S$f" ,18,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//N->O//#55
		$this->cell($sheet,'Vida Útil Transcurrida (meses)'	,"T$f" ,19,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//N->O//#55
		$this->cell($sheet,'Vida Útil Residual (meses)'	,"U$f" ,20,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//O->P//#55
		$this->cell($sheet,'Dep.Acum. Gest.Ant.'		,"V$f" ,21,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Inc.x Actualiz. Dep.Acum.'	,"W$f" ,22,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación del Mes'		,"X$f" ,23,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Acum. Bajas'			,"Y$f" ,24,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Acum. Traspasos'		,"Z$f" ,25,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación Acum.'			,"AA$f",26,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación Gestión'		,"AB$f",27,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Neto'					,"AC$f",28,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55

		$this->cell($sheet,'AITB Dep.Acum.'				,"AD$f",29,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#31
		$this->cell($sheet,'AITB Dep.'					,"AE$f",30,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#31
		$this->cell($sheet,'AITB Dep.Acum.Anual'		,"AF$f",31,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#31
		$this->cell($sheet,'AITB Dep.Anual'				,"AG$f",32,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#31

		$this->cell($sheet,'Cuenta Activo'				,"AH$f",33,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cuenta Dep. Acum'			,"AI$f",34,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cuenta Deprec.'				,"AJ$f",35,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Agrupador AE'				,"AK$f",36,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Clasificador AE'			,"AL$f",37,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación Acum. Nueva'   ,"AM$f",38,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55

		//Inicio #9: Inclusión de nuevas columnas en método de reporte detalle depreciación
		$this->cell($sheet,'Código 2018'   				,"AN$f",39,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 1'   					,"AO$f",40,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 1'   			,"AP$f",41,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 2'   					,"AQ$f",42,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 2'   			,"AR$f",43,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 3'   					,"AS$f",44,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 3'   			,"AT$f",45,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 4'   					,"AU$f",46,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 4'   			,"AV$f",47,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 5'   					,"AW$f",48,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 5'   			,"AX$f",49,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 6'   					,"AY$f",50,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 6'   			,"AZ$f",51,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 7'   					,"BA$f",52,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 7'   			,"BB$f",53,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 8'   					,"BC$f",54,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 8'   			,"BD$f",55,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 9'   					,"BE$f",56,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 9'   			,"BF$f",57,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 10'   					,"BG$f",58,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 10'   			,"BH$f",59,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		//Fin #9

		$this->fila++;
		//////////////////
		//Detalle de datos
		//////////////////
		//Array totalizador


		//Estilos
		$count = count($this->dataSet) + 5;
		$sheet->getStyle("L5:R$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
		$sheet->getStyle("V5:AC$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);


		//Renderiza los datos
		$sheet->fromArray(
		    $this->dataSet,  // The data to set
		    NULL,        // Array values with this value will not be set
		    'A6'         // Top left coordinate of the worksheet range where
		                 //    we want to set these values (default is A1)
		);

		//Definición del rango total de filas
		$range=count($this->dataSet)+6;

		//Coloreado de las columnas que se utilizan para la generación del comprobante contable
		$sheet->getStyle('R5:R'.$range)->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		); //Inc.x Actualiz.

		$sheet->getStyle('AA5:AA'.$range)->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		);//Inc. Dep.Acum.Actualiz.

		$sheet->getStyle('AC5:AC'.$range)->applyFromArray(
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		);//Depreciación Mensual


		//Totales
		$f=count($this->dataSet)+6;
		$this->cell($sheet,'TOTALES',"A$f",0,$f,"center",true,$this->tam_letra_detalle,'Arial',false,false);//#55
		$this->cellBorder($sheet,"A$f:K$f");
		$sheet->mergeCells("A$f:K$f");

		//Inicio #35: calcular totales solo si hay alguna fila obtenida
		if($f > 6) {
			$range_sum='=SUM(L'.($this->fila).':L'.($f-1).')';
			$this->cell($sheet,$range_sum,"L$f",11,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(M'.($this->fila).':M'.($f-1).')';
			$this->cell($sheet,$range_sum,"M$f",12,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(N'.($this->fila).':N'.($f-1).')';
			$this->cell($sheet,$range_sum,"N$f",13,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(O'.($this->fila).':O'.($f-1).')';
			$this->cell($sheet,$range_sum,"O$f",14,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(P'.($this->fila).':P'.($f-1).')';
			$this->cell($sheet,$range_sum,"P$f",15,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(Q'.($this->fila).':Q'.($f-1).')';
			$this->cell($sheet,$range_sum,"Q$f",16,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(R'.($this->fila).':R'.($f-1).')';
			$this->cell($sheet,$range_sum,"R$f",17,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$this->cell($sheet,'',"S$f",18,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$this->cell($sheet,'',"T$f",19,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$this->cell($sheet,'',"U$f",20,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(V'.($this->fila).':V'.($f-1).')';
			$this->cell($sheet,$range_sum,"V$f",21,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(W'.($this->fila).':W'.($f-1).')';
			$this->cell($sheet,$range_sum,"W$f",22,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(X'.($this->fila).':X'.($f-1).')';
			$this->cell($sheet,$range_sum,"X$f",23,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(Y'.($this->fila).':Y'.($f-1).')';
			$this->cell($sheet,$range_sum,"Y$f",24,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(Z'.($this->fila).':Z'.($f-1).')';
			$this->cell($sheet,$range_sum,"Z$f",25,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(AA'.($this->fila).':AA'.($f-1).')';
			$this->cell($sheet,$range_sum,"AA$f",26,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(AB'.($this->fila).':AB'.($f-1).')';
			$this->cell($sheet,$range_sum,"AB$f",27,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(AC'.($this->fila).':AC'.($f-1).')';
			$this->cell($sheet,$range_sum,"AC$f",28,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55

			//Inicio #31
			$range_sum='=SUM(AD'.($this->fila).':AD'.($f-1).')';
			$this->cell($sheet,$range_sum,"AD$f",29,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);

			$range_sum='=SUM(AE'.($this->fila).':AE'.($f-1).')';
			$this->cell($sheet,$range_sum,"AE$f",30,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);

			$range_sum='=SUM(AF'.($this->fila).':AF'.($f-1).')';
			$this->cell($sheet,$range_sum,"AE$f",31,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);

			$range_sum='=SUM(AG'.($this->fila).':AG'.($f-1).')';
			$this->cell($sheet,$range_sum,"AE$f",32,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			//Fin #31

		} //Fin #35



		//Inicio #9: se estira el  merge cell de AH hasta BC y también el borde
		$sheet->mergeCells("AH$f:BD$f");
		$this->cellBorder($sheet,"AD$f:BD$f");
		//Fin #9

		//Formato de números para los totales
		$count=count($this->dataSet)+6;
		$sheet->getStyle("L$count:R$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
		$sheet->getStyle("V$count:AC$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);


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
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);//#55
		$f++;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,'Arial',false,false);*///#55
	}

	function initializeColumnWidth($sheet){
		$sheet->getColumnDimension('A')->setWidth(8);
		$sheet->getColumnDimension('B')->setWidth(20);
		$sheet->getColumnDimension('C')->setWidth(10);
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
		$sheet->getColumnDimension('N')->setWidth(15);
		$sheet->getColumnDimension('O')->setWidth(15);//N:10
		$sheet->getColumnDimension('P')->setWidth(10);//O:10
		$sheet->getColumnDimension('Q')->setWidth(10);//P:15
		$sheet->getColumnDimension('R')->setWidth(15);//Q:15
		$sheet->getColumnDimension('S')->setWidth(15);
		$sheet->getColumnDimension('T')->setWidth(15);
		$sheet->getColumnDimension('U')->setWidth(15);
		$sheet->getColumnDimension('V')->setWidth(15);
		$sheet->getColumnDimension('W')->setWidth(15);
		$sheet->getColumnDimension('X')->setWidth(15);
		$sheet->getColumnDimension('Y')->setWidth(15);
		$sheet->getColumnDimension('Z')->setWidth(15);
		$sheet->getColumnDimension('AA')->setWidth(15);
		$sheet->getColumnDimension('AB')->setWidth(15);
		$sheet->getColumnDimension('AC')->setWidth(15);

		$sheet->getColumnDimension('AD')->setWidth(15);//#31
		$sheet->getColumnDimension('AE')->setWidth(15);//#31
		$sheet->getColumnDimension('AF')->setWidth(15);//#31
		$sheet->getColumnDimension('AG')->setWidth(15);//#31

		$sheet->getColumnDimension('AH')->setWidth(60);
		$sheet->getColumnDimension('AI')->setWidth(60);
		$sheet->getColumnDimension('AJ')->setWidth(60);
		$sheet->getColumnDimension('AK')->setWidth(60);
		$sheet->getColumnDimension('AL')->setWidth(60);
		$sheet->getColumnDimension('AM')->setWidth(60);
		$sheet->getColumnDimension('AN')->setWidth(15);
		$sheet->getColumnDimension('AO')->setWidth(15);
		$sheet->getColumnDimension('AP')->setWidth(15);
		$sheet->getColumnDimension('AQ')->setWidth(15);

		//Inicio #9: Seteo del ancho de nuevas columnas
		$sheet->getColumnDimension('AR')->setWidth(15);
		$sheet->getColumnDimension('AS')->setWidth(15);
		$sheet->getColumnDimension('AT')->setWidth(15);
		$sheet->getColumnDimension('AU')->setWidth(15);
		$sheet->getColumnDimension('AV')->setWidth(15);
		$sheet->getColumnDimension('AW')->setWidth(15);
		$sheet->getColumnDimension('AX')->setWidth(15);
		$sheet->getColumnDimension('AY')->setWidth(15);
		$sheet->getColumnDimension('AZ')->setWidth(15);
		$sheet->getColumnDimension('BA')->setWidth(15);
		$sheet->getColumnDimension('BB')->setWidth(15);
		$sheet->getColumnDimension('BC')->setWidth(15);
		$sheet->getColumnDimension('BD')->setWidth(15);
		$sheet->getColumnDimension('BE')->setWidth(15);
		$sheet->getColumnDimension('BF')->setWidth(15);
		$sheet->getColumnDimension('BG')->setWidth(15);
		$sheet->getColumnDimension('BH')->setWidth(15);

		$sheet->getColumnDimension('BI')->setWidth(0);
		$sheet->getColumnDimension('BJ')->setWidth(0);
		$sheet->getColumnDimension('BK')->setWidth(0);
		$sheet->getColumnDimension('BL')->setWidth(0);
		$sheet->getColumnDimension('BM')->setWidth(0);
		$sheet->getColumnDimension('BN')->setWidth(0);
		//Fin #9
	}

}
?>