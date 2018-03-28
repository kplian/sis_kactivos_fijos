<?php
/**
*@package pXP
*@file ReporteDetalleDep.php
*@author RCM
*@date 16/10/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteDetalleDep=Ext.extend(Phx.gridInterfaz,{
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarRepDetalleDep',

	constructor:function(config){
		this.maestro=config;
		console.log('data',this.maestro);
    	//llama al constructor de la clase padre
		Phx.vista.ReporteDetalleDep.superclass.constructor.call(this,config);
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
			fecha_compra_max: this.maestro.paramsRep.fecha_compra_max
		};
		this.load();

		this.definirReporteCabecera();
	},

	Atributos:[
		{
			config:{
				name: 'desc_moneda', 
				fieldLabel: 'Moneda',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'gestion_final', 
				fieldLabel: 'Gestión',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'tipo', 
				fieldLabel: 'Tipo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'nombre_raiz', 
				fieldLabel: 'Clasificación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
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
				fieldLabel: 'Fecha Ini.Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
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
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'descripcion', 
				fieldLabel: 'Denominación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_vigente_orig', 
				fieldLabel: 'Monto Vigente Orig.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_vigente_inicial', 
				fieldLabel: 'Monto vigente Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_vigente_final', 
				fieldLabel: 'Monto VIgente Final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_actualiz_inicial', 
				fieldLabel: 'Monto Actualiz.Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'monto_actualiz_final', 
				fieldLabel: 'Monto Actualiza final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'depreciacion_acum_inicial', 
				fieldLabel: 'Dep.Acum.Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'depreciacion_acum_final', 
				fieldLabel: 'Dep.Acum.Final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'aitb_activo', 
				fieldLabel: 'AITB',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'aitb_depreciacion_acumulada', 
				fieldLabel: 'AITB Dep.Acum.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'vida_util_orig', 
				fieldLabel: 'Vida Útil Orig.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'vida_util_inicial', 
				fieldLabel: 'Vida Útil Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'vida_util_final', 
				fieldLabel: 'Vida Útil Final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'vida_util_trans', 
				fieldLabel: 'Vida Útil Trans.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'codigo_raiz', 
				fieldLabel: 'Código Clasif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion_per_final', 
				fieldLabel: 'Dep.Per.Final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	    {
			config:{
				name: 'depreciacion_per_actualiz_final', 
				fieldLabel: 'Dep.Per.Actualiz.Final',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		}
	],
	tam_pag:50,	
	title:'Reporte',
	ActList:'../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
        {name:'id_moneda_dep', type: 'numeric'},
		{name:'desc_moneda', type: 'string'},
		{name:'gestion_final', type: 'numeric'},
        {name:'tipo', type: 'string'},
        {name:'nombre_raiz', type: 'string'},
        {name:'fecha_ini_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'id_movimiento', type: 'numeric'},
        {name:'id_movimiento_af', type: 'numeric'},
        {name:'id_activo_fijo_valor', type: 'numeric'},
        {name:'id_activo_fijo', type: 'numeric'},
        {name:'codigo', type: 'string'},
        {name:'id_clasificacion', type: 'numeric'},
        {name:'descripcion', type: 'string'},
        {name:'monto_vigente_orig', type: 'numeric'},
        {name:'monto_vigente_inicial', type: 'numeric'},
        {name:'monto_vigente_final', type: 'numeric'},
        {name:'monto_actualiz_inicial', type: 'numeric'},
        {name:'monto_actualiz_final', type: 'numeric'},
        {name:'depreciacion_acum_inicial', type: 'numeric'},
        {name:'depreciacion_acum_final', type: 'numeric'},
        {name:'aitb_activo', type: 'numeric'},
        {name:'aitb_depreciacion_acumulada', type: 'numeric'},
        {name:'vida_util_orig', type: 'numeric'},
        {name:'vida_util_inicial', type: 'numeric'},
        {name:'vida_util_final', type: 'numeric'},
        {name:'vida_util_trans', type: 'numeric'},
        {name:'codigo_raiz', type: 'string'},
        {name:'id_clasificacion_raiz', type: 'numeric'},
		{name:'depreciacion_per_final', type: 'numeric'},
        {name:'depreciacion_per_actualiz_final', type: 'numeric'}
	],
	sortInfo:{
		field: 'codigo',
		direction: 'ASC'
	},
	title2: 'DETALLE DEPRECIACIÓN',
	desplegarMaestro: 'si',
	repFilaInicioEtiquetas: 45,
	repFilaInicioDatos: 3,
	pdfOrientacion: 'L',
	definirReporteCabecera: function(){
		this.colMaestro= [{
			label: 'RESPONSABLE',
			value: this.maestro.paramsRep.repResponsable
		}, {
			label: 'OFICINA',
			value: this.maestro.paramsRep.repOficina
		}, {
			label: 'CARGO',
			value: this.maestro.paramsRep.repCargo
		}, {
			label: 'DEPTO.',
			value: this.maestro.paramsRep.repDepto
		}]
	}
})
</script>