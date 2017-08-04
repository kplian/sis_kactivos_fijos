<?php
/**
*@package pXP
*@file    SolModPresupuesto.php
*@author  Rensi Arteaga Copari 
*@date    30-01-2014
*@description permites subir archivos a la tabla de documento_sol
*/
header("content-type: text/javascript; charset=UTF-8");
?>

<script>
Phx.vista.FormRepCodigoAF=Ext.extend(Phx.frmInterfaz,{
    constructor:function(config)
    {   
    	this.panelResumen = new Ext.Panel({html:'Hola Prueba'});
    	this.Grupos = [{

	                    xtype: 'fieldset',
	                    border: false,
	                    autoScroll: true,
	                    layout: 'form',
	                    items: [],
	                    id_grupo: 0
				               
				    },
				     this.panelResumen
				    ];
				    
        Phx.vista.FormRepCodigoAF.superclass.constructor.call(this,config);
        this.init(); 
        this.iniciarEventos();   
       
        
        
    },
    
    Atributos:[
          
	   	   {
				config:{
					name: 'desde',
					fieldLabel: 'Comprado Desde',
					allowBlank: true,
					format: 'd/m/Y',
					width: 150
				},
				type: 'DateField',
				id_grupo: 0,
				form: true
		  },
		  {
				config:{
					name: 'hasta',
					fieldLabel: 'Compra Hasta',
					allowBlank: true,
					format: 'd/m/Y',
					width: 150
				},
				type: 'DateField',
				id_grupo: 0,
				form: true
		  },
		 {
	        config: {
	            name: 'id_clasificacion',
	            fieldLabel: 'Clasificación',
	            allowBlank: true,
	            emptyText: 'Elija una opción...',
	            store: new Ext.data.JsonStore({
	                url: '../../sis_kactivos_fijos/control/Clasificacion/listarClasificacion',
	                id: 'id_clasificacion',
	                root: 'datos',
	                sortInfo: {
	                    field: 'nombre',
	                    direction: 'ASC'
	                },
	                totalProperty: 'total',
	                fields: ['id_clasificacion', 'nombre', 'codigo', 'clasificacion'],
	                remoteSort: true,
	                baseParams: {
	                    par_filtro: 'cla.nombre#cla.codigo'
	                }
	            }),
	            valueField: 'id_clasificacion',
	            displayField: 'clasificacion',
	            gdisplayField: 'clasificacion',
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
	            renderer: function(value, p, record) {
	                return String.format('{0}', record.data['clasificacion']);
	            }
	        },
	        type: 'ComboBox',
	        id_grupo: 0,
	        filters: {
	            pfiltro: 'cla.nombre',
	            type: 'string'
	        },
	        grid: true,
	        form: false,
	        bottom_filter:true
	    }
    ],
    labelSubmit: '<i class="fa fa-check"></i> Aplicar Filtro',
    title: 'Filtro de mayores',
    // Funcion guardar del formulario
    onSubmit: function(o) {
    	var me = this;
    	if (me.form.getForm().isValid()) {
             var parametros = me.getValForm()
             Phx.CP.loadingShow();
             
             var deptos = this.Cmp.id_deptos.getValue('object');
             console.log('deptos',deptos)
             var sw = 0, codigos = ''
             deptos.forEach(function(entry) {
			    if(sw == 0){
			    	codigos = entry.codigo;
			    }
			    else{
			    	codigos = codigos + ', '+ entry.codigo;
			    }
			    sw = 1;
			});
             
             Ext.Ajax.request({
						url : '../../sis_contabilidad/control/Cuenta/reporteBalanceGeneral',
						params : Ext.apply(parametros,{'codigos': codigos, 'tipo_balance':'general'}),
						success : this.successExport,
						failure : this.conexionFailure,
						timeout : this.timeout,
						scope : this
					})
                    
        }

    }
    
    
})    
</script>