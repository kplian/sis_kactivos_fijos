<?php
/**
*@package pXP
*@file ReporteGralAF.php
*@author  RCM
*@date 28/07/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteGralAF=Ext.extend(Phx.gridInterfaz,{

	constructor: function(config){
		this.maestro=config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteGralAF.superclass.constructor.call(this,config);
		this.init();
		this.load({
			params: {
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
				tipo_salida: 'grid'
			}
		});

		this.actualizarBaseParams();
		this.addButton('btnSelect', {
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
				name: 'codigo',
				fieldLabel: 'Código',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				gwidth: 160,
			},
			type:'DateField',
			filters:{pfiltro:'afij.denominacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'descripcion',
				fieldLabel: 'Descripción',
				gwidth: 210,
			},
			type:'DateField',
			filters:{pfiltro:'afij.descripcion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha Ini.Dep.',
				gwidth: 140,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'TextField',
			filters:{pfiltro:'afij.fecha_ini_dep',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_compra_orig_100',
				fieldLabel: 'Comp. 100%',
				gwidth: 150
			},
			type:'TextField',
			filters:{pfiltro:'afij.monto_compra_orig_100',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_compra_orig',
				fieldLabel: 'Comp. 87% ',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'afij.monto_compra_orig',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'valor_residual_gest_ant',
				fieldLabel: 'Valor Residual Gest.Ant.',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'afij.valor_residual_gest_ant',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_gest_actual',
				fieldLabel: 'Incorporaciones Gest.Act.',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'afij.inc_gest_actual',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'ajustes',
				fieldLabel: 'Ajustes (+ o -)',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.ajustes',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'bajas',
				fieldLabel: 'Bajas',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.bajas',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'transito',
				fieldLabel: 'Tránsito',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.transito',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_actualiz_acum',
				fieldLabel: 'Inc.Actualiz.Acum',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.inc_actualiz_acum',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_actualiz_per',
				fieldLabel: 'Inc.Actualiz.Periodo',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.inc_actualiz_per',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'val_actualiz',
				fieldLabel: 'Valor Actualiz.',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.val_actualiz',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'vida_usada',
				fieldLabel: 'Vida usada',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.vida_usada',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'vida_residual',
				fieldLabel: 'Vida residual',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.vida_residual',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'dep_acum_gest_ant',
				fieldLabel: 'Dep.Acum.Gest.Ant',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.dep_acum_gest_ant',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'act_dep_gest_ant',
				fieldLabel: 'Act.Dep.Gest.Ant.',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.act_dep_gest_ant',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'dep_gestion',
				fieldLabel: 'Depreciación Gestión',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.dep_gestion',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'dep_periodo',
				fieldLabel: 'Dep.Periodo',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.dep_periodo',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'dep_acum',
				fieldLabel: 'Dep.Acum.',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.dep_acum',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'valor_residual',
				fieldLabel: 'Valor residual',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.valor_residual',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'impuestos',
				fieldLabel: 'Impuestos',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.impuestps',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},{
			config:{
				name: 'ubicacion',
				fieldLabel: 'Ubicación Física',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'afij.ubicacion',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		}, {
			config:{
				name: 'responsable',
				fieldLabel: 'Responsable',
				gwidth: 150
			},
			type:'TextField',
			filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		}
	],
	tam_pag:50,	
	title:'Reportes Activos Fijos',
	ActList:'../../sis_kactivos_fijos/control/Reportes/reporteGralAF',
	fields: [
		{name:'codigo',type: 'string'},
		{name:'denominacion',type: 'string'},
		{name:'descripcion',type: 'string'},
		{name:'fecha_compra',type: 'date',dateFormat: 'Y-m-d'},
		{name:'fecha_ini_dep',type: 'date',dateFormat: 'Y-m-d'},
		{name:'monto_compra_orig_100',type: 'numeric'},
		{name:'monto_compra_orig',type: 'numeric'},
		{name:'responsable',type: 'string'},


		{name:'estado',type: 'string'},
		{name:'vida_util_original',type: 'numeric'},
		{name:'porcentaje_dep',type: 'numeric'},
		{name:'ubicacion',type: 'string'},
		{name:'monto_compra_orig',type: 'numeric'},
		{name:'moneda',type: 'string'},
		{name:'nro_cbte_asociado',type: 'string'},
		{name:'fecha_cbte_asociado',type: 'date',dateFormat: 'Y-m-d'},
		
		{name:'valor_actual',type: 'numeric'},
		{name:'vida_util_residual',type: 'numeric'},
		{name:'cod_clasif',type: 'string'},
		{name:'desc_clasif',type: 'string'},
		{name:'metodo_dep',type: 'string'},
		{name:'ufv_fecha_compra',type: 'numeric'},
		
		{name:'cargo',type: 'string'},
		{name:'fecha_mov',type: 'date',dateFormat: 'Y-m-d'},
		{name:'num_tramite',type: 'string'},
		{name:'desc_mov',type: 'string'}
	],
	sortInfo:{
		field: 'codigo',
		direction: 'ASC'
	},
	bdel: false,
	bsave: false,
	bnew: false,
	bedit: false,
	imprimirReporte: function(){
	    Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Reportes/reporteGralAF',
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
				tipo_salida: 'reporte'
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        }); 
	},
	actualizarBaseParams: function(){
		this.store.setBaseParam('start', 0);
        this.store.setBaseParam('limit', this.tam_pag);
        this.store.setBaseParam('fecha_ini', this.maestro.fecha_ini);
        this.store.setBaseParam('fecha_fin',this.maestro.fecha_fin);
        this.store.setBaseParam('ids',this.maestro.ids);
        this.store.setBaseParam('velocidad_ini', this.maestro.velocidad_ini);
        this.store.setBaseParam('velocidad_fin', this.maestro.velocidad_fin);

        this.store.setBaseParam('start', 0);
		this.store.setBaseParam('limit', this.tam_pag);
		this.store.setBaseParam('titulo_reporte', this.maestro.paramsRep.titleReporte);
		this.store.setBaseParam('reporte', this.maestro.paramsRep.reporte);
		this.store.setBaseParam('fecha_desde', this.maestro.paramsRep.fecha_desde);
		this.store.setBaseParam('fecha_hasta', this.maestro.paramsRep.fecha_hasta);
		this.store.setBaseParam('id_activo_fijo', this.maestro.paramsRep.id_activo_fijo);
		this.store.setBaseParam('id_clasificacion', this.maestro.paramsRep.id_clasificacion);
		this.store.setBaseParam('denominacion', this.maestro.paramsRep.denominacion);
		this.store.setBaseParam('fecha_compra', this.maestro.paramsRep.fecha_compra);
		this.store.setBaseParam('fecha_ini_dep', this.maestro.paramsRep.fecha_ini_dep);
		this.store.setBaseParam('estado', this.maestro.paramsRep.estado);
		this.store.setBaseParam('id_centro_costo', this.maestro.paramsRep.id_centro_costo);
		this.store.setBaseParam('ubicacion', this.maestro.paramsRep.ubicacion);
		this.store.setBaseParam('id_oficina', this.maestro.paramsRep.id_oficina);
		this.store.setBaseParam('id_funcionario', this.maestro.paramsRep.id_funcionario);
		this.store.setBaseParam('id_uo', this.maestro.paramsRep.id_uo);
		this.store.setBaseParam('id_funcionario_compra', this.maestro.paramsRep.id_funcionario_compra);
		this.store.setBaseParam('id_lugar', this.maestro.paramsRep.id_lugar);
		this.store.setBaseParam('af_transito', this.maestro.paramsRep.af_transito);
		this.store.setBaseParam('af_tangible', this.maestro.paramsRep.af_tangible);
		this.store.setBaseParam('af_estado_mov', this.maestro.paramsRep.af_estado_mov);
		this.store.setBaseParam('id_depto', this.maestro.paramsRep.id_depto);
		this.store.setBaseParam('id_deposito', this.maestro.paramsRep.id_deposito);
		this.store.setBaseParam('id_moneda', this.maestro.paramsRep.id_moneda);
		this.store.setBaseParam('desc_moneda', this.maestro.paramsRep.desc_moneda);
		this.store.setBaseParam('tipo_salida', 'grid');

	}
})
</script>
		
		