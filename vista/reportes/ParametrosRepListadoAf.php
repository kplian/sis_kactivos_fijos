<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepListadoAf = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepListadoAf.superclass.constructor.call(this,config);
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
	},
	definicionRutareporte: function(report){
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteListadoAf.php';
		this.claseReporte = 'ReporteListadoAf';
		this.titleReporte = 'Listado Activos Fijos';
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
		this.configElement(this.cmbLugar,true,true);
		this.configElement(this.radGroupTransito,false,true);
		this.configElement(this.radGroupTangible,false,true);
		this.configElement(this.cmbDepto,true,true);
		this.configElement(this.cmbDeposito,true,true);
		this.configElement(this.lblDesde,false,true);
		this.configElement(this.lblHasta,true,true);
		this.configElement(this.cmpFechas,false,true);
		this.configElement(this.txtMontoInf,true,true);
		this.configElement(this.txtMontoSup,true,true);
		this.configElement(this.lblMontoInf,true,true);
		this.configElement(this.lblMontoSup,true,true);
		this.configElement(this.txtNroCbteAsociado,false,true);
		this.configElement(this.cmpMontos,true,true);
		this.configElement(this.cmbMoneda,false,true);
		this.configElement(this.radGroupEstadoMov,false,true);
		this.configElement(this.cmpFechaCompra,false,true);
		this.configElement(this.radGroupDeprec,false,true);
		this.configElement(this.cmbUbicacion,true,true);

		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},
	onSubmit: function(){
		console.log(this.formParam.getForm());
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
			this.formParam.getForm().markInvalid();
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