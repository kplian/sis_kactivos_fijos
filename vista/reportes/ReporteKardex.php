<?php
/**
*@package pXP
*@file ReporteKardex.php
*@author  RCM
*@date 27/07/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
        KAF       ETR           27/07/2017  RCM         Creación del archivo
 #42	KAF 	  ETR 			13/12/2019  RCM 		Modificación de parámetro para reporte
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ReporteKardex=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config;
    	//llama al constructor de la clase padre
		Phx.vista.ReporteKardex.superclass.constructor.call(this,config);
		this.init();
		this.load({
			params:{
				start:0,
				limit:this.tam_pag,
				fecha_desde: this.maestro.paramsRep.fecha_desde,
				fecha_hasta: this.maestro.paramsRep.fecha_hasta,
				id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
				id_moneda: this.maestro.paramsRep.id_moneda,
				desc_moneda: this.maestro.paramsRep.desc_moneda,
				af_estado_mov: this.maestro.paramsRep.af_estado_mov,
				tipo_salida: 'grid',
				id_moneda_dep: this.maestro.paramsRep.id_moneda_dep //#42
			}
		});
		this.addButton('btnSelect', {
            text: 'Reporte',
            iconCls: 'bpdf32',
            disabled: false,
            handler: this.imprimirReporte,
            tooltip: '<b>Imprimir reporte</b><br/>Genera el reporte en el formato para impresión.'
         });

		//Eventos
		//Grid
       	this.grid.on('cellclick', this.abrirEnlace, this);
	},

	Atributos:[
		{
			config:{
				name: 'fecha_mov',
				fieldLabel: 'Fecha',
				gwidth: 80,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'DateField',
			filters:{pfiltro:'mov.fecha_mov',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_mov',
				fieldLabel: 'Proceso',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'num_tramite',
				fieldLabel: 'Nro.Trámite',
				gwidth: 160,
				renderer: function(value,p,record){
					return String.format('{0}','<i class="fa fa-reply-all" aria-hidden="true"></i> '+record.data['num_tramite']);
				}
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},

		{
			config:{
				name: 'codigo',
				fieldLabel: 'Código AF',
				gwidth: 100,
				renderer: function(value,p,record){
					return String.format('{0}','<i class="fa fa-reply-all" aria-hidden="true"></i> '+record.data['codigo']);
				}
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'codigo_ant',
				fieldLabel: 'Código SAP',
				gwidth: 100,
				renderer: function(value,p,record){
					return String.format('{0}','<i class="fa fa-reply-all" aria-hidden="true"></i> '+record.data['codigo']);
				}
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo_ant',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				gwidth: 200
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_compra',
				fieldLabel: 'Fecha Compra',
				gwidth: 100,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'DateField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha Ini.Dep.',
				gwidth: 100,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'DateField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'desc_clasif',
				fieldLabel: 'Clasificación',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'metodo_dep',
				fieldLabel: 'Método Dep.',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'ubicacion',
				fieldLabel: 'Ubicación',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'responsable',
				fieldLabel: 'Responsable actual',
				gwidth: 150
			},
			type:'TextField',
			filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'cargo',
				fieldLabel: 'Cargo',
				gwidth: 150
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'porcentaje_dep',
				fieldLabel: '%Dep. Años',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'moneda',
				fieldLabel: 'Moneda',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'mon.moneda',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		////////
		{
			config:{
				name: 'tipo_cambio_ini',
				fieldLabel: 'T/C Ini.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'mdep.tipo_cambio_ini',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'tipo_cambio_fin',
				fieldLabel: 'T/C Fin',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'mdep.tipo_cambio_fin',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'factor',
				fieldLabel: 'Factor)',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'mdep.factor',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'fecha_dep',
				fieldLabel: 'Fecha Dep.',
				gwidth: 140
			},
			type:'TextField',
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_actualiz_ant',
				fieldLabel: 'Valor Vigente Actualiz.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_monto_actualiz',
				fieldLabel: 'Inc.Actualiz.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_actualiz',
				fieldLabel: 'Valor Actualiz.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'vida_util_ant',
				fieldLabel: 'Vida Útil Ant.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion_acum_ant',
				fieldLabel: 'Dep.Acum.Ant',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'inc_dep_acum',
				fieldLabel: 'Inc.ActualizDep.Acum',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion_acum_actualiz',
				fieldLabel: 'Dep.Acum.Ant.Actualiz.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion',
				fieldLabel: 'Dep.Mes',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion_per',
				fieldLabel: 'Dep.Periodo',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'depreciacion_acum',
				fieldLabel: 'Dep.Acum.',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_vigente',
				fieldLabel: 'Valor Neto',
				gwidth: 140
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		}
	],
	tam_pag:50,
	title:'Kardex Activos Fijos',
	ActList:'../../sis_kactivos_fijos/control/Reportes/reporteKardexAF',
	fields: [

		{name:'codigo',type: 'string'},
		{name:'denominacion',type: 'string'},
		{name:'fecha_compra',type: 'date'},
		{name:'fecha_ini_dep',type: 'date'},
		{name:'estado',type: 'string'},
		{name:'porcentaje_dep',type: 'numeric'},
		{name:'ubicacion',type: 'string'},
		{name:'moneda',type: 'string'},
		{name:'desc_clasif',type: 'string'},
		{name:'metodo_dep',type: 'string'},
		{name:'responsable',type: 'string'},
		{name:'cargo',type: 'string'},
		{name:'fecha_mov',type: 'date'},
		{name:'num_tramite',type: 'string'},
		{name:'desc_mov',type: 'string'},
		{name:'codigo_mov',type: 'string'},
		{name:'id_activo_fijo',type: 'numeric'},
		{name:'id_movimiento',type: 'numeric'},
		{name:'tipo_cambio_ini',type:'numeric'},
		{name:'tipo_cambio_fin',type:'numeric'},
		{name:'factor',type:'numeric'},
		{name:'fecha_dep',type:'numeric'},
		{name:'monto_actualiz_ant',type:'numeric'},
		{name:'inc_monto_actualiz',type:'numeric'},
		{name:'monto_actualiz',type:'numeric'},
		{name:'vida_util_ant',type:'numeric'},
		{name:'depreciacion_acum_ant',type:'numeric'},
		{name:'inc_dep_acum numeric,',type:'numeric'},
		{name:'depreciacion_acum_actualiz',type:'numeric'},
		{name:'depreciacion',type:'numeric'},
		{name:'depreciacion_per',type:'numeric'},
		{name:'depreciacion_acum',type:'numeric'},
		{name:'monto_vigente',type:'numeric'}

	],
	sortInfo:{
		field: 'fecha_mov',
		direction: 'DESC'
	},
	bdel: false,
	bsave: false,
	bnew: false,
	bedit: false,
	imprimirReporte: function(){
	    Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Reportes/reporteKardexAF',
            params:{
            	fecha_desde: this.maestro.paramsRep.fecha_desde,
				fecha_hasta: this.maestro.paramsRep.fecha_hasta,
            	id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
				id_moneda: this.maestro.paramsRep.id_moneda,
				desc_moneda: this.maestro.paramsRep.desc_moneda,
				af_estado_mov: this.maestro.paramsRep.af_estado_mov,
				tipo_salida: 'reporte'
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });
	},
	actualizarBaseParams: function(){
        this.store.setBaseParam('start', 0);
		this.store.setBaseParam('limit', this.tam_pag);
		this.store.setBaseParam('fecha_desde', this.maestro.paramsRep.fecha_desde);
		this.store.setBaseParam('fecha_hasta', this.maestro.paramsRep.fecha_hasta);
		this.store.setBaseParam('id_activo_fijo', this.maestro.paramsRep.id_activo_fijo);
		this.store.setBaseParam('id_moneda', this.maestro.paramsRep.id_moneda);
		this.store.setBaseParam('desc_moneda', this.maestro.paramsRep.desc_moneda);
		this.store.setBaseParam('tipo_salida', 'grid');
	},
	abrirEnlace: function(cell,rowIndex,columnIndex,e){
		if(columnIndex==3){
			//Movimiento
			var data = this.sm.getSelected().data;
			Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/movimiento/MovimientoPrincipal.php',
				'Detalle', {
					width:'90%',
					height:'90%'
			    }, {
			    	lnk_id_movimiento: data.id_movimiento,
			    	link: true
			    },
			    this.idContenedor,
			    'MovimientoPrincipal'
			);

		} else if(columnIndex==4){
			//Activo Fijo
			var data = this.sm.getSelected().data;
			Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php',
				'Detalle', {
					width:'90%',
					height:'90%'
			    }, {
			    	lnk_id_activo_fijo: data.id_activo_fijo,
			    	link: true
			    },
			    this.idContenedor,
			    'ActivoFijo'
			);
		}
	}
})
</script>

