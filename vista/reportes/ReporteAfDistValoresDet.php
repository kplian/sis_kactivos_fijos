<?php
/**
*@package pXP
*@file ReporteAfDistValoresDet.php
*@author  RCM
*@date 22/07/2019
*@description Detalle del reporte de activos fijos con Distribución de Valores

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #20    KAF       ETR           22/07/2019  RCM         Creación
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteAfDistValoresDet = Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteAfDistValoresDet.superclass.constructor.call(this,config);
		this.init();
		this.bloquearMenus();
	},

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_af_especial'
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
					name: 'id_moneda'
			},
			type:'Field',
			form:true
		},
		{
			config:{
				name: 'tipo',
				fieldLabel: 'Tipo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:100
			},
			type:'TextField',
			filters:{pfiltro:'mafe.tipo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'codigo_activo_dest',
				fieldLabel: 'Activo Fijo Destino',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'af1.codigo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'denominacion_activo_dest',
				fieldLabel: 'Denominación Activo Fijo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'af1.denominacion', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado Activo Fijo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'af1.estado', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'codigo_almacen',
				fieldLabel: 'Almacén',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'al.codigo', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'nombre_almacen',
				fieldLabel: 'Nombre Almacén',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'al.nombre', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'porcentaje',
				fieldLabel: 'Porcentaje',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 1000
			},
			type: 'TextField',
			filters: {pfiltro: 'mafe.porcentaje', type: 'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'monto_actualiz',
				fieldLabel: 'Monto Activo Fijo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 1000
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config:{
				name: 'depreciacion_acum',
				fieldLabel: 'Depreciación Acum.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				maxLength: 1000
			},
			type: 'TextField',
			id_grupo: 1,
			grid: true,
			form: true
		}
	],
	tam_pag: 50,
	title: 'Detalle',
	ActList: '../../sis_kactivos_fijos/control/Reportes/reporteAfDistValoresDetalle',
	id_store: 'id_movimiento_af_especial',
	fields: [
		{name: 'id_movimiento_af_especial', type: 'numeric'},
		{name: 'id_movimiento_af', type: 'numeric'},
		{name: 'id_moneda', type: 'numeric'},
		{name: 'fecha_mov', type: 'date', dateFormat: 'Y-m-d'},
		{name: 'num_tramite', type: 'string'},
		{name: 'glosa', type: 'string'},
		{name: 'estado', type: 'string'},
		{name: 'codigo_activo_origen', type: 'string'},
		{name: 'denominacion_activo_origen', type: 'string'},
		{name: 'tipo', type: 'string'},
		{name: 'codigo_activo_dest', type: 'string'},
		{name: 'denominacion_activo_dest', type: 'string'},
		{name: 'estado', type: 'string'},
		{name: 'codigo_almacen', type: 'string'},
		{name: 'nombre_almacen', type: 'string'},
		{name: 'porcentaje', type: 'numeric'},
		{name: 'fecha', type: 'date', dateFormat: 'Y-m-d'},
		{name: 'monto_actualiz', type: 'numeric'},
		{name: 'depreciacion_acum', type: 'numeric'},
	],
	sortInfo:{
		field: 'mafe.id_movimiento_af_especial',
		direction: 'ASC'
	},
	bdel: false,
	bsave: false,
	bedit: false,
	bnew: false,

	onReloadPage: function(m) {
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_movimiento_af;
		this.Atributos[2].valorInicial = this.maestro.id_moneda;

		//Define the filter to apply for activos fijod drop down
		this.store.baseParams = {
			id_movimiento_af: this.maestro.id_movimiento_af,
			id_moneda: this.maestro.id_moneda
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