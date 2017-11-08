<?php
/**
*@package pXP
*@file gen-ACTMovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Clase que recibe los parametros enviados por la vista para mandar a la capa de Modelo
*/

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




			
}

?>