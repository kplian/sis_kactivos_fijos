<?php
/**
*@package pXP
*@file ParametrosRepInventarioDetallado.php
*@author RCM
*@date 12/08/2019
*@description Parámetros para generación del Reporte Inventario Detallado por Grupo Contable
/*
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #24    KAF       ETR           12/08/2019  RCM         Creación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepInventarioDetallado = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',

	constructor: function(config){
		Phx.vista.ParametrosRepInventarioDetallado.superclass.constructor.call(this,config);
		this.definicionRutareporte();
		this.definirParametros();

		//Eventos
		this.definirEventos();
	},

	definirEventos: function(){

	},

	definicionRutareporte: function(report){
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteInventarioDetallado.php';
		this.claseReporte = 'ReporteInventarioDetallado';
		this.titleReporte = 'Inventario Detallado Activos Fijos por Grupo Contable';
	},

	definirParametros: function(report){
		this.inicializarParametros();

		//Visibles
		this.configElement(this.dteFechaHasta, true, false);
		this.configElement(this.cmpFechas, true, false);
		this.configElement(this.lblHasta, false, true);
		this.configElement(this.cmbMoneda,true,false);
		this.configElement(this.cmbActivoFijoMulti,true,true);
		this.configElement(this.txtDenominacion,true,true);

		//No Visibles
		this.configElement(this.dteFechaDesde, false, true);
		this.configElement(this.cmbActivo, false, true);
		this.configElement(this.cmbClasificacion,false,true);
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
		this.configElement(this.radGroupTangible,true,true);
		this.configElement(this.cmbDepto,false,true);
		this.configElement(this.cmbDeposito,false,true);
		this.configElement(this.lblDesde,false,true);
		this.configElement(this.txtMontoInf,true,true);
		this.configElement(this.txtMontoSup,true,true);
		this.configElement(this.lblMontoInf,true,true);
		this.configElement(this.lblMontoSup,true,true);
		this.configElement(this.txtNroCbteAsociado,false,true);
		this.configElement(this.cmpMontos,false,true);
		this.configElement(this.radGroupEstadoMov,false,true);
		this.configElement(this.cmpFechaCompra,false,true);
		this.configElement(this.radGroupDeprec,false,true);
		this.configElement(this.cmbGestion, false, true);
		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},

	onSubmit: function(){
		if(this.formParam.getForm().isValid()){
			var win = Phx.CP.loadWindows(
				this.rutaReporte,
                this.titleReporte, {
                    width: 870,
                    height: 620
                }, {
                    paramsRep: this.getParams()
                },
                this.idContenedor,
                this.claseReporte
            );
		}
	},

	getExtraParams: function(){
		var params = {
			repResponsable: this.repResponsable,
			repCargo: this.repCargo,
			repDepto: this.repDepto,
			repOficina: this.repOficina
		}
		return params;
	}

}
</script>