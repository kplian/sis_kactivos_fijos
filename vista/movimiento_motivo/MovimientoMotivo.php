<?php
/**
*@package pXP
*@file gen-MovimientoMotivo.php
*@author  (admin)
*@date 18-03-2016 07:25:59
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoMotivo=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.MovimientoMotivo.superclass.constructor.call(this,config);
		this.init();
		//this.load({params:{start:0, limit:this.tam_pag}})
		//Add report button
        this.addButton('btnCuenta',{
            text:'Cuentas Contables',
            //iconCls: 'bpdf32',
            disabled: true,
            handler: this.onButtonCuenta,
            tooltip: '<b>Cuentas Contables</b><br/>Configuración de las cuentas contables por Proceso y Clasificación'
       	});
	},

	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_motivo'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
				labelSeparator:'',
				inputType:'hidden',
				name: 'id_cat_movimiento'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'motivo',
				fieldLabel: 'Motivo',
				allowBlank: false,
				anchor: '80%',
				gwidth: 200,
				maxLength:100
			},
				type:'TextField',
				filters:{pfiltro:'mmot.motivo',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'plantilla_cbte',
				fieldLabel: 'Plantilla Comprobante',
				qtip: 'Código de la Plantilla de Comprobante con el que se generará el comprobante por el motivo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 200,
				maxLength:100
			},
				type:'TextField',
				filters:{pfiltro:'mmot.plantilla_cbte',type:'string'},
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
				filters:{pfiltro:'mmot.estado_reg',type:'string'},
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
				filters:{pfiltro:'mmot.id_usuario_ai',type:'numeric'},
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
				filters:{pfiltro:'mmot.usuario_ai',type:'string'},
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
				filters:{pfiltro:'mmot.fecha_reg',type:'date'},
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
				filters:{pfiltro:'mmot.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	
	tam_pag:50,	
	title:'Motivo',
	ActSave:'../../sis_kactivos_fijos/control/MovimientoMotivo/insertarMovimientoMotivo',
	ActDel:'../../sis_kactivos_fijos/control/MovimientoMotivo/eliminarMovimientoMotivo',
	ActList:'../../sis_kactivos_fijos/control/MovimientoMotivo/listarMovimientoMotivo',
	id_store:'id_movimiento_motivo',
	fields: [
		{name:'id_movimiento_motivo', type: 'numeric'},
		{name:'id_cat_movimiento', type: 'numeric'},
		{name:'motivo', type: 'string'},
		{name:'estado_reg', type: 'string'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'movimiento', type: 'string'},
		{name:'plantilla_cbte', type: 'string'}
	],
	sortInfo:{
		field: 'id_movimiento_motivo',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,
	onReloadPage: function(m){
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_catalogo;

		this.store.baseParams = {
			id_cat_movimiento: this.maestro.id_catalogo
		};
		this.load({
			params: {
				start: 0,
				limit: 50
			}
		});
	},
	onButtonCuenta: function(){
	    var rec=this.sm.getSelected();
		Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/clasificacion_cuenta_motivo/ClasificacionCuentaMotivo.php',
			'Detalle', {
				width:'70%',
				height:'70%'
		    },
		    rec.data,
		    this.idContenedor,
		    'ClasificacionCuentaMotivo'
		);
	},
	liberaMenu:function(){
        var tb = Phx.vista.MovimientoMotivo.superclass.liberaMenu.call(this);
        if(tb){
            this.getBoton('btnCuenta').disable();
        }
       return tb
    },
    preparaMenu:function(n){
    	var tb = Phx.vista.MovimientoMotivo.superclass.preparaMenu.call(this);
      	var data = this.getSelectedData();
      	var tb = this.tbar;

        this.getBoton('btnCuenta').enable();        

        return tb;
    }

});
</script>
		
		