<?php
class RReporteGralAFXls
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
		/*$this->imprimeCabecera($sheet);
		$this->firstBox($sheet);
		$this->secondBox($sheet);*/
		$this->mainBox($sheet);
		$this->firmas($sheet);
		// Set active sheet index to the first sheet, so Excel opens this as the first sheet
		$this->docexcel->setActiveSheetIndex(0);
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);		
	}

	function imprimeTitulo($sheet) {
		$sheet->setCellValueByColumnAndRow(0,1,$this->objParam->getParametro('titulo_rep'));
		//Título Principal
		$titulo1 = "";
		$this->cell($sheet,$titulo1,'A1',0,1,"center",true,$this->tam_letra_titulo,Arial);
		$sheet->mergeCells('A1:Z1');

		if($this->tipo_reporte=='rep.sasig'){
			//Título 1
			//echo 'fuck fuk: '.$this->titulo_reporte;exit;
			$titulo1 = $this->titulo_reporte;
			$this->cell($sheet,$titulo1,'A2',0,2,"center",true,$this->tam_letra_titulo,Arial);
			$sheet->mergeCells('A2:Z2');
			//Título 2
			$fecha_hasta = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
			$titulo2 = "AL ".$fecha_hasta;
			$this->cell($sheet,$titulo2,'A3',0,3,"center",true,$this->tam_letra_subtitulo,Arial);
			$sheet->mergeCells('A3:Z3');
			//Título 3
			$titulo3="(Expresado en ".$this->desc_moneda.")";
			$this->cell($sheet,$titulo3,'A4',0,4,"center",true,$this->tam_letra_subtitulo,Arial);
			$sheet->mergeCells('A4:Z4');
		} else if($this->tipo_reporte=='rep.asig'){
			//Título 1
			$titulo1 = $this->titulo_reporte;
			$this->cell($sheet,$titulo1,'A2',0,2,"center",true,$this->tam_letra_titulo,Arial);
			$sheet->mergeCells('A2:Z2');
			//Título 2
			$fecha_hasta = date("d/m/Y",strtotime($this->objParam->getParametro('fecha_hasta')));
			$titulo2 = "AL ".$fecha_hasta;
			$this->cell($sheet,$titulo2,'A3',0,3,"center",true,$this->tam_letra_subtitulo,Arial);
			$sheet->mergeCells('A3:Z3');
			//Título 3
			$titulo3="(Expresado en ".$this->desc_moneda.")";
			$this->cell($sheet,$titulo3,'A4',0,4,"center",true,$this->tam_letra_subtitulo,Arial);
			$sheet->mergeCells('A4:Z4');
		}
		
		//Logo
		$objDrawing = new PHPExcel_Worksheet_Drawing();
		$objDrawing->setName('Logo');
		$objDrawing->setDescription('Logo');
		$objDrawing->setPath(dirname(__FILE__).'/../../lib'.$_SESSION['_DIR_LOGO']);
		$objDrawing->setHeight(50);
		$objDrawing->setWorksheet($this->docexcel->setActiveSheetIndex(0));

		$this->fila = 8;
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
		$this->cell($sheet,'UFV FECHA DE COMPRA','A11',0,11,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'VIDA ÚTIL ORIGINAL (MESES)','A12',0,12,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'CENTRO DE COSTOS','A13',0,13,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'UNIDAD SOLICITANTE','A14',0,14,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'RESPONSABLE DE LA COMPRA','A15',0,15,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'LUGAR DE COMPRA','A16',0,16,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'UBICACIÓN FÍSICA','A17',0,17,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'UBICACIÓN DEL BIEN (CIUDAD)','A18',0,18,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'RESPONSABLE DEL BIEN','A19',0,19,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'No DE C31','A20',0,20,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'FECHA DE C31','A21',0,21,"",true,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,'No DE PROCESO','A22',0,22,"",true,$this->tam_letra_cabecera,Arial);

		$this->cell($sheet,$record['codigo'],'E5',4,5,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_clasif'],'E6',4,6,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['denominacion'],'E7',4,7,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['fecha_compra'],'E8',4,8,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['fecha_ini_dep'],'E9',4,9,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['estado'],'E10',4,10,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['ufv_fecha_compra'],'E11',4,11,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['vida_util_original'],'E12',4,12,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_centro_costo'],'E13',4,13,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_uo_solic'],'E14',4,14,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['desc_funcionario_compra'],'E15',4,15,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['lugar_compra'],'E16',4,16,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['ubicacion'],'E17',4,17,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['ciudad'],'E18',4,18,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['responsable'],'E19',4,19,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['nro_cbte_asociado'],'E20',4,20,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['fecha_cbte_asociado'],'E21',4,21,"",false,$this->tam_letra_cabecera,Arial);
		$this->cell($sheet,$record['num_tramite'],'E22',4,22,"",false,$this->tam_letra_cabecera,Arial);

		//Segunda columna
		$this->cell($sheet,'NUMERAL','J6',9,6,"",true,10,Arial);
		$this->cell($sheet,'MONTO','J11',9,11,"",true,10,Arial);
		$this->cell($sheet,'% DEPRECIACIÓN','J12',9,12,"",true,10,Arial);
		$this->cell($sheet,'MÉTODO DEPRECIACIÓN','J13',9,13,"",true,10,Arial);
		$this->cell($sheet,'OFICINA','J14',9,14,"",true,10,Arial);

		$this->cell($sheet,$record['cod_clasif'],'M6',12,6,"",false,10,Arial);
		$this->cell($sheet,$record['monto_compra_orig'],'M11',12,11,"",false,10,Arial);
		$this->cell($sheet,$record['porcentaje_dep'],'M12',12,12,"",false,10,Arial);
		$this->cell($sheet,$record['metodo_dep'],'M13',12,13,"",false,10,Arial);
		$this->cell($sheet,$record['desc_oficina'],'M14',12,14,"",false,10,Arial);

		//Actualiza número de fila
		$this->fila = 25;
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

	function mainBox($sheet){
		//Cabecera caja
		$f = $this->fila;
		$this->cell($sheet,'NRO.',"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'CÓDIGO',"B$f",1,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DENOMINACIÓN',"C$f",2,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DESCRIPCIÓN',"D$f",3,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'FECHA INI.DEP.',"E$f",4,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'COMP. 100%',"F$f",5,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'COMP. 87%',"G$f",6,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'VALOR RESIDUAL GESTION ANTERIOR',"H$f",7,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'INCORPORACIONES GESTION ACTUAL',"I$f",8,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'REVALORIZACIONES',"J$f",9,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'AJUSTES (+ o -)',"K$f",10,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'BAJAS',"L$f",11,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'TRANSITO',"M$f",12,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'INC. ACTUALIZ/ACUMULADO',"N$f",13,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'INC. ACTUALIZ DEL PERIODO',"O$f",14,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'VAL. ACTUALIZ',"P$f",15,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'VIDA USADA',"Q$f",16,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'VIDA RESI',"R$f",17,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DEP ACUM GEST ANT',"S$f",18,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'ACT DEP GEST ANT',"T$f",19,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DEP GESTION',"U$f",20,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DEP DEL PERIODO',"V$f",21,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'DEP ACUM',"W$f",22,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'IMPUESTOS',"X$f",23,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'UBICACIÓN FISICA',"Y$f",24,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$this->cell($sheet,'RESPONSABLE',"Z$f",25,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);

		//////////////////
		//Detalle de datos
		//////////////////
		//Array totalizador
		$arrayTotal = array(
		 	'monto_compra_orig_100' => 0,
		 	'monto_compra_orig'=>0,
		 	'valor_residual_gest_ant' => 0,
		 	'inc_gest_actual'=>0,
		 	'ajustes' => 0,
		 	'bajas'=>0,
		 	'transito' => 0,
		 	'inc_actualiz_acum'=>0,
		 	'inc_actualiz_per' => 0,
		 	'val_actualiz'=>0,
		 	'dep_acum_gest_ant' => 0,
		 	'act_dep_gest_ant'=>0,
		 	'dep_gestion' => 0,
		 	'dep_periodo'=>0,
		 	'dep_acum' => 0,
		 	'valor_residual'=>0,
		 	'impuestos' => 0
		);
		echo '<pre>';
		print_r($this->dataSet);
		echo '</pre>';
		exit;

		for ($fil=0; $fil < count($this->dataSet); $fil++) {
			$f++;
			//Fecha
			$fecha='';
			if($this->dataSet[$fil]['fecha_ini_dep']!=''){
				$fecha=date("d/m/Y",strtotime($this->dataSet[$fil]['fecha_ini_dep']));
			}
			$this->cell($sheet,$fil+1,"A$f",0,$f,"right",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['codigo'],"B$f",1,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['denominacion'],"C$f",2,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['descripcion'],"D$f",3,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$fecha,"E$f",4,$f,"center",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['monto_vigente_orig_100'],"F$f",5,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['monto_vigente_orig'],"G$f",6,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['valor_residual_gest_ant'],"H$f",7,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['inc_gest_actual'],"I$f",8,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['ajustes'],"J$f",9,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['bajas'],"K$f",10,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['transito'],"L$f",11,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['inc_actualiz_acum'],"M$f",12,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['inc_actualiz_per'],"N$f",13,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['val_actualiz'],"O$f",14,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['vida_usada'],"P$f",15,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['vida_residual'],"Q$f",16,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['dep_acum_gest_ant'],"R$f",17,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['act_dep_gest_ant'],"S$f",18,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['dep_gestion'],"T$f",19,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['dep_periodo'],"U$f",20,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['dep_acum'],"V$f",21,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['valor_residual'],"W$f",22,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['impuestos'],"X$f",23,$f,"right",false,$this->tam_letra_detalle,Arial,false,true);
			$this->cell($sheet,$this->dataSet[$fil]['ubicacion'],"Y$f",24,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);
			$this->cell($sheet,$this->dataSet[$fil]['responsable'],"Z$f",25,$f,"left",false,$this->tam_letra_detalle,Arial,true,true);

			//Actualiza los totales
			$arrayTotal['monto_compra_orig_100']+=$this->dataSet[$fil]['monto_compra_orig_100'];
		 	$arrayTotal['monto_compra_orig']+=$this->dataSet[$fil]['monto_compra_orig'];
		 	$arrayTotal['valor_residual_gest_ant']+=$this->dataSet[$fil]['valor_residual_gest_ant'];
		 	$arrayTotal['inc_gest_actual']+=$this->dataSet[$fil]['inc_gest_actual'];
		 	$arrayTotal['ajustes']+=$this->dataSet[$fil]['ajustes'];
		 	$arrayTotal['bajas']+=$this->dataSet[$fil]['bajas'];
		 	$arrayTotal['transito']+=$this->dataSet[$fil]['transito'];
		 	$arrayTotal['inc_actualiz_acum']+=$this->dataSet[$fil]['inc_actualiz_acum'];
		 	$arrayTotal['inc_actualiz_per']+=$this->dataSet[$fil]['inc_actualiz_per'];
		 	$arrayTotal['val_actualiz']+=$this->dataSet[$fil]['val_actualiz'];
		 	$arrayTotal['dep_acum_gest_ant']+=$this->dataSet[$fil]['dep_acum_gest_ant'];
		 	$arrayTotal['act_dep_gest_ant']+=$this->dataSet[$fil]['act_dep_gest_ant'];
		 	$arrayTotal['dep_gestion']+=$this->dataSet[$fil]['dep_gestion'];
		 	$arrayTotal['dep_periodo']+=$this->dataSet[$fil]['dep_periodo'];
		 	$arrayTotal['dep_acum']+=$this->dataSet[$fil]['dep_acum'];
		 	$arrayTotal['valor_residual']+=$this->dataSet[$fil]['valor_residual'];
		 	$arrayTotal['impuestos']+=$this->dataSet[$fil]['impuestos'];
		}

		//Borde a la caja
		$this->cellBorder($sheet,"A".$this->fila.":O$f",'vertical');
		$this->cellBorder($sheet,"O".$this->fila.":O$f");

		//Totales
		$f++;
		$this->cell($sheet,'TOTALES',"A$f",0,$f,"center",true,$this->tam_letra_detalle,Arial,true,true);
		$sheet->mergeCells("A$f:D$f");
		$this->cellBorder($sheet,"A$f:D$f");
		$this->cell($sheet,'',"E$f",4,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['monto_compra_orig_100'],2),"F$f",5,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['monto_compra_orig'],2),"G$f",6,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['valor_residual_gest_ant'],2),"H$f",7,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['inc_gest_actual'],2),"I$f",8,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['ajustes'],2),"J$f",9,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['bajas'],2),"K$f",10,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['transito'],2),"L$f",11,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['inc_actualiz_acum'],2),"M$f",12,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['inc_actualiz_per'],2),"N$f",13,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['val_actualiz'],2),"O$f",14,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,'',"P$f",15,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,'',"Q$f",16,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['dep_acum_gest_ant'],2),"R$f",17,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['act_dep_gest_ant'],2),"S$f",18,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['dep_gestion'],2),"T$f",19,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['dep_periodo'],2),"U$f",20,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['dep_acum'],2),"V$f",21,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['valor_residual'],2),"W$f",22,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,number_format($arrayTotal['impuestos'],2),"X$f",23,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,'',"Y$f",24,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);
		$this->cell($sheet,'',"Z$f",25,$f,"right",true,$this->tam_letra_detalle,Arial,false,true);

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
		$f=$this->fila;
		$this->cell($sheet,'Jefe de Activos Fijos',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);
		$f++;
		$this->cell($sheet,'Lic. Juan Perez Agramont',"C$f",2,$f,"left",true,$this->tam_letra_cabecera,Arial,false,false);
	}

	function setDataSet($dataset){
		$this->dataSet = $dataset;
	}

	function initializeColumnAnchos(){
		$this->docexcel->getActiveSheet()->getColumnDimension('A')->setWidth(5);
		$this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(12);
		$this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(30);
		$this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(50);
		$this->docexcel->getActiveSheet()->getColumnDimension('Y')->setWidth(25);
		$this->docexcel->getActiveSheet()->getColumnDimension('Z')->setWidth(25);
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