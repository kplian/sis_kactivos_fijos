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
	   			config:{
	   				name : 'id_gestion',
	   				origen : 'GESTION',
	   				fieldLabel : 'Gestion',
	   				allowBlank : false,
	   				resizable:true,
	   				gdisplayField : 'desc_gestion',//mapea al store del grid
	   				width: 380,
	   				gwidth : 100
	       	     },
	   			type : 'ComboRec',
	   			id_grupo : 0,
	   			filters : {	
			        pfiltro : 'ges.gestion',
					type : 'numeric'
				},
	   		   
	   			grid : true,
	   			form : true
	   	},
		{
            config:{
                name: 'id_centro_costo',
                fieldLabel: 'Centro Costo',
                allowBlank: false,
                tinit:false,
                resizable:true,
                origen:'CENTROCOSTO',
                gdisplayField: 'desc_centro_costo',
                width: 380,
                gwidth: 300
            },
            type:'ComboRec',
            filters:{pfiltro:'cc.codigo_cc',type:'string'},
            bottom_filter : true,
            id_grupo:1,
            grid:true,
            form:true
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
				fieldLabel: 'factor',
				allowBlank: false,
				width: 380,
				gwidth: 100,
				maxLength:1
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
				name: 'descripcion',
				fieldLabel: 'descripcion',
				allowBlank: true,
				width: 380,
				gwidth: 100,
				maxLength:300
			},
				type:'TextArea',
				filters:{pfiltro:'tipr.descripcion',type:'string'},
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
		{name:'descripcion', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'id_gestion', type: 'numeric'},
		{name:'id_ot', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_centro_costo', type: 'numeric'},
		{name:'id_proyecto', type: 'numeric'},
		{name:'factor', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},'desc_ot','desc_centro_costo','desc_gestion'
		
	],
	sortInfo:{
		field: 'id_tipo_prorrateo',
		direction: 'ASC'
	},
	bdel:true,
	bsave:false,
	onReloadPage:function(m){
		this.maestro=m;
		this.store.baseParams={id_proyecto:this.maestro.id_proyecto};
		this.load({params:{start:0, limit:50}})
		
	},
	loadValoresIniciales:function(){
		Phx.vista.TipoProrrateo.superclass.loadValoresIniciales.call(this);
		this.getComponente('id_proyecto').setValue(this.maestro.id_proyecto);		
	}
	
	
})
</script>		
		