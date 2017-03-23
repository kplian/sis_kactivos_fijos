<?php
/**
*@package pXP
*@file gen-MovimientoAf.php
*@author  (admin)
*@date 18-03-2016 05:34:15
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoAf=Ext.extend(Phx.gridInterfaz,{

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.MovimientoAf.superclass.constructor.call(this,config);
		this.init();
		this.grid.getTopToolbar().disable();
		this.grid.getBottomToolbar().disable();

       	//Add report button
        this.addButton('btnDetDep',{
            text :'Depreciacion',
            iconCls : 'bpdf32',
            disabled: true,
            handler : this.onButtonDetDep,
            tooltip : '<b>Depreciacion</b><br/>Detalle del calculo de depreciacion'
       	});
	},
	filter:{},
			
	Atributos:[
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento_af'
			},
			type:'Field',
			form:true 
		},
		{
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_movimiento'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
				name: 'cod_af',
				fieldLabel: 'Codigo',
				gwidth: 130,
				maxLength:10
			},
			type:'TextField',
			filters:{pfiltro:'af.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config: {
				name: 'id_activo_fijo',
				fieldLabel: 'Activo Fijo',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijo',
					id: 'id_activo_fijo',
					root: 'datos',
					sortInfo: {
						field: 'denominacion',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_activo_fijo', 'denominacion', 'codigo','descripcion'],
					remoteSort: true,
					baseParams: {par_filtro: 'afij.denominacion#afij.codigo#afij.descripcion'}
				}),
				valueField: 'id_activo_fijo',
				displayField: 'denominacion',
				gdisplayField: 'denominacion',
				hiddenName: 'id_activo_fijo',
				forceSelection: true,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '100%',
				gwidth: 300,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['denominacion']);
				},
				tpl : '<tpl for="."><div class="x-combo-list-item"><p><b>Codigo:</b> {codigo}</p><p><b>Activo Fijo:</b> {denominacion}</p><p><b>Descripcion:</b> {descripcion}</p></div></tpl>',
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'af.denominacion',type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_cat_estado_fun',
				fieldLabel: 'Detalle',
				anchor: '95%',
				tinit: false,
				allowBlank: true,
				origen: 'CATALOGO',
				gdisplayField: 'estado_fun',
				hiddenName: 'id_cat_estado_fun',
				gwidth: 180,
				baseParams:{
						cod_subsistema:'KAF',
						catalogo_tipo:'tactivo_fijo__id_cat_estado_fun'
				},
				renderer: function (value,p,record) {
					var resp;
					if(this.maestro=='reval'||this.maestro=='incdec'){
						resp='<tpl for="."><div class="x-combo-list-item"><p><b>Estado Funcional: </b> '+record.data['estado_fun']+'</p><p><b>Nuevo Importe: </b> <font color="blue">'+record.data['importe']+'</font></p><p><b>Nueva Vida util: </b>'+record.data['vida_util']+'</p></div></tpl>';
					} else {
						resp='<tpl for="."><div class="x-combo-list-item"><p><b>Estado Funcional: </b> '+record.data['estado_fun']+'</p></div></tpl>';
					}
					return resp;
				},
				valueField: 'id_catalogo'
			},
			type: 'ComboRec',
			id_grupo: 1,
			filters:{pfiltro:'cat.descripcion',type:'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'id_movimiento_motivo',
				fieldLabel: 'Motivo',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/MovimientoMotivo/listarMovimientoMotivo',
					id: 'id_movimiento_motivo',
					root: 'datos',
					sortInfo: {
						field: 'motivo',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_movimiento_motivo', 'motivo'],
					remoteSort: true,
					baseParams: {par_filtro: 'mmot.motivo'}
				}),
				valueField: 'id_movimiento_motivo',
				displayField: 'motivo',
				gdisplayField: 'motivo',
				hiddenName: 'id_movimiento_motivo',
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
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['motivo']);
				},hidden:true
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'mmot.motivo',type: 'string'},
			grid: false,
			form: true
		},
		{
			config:{
				name: 'importe',
				fieldLabel: 'Importe',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength:1179650
			},
			type:'NumberField',
			filters:{pfiltro:'movaf.importe',type:'numeric'},
			id_grupo:1,
			grid:false,
			form:true
		},
		{
			config:{
				name: 'respuesta',
				fieldLabel: 'Respuesta',
				allowBlank: true,
				anchor: '100%',
				gwidth: 200,
				maxLength:-5
			},
			type:'TextField',
			filters:{pfiltro:'movaf.respuesta',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 85,
				maxLength:10
			},
			type:'TextField',
			filters:{pfiltro:'movaf.estado_reg',type:'string'},
			id_grupo:1,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'vida_util',
				fieldLabel: 'Vida util',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength:4
			},
			type:'NumberField',
			filters:{pfiltro:'movaf.vida_util',type:'numeric'},
			id_grupo:1,
			grid:false,
			form:true
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
				filters:{pfiltro:'movaf.fecha_reg',type:'date'},
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
				filters:{pfiltro:'movaf.usuario_ai',type:'string'},
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
				name: 'id_usuario_ai',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:4
			},
				type:'Field',
				filters:{pfiltro:'movaf.id_usuario_ai',type:'numeric'},
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
				filters:{pfiltro:'movaf.fecha_mod',type:'date'},
				id_grupo:1,
				grid:true,
				form:false
		}
	],
	tam_pag:50,	
	title:'Detalle Movimiento',
	ActSave:'../../sis_kactivos_fijos/control/MovimientoAf/insertarMovimientoAf',
	ActDel:'../../sis_kactivos_fijos/control/MovimientoAf/eliminarMovimientoAf',
	ActList:'../../sis_kactivos_fijos/control/MovimientoAf/listarMovimientoAf',
	id_store:'id_movimiento_af',
	fields: [
		{name:'id_movimiento_af', type: 'numeric'},
		{name:'id_movimiento', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_cat_estado_fun', type: 'numeric'},
		{name:'id_movimiento_motivo', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'importe', type: 'numeric'},
		{name:'respuesta', type: 'string'},
		{name:'vida_util', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'cod_af', type: 'string'},
		{name:'denominacion', type: 'string'},
		{name:'estado_fun', type: 'string'},
		{name:'motivo', type: 'string'}
		
	],
	sortInfo:{
		field: 'id_movimiento_af',
		direction: 'ASC'
	},
	bdel:true,
	bsave:true,

	rowExpander: new Ext.ux.grid.RowExpander({
	        tpl : new Ext.Template(
	        	'<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Importe:&nbsp;&nbsp;</b> {importe}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Vida Util:&nbsp;&nbsp;</b> {vida_util}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Motivo:&nbsp;&nbsp;</b> {motivo}</p>','<hr>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Registro:&nbsp;&nbsp;</b> {usr_reg}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Registro:&nbsp;&nbsp;</b> {fecha_reg}</p>',	       
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Modificación:&nbsp;&nbsp;</b> {usr_mod}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Modificación:&nbsp;&nbsp;</b> {fecha_mod}</p>'
	        )
    }),

	onReloadPage : function(m) {
		this.maestro = m;
		this.Atributos[1].valorInicial = this.maestro.id_movimiento;
		
		//Define the filter to apply for activos fijod drop down
		this.Cmp.id_activo_fijo.store.baseParams = {
		"start":"0","limit":"15","sort":"denominacion","dir":"ASC","par_filtro":"afij.denominacion#afij.codigo#afij.descripcion"
		};
		//este 
		Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{codMov:this.maestro.cod_movimiento});
		this.Cmp.id_activo_fijo.modificado=true;
		
		//Setea parametros de filtro para el combo de motivos
		this.Cmp.id_movimiento_motivo.store.baseParams = {
			"start":"0","limit":"15","sort":"denominacion","dir":"ASC","par_filtro":"mmot.motivo","id_cat_movimiento":this.maestro.id_cat_movimiento
		}
		this.Cmp.id_movimiento_motivo.modificado=true;

		//Cambio del titulo de la ventana
		this.window.setTitle('Detalle del(a) '+this.maestro.movimiento);

		//Filtros por tipo de movimiento
		if(this.maestro.cod_movimiento=='alta'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'registrado',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='baja'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='reval'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='deprec'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='asig'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{en_deposito_mov:'si',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='devol'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario});
		} else if(this.maestro.cod_movimiento=='transf'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario});
		} else if(this.maestro.cod_movimiento=='desuso'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario,id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='incdec'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario,id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='tranfdep'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		}

		this.habilitarCampos();

		//Hide/show button
		this.getBoton('btnDetDep').hide();
		if(this.maestro.cod_movimiento=='deprec'){
			this.getBoton('btnDetDep').show();
		}

		this.store.baseParams = {
			id_movimiento : this.maestro.id_movimiento
		};
		this.load({
			params : {
				start : 0,
				limit : 50
			}
		});
	},

	habilitarCampos: function(){
		//Mostrar/ocultar componentes
		var swEstadoFun=false, swMotivo=false, swImporte=false, swVidaUtil=false,h=130,w=400;
		if(this.maestro.cod_movimiento=='alta'){
			
		} else if(this.maestro.cod_movimiento=='baja'){
			swMotivo=true;
			h=163;
		} else if(this.maestro.cod_movimiento=='reval'){
			swMotivo=true;
			swImporte=true;
			swVidaUtil=true;
			h=205;
		} else if(this.maestro.cod_movimiento=='deprec'){
			
		} else if(this.maestro.cod_movimiento=='asig'){
			
		} else if(this.maestro.cod_movimiento=='devol'){
			
		} else if(this.maestro.cod_movimiento=='transf'){
			
		} else if(this.maestro.cod_movimiento=='desuso'){
			swMotivo=true;
			h=163;
		} else if(this.maestro.cod_movimiento=='incdec'){
			swMotivo=true;
			swImporte=true;
			swVidaUtil=true;
			h=205;
		} else if(this.maestro.cod_movimiento=='tranfdep'){
			
		}

		this.Cmp.id_cat_estado_fun.setVisible(swEstadoFun);
		this.Cmp.importe.setVisible(swImporte);
		this.Cmp.vida_util.setVisible(swVidaUtil);

		this.Cmp.id_cat_estado_fun.allowBlank=!swEstadoFun;
		this.Cmp.importe.allowBlank=!swImporte;
		this.Cmp.vida_util.allowBlank=!swVidaUtil;

		//Resize window
    	this.window.setSize(w,h);
	},

	onButtonDetDep: function(){
	    var rec=this.sm.getSelected();
	    console.log('UNO: ',rec.data);
		Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/activo_fijo_valores/ActivoFijoValoresDep.php',
			'Detalle', {
				width:'90%',
				height:'90%'
		    },
		    rec.data,
		    this.idContenedor,
		    'ActivoFijoValoresDep'
		);
	},
	preparaMenu : function(n) {
		var tb = Phx.vista.MovimientoAf.superclass.preparaMenu.call(this);
		var data = this.getSelectedData();
		if(this.maestro.estado != 'borrador'){
			this.getBoton('new').disable();
	        this.getBoton('edit').disable();
		    this.getBoton('del').disable();
		}
		this.getBoton('btnDetDep').enable();
		return tb;
	},
	liberaMenu : function() {
		var tb = Phx.vista.MovimientoAf.superclass.liberaMenu.call(this);
		if(this.maestro.estado != 'borrador'){
			this.getBoton('new').disable();						
		}
		this.getBoton('btnDetDep').disable();
		return tb;
	},
	onButtonEdit: function() {
    	Phx.vista.MovimientoAf.superclass.onButtonEdit.call(this);
    	this.habilitarCampos();
    }

})
</script>