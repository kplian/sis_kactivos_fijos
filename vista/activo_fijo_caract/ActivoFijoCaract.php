<?php
/**
*@package pXP
*@file ActivoFijoCaract.php
*@author  (admin)
*@date 17-04-2016 07:14:58
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #18    KAF       ETR           15/07/2019  RCM         Inclusión de expresión regular como máscara para validación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoCaract=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.ActivoFijoCaract.superclass.constructor.call(this,config);
		this.init();
		this.bloquearMenus();

		//Eventos
		this.Cmp.id_clasificacion_variable.on('select', function(combo, record, index) {
			this.Cmp.fecha.hide();
			this.Cmp.fecha.allowBlank = true;
			this.Cmp.fecha.setValue('');
			this.Cmp.numero.hide();
			this.Cmp.numero.allowBlank = true;
			this.Cmp.numero.setValue('');
			this.Cmp.texto.hide();
			this.Cmp.texto.allowBlank = true;
			this.Cmp.texto.setValue('');
			this.Cmp.valor.setValue('');


			if(record.data.tipo_dato == 'fecha') {
				this.Cmp.fecha.show();
				this.Cmp.fecha.allowBlank = false;
			} else if(record.data.tipo_dato == 'numero') {
				this.Cmp.numero.show();
				this.Cmp.numero.allowBlank = false;
			} else {
				this.Cmp.texto.show();
				this.Cmp.texto.allowBlank = false;

				//Si tiene máscara la aplica
				/*this.Cmp.texto.maskRe = /^[0-9]{4}-{1}[A-Z]{3}$/i;
				this.Cmp.texto.regex = /^[0-9]{4}-{1}[A-Z]{3}$/i;
				this.Cmp.texto.regexText = 'Formato: 9999-ZZZ';*/

				//Si tiene máscara la aplica
				/*this.Cmp.texto.maskRe = record.data.regex;
				this.Cmp.texto.regex = record.data.regex;
				this.Cmp.texto.regexText = 'Formato: ' + record.data.regex_ejemplo;*/
			}
		},this);

		this.Cmp.fecha.on('blur',function(cmp){
			var d = new Date(this.Cmp.fecha.getValue());
			this.Cmp.valor.setValue(d.format("d/m/Y"));
		},this);
		this.Cmp.numero.on('blur',function(cmp){
			this.Cmp.valor.setValue(this.Cmp.numero.getValue());
		},this);
		this.Cmp.texto.on('blur',function(cmp){
			this.Cmp.valor.setValue(this.Cmp.texto.getValue());
		},this);
	},

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo_caract'
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
			config: {
				name: 'id_clasificacion_variable',
				fieldLabel: 'Variable',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/ClasificacionVariable/listarClasificacionVariable',
					id: 'id_clasificacion_variable',
					root: 'datos',
					sortInfo: {
						field: 'nombre',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_clasificacion_variable', 'nombre', 'descripcion', 'obligatorio', 'tipo_dato', 'orden_var', 'regex', 'regex_ejemplo'], //#18 se agregan nuevas columnas
					remoteSort: true,
					baseParams: {par_filtro: 'clavar.nombre#clavar.descripcion'}
				}),
				valueField: 'id_clasificacion_variable',
				displayField: 'nombre',
				gdisplayField: 'nombre_variable',
				hiddenName: 'id_clasificacion_variable',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '95%',
				gwidth: 150,
				minChars: 2
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'clavar.nombre#clavar.descripcion',type: 'string'},
			grid: true,
			form: true
		},
		{
			config:{
				name: 'clave',
				fieldLabel: 'Caracteristica',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				maxLength:100,
				hidden: true
			},
			type:'TextField',
			filters:{pfiltro:'afcaract.clave',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'valor',
				fieldLabel: 'Valor',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				maxLength:1000
			},
			type:'TextField',
			filters:{pfiltro:'afcaract.valor',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,
			egrid: true
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
			filters:{pfiltro:'afcaract.estado_reg',type:'string'},
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
			filters:{pfiltro:'afcaract.id_usuario_ai',type:'numeric'},
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
			filters:{pfiltro:'afcaract.usuario_ai',type:'string'},
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
			filters:{pfiltro:'afcaract.fecha_reg',type:'date'},
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
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
			type:'DateField',
			filters:{pfiltro:'afcaract.fecha_mod',type:'date'},
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
				labelSeparator:'',
				inputType:'hidden',
				name: 'nombre_variable'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				labelSeparator:'',
				inputType:'hidden',
				name: 'tipo_dato'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				labelSeparator:'',
				inputType:'hidden',
				name: 'obligatorio'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				name: 'fecha',
				fieldLabel: 'Valor',
				hidden: true,
			},
			type:'DateField',
			form:true,
			id_grupo:1,
			grid:false
		},
		{
			config:{
				name: 'numero',
				fieldLabel: 'Valor',
				hidden: true,
			},
			type:'NumberField',
			form:true,
			id_grupo:1,
			grid:false
		},
		{
			config:{
				name: 'texto',
				fieldLabel: 'Valor',
				anchor: '95%',
			},
			type:'TextField',
			form:true,
			id_grupo:1,
			grid:false
		}

	],
	tam_pag:50,
	title:'Caracteristicas',
	ActSave:'../../sis_kactivos_fijos/control/ActivoFijoCaract/insertarActivoFijoCaract',
	ActDel:'../../sis_kactivos_fijos/control/ActivoFijoCaract/eliminarActivoFijoCaract',
	ActList:'../../sis_kactivos_fijos/control/ActivoFijoCaract/listarActivoFijoCaract',
	id_store:'id_activo_fijo_caract',
	fields: [
		{name:'id_activo_fijo_caract', type: 'numeric'},
		{name:'clave', type: 'string'},
		{name:'valor', type: 'string'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		'id_clasificacion_variable','nombre_variable','tipo_dato','obligatorio'
	],
	sortInfo:{
		field: 'id_activo_fijo_caract',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,

	onReloadPage : function(m) {
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

		//Actualización de parámetros para combo de variables
		Ext.apply(this.Cmp.id_clasificacion_variable.store.baseParams,{
			id_clasificacion: this.maestro.id_clasificacion,
			id_activo_fijo: this.maestro.id_activo_fijo
		});
		this.Cmp.id_clasificacion_variable.modificado=true;
	},

	onButtonNew: function() {
        Phx.vista.ActivoFijoCaract.superclass.onButtonNew.call(this);
        this.Cmp.valor.setVisible(false);
        //this.Cmp.clave.allowBlank=false;
        //this.Cmp.clave.show();
        this.Cmp.id_clasificacion_variable.modificado=true;
    },
    onButtonEdit: function() {
        Phx.vista.ActivoFijoCaract.superclass.onButtonEdit.call(this);
        this.Cmp.valor.setVisible(false);
        //this.Cmp.clave.allowBlank=true;
        //this.Cmp.clave.hide();
        var data = this.sm.getSelected().data;
        //Inicialización
        this.Cmp.fecha.hide();
		this.Cmp.fecha.allowBlank = true;
		this.Cmp.numero.hide();
		this.Cmp.numero.allowBlank = true;
		this.Cmp.texto.hide();
		this.Cmp.texto.allowBlank = true;
		//Por caso
        if(data.tipo_dato=='fecha'){
        	this.Cmp.fecha.show();
			this.Cmp.fecha.allowBlank = false;
			this.Cmp.fecha.setValue(data.valor);
        } else if(data.tipo_dato=='numero'){
        	this.Cmp.numero.show();
			this.Cmp.numero.allowBlank = false;
			this.Cmp.numero.setValue(data.valor);
        } else {
        	this.Cmp.texto.show();
			this.Cmp.texto.allowBlank = false;
			this.Cmp.texto.setValue(data.valor);

        }
        this.Cmp.id_clasificacion_variable.modificado=true;
    }
})
</script>

