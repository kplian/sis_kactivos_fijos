<?php
/**
*@package pXP
*@file ReporteAltaOrigen.php
*@author RCM
*@date 22/08/2019
*@description Reporte en grilla de Origen de Altas

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #26    KAF       ETR           22/08/2019  RCM         Creación
 #29    KAF       ETR           20/09/2019  RCM         Corrección reportes
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteAltaOrigen = Ext.extend(Phx.gridInterfaz, {
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarAltaOrigen',

	constructor: function(config) {
		this.maestro = config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteAltaOrigen.superclass.constructor.call(this, config);
		this.init();
		this.store.baseParams = {
			start: 0,
			limit: this.tam_pag,
			titulo_reporte: this.maestro.paramsRep.titleReporte,
			reporte: this.maestro.paramsRep.reporte,
			fecha_desde: this.maestro.paramsRep.fecha_desde,
			fecha_hasta: this.maestro.paramsRep.fecha_hasta,
			id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
			id_clasificacion: this.maestro.paramsRep.id_clasificacion,
			denominacion: this.maestro.paramsRep.denominacion,
			fecha_compra: this.maestro.paramsRep.fecha_compra,
			fecha_ini_dep: this.maestro.paramsRep.fecha_ini_dep,
			estado: this.maestro.paramsRep.estado,
			id_centro_costo: this.maestro.paramsRep.id_centro_costo,
			ubicacion: this.maestro.paramsRep.ubicacion,
			id_oficina: this.maestro.paramsRep.id_oficina,
			id_funcionario: this.maestro.paramsRep.id_funcionario,
			id_uo: this.maestro.paramsRep.id_uo,
			id_funcionario_compra: this.maestro.paramsRep.id_funcionario_compra,
			id_lugar: this.maestro.paramsRep.id_lugar,
			af_transito: this.maestro.paramsRep.af_transito,
			af_tangible: this.maestro.paramsRep.af_tangible,
			af_estado_mov: this.maestro.paramsRep.af_estado_mov,
			id_depto: this.maestro.paramsRep.id_depto,
			id_deposito: this.maestro.paramsRep.id_deposito,
			id_moneda: this.maestro.paramsRep.id_moneda,
			desc_moneda: this.maestro.paramsRep.desc_moneda,
			tipo_salida: 'grid',
			rep_metodo_list: this.metodoList,
			monto_inf: this.maestro.paramsRep.monto_inf,
			monto_sup: this.maestro.paramsRep.monto_sup,
			fecha_compra_max: this.maestro.paramsRep.fecha_compra_max,
			gestion: this.maestro.paramsRep.gestion,
			id_activo_fijo_multi: this.maestro.paramsRep.id_activo_fijo_multi,
			id_ubicacion: this.maestro.paramsRep.id_ubicacion,
			tipo_activacion: this.maestro.paramsRep.tipo_activacion,
			nro_tramite: this.maestro.paramsRep.nro_tramite
		};

		this.load();

		this.definirReporteCabecera();

		this.addButton('btnReporte', {
            text: 'Reporte',
            iconCls: 'bpdf32',
            disabled: false,
            handler: this.imprimirReporte,
            tooltip: '<b>Imprimir reporte</b><br/>Genera el reporte en el formato para impresión.'
         });
	},

	Atributos:[
		{
			config:{
				name: 'tipo',
				fieldLabel: 'Tipo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 160
			},
			type: 'TextField',
			filters: {pfiltro: 'tipo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Código',
				allowBlank: true,
				anchor: '80%',
				gwidth: 160
			},
			type: 'TextField',
			filters: {pfiltro: 'codigo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				allowBlank: true,
				gwidth: 230
			},
			type: 'TextField',
			filters: {pfiltro:'denominacion', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: true,
				gwidth: 80
			},
			type: 'TextField',
			filters: {pfiltro: 'estado', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha Ini. Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type: 'TextField',
			filters: {pfiltro: 'fecha_ini_dep', type: 'date'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'monto_activo',
				fieldLabel: 'Valor Actualiz.',
				allowBlank: true,
				gwidth: 130
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		//Inicio #29:se quita columna dep_acum_inici
		/*{
			config:{
				name: 'dep_acum_inicial',
				fieldLabel: 'Dep. Acum. Inicial',
				allowBlank: true,
				gwidth: 130
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},*/
		//Fin #29
		{
			config:{
				name: 'vida_util_orig',
				fieldLabel: 'Vida útil Original (Meses)',
				allowBlank: true,
				gwidth: 130
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'nro_tramite',
				fieldLabel: 'Nro.Trámite',
				allowBlank: true,
				gwidth: 130
			},
			type: 'TextField',
			filters: {pfiltro:'nro_tramite', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
	    {
			config:{
				name: 'descripcion',
				fieldLabel: 'Descripción',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		}
	],
	tam_pag: 50,
	title: 'IMPUESTOS DE VEHÍCULOS',
	ActList: '../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
		{name: 'tipo', type: 'string'},
		{name: 'codigo', type: 'string'},
		{name: 'denominacion', type: 'string'},
		{name: 'estado', type: 'string'},
		{name: 'fecha_ini_dep', type: 'date', dateFormat: 'Y-m-d'},
		{name: 'monto_activo', type: 'numeric'},
		//{name: 'dep_acum_inicial', type: 'numeric'},//#29 se quita columna dep_acum_inici
		{name: 'vida_util_orig', type: 'numeric'},
		{name: 'nro_tramite', type: 'string'},
		{name: 'descripcion', type: 'string'},
		{name: 'id_moneda', type: 'numeric'},
		{name: 'id_estado_wf', type: 'numeric'},
		{name: 'identificador', type: 'numeric'},
		{name: 'tabla', type: 'string'}
	],
	sortInfo: {
		field: 'codigo',
		direction: 'ASC'
	},
	title2: '',
	desplegarMaestro: 'si',
	repFilaInicioEtiquetas: 25,
	repFilaInicioDatos: 20,
	pdfOrientacion: 'L',

	definirReporteCabecera: function(){
		this.colMaestro= [{
			label: 'Moneda',
			value: this.maestro.paramsRep.desc_moneda
		}]
	},

	imprimirReporte: function(){
	    Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Reportes/ReporteAltaOrigenXls',
            params:{
            	titulo_reporte: this.maestro.paramsRep.titleReporte,
				reporte: this.maestro.paramsRep.reporte,
				fecha_desde: this.maestro.paramsRep.fecha_desde,
				fecha_hasta: this.maestro.paramsRep.fecha_hasta,
				id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
				id_clasificacion: this.maestro.paramsRep.id_clasificacion,
				denominacion: this.maestro.paramsRep.denominacion,
				fecha_compra: this.maestro.paramsRep.fecha_compra,
				fecha_ini_dep: this.maestro.paramsRep.fecha_ini_dep,
				estado: this.maestro.paramsRep.estado,
				id_centro_costo: this.maestro.paramsRep.id_centro_costo,
				ubicacion: this.maestro.paramsRep.ubicacion,
				id_oficina: this.maestro.paramsRep.id_oficina,
				id_funcionario: this.maestro.paramsRep.id_funcionario,
				id_uo: this.maestro.paramsRep.id_uo,
				id_funcionario_compra: this.maestro.paramsRep.id_funcionario_compra,
				id_lugar: this.maestro.paramsRep.id_lugar,
				af_transito: this.maestro.paramsRep.af_transito,
				af_tangible: this.maestro.paramsRep.af_tangible,
				af_estado_mov: this.maestro.paramsRep.af_estado_mov,
				id_depto: this.maestro.paramsRep.id_depto,
				id_deposito: this.maestro.paramsRep.id_deposito,
				id_moneda: this.maestro.paramsRep.id_moneda,
				desc_moneda: this.maestro.paramsRep.desc_moneda,
				tipo_salida: 'grid',
				rep_metodo_list: this.metodoList,
				monto_inf: this.maestro.paramsRep.monto_inf,
				monto_sup: this.maestro.paramsRep.monto_sup,
				fecha_compra_max: this.maestro.paramsRep.fecha_compra_max,
				af_deprec: this.maestro.paramsRep.af_deprec,
				nro_cbte_asociado: this.maestro.paramsRep.nro_cbte_asociado,
				gestion: this.maestro.paramsRep.gestion,
				id_activo_fijo_multi: this.maestro.paramsRep.id_activo_fijo_multi,
				id_ubicacion: this.maestro.paramsRep.id_ubicacion,
				tipo_activacion: this.maestro.paramsRep.tipo_activacion,
				nro_tramite: this.maestro.paramsRep.nro_tramite
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
	}
})
</script>