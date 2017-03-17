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
    ActSave:'../../sis_kactivos_fijos/control/ActivoFijo/impVariosCodigoActivoFijo',
    tipo: 'reporte',
    topBar: true,
    constructor:function(config)
    {   
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
					width: 200
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
					width: 200
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
	            hiddenName: 'id_clasificacion',
	            forceSelection: true,
	            typeAhead: false,
	            triggerAction: 'all',
	            lazyRender: true,
	            mode: 'remote',
	            pageSize: 15,
	            queryDelay: 1000,
	            width: 200,
	            minChars: 2
	        },
	        type: 'ComboBox'
	    }
    ],
    labelSubmit: '<i class="fa fa-check"></i> Aplicar Filtro',
    title: 'Filtro de mayores'
    
    
})    
</script>