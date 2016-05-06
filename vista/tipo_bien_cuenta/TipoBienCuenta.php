<?php
/**
*@package pXP
*@file gen-TipoBienCuenta.php
*@author  (admin)
*@date 16-04-2016 10:01:08
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.TipoBienCuenta=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.TipoBienCuenta.superclass.constructor.call(this,config);
		this.init();
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tipo_bien_cuenta'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tipo_cuenta'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'codigo_bien',
				fieldLabel: 'Codigo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:10
			},
				type:'TextField',
				filters:{pfiltro:'tipbie.codigo',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config: {
				name: 'id_tipo_bien',
				fieldLabel: 'Tipo Bien',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/TipoBien/listarTipoBien',
					id: 'id_tipo_bien',
					root: 'datos',
					sortInfo: {
						field: 'descripcion',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_tipo_bien', 'codigo', 'descripcion'],
					remoteSort: true,
					baseParams: {par_filtro: 'tipbie.codigo#tipbie.descripcion'}
				}),
				valueField: 'id_tipo_bien',
				displayField: 'descripcion',
				gdisplayField: 'desc_bien',
				hiddenName: 'id_tipo_bien',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 300,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['desc_bien']);
				},
				tpl : '<tpl for="."><div class="x-combo-list-item"><p><b>Codigo:</b> {codigo}</p><p><b>Bien:</b> {descripcion}</p></div></tpl>',
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'tipbi.codigo',type: 'string'},
			grid: true,
			form: true
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
				filters:{pfiltro:'biecue.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'id_usuario_ai',
				fieldLabel: '',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'biecue.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
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
				filters:{pfiltro:'biecue.usuario_ai',type:'string'},
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
				filters:{pfiltro:'biecue.fecha_reg',type:'date'},
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
				filters:{pfiltro:'biecue.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Tipo de Bien - Cuenta contable',
	ActSave:'../../sis_kactivos_fijos/control/TipoBienCuenta/insertarTipoBienCuenta',
	ActDel:'../../sis_kactivos_fijos/control/TipoBienCuenta/eliminarTipoBienCuenta',
	ActList:'../../sis_kactivos_fijos/control/TipoBienCuenta/listarTipoBienCuenta',
	id_store:'id_tipo_bien_cuenta',
	fields: [
		{name:'id_tipo_bien_cuenta', type: 'numeric'},
		{name:'id_tipo_cuenta', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_tipo_bien', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'codigo_bien', type: 'string'},
		{name:'desc_bien', type: 'string'}
	],
	sortInfo:{
		field: 'id_tipo_bien_cuenta',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,
	onReloadPage : function(m) {
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_tipo_cuenta;

		this.store.baseParams = {
			id_tipo_cuenta: this.maestro.id_tipo_cuenta
		};
		this.load({
			params : {
				start : 0,
				limit : 50
			}
		});
	}
})
</script>
		
		