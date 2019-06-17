<?php
/**
*@package pXP
*@file gen-ActivoFijoCc.php
*@author  (admin)
*@date 10-05-2019 11:30:44
*@description 
 * */

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoCc=Ext.extend(Phx.gridInterfaz,{
   

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.ActivoFijoCc.superclass.constructor.call(this,config);
		this.init();
		//this.bloquearMenus();
		var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData()
        if(dataPadre){
            this.onEnablePanel(this, dataPadre);
        } else {
           this.bloquearMenus();
        }
        
        
        
        		
	},
		
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo_cc'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_activo_fijo'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'mes',
				fieldLabel: 'Mes',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y', 
				renderer:function (value,p,record){return value?value.dateFormat('m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'afccosto.mes',type:'date'},
				id_grupo:1,
				grid:true,
				form:true
		},
        {
	   		config: {
   				name:'id_centro_costo',
   				qtip: 'Tipo de centro de costo',
   				origen:'CENTROCOSTO',
   				fieldLabel:'Centro de Costo',
   				gdisplayField:'desc_tipo_cc',//mapea al store del grid
   				anchor: '100%',
   				listWidth: 0,
   				gwidth:200,
   				allowBlank: false
   				
      		},
   			type:'ComboRec',
   			id_grupo:1,
   			filters:{pfiltro:'cc.codigo#cc.descripcion',type:'string'},
   		    grid:true,
   			form:true,
   			bottom_filter: true
	    },
	    
		{
			config:{
				name: 'cantidad_horas',
				fieldLabel: 'Horas (1 - 720)',
				allowBlank: false,
				width: 380,
				gwidth: 100,
				maxValue:720,
				minValue:0,
				allowDecimals: true
			},
				type:'NumberField',
				valorInicial: 1,
				filters:{pfiltro:'afccosto.cantidad_horas',type:'numeric'},
				id_grupo:1,
				grid:true,
				form:true
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
				filters:{pfiltro:'tipr.estado_reg',type:'string'},
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
				name: 'usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:300
			},
				type:'TextField',
				filters:{pfiltro:'tipr.usuario_ai',type:'string'},
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
				filters:{pfiltro:'tipr.fecha_reg',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		},
		{
			config:{
				name: 'id_usuario_ai',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'tipr.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
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
				filters:{pfiltro:'tipr.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
		
	],
	tam_pag:50,	
	title:'Centro de Costo',
	ActSave:'../../sis_kactivos_fijos/control/ActivoFijoCc/insertarActivoFijoCc',
	ActDel:'../../sis_kactivos_fijos/control/ActivoFijoCc/eliminarActivoFijoCc',
	ActList:'../../sis_kactivos_fijos/control/ActivoFijoCc/listarActivoFijoCc',
	id_store:'id_activo_fijo_cc',
	fields: [
		{name:'id_activo_fijo_cc', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_centro_costo', type: 'numeric'},
		{name:'mes', type: 'date',dateFormat:'Y-m-d'},
		{name:'cantidad_horas', type: 'numeric'},
		
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		
		
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'desc_tipo_cc', type: 'string'}
		
		
	],
	sortInfo:{
		field: 'id_centro_costo',
		direction: 'ASC'
	},
	bdel:true,
	bsave:false,
	onReloadPage:function(m){
		this.maestro=m;
		//this.store.baseParams={id_proyecto:this.maestro.id_proyecto};
		this.store.baseParams={id_activo_fijo:this.maestro.id_activo_fijo};
		this.load({params:{start:0, limit:50}})
		
	},
	loadValoresIniciales:function(){
		Phx.vista.ActivoFijoCc.superclass.loadValoresIniciales.call(this);
		//this.getComponente('id_proyecto').setValue(this.maestro.id_proyecto);		
		this.getComponente('id_activo_fijo').setValue(this.maestro.id_activo_fijo);		
	},
	onButtonSubirCC: function(rec)
    {
        
        Phx.CP.loadWindows
        (
            '../../../sis_kactivos_fijos/vista/activo_fijo_cc/ImportarCentroCosto.php',
            'Importar CC desde Excel',
            {
                modal: true,
                width: 450,
                height: 150
            },
            {'id_activo_fijo':1},
            this.idContenedor,
            'ImportarCentroCosto'
        );
	}
	
	
	
})
</script>		
		