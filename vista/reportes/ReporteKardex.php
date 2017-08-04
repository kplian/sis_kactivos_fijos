<?php
/**
*@package pXP
*@file ReporteKardex.php
*@author  RCM
*@date 27/07/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
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
				tipo_salida: 'grid'
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
			filters:{pfiltro:'depaf.codigo',type:'string'},
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
				fieldLabel: 'Nro.',
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
			filters:{pfiltro:'depaf.codigo',type:'string'},
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
				name: 'ufv_fecha_compra',
				fieldLabel: 'UFV (fecha compra)',
				gwidth: 100,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'DateField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:false,
			form:true
		},
		{
			config:{
				name: 'ufv_mov',
				fieldLabel: 'UFV (Fecha Proc.)',
				gwidth: 100,
				format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
			},
			type:'NumberField',
			id_grupo:1,
			grid:false,
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
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name: 'monto_compra_orig',
				fieldLabel: 'Monto Compra Orig.(87%)',
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
				name: 'monto_compra_orig_100',
				fieldLabel: 'Monto Compra Orig.(100%)',
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
				name: 'valor_actual',
				fieldLabel: 'Valor Actual',
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
				name: 'vida_util_original',
				fieldLabel: 'VU. Orig.',
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
				name: 'vida_util_residual',
				fieldLabel: 'VU. Res.',
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
				name: 'nro_cbte_asociado',
				fieldLabel: 'Cbte.Asoc.',
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
				name: 'fecha_cbte_asociado',
				fieldLabel: 'Fecha Cbte.Asoc.',
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
				name: 'cod_clasif',
				fieldLabel: 'Cod.Clasif',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'depaf.codigo',type:'string'},
			id_grupo:1,
			grid: false,
			form:true
		}
	],
	tam_pag:50,	
	title:'Kardex Activos Fijos',
	ActList:'../../sis_kactivos_fijos/control/Reportes/reporteKardexAF',
	fields: [
		{name:'codigo',type: 'string'},
		{name:'denominacion',type: 'string'},
		{name:'fecha_compra',type: 'date',dateFormat: 'Y-m-d'},
		{name:'fecha_ini_dep',type: 'date',dateFormat: 'Y-m-d'},
		{name:'estado',type: 'string'},
		{name:'vida_util_original',type: 'numeric'},
		{name:'porcentaje_dep',type: 'numeric'},
		{name:'ubicacion',type: 'string'},
		{name:'monto_compra_orig',type: 'numeric'},
		{name:'moneda',type: 'string'},
		{name:'nro_cbte_asociado',type: 'string'},
		{name:'fecha_cbte_asociado',type: 'date',dateFormat: 'Y-m-d'},
		{name:'monto_compra_orig_100',type: 'numeric'},
		{name:'valor_actual',type: 'numeric'},
		{name:'vida_util_residual',type: 'numeric'},
		{name:'cod_clasif',type: 'string'},
		{name:'desc_clasif',type: 'string'},
		{name:'metodo_dep',type: 'string'},
		{name:'ufv_fecha_compra',type: 'date'},
		{name:'responsable',type: 'string'},
		{name:'cargo',type: 'string'},
		{name:'fecha_mov',type: 'date',dateFormat: 'Y-m-d'},
		{name:'num_tramite',type: 'string'},
		{name:'desc_mov',type: 'string'},
		{name:'ufv_mov',type: 'date'},
		{name:'id_activo_fijo',type: 'numeric'},
		{name:'id_movimiento',type: 'numeric'}
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
		
		