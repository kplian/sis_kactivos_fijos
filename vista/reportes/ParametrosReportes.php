<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosReportes = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	reportes: [
		['rep.kard', 'Kardex por Activo Fijo'],
		['rep.sasig', 'Activos Fijos sin asignar'],
		['rep.asig', 'Activos Fijos asignados']
	],
	constructor: function(config){
		Phx.vista.ParametrosReportes.superclass.constructor.call(this,config);
		//Eventos
		this.cmbReporte.on('select',function(combo,record,index){
			this.definirParametros(record.data.key);
			this.definicionRutareporte(record.data.key)
		},this);
	},
	cargaReportes: function(){
		this.cmbReporte.getStore().loadData(this.reportes);
	},
	definicionRutareporte: function(report){
		if(report=='rep.kard'){
			this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteKardex.php';
			this.claseReporte = 'ReporteKardex';
			this.titleReporte = 'Kardex Activo Fijo';
		} else if(report=='rep.sasig'){
			this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteGralAF.php';
			this.claseReporte = 'ReporteGralAF';
			this.titleReporte = 'Activos Fijos Sin Asignar';
		} else if(report=='rep.asig'){
			this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteGralAF.php';
			this.claseReporte = 'ReporteGralAF';
			this.titleReporte = 'Activos Fijos Asignados';
		}
	},
	inicializarParametros: function(){
		this.configElement(this.dteFechaDesde,false,true);
		this.configElement(this.dteFechaHasta,false,true);
		this.configElement(this.cmbActivo,false,true);
		this.configElement(this.cmbClasificacion,false,true);
		this.configElement(this.txtDenominacion,false,true);
		this.configElement(this.dteFechaCompra,false,true);
		this.configElement(this.dteFechaIniDep,false,true);
		this.configElement(this.cmbEstado,false,true);
		this.configElement(this.cmbCentroCosto,false,true);
		this.configElement(this.txtUbicacionFisica,false,true);
		this.configElement(this.cmbOficina,false,true);
		this.configElement(this.cmbResponsable,false,true);
		this.configElement(this.cmbUnidSolic,false,true);
		this.configElement(this.cmbResponsableCompra,false,true);
		this.configElement(this.cmbLugar,false,true);
		this.configElement(this.radGroupTransito,false,true);
		this.configElement(this.radGroupTangible,false,true);
		this.configElement(this.cmbDepto,false,true);
		this.configElement(this.cmbDeposito,false,true);
	},
	definirParametros: function(report){
		this.inicializarParametros();
		if(report=='rep.kard'){
			this.configElement(this.dteFechaDesde,false,false);
			this.configElement(this.dteFechaHasta,false,false);
			this.configElement(this.cmbActivo,false,false);
			this.configElement(this.cmbClasificacion,true,true);
			this.configElement(this.txtDenominacion,true,true);
			this.configElement(this.dteFechaCompra,true,true);
			this.configElement(this.dteFechaIniDep,true,true);
			this.configElement(this.cmbEstado,true,true);
			this.configElement(this.cmbCentroCosto,true,true);
			this.configElement(this.txtUbicacionFisica,true,true);
			this.configElement(this.cmbOficina,true,true);
			this.configElement(this.cmbResponsable,true,true);
			this.configElement(this.cmbUnidSolic,true,true);
			this.configElement(this.cmbResponsableCompra,true,true);
			this.configElement(this.cmbLugar,true,true);
			this.configElement(this.radGroupTransito,true,true);
			this.configElement(this.radGroupTangible,true,true);
			this.configElement(this.cmbDepto,true,true);
			this.configElement(this.cmbDeposito,true,true);
		} else if(report=='rep.estado'){
			this.rutaReporte = '';
		} else if(report=='rep.sasig'){
			this.configElement(this.dteFechaDesde,true,true);
			this.configElement(this.dteFechaHasta,true,true);
			this.configElement(this.cmbActivo,true,true);
			this.configElement(this.cmbClasificacion,false,true);
			this.configElement(this.txtDenominacion,false,true);
			this.configElement(this.dteFechaCompra,false,true);
			this.configElement(this.dteFechaIniDep,false,true);
			this.configElement(this.cmbEstado,true,true);
			this.configElement(this.cmbCentroCosto,false,true);
			this.configElement(this.txtUbicacionFisica,false,true);
			this.configElement(this.cmbOficina,false,true);
			this.configElement(this.cmbResponsable,true,true);
			this.configElement(this.cmbUnidSolic,false,true);
			this.configElement(this.cmbResponsableCompra,false,true);
			this.configElement(this.cmbLugar,false,true);
			this.configElement(this.radGroupTransito,false,true);
			this.configElement(this.radGroupTangible,false,true);
			this.configElement(this.cmbDepto,false,true);
			this.configElement(this.cmbDeposito,false,true);
		} else if(report=='rep.asig'){
			this.configElement(this.dteFechaDesde,true,true);
			this.configElement(this.dteFechaHasta,true,true);
			this.configElement(this.cmbActivo,true,true);
			this.configElement(this.cmbClasificacion,false,true);
			this.configElement(this.txtDenominacion,false,true);
			this.configElement(this.dteFechaCompra,false,true);
			this.configElement(this.dteFechaIniDep,false,true);
			this.configElement(this.cmbEstado,false,true);
			this.configElement(this.cmbCentroCosto,false,true);
			this.configElement(this.txtUbicacionFisica,false,true);
			this.configElement(this.cmbOficina,false,true);
			this.configElement(this.cmbResponsable,false,true);
			this.configElement(this.cmbUnidSolic,false,true);
			this.configElement(this.cmbResponsableCompra,false,true);
			this.configElement(this.cmbLugar,false,true);
			this.configElement(this.radGroupTransito,false,true);
			this.configElement(this.radGroupTangible,false,true);
			this.configElement(this.cmbDepto,false,true);
			this.configElement(this.cmbDeposito,false,true);
		}	
	},
	configElement: function(elm,disable,allowBlank){
		elm.setDisabled(disable);
		elm.allowBlank = allowBlank;
	}

};
</script>