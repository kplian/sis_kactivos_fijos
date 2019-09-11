<?php
/**
*@package pXP
*@file ClasificacionVariable.php
*@author  (admin)
*@date 27-06-2017 09:34:29
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #18    KAF       ETR           15/07/2019  RCM         Inclusión de expresión regular como máscara para validación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ClasificacionVariable = Ext.extend(Phx.gridInterfaz, {

	constructor: function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.ClasificacionVariable.superclass.constructor.call(this,config);
		this.init();
	},

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_clasificacion_variable'
			},
			type:'Field',
			form:true
		},
		{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_clasificacion'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				name: 'nombre',
				fieldLabel: 'Nombre Variable',
				allowBlank: false,
				anchor: '95%',
				gwidth: 130,
				maxLength:50
			},
			type:'TextField',
			filters:{pfiltro:'clavar.nombre',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'descripcion',
				fieldLabel: 'Descripción',
				allowBlank: true,
				anchor: '95%',
				gwidth: 200,
				maxLength: 500
			},
			type:'TextArea',
			filters:{pfiltro:'clavar.descripcion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config: {
				name: 'tipo_dato',
				fieldLabel: 'Tipo de Dato',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'tipo_dato',
				hiddenName: 'tipo_dato',
				gwidth: 90,
				baseParams:{
					cod_subsistema:'KAF',
					catalogo_tipo:'tclasificacion_variable__tipo_dato'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'clavar.tipo_dato',type:'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'obligatorio',
				fieldLabel: '¿Es Obligatorio?',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'obligatorio',
				hiddenName: 'obligatorio',
				gwidth: 130,
				baseParams:{
					cod_subsistema:'KAF',
					catalogo_tipo:'tclasificacion_variable__obligatorio'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'clavar.obligatorio',type:'string'},
			grid: true,
			form: true
		},
		{
			config:{
				name: 'orden_var',
				fieldLabel: 'Orden',
				allowBlank: true,
				anchor: '30%',
				gwidth: 80,
				maxLength:4,
				maxValue: 50,
				minValue: 0,
				allowDecimals: false
			},
			type:'NumberField',
			filters:{pfiltro:'clavar.orden_var',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		//#18 Inicio: se agrega columna
		{
			config: {
				name: 'regex',
				fieldLabel: 'Expresión Regular',
				allowBlank: true,
				anchor: '95%',
				gwidth: 150,
				maxLength: 200
			},
			type: 'TextField',
			filters: {pfiltro:'clavar.regex', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		}, {
			config: {
				name: 'regex_ejemplo',
				fieldLabel: 'Ejemplo Expr.Regular',
				allowBlank: true,
				anchor: '95%',
				gwidth: 150,
				maxLength: 200
			},
			type: 'TextField',
			filters: {pfiltro:'clavar.regex_ejemplo', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		//#18 Fin
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
			filters:{pfiltro:'clavar.estado_reg',type:'string'},
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
			filters:{pfiltro:'clavar.id_usuario_ai',type:'numeric'},
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
			filters:{pfiltro:'clavar.usuario_ai',type:'string'},
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
			filters:{pfiltro:'clavar.fecha_reg',type:'date'},
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
			filters:{pfiltro:'clavar.fecha_mod',type:'date'},
			id_grupo:1,
			grid:true,
			form:false
		}
	],
	tam_pag:50,
	title:'Variables',
	ActSave:'../../sis_kactivos_fijos/control/ClasificacionVariable/insertarClasificacionVariable',
	ActDel:'../../sis_kactivos_fijos/control/ClasificacionVariable/eliminarClasificacionVariable',
	ActList:'../../sis_kactivos_fijos/control/ClasificacionVariable/listarClasificacionVariable',
	id_store:'id_clasificacion_variable',
	fields: [
		{name:'id_clasificacion_variable', type: 'numeric'},
		{name:'id_clasificacion', type: 'numeric'},
		{name:'nombre', type: 'string'},
		{name:'tipo_dato', type: 'string'},
		{name:'descripcion', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'obligatorio', type: 'string'},
		{name:'orden_var', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'regex', type: 'string'}, //#18 Se agrega columna
		{name:'regex_ejemplo', type: 'string'} //#18 Se agrega columna
	],
	sortInfo: {
		field: 'id_clasificacion_variable',
		direction: 'ASC'
	},
	bdel: true,
	bsave: true,
	onReloadPage: function(m){
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_clasificacion;
		this.store.baseParams = {
			id_clasificacion: this.maestro.id_clasificacion
		};
		this.load({
			params: {
				start: 0,
				limit: 50
			}
		});
	}
})
</script>

