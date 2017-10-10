<?php
/**
*@package pXP
*@file ReporteAsignados.php
*@author  RCM
*@date 06/10/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteAsignados=Ext.extend(Phx.gridInterfaz,{
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarRepAsignados',

	constructor:function(config){
		this.maestro=config;
		console.log('data',this.maestro);
    	//llama al constructor de la clase padre
		Phx.vista.ReporteAsignados.superclass.constructor.call(this,config);
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

		this.definiirReporteCabecera();
	},

	Atributos:[
		{
			config:{
				name: 'codigo', 
				fieldLabel: 'Código',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:15
			},
				type:'TextField',
				filters:{pfiltro:'afij.codigo',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'desc_clasificacion',
				fieldLabel: 'Clasificación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'cla.nombre',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'afij.denominacion',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'afij.estado',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'observaciones',
				fieldLabel: 'Observaciones',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'afij.observaciones',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'ubicacion',
				fieldLabel: 'Ubicación',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'afij.ubicacion',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'fecha_asignacion',
				fieldLabel: 'Fecha asignación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y', 
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'afij.fecha_asignacion',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'desc_oficina',
				fieldLabel: 'Oficina',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'ofi.nombre',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'responsable',
				fieldLabel: 'Responsable',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		}
	],
	tam_pag:50,	
	title:'Reporte',
	ActList:'../../sis_kactivos_fijos/control/Reportes/ReporteGralAF',
	fields: [
		{name:'codigo', type: 'string'},
        {name:'desc_clasificacion', type: 'string'},
        {name:'denominacion', type: 'string'},
        {name:'descripcion', type: 'string'},
        {name:'estado', type: 'string'},
        {name:'observaciones', type: 'string'},
        {name:'ubicacion', type: 'string'},
        {name:'fecha_asignacion', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
        {name:'desc_oficina', type: 'string'},
        {name:'responsable', type: 'string'}
	],
	sortInfo:{
		field: 'codigo',
		direction: 'ASC'
	},
	title2: 'DETALLE DE ACTIVOS FIJOS  POR RESPONSABLE',
	desplegarMaestro: 'si',
	repFilaInicioEtiquetas: 45,
	repFilaInicioDatos: 3,
	pdfOrientacion: 'L',
	definiirReporteCabecera: function(){
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