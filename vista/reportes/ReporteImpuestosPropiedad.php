<?php
/**
*@package pXP
*@file ReporteImpuestosPropiedad.php
*@author RCM
*@date 13/08/2019
*@description Reporte en grilla de Impuestos Propiedad e Inmuebles

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #17    KAF       ETR           13/08/2019  RCM         Creación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteImpuestosPropiedad = Ext.extend(Phx.gridInterfaz, {
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarImpuestosPropiedad',

	constructor: function(config){
		this.maestro = config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteImpuestosPropiedad.superclass.constructor.call(this, config);
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
			id_ubicacion: this.maestro.paramsRep.id_ubicacion
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
				name: 'ubicacion',
				fieldLabel: 'Ubicación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 160
			},
			type: 'TextField',
			filters: {pfiltro: 'ubicacion', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'clasificacion',
				fieldLabel: 'Clasificación',
				allowBlank: true,
				gwidth: 230
			},
			type: 'TextField',
			filters: {pfiltro:'clasificacion', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
	    {
			config:{
				name: 'valor_actualiz_gest_ant',
				fieldLabel: 'Valor Actualiz Gestión Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'deprec_acum_gest_ant',
				fieldLabel: 'Depreciación Acum. Gestión Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'valor_actualiz',
				fieldLabel: 'Valor Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'deprec_sin_actualiz',
				fieldLabel: 'Depreciación Sin Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
	    {
			config:{
				name: 'deprec_acum',
				fieldLabel: 'Depreciación Acumulada',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
	    {
			config:{
				name: 'valor_neto',
				fieldLabel: 'Valor Neto',
				allowBlank: true,
				anchor: '80%',
				gwidth: 130
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		}
	],
	tam_pag:50,
	title:'IMPUESTOS A LA PROPIEDAD E INMUEBLES',
	ActList:'../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
		{name:'orden', type: 'numeric'},
		{name:'ubicacion', type: 'string'},
		{name:'clasificacion', type: 'string'},
		{name:'moneda', type: 'string'},
		{name:'valor_actualiz_gest_ant', type: 'numeric'},
		{name:'deprec_acum_gest_ant', type: 'numeric'},
		{name:'valor_actualiz', type: 'numeric'},
		{name:'deprec_sin_actualiz', type: 'numeric'},
		{name:'deprec_acum', type: 'numeric'},
		{name:'valor_neto', type: 'numeric'}
	],
	sortInfo:{
		field: 'orden',
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
            url:'../../sis_kactivos_fijos/control/Reportes/ReporteImpuestosPropiedadXls',
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
				id_ubicacion: this.maestro.paramsRep.id_ubicacion
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });
	}
})
</script>