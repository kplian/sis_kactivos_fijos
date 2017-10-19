<?php
/**
*@package pXP
*@file gen-TipoProrrateo.php
*@author  (admin)
*@date 02-05-2017 08:30:44
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.TipoProrrateo=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.TipoProrrateo.superclass.constructor.call(this,config);
		this.init();
		this.bloquearMenus();
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
					name: 'id_tipo_prorrateo'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_tipo_prorrateo'
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
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_proyecto'
			},
			type:'Field',
			form:true 
		},
        {
	   		config: {
   				name:'id_tipo_cc',
   				qtip: 'Tipo de centro de costo',
   				origen:'TIPOCC',
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
                    name:'id_ot',
                    fieldLabel: 'Orden Trabajo',
                    sysorigen:'sis_contabilidad',
                    gdisplayField : 'desc_ot',
	       		    origen:'OT',
                    allowBlank:true,
                    gwidth:200,
                    width: 380,
   				    listWidth: 380
            
            },
            type:'ComboRec',
            id_grupo:0,
            filters:{pfiltro:'ot.motivo_orden#ot.desc_orden',type:'string'},
            grid:true,
            form:true
        },
		{
			config:{
				name: 'factor',
				fieldLabel: 'Prorrateo (0 - 1)',
				allowBlank: false,
				width: 380,
				gwidth: 100,
				maxValue:1,
				minValue:0,
				allowDecimals: true
			},
				type:'NumberField',
				valorInicial: 1,
				filters:{pfiltro:'tipr.factor',type:'numeric'},
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
	title:'Tipo Prorrateo',
	ActSave:'../../sis_kactivos_fijos/control/TipoProrrateo/insertarTipoProrrateo',
	ActDel:'../../sis_kactivos_fijos/control/TipoProrrateo/eliminarTipoProrrateo',
	ActList:'../../sis_kactivos_fijos/control/TipoProrrateo/listarTipoProrrateo',
	id_store:'id_tipo_prorrateo',
	fields: [
		{name:'id_tipo_prorrateo', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_ot', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_tipo_cc', type: 'numeric'},
		{name:'id_proyecto', type: 'numeric'},
		{name:'factor', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'desc_ot', type: 'string'},
		{name:'desc_tipo_cc', type: 'string'}
		
	],
	sortInfo:{
		field: 'id_tipo_prorrateo',
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
		Phx.vista.TipoProrrateo.superclass.loadValoresIniciales.call(this);
		//this.getComponente('id_proyecto').setValue(this.maestro.id_proyecto);		
		this.getComponente('id_activo_fijo').setValue(this.maestro.id_activo_fijo);		
	}
	
	
})
</script>		
		