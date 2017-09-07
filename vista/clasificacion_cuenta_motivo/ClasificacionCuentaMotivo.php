<?php
/**
*@package pXP
*@file gen-ClasificacionCuentaMotivo.php
*@author  (admin)
*@date 15-08-2017 17:28:50
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ClasificacionCuentaMotivo=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config;
    	//llama al constructor de la clase padre
		Phx.vista.ClasificacionCuentaMotivo.superclass.constructor.call(this,config);
		this.init();

		this.Atributos[1].valorInicial = this.maestro.id_movimiento_motivo;

		this.store.baseParams = {
			id_movimiento_motivo: this.maestro.id_movimiento_motivo
		};
		this.load({params:{start:0, limit:this.tam_pag}})
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_clasificacion_cuenta_motivo'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_motivo'
			},
			type:'Field',
			form:true 
		},
		{
			config: {
				name: 'id_clasificacion',
				fieldLabel: 'Clasificación',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
	                url: '../../sis_kactivos_fijos/control/Clasificacion/ListarClasificacionTree',
	                id: 'id_clasificacion',
	                root: 'datos',
	                sortInfo: {
	                    field: 'orden',
	                    direction: 'ASC'
	                },
	                totalProperty: 'total',
	                fields: ['id_clasificacion', 'clasificacion', 'id_clasificacion_fk'],
	                remoteSort: true,
	                baseParams: {
	                    par_filtro: 'claf.clasificacion'
	                }
	            }),
				valueField: 'id_clasificacion',
				displayField: 'clasificacion',
				gdisplayField: 'desc_clasificacion',
				hiddenName: 'id_clasificacion',
				forceSelection: true,
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
					return String.format('{0}', record.data['desc_clasificacion']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'movtip.nombre',type: 'string'},
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
				filters:{pfiltro:'clacue.estado_reg',type:'string'},
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
				filters:{pfiltro:'clacue.id_usuario_ai',type:'numeric'},
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
				filters:{pfiltro:'clacue.usuario_ai',type:'string'},
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
				filters:{pfiltro:'clacue.fecha_reg',type:'date'},
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
				filters:{pfiltro:'clacue.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Parametrización de Cuentas',
	ActSave:'../../sis_kactivos_fijos/control/ClasificacionCuentaMotivo/insertarClasificacionCuentaMotivo',
	ActDel:'../../sis_kactivos_fijos/control/ClasificacionCuentaMotivo/eliminarClasificacionCuentaMotivo',
	ActList:'../../sis_kactivos_fijos/control/ClasificacionCuentaMotivo/listarClasificacionCuentaMotivo',
	id_store:'id_clasificacion_cuenta_motivo',
	fields: [
		{name:'id_clasificacion_cuenta_motivo', type: 'numeric'},
		{name:'id_movimiento_motivo', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_clasificacion', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'desc_clasificacion', type: 'string'}
		
	],
	sortInfo:{
		field: 'id_clasificacion_cuenta_motivo',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,
	east: {
		url:'../../../sis_contabilidad/vista/relacion_contable/RelacionContableTabla.php',
		title:'Relacion Contable', 
		width:'50%',
		cls:'RelacionContableTabla',
		params:{nombre_tabla:'kaf.tclasificacion',tabla_id:'id_clasificacion'}
	}
})
</script>