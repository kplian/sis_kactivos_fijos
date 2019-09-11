<?php
/**
*@package pXP
*@file ReporteAfDistValores.php
*@author RCM
*@date 22/07/2019
*@description Reporte de los activos fijos que tuvieron una Distribución de Valores
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteAfDistValores = Ext.extend(Phx.gridInterfaz, {

	fheight: '90%',
	fwidth: '90%',
	nombreVista: 'ReporteAfDistValores',
	idMonedaMovEsp: 0,
	codigoMoneda: 0,
	descMoneda: '',

	constructor: function(config) {
		this.maestro = config.maestro;
		this.initButtons = [this.cmbMoneda];
    	//llama al constructor de la clase padre
		Phx.vista.ReporteAfDistValores.superclass.constructor.call(this, config);
		this.init();

		this.addButton('btnDocCmpVnt', {
			text: 'Reporte',
			iconCls: 'brenew',
			disabled: false,
			handler: this.generarReporte,
			tooltip: '<b>Documentos de compra/venta</b><br/>Muestras los docuemntos relacionados con el comprobante'
		});

		this.bloquearOrdenamientoGrid();

		this.cmbMoneda.on('clearcmb', function() {
			this.DisableSelect();
			this.store.removeAll();
		}, this);

		this.cmbMoneda.on('valid', function() {
			this.capturaFiltros();
		}, this);

		this.cargarMonedaMovEspecial();
	},

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_af'
			},
			type:'Field',
			form:true
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo'
			},
			type:'Field',
			form:true
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				name: 'fecha_mov',
				fieldLabel: 'Fecha',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record){ return value?value.dateFormat('d/m/Y'):'' }
			},
			type: 'DateField',
			filters: {pfiltro:'mov.fecha_mov',type:'date'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Codigo AF',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 15
			},
			type: 'TextField',
			filters: {pfiltro: 'af.codigo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true,
			bottom_filter: true
		},
		{
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 250,
				maxLength:50
			},
			type:'TextField',
			filters:{pfiltro:'af.denominacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,bottom_filter: true
		},
		{
			config:{
				name: 'num_tramite',
				fieldLabel: 'Nro.Trámite',
				allowBlank: false,
				anchor: '80%',
				gwidth: 180,
				maxLength: 50
			},
			type: 'TextField',
			filters: {pfiltro: 'mov.num_tramite', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true,
			bottom_filter: true
		},
		{
			config:{
				name: 'monto_actualiz',
				fieldLabel: 'Valor Actualiz.',
				allowBlank: false,
				anchor: '80%',
				gwidth: 180,
				maxLength: 50
			},
			type:'TextField',
			filters: {pfiltro:'mdep1.monto_actualiz', type: 'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'depreciacion_acum',
				fieldLabel: 'Depreciación Acum.',
				allowBlank: false,
				anchor: '80%',
				gwidth: 180,
				maxLength: 50
			},
			type: 'TextField',
			filters: {pfiltro: 'mdep1.depreciacion_acum', type:'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
	],
	tam_pag:50,
	title:'Activos Fijos - Distribución de Valores',
	ActList:'../../sis_kactivos_fijos/control/Reportes/reporteAfDistValores',
	id_store:'id_movimiento_af',
	fields: [
		{name:'id_movimiento_af', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_movimiento', type: 'numeric'},
		{name:'id_moneda', type: 'numeric'},
		{name:'id_movimiento_af_dep', type: 'numeric'},
		{name:'codigo', type: 'string'},
		{name:'denominacion', type: 'string'},
		{name:'num_tramite', type: 'string'},
		{name:'fecha_mov', type: 'date', dateFormat: 'Y-m-d'},
		{name:'estado', type: 'string'},
		{name:'monto_actualiz', type: 'numeric'},
		{name:'depreciacion_acum', type: 'numeric'}
	],
	sortInfo: {
		field: 'mov.fecha_mov',
		direction: 'DESC'
	},
	bdel: false,
	bsave: false,
	bnew: false,
	bedit: false,

	cmbMoneda: new Ext.form.ComboBox({
		name: 'id_moneda',
		fieldLabel: 'Moneda',
		allowBlank: false,
		blankText: '... ?',
		emptyText: 'Moneda...',
		forceSelection: true,
		store: new Ext.data.JsonStore({
			url: '../../sis_kactivos_fijos/control/MonedaDep/listarMonedaDep',
			id: 'id_moneda',
			root: 'datos',
			sortInfo: {
				field: 'descripcion',
				direction: 'DESC'
			},
			totalProperty: 'total',
			fields: ['id_moneda_dep', 'descripcion', 'id_moneda', 'actualiza'],
			remoteSort: true,
			baseParams: {par_filtro: 'descripcion'}
		}),
		valueField: 'id_moneda',
		triggerAction: 'all',
		displayField: 'descripcion',
	    hiddenName: 'id_moneda',
		mode: 'remote',
		pageSize: 50,
		queryDelay: 500,
		listWidth: '280',
		width: 80
	}),

	generarReporte: function() {
		Phx.CP.loadingShow();
        Ext.Ajax.request({
            url: '../../sis_kactivos_fijos/control/Reportes/ReporteAfDistValoresXls',
            params: {
				id_moneda: this.cmbMoneda.getValue(),
				desc_moneda: this.descMoneda
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
	},

	capturaFiltros: function(combo, record, index) {
		this.desbloquearOrdenamientoGrid();
		var index = this.cmbMoneda.store.find('descripcion', this.cmbMoneda.getValue());

		if(index!=-1){
	        var id_moneda = this.cmbMoneda.store.getAt(index).data.id_moneda;
	        this.descMoneda = this.cmbMoneda.store.getAt(index).data.descripcion;
			this.store.baseParams.id_moneda = id_moneda;
			this.load();
		}
		this.grid.focus();
	},

	south: {
		url: '../../../sis_kactivos_fijos/vista/reportes/ReporteAfDistValoresDet.php',
		title: 'Detalle',
		height: '30%',
		cls: 'ReporteAfDistValoresDet'
	},

	cargarMonedaMovEspecial: function() {
    	//Obtención de la moneda base
       	Ext.Ajax.request({
	        url: '../../sis_kactivos_fijos/control/MovimientoAf/obtenerMonedaMovEsp',
	        params: { moneda: 'si' },
	        success: function(res, params) {
	        	var response = Ext.decode(res.responseText).ROOT;
	        	this.idMonedaMovEsp = response.datos.id_moneda;
	        	this.codigoMoneda = response.datos.codigo;

	        	//Carga de la moneda UFV
	        	this.cmbMoneda.store.load({params: {start: 0, limit: this.tam_pag},
		            callback: function (data) {
		                if (data.length > 0 ) {
		                	this.cmbMoneda.store.each(function(rec) {
		                		if(rec.data.descripcion == this.codigoMoneda) {
									this.cmbMoneda.setValue(rec.data.id_moneda);
		                		}
		                	}, this)
		                    this.capturaFiltros();
		                }
		            }, scope: this
		        });
	        },
	        argument: this.argumentSave,
	        failure: this.conexionFailure,
	        timeout: this.timeout,
	        scope: this
	    });
    }

})
</script>

