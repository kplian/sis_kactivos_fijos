<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepAsignados = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepAsignados.superclass.constructor.call(this,config);
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
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteAsignados.php';
		this.claseReporte = 'ReporteAsignados';
		this.titleReporte = 'Reportes asignados';

	},
	definirParametros: function(report){
		this.inicializarParametros();

		this.configElement(this.dteFechaDesde,false,true);
		this.configElement(this.dteFechaHasta,false,true);
		this.configElement(this.cmbActivo,false,true);

		this.configElement(this.cmbClasificacion,true,true);
		this.configElement(this.txtDenominacion,true,true);
		this.configElement(this.dteFechaCompra,true,true);
		this.configElement(this.dteFechaIniDep,true,true);
		this.configElement(this.cmbEstado,true,true);
		this.configElement(this.cmbCentroCosto,false,true);
		this.configElement(this.txtUbicacionFisica,true,true);
		this.configElement(this.cmbOficina,true,true);
		this.configElement(this.cmbResponsable,true,true);
		this.configElement(this.cmbUnidSolic,false,true);
		this.configElement(this.cmbResponsableCompra,false,true);
		this.configElement(this.cmbLugar,false,true);
		this.configElement(this.radGroupTransito,false,true);
		this.configElement(this.radGroupTangible,false,true);
		this.configElement(this.cmbDepto,false,true);
		this.configElement(this.cmbDeposito,false,true);
		this.configElement(this.lblHasta,false,true);
		this.configElement(this.cmpFechas,false,true);
		this.configElement(this.txtMontoInf,true,true);
		this.configElement(this.txtMontoSup,true,true);
		this.configElement(this.lblMontoInf,true,true);
		this.configElement(this.lblMontoSup,true,true);
		this.configElement(this.txtNroCbteAsociado,true,true);
		this.configElement(this.cmpMontos,true,true);
		this.configElement(this.cmbMoneda,true,true);
		this.configElement(this.radGroupEstadoMov,false,true);

		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},
	onSubmit: function(){
		if(this.formParam.getForm().isValid()){
			var win = Phx.CP.loadWindows(
				this.rutaReporte,
                this.titleReporte, {
                    width: 870,
                    height : 620
                }, { 
                    paramsRep: this.getParams()
                },
                this.idContenedor,
                this.claseReporte
            );

			
		} else {
			Ext.MessageBox.alert('Información','Debe seleccionar alguno de los dos criterios.');
		}
	}

}
</script>