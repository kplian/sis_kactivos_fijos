<?php
/**
*@package pXP
*@file gen-ActivoFijoValores.php
*@author  (admin)
*@date 04-05-2016 03:02:26
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoValores=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config;
		this.initButtons = [this.cmbMonedaDep];
    	//llama al constructor de la clase padre
		Phx.vista.ActivoFijoValores.superclass.constructor.call(this,config);
		
		
		this.cmbMonedaDep.on('select', function(){
			    if( this.validarFiltros() ){
	                  this.capturaFiltros();
	             }
		     },this);
			
			
			
			
		this.init();
		
	},
	
	 cmbMonedaDep: new Ext.form.ComboBox({
				fieldLabel: 'Moneda',
				grupo:[0,1,2],
				allowBlank: false,
				blankText:'... ?',
				emptyText:'Moneda...',
				store:new Ext.data.JsonStore(
				{
					url: '../../sis_kactivos_fijos/control/MonedaDep/listarMonedaDep',
					id: 'id_moneda_dep',
					root: 'datos',
					sortInfo:{
						field: 'descripcion',
						direction: 'DESC'
					},
					totalProperty: 'total',
					fields: ['id_moneda_dep','descripcion','id_moneda','actualiza',],
					// turn on remote sorting
					remoteSort: true,
					baseParams:{par_filtro:'descripcion'}
				}),
				valueField: 'id_moneda_dep',
				triggerAction: 'all',
				displayField: 'descripcion',
			    hiddenName: 'id_moneda_dep',
    			mode:'remote',
				pageSize:50,
				queryDelay:500,
				listWidth:'280',
				width:80
	}),	
			
	Atributos:[
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
					name: 'id_movimiento_af'
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
				gwidth: 200,
				maxLength:50
			},
				type:'TextField',
				filters:{pfiltro:'actval.depreciacion_per',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config: {
				name: 'tipo',
				fieldLabel: 'Tipo',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'tipo',
				hiddenName: 'tipo',
				gwidth: 95,
				baseParams:{
						cod_subsistema:'KAF',
						catalogo_tipo:'tactivo_fijo_valores__tipo'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'actval.tipo',type:'string'},
			grid: true,
			form: true
		},
		
		{
			config:{
				name: 'monto_vigente_orig',
				fieldLabel: 'Monto vigente Orig.',
				allowBlank: true,
				anchor: '80%',
				renderer:function (value,p,record){
						if(record.data.tipo_reg != 'summary'){
							return  String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
						}
						else{
							Ext.util.Format.usMoney
							return  String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
						}
				},
				gwidth: 100,
			},
				type:'NumberField',
				filters:{pfiltro:'actval.monto_vigente_orig',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'monto_actualiz_real',
				fieldLabel: 'Monto Actualizado',
				allowBlank: true,
				anchor: '80%',
				renderer:function (value,p,record){
						if(record.data.tipo_reg != 'summary'){
							return  String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
						}
						else{
							Ext.util.Format.usMoney
							return  String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
						}
				},
				gwidth: 100,
			},
				type:'NumberField',
				filters:{pfiltro:'actval.monto_vigente_orig',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'depreciacion_acum_real',
				fieldLabel: 'Dep. Acum.',
				allowBlank: true,
				anchor: '80%',
				renderer:function (value,p,record){
						if(record.data.tipo_reg != 'summary'){
							return  String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
						}
						else{
							Ext.util.Format.usMoney
							return  String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
						}
				},
				gwidth: 100
			},
				type:'NumberField',
				filters:{pfiltro:'afv.depreciacion_acum_real',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'monto_vigente_real',
				fieldLabel: 'Monto Vigente',
				allowBlank: true,
				renderer:function (value,p,record){
						if(record.data.tipo_reg != 'summary'){
							return  String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
						}
						else{
							Ext.util.Format.usMoney
							return  String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
						}
				},
				
				anchor: '80%',
				gwidth: 100
			},
				type:'NumberField',
				filters:{pfiltro:'aafv.monto_vigente_real',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'vida_util_orig',
				fieldLabel: 'Vida util Original',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'NumberField',
				filters:{pfiltro:'actval.vida_util_orig',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'vida_util_real',
				fieldLabel: 'Vida util',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4,
				renderer:function (value,p,record){
						if(record.data.tipo_reg != 'summary'){
							return  String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
						}
						else{
							Ext.util.Format.usMoney
							return  String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
						}
				}
			},
				type:'NumberField',
				filters:{pfiltro:'afv.vida_util_real',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha Ini. Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'actval.fecha_ini_dep',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_ult_dep',
				fieldLabel: 'Fecha Ult. Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'actval.fecha_ult_dep',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'monto_rescate',
				fieldLabel: 'Valor Rescate',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:-5
			},
				type:'NumberField',
				filters:{pfiltro:'actval.monto_rescate',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'depreciacion_per',
				fieldLabel: 'Dep. Periodo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:-5
			},
				type:'NumberField',
				filters:{pfiltro:'actval.depreciacion_per',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:15
			},
				type:'TextField',
				filters:{pfiltro:'actval.estado',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'desc_moneda',
				fieldLabel: 'Moneda',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:15
			},
				type:'TextField',
				filters:{pfiltro:'mon.desc_moneda',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'principal',
				fieldLabel: 'Principal',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:2
			},
				type:'TextField',
				filters:{pfiltro:'actval.principal',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'tipo_cambio_ini',
				fieldLabel: 'T.C. Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:-5
			},
				type:'NumberField',
				filters:{pfiltro:'actval.tipo_cambio_ini',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'depreciacion_mes',
				fieldLabel: 'Depreciacion',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:-5
			},
				type:'NumberField',
				filters:{pfiltro:'actval.depreciacion_mes',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		
		
		{
			config:{
				name: 'tipo_cambio_fin',
				fieldLabel: 'T.C. Fin',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:-5
			},
				type:'NumberField',
				filters:{pfiltro:'actval.tipo_cambio_fin',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
	
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
				type:'TextField',
				filters:{pfiltro:'actval.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'actval.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'usu1.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
			{
			config:{
				name: 'usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:300
			},
				type:'TextField',
				filters:{pfiltro:'actval.usuario_ai',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'id_usuario_ai',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'actval.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
				form:false
		},
		{
			config:{
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'actval.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'usu2.cuenta',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	capturaFiltros : function(combo, record, index) {
		
			this.desbloquearOrdenamientoGrid();
			this.store.baseParams.id_moneda_dep = this.cmbMonedaDep.getValue();			
			this.load();
			
	},

	validarFiltros : function() {
		
		if ( this.cmbMonedaDep.validate() ) {
			
			return true;
		} else {
			return false;
		}
		
	},
	onButtonAct : function() {
		
			if (!this.validarFiltros()) {
				alert('Especifique los filtros antes')
			}
			else{
				 this.capturaFiltros();
			}
			
	},
	
	
	
	tam_pag:50,	
	title:'Valores Activos Fijos',
	ActSave:'../../sis_kactivos_fijos/control/ActivoFijoValores/insertarActivoFijoValores',
	ActDel:'../../sis_kactivos_fijos/control/ActivoFijoValores/eliminarActivoFijoValores',
	ActList:'../../sis_kactivos_fijos/control/ActivoFijoValores/listarActivoFijoValores',
	id_store:'id_activo_fijo_valor',
	fields: [
		{name:'id_activo_fijo_valor', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'depreciacion_per', type: 'numeric'},
		{name:'estado', type: 'string'},
		{name:'principal', type: 'string'},
		{name:'monto_vigente', type: 'numeric'},
		{name:'monto_rescate', type: 'numeric'},
		{name:'tipo_cambio_ini', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'tipo', type: 'string'},
		{name:'depreciacion_mes', type: 'numeric'},
		{name:'depreciacion_acum', type: 'numeric'},
		{name:'fecha_ult_dep', type: 'date',dateFormat:'Y-m-d'},
		{name:'fecha_ini_dep', type: 'date',dateFormat:'Y-m-d'},
		{name:'monto_vigente_orig', type: 'numeric'},
		{name:'vida_util', type: 'numeric'},
		{name:'vida_util_orig', type: 'numeric'},
		{name:'id_movimiento_af', type: 'numeric'},
		{name:'tipo_cambio_fin', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'codigo', type: 'string'},
        'monto_vigente_real',
        'vida_util_real',
         'depreciacion_acum_ant_real',
         'depreciacion_acum_real',
         'depreciacion_per_real','tipo_reg','monto_actualiz_real','desc_moneda'

		
	],
	sortInfo:{
		field: 'id_activo_fijo_valor',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true
})
</script>
		
		