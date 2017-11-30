<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepKardex = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepKardex.superclass.constructor.call(this,config);
		this.definicionRutareporte();
		this.definirParametros();

		//Eventos
		this.definirEventos();
	},
	definirEventos: function(){
		//Responsable
		this.cmbResponsable.on('select',function(combo,record,index){
			this.repResponsable = record.data['desc_funcionario1'];
			this.repCargo = record.data['nombre_cargo'];
		}, this);

		//Depto
		this.repDepto = '%'
		this.cmbDepto.on('select',function(combo,record,index){
			this.repDepto = record.data['nombre'];
		}, this);

		//Oficina
		this.repOficina = '%'
		this.cmbOficina.on('select',function(combo,record,index){
			this.repOficina = record.data['nombre'];
		}, this);

		//Depósito
		this.cmbDeposito.on('select',function(combo,record,index){
			this.repDeposito = record.data['nombre'];
		}, this);
	},
	definicionRutareporte: function(report){
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteKardex.php';
		this.claseReporte = 'ReporteKardex';
		this.titleReporte = 'Kardex Activos Fijos';
	},
	definirParametros: function(report){
		this.inicializarParametros();

		this.configElement(this.dteFechaDesde,true,false);
		this.configElement(this.dteFechaHasta,true,false);
		this.configElement(this.cmbActivo,true,false);

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
		this.configElement(this.cmpFechas,true,true);
		this.configElement(this.txtMontoInf,false,true);
		this.configElement(this.txtMontoSup,false,true);
		this.configElement(this.lblMontoInf,false,true);
		this.configElement(this.lblMontoSup,false,true);
		this.configElement(this.txtNroCbteAsociado,false,true);
		this.configElement(this.cmpMontos,false,true);
		this.configElement(this.cmbMoneda,true,false);
		this.configElement(this.radGroupEstadoMov,true,false);
		this.configElement(this.cmpFechaCompra,false,true);
		this.configElement(this.txtNroCbteAsociado,false,true);

		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,true,true);
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

			
		}
	},
	getExtraParams: function(){
		var params = {
			repResponsable: this.repResponsable,
			repCargo: this.repCargo,
			repDepto: this.repDepto,
			repOficina: this.repOficina,
			repDeposito: this.repDeposito
		}
		return params;
	},
	setPersonalBackgroundColor: function(elm){
    	//Para sobreescribir
    	var color='#FFF',
    		obligatorio='#ffffb3';
    	if(elm=='dteFechaDesde'||elm=='dteFechaHasta'||elm=='cmbActivo'||elm=='cmbMoneda'){
    		color = obligatorio;
    	}
    	return color;
    }

}
</script>