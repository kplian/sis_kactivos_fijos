<?php
/**
*@package pXP
*@file gen-MonedaDep.php
*@author  (admin)
*@date 20-04-2017 10:18:50
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MonedaDep=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.MonedaDep.superclass.constructor.call(this,config);
		this.init();
		this.load({params:{start:0, limit:this.tam_pag}})
	},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_moneda_dep'
			},
			type:'Field',
			form:true 
		},
		
		 {
            config:{
                name: 'descripcion',
                fieldLabel: 'Descripción',
                allowBlank: false,
                anchor: '70%',
                gwidth: 100,
                maxLength:150
            },
            type:'TextField',
            filters:{pfiltro:'mod.coddescripcionigo',type:'string'},
            id_grupo:1,
            grid:true,
            form:true
        },
		
		
		{
            config:{
                name:'id_moneda',
                origen:'MONEDA',
                allowBlank:false,
                fieldLabel:'Moneda',
                gdisplayField:'desc_moneda',//mapea al store del grid
                gwidth:50,
                baseParams:{filtrar:'no'},
                renderer:function (value, p, record){return String.format('{0}', record.data['desc_moneda']);}
             },
            type:'ComboRec',
            id_grupo:1,
            filters:{   
                pfiltro:'mon.codigo',
                type:'string'
            },
            grid:true,
            form:true
         },	
         
         {
            config:{
                name:'id_moneda_act',
                qtip:'Indica con moneda se actuliza',
                origen:'MONEDA',
                allowBlank:true,
                fieldLabel:'Moneda',
                gdisplayField:'desc_moneda_act',//mapea al store del grid
                gwidth:50,
                baseParams:{filtrar:'no'},
                renderer:function (value, p, record){return String.format('{0}', record.data['desc_moneda_act']);}
             },
            type:'ComboRec',
            id_grupo:1,
            filters:{   
                pfiltro:'mona.codigo',
                type:'string'
            },
            grid:true,
            form:true
        },	
		{
            config:{
                name: 'actualizar',
                qtip:'Incica si los valores de esta moneda se tienen  que actualizar (AITB)',
                fieldLabel: 'Actualizar?',
                allowBlank: false,
                anchor: '40%',
                gwidth: 50,
                maxLength:2,
                emptyText:'si/no...',                   
                typeAhead: true,
                triggerAction: 'all',
                lazyRender:true,
                mode: 'local',
                store:['si','no']
            },
            type:'ComboBox',
            id_grupo:1,
            filters:{   
                         type: 'list',
                         pfiltro:'mod.actualizar',
                         options: ['si','no'],  
                    },
            grid:true,
            form:true
        },
		
		 {
            config:{
                name: 'contabilizar',
                qtip:'Solo una de las configuracion se peude seleccionar apra realizar la contabilizacion (tiene que ser la moneda base)',
                fieldLabel: 'Contabilizar?',
                allowBlank: false,
                anchor: '40%',
                gwidth: 50,
                maxLength:2,
                emptyText:'si/no...',                   
                typeAhead: true,
                triggerAction: 'all',
                lazyRender:true,
                mode: 'local',
                store:['si','no']
            },
            type:'ComboBox',
            id_grupo:1,
            filters:{   
                         type: 'list',
                         pfiltro:'mod.contabilizar',
                         options: ['si','no'],  
                    },
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
				filters:{pfiltro:'mod.estado_reg',type:'string'},
				id_grupo:1,
				grid:true,
				form:false
		},
		
		{
			config:{
				name: 'id_usuario_ai',
				fieldLabel: '',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'mod.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
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
				filters:{pfiltro:'mod.usuario_ai',type:'string'},
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
				filters:{pfiltro:'mod.fecha_reg',type:'date'},
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
				filters:{pfiltro:'mod.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Configuracion',
	ActSave:'../../sis_kactivos_fijos/control/MonedaDep/insertarMonedaDep',
	ActDel:'../../sis_kactivos_fijos/control/MonedaDep/eliminarMonedaDep',
	ActList:'../../sis_kactivos_fijos/control/MonedaDep/listarMonedaDep',
	id_store:'id_moneda_dep',
	fields: [
		{name:'id_moneda_dep', type: 'numeric'},
		{name:'id_moneda_act', type: 'numeric'},
		{name:'actualizar', type: 'string'},
		{name:'contabilizar', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'id_moneda', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},'desc_moneda', 'desc_moneda_act','descripcion'
		
	],
	sortInfo:{
		field: 'id_moneda_dep',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true
	}
)
</script>
		
		