<?php
/**
*@package pXP
*@file ParametrosRepSaldoAf.php
*@author  RCM
*@date 23/09/2020
*@description Parámetros para reporte de Saldos de Activos Fijos
*/
/***************************************************************************
#ISSUE  SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
 #AF-13  KAF     ETR         23-09-2020  RCM     Creación de archivo
***************************************************************************/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepSaldoAf = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepSaldoAf.superclass.constructor.call(this,config);
		this.definicionRutareporte();
		this.definirParametros();

		//Eventos
		this.definirEventos();
	},
	definirEventos: function(){
		this.cmbActivo.on('select',function(){
			this.cmbClasificacion.setValue('');
		},this);
		this.cmbClasificacion.on('select',function(){
			this.cmbActivo.setValue('');
		},this);
	},
	definicionRutareporte: function(report){
		console.log('aqui aqui');
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteDepreciacion.php';
		this.claseReporte = 'ReporteDepreciacion';
		this.titleReporte = 'Depreciación al ';
	},
	definirParametros: function(report){
		this.inicializarParametros();

		this.configElement(this.dteFechaDesde,false,true);
		this.configElement(this.dteFechaHasta,true,false);
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
		this.configElement(this.lblDesde,false,true);
		this.configElement(this.lblHasta,false,true);
		this.configElement(this.cmpFechas,true,true);
		this.configElement(this.txtMontoInf,false,true);
		this.configElement(this.txtMontoSup,false,true);
		this.configElement(this.lblMontoInf,false,true);
		this.configElement(this.lblMontoSup,false,true);
		this.configElement(this.txtNroCbteAsociado,false,true);
		this.configElement(this.cmpMontos,false,true);
		this.configElement(this.cmbMoneda,false,true);
		this.configElement(this.radGroupEstadoMov,false,true);
		this.configElement(this.cmpFechaCompra,false,true);
		this.configElement(this.radGroupDeprec,false,true);

		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},

	onSubmit: function(){
		if(this.formParam.getForm().isValid()) {
			Phx.CP.loadingShow();
            //Genera el reporte
            var params = this.getParams();
            console.log('YYY', params);
            Ext.Ajax.request({
                url:'../../sis_kactivos_fijos/control/Reportes/generarReporteSaldoAf',
                params: {
                    fecha: params.fecha_hasta
                },
                success: this.successExport,
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope: this
            });
		}
	},

	setPersonalBackgroundColor: function(elm){
    	//Para sobreescribir
    	var color='#FFF',
    		obligatorio='#ffffb3';

    	if(elm=='dteFechaHasta'||elm=='cmbMoneda'){
    		color = obligatorio;
    	}
    	return color;
    },

    getExtraParams: function() {

    }

}
</script>