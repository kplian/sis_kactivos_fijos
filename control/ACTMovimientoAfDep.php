<?php
/**
*@package pXP
*@file gen-ACTMovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/
/***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #11    KAF       ETR           11/01/2019  RCM         Actualización de listado detalle depreciación interfaz
 #35    KAF       ETR           11/10/2019  RCM     	Adición de botón para procesar Detalle Depreciación
 #AF-12 KAF       ETR      		08/09/2020  RCM         Reporte de saldos en las tres monedas a una fecha
 ***************************************************************************/

class ACTMovimientoAfDep extends ACTbase{

	function listarMovimientoAfDep(){
		$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento_af')!=''){
			$this->objParam->addFiltro("mafdep.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
		}

		if($this->objParam->getParametro('id_activo_fijo_valor')!=''){
			$this->objParam->addFiltro("mafdep.id_activo_fijo_valor = ".$this->objParam->getParametro('id_activo_fijo_valor'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarMovimientoAfDep');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');

			$this->res=$this->objFunc->listarMovimientoAfDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function insertarMovimientoAfDep(){
		$this->objFunc=$this->create('MODMovimientoAfDep');
		if($this->objParam->insertar('id_movimiento_af_dep')){
			$this->res=$this->objFunc->insertarMovimientoAfDep($this->objParam);
		} else{
			$this->res=$this->objFunc->modificarMovimientoAfDep($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function eliminarMovimientoAfDep(){
			$this->objFunc=$this->create('MODMovimientoAfDep');
		$this->res=$this->objFunc->eliminarMovimientoAfDep($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarMovimientoAfDepRes(){
		$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento_af')!=''){
			$this->objParam->addFiltro("mafdep.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
		}

		if($this->objParam->getParametro('id_activo_fijo_valor')!=''){
			$this->objParam->addFiltro("mafdep.id_activo_fijo_valor = ".$this->objParam->getParametro('id_activo_fijo_valor'));
		}

        if($this->objParam->getParametro('fecha_hasta')!=''){
			$this->objParam->addFiltro("mafdep.fecha  <= ''".$this->objParam->getParametro('fecha_hasta')."''::date");
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarMovimientoAfDepRes');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');

			$this->res=$this->objFunc->listarMovimientoAfDepRes($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarMovimientoAfDepResCab(){
			$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
			$this->objParam->defecto('dir_ordenacion','asc');

			if($this->objParam->getParametro('id_movimiento_af')!=''){
				$this->objParam->addFiltro("mafdep.id_movimiento_af = ".$this->objParam->getParametro('id_movimiento_af'));
			}

			if($this->objParam->getParametro('id_movimiento')!=''){
				$this->objParam->addFiltro("movaf.id_movimiento = ".$this->objParam->getParametro('id_movimiento'));
			}


			if($this->objParam->getParametro('id_activo_fijo')!=''){
				$this->objParam->addFiltro("actval.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
			}

			if($this->objParam->getParametro('id_moneda_dep')!=''){
				$this->objParam->addFiltro("actval.id_moneda_dep = ".$this->objParam->getParametro('id_moneda_dep'));
			}

			if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
				$this->objReporte = new Reporte($this->objParam,$this);
				$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarMovimientoAfDepResCab');
			} else{
				$this->objFunc=$this->create('MODMovimientoAfDep');

				$this->res=$this->objFunc->listarMovimientoAfDepResCab($this->objParam);
			}

			$temp = Array();
			$temp['monto_actualiz_real'] = $this->res->extraData['total_monto_actualiz_real'];
			$temp['depreciacion_acum_real'] = $this->res->extraData['total_depreciacion_acum_real'];
			$temp['monto_vigente_real'] = $this->res->extraData['total_monto_vigente_real'];

			$temp['vida_util_real'] = $this->res->extraData['max_vida_util_real'];
			$temp['tipo_reg'] = 'summary';
			$temp['id_activo_fijo_valor'] = 0;
			$this->res->total++;
			$this->res->addLastRecDatos($temp);


			$this->res->imprimirRespuesta($this->res->generarJson());
	}

     function listarMovimientoAfDepResCabPr(){
			$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
			$this->objParam->defecto('dir_ordenacion','asc');

			if($this->objParam->getParametro('id_moneda_dep')!=''){
				$this->objParam->addFiltro("actval.id_moneda_dep = ".$this->objParam->getParametro('id_moneda_dep'));
			}

			if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
				$this->objReporte = new Reporte($this->objParam,$this);
				$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarMovimientoAfDepResCabPr');
			} else{
				$this->objFunc=$this->create('MODMovimientoAfDep');
				$this->res=$this->objFunc->listarMovimientoAfDepResCabPr($this->objParam);
			}

			$temp = Array();
			$temp['monto_actualiz_real'] = $this->res->extraData['total_monto_actualiz_real'];
			$temp['depreciacion_acum_real'] = $this->res->extraData['total_depreciacion_acum_real'];
			$temp['monto_vigente_real'] = $this->res->extraData['total_monto_vigente_real'];

			$temp['vida_util_real'] = $this->res->extraData['max_vida_util_real'];
			$temp['tipo_reg'] = 'summary';
			$temp['id_activo_fijo_valor'] = 0;
			$this->res->total++;
			$this->res->addLastRecDatos($temp);


			$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarDepreciacionMensual(){
		$this->objParam->defecto('ordenacion','id_movimiento_af_dep');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_movimiento')!=''){
			$this->objParam->addFiltro("maf.id_movimiento = ".$this->objParam->getParametro('id_movimiento'));
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarDepreciacionMensual');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');

			$this->res=$this->objFunc->listarDepreciacionMensual($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	//Inicio #11: Actualización listado detalle depreciación interfaz
	function listarDeprecFormato(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afv.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("mdep.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('fecha_mov')!=''){
			$this->objParam->addFiltro("DATE_TRUNC('month', mdep.fecha) = DATE_TRUNC('month',".$this->objParam->getParametro('fecha_mov').")");
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarDeprecFormato');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');

			$this->res=$this->objFunc->listarDeprecFormato($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function listarDeprecFormatoTotales(){
		$this->objParam->defecto('ordenacion','id_activo_fijo_valor');
		$this->objParam->defecto('dir_ordenacion','asc');

		if($this->objParam->getParametro('id_activo_fijo')!=''){
			$this->objParam->addFiltro("afv.id_activo_fijo = ".$this->objParam->getParametro('id_activo_fijo'));
		}

		if($this->objParam->getParametro('id_moneda')!=''){
			$this->objParam->addFiltro("mdep.id_moneda = ".$this->objParam->getParametro('id_moneda'));
		}

		if($this->objParam->getParametro('fecha')!=''){
			$this->objParam->addFiltro("DATE_TRUNC(''month'', mdep.fecha) = DATE_TRUNC(''month'',''".$this->objParam->getParametro('fecha')."''::date)");
		}

		if($this->objParam->getParametro('tipoReporte')=='excel_grid' || $this->objParam->getParametro('tipoReporte')=='pdf_grid'){
			$this->objReporte = new Reporte($this->objParam,$this);
			$this->res = $this->objReporte->generarReporteListado('MODMovimientoAfDep','listarDeprecFormatoTotales');
		} else{
			$this->objFunc=$this->create('MODMovimientoAfDep');

			$this->res=$this->objFunc->listarDeprecFormatoTotales($this->objParam);
		}
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #11

	//Inicio #35
	function procesarDetalleDepreciacion(){
		$this->objFunc = $this->create('MODMovimientoAfDep');
		$this->res = $this->objFunc->procesarDetalleDepreciacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}

	function verificarProcesarDetalleDepreciacion(){
		$this->objFunc = $this->create('MODMovimientoAfDep');
		$this->res = $this->objFunc->verificarProcesarDetalleDepreciacion($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #35

	//Inicio #AF-12
	function listarSaldoAf(){
		$this->objFunc = $this->create('MODMovimientoAfDep');
		$this->res = $this->objFunc->listarSaldoAf($this->objParam);
		$this->res->imprimirRespuesta($this->res->generarJson());
	}
	//Fin #AF-12

}

?>