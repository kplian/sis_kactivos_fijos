<?php
/**
*@package pXP
*@file MovimientoGral.php
*@author  RCM
*@date 17/11/2015
*@description Archivo para la generación de Movimientos de activos fijos
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
	Phx.vista.MovimientoGral = Ext.extend(Phx.frmInterfaz, {
		
		constructor: function(config) {
			Phx.vista.MovimientoGral.superclass.constructor.call(this, config);
			this.init();
			//Ext.getCmp('tree_af_clasif_mov').getRootNode().expand(true);
			Ext.getCmp('tree_af_clasif_mov').loader.on('beforeload', this.onBeforeLoad, this);
			//Ext.getCmp('tree_af_clasif_mov').root.reload();
			//Ext.getCmp('tree_af_clasif_mov').root.expand(false,false);
		},
		
		Atributos : [{
	        //configuracion del componente
	        config: {
	            labelSeparator: '',
	            inputType: 'hidden',
	            name: 'id_movimiento'
	        },
	        type: 'Field',
	        form: true
	    },
		{
			config : {
				name : 'movimiento',
				id:this.idContenedor+'_movimiento',
				fieldLabel: 'Movimiento',
				disabled: true,
				width: 250
			},
			type : 'Field',
			id_grupo : 0,
			form : true
		},
		{
			config : {
				name : 'fecha_ini',
				id:this.idContenedor+'_fecha_ini',
				fieldLabel: 'Fecha',
				allowBlank: false,
				format: 'd/m/Y',
				renderer: function(value, p, record) {
					return value ? value.dateFormat('d/m/Y h:i:s') : ''
				}
			},
			type: 'DateField',
			id_grupo: 0,
			form: true
		},
		{
			config: {
				name: 'glosa',
				id: this.idContenedor+'_glosa',
				fieldLabel: 'Glosa',
				allowBlank: false,
				width:'100%'
			},
			type: 'TextArea',
			id_grupo: 0,
			form: true
		}],
		title : 'Kardex x Item',
		ActSave : '../../sis_almacenes/control/Reportes/listarKardexItem',
		topBar : true,
		botones : false,
		labelSubmit : 'Generar',
		tooltipSubmit : '<b>Generar Reporte de Kardex x Item</b>',
		tipo : 'reporte',
		clsSubmit : 'bprint',
		Grupos: [{
			xtype: 'fieldset',
			layout: 'form',
			border: false,
			items: [],
			id_grupo: 0
		},{
			layout: 'hbox',
			border: false,
			defaults: {flex: 10},
			items: [
				new Ext.grid.GridPanel({
		        store: new Ext.data.ArrayStore({
			        fields: [
			           {name: 'company'},
			           {name: 'price',      type: 'float'},
			           {name: 'change',     type: 'float'},
			           {name: 'pctChange',  type: 'float'},
			           {name: 'lastChange', type: 'date', dateFormat: 'n/j h:ia'}
			        ]
			    }),
		        columns: [
		            {
		                id       :'company',
		                header   : 'Company', 
		                width    : 160, 
		                sortable : true, 
		                dataIndex: 'company'
		            },
		            {
		                header   : 'Price', 
		                width    : 75, 
		                sortable : true, 
		                renderer : 'usMoney', 
		                dataIndex: 'price'
		            },
		            {
		                header   : 'Change', 
		                width    : 75, 
		                sortable : true, 
		                dataIndex: 'change'
		            },
		            {
		                header   : '% Change', 
		                width    : 75, 
		                sortable : true, 
		                dataIndex: 'pctChange'
		            },
		            {
		                header   : 'Last Updated', 
		                width    : 85, 
		                sortable : true, 
		                renderer : Ext.util.Format.dateRenderer('m/d/Y'), 
		                dataIndex: 'lastChange'
		            },
		            {
		                xtype: 'actioncolumn',
		                width: 50,
		                items: [{
		                    icon   : '../shared/icons/fam/delete.gif',  // Use a URL in the icon config
		                    tooltip: 'Sell stock',
		                    handler: function(grid, rowIndex, colIndex) {
		                        var rec = store.getAt(rowIndex);
		                        alert("Sell " + rec.get('company'));
		                    }
		                }, {
		                    getClass: function(v, meta, rec) {          // Or return a class from a function
		                        if (rec.get('change') < 0) {
		                            this.items[1].tooltip = 'Do not buy!';
		                            return 'alert-col';
		                        } else {
		                            this.items[1].tooltip = 'Buy stock';
		                            return 'buy-col';
		                        }
		                    },
		                    handler: function(grid, rowIndex, colIndex) {
		                        var rec = store.getAt(rowIndex);
		                        alert("Buy " + rec.get('company'));
		                    }
		                }]
		            }
		        ],
		        stripeRows: true,
		        autoExpandColumn: 'company',
		        height: 350,
		        width: 600,
		        title: 'Activos Fijos',
		        // config options for stateful behavior
		        stateful: true,
		        stateId: 'grid'
		    }),

			new Ext.tree.TreePanel({
				id: 'tree_af_clasif_mov',
				region : 'center',
				scale : 'large',
				singleClickExpand : true,
				// collapsed:true,
				rootVisible: true,
				root: new Ext.tree.AsyncTreeNode({
					text : 'Activos Fijos',
					draggable : false,
					allowDelete : false,
					allowEdit : false,
					collapsed : true,
					expanded : true,
					expandable : true,
					disabled : false,
					hidden : false,
					id : 'id'
				}),
				animate : true,
				singleExpand : false,
				autoScroll : true,
				loader :  new Ext.tree.TreeLoader({
					url : '../../sis_kactivos_fijos/control/Clasificacion/listarClasificacionArb',
					baseParams: {
						start: 0,
						limit: 10,
						sort: 'codigo',
						dir: 'ASC',
						id_clasificacion_fk: 'null'
					},
					clearOnLoad : true
				}),
				enableDD : true,
				containerScroll : true,
				border: false,
				dropConfig: this.dropConfig,
				tbar: this.tbar
			})

			],
			id_grupo: 1
		}],
		onSubmit: function(){
			if (this.form.getForm().isValid()) {

			}
		},
		desc_item:'',
		onBeforeLoad : function(treeLoader, node) {
			treeLoader.baseParams['id_clasificacion'] = node.attributes['id_clasificacion'];
		}

	})
</script>