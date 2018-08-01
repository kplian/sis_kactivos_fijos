<?php
/**
*@package pXP
*@file gen-MovimientoAfDep.php
*@author  (admin)
*@date 16-04-2016 08:14:17
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoAfDep=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){		
		this.maestro=config;
    	//llama al constructor de la clase padre
		Phx.vista.MovimientoAfDep.superclass.constructor.call(this,config);
		this.init();
		
		
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_af_dep'
			},
			type:'Field',
			form:true 
		},
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
					name: 'id_activo_fijo_valor'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'fecha',
				fieldLabel: 'Fecha',
				gwidth: 70,
				maxLength:10,
				renderer: function (value,p,record){return value?value.dateFormat('m/Y'):''}
			},
			type:'TextField',
			filters:{pfiltro:'res.fecha',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'tipo_cambio_ini',
				fieldLabel: 'T/C Ini.',
				gwidth: 80,
				maxLength:10,
				//renderer: function(value,p,record){return Ext.util.Format.number(value,'0,000.00');}
			},
			type:'TextField',
			filters:{pfiltro:'res.tipo_cambio_ini',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'tipo_cambio_fin',
				fieldLabel: 'T/C Fin',
				gwidth: 80,
				maxLength:10,
				//renderer: function(value,p,record){return Ext.util.Format.number(value,'0,000.00');}
			},
			type:'TextField',
			filters:{pfiltro:'res.tipo_cambio_fin',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'factor',
				fieldLabel: 'Factor',
				gwidth: 70,
				maxLength:10,
				renderer: function(value,p,record){return Ext.util.Format.number(value,'0.000000');}
			},
			type:'TextField',
			filters:{pfiltro:'res.factor',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'monto_actualiz_ant',
				fieldLabel: 'Valor Vigente Actualiz.',//'Monto Vigente Ant.',
				gwidth: 140,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.monto_actualiz_ant',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'inc_monto_actualiz',
				fieldLabel: 'Inc.Actualiz',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.inc_monto_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'monto_actualiz',
				fieldLabel: 'Valor Actualiz.',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.monto_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'vida_util_ant',
				fieldLabel: 'Vida Util Ant.',
				gwidth: 85,
				maxLength:10
			},
			type:'TextField',
			filters:{pfiltro:'res.vida_util_ant',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_acum_ant',
				fieldLabel: 'Dep.Acum.Ant',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_acum_ant',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_per_ant',
				fieldLabel: 'Dep.Periodo Ant.',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_per_ant',type:'string'},
			id_grupo:1,
			grid:false,
			form:false
		},
		{
			config:{
				name: 'inc_depreciacion_acum_actualiz',
				fieldLabel: 'Inc.Actualiz.Dep.Acum.',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.inc_depreciacion_acum_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_acum_actualiz',
				fieldLabel: 'Dep.Acum.Ant.Actualiz.',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_acum_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_per_actualiz',
				fieldLabel: 'Dep.Per.Actualiz',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_per_actualiz',type:'string'},
			id_grupo:1,
			grid:false,
			form:false
		},
		{
			config:{
				name: 'depreciacion',
				fieldLabel: 'Dep.Mes',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_per',
				fieldLabel: 'Dep.Periodo',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_per',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'depreciacion_acum',
				fieldLabel: 'Dep.Acum.',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.depreciacion_acum',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'monto_vigente',
				fieldLabel: 'Valor Neto',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					p.style="text-align: right;";
					return Ext.util.Format.number(value,'0,000.00');
				}
			},
			type:'TextField',
			filters:{pfiltro:'res.monto_vigente',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'vida_util',
				fieldLabel: 'Vida Util',
				gwidth: 70,
				maxLength:10
			},
			type:'TextField',
			filters:{pfiltro:'res.vida_util',type:'string'},
			id_grupo:1,
			grid:false,
			form:false
		}

	],
	tam_pag:50,	
	title:'Detalle de Depreciacion',
	ActSave:'../../sis_kactivos_fijos/control/MovimientoAfDep/insertarMovimientoAfDep',
	ActDel:'../../sis_kactivos_fijos/control/MovimientoAfDep/eliminarMovimientoAfDep',
	ActList:'../../sis_kactivos_fijos/control/MovimientoAfDep/listarMovimientoAfDep',
	id_store:'id_movimiento_af_dep',
	fields: [
		{name:'id_movimiento_af_dep', type: 'numeric'},
		{name:'id_movimiento_af', type: 'numeric'},
		{name:'id_activo_fijo_valor', type: 'numeric'},
		{name:'fecha', type: 'date',dateFormat:'Y-m-d'},
		{name:'depreciacion_acum_ant', type: 'numeric'},
		{name:'depreciacion_per_ant', type: 'numeric'},
		{name:'monto_actualiz_ant', type: 'numeric'},
		{name:'vida_util_ant', type: 'numeric'},
		{name:'depreciacion_acum_actualiz', type: 'numeric'},
		{name:'depreciacion_per_actualiz', type: 'numeric'},
		{name:'monto_actualiz', type: 'numeric'},
		{name:'depreciacion', type: 'numeric'},
		{name:'depreciacion_acum', type: 'numeric'},
		{name:'depreciacion_per', type: 'numeric'},
		{name:'monto_vigente', type: 'numeric'},
		{name:'vida_util', type: 'numeric'},
		{name:'tipo_cambio_ini', type: 'numeric'},
		{name:'tipo_cambio_fin', type: 'numeric'},
		{name:'factor', type: 'numeric'},
		{name:'inc_monto_actualiz', type: 'numeric'},
		{name:'inc_depreciacion_acum_actualiz', type: 'numeric'}
	],
	sortInfo:{
		field: 'id_movimiento_af_dep',
		direction: 'ASC'
	},
	sortInfo:{
		field: 'id_movimiento_af_dep',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true
	}
)
</script>
		
		