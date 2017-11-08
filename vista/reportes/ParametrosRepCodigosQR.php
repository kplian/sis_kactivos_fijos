<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepCodigosQR = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepCodigosQR.superclass.constructor.call(this,config);
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
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/RCodigoQRAFVarios.php';
		this.claseReporte = 'RCodigoQRAFVarios';
		this.titleReporte = 'Código QR';
	},
	definirParametros: function(report){
		this.inicializarParametros();

		this.configElement(this.dteFechaDesde,false,true);
		this.configElement(this.dteFechaHasta,false,true);
		this.configElement(this.cmbActivo,true,true);
		this.configElement(this.cmbClasificacion,true,true);
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
		this.configElement(this.lblHasta,false,true);
		this.configElement(this.cmpFechas,false,true);
		this.configElement(this.txtMontoInf,false,true);
		this.configElement(this.txtMontoSup,false,true);
		this.configElement(this.lblMontoInf,false,true);
		this.configElement(this.lblMontoSup,false,true);
		this.configElement(this.txtNroCbteAsociado,false,true);
		this.configElement(this.cmpMontos,false,true);
		this.configElement(this.cmbMoneda,false,true);
		this.configElement(this.radGroupEstadoMov,false,true);

		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},
	onSubmit: function(){
		console.log('aaa',Phx.CP.successExport);
		if(this.formParam.getForm().isValid()){
			if(this.cmbActivo.getValue()!=''||this.cmbClasificacion.getValue()!=''){
				Phx.CP.loadingShow();
				//Generación del reporte
		        Ext.Ajax.request({
	                url: '../../sis_kactivos_fijos/control/ActivoFijo/repCodigoQRVarios',
	                params: {
	                	id_activo_fijo: this.cmbActivo.getValue(),
	                	id_clasificacion: this.cmbClasificacion.getValue()
	                },
	                success: this.successExport,
	                failure: this.conexionFailure,
	                timeout: this.timeout,
	                scope: this
	            });
			} else {
				Ext.MessageBox.alert('Información','Debe seleccionar alguno de los dos criterios.');
			}
			
		}
	}

}
</script>