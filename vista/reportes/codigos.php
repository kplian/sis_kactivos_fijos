<?php
/**
 *@package pXP
 *@file    Codigos.php
 *@author  RCM
 *@date    07-06-2016
 *@description Archivo con la interfaz para generación de reporte
 */
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.Codigos = Ext.extend(Phx.frmInterfaz, {

	Atributos: [{
			config: {
				name: 'tipo_codigo',
				fieldLabel: 'Tipo',
				anchor: '50%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				hiddenName: 'tipo_codigo',
				baseParams: {
					cod_subsistema:'KAF',
					catalogo_tipo:'tactivo_fijo__codigo'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			grid: true,
			form: true
		}, {
			config: {
				name: 'criterio',
				fieldLabel: 'Criterio',
				anchor: '70%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				hiddenName: 'criterio',
				baseParams: {
					cod_subsistema:'KAF',
					catalogo_tipo:'tactivo_fijo__codigo_opcion'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			grid: true,
			form: true
		}, {
			config: {
				name: 'id_clasificacion',
				fieldLabel: 'Clasificación',
				allowBlank: false,
				emptyText: 'Elija la Clasificación',
	            store: new Ext.data.JsonStore({
	                url: '../../sis_kactivos_fijos/control/Clasificacion/listarClasificacion',
	                id: 'id_clasificacion',
	                root: 'datos',
	                fields: ['id_clasificacion','codigo','nombre','met_dep','vida_util','monto_residual','clasificacion'],
	                totalProperty: 'total',
	                sortInfo: {
	                    field: 'codigo',
	                    direction: 'ASC'
	                },
	                baseParams:{
	                    start: 0,
	                    limit: 10,
	                    sort: 'codigo',
	                    dir: 'ASC',
	                    par_filtro:'claf.codigo#claf.nombre'
	                }
	            }),
	            valueField: 'id_clasificacion',
	            displayField: 'clasificacion',
	            gdisplayField: 'clasificacion',
	            mode: 'remote',
	            triggerAction: 'all',
	            lazyRender: true,
	            pageSize: 15
			},
			type: 'ComboBox',
			id_grupo: 0,
			grid: true,
			form: true
        }, {
			config : {
				name : 'id_activo_fijo',
				fieldLabel : 'Activos Fijos',
				allowBlank : false,
				emptyText : 'Activos Fijos...',
				store : new Ext.data.JsonStore({
					url : '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijo',
					id : 'id_activo_fijo',
					root : 'datos',
					sortInfo : {
						field : 'codigo',
						direction : 'ASC'
					},
					totalProperty : 'total',
					fields : ['id_activo_fijo','codigo','denominacion','descripcion'],
					remoteSort : true,
					baseParams : {
						par_filtro : 'af.codigo#af.denominacion'
					}
				}),
				valueField : 'id_activo_fijo',
				hiddenValue: 'id_activo_fijo',
				displayField : 'codigo',
				tpl : '<tpl for="."><div class="x-combo-list-item"><p>Activo: {codigo}</p></div></tpl>',
				hiddenName : 'id_activo_fijo',
				forceSelection : true,
				typeAhead : false,
				triggerAction : 'all',
				lazyRender : true,
				mode : 'remote',
				pageSize : 10,
				queryDelay : 1000,
				anchor : '100%',
				gwidth : 250,
				minChars : 2,
				enableMultiSelect : true
			},
			type : 'AwesomeCombo',
			id_grupo : 1,
			grid : false,
			form : true
		}],
		title : 'Impresion de Codigos de Barras',
		ActSave : '../../sis_kactivos_fijos/control/Reportes/reporteExistencias',
		topBar : true,
		botones : false,
		labelSubmit : 'Imprimir',
		tooltipSubmit : '<b>Imprimir codigos de activos fijos</b>',

		constructor : function(config) {
			Phx.vista.Codigos.superclass.constructor.call(this, config);
			this.init();
			
			this.getComponente('criterio').on('select', function(e, component, index) {
			    if (e.value == 'todos') {
                    this.getComponente('id_clasificacion').disable();
                    this.getComponente('id_activo_fijo').disable();
                    this.getComponente('id_clasificacion').allowBlank=true;
                    this.getComponente('id_activo_fijo').allowBlank=true;
                    
                } else if(e.value == 'clasif') {
                    this.getComponente('id_clasificacion').enable();
                    this.getComponente('id_activo_fijo').disable();
                    this.getComponente('id_clasificacion').allowBlank=false;
                    this.getComponente('id_activo_fijo').allowBlank=true;
                } else {
                	this.getComponente('id_clasificacion').disable();
                    this.getComponente('id_activo_fijo').enable();
                    this.getComponente('id_clasificacion').allowBlank=true;
                    this.getComponente('id_activo_fijo').allowBlank=false;
                }
			}, this);
	   
		},
		tipo : 'reporte',
		clsSubmit : 'bprint',
		Grupos : [{
			layout : 'column',
			items : [{
				xtype : 'fieldset',
				layout : 'form',
				border : true,
				title : 'Generar Reporte',
				bodyStyle : 'padding:0 10px 0;',
				columnWidth : '500px',
				items : [],
				id_grupo : 0,
				collapsible : true
			}]
		}],
		onAlmacenSelect : function () {
			this.Cmp.id_item.store.baseParams.id_almacen = this.maestro.id_almacen;
			this.Cmp.id_item.modificado = true;
		},
		bntClasificacion: function(){
			var data;
			//Valida que el combo de criterio sea por Clasificación
			if(this.Cmp.all_items.getValue()=='Por Clasificacion'){
				Phx.CP.loadWindows('../../../sis_almacenes/vista/clasificacion/BuscarClasificacion.php',
						'Clasificación',
						{
							width:'60%',
							height:'70%'
					    },
					    data,
					    this.idContenedor,
					    'BuscarClasificacion'
				);
			}
		},
		id_clasificacion:'',
		clasificacion:'',
		agregarArgsExtraSubmit: function(){
			//Inicializa el objeto de los argumentos extra
			this.argumentExtraSubmit={};
				//Añade los parámetros extra para mandar por submit
			this.argumentExtraSubmit.id_clasificacion=this.id_clasificacion;
			this.argumentExtraSubmit.almacen=this.Cmp.id_almacen.getRawValue();
		}

});
</script>