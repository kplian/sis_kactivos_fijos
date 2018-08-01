<?php
/**
*@package pXP
*@file ReporteListadoAf.php
*@author RCM
*@date 16/10/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteListadoAf=Ext.extend(Phx.gridInterfaz,{
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listadoActivosFijos',

	constructor:function(config){
		this.maestro=config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteListadoAf.superclass.constructor.call(this,config);
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
			id_ubicacion: this.maestro.paramsRep.id_ubicacion
		};
		this.load();

		this.definirReporteCabecera();
	},

	Atributos:[
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
				name: 'codigo_ant', 
				fieldLabel: 'Código SAP',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo_ant',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'denominacion', 
				fieldLabel: 'Denominación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250
			},
			type:'TextField',
			filters:{pfiltro:'afij.denominacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_clasificacion', 
				fieldLabel: 'Clasificación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'cla.descripcion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_compra', 
				fieldLabel: 'Fecha Compra',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
			type:'TextField',
			filters:{pfiltro:'afij.fecha_compra',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_ini_dep', 
				fieldLabel: 'Inicio Deprec.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
			type:'TextField',
			filters:{pfiltro:'afij.fecha_ini_dep',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'vida_util_original', 
				fieldLabel: 'Vida Útil Orig.(meses)',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'afij.vida_util_original',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'cantidad_af', 
				fieldLabel: 'Cantidad',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'afihj.cantidad_af',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_unidad_medida', 
				fieldLabel: 'Unidad Medida',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'um.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'estado', 
				fieldLabel: 'Estado',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'af.estado',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_compra_orig', 
				fieldLabel: 'Monto Compra Orig.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'afij.monto_compra_orig',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'codigo_tcc', 
				fieldLabel: 'Centro Costo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'cc.codigo_tcc',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_funcionario2', 
				fieldLabel: 'Responsable',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250
			},
			type:'TextField',
			filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_asignacion', 
				fieldLabel: 'Fecha Asignación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
			type:'TextField',
			filters:{pfiltro:'afij.fecha_asignacion',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_ubicacion', 
				fieldLabel: 'Local',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120
			},
			type:'TextField',
			filters:{pfiltro:'ubi.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
	],
	tam_pag:50,	
	title:'INVENTARIO DETALLADO DE ACTIVOS FIJOS POR GRUPO CONTABLE',
	ActList:'../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
        {name:'codigo', type: 'string'},
		{name:'codigo_ant', type: 'string'},
		{name:'denominacion', type: 'string'},
		{name:'desc_clasificacion', type: 'string'},
		{name:'fecha_compra', type: 'date', dateFormat:'Y-m-d'},
		{name:'fecha_ini_dep', type: 'date', dateFormat:'Y-m-d'},
		{name:'vida_util_original', type: 'numeric'},
		{name:'cantidad_af', type: 'string'},
		{name:'desc_unidad_medida', type: 'string'},
		{name:'estado', type: 'string'},
		{name:'monto_compra_orig', type: 'string'},
		{name:'codigo_tcc', type: 'string'},
		{name:'desc_funcionario2', type: 'string'},
		{name:'fecha_asignacion', type: 'date', dateFormat:'Y-m-d'},
		{name:'desc_ubicacion', type: 'string'}
	],
	sortInfo:{
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
	}

})
</script>