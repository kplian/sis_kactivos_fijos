<?php
class RLogAFCCXls
{
	private $docexcel;
	private $objWriter;
	private $numero;
	private $equivalencias=array();
	private $objParam;
	public  $url_archivo;
	function __construct(CTParametro $objParam)
	{
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
		$this->equivalencias=array( 0=>'A',1=>'B',2=>'C',3=>'D',4=>'E',5=>'F',6=>'G',7=>'H',8=>'I',
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
	}
	//
	function imprimeCabecera() {
		$this->docexcel->createSheet();		
		$this->docexcel->getActiveSheet()->setTitle('INFORMACION NO SUBIDA');	
		$this->docexcel->setActiveSheetIndex(0);
		$datos = $this->objParam->getParametro('datos');
        $styleTitulos1 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 12,
                'name'  => 'Arial'
            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
        );
        $styleTitulos2 = array(
            'font'  => array(
                'bold'  => true,
                'size'  => 9,
                'name'  => 'Arial',
                'color' => array(
					'rgb' => 'FFFFFF'
                )
            ),
            'alignment' => array(
                'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
                'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
            ),
            'fill' => array(
                'type' => PHPExcel_Style_Fill::FILL_SOLID,
                'color' => array(
                    'rgb' => '0066CC'
                )
            ),
            'borders' => array(
                'allborders' => array(
					'style' => PHPExcel_Style_Border::BORDER_THIN
                )
            ));
		$styleTitulos3 = array(
			'font'  => array(
				'bold'  => true,
				'size'  => 11,
				'name'  => 'Arial'
			),
			'alignment' => array(
				'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
				'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER,
			),
		);
		
		//$this->docexcel->getActiveSheet()->getStyle('B2:G2')->applyFromArray($styleTitulos1);
		//$this->docexcel->getActiveSheet()->mergeCells('B2:G2');
		
		$this->docexcel->getActiveSheet()->getColumnDimension('B')->setWidth(10);
		$this->docexcel->getActiveSheet()->getColumnDimension('C')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('D')->setWidth(15);
		$this->docexcel->getActiveSheet()->getColumnDimension('E')->setWidth(10);
		$this->docexcel->getActiveSheet()->getColumnDimension('F')->setWidth(10);
		$this->docexcel->getActiveSheet()->getColumnDimension('G')->setWidth(70);
		
		$this->docexcel->getActiveSheet()->getStyle('B2:G2')->getAlignment()->setWrapText(true);
		$this->docexcel->getActiveSheet()->getStyle('B2:G2')->applyFromArray($styleTitulos2);
		//*************************************Cabecera*****************************************
		$this->docexcel->getActiveSheet()->setCellValue('B2','Nº');
		$this->docexcel->getActiveSheet()->setCellValue('C2','ACTIVO FIJO');
		$this->docexcel->getActiveSheet()->setCellValue('D2','CENTRO COSTO');
		
		$this->docexcel->getActiveSheet()->setCellValue('E2','MES');
		$this->docexcel->getActiveSheet()->setCellValue('F2','CANTIDAD HORAS');
		$this->docexcel->getActiveSheet()->setCellValue('G2','DETALLE');
		
		
		
	}
	//
	function generarDatos()
	{
		$styleTitulos3 = array(
			'font'  => array(
				'bold'  => true,
				'size'  => 12,
				'name'  => 'Arial',
				'color' => array(
					'rgb' => 'FFFFFF'
				)
			),
			'alignment' => array(
				'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
				'vertical' => PHPExcel_Style_Alignment::VERTICAL_CENTER
			),
			'fill' => array(
				'type' => PHPExcel_Style_Fill::FILL_SOLID,
				'color' => array(
					'rgb' => '707A82'
				)
			),
			'borders' => array(
				'allborders' => array(
					'style' => PHPExcel_Style_Border::BORDER_THIN
				)
			)
		);
		$this->numero = 1;
		$fila = 3;
		$datos = $this->objParam->getParametro('datos');
		
		$this->imprimeCabecera(0);
		
		foreach ($datos as $value){
			
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(1, $fila, $this->numero);
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(2, $fila, $value['activo_fijo']);
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(3, $fila, $value['centro_costo']);
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(4, $fila, $value['mes']);
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(5, $fila, trim($value['cantidad_horas']));
			$this->docexcel->getActiveSheet()->setCellValueByColumnAndRow(6, $fila, $value['detalle']);
			$fila++;
			$this->numero++;			
		}					
	}
	//
	function generarReporte(){
		$this->objWriter = PHPExcel_IOFactory::createWriter($this->docexcel, 'Excel5');
		$this->objWriter->save($this->url_archivo);
		$this->imprimeCabecera(0);
	}
	
}
?>