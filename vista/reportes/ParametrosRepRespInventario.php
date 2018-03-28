<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ParametrosRepRespInventario = {
	require: '../../../sis_kactivos_fijos/vista/reportes/ParametrosBase.php',
	requireclase: 'Phx.vista.ParametrosBase',
	constructor: function(config){
		Phx.vista.ParametrosRepRespInventario.superclass.constructor.call(this,config);
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

		//Tipo
		this.cmbTipo.on('select',function(combo,record,index){
			if(record.data.key=='lug' || record.data.key=='lug_fun'){
				this.cmbLugar.setVisible(true);
				this.cmbLugar.allowBlank=false;
				this.cmbLugar.markInvalid();
				this.cmbLugar.modificado=true;

				this.cmbResponsable.allowBlank=true;
				this.cmbResponsable.clearInvalid();
				this.cmbResponsable.setValue('');
				this.cmbResponsable.modificado=true;

				this.cmbOficina.allowBlank=true;
				this.cmbOficina.setValue('');
				this.cmbOficina.setVisible(false);
				this.cmbOficina.modificado=true;

			} else {
				this.cmbLugar.setVisible(false);
				this.cmbLugar.allowBlank=true;
				this.cmbLugar.clearInvalid();
				this.cmbLugar.setValue('');

				this.cmbResponsable.allowBlank=false;
				this.cmbResponsable.markInvalid();
				this.cmbResponsable.modificado=true;

				this.cmbOficina.allowBlank=true;
				this.cmbOficina.setVisible(true);
				this.cmbOficina.modificado=true;
			}
		}, this);
	},
	definicionRutareporte: function(report){
		this.rutaReporte = '../../../sis_kactivos_fijos/vista/reportes/ReporteAsignados.php';
		this.claseReporte = 'ReporteAsignados';
		this.titleReporte = 'Reportes asignados - Inventario';
	},
	definirParametros: function(report){
		this.inicializarParametros();

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
		this.configElement(this.cmbOficina,true,false);
		this.configElement(this.cmbResponsable,true,true);
		this.configElement(this.cmbUnidSolic,false,true);
		this.configElement(this.cmbResponsableCompra,false,true);
		this.configElement(this.cmbLugar,true,false);
		this.configElement(this.radGroupTransito,false,true);
		this.configElement(this.radGroupTangible,false,true);
		this.configElement(this.cmbDepto,true,false);
		this.configElement(this.cmbDeposito,false,true);
		this.configElement(this.lblDesde,false,true);
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
		this.configElement(this.cmpFechaCompra,false,true);
		this.configElement(this.cmbTipo,true,false);

		this.configElement(this.fieldSetGeneral,true,true);
		this.configElement(this.fieldSetIncluir,false,true);
		this.configElement(this.fieldSetCompra,false,true);
	},
	onSubmit: function(){
		if(this.formParam.getForm().isValid()){
			/*if(this.cmbOficina.getValue()!=''){*/
				Phx.CP.loadingShow();
				//Generación del reporte
		        Ext.Ajax.request({
	                url: '../../sis_kactivos_fijos/control/Reportes/ReporteRespInventario',
	                params: {
	                	id_funcionario: this.cmbResponsable.getValue(),
	                	id_oficina: this.cmbOficina.getValue(),
	                	id_depto: this.cmbDepto.getValue(),
	                	nombre_oficina: this.repOficina,
	                	tipo: this.cmbTipo.getValue(),
	                	id_lugar: this.cmbLugar.getValue(),
	                	sort: 'afij.codigo',
	                	dir: 'ASC',
	                	limit: 5000,
	                	start: 0,
	                	tipo_salida: 'reporte'
	                },
	                success: this.successExport,
	                failure: this.conexionFailure,
	                timeout: this.timeout,
	                scope: this
	            });
			/*} else {
				Ext.MessageBox.alert('Información','Debe seleccionar los criterios obligatorios.');
			}*/
			
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
	},
	setPersonalBackgroundColor: function(elm){
    	//Para sobreescribir
    	var color='#FFF',
    		obligatorio='#ffffb3';

    	if(elm=='cmbTipo'||elm=='cmbDepto'||elm=='cmbLugar'){
    		color = obligatorio;
    	}
    	return color;
    }

}
</script>	