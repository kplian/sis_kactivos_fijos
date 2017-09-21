<?php
/**
*@package pXP
*@file MovimientoDepRep.php
*@author  RCM
*@date 10/05/2016
*@description Reporte resumen de depreciacion
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoDepRep = Ext.extend(Phx.gridInterfaz, {

	constructor: function(config){
		Phx.vista.MovimientoDepRep.superclass.constructor.call(this,config);
		this.init();
		this.load({params:{start:0, limit:this.tam_pag}})
	}

	Atributos:[
		{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_af_dep'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Codigo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				disabled: true
			},
			type:'TextField',
			filters:{pfiltro:'af.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,
			bottom_filter:true
		},
		{
			config:{
				name: 'clasificacion',
				fieldLabel: 'Clasificacion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250,
				disabled: true
			},
			type:'TextField',
			filters:{pfiltro:'af.descripcion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,
			bottom_filter:true
		},
		{
			config:{
				name: 'descripcion',
				fieldLabel: 'Descripcion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250,
				disabled: true
			},
			type:'TextField',
			filters:{pfiltro:'af.descripcion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,
			bottom_filter:true
		},
		{
			config:{
				name: 'fecha_inc',
				fieldLabel: 'Fecha Incorporacion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'af.fecha_ini_dep',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_vigente_orig',
				fieldLabel: 'Monto Compra',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.monto_vigente_orig',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_actualiz',
				fieldLabel: 'Inc.Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.inc_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'valor_actualiz',
				fieldLabel: 'Valor Actualizado',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.valor_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'vida_util',
				fieldLabel: 'Vida Util',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.vida_util',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'vida_util_restante',
				fieldLabel: 'Vida Util Restante',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.vida_util_restante',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'dep_acum_gest_ant',
				fieldLabel: 'Dep.Acum. Gestion Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.monto_vigente_orig',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'dep_gest_ant_act',
				fieldLabel: 'Act.Deprec. Gestion Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.dep_gest_ant_act',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'dep_gestion',
				fieldLabel: 'Depreciacion Gestion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.dep_gestion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'dep_acum',
				fieldLabel: 'Depreciacion Acum.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.depreciacion_acum',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_vigente',
				fieldLabel: 'Valor Residual',
				allowBlank: true,
				anchor: '80%',
				gwidth: 140,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.00');}
			},
			type:'NumberField',
			filters:{pfiltro:'mafdep.monto_vigente',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},

	],

	tam_pag:500,	
	title:'Depreciacion Activos Fijos',
	ActList:'../../sis_kactivos_fijos/control/Movimiento/listarMovimientoDepRes',
	id_store:'id_movimiento_af_dep',
	fields: [
		{name:'id_movimiento_af_dep', type: 'numeric'},
		{name:'codigo', type: 'string'},
		{name:'clasificacion', type: 'string'},
		{name:'descripcion', type: 'string'},
		{name:'fecha_inc', type: 'date', dateFormat:'Y-m-d'},
		{name:'monto_vigente_orig', type: 'numeric'},
		{name:'inc_actualiz', type: 'numeric'},
		{name:'valor_actualiz', type: 'numeric'},
		{name:'vida_util', type: 'numeric'},
		{name:'vida_util_restante', type: 'numeric'},
		{name:'dep_acum_gest_ant', type: 'numeric'},
		{name:'dep_gest_ant_act', type: 'numeric'},
		{name:'dep_gestion', type: 'numeric'},
		{name:'dep_acum', type: 'numeric'},
		{name:'monto_vigente', type: 'numeric'}
	],
	sortInfo:{
		field: 'codigo',
		direction: 'ASC'
	},
	bdel: false,
	bsave: false,
	bedit: false,
	bnew: false

});