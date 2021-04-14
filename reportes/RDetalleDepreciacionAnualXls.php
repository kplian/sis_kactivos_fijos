<?php
/**
*@package pXP
*@file RDetalleDepreciacionAnualXls.php
*@author  RCM
*@date 21/04/2020
*@description Reporte Detalle de Depreciación
*/
/***************************************************************************
 ISSUE  	SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #58    	KAF       ETR           21/04/2020  RCM         Creación del archivo
 #AF-17 	KAF       ETR           31/07/2020  RCM         Ajustes al formato
 #ETR-3361  KAF       ETR           13/04/2021  RCM         Adición de dos nuevos campos de los históricos de vida útil y fecha inicio depreciación
 ****************************************************************************
*/
class RDetalleDepreciacionAnualXls
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
		$titulo1 = "DEPRECIACIÓN ACTIVOS FIJOS ANUAL";
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
		$this->cell($sheet,'Fecha Ini.Dep.Orig.'		,"E$f" ,4, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#ETR-3361
		$this->cell($sheet,'Fecha Ini.Dep.'				,"F$f" ,5, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cantidad'					,"G$f" ,6, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Unidad de Medida'			,"H$f" ,7, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Centro de Costo'			,"I$f" ,8, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Nro. Serie'					,"J$f" ,9, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Lugar'						,"K$f" ,10, $f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Responsable Actual'			,"L$f" ,11,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Vida Útil Original (meses)'	,"M$f" ,12,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#ETR-3361
		$this->cell($sheet,'Vida Útil (meses)'			,"N$f" ,13,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Vida Útil Transcurrida (meses)',"O$f" ,14,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Vida Útil Residual (meses)'	,"P$f" ,15,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Compra'				,"Q$f" ,16,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Inicial'				,"R$f" ,17,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Mes Ant.'				,"S$f" ,18,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Altas'						,"T$f" ,19,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Bajas'						,"U$f" ,20,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Traspasos'					,"V$f" ,21,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Inc.x Actualiz.'			,"W$f" ,22,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//Q->N//#55
		$this->cell($sheet,'Valor Actualiz.'			,"X$f" ,23,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//Q->N//#55
		$this->cell($sheet,'Dep.Acum. Gest.Ant.'		,"Y$f" ,24,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#70
		$this->cell($sheet,'Dep.Acum. Mes.Ant.'			,"Z$f" ,25,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Acum. Bajas'			,"AA$f" ,26,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Acum. Traspasos'		,"AB$f" ,27,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Inc.x Actualiz. Dep.Acum.'	,"AC$f",28,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación del Mes'		,"AD$f",29,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación Acum.'			,"AE$f",30,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Valor Neto'					,"AF$f",31,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'AITB Dep. Mes'				,"AG$f",32,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#70
		$this->cell($sheet,'AITB AF Ene'				,"AH$f",33,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Feb'				,"AI$f",34,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Mar'				,"AJ$f",35,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Abr'				,"AK$f",36,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF May'				,"AL$f",37,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Jun'				,"AM$f",38,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Jul'				,"AN$f",39,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Ago'				,"AO$f",40,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Sep'				,"AP$f",41,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Oct'				,"AQ$f",42,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Nov'				,"AR$f",43,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB AF Dic'				,"AS$f",44,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Total AITB AF'				,"AT$f",45,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Ene'			,"AU$f",46,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Feb'			,"AV$f",47,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Mar'			,"AW$f",48,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Abr'			,"AX$f",49,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. May'			,"AY$f",50,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Jun'			,"AZ$f",51,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Jul'			,"BA$f",52,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Ago'			,"BB$f",53,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Sep'			,"BC$f",54,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Oct'			,"BD$f",55,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Nov'			,"BE$f",56,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Acum. Dic'			,"BF$f",57,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Total AITB Dep.Acum.'		,"BG$f",58,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Ene'					,"BH$f",59,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Feb'					,"BI$f",60,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Mar'					,"BJ$f",61,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Abr'					,"BK$f",62,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep May'					,"BL$f",63,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Jun'					,"BM$f",64,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Jul'					,"BN$f",65,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Ago'					,"BO$f",66,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Sep'					,"BP$f",67,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Oct'					,"BQ$f",68,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Nov'					,"BR$f",69,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Dep Dic'					,"BS$f",70,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Total Dep. Gestion'			,"BT$f",71,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Ene'				,"BU$f",72,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Feb'				,"BV$f",73,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Mar'				,"BW$f",74,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Abr'				,"BX$f",75,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.May'				,"BY$f",76,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Jun'				,"BZ$f",77,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Jul'				,"CA$f",78,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Ago'				,"CB$f",79,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Sep'				,"CC$f",80,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Oct'				,"CD$f",81,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Nov'				,"CE$f",82,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'AITB Dep.Dic'				,"CF$f",83,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);
		$this->cell($sheet,'Total AITB Dep'				,"CG$f",84,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);

		$this->cell($sheet,'Cuenta Activo'				,"CH$f",85,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cuenta Dep. Acum'			,"CI$f",86,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Cuenta Deprec.'				,"CJ$f",87,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Agrupador AE'				,"CK$f",88,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Clasificador AE'			,"CL$f",89,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Depreciación Acum. Nueva'	,"CM$f",90,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#70
		$this->cell($sheet,'Código 2018'				,"CN$f",91,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#70
		/*$this->cell($sheet,'Dep. Acum. Nueva'   		,"CI$f",86,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55

		//Inicio #9: Inclusión de nuevas columnas en método de reporte detalle depreciación
		$this->cell($sheet,'Código 2018'   				,"CJ$f",87,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 1'   					,"CK$f",88,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 1'   			,"CL$f",89,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 2'   					,"CM$f",90,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 2'   			,"CN$f",91,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 3'   					,"CO$f",92,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 3'   			,"CP$f",93,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 4'   					,"CQ$f",94,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 4'   			,"CR$f",95,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 5'   					,"CS$f",96,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 5'   			,"CT$f",97,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 6'   					,"CU$f",98,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 6'   			,"CV$f",99,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 7'   					,"CW$f",100,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 7'   			,"CX$f",101,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 8'   					,"CY$f",102,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 8'   			,"CZ$f",103,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 9'   					,"DA$f",104,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 9'   			,"DB$f",105,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'CC 10'   					,"DC$f",106,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		$this->cell($sheet,'Dep.Mes. CC 10'   			,"DD$f",107,$f,"center",true,$this->tam_letra_detalle,'Arial',true,true);//#55
		*/
		//Fin #9

		$this->fila++;
		//////////////////
		//Detalle de datos
		//////////////////
		//Estilos
		//Definición del rango total de filas
		$count = count($this->dataSet) + 5;
		$range = count($this->dataSet)+6;

		$sheet->getStyle("O5:CE$count")
			  ->getNumberFormat()
			  ->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);

		//Renderiza los datos
		$sheet->fromArray(
		    $this->dataSet,  // The data to set
		    NULL,        // Array values with this value will not be set
		    'A6'         // Top left coordinate of the worksheet range where
		                 //    we want to set these values (default is A1)
		);

		//Coloreado de las columnas que se utilizan para la generación del comprobante contable
		$sheet->getStyle('W5:W'.$range)->applyFromArray( //#ETR-3361
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		); //Inc.x Actualiz.

		$sheet->getStyle('AC5:AC'.$range)->applyFromArray( //#ETR-3361
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		);//Inc. Dep.Acum.Actualiz.

		$sheet->getStyle('AD5:AD'.$range)->applyFromArray( //#ETR-3361
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		);//Depreciación Mensual

		$sheet->getStyle('AG5:AG'.$range)->applyFromArray(//#ETR-3361
		    array(
		        'fill' => array(
		            'type' => PHPExcel_Style_Fill::FILL_SOLID,
		            'color' => array('rgb' => '#ffff99')
		        )
		    )
		);//Incremento AITB del Mes

		//Totales
		$f = count($this->dataSet)+6;
		$this->cell($sheet,'TOTALES',"A$f",0,$f,"center",true,$this->tam_letra_detalle,'Arial',false,false);//#55
		$this->cellBorder($sheet,"A$f:N$f");
		$sheet->mergeCells("A$f:N$f");

		//Inicio #35: calcular totales solo si hay alguna fila obtenida
		if($f > 6) { //O hasta CE
			$range_sum='=SUM(O'.($this->fila).':O'.($f-1).')';
			$this->cell($sheet,$range_sum,"OL$f",14,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(P'.($this->fila).':P'.($f-1).')';
			$this->cell($sheet,$range_sum,"P$f",15,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(Q'.($this->fila).':Q'.($f-1).')';
			$this->cell($sheet,$range_sum,"Q$f",16,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(R'.($this->fila).':R'.($f-1).')';
			$this->cell($sheet,$range_sum,"R$f",17,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(S'.($this->fila).':S'.($f-1).')';
			$this->cell($sheet,$range_sum,"S$f",18,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(T'.($this->fila).':T'.($f-1).')';
			$this->cell($sheet,$range_sum,"T$f",19,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55
			$range_sum='=SUM(U'.($this->fila).':U'.($f-1).')';
			$this->cell($sheet,$range_sum,"U$f",20,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);//#55

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
			$this->cell($sheet,$range_sum,"AF$f",31,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AG'.($this->fila).':AG'.($f-1).')';
			$this->cell($sheet,$range_sum,"AG$f",32,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			//Fin #31
			$range_sum='=SUM(AH'.($this->fila).':AH'.($f-1).')';
			$this->cell($sheet,$range_sum,"AH$f",33,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AI'.($this->fila).':AI'.($f-1).')';
			$this->cell($sheet,$range_sum,"AI$f",34,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AJ'.($this->fila).':AJ'.($f-1).')';
			$this->cell($sheet,$range_sum,"AJ$f",35,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AK'.($this->fila).':AK'.($f-1).')';
			$this->cell($sheet,$range_sum,"AK$f",36,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AL'.($this->fila).':AL'.($f-1).')';
			$this->cell($sheet,$range_sum,"AL$f",37,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AM'.($this->fila).':AM'.($f-1).')';
			$this->cell($sheet,$range_sum,"AM$f",38,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AN'.($this->fila).':AN'.($f-1).')';
			$this->cell($sheet,$range_sum,"AN$f",39,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AO'.($this->fila).':AO'.($f-1).')';
			$this->cell($sheet,$range_sum,"AO$f",40,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AP'.($this->fila).':AP'.($f-1).')';
			$this->cell($sheet,$range_sum,"AP$f",41,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AQ'.($this->fila).':AQ'.($f-1).')';
			$this->cell($sheet,$range_sum,"AQ$f",42,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AR'.($this->fila).':AR'.($f-1).')';
			$this->cell($sheet,$range_sum,"AR$f",43,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AS'.($this->fila).':AS'.($f-1).')';
			$this->cell($sheet,$range_sum,"AS$f",44,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AT'.($this->fila).':AT'.($f-1).')';
			$this->cell($sheet,$range_sum,"AT$f",45,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AU'.($this->fila).':AU'.($f-1).')';
			$this->cell($sheet,$range_sum,"AU$f",46,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AV'.($this->fila).':AV'.($f-1).')';
			$this->cell($sheet,$range_sum,"AV$f",47,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AW'.($this->fila).':AW'.($f-1).')';
			$this->cell($sheet,$range_sum,"AW$f",48,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AX'.($this->fila).':AX'.($f-1).')';
			$this->cell($sheet,$range_sum,"AX$f",49,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AY'.($this->fila).':AY'.($f-1).')';
			$this->cell($sheet,$range_sum,"AY$f",50,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(AZ'.($this->fila).':AZ'.($f-1).')';
			$this->cell($sheet,$range_sum,"AZ$f",51,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BA'.($this->fila).':BA'.($f-1).')';
			$this->cell($sheet,$range_sum,"BA$f",52,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BB'.($this->fila).':BB'.($f-1).')';
			$this->cell($sheet,$range_sum,"BB$f",53,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BC'.($this->fila).':BC'.($f-1).')';
			$this->cell($sheet,$range_sum,"BC$f",54,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BD'.($this->fila).':BD'.($f-1).')';
			$this->cell($sheet,$range_sum,"BD$f",55,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BE'.($this->fila).':BE'.($f-1).')';
			$this->cell($sheet,$range_sum,"BE$f",56,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BF'.($this->fila).':BF'.($f-1).')';
			$this->cell($sheet,$range_sum,"BF$f",57,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BG'.($this->fila).':BG'.($f-1).')';
			$this->cell($sheet,$range_sum,"BG$f",58,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BH'.($this->fila).':BH'.($f-1).')';
			$this->cell($sheet,$range_sum,"BH$f",59,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BI'.($this->fila).':BI'.($f-1).')';
			$this->cell($sheet,$range_sum,"BI$f",60,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BJ'.($this->fila).':BJ'.($f-1).')';
			$this->cell($sheet,$range_sum,"BJ$f",61,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BK'.($this->fila).':BK'.($f-1).')';
			$this->cell($sheet,$range_sum,"BK$f",62,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BL'.($this->fila).':BL'.($f-1).')';
			$this->cell($sheet,$range_sum,"BL$f",63,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BM'.($this->fila).':BM'.($f-1).')';
			$this->cell($sheet,$range_sum,"BM$f",64,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BN'.($this->fila).':BN'.($f-1).')';
			$this->cell($sheet,$range_sum,"BN$f",65,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BO'.($this->fila).':BO'.($f-1).')';
			$this->cell($sheet,$range_sum,"BO$f",66,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BP'.($this->fila).':BP'.($f-1).')';
			$this->cell($sheet,$range_sum,"BP$f",67,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BQ'.($this->fila).':BQ'.($f-1).')';
			$this->cell($sheet,$range_sum,"BQ$f",68,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BR'.($this->fila).':BR'.($f-1).')';
			$this->cell($sheet,$range_sum,"BR$f",69,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BS'.($this->fila).':BS'.($f-1).')';
			$this->cell($sheet,$range_sum,"BS$f",70,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BT'.($this->fila).':BT'.($f-1).')';
			$this->cell($sheet,$range_sum,"BT$f",71,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BU'.($this->fila).':BU'.($f-1).')';
			$this->cell($sheet,$range_sum,"BU$f",72,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BV'.($this->fila).':BV'.($f-1).')';
			$this->cell($sheet,$range_sum,"BV$f",73,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BW'.($this->fila).':BW'.($f-1).')';
			$this->cell($sheet,$range_sum,"BW$f",74,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BX'.($this->fila).':BX'.($f-1).')';
			$this->cell($sheet,$range_sum,"BX$f",75,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BY'.($this->fila).':BY'.($f-1).')';
			$this->cell($sheet,$range_sum,"BY$f",76,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(BZ'.($this->fila).':BZ'.($f-1).')';
			$this->cell($sheet,$range_sum,"BZ$f",77,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(CA'.($this->fila).':CA'.($f-1).')';
			$this->cell($sheet,$range_sum,"CA$f",78,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(CB'.($this->fila).':CB'.($f-1).')';
			$this->cell($sheet,$range_sum,"CB$f",79,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(CC'.($this->fila).':CC'.($f-1).')';
			$this->cell($sheet,$range_sum,"CC$f",80,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(CD'.($this->fila).':CD'.($f-1).')';
			$this->cell($sheet,$range_sum,"CD$f",81,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$range_sum='=SUM(CE'.($this->fila).':CE'.($f-1).')';
			$this->cell($sheet,$range_sum,"CE$f",82,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);

			$this->cell($sheet,'',"CF$f",83,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CG$f",84,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CH$f",85,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CI$f",86,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CJ$f",87,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CK$f",88,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);
			$this->cell($sheet,'',"CL$f",89,$f,"right",true,$this->tam_letra_detalle,'Arial',true,true,'center',true);

		} //Fin #35

		//Formato de números para los totales
		$count=count($this->dataSet)+6;

		$sheet->getStyle('O'.$count.':CE'.$count)
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
		$sheet->getColumnDimension('O')->setWidth(15);
		$sheet->getColumnDimension('P')->setWidth(15);//N:10
		$sheet->getColumnDimension('Q')->setWidth(10);//O:10
		$sheet->getColumnDimension('R')->setWidth(10);//P:15
		$sheet->getColumnDimension('S')->setWidth(15);//Q:15
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
		$sheet->getColumnDimension('AD')->setWidth(15);

		$sheet->getColumnDimension('AE')->setWidth(15);//#31
		$sheet->getColumnDimension('AF')->setWidth(15);//#31
		$sheet->getColumnDimension('AG')->setWidth(15);//#31
		$sheet->getColumnDimension('AH')->setWidth(15);//#31

		$sheet->getColumnDimension('AI')->setWidth(15);
		$sheet->getColumnDimension('AJ')->setWidth(15);
		$sheet->getColumnDimension('AK')->setWidth(15);
		$sheet->getColumnDimension('AL')->setWidth(15);
		$sheet->getColumnDimension('AM')->setWidth(15);
		$sheet->getColumnDimension('AN')->setWidth(15);
		$sheet->getColumnDimension('AO')->setWidth(15);
		$sheet->getColumnDimension('AP')->setWidth(15);
		$sheet->getColumnDimension('AQ')->setWidth(15);
		$sheet->getColumnDimension('AR')->setWidth(15);

		//Inicio #9: Seteo del ancho de nuevas columnas
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
		$sheet->getColumnDimension('BI')->setWidth(15);
		$sheet->getColumnDimension('BJ')->setWidth(15);
		$sheet->getColumnDimension('BK')->setWidth(15);
		$sheet->getColumnDimension('BL')->setWidth(15);
		$sheet->getColumnDimension('BM')->setWidth(15);
		$sheet->getColumnDimension('BN')->setWidth(15);
		$sheet->getColumnDimension('BO')->setWidth(15);
		$sheet->getColumnDimension('BP')->setWidth(15);
		$sheet->getColumnDimension('BQ')->setWidth(15);
		$sheet->getColumnDimension('BR')->setWidth(15);
		$sheet->getColumnDimension('BS')->setWidth(15);
		$sheet->getColumnDimension('BT')->setWidth(15);
		$sheet->getColumnDimension('BU')->setWidth(15);
		$sheet->getColumnDimension('BV')->setWidth(15);
		$sheet->getColumnDimension('BW')->setWidth(15);
		$sheet->getColumnDimension('BX')->setWidth(15);
		$sheet->getColumnDimension('BY')->setWidth(15);
		$sheet->getColumnDimension('BZ')->setWidth(15);
		$sheet->getColumnDimension('CA')->setWidth(15);
		$sheet->getColumnDimension('CB')->setWidth(15);
		$sheet->getColumnDimension('CC')->setWidth(15);
		$sheet->getColumnDimension('CD')->setWidth(15);
		$sheet->getColumnDimension('CE')->setWidth(15);
		$sheet->getColumnDimension('CF')->setWidth(15);
		$sheet->getColumnDimension('CG')->setWidth(15);
		$sheet->getColumnDimension('CH')->setWidth(15);
		$sheet->getColumnDimension('CI')->setWidth(15);
		$sheet->getColumnDimension('CJ')->setWidth(35);
		$sheet->getColumnDimension('CK')->setWidth(20);
		$sheet->getColumnDimension('CL')->setWidth(15);
		$sheet->getColumnDimension('CM')->setWidth(15);
		$sheet->getColumnDimension('CN')->setWidth(15);
		$sheet->getColumnDimension('CO')->setWidth(15);
		$sheet->getColumnDimension('CP')->setWidth(15);
		$sheet->getColumnDimension('CQ')->setWidth(15);
		$sheet->getColumnDimension('CR')->setWidth(15);
		$sheet->getColumnDimension('CS')->setWidth(15);
		$sheet->getColumnDimension('CT')->setWidth(15);
		$sheet->getColumnDimension('CU')->setWidth(15);
		$sheet->getColumnDimension('CV')->setWidth(15);
		$sheet->getColumnDimension('CW')->setWidth(15);
		$sheet->getColumnDimension('CX')->setWidth(15);
		$sheet->getColumnDimension('CY')->setWidth(15);
		$sheet->getColumnDimension('CZ')->setWidth(15);
		$sheet->getColumnDimension('DA')->setWidth(15);
		$sheet->getColumnDimension('DB')->setWidth(15);
		$sheet->getColumnDimension('DC')->setWidth(15);
		$sheet->getColumnDimension('DD')->setWidth(15);
		$sheet->getColumnDimension('DE')->setWidth(15);

		//Fin #9
	}

}
?>