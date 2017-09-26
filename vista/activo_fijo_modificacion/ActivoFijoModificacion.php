<?php
/**
*@package pXP
*@file gen-ActivoFijoModificacion.php
*@author  (admin)
*@date 23-08-2017 14:14:25
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoModificacion=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.ActivoFijoModificacion.superclass.constructor.call(this,config);
		this.init();
		this.grid.getTopToolbar().disable();
		this.grid.getBottomToolbar().disable();

		//Se oculta componentes
		this.Cmp.id_oficina_ant.setVisible(false);

		//Eventos
		this.Cmp.tipo.on('select',this.onSelectTipo,this);
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo_modificacion'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'fecha_reg',
				fieldLabel: 'Fecha',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y', 
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
			type:'DateField',
			filters:{pfiltro:'kafmod.fecha_reg',type:'date'},
			id_grupo:1,
			grid:true,
			form:false
		}, {
			config: {
				name: 'tipo',
				fieldLabel: 'Tipo Modificación',
				typeAhead: true,
			    triggerAction: 'all',
			    lazyRender:true,
				mode: 'local',
			    store: new Ext.data.ArrayStore({
			        id: 0,
			        fields: [
			            'key',
			            'value'
			        ],
			        data: [[1, 'Dirección'], [2, 'Notas']]
			    }),
			    valueField: 'key',
			    displayField: 'value',
			    gdisplayField: 'desc_tipo'
			},
			type: 'ComboBox',
			id_grupo: 1,
			grid: true,
			form: true
		}, {
			config: {
				name: 'datos_nuevos',
				fieldLabel: 'Datos Nuevos',
				gwidth: 350,
				renderer: function(value,p,record){
					var resp;
					console.log('xxxx 111',record);
					if(record.data.tipo==1){
						//Dirección
						resp=String.format('<tpl for="."><div class="x-combo-list-item"><b>Oficina:</b> {0}<br><b>Ubicación:</b> {1}<br><b>Obervaciones:</b> {2}</div></tpl>',record.data['desc_oficina'],record.data['ubicacion'],record.data['observaciones']);
					} else if(record.data.tipo==2){
						//Notas
						resp=String.format('<tpl for="."><div class="x-combo-list-item"><b>Nota:</b> {0}</div></tpl>',record.data['observaciones']);
					}
					console.log('xxxx 222',resp);
					return resp;
					
				}
			},
			type: 'TextField',
			grid: true,
			form: false
		}, {
			config: {
				name: 'datos_anteriores',
				fieldLabel: 'Datos Anteriores',
				gwidth: 350,
				renderer: function(value,p,record){
					var resp;
					if(record.data.tipo==1){
						//Dirección
						resp=String.format('<tpl for="."><div class="x-combo-list-item"><b>Oficina:</b> {0}<br><b>Ubicación:</b> {1}<br><b>Obervaciones:</b> {2}</div></tpl>',record.data['desc_oficina_ant'],record.data['ubicacion_ant'],record.data['observaciones']);
					} else if(record.data.tipo==2){
						//Notas
						resp='';
					}
					return resp;
					
				}
			},
			type: 'TextField',
			grid: true,
			form: false
		},
		{
			config: {
				name: 'id_oficina',
				fieldLabel: 'Oficina',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
                    url: '../../sis_organigrama/control/Oficina/listarOficina',
                    id: 'id_oficina',
                    root: 'datos',
                    fields: ['id_oficina','codigo','nombre'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    baseParams:{par_filtro:'ofi.codigo#ofi.nombre'}
                }),
				valueField: 'id_oficina',
				displayField: 'nombre',
				gdisplayField: 'desc_oficina',
				hiddenName: 'id_oficina',
				forceSelection: false,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 150,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['desc_oficina']);
				},
				disabled: true
			},
			type: 'ComboBox',
			id_grupo: 1,
			filters: {pfiltro: 'ofi.codigo#ofi.nombre',type: 'string'},
			grid: false,
			form: true,
			bottom_filter: true
		},
		{
			config:{
				name: 'ubicacion',
				fieldLabel: 'Ubicación',
				anchor: '100%',
				gwidth: 100,
				maxLength:1000,
				disabled: true
			},
			type:'TextArea',
			filters:{pfiltro:'kafmod.ubicacion',type:'string'},
			id_grupo:1,
			grid:false,
			form:true
		},
	    {
			config:{
				name: 'observaciones',
				fieldLabel: 'Notas',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength:5000,
				disabled: true
			},
			type:'TextArea',
			filters:{pfiltro:'kafmod.observaciones',type:'string'},
			id_grupo:1,
			grid:false,
			form:true,
			bottom_filter: true
		},
		{
			config: {
				name: 'id_oficina_ant',
				fieldLabel: 'Oficina',
				allowBlank: true,
				gdisplayField: 'desc_oficina_ant',
				gwidth: 150,
				width: '100%',
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['desc_oficina_ant']);
				}
			},
			type: 'TextField',
			id_grupo: 0,
			filters: {pfiltro: 'ofi.codigo#ofi.nombre',type: 'string'},
			grid: false,
			form: true
		},
		{
			config: {
				name: 'oficina_ant',
				fieldLabel: 'Oficina',
				style: 'background-color: #ddd; background-image: none;',
				readOnly: true,
				width:'100%'
			},
			type: 'TextField',
			id_grupo: 0,
			grid: false,
			form: true
		},
	    {
			config:{
				name: 'ubicacion_ant',
				fieldLabel: 'Ubicación',
				allowBlank: true,
				width:'100%',
				gwidth: 100,
				maxLength:1000,
				style: 'background-color: #ddd; background-image: none;',
				readOnly: true
			},
			type:'TextArea',
			filters:{pfiltro:'kafmod.ubicacion_ant',type:'string'},
			id_grupo:0,
			grid:false,
			form:false
		},
		{
			config: {
				name: 'ubicacion_ant_tmp',
				fieldLabel: 'Ubicación',
				style: 'background-color: #ddd; background-image: none;',
				readOnly: true,
				width:'100%'
			},
			type: 'TextField',
			id_grupo: 0,
			grid: false,
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
				filters:{pfiltro:'kafmod.estado_reg',type:'string'},
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
				filters:{pfiltro:'kafmod.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
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
				filters:{pfiltro:'kafmod.usuario_ai',type:'string'},
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
				filters:{pfiltro:'kafmod.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Modificaciones',
	ActSave:'../../sis_kactivos_fijos/control/ActivoFijoModificacion/insertarActivoFijoModificacion',
	ActDel:'../../sis_kactivos_fijos/control/ActivoFijoModificacion/eliminarActivoFijoModificacion',
	ActList:'../../sis_kactivos_fijos/control/ActivoFijoModificacion/listarActivoFijoModificacion',
	id_store:'id_activo_fijo_modificacion',
	fields: [
		{name:'id_activo_fijo_modificacion', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_oficina', type: 'numeric'},
		{name:'id_oficina_ant', type: 'numeric'},
		{name:'ubicacion', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'ubicacion_ant', type: 'string'},
		{name:'observaciones', type: 'string'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'desc_oficina', type: 'string'},
		{name:'desc_oficina_ant', type: 'string'},
		{name:'tipo', type: 'numeric'},
		{name:'desc_tipo', type: 'string'}
	],
	sortInfo:{
		field: 'id_activo_fijo_modificacion',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,
	onReloadPage: function(m) {
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_activo_fijo;

		//Define the filter to apply for activos fijod drop down
		this.store.baseParams = {
			id_activo_fijo: this.maestro.id_activo_fijo
		};
		this.load({
			params: {
				start: 0,
				limit: 50
			}
		});
	},
	onButtonNew: function(){
		Phx.vista.ActivoFijoModificacion.superclass.onButtonNew.call(this);
		this.Cmp.oficina_ant.setValue(this.maestro.oficina);
		this.Cmp.ubicacion_ant_tmp.setValue(this.maestro.ubicacion);
    },
    onSelectTipo: function(combo,record,index){
    	//Por defecto se permite nulo a todos los componentes
		this.Cmp.id_oficina.allowBlank=true;
		this.Cmp.ubicacion.allowBlank=true;
		this.Cmp.observaciones.allowBlank=true;

		this.Cmp.id_oficina.setValue('');
		this.Cmp.ubicacion.setValue('');
		this.Cmp.observaciones.setValue('');

    	//Habilita/deshabilita componentes en función de la selección realizada
    	if(record.id==1){
    		//Dirección
    		this.Cmp.id_oficina.setDisabled(false);
    		this.Cmp.ubicacion.setDisabled(false);
    		this.Cmp.observaciones.setDisabled(false);

    		this.Cmp.id_oficina.allowBlank=false;
			this.Cmp.ubicacion.allowBlank=false;

    	} else if(record.id==2){
    		//Notas
    		this.Cmp.id_oficina.setDisabled(true);
    		this.Cmp.ubicacion.setDisabled(true);
    		this.Cmp.observaciones.setDisabled(false);

			this.Cmp.observaciones.allowBlank=false;

    	}
    },
    agregarArgsExtraSubmit: function(){
		//Inicializa el objeto de los argumentos extra
		this.argumentExtraSubmit={};

		//Añade los parámetros para los valores anteriores según corresponda
		var tipo = this.Cmp.tipo.getValue();
		this.argumentExtraSubmit.ubicacion_ant = '';
		if(tipo==1){
			//Dirección
			this.argumentExtraSubmit.id_oficina_ant = this.maestro.id_oficina;
			this.argumentExtraSubmit.ubicacion_ant = this.maestro.ubicacion;
		} 
	},
	Grupos: [{
        layout: 'anchor',
        border: false,
        width: '100%',
        defaults: {
           border: false
        },            
        items: [
        	{
		        bodyStyle: 'padding-right:5px;',
		        items: [{
		            xtype: 'fieldset',
		            title: 'Datos actuales del Activo Fijo',
		            autoHeight: true,
		            anchor: '100%',
		            items: [],
			        id_grupo:0
		        }]
	    	}, {
		        bodyStyle: 'padding-right:5px;',
		        items: [{
		            xtype: 'fieldset',
		            title: 'Nuevos datos',
		            autoHeight: true,
		            anchor: '100%',
		            items: [],
			        id_grupo:1
	        	}]
	    	}
	    ]
    }],
    bedit: false,
    bdel: false,
    bsave: false
})
</script>
		
		