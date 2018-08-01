<?php
class RKardexAFxls
{
	private $docexcel;
	private $objWriter;
	private $nombre_archivo;
	private $fila;
	private $filaFirstBox;
	private $filaSecondBox;
	private $equivalencias=array();
	private $objParam;
	public  $url_archivo;

	private $desc_moneda='Bolivianos';
	private $dataSet;
	private $tipo_reporte;
	private $titulo_reporte;


	private $tam_letra_titulo = 12;
	private $tam_letra_subtitulo = 10;
	private $tam_letra_cabecera = 10;
	private $tam_letra_detalle_cabecera = 8;
	private $tam_letra_detalle = 8;
	
	function __construct(CTParametro $objParam){
		$this->objParam = $objParam;
		$this->url_archivo = "../../../reportes_generados/".$this->objParam->getParametro('nombre_archivo');
		//ini_set('memory_limit','512M');
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
		
		$this->equivalencias=array(0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
								9=>'J',10=>'K',11=>'L',12=>'M',13=>'N',14=>'O',15=>'P',16=>'Q',17=>'R',
								18=>'S',19=>'T',20=>'U',21=>'V',22=>'W',23=>'X',24=>'Y',25=>'Z',
								26=>'AA',27=>'AB',28=>'AC',29=>'AD',30=>'AE',31=>'AF',32=>'AG',33=>'AH',
								34=>'AI',35=>'AJ',36=>'AK',37=>'AL',38=>'AM',39=>'AN',40=>'AO',41=>'AP',
								42=>'AQ',43=>'AR',44=>'AS',45=>'AT',46=>'AU',47=>'AV',48=>'AW',49=>'AX',
								50=>'AY',51=>'AZ',
								52=>'BA',53=>'BB',54=>'BC',55=>'BD',56=>'BE',57=>'BF',58=>'BG',59=>'BH',
								60=>'BI',61=>'BJ',62=>'BK',63=>'BL',64=>'BM',65=>'BN',66=>'BO',67=>'BP',
								68=>'BQ',69=>'BR',70=>'BS',71=>'BT',72=>'BU',73=>'BV',74=>'BW',75=>'BX',
								76=>'BY',77=>'BZ');	

		$this->initializeColumnAnchos();
		$this->printerConfiguration();
									
	}
	
	function datosHeader ( $detalle, $id_entrega) {
		$this->datos_detalle = $detalle;
		$this->id_entrega = $id_entrega;
	}

	function generarReporte() {
		$sheet=$this->docexcel->setActiveSheetIndex(0);
		$this->imprimeTitulo($sheet);
		$this->imprimeCabecera($sheet);
		$this->firstBox($sheet);
		$this->secondBox($sheet);
		$this->mainBox($sheet);
		$this->firmas($sheet);
		// Set active sheet index to the first sheet, so Excel opens this as the first sheet
		$this->docexcel->setActiveSheetIndex(0);
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);		
	}

	function imprimeTitulo($sheet) {
		$sheet->setCellValueByColumnAndRow(0,1,$this->objParam->getParametro('titulo_rep'));
		//Título 1
		$titulo1 = "KARDEX DE ACTIVOS FIJOS";
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A1:Q1');
		
		//Título 2
		$fecha_desde = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_desde')));
		$fecha_hasta = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
		$titulo2 = "DEL ".$fecha_desde." AL ".$fecha_hasta;
		$this->cell($sheet,$titulo2,'A2',0,2,"center",true,$this->tam_letra_subtitulo,Arial);
		$sheet->mergeCells('A2:Q2');

		//Título 3
		$titulo3="(Expresado en ".$this->desc_moneda.")";
		$this->cell($sheet,$titulo3,'A3',0,3,"center",true,$this->tam_letra_subtitulo,Arial);
		$sheet->mergeCells('A3:Q3');

		//Logo
		$objDrawing = new PHPExcel_Worksheet_Drawing();
		$objDrawing->setName('Logo');
		$objDrawing->setDescription('Logo');
		$objDrawing->setPath(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO']);
		$objDrawing->setHeight(50);
		$objDrawing->setWorksheet($this->docexcel->setActiveSheetIndex(0));
	}

	function imprimeCabecera($sheet) {
		$record = $this->dataSet[0];

		//Primera columna
		$this->cell($sheet,'CÓDIGO','A5',0,5,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'CLASIFICACIÓN','A6',0,6,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'DENOMINACIÓN','A7',0,7,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'FECHA COMPRA','A8',0,8,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'INICIO DE DEPRECIACIÓN','A9',0,9,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'ESTADO DEL ACTIVO','A10',0,10,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'UFV FECHA DE COMPRA','A11',0,11,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'VIDA ÚTIL ORIGINAL (MESES)','A11',0,11,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'CENTRO DE COSTOS','A12',0,12,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'UNIDAD SOLICITANTE','A14',0,14,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'RESPONSABLE DE LA COMPRA','A15',0,15,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'LUGAR DE COMPRA','A16',0,16,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'UBICACIÓN FÍSICA','A13',0,13,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'UBICACIÓN DEL BIEN (CIUDAD)','A18',0,18,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'RESPONSABLE DEL BIEN','A14',0,14,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'No DE C31','A20',0,20,"",true,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,'FECHA DE C31','A21',0,21,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'No DE PROCESO','A15',0,15,"",true,$this->tam_letra_cabecera,Arial);

		$this->cell($sheet,$record['codigo'],'E5',4,5,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_clasif'],'E6',4,6,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['denominacion'],'E7',4,7,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['fecha_compra'],'E8',4,8,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['fecha_ini_dep'],'E9',4,9,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['estado'],'E10',4,10,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['ufv_fecha_compra'],'E11',4,11,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['vida_util_original'],'E11',4,11,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_centro_costo'],'E12',4,12,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['desc_uo_solic'],'E14',4,14,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['desc_funcionario_compra'],'E15',4,15,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['lugar_compra'],'E16',4,16,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['ubicacion'],'E13',4,13,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['ciudad'],'E18',4,18,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['responsable'],'E14',4,14,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['nro_cbte_asociado'],'E20',4,20,"left",false,$this->tam_letra_cabecera,Arial);
		//$this->cell($sheet,$record['fecha_cbte_asociado'],'E21',4,21,"left",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['num_tramite'],'E15',4,15,"left",false,$this->tam_letra_cabecera,Arial);

		//Segunda columna
		$this->cell($sheet,'CODIGO SAP','J6',9,6,"",true,10,Arial);
		$this->cell($sheet,'MONTO','J11',9,11,"",true,10,Arial);
		$this->cell($sheet,'% DEPRECIACIÓN','J12',9,12,"",true,10,Arial);
		$this->cell($sheet,'MÉTODO DEPRECIACIÓN','J13',9,13,"",true,10,Arial);
		$this->cell($sheet,'OFICINA','J14',9,14,"",true,10,Arial);

		$this->cell($sheet,$record['codigo_ant'],'M6',12,6,"left",false,10,Arial);
		$this->cell($sheet,$record['monto_compra_orig'],'M11',12,11,"left",false,10,Arial);
		$this->cell($sheet,$record['porcentaje_dep'],'M12',12,12,"left",false,10,Arial);
		$this->cell($sheet,$record['metodo_dep'],'M13',12,13,"left",false,10,Arial);
		$this->cell($sheet,$record['desc_oficina'],'M14',12,14,"left",false,10,Arial);

		//Actualiza número de fila
		$this->fila = 17;
	}

	function cell($sheet,$texto,$cell,$x,$y,$align="left",$bold=true,$size=10,$name=Arial,$wrap=false,$border=false,$valign='center'){
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
	}

	

	function firstBox($sheet){
		//Cabecera caja
		$f = $this->fila;
		$this->cell($sheet,'MOVIMIENTO FÍSICO DEL ACTIVO',"A$f",0,$f,"center",true,$this->tam_letra_detalle_cabecera,Arial);
		$sheet->mergeCells("A$f:H$f");
		$this->cellBorder($sheet,"A$f:H$f");
		$f++;
		$this->cell($sheet,'No.',"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'N.PROCESO',"B$f",1,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'PROCESO',"C$f",2,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DEL',"D$f",3,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'AL',"E$f",4,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'RESPONSABLE',"F$f",5,$f,"center",true,$this->tam_letra_detalle,Arial,true,false);
		$sheet->mergeCells("F$f:G$f");
		$this->cellBorder($sheet,"F$f:G$f");
		$this->cell($sheet,'CARGO',"H$f",7,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);

		///////////////////
		//Detalle de datos
		///////////////////
		//Vacía los movimientos físicos en un array temporal
		$arrayTmp=array();
		for ($fil=0; $fil < count($this->dataSet); $fil++) {
			if($this->dataSet[$fil]['codigo_mov']=='asig'||$this->dataSet[$fil]['codigo_mov']=='devol'||$this->dataSet[$fil]['codigo_mov']=='transf'||$this->dataSet[$fil]['codigo_mov']=='tranfdep') {
				array_push($arrayTmp,$this->dataSet[$fil]);
			}
		}

		//Despliegue de los datos
		$cont=0;
		for ($fil=0; $fil < count($arrayTmp); $fil++) {
			//Actualiza contadores
			$cont++;
			$f++;
			//Calcula la fecha hasta si existe
			$fecha_sig='';
			/*// --Caso de ordenamiento desc (comentado por ahora)
			if($arrayTmp[$fil-1]['fecha_mov']!=''){
				$fecha_sig = date("d/m/Y",strtotime($arrayTmp[$fil-1]['fecha_mov']. ' -1 day'));
				//Verifica que esta fecha no sea menor que la fecha del movimiento (desde)
				if($fecha_sig < date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov']))){
					$fecha_sig = date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov']));
				}
			}*/
			// --Caso de ordenamiento asc
			if($arrayTmp[$fil+1]['fecha_mov']!=''){
				$fecha_sig = date("d/m/Y",strtotime($arrayTmp[$fil-1]['fecha_mov']. ' -1 day'));
				//Verifica que esta fecha no sea menor que la fecha del movimiento (desde)
				if($fecha_sig < date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov']))){
					$fecha_sig = date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov']));
				}
			}
			//Despliega los datos
			$this->cell($sheet,$cont,"A$f",0,$f,"right",false,$this->tam_letra_detalle,Arial,false,false);
			$this->cell($sheet,$arrayTmp[$fil]['num_tramite'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,false);
			$this->cell($sheet,$arrayTmp[$fil]['desc_mov'],"C$f",2,$f,"center",false,$this->tam_letra_detalle,Arial,true,false);
			$this->cell($sheet,date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov'])),"D$f",3,$f,"center",false,$this->tam_letra_detalle,Arial,true,false);
			$this->cell($sheet,$fecha_sig,"E$f",4,$f,"center",false,$this->tam_letra_detalle,Arial,true,false);
			$this->cell($sheet,$arrayTmp[$fil]['responsable'],"F$f",5,$f,"left",false,$this->tam_letra_detalle,Arial,true,false);
			$sheet->mergeCells("F$f:G$f");
			$this->cell($sheet,$arrayTmp[$fil]['cargo'],"H$f",7,$f,"left",false,$this->tam_letra_detalle,Arial,true,false);
		}

		//Borde a la caja
		$this->cellBorder($sheet,"A".$this->fila.":H$f",'vertical');
		$this->cellBorder($sheet,"A".$this->fila.":H$f");

		//Actualización variables
		$this->filaFirstBox=$f;

	}

	function secondBox($sheet){
		//Cabecera caja
		$f = $this->fila;
		$this->cell($sheet,'PROCESOS DEL ACTIVO',"J$f",9,$f,"center",true,$this->tam_letra_detalle_cabecera,Arial);
		$sheet->mergeCells("J$f:Q$f");
		$this->cellBorder($sheet,"J$f:Q$f");
		$f++;
		$this->cell($sheet,'FECHA MOVIMIENTO',"J$f",9,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'UFV DEL PROCESO',"K$f",10,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'N.PROCESO',"L$f",11,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'MEJORA',"M$f",12,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'REVALORIZACIÓN',"N$f",13,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'AJUSTE (+ o -)',"O$f",14,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'RETIRO',"P$f",15,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'MESES',"Q$f",16,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);

		//Detalle de datos
		for ($fil=0; $fil < count($this->dataSet); $fil++) {
			if($this->dataSet[$fil]['codigo_mov']=='reval'||$this->dataSet[$fil]['codigo_mov']=='mejora'||$this->dataSet[$fil]['codigo_mov']=='ajuste'||$this->dataSet[$fil]['codigo_mov']=='retiro') {
				$f++;
				$this->cell($sheet,date("d/m/Y",strtotime($this->dataSet[$fil]['fecha_mov'])),"J$f",9,$f,"center",false,$this->tam_letra_detalle,Arial,false,false);
				$this->cell($sheet,$this->dataSet[$fil]['ufv_mov'],"K$f",10,$f,"right",false,$this->tam_letra_detalle,Arial,true,false);
				$this->cell($sheet,$this->dataSet[$fil]['num_tramite'],"L$f",11,$f,"center",false,$this->tam_letra_detalle,Arial,true,false);
				//Escoge en que celda colocar el importe
				$monto=$this->dataSet[$fil]['monto_vigente_orig'];
				$celda='';
				$numero='';
				if($this->dataSet[$fil]['codigo_mov']=='mejora'){
					$celda="M";
					$numero=12;
				} else if($this->dataSet[$fil]['codigo_mov']=='reval'){
					$celda="N";
					$numero=13;
				} else if($this->dataSet[$fil]['codigo_mov']=='ajuste'){
					$celda="O";
					$numero=14;
				} else if($this->dataSet[$fil]['codigo_mov']=='retiro'){
					$celda="P";
					$numero=15;
				}
				if($celda!=''){
					$this->cell($sheet,$monto,"$celda$f",$numero,$f,"right",false,$this->tam_letra_detalle,Arial,true,false);
				}
				$this->cell($sheet,'19',"Q$f",16,$f,"center",false,$this->tam_letra_detalle,Arial,true,false);
			}
		}
		//Borde a la caja
		$this->cellBorder($sheet,"J".$this->fila.":Q$f",'vertical');
		$this->cellBorder($sheet,"J".$this->fila.":Q$f");

		//Actualización variables
		$this->filaSecondBox=$f;
		$this->fila = $this->filaFirstBox +2;
		if($this->filaSecondBox>$this->filaFirstBox){
			$this->fila = $this->filaSecondBox +2;
		}
	}

	function mainBox($sheet){
		//Cabecera caja
		$f = $this->fila;
		$this->cell($sheet,'DETALLE CONTABLE DEL BIEN',"A$f",0,$f,"center",true,$this->tam_letra_detalle_cabecera,Arial);
		$sheet->mergeCells("A$f:Q$f");
		$this->cellBorder($sheet,"A$f:Q$f");
		$f++;
		$this->cell($sheet,'PROCESO',"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true);
		$sheet->mergeCells("A$f:C$f");
		$this->cellBorder($sheet,"A$f:C$f");
		$this->cell($sheet,'FECHA DE PROCESO',"D$f",3,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$sheet->mergeCells("D$f:E$f");
		$this->cellBorder($sheet,"D$f:E$f");
		$this->cell($sheet,'T/C Ini.',"F$f",5,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'T/C Fin',"G$f",6,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Factor',"H$f",7,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Fecha Dep.',"I$f",8,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Vigente Actualiz.',"J$f",9,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Inc.Actualiz.',"K$f",10,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Actualiz.',"L$f",11,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Vida Útil Ant.',"M$f",12,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Acum.Ant',"N$f",13,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Inc.ActualizDep.Acum',"O$f",14,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Acum.Ant.Actualiz.',"P$f",15,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Mes',"Q$f",16,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Periodo',"R$f",17,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Dep.Acum.',"S$f",18,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'Valor Neto.',"T$f",19,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);

		//Vacía los movimientos físicos en un array temporal
		$arrayTmp=array();
		for ($fil=0; $fil < count($this->dataSet); $fil++) {
			if($this->dataSet[$fil]['codigo_mov']!='asig'&&$this->dataSet[$fil]['codigo_mov']!='devol'&&$this->dataSet[$fil]['codigo_mov']!='transf'&&$this->dataSet[$fil]['codigo_mov']!='tranfdep') {
				array_push($arrayTmp,$this->dataSet[$fil]);
			}
		}

		//Detalle de datos
		//var_dump($arrayTmp);exit;
		for ($fil=0; $fil < count($arrayTmp); $fil++) {
			$f++;
			$this->cell($sheet,$arrayTmp[$fil]['desc_mov'],"A$f",0,$f,"left",false,$this->tam_letra_detalle,Arial,true);
			$sheet->mergeCells("A$f:C$f");
			$this->cellBorder($sheet,"A$f:C$f");
			$this->cell($sheet,date("d/m/Y",strtotime($arrayTmp[$fil]['fecha_mov'])),"D$f",3,$f,"center",false,$this->tam_letra_detalle,Arial,true,true);
			$sheet->mergeCells("D$f:E$f");
			$this->cellBorder($sheet,"D$f:E$f");
			$this->cell($sheet,number_format($arrayTmp[$fil]['tipo_cambio_ini'],6),"F$f",5,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['tipo_cambio_fin'],6),"G$f",6,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['factor'],6),"H$f",7,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$arrayTmp[$fil]['fecha_dep'],"I$f",8,$f,"center",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['monto_actualiz_ant'],2),"J$f",9,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['inc_monto_actualiz'],2),"K$f",10,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['monto_actualiz'],2),"L$f",11,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$arrayTmp[$fil]['vida_util_ant'],"M$f",12,$f,"center",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['depreciacion_acum_ant'],2),"N$f",13,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['inc_dep_acum'],2),"O$f",14,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['depreciacion_acum_actualiz'],2),"P$f",15,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['depreciacion'],2),"Q$f",16,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['depreciacion_per'],2),"R$f",17,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['depreciacion_acum'],2),"S$f",18,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,number_format($arrayTmp[$fil]['monto_vigente'],2),"T$f",19,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
		}

		//Borde a la caja
		$this->cellBorder($sheet,"A".$this->fila.":Q$f",'vertical');
		$this->cellBorder($sheet,"O".$this->fila.":Q$f");

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
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setOrientation(PHPExcel_Worksheet_PageSetup::ORIENTATION_PORTRAIT);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setPaperSize(PHPExcel_Worksheet_PageSetup::PAPERSIZE_LETTER);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setFitToWidth(1);
		$this->docexcel->setActiveSheetIndex(0)->getPageSetup()->setFitToHeight(0);

	}

	function firmas($sheet){
		$f=$this->fila;
		$this->cell($sheet,'Jefe de Activos Fijos',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);
		$f++;
		$this->cell($sheet,'',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);
	}
	
	function setDataSet($dataset){
		$this->dataSet = $dataset;
	}

	function initializeColumnAnchos(){
		$this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(5);
		$this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('J')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('K')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('L')->setWidth(15);
		//$this->docexcel->getActiveSheet()->getColumnDimension('M')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('N')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('O')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('P')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('Q')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('R')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('S')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('T')->setWidth(15);
	}

	function setTipoReporte($val){
		$this->tipo_reporte = $val;
	}

	function setTituloReporte($val){
		$this->titulo_reporte = $val;
	}

	function setMoneda($val){
		if($val!=''){
			$this->desc_moneda = $val;
		}
	}
	
}
?>