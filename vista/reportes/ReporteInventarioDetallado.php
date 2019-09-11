<?php
/**
*@package pXP
*@file ReporteInventarioDetallado.php
*@author RCM
*@date 12/08/2019
*@description Reporte Inventario Activos Fijos Detallado por Grupo Contable
/*
***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #24    KAF       ETR           12/08/2019  RCM         Creación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteInventarioDetallado = Ext.extend(Phx.gridInterfaz, {
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarInventarioDetallado',

	constructor: function(config){
		this.maestro = config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteInventarioDetallado.superclass.constructor.call(this, config);
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
			id_activo_fijo_multi: this.maestro.paramsRep.id_activo_fijo_multi
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
				name: 'nro_cuenta',
				fieldLabel: 'Cuenta',
				allowBlank: true,
				gwidth: 200
			},
			type:'TextField',
			filters:{pfiltro:'cue.nro_cuenta',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Código',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha',
				allowBlank: false,
				anchor: '80%',
				gwidth: 70,
				format: 'd/m/Y',
				renderer: function (value, p, record){
					return value ? value.dateFormat('d/m/Y') : ''
				}
			},
			type: 'DateField',
			filters: {pfiltro: 'afij.fecha_ini_dep', type: 'date'},
			id_grupo: 0,
			grid: false,
			form: true
		},
	    {
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación del Activo Fijo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 200,
			},
			type:'TextField',
			filters:{pfiltro:'afij.denominacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_actualiz',
				fieldLabel: 'Valor Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 125,
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
	    {
			config:{
				name: 'depreciacion_acum',
				fieldLabel: 'Dep. Acumulada',
				allowBlank: true,
				anchor: '80%',
				gwidth: 125
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'valor_actual',
				fieldLabel: 'Valor Neto',
				allowBlank: true,
				anchor: '80%',
				gwidth: 125
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'codigo_moneda',
				fieldLabel: 'Moneda',
				allowBlank: true,
				anchor: '80%',
				gwidth: 80,
			},
			type: 'TextField',
			filters: {pfiltro: 'mon.codigo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		}
	],
	tam_pag: 50,
	title: 'INVENTARIO DETALLADO DE ACTIVOS FIJOS POR GRUPO CONTABLE',
	ActList: '../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
        {name:'nro_cuenta', type: 'string'},
        {name:'codigo', type: 'string'},
        {name:'fecha_ini_dep', type: 'string'},
        {name:'denominacion', type: 'string'},
        {name:'monto_actualiz', type: 'numeric'},
        {name:'depreciacion_acum', type: 'numeric'},
        {name:'valor_actual', type: 'numeric'},
        {name:'codigo_moneda', type: 'string'},
        {name:'desc_moneda', type: 'string'}
	],
	sortInfo:{
		field: 'afij.codigo',
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
            url: '../../sis_kactivos_fijos/control/Reportes/ReporteInventarioDetalladoXls',
            params: {
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
				id_activo_fijo_multi: this.maestro.paramsRep.id_activo_fijo_multi
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
	}
})
</script>