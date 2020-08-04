<?php
/**
*@package pXP
*@file ActivoFijoValoresHist.php
*@author  RCM
*@date 01/11/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
/***************************************************************************
#ISSUE  SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
		KAF 	ETR 		01/11/2017  RCM 	Creación del archivo
 #40    KAF     ETR         05/12/2019  RCM     Adición de campos faltantes
 #70    KAF     ETR         03/08/2020  RCM     Adición de fecha para TC ini de la primera depreciación
***************************************************************************/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoValoresHist = Ext.extend(Phx.gridInterfaz, {

	constructor: function(config) {
		this.maestro = config;
		this.initButtons = [this.cmbMonedaDep];
    	//llama al constructor de la clase padre
		Phx.vista.ActivoFijoValoresHist.superclass.constructor.call(this,config);
		this.init();

		Phx.CP.loadingShow();

		Ext.Ajax.request({
            url: '../../sis_parametros/control/Moneda/getMonedaBase',
            params: {moneda:'si'},
            success: function(res,params){
                Phx.CP.loadingHide();
                var response = Ext.decode(res.responseText).ROOT.datos;
                Ext.apply(this.store.baseParams,{
                	id_activo_fijo: this.maestro[0].data.id_activo_fijo,
                	id_moneda: response.id_moneda});
                this.load();
            },
            argument: this.argumentSave,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });

        this.iniciaEventos();

	},
	cmbMonedaDep: new Ext.form.ComboBox({
		fieldLabel: 'Moneda',
		grupo: [0,1,2],
		allowBlank: true,
		blankText: '...',
		emptyText: 'Moneda...',
		store: new Ext.data.JsonStore({
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
				gwidth: 80,
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
				name: 'desc_moneda',
				fieldLabel: 'Moneda',
				allowBlank: true,
				anchor: '80%',
				gwidth: 90,
				maxLength:15
			},
				type:'TextField',
				filters:{pfiltro:'mon.codigo',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'monto_vigente_orig_100',
				fieldLabel: 'Valor Compra',
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
				filters:{pfiltro:'actval.monto_vigente_orig_100',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'monto_vigente_orig',
				fieldLabel: 'Valor Inicial',
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
				id_grupo: 1,
				grid: true,
				form: true
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
				grid:false,
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
				grid:false,
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
				grid:false,
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
				name: 'fecha_ult_dep',
				fieldLabel: 'Fecha Ult. Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 110,
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
				name: 'fecha_fin',
				fieldLabel: 'Fecha Fin',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type: 'DateField',
				filters: {pfiltro:'actval.fecha_fin',type:'date'},
				id_grupo: 1,
				grid: true,
				form: true
		},
		{
			config:{
				name: 'monto_rescate',
				fieldLabel: 'Valor Rescate',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 10
			},
				type:'NumberField',
				filters:{pfiltro:'actval.monto_rescate',type:'numeric'},
				id_grupo:1,
				grid: true,
				form: true
		},
		//Inicio #40
		{
			config:{
				name: 'monto_vigente_actualiz_inicial',
				fieldLabel: 'Valor Actualizado Inicial',
				allowBlank: true,
				anchor: '80%',
				renderer: function (value, p, record){
					if(record.data.tipo_reg != 'summary'){
						return String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
					} else {
						Ext.util.Format.usMoney
						return String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
					}
				},
				gwidth: 130
			},
			type: 'NumberField',
			filters: { pfiltro: 'actval.monto_vigente_actualiz_inicial', type: 'numeric' },
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'depreciacion_acum_inicial',
				fieldLabel: 'Dep.Acum. Inicial',
				allowBlank: true,
				anchor: '80%',
				renderer: function (value, p, record){
					if(record.data.tipo_reg != 'summary'){
						return String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
					} else {
						Ext.util.Format.usMoney
						return String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
					}
				},
				gwidth: 130
			},
			type: 'NumberField',
			filters: { pfiltro: 'actval.depreciacion_acum_inicial', type: 'numeric' },
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'depreciacion_per_inicial',
				fieldLabel: 'Dep.Per. Inicial',
				allowBlank: true,
				anchor: '80%',
				renderer: function (value, p, record){
					if(record.data.tipo_reg != 'summary'){
						return String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
					} else {
						Ext.util.Format.usMoney
						return String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
					}
				},
				gwidth: 130
			},
			type: 'NumberField',
			filters: { pfiltro: 'actval.depreciacion_per_inicial', type: 'numeric' },
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'importe_modif',
				fieldLabel: 'Incremento',
				allowBlank: true,
				anchor: '80%',
				renderer: function (value, p, record){
					if(record.data.tipo_reg != 'summary'){
						return String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
					} else {
						Ext.util.Format.usMoney
						return String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
					}
				},
				gwidth: 130
			},
			type: 'NumberField',
			filters: { pfiltro: 'actval.importe_modif', type: 'numeric' },
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'importe_modif_sin_act',
				fieldLabel: 'Inc. Sin Actualiz',
				allowBlank: true,
				anchor: '80%',
				renderer: function (value, p, record){
					if(record.data.tipo_reg != 'summary'){
						return String.format('{0}',  Ext.util.Format.number(value,'0,000.00'));
					} else {
						Ext.util.Format.usMoney
						return String.format('<b><font size=2 >{0}</font><b>', Ext.util.Format.number(value,'0,000.00'));
					}
				}

			},
			type: 'NumberField',
			filters: { pfiltro: 'actval.importe_modif_sin_act', type: 'numeric' },
			id_grupo: 1,
			grid: true,
			form: true,
			gwidth: 160
		},
		//Fin #40
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
				grid:false,
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
				grid:false,
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
				grid:false,
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
				grid:false,
				form:false
		},
		//Inicio #70
		{
			config:{
				name: 'fecha_tc_ini_dep',
				fieldLabel: 'Fecha UFV Ini',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record){return value?value.dateFormat('d/m/Y'):''}
			},
			type: 'DateField',
			filters: {pfiltro: 'actval.fecha_tc_ini_dep', type:'date'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		//Fin #70
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
        'depreciacion_per_real','tipo_reg','monto_actualiz_real','desc_moneda',
        {name:'fecha_fin', type: 'date',dateFormat:'Y-m-d'},
        {name:'monto_vigente_orig_100', type: 'numeric'},'id_moneda',
        //Inicio #40
        {name:'monto_vigente_actualiz_inicial', type: 'numeric'},
        {name:'depreciacion_acum_inicial', type: 'numeric'},
        {name:'depreciacion_per_inicial', type: 'numeric'},
        {name:'importe_modif', type: 'numeric'},
        {name:'importe_modif_sin_act', type: 'numeric'},
        //Fin #40
        {name:'fecha_tc_ini_dep', type: 'date',dateFormat:'Y-m-d'} //#70
	],
	sortInfo:{
		field: 'id_activo_fijo_valor',
		direction: 'ASC'
	},
	bdel: false,
	bedit: true,
	bsave: false,
	south: {
        url: '../../../sis_kactivos_fijos/vista/movimiento_af_dep/MovimientoAfDepPrin.php',
        title: 'Depreciaciones',
        height: '60%',
        cls: 'MovimientoAfDepPrin'
    },
    iniciaEventos: function(){
    	this.cmbMonedaDep.on('select',function(combo, record, index){
			Ext.apply(this.store.baseParams,{
				id_moneda: record.data.id_moneda});
			this.load();
    	},this)
    }
})
</script>

