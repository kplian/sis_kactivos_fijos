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

		bsubmit: false,
		breset: false,
		
		constructor: function(config) {
			Phx.vista.MovimientoGral.superclass.constructor.call(this, config);
			
			this.addButton('btnAddAF',
	            {
	                text: 'Agregar Activo Fijo',
	                iconCls: 'bchecklist',
	                disabled: false,
	                handler: this.openAF
	            }
	        );
	        this.addButton('btnSaveMov',
	            {
	                text: 'Guardar',
	                iconCls: 'bchecklist',
	                disabled: false //,
	                //handler: this.openMovimientos
	            }
	        );
	        this.initButtons=[this.cmbAF];

	        this.init();
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
				name : 'nro_tramite',
				id:this.idContenedor+'_nro_tramite',
				fieldLabel: 'Num.Trámite',
				disabled: true,
				width: 160
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
		}, {
			config: {
	        name: 'cmb_af',
	        fieldLabel: 'Activos Fijos',
	        typeAhead: false,
	        forceSelection: true,
	        allowBlank: false,
	        emptyText: 'Activo Fijo...',
	        store: new Ext.data.JsonStore({
	            url: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijo',
	            id: 'id_activo_fijo',
	            root: 'datos',
	            sortInfo: {
	                field: 'codigo',
	                direction: 'ASC'
	            },
	            totalProperty: 'total',
	            fields: ['id_activo_fijo','codigo','denominacion','descripcion'],
	            // turn on remote sorting
	            remoteSort: true,
	        }),
	        valueField: 'id_activo_fijo',
			displayField: 'denominacion',
			gdisplayField: 'activo_fijo',
			forceSelection:true,
			typeAhead: false,
			triggerAction: 'all',
			lazyRender:true,
			mode:'remote',
			pageSize:10,
			queryDelay:1000,
			width:155,
			minChars:2
	    },
	    type: 'ComboBox',
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
			           {name: 'id_activo_fijo', type:'numeric'},
			           {name: 'codigo',      type: 'string'},
			           {name: 'nombre',     type: 'string'},
			           {name: 'descripcion',     type: 'string'}
			        ]
			    }),
		        columns: [
		            {
		                id       :'id_activo_fijo',
		                header   : 'ID', 
		                width    : 10, 
		                sortable : true, 
		                dataIndex: 'company',
		                hidden: true
		            },
		            {
		                header   : 'Código', 
		                width    : 90, 
		                sortable : true, 
		                dataIndex: 'codigo'
		            },
		            {
		                header   : 'Nombre', 
		                width    : 190, 
		                sortable : true, 
		                dataIndex: 'nombre'
		            },
		            {
		                header   : 'Descripción', 
		                width    : 300, 
		                sortable : true, 
		                dataIndex: 'descripcion'
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
		        autoExpandColumn: 'id_activo_fijo',
		        height: 350,
		        width: '100%',
		        title: 'Activos Fijos',
		        // config options for stateful behavior
		        stateful: true,
		        stateId: 'grid'
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
		},
		openAF: function(){
	    	Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php',
	            'Activos Fijos',
	            {
	                width:'50%',
	                height:'85%'
	            },
	            {movimiento: true},
	            this.idContenedor,
	            'ActivoFijo'
	        )
	    }
	})
</script>