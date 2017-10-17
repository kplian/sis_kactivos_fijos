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

	swAccion: 'new',
	IdMovimientoAf: '',

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
            tooltip : '<b>Depreciación</b><br/>Detalle del cálculo de depreciación'
       	});

        /////////
        //Eventos
       	/////////
       	// Combo activos
       	this.Cmp.id_activo_fijo.on('select', function(combo, record, index){
       		this.cargarResumenAf(record.data);
       		this.validarDatosMov();
       	}, this)

       	//Campo importe
       	this.Cmp.importe.on('blur', function(cmp){
       		this.validarDatosMov();
       	}, this);

       	//Campo vida util
       	this.Cmp.vida_util.on('blur', function(cmp){
       		this.validarDatosMov();
       	}, this);

       	//Campo depreciacion_acum
       	this.Cmp.depreciacion_acum.on('blur', function(cmp){
       		this.validarDatosMov();
       	}, this);

       	//Grid
       	this.grid.on('cellclick', this.abrirEnlace, this);
	},

	isNumeric: function (obj) {
	    return !isNaN(obj - parseFloat(obj));
	},

	cargarResumenAf: function(data){
		this.Cmp.res_codigo.setValue(data.codigo);
		this.Cmp.res_denominacion.setValue(data.denominacion);
		this.Cmp.res_descripcion.setValue(data.descripcion);
		this.Cmp.res_mon_orig.setValue(data.desc_moneda_orig);
		this.Cmp.res_monto_compra.setValue(data.monto_compra);
		this.Cmp.res_vida_util.setValue(data.vida_util ? data.vida_util:data.vida_util_af);
		this.Cmp.res_fecha_ini_dep.setValue(data.fecha_ini_dep);
		this.Cmp.res_monto_vigente_real.setValue(data.monto_vigente_real_af);
		this.Cmp.res_dep_acum_real.setValue(data.depreciacion_acum_real_af);
		this.Cmp.res_dep_per_real.setValue(data.depreciacion_per_real_af);
		this.Cmp.res_vida_util_real.setValue(data.vida_util_real_af);
		this.Cmp.res_fecha_ult_dep_real.setValue(data.fecha_ult_dep_real_af);
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
				fieldLabel: 'Código',
				gwidth: 130,
				maxLength:10,
				renderer: function(value,p,record){
					return String.format('{0}','<i class="fa fa-reply-all" aria-hidden="true"></i> '+record.data['cod_af']);
				}
			},
			type:'TextField',
			filters:{pfiltro:'af.codigo',type:'string'},
			id_grupo:0,
			grid:true,
			form:false,
			bottom_filter:true
		},
		{
			config: {
				name: 'id_activo_fijo',
				fieldLabel: 'Activo Fijo',
				allowBlank: false,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijoFecha',
					id: 'id_activo_fijo',
					root: 'datos',
					sortInfo: {
						field: 'denominacion',
						direction: 'ASC'
					},
					totalProperty: 'total',
					fields: ['id_activo_fijo', 'denominacion', 'codigo','descripcion','cantidad_revaloriz','desc_moneda_orig','monto_compra','vida_util','fecha_ini_dep','monto_vigente_real_af','vida_util_real_af','fecha_ult_dep_real_af','depreciacion_acum_real_af','depreciacion_per_real_af'],
					remoteSort: true,
					baseParams: {par_filtro: 'afij.denominacion#afij.codigo#afij.descripcion', fecha_mov:''}
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
			form: true,
			bottom_filter:true
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
					if(this.maestro=='reval'||this.maestro=='ajuste'){
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
				name: 'moneda_base',
				fieldLabel: 'Expresado en ',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		},
		{
			config:{
				name: 'importe',
				fieldLabel: '(A) Importe',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength:1179650
			},
			type:'NumberField',
			filters:{pfiltro:'movaf.importe',type:'numeric'},
			id_grupo:0,
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
			id_grupo:0,
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
			id_grupo:0,
			grid:true,
			form:false
		},
		{
			config:{
				name: 'vida_util',
				fieldLabel: '(B) Vida útil',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100,
				maxLength:4
			},
			type:'NumberField',
			filters:{pfiltro:'movaf.vida_util',type:'numeric'},
			id_grupo:0,
			grid:false,
			form:true
		},
		{
			config:{
				name: 'depreciacion_acum',
				fieldLabel: '(F) Depreciación Acum.',
				allowBlank: true,
				anchor: '100%',
				gwidth: 100
			},
			type:'NumberField',
			filters:{pfiltro:'movaf.depreciacion_acum',type:'numeric'},
			id_grupo:0,
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
				id_grupo:0,
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
				id_grupo:0,
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
				id_grupo:0,
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
				id_grupo:0,
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
				id_grupo:0,
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
			id_grupo:0,
			grid:true,
			form:false
		}, {
			config:{
				name: 'res_saldo_importe',
				fieldLabel: 'Importe (A) - (C)',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_saldo_vida_util',
				fieldLabel: 'Vida útil (B) - (E)',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_saldo_depreciacion_acum',
				fieldLabel: 'Dep.Acum.(F)-(D)',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_codigo',
				fieldLabel: 'Código Activo Fijo',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_denominacion',
				fieldLabel: 'Denominación',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_descripcion',
				fieldLabel: 'Descripción',
				readOnly: true,
				width: '100%',
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'TextArea',
			id_grupo:0,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_mon_orig',
				fieldLabel: 'Moneda original',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:1,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_monto_compra',
				fieldLabel: 'Monto Compra',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:1,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_vida_util',
				fieldLabel: 'Vida útil',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:1,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_fecha_ini_dep',
				fieldLabel: 'Fecha Ini. Dep.',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:1,
			grid:false,
			form:true
		}, { ////////////
			config:{
				name: 'res_monto_vigente_real',
				fieldLabel: '(C) Monto Vigente',
				readOnly: true,
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:2,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_dep_acum_real',
				fieldLabel: '(D) Dep. Acumulada',
				readOnly: true,
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:2,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_dep_per_real',
				fieldLabel: 'Dep. Periodo',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:2,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_vida_util_real',
				fieldLabel: '(E) Vida útil restante',
				readOnly: true,
				style: 'background-color: #ffffb3; background-image: none;'
			},
			type:'Field',
			id_grupo:2,
			grid:false,
			form:true
		}, {
			config:{
				name: 'res_fecha_ult_dep_real',
				fieldLabel: 'Fecha Ult. Dep.',
				readOnly: true,
				style: 'background-color: #ddd; background-image: none;'
			},
			type:'Field',
			id_grupo:2,
			grid:false,
			form:true
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
		{name:'motivo', type: 'string'},
		'descripcion','monto_vigente_real_af','vida_util_real_af','fecha_ult_dep_real_af','depreciacion_acum_real_af','depreciacion_per_real_af','desc_moneda_orig','monto_compra','vida_util_af','fecha_ini_dep','depreciacion_acum'
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
		console.log('reload page',m);

		//Crear ventana mov esp y componentes
		if(this.maestro.cod_movimiento=='divis'||this.maestro.cod_movimiento=='desgl'||this.maestro.cod_movimiento=='intpar'){
			this.reinicializarParams();
		} else {
			this.eliminarComponentesMovEsp();
		}
		
		//Define the filter to apply to activos fijos drop down
		this.Cmp.id_activo_fijo.store.baseParams = {
		"start":"0","limit":"15","sort":"denominacion","dir":"ASC","par_filtro":"afij.denominacion#afij.codigo#afij.descripcion",fecha_mov: this.maestro.fecha_mov
		};
		//este 
		Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{codMov:this.maestro.cod_movimiento});
		this.Cmp.id_activo_fijo.modificado=true;
		
		//Setea parametros de filtro para el combo de motivos
		this.Cmp.id_movimiento_motivo.store.baseParams = {
			"start":"0","limit":"15","sort":"denominacion","dir":"ASC","par_filtro":"mmot.motivo","id_cat_movimiento":this.maestro.id_cat_movimiento
		}
		this.Cmp.id_movimiento_motivo.modificado=true;

		//Cambio del titulo de la ventana y panel
		var fecha = new Date (this.maestro.fecha_mov);
		this.window.setTitle('Detalle del(a) '+this.maestro.movimiento+' (Al '+fecha.format("d/m/Y")+')');

		//Filtros para el listado de activos fijos por tipo de movimiento
		if(this.maestro.cod_movimiento=='alta'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'registrado',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='baja'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'retiro',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='reval'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='mejora'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='deprec'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{depreciable:'si',estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='actua'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{depreciable:'no',estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='asig'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{en_deposito_mov:'si',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='devol'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario});
		} else if(this.maestro.cod_movimiento=='transf'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{id_funcionario_mov: this.maestro.id_funcionario});
		} else if(this.maestro.cod_movimiento=='retiro'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='ajuste'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='tranfdep'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta,registrado',en_deposito_mov:'si',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='divis'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='desgl'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		} else if(this.maestro.cod_movimiento=='intpar'){
			Ext.apply(this.Cmp.id_activo_fijo.store.baseParams,{estado_mov:'alta',id_depto_mov: this.maestro.id_depto});
		}

		this.habilitarCampos();

		//Bloquea botones nuevo, edición y eliminación
		this.getBoton('new').show();
		this.getBoton('edit').show();
		this.getBoton('del').show();
		this.getBoton('save').show();
		if(this.maestro.estado!='borrador'){
			this.getBoton('new').hide();
			this.getBoton('edit').hide();
			this.getBoton('del').hide();
			this.getBoton('save').hide();
		}

		//Hide/show button
		this.getBoton('btnDetDep').hide();
		if(this.maestro.cod_movimiento=='deprec' || this.maestro.cod_movimiento=='actua'){
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
		//Mostrar/ocultar componentes.
		var swEstadoFun=false, swMotivo=false, swImporte=false, swVidaUtil=false,h=280,w=980,swDepAcum=false;
		if(this.maestro.cod_movimiento=='alta'){
			
		} else if(this.maestro.cod_movimiento=='baja'){
			swMotivo=true;
			h=313;//163;
		} else if(this.maestro.cod_movimiento=='reval'){
			swMotivo=true;
			swImporte=true;
			swVidaUtil=true;
			h=355;//205;
		} else if(this.maestro.cod_movimiento=='deprec'){
			
		} else if(this.maestro.cod_movimiento=='asig'){
			
		} else if(this.maestro.cod_movimiento=='devol'){
			
		} else if(this.maestro.cod_movimiento=='transf'){
			
		} else if(this.maestro.cod_movimiento=='retiro'){
			swMotivo=true;
			h=313;//163;
		} else if(this.maestro.cod_movimiento=='ajuste'){
			swMotivo=true;
			swImporte=true;
			swVidaUtil=true;
			swDepAcum=true;
			h=400;//205;
		} else if(this.maestro.cod_movimiento=='tranfdep'){
			
		} else if(this.maestro.cod_movimiento=='mejora'){
			swMotivo=true;
			swImporte=true;
			swVidaUtil=true;
			h=355;//205;
		} else if(this.maestro.cod_movimiento=='actua'){
			
		} else if(this.maestro.cod_movimiento=='divis'){
			
		} else if(this.maestro.cod_movimiento=='desgl'){
			
		} else if(this.maestro.cod_movimiento=='intpar'){
			
		}

		this.Cmp.id_cat_estado_fun.setVisible(swEstadoFun);
		this.Cmp.importe.setVisible(swImporte);
		this.Cmp.vida_util.setVisible(swVidaUtil);
		this.Cmp.depreciacion_acum.setVisible(swDepAcum);
		this.Cmp.res_saldo_importe.setVisible(swImporte);
		this.Cmp.res_saldo_vida_util.setVisible(swVidaUtil);
		this.Cmp.res_saldo_depreciacion_acum.setVisible(swDepAcum);
		this.Cmp.moneda_base.setVisible(swImporte);

		this.Cmp.id_cat_estado_fun.allowBlank=!swEstadoFun;
		this.Cmp.importe.allowBlank=!swImporte;
		this.Cmp.vida_util.allowBlank=!swVidaUtil;
		this.Cmp.depreciacion_acum.allowBlank=!swDepAcum;
		this.Cmp.res_saldo_importe.allowBlank=!swImporte;
		this.Cmp.res_saldo_vida_util.allowBlank=!swVidaUtil;
		this.Cmp.res_saldo_depreciacion_acum.allowBlank=!swDepAcum;

		//Resize window
    	this.window.setSize(w,h);
	},

	onButtonDetDep: function(){
	    var rec=this.sm.getSelected();
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
		this.swAccion='edit';
		if(this.maestro.cod_movimiento=='divis'||this.maestro.cod_movimiento=='desgl'||this.maestro.cod_movimiento=='intpar'){
			var rec=this.sm.getSelected().data;
			this.reinicializarParams();
			this.edicionCargarDataMovEsp(rec);
		} else {
			Phx.vista.MovimientoAf.superclass.onButtonEdit.call(this);
	    	this.cargarMonedaBase();
	    	this.habilitarCampos();
	    	this.cargarResumenAf(this.sm.getSelected().data);
	    	//Carga los inc. o dec. reales
	    	var temp = Ext.util.Format.round(this.Cmp.importe.getValue()-this.Cmp.res_monto_vigente_real.getValue(),2);
	    	var temp1 = Ext.util.Format.round(this.Cmp.depreciacion_acum.getValue()-this.Cmp.res_dep_acum_real.getValue(),2);
	    	this.Cmp.res_saldo_importe.setValue(temp);
			this.Cmp.res_saldo_vida_util.setValue(this.Cmp.vida_util.getValue()-this.Cmp.res_vida_util_real.getValue());
			this.Cmp.res_saldo_depreciacion_acum.setValue(temp1);
		}
		this.IdMovimientoAf=this.sm.getSelected().data.id_movimiento_af;
    },
    onButtonNew: function(){
    	this.swAccion='new';
    	if(this.maestro.cod_movimiento=='divis'||this.maestro.cod_movimiento=='desgl'||this.maestro.cod_movimiento=='intpar'){
    		this.reinicializarParams();
    		this.abrirVentanaMovEspeciales();
    	} else {
    		Phx.vista.MovimientoAf.superclass.onButtonNew.call(this);	
    	}
    	this.cargarMonedaBase();
    	//Variable temporal
    	this.IdMovimientoAf='';
    },
	Grupos: [{
        layout: 'column',
        border: false,
        width: '100%',
        defaults: {
           border: false
        },            
        items: [{
			        bodyStyle: 'padding-right:5px;',
			        items: [{
			            xtype: 'fieldset',
			            title: 'Movimiento',
			            autoHeight: true,
			            width: '95%',
			            items: [],
				        id_grupo:0
			        }]
			    }, {
			        bodyStyle: 'padding-left:5px;',
			        items: [{
			            xtype: 'fieldset',
			            title: 'Datos Originales',
			            autoHeight: true,
			            items: [],
				        id_grupo:1
			        }]
			    }, {
			        bodyStyle: 'padding-left:5px;',
			        items: [{
			            xtype: 'fieldset',
			            title: 'Datos Vigentes',
			            autoHeight: true,
			            items: [],
				        id_grupo:2
			        }]
			    }]
    }],
    validarDatosMov: function(){
    	//Validación genérica
    	this.Cmp.importe.setMinValue(0);
    	this.Cmp.vida_util.setMinValue(0);

    	if(this.maestro.cod_movimiento=='reval'){
    		//Obtener saldo real de la revalorización
    		if(this.Cmp.importe.getValue()){
    			var temp = Ext.util.Format.round(this.Cmp.importe.getValue()-this.Cmp.res_monto_vigente_real.getValue(),2);
    			this.Cmp.res_saldo_importe.setValue(temp);
    		}
    		if(this.Cmp.vida_util.getValue()){
    			this.Cmp.res_saldo_vida_util.setValue(this.Cmp.vida_util.getValue()-this.Cmp.res_vida_util_real.getValue());
    		}
    	} else if(this.maestro.cod_movimiento=='mejora') {
    		//Validación de mínimos específica
    		this.Cmp.importe.setMinValue(parseFloat(this.Cmp.res_monto_vigente_real.getValue())+1);
    		this.Cmp.vida_util.setMinValue(parseInt(this.Cmp.res_vida_util_real.getValue()));

    		//Obtener saldo real de la revalorización
    		if(this.Cmp.importe.getValue()){
    			var temp = Ext.util.Format.round(this.Cmp.importe.getValue()-this.Cmp.res_monto_vigente_real.getValue(),2);
    			this.Cmp.res_saldo_importe.setValue(temp);
    		}
    		if(this.Cmp.vida_util.getValue()){
    			this.Cmp.res_saldo_vida_util.setValue(this.Cmp.vida_util.getValue()-this.Cmp.res_vida_util_real.getValue());
    		}

    		//Validacion de importe post cálculo de inc. o dec.
    		if(this.Cmp.res_saldo_importe.getValue()<=0){
    			this.Cmp.res_saldo_importe.markInvalid('El importe de la mejora debe incrementar el valor');
    		}
    		if(this.Cmp.res_saldo_vida_util.getValue()<0){
    			this.Cmp.res_saldo_vida_util.markInvalid('La vida útil de la mejora debe incrementar a la actual');
    		}
    	} else if(this.maestro.cod_movimiento=='ajuste'){
    		//Obtener saldo real de la revalorización
    		if(this.Cmp.importe.getValue()){
    			var temp = Ext.util.Format.round(this.Cmp.importe.getValue()-this.Cmp.res_monto_vigente_real.getValue(),2);
    			this.Cmp.res_saldo_importe.setValue(temp);
    		}
    		if(this.Cmp.vida_util.getValue()){
    			this.Cmp.res_saldo_vida_util.setValue(this.Cmp.vida_util.getValue()-this.Cmp.res_vida_util_real.getValue());
    		}
    		if(this.Cmp.depreciacion_acum.getValue()){
    			this.Cmp.res_saldo_depreciacion_acum.setValue(this.Cmp.depreciacion_acum.getValue()-this.Cmp.res_dep_acum_real.getValue());
    		}
    	} else {

    	}
    },
    cargarMonedaBase: function(){
    	//Obtención de la moneda base
       	Ext.Ajax.request({
	        url: '../../sis_parametros/control/Moneda/getMonedaBase',
	        params: {moneda:'si'},
	        success: function(res,params){
	        	var response = Ext.decode(res.responseText).ROOT.datos.moneda;
	        	this.Cmp.moneda_base.setValue(response);
	        },
	        argument: this.argumentSave,
	        failure: this.conexionFailure,
	        timeout: this.timeout,
	        scope: this
	    });
    },
    crearVentanaMovEspeciales: function(movimiento){
    	//////////
    	//Grupo 1
    	//Activo Fijo
    	this.me_activo_fijo = new Ext.form.ComboBox({
            name: 'me_activo_fijo',
            fieldLabel: 'Activo Fijo',
            allowBlank: false,
            emptyText:'Seleccione un activo Fijo...',
            store: new Ext.data.JsonStore({
				url: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijoFecha',
				id: 'id_activo_fijo',
				root: 'datos',
				sortInfo: {
					field: 'denominacion',
					direction: 'ASC'
				},
				totalProperty: 'total',
				fields: ['id_activo_fijo', 'denominacion', 'codigo','descripcion','cantidad_revaloriz','desc_moneda_orig','monto_compra','vida_util','fecha_ini_dep','monto_vigente_real_af','vida_util_real_af','fecha_ult_dep_real_af','depreciacion_acum_real_af','depreciacion_per_real_af'],
				remoteSort: true,
				baseParams: {par_filtro: 'afij.denominacion#afij.codigo#afij.descripcion', fecha_mov:''}
			}),
            valueField: 'id_activo_fijo',
			displayField: 'denominacion',
            forceSelection:true,
            typeAhead: false,
            triggerAction: 'all',
            lazyRender:true,
            mode:'remote',
            pageSize:15,
            queryDelay:1000,
            minChars:2,
            width:130,
            listWidth:300,
            renderer : function(value, p, record) {
					return String.format('{0}', record.data['denominacion']);
				},
				tpl : '<tpl for="."><div class="x-combo-list-item"><p><b>Codigo:</b> {codigo}</p><p><b>Activo Fijo:</b> {denominacion}</p><p><b>Descripcion:</b> {descripcion}</p></div></tpl>',
        });
        //Código del activo Fijo
        this.me_codigo = new Ext.form.Field({
        	name: 'me_codigo',
			fieldLabel: 'Código Activo Fijo',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //Denominación
        this.me_denominacion = new Ext.form.Field({
        	name: 'me_denominacion',
			fieldLabel: 'Denominación',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //Descripción
        this.me_descripcion = new Ext.form.TextArea({
        	name: 'me_descripcion',
			fieldLabel: 'Descripción',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //////////
    	//Grupo 2
    	//Moneda original
    	this.me_mon_orig = new Ext.form.Field({
    		name: 'me_mon_orig',
			fieldLabel: 'Moneda original',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Monto compra
    	this.me_monto_compra = new Ext.form.Field({
    		name: 'me_monto_compra',
			fieldLabel: 'Monto Compra',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Vida útil
    	this.me_vida_util = new Ext.form.Field({
    		name: 'me_vida_util',
			fieldLabel: 'Vida útil',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Fecha Ini. Dep.
    	this.me_fecha_ini_dep = new Ext.form.Field({
    		name: 'me_fecha_ini_dep',
			fieldLabel: 'Fecha Ini. Dep.',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });

    	//////////
    	//Grupo 3
    	//Monto Vigente
    	this.me_monto_vigente_real = new Ext.form.Field({
    		name: 'me_monto_vigente_real',
			fieldLabel: 'Monto Vigente',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Dep. Acumulada
    	this.me_dep_acum_real = new Ext.form.Field({
    		name: 'me_dep_acum_real',
			fieldLabel: 'Dep. Acumulada',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Dep Periodo
    	this.me_dep_per_real = new Ext.form.Field({
    		name: 'me_dep_per_real',
			fieldLabel: 'Dep. Periodo',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Vida útil restante
    	this.me_vida_util_real = new Ext.form.Field({
    		name: 'me_vida_util_real',
			fieldLabel: 'Vida útil restante',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Fecha Ult. dep
    	this.me_fecha_ult_dep_real = new Ext.form.Field({
    		name: 'me_fecha_ult_dep_real',
			fieldLabel: 'Fecha Ult. Dep.',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });

        //Toolbar
        this.me_btn_nuevo = new Ext.Button({
        	text:'<i class="fa fa-file-o fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		if(this.me_activo_fijo.getValue()){
        			this.openInputForm();	
        		} else {
        			Ext.MessageBox.alert('Mensaje','Previamente debe seleccionar un activo fijo');
        		}
        	},
        	tooltip: 'Nuevo',
        	scope: this
        });
        this.me_btn_editar = new Ext.Button({
        	text:'<i class="fa fa-pencil fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		this.editNode(this.treeLeft.getSelectionModel().getSelectedNode());
        	},
        	disabled: true,
        	tooltip: 'Editar',
        	scope: this
        });
        this.me_btn_eliminar = new Ext.Button({
        	text:'<i class="fa fa-trash fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		this.deleteNode(this.treeLeft.getSelectionModel().getSelectedNode());
        	},
        	disabled: true,
        	tooltip: 'Eliminar',
        	scope: this
        });
        this.me_btn_refresh = new Ext.Button({
        	text:'<i class="fa fa-refresh fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		this.treeLeft.getRootNode().reload();
        	},
        	scope: this
        });
        this.me_btn_new_intpar = new Ext.Button({
        	text:'<i class="fa fa-plus-circle fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		if(this.me_activo_fijo.getValue()){
        			this.abrirVentanaIntPar();
        		} else {
        			Ext.MessageBox.alert('Mensaje','Previamente debe seleccionar un activo fijo');
        		}
        	},
        	scope: this,
        	tooltip: 'Agregar Activo Fijo'
        });

        this.me_btn_eliminar_intpar = new Ext.Button({
        	text:'<i class="fa fa-trash fa-lg" aria-hidden="true"></i>',
        	border: false,
        	handler: function(btn,event){
        		//Verifica si el nodo seleccionado no es una hoja
        		var node = this.treeRight.getSelectionModel().getSelectedNode();
        		if(node.isLeaf()){
        			this.me_btn_eliminar_intpar.setDisabled(true);
        			return;
        		} 
        		Ext.MessageBox.confirm('Confirmación','¿Está seguro de quitar el Activo Fijo?',function(resp,cmp){
					if(resp=='yes'){

						//Llamada backend
						Phx.CP.loadingShow();
						var post = {
							id_movimiento_af: this.IdMovimientoAf,
							id_activo_fijo: this.treeRight.getSelectionModel().getSelectedNode().attributes.id_activo_fijo
						};

						Ext.Ajax.request({
							url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/eliminarMovimientoAfEspecialPorActivo',
							params: post,
							isUpload: false,
							success: function(res,params){
								this.treeRight.getSelectionModel().getSelectedNode().remove();
								Phx.CP.loadingHide();
							},
							argument: this.argumentSave,
				            failure: this.conexionFailure,
				            timeout: this.timeout,
				            scope: this
						});



        				
					}
				}, this);
        	},
        	scope: this,
        	tooltip: 'Quitar Activo Fijo'
        });
        this.me_toolbar = new Ext.Toolbar({
        	items:[this.me_btn_nuevo,this.me_btn_editar,this.me_btn_eliminar,this.me_btn_refresh]
        });
        this.me_toolbar_right = new Ext.Toolbar({
        	items:[this.me_btn_new_intpar,this.me_btn_eliminar_intpar]
        });

        //Si es División de valores deshabilita DD
        this.tmpDD = true;
        if(this.maestro.cod_movimiento=='divis'){
        	this.tmpDD = false;
        }

        //Arbol izquierdo
    	this.treeLeft = new Ext.tree.TreePanel({
    		title: 'Valores del Activo Fijo',
    		animate:true, 
            autoScroll:true,
            singleClickExpand: true,
            loader: new Ext.tree.TreeLoader({
            	url:'../../sis_kactivos_fijos/control/ActivoFijoValores/listarActivoFijoValoresArb',
            	clearOnLoad: true,
                baseParams: {
                    start: 0,
                    limit: 50,
                    sort: 'actval.id_activo_fijo_valor',
                    dir: 'ASC',
                    id_activo_fijo: '-1'
                }
            }),
            enableDD: this.tmpDD,
            containerScroll: false,
            border: true,
            width: 476,
            height: 250,
            dropConfig: {appendOnly:true}
    	});

        //Árbol derecho
    	this.treeRight = new Ext.tree.TreePanel({
    		title: 'Nuevos Activos Fijos',
    		animate:true, 
            autoScroll:true,
            enableDD:true,
            containerScroll: false,
            border: true,
            width: 476,
            height: 250,
            dropConfig: {appendOnly:true}
    	});

        ///////////////////////////////////////////////////////////////
        //Personalización por tipo de movimiento: divis, desgl, intpar
        ///////////////////////////////////////////////////////////////
        if(this.maestro.cod_movimiento=='divis'){
        	//Árbol izquierdo síncrono
        	var root = new Ext.tree.TreeNode({
	            text: 'Valores AF (Saldo: )', 
	            draggable:false,
	            expandable: true,
	            expanded: true
	        });
        	root.on('click',function(cmp,event){
	        	this.me_btn_editar.setDisabled(true);
	        	this.me_btn_eliminar.setDisabled(true);
	        },this);
	        this.treeLeft.setRootNode(root);
	        //Árbol derecho asíncrono
	        var rootR = new Ext.tree.AsyncTreeNode({
	            text: 'Nuevos Activos Fijos', 
	            draggable:false,
	            expandable: true
	        });
	        this.treeRight.setRootNode(rootR);
	        //Oculta/muestra botones
	        this.me_btn_nuevo.setVisible(true);
	        this.me_btn_editar.setVisible(true);
	        this.me_btn_eliminar.setVisible(true);
	        this.me_btn_refresh.setVisible(false);
	        //Oculta right tree
	        this.treeRight.setVisible(false);
	        this.me_toolbar_right.setVisible(false);
	        //Redimensión del left tree
	        this.treeLeft.setSize(980,250);

        } else if(this.maestro.cod_movimiento=='desgl'){
        	//Árbol izquierdo asíncrono
        	var root = new Ext.tree.AsyncTreeNode({
	            text: 'Valores AF', 
	            draggable:false,
	            expandable: true
	        });
	        this.treeLeft.setRootNode(root);
	        //Árbol derecho síncrono
	        var rootR = new Ext.tree.TreeNode({
	            text: 'Nuevos Activos Fijos', 
	            draggable:false,
	            expandable: true,
	            expanded: true
	        });
	        rootR.on('beforeappend',function(tree, old, node){
        		var aux = this.treeRight.getRootNode().findChild('id_activo_fijo_valor',node.attributes.id_activo_fijo_valor);
        		if(aux!==null){
					Ext.MessageBox.alert('Alerta','Este valor ya fue agregado previamente');
					return false;
				}

        	},this);
	        rootR.on('append',function(tree, old, node){
        		this.addNodeDesgl(tree, old, node);
        	},this);
        	rootR.on('remove',function(tree, old, node){
        		this.deleteNodeDesgl(tree, old, node);
        	},this);
	        this.treeRight.setRootNode(rootR);
	        //Oculta/muestra botones
	        this.me_btn_nuevo.setVisible(false);
	        this.me_btn_editar.setVisible(false);
	        this.me_btn_eliminar.setVisible(false);
	        this.me_btn_refresh.setVisible(true);
	        this.me_btn_new_intpar.setDisabled(true);
	        this.me_btn_eliminar_intpar.setDisabled(true);
	        //Muestra right tree
	        this.treeRight.setVisible(true);
	        this.me_toolbar_right.setVisible(true);
	        //Redimensión del left tree
	        this.treeLeft.setSize(476,250);

        } else if(this.maestro.cod_movimiento=='intpar'){
        	//Árbol izquierdo asíncrono
        	var root = new Ext.tree.AsyncTreeNode({
	            text: 'Valores AF', 
	            draggable:false,
	            expandable: true
	        });
	        this.treeLeft.setRootNode(root);
	        //Árbol derecho síncrono
	        var rootR = new Ext.tree.TreeNode({
	            text: 'Nuevos Activos Fijos', 
	            draggable:false,
	            expandable: true,
	            expanded: true,
	            allowDrop: false
	        });
	        rootR.on('click',function(cmp,event){
	        	this.me_btn_eliminar_intpar.setDisabled(true);
	        },this);
	        this.treeRight.setRootNode(rootR);
	        //Oculta/muestra botones
	        this.me_btn_nuevo.setVisible(false);
	        this.me_btn_editar.setVisible(false);
	        this.me_btn_eliminar.setVisible(false);
	        this.me_btn_refresh.setVisible(true);
	        this.me_btn_new_intpar.setDisabled(false);
	        this.me_btn_eliminar_intpar.setDisabled(true);
	        //Muestra right tree
	        this.treeRight.setVisible(true);
	        this.me_toolbar_right.setVisible(true);
	        //Redimensión del left tree
	        this.treeLeft.setSize(476,250);
	        //Cambio de título del árbol derecho
	        this.treeRight.setTitle('Activos Fijos seleccionados');
        }

        //Eventos
        this.treeLeft.loader.on('beforeload', function(treeLoader,node){
        	var idActivoFijo='-1';
        	if(this.me_activo_fijo.getValue()){
        		idActivoFijo=this.me_activo_fijo.getValue();
        	}
            Ext.apply(this.treeLeft.loader.baseParams,{
                id_activo_fijo: idActivoFijo
            });
        },this);

        this.me_activo_fijo.on('select', function(combo, record, index){
        	//Carga el resumen del activo fijo seleccionado
        	this.cargarResumenAfMovEsp(record.data);
        	//Inicialización de variables
        	this.saldoDivis=0;
        	Ext.apply(this.treeLeft.loader.baseParams,{
                id_activo_fijo: '-1'
            });
            //Casos por tipos de mov. esp.
        	if(this.maestro.cod_movimiento=='divis'){
        		//Setea el saldo
		        this.saldoDivis = this.me_monto_vigente_real.getValue();
		        //Setea la etiqueta del árbol izquierdo
		        this.treeLeft.getRootNode().setText('Valores AF (Saldo: '+this.saldoDivis+')');
		        this.treeLeft.getRootNode().removeAll();
        	} else if(this.maestro.cod_movimiento=='desgl'){
	            //Actualiza los parámetros el treeleft
	       		Ext.apply(this.treeLeft.loader.baseParams,{
	                id_activo_fijo: this.me_activo_fijo.getValue()
	            });
	       		this.treeLeft.getRootNode().reload();
	       		//Reinicializar tree right
	        	this.treeRight.getRootNode().removeAll();

        	} else if(this.maestro.cod_movimiento=='intpar'){
        		Ext.apply(this.treeLeft.loader.baseParams,{
	                id_activo_fijo: '-1'
	            });
	            //Carga el tree left
	       		Ext.apply(this.treeLeft.loader.baseParams,{
	                id_activo_fijo: this.me_activo_fijo.getValue()
	            });
	       		this.treeLeft.getRootNode().reload();
	       		//Reinicializar tree right
	        	this.treeRight.getRootNode().removeAll();
        	}

       	}, this);
        

        //Form
    	this.formMovEsp = new Ext.form.FormPanel({
            items: [{
			        layout: 'column',
			        border: false,
			        //width: '100%',
			        defaults: {
			           border: false
			        },
			        items: [{
				        bodyStyle: 'padding-right:5px;',
				        items: [{
				            xtype: 'fieldset',
				            title: 'Movimiento',
				            autoHeight: true,
				            items: [this.me_activo_fijo, this.me_codigo, this.me_denominacion, this.me_descripcion]
				        }]
				    	}, {
					        bodyStyle: 'padding-left:5px;',
					        items: [{
					            xtype: 'fieldset',
					            title: 'Datos Originales',
					            autoHeight: true,
					            items: [this.me_mon_orig,this.me_monto_compra,this.me_vida_util,this.me_fecha_ini_dep]
					        }]
					    }, {
					        bodyStyle: 'padding-left:5px;',
					        items: [{
					            xtype: 'fieldset',
					            title: 'Datos Vigentes',
					            autoHeight: true,
					            items: [this.me_monto_vigente_real,this.me_dep_acum_real,this.me_dep_per_real,this.me_vida_util_real,this.me_fecha_ult_dep_real]
					        }]
					    }]
			    },
            	new Ext.Panel({
            		layout: 'hbox',
            		items: [
            			new Ext.Panel({
            				layout: 'form',
            				items: [
            					this.me_toolbar,
            					this.treeLeft
            				]
            			}),
            			new Ext.Panel({
            				layout: 'form',
            				items: [this.me_toolbar_right,
            					this.treeRight
            				]
            			}),
            			
            		]
            	})
            ],
            padding: this.paddingForm,
            bodyStyle: this.bodyStyleForm,
            border: this.borderForm,
            frame: this.frameForm, 
            autoScroll: false,
            autoDestroy: true,
            autoScroll: true,
            region: 'center'
        });

    	//Window
    	this.windowMovEsp = new Ext.Window({
            width: 980,
            height: 550,
            modal: true,
            closeAction: 'hide',
            labelAlign: 'top',
            title: this.maestro.movimiento,
            bodyStyle: 'padding:5px',
            layout: 'border',
            items: [this.formMovEsp],
            buttons: [ {
                text: 'Cerrar',
                handler: function() {
                    this.reload();
                    this.windowMovEsp.hide();
                },
                scope: this
            }]
        });
    },
    abrirVentanaMovEspeciales: function(tipo='new'){
    	if(this.windowMovEsp){
    		var fecha = new Date (this.maestro.fecha_mov);
    		var title;
    		if(tipo=='edit'){
    			title='Editar Registro - '+this.maestro.movimiento+' (Al '+fecha.format("d/m/Y")+')';
    		} else {
    			title='Nuevo Registro - '+this.maestro.movimiento+' (Al '+fecha.format("d/m/Y")+')';
    		}
    		
	    	this.windowMovEsp.setTitle(title);
	    	this.windowMovEsp.show();
    	}
    },
    cargarResumenAfMovEsp: function(data){
		this.me_codigo.setValue(data.codigo?data.codigo:data.cod_af);
		this.me_denominacion.setValue(data.denominacion);
		this.me_descripcion.setValue(data.descripcion);
		this.me_mon_orig.setValue(data.desc_moneda_orig);
		this.me_monto_compra.setValue(data.monto_compra);
		this.me_vida_util.setValue(data.vida_util ? data.vida_util:data.vida_util_af);
		this.me_fecha_ini_dep.setValue(data.fecha_ini_dep);
		this.me_monto_vigente_real.setValue(data.monto_vigente_real_af);
		this.me_dep_acum_real.setValue(data.depreciacion_acum_real_af);
		this.me_dep_per_real.setValue(data.depreciacion_per_real_af);
		this.me_vida_util_real.setValue(data.vida_util_real_af);
		this.me_fecha_ult_dep_real.setValue(data.fecha_ult_dep_real_af);
	},
	openInputForm: function(){
		Ext.MessageBox.prompt('Nuevo Valor','Introduzca el monto del nuevo valor', function(resp,val,cmp){
			if(resp=='ok'){
				if(this.isNumeric(val)){
					//Verificar que no se pase del total
					if(this.calculaSaldoDivis(val)){
						this.addNode({importe: val});
					} else {
						Ext.MessageBox.alert('Mensaje','El importe supera al total');
					}
				} else {
					Ext.MessageBox.alert('Mensaje','Introduzca un monto válido');
				}
			}
		}, this);
	},
	addNode: function(node){
		var newNode = new Ext.tree.TreeNode({
            text: 'Valor: '+ node.importe,
            leaf: true,
            monto_vigente_real: node.importe
		});
		newNode.on('click', function(cmp,event){
			this.me_btn_editar.setDisabled(false);
			this.me_btn_eliminar.setDisabled(false);
		},this);
		//Llamada backend
		Phx.CP.loadingShow();
		var post = {
			id_movimiento_af: this.IdMovimientoAf,
			id_movimiento: this.maestro.id_movimiento,
			cod_movimiento: this.maestro.cod_movimiento,
			id_movimiento_af_especial: '',
			id_activo_fijo_valor: '',
			id_activo_fijo: this.me_activo_fijo.getValue(),
			importe: node.importe
		};

		Ext.Ajax.request({
			url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/insertarMovimientoAfEspecial',
			params: post,
			isUpload: false,
			success: function(res,params){
				var response = Ext.decode(res.responseText).ROOT.datos;
				newNode.attributes.id_movimiento_af_especial = response.id_movimiento_af_especial;
				newNode.attributes.id_movimiento_af = response.id_movimiento_af;
				this.treeLeft.getRootNode().appendChild(newNode);
				//Id movimiento_af auxiliar
				this.IdMovimientoAf = response.id_movimiento_af;
				Phx.CP.loadingHide();
			},
			argument: this.argumentSave,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
		});
	},
	editNode: function(node){
		Ext.MessageBox.prompt('Edición de Valor','Introduzca el monto del valor', function(resp,val,cmp){
			if(resp=='ok'){
				if(this.isNumeric(val)){
					//Verificar que no se pase del total
					if(this.calculaSaldoDivis(val,node.attributes.monto_vigente_real)){
						//Llamada backend
						var post = {
							id_movimiento_af: this.IdMovimientoAf,
							id_movimiento: this.maestro.id_movimiento,
							cod_movimiento: this.maestro.cod_movimiento,
							id_movimiento_af_especial: node.attributes.id_movimiento_af_especial,
							id_activo_fijo_valor: '',
							id_activo_fijo: this.me_activo_fijo.getValue(),
							importe: val
						};

						Ext.Ajax.request({
							url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/insertarMovimientoAfEspecial',
							params: post,
							isUpload: false,
							success: function(res,params){
								//Modifica el monto del nodo seleccionado
								this.treeLeft.getSelectionModel().getSelectedNode().attributes.monto_vigente_real=val;
								this.treeLeft.getSelectionModel().getSelectedNode().setText('Valor: '+val);
								Phx.CP.loadingHide();
							},
							argument: this.argumentSave,
				            failure: this.conexionFailure,
				            timeout: this.timeout,
				            scope: this
						});
					} else {
						Ext.MessageBox.alert('Mensaje','El importe supera al total');
					}
				} else {
					Ext.MessageBox.alert('Mensaje','Introduzca un monto válido');
				}
			}
		}, this, false, node.attributes.monto_vigente_real);
	},
	deleteNode: function(node){
		this.treeLeft.getSelectionModel().getSelectedNode().attributes.monto_vigente_real
		Ext.MessageBox.confirm('Confirmación','¿Está seguro de eliminar el Valor?',function(resp,cmp){
			if(resp=='yes'){
				//Llamada backend
				var post = {
					id_movimiento_af: this.IdMovimientoAf,
					id_movimiento: this.maestro.id_movimiento,
					cod_movimiento: this.maestro.cod_movimiento,
					id_movimiento_af_especial: node.attributes.id_movimiento_af_especial,
					id_activo_fijo_valor: '',
					id_activo_fijo: this.me_activo_fijo.getValue(),
					importe: node.attributes.monto_vigente_real
				};

				Ext.Ajax.request({
					url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/eliminarMovimientoAfEspecial',
					params: post,
					isUpload: false,
					success: function(res,params){
						//Elimina el nodo seleccionado
						this.treeLeft.getSelectionModel().getSelectedNode().remove();
						//Actualiza el saldo
						this.saldoDivis += parseFloat(node.attributes.monto_vigente_real);
						this.treeLeft.getRootNode().setText('Valores AF (Saldo: '+this.saldoDivis+')');

						Phx.CP.loadingHide();
					},
					argument: this.argumentSave,
		            failure: this.conexionFailure,
		            timeout: this.timeout,
		            scope: this
				});
			}
		},this);
	},
	eliminarComponentesMovEsp: function(){
		this.me_activo_fijo = undefined;
		this.me_codigo = undefined;
		this.me_denominacion = undefined;
		this.me_descripcion = undefined;
		this.me_mon_orig = undefined;
		this.me_monto_compra = undefined;
		this.me_vida_util = undefined;
		this.me_fecha_ini_dep = undefined;
		this.me_monto_vigente_real = undefined;
		this.me_dep_acum_real = undefined;
		this.me_dep_per_real = undefined;
		this.me_vida_util_real = undefined;
		this.me_fecha_ult_dep_real = undefined;
		this.me_btn_nuevo = undefined;
		this.me_btn_refresh = undefined;
		this.me_btn_eliminar = undefined;
		this.me_btn_new_intpar = undefined;
		this.me_toolbar = undefined;
		this.me_toolbar_right = undefined;
		this.treeLeft = undefined;
		this.treeRight = undefined;
		this.formMovEsp = undefined;
		this.windowMovEsp = undefined;

		this.me_intpar_activo_fijo = undefined;
		this.me_intpar_codigo = undefined;
		this.me_intpar_denominacion = undefined;
		this.me_intpar_descripcion = undefined;
		this.me_intpar_mon_orig = undefined;
		this.me_intpar_monto_compra = undefined;
		this.me_intpar_vida_util = undefined;
		this.me_intpar_fecha_ini_dep = undefined;
		this.me_intpar_monto_vigente_real = undefined;
		this.me_intpar_dep_acum_real = undefined;
		this.me_intpar_dep_per_real = undefined;
		this.me_intpar_vida_util_real = undefined;
		this.me_intpar_fecha_ult_dep_real = undefined;
		this.me_intpar_btn_nuevo = undefined;
		this.me_intpar_btn_refresh = undefined;
		this.me_intpar_btn_eliminar = undefined;
		this.me_intpar_btn_new_intpar = undefined;
		this.me_intpar_toolbar = undefined;
		this.me_intpar_toolbar_right = undefined;
		this.formIntPar = undefined;
		this.windowIntPar = undefined;
	},
	calculaSaldoDivis: function(importeNuevo,importeAnterior=undefined){
		if(importeAnterior){
			//Edit
			if(parseFloat(this.saldoDivis) - parseFloat(importeNuevo) + parseFloat(importeAnterior) < 0){
				return false;
			}
			this.saldoDivis = parseFloat(this.saldoDivis) - parseFloat(importeNuevo) + parseFloat(importeAnterior);
			this.saldoDivis = Math.round(this.saldoDivis*100)/100;
			this.treeLeft.getRootNode().setText('Valores AF (Saldo: '+this.saldoDivis+')');
			return true;
		} else {
			//Nuevo
			if(parseFloat(this.saldoDivis) - parseFloat(importeNuevo) < 0){
				return false;
			}
			this.saldoDivis -= parseFloat(importeNuevo);
			this.saldoDivis = Math.round(this.saldoDivis*100)/100;
			this.treeLeft.getRootNode().setText('Valores AF (Saldo: '+this.saldoDivis+')');
			return true;
		}
	},
	crearVentanaIntPar: function(){
		//////////
    	//Grupo 1
    	//Activo Fijo
    	this.me_intpar_activo_fijo = new Ext.form.ComboBox({
            name: 'me_intpar_activo_fijo',
            fieldLabel: 'Activo Fijo',
            allowBlank: false,
            emptyText:'Seleccione un activo Fijo...',
            store: new Ext.data.JsonStore({
				url: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijoFecha',
				id: 'id_activo_fijo',
				root: 'datos',
				sortInfo: {
					field: 'denominacion',
					direction: 'ASC'
				},
				totalProperty: 'total',
				fields: ['id_activo_fijo', 'denominacion', 'codigo','descripcion','cantidad_revaloriz','desc_moneda_orig','monto_compra','vida_util','fecha_ini_dep','monto_vigente_real_af','vida_util_real_af','fecha_ult_dep_real_af','depreciacion_acum_real_af','depreciacion_per_real_af'],
				remoteSort: true,
				baseParams: {par_filtro: 'afij.denominacion#afij.codigo#afij.descripcion', fecha_mov:''}
			}),
            valueField: 'id_activo_fijo',
			displayField: 'denominacion',
            forceSelection:true,
            typeAhead: false,
            triggerAction: 'all',
            lazyRender:true,
            mode:'remote',
            pageSize:15,
            queryDelay:1000,
            minChars:2,
            width:130,
            listWidth:300,
            renderer : function(value, p, record) {
					return String.format('{0}', record.data['denominacion']);
				},
				tpl : '<tpl for="."><div class="x-combo-list-item"><p><b>Codigo:</b> {codigo}</p><p><b>Activo Fijo:</b> {denominacion}</p><p><b>Descripcion:</b> {descripcion}</p></div></tpl>',
        });
        //Código del activo Fijo
        this.me_intpar_codigo = new Ext.form.Field({
        	name: 'me_intpar_codigo',
			fieldLabel: 'Código Activo Fijo',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //Denominación
        this.me_intpar_denominacion = new Ext.form.Field({
        	name: 'me_intpar_denominacion',
			fieldLabel: 'Denominación',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //Descripción
        this.me_intpar_descripcion = new Ext.form.TextArea({
        	name: 'me_intpar_descripcion',
			fieldLabel: 'Descripción',
			readOnly: true,
			width: '100%',
			style: 'background-color: #ddd; background-image: none;'
        });
        //////////
    	//Grupo 2
    	//Moneda original
    	this.me_intpar_mon_orig = new Ext.form.Field({
    		name: 'me_intpar_mon_orig',
			fieldLabel: 'Moneda original',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Monto compra
    	this.me_intpar_monto_compra = new Ext.form.Field({
    		name: 'me_intpar_monto_compra',
			fieldLabel: 'Monto Compra',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Vida útil
    	this.me_intpar_vida_util = new Ext.form.Field({
    		name: 'me_intpar_vida_util',
			fieldLabel: 'Vida útil',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Fecha Ini. Dep.
    	this.me_intpar_fecha_ini_dep = new Ext.form.Field({
    		name: 'me_intpar_fecha_ini_dep',
			fieldLabel: 'Fecha Ini. Dep.',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });

    	//////////
    	//Grupo 3
    	//Monto Vigente
    	this.me_intpar_monto_vigente_real = new Ext.form.Field({
    		name: 'me_intpar_monto_vigente_real',
			fieldLabel: 'Monto Vigente',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Dep. Acumulada
    	this.me_intpar_dep_acum_real = new Ext.form.Field({
    		name: 'me_intpar_dep_acum_real',
			fieldLabel: 'Dep. Acumulada',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Dep Periodo
    	this.me_intpar_dep_per_real = new Ext.form.Field({
    		name: 'me_intpar_dep_per_real',
			fieldLabel: 'Dep. Periodo',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });
    	//Vida útil restante
    	this.me_intpar_vida_util_real = new Ext.form.Field({
    		name: 'me_intpar_vida_util_real',
			fieldLabel: 'Vida útil restante',
			readOnly: true,
			style: 'background-color: #ffffb3; background-image: none;'
        });
    	//Fecha Ult. dep
    	this.me_intpar_fecha_ult_dep_real = new Ext.form.Field({
    		name: 'me_intpar_fecha_ult_dep_real',
			fieldLabel: 'Fecha Ult. Dep.',
			readOnly: true,
			style: 'background-color: #ddd; background-image: none;'
        });

        //Eventos
        this.me_intpar_activo_fijo.on('select', function(combo, record, index){
        	//Carga el resumen del activo fijo seleccionado
        	this.cargarResumenAfIntPar(record.data);
        },this);

        //Form
    	this.formIntPar = new Ext.form.FormPanel({
    		items: [{
			        layout: 'column',
			        border: false,
			        //width: '100%',
			        defaults: {
			           border: false
			        },
			        items: [{
				        bodyStyle: 'padding-right:5px;',
				        items: [{
				            xtype: 'fieldset',
				            title: 'Movimiento',
				            autoHeight: true,
				            items: [this.me_intpar_activo_fijo, this.me_intpar_codigo, this.me_intpar_denominacion, this.me_intpar_descripcion]
				        }]
				    	}, {
					        bodyStyle: 'padding-left:5px;',
					        items: [{
					            xtype: 'fieldset',
					            title: 'Datos Originales',
					            autoHeight: true,
					            items: [this.me_intpar_mon_orig,this.me_intpar_monto_compra,this.me_intpar_vida_util,this.me_intpar_fecha_ini_dep]
					        }]
					    }, {
					        bodyStyle: 'padding-left:5px;',
					        items: [{
					            xtype: 'fieldset',
					            title: 'Datos Vigentes',
					            autoHeight: true,
					            items: [this.me_intpar_monto_vigente_real,this.me_intpar_dep_acum_real,this.me_intpar_dep_per_real,this.me_intpar_vida_util_real,this.me_intpar_fecha_ult_dep_real]
					        }]
					    }]
			    }
            ],
            padding: this.paddingForm,
            bodyStyle: this.bodyStyleForm,
            border: this.borderForm,
            frame: this.frameForm, 
            autoScroll: false,
            autoDestroy: true,
            autoScroll: true,
            region: 'center'
    	});

    	//Window
    	this.windowIntPar = new Ext.Window({
            width: 880,
            height: 270,
            modal: true,
            closeAction: 'hide',
            labelAlign: 'top',
            title: this.maestro.movimiento,
            bodyStyle: 'padding:5px',
            layout: 'border',
            items: [this.formIntPar],
            buttons: [{
                text: 'Agregar',
                handler: this.agregarAfIntPar,
                scope: this
            }, {
                text: 'Declinar',
                handler: function() {
                    this.windowIntPar.hide();
                },
                scope: this
            }]
        });

	},
	abrirVentanaIntPar: function(){
    	if(this.windowIntPar){
    		var fecha = new Date (this.maestro.fecha_mov);
	    	this.windowIntPar.setTitle('Agregar Activo Fijo (Al '+fecha.format("d/m/Y")+')');
	    	this.windowIntPar.show();
    	}
    },
	cargarResumenAfIntPar: function(data){
		this.me_intpar_codigo.setValue(data.codigo);
		this.me_intpar_denominacion.setValue(data.denominacion);
		this.me_intpar_descripcion.setValue(data.descripcion);
		this.me_intpar_mon_orig.setValue(data.desc_moneda_orig);
		this.me_intpar_monto_compra.setValue(data.monto_compra);
		this.me_intpar_vida_util.setValue(data.vida_util ? data.vida_util:data.vida_util_af);
		this.me_intpar_fecha_ini_dep.setValue(data.fecha_ini_dep);
		this.me_intpar_monto_vigente_real.setValue(data.monto_vigente_real_af);
		this.me_intpar_dep_acum_real.setValue(data.depreciacion_acum_real_af);
		this.me_intpar_dep_per_real.setValue(data.depreciacion_per_real_af);
		this.me_intpar_vida_util_real.setValue(data.vida_util_real_af);
		this.me_intpar_fecha_ult_dep_real.setValue(data.fecha_ult_dep_real_af);
	},
	agregarAfIntPar: function(){
		if(this.me_intpar_activo_fijo.getValue()){
			var IdActivoFijo = this.me_intpar_activo_fijo.getValue();
			//Verificar si el activo fijo ya fue incluido en el árbol
			var node = this.treeRight.getRootNode().findChild('id_activo_fijo',IdActivoFijo);

			//Verifica que no sea el mismo activo fijo que el activo fijo padre
			if(this.me_activo_fijo.getValue()==this.me_intpar_activo_fijo.getValue()){
				Ext.MessageBox.alert('Alerta','El Activo Fijo no puede ser el mismo que el padre');
				return;
			}

			//Add node
			if(node===null){
				var newNode = new Ext.tree.TreeNode({
		            leaf: false,
		            id_activo_fijo: IdActivoFijo,
		            monto_vigente_real: this.me_intpar_monto_vigente_real.getValue(),
		            monto_incremento: 0,
		            allowDrop: true,
		            allowDrag: false,
		            codigo: this.me_intpar_codigo.getValue(),
		            denominacion: this.me_intpar_denominacion.getValue(),
				});
				newNode.setText(this.getNodeTextIntPar(newNode));
				newNode.on('click', function(cmp,event){
					this.me_btn_eliminar_intpar.setDisabled(false);
				},this);

				//Evento cuando se agregue un nodo (drag and drop)
				newNode.on('beforeappend',function(tree, old, node){
	        		if(!node.attributes.swBd){
		        		var aux = newNode.findChild('id_activo_fijo_valor',node.attributes.id_activo_fijo_valor);
		        		if(aux!==null){
							Ext.MessageBox.alert('Alerta','Este valor ya fue agregado previamente');
							return false;
						}
					}
	        	},this);
	        	newNode.on('append',function(tree, old, node, index){
	        		//Llamada backend
					this.addNodeIntPar(tree,old,node,index);

	        	},this);
	        	newNode.on('remove',function(tree, old, node){
	        		this.deleteNodeIntPar(tree, old, node);
	        	},this);
				this.treeRight.getRootNode().appendChild(newNode);
				this.windowIntPar.hide();
			} else {
				Ext.MessageBox.alert('Alerta','El Activo Fijo ya fue incluido previamente');
			}
		}
	},
	getNodeTextIntPar: function(parent){
		var incremento=0;
		//Recorre todos los nodos hijos
		Ext.each(parent.childNodes, function(node){
			if(node){
				incremento+=parseFloat(node.attributes.monto_vigente_real);
			}
		})
		var monto = parseFloat(parent.attributes.monto_vigente_real) + parseFloat(incremento);
		monto = Math.round(monto*100)/100;
		var title = '['+parent.attributes.codigo+'] '+parent.attributes.denominacion+': '+parent.attributes.monto_vigente_real+' + '+incremento+' = '+ monto;

		return title;
	},
	reinicializarParams: function(){
		this.eliminarComponentesMovEsp();
		this.crearVentanaMovEspeciales();
		this.crearVentanaIntPar();
		//Actualiza los parámetros del combo de activos de mov. esp.
		this.me_activo_fijo.store.baseParams = {
			start:"0",
			limit:"15",
			sort:"denominacion",
			dir:"ASC",
			par_filtro:"afij.denominacion#afij.codigo#afij.descripcion",
			fecha_mov: this.maestro.fecha_mov,
			codMov:this.maestro.cod_movimiento
		};
		this.me_activo_fijo.modificado=true;
		//Actualiza los parámetros del combo de activos de Intercambio de Partes
		this.me_intpar_activo_fijo.store.baseParams = {
			start:"0",
			limit:"15",
			sort:"denominacion",
			dir:"ASC",
			par_filtro:"afij.denominacion#afij.codigo#afij.descripcion",
			fecha_mov: this.maestro.fecha_mov,
			codMov:this.maestro.cod_movimiento
		};
		this.me_intpar_activo_fijo.modificado=true;
	},
	edicionCargarDataMovEsp: function(obj){
		Ext.Ajax.request({
			url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/listarMovimientoAfEspecial',
	        params: {
	        	start: 0,
                limit: 50,
                sort: 'movesp.id_movimiento_af_especial',
                dir: 'ASC',
	        	id_movimiento_af: obj.id_movimiento_af
	        },
	        success: this.edicionRenderDataMovEsp,
	        argument: this.argumentSave,
	        failure: this.conexionFailure,
	        timeout: this.timeout,
	        scope: this
		});
	},
	edicionRenderDataMovEsp: function(res,params){
		var response = Ext.decode(res.responseText).datos;
		/////////////////////////
		//Cargar datos cabecera
		////////////////////////
		var movimientoAf=this.sm.getSelected().data;
		//Combo activo fijo
		var rec = new Ext.data.Record({
			denominacion: movimientoAf.denominacion,
			id_activo_fijo: movimientoAf.id_activo_fijo
		});
        this.me_activo_fijo.store.add(rec);
        this.me_activo_fijo.store.commitChanges();
        this.me_activo_fijo.modificado = true;
		this.me_activo_fijo.setValue(movimientoAf.id_activo_fijo);
		//Cargar resumen
		this.cargarResumenAfMovEsp(movimientoAf);

		//////////////////
		//Cargar árboles
		/////////////////
		if(this.maestro.cod_movimiento=='divis'){
			var saldoTmp=0;
			for(var i=0;i<response.length;i++){
				var newNode = new Ext.tree.TreeNode({
		            text: 'Valor: '+ response[i].importe,
		            leaf: true,
		            monto_vigente_real: response[i].importe,
		            id_movimiento_af_especial: response[i].id_movimiento_af_especial,
		            id_movimiento_af: response[i].id_movimiento_af
				});
				newNode.on('click', function(cmp,event){
					this.me_btn_editar.setDisabled(false);
					this.me_btn_eliminar.setDisabled(false);
				},this);
				this.treeLeft.getRootNode().appendChild(newNode);

				saldoTmp+=parseFloat(response[i].importe);
			}
			//Actualiza el saldo
			this.saldoDivis = parseFloat(this.me_monto_vigente_real.getValue())-parseFloat(saldoTmp);
			//Actualiza el texto del root node
			this.treeLeft.getRootNode().setText('Valores AF (Saldo: '+this.saldoDivis+')');
		} else if(this.maestro.cod_movimiento=='desgl'){
			//////////////////////////////
			//Carga los activo fijo valor
			//////////////////////////////
       		Ext.apply(this.treeLeft.loader.baseParams,{
                id_activo_fijo: movimientoAf.id_activo_fijo
            });
       		this.treeLeft.getRootNode().reload();
       		///////////////////////
       		//Carga árbol derecho
       		///////////////////////
        	//this.treeRight.getRootNode().removeAll();
        	//Carga los activos fijos
        	for(var i=0;i<response.length;i++){
        		var newNode = new Ext.tree.TreeNode({
		            text: '['+response[i].codigo_afv+']-'+ response[i].tipo_afv + ' ' + response[i].monto_vigente_real_afv,
		            leaf: false,
		            monto_vigente_real: response[i].monto_vigente_real,
		            id_movimiento_af_especial: response[i].id_movimiento_af_especial,
		            id_activo_fijo_valor: response[i].id_activo_fijo_valor,
		            id_movimiento_af: response[i].id_movimiento_af,
		            allowDrop: false,
		            swBd: true
				});
				this.treeRight.getRootNode().appendChild(newNode);
        	}

		} else if(this.maestro.cod_movimiento=='intpar'){
			//////////////////////////////
			//Carga los activo fijo valor
			//////////////////////////////
       		Ext.apply(this.treeLeft.loader.baseParams,{
                id_activo_fijo: movimientoAf.id_activo_fijo
            });
       		this.treeLeft.getRootNode().reload();
       		///////////////////////
       		//Carga árbol derecho
       		///////////////////////
        	//this.treeRight.getRootNode().removeAll();
        	//Prepar datos
        	var arr=[];
        	var arrAux=[];
        	for(var i=0;i<response.length;i++){
        		if(arr.indexOf(response[i].id_activo_fijo)==-1){
        			arr.push(response[i].id_activo_fijo);
        			arrAux.push(response[i]);
        		}
        	}

        	//Carga los activos fijos
        	for(var i=0;i<arr.length;i++){
        		var newNode = new Ext.tree.TreeNode({
		            leaf: false,
		            monto_vigente_real: arrAux[i].monto_vigente_real,
		            id_movimiento_af_especial: arrAux[i].id_movimiento_af_especial,
		            id_activo_fijo_valor: arrAux[i].id_activo_fijo_valor,
		            id_activo_fijo: arrAux[i].id_activo_fijo,
		            denominacion: arrAux[i].denominacion,
		            codigo: arrAux[i].codigo,
		            swBd: true,
		            draggable: false
				});

				newNode.on('remove',function(tree, old, node){
	        		this.deleteNodeIntPar(tree, old, node);
	        	},this);
				//Evento cuando se agregue un nodo (drag and drop)
				newNode.on('beforeappend',function(tree, old, node){
					if(!node.attributes.swBd){
		        		var aux = newNode.findChild('id_activo_fijo_valor',node.attributes.id_activo_fijo_valor);
		        		if(aux!==null){
							Ext.MessageBox.alert('Alerta','Este valor ya fue agregado previamente');
							return false;
						}
					}
	        	},this);
	        	newNode.on('append',function(tree, old, node, index){
	        		this.addNodeIntPar(tree,old,node,index);
	        	},this);
	        	newNode.on('click', function(cmp,event){
					this.me_btn_eliminar_intpar.setDisabled(false);
				},this);

				//Carga los valores a intercambiar
	        	for(var j=0;j<response.length;j++){
	        		if(response[j].id_activo_fijo == arr[i]){
	        			var depNode = new Ext.tree.TreeNode({
				            text: '['+response[j].codigo_afv+']-'+ response[j].tipo_afv + ' ' + response[j].monto_vigente_real_afv,
				            leaf: true,
				            monto_vigente_real: response[j].importe,
				            id_movimiento_af_especial: response[j].id_movimiento_af_especial,
				            id_activo_fijo_valor: response[j].id_activo_fijo_valor,
				            id_movimiento_af: response[j].id_movimiento_af,
				            swBd: true,
				            draggable: true
						});
						newNode.appendChild(depNode);
	        		}
	        	}
	        	newNode.setText(this.getNodeTextIntPar(newNode));

	        	this.treeRight.getRootNode().appendChild(newNode);
        	}
        	

		}


		//Abre la ventana
		this.abrirVentanaMovEspeciales('edit');
	},
	addNodeDesgl: function (tree, old, node){
		//Llamada backend
		if(!node.attributes.swBd){
			Phx.CP.loadingShow();
			var post = {
				id_movimiento_af: this.IdMovimientoAf,
				id_movimiento: this.maestro.id_movimiento,
				cod_movimiento: this.maestro.cod_movimiento,
				id_movimiento_af_especial: '',
				id_activo_fijo_valor: node.attributes.id_activo_fijo_valor,
				id_activo_fijo: this.me_activo_fijo.getValue(),
				importe: node.attributes.monto_vigente
			};

			Ext.Ajax.request({
				url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/insertarMovimientoAfEspecial',
				params: post,
				isUpload: false,
				success: function(res,params){
					var response = Ext.decode(res.responseText).ROOT.datos;
					node.attributes.id_movimiento_af_especial = response.id_movimiento_af_especial;
					node.attributes.id_movimiento_af = response.id_movimiento_af;
					this.IdMovimientoAf = response.id_movimiento_af;
					Phx.CP.loadingHide();
				},
				argument: this.argumentSave,
	            failure: function(res,params){
	            	var response = Ext.decode(res.responseText).ROOT.detalle;
	            	node.remove();
	            	Ext.MessageBox.alert('Error',response.mensaje);
	            },
	            timeout: this.timeout,
	            scope: this
			});
		}
	},
	deleteNodeDesgl: function(tree, old, node){
		//Llamada backend
		Phx.CP.loadingShow();
		var post = {
			id_movimiento_af: this.IdMovimientoAf,
			id_movimiento: this.maestro.id_movimiento,
			cod_movimiento: this.maestro.cod_movimiento,
			id_movimiento_af_especial: node.attributes.id_movimiento_af_especial,
			id_activo_fijo_valor: '',
			id_activo_fijo: this.me_activo_fijo.getValue()
		};

		Ext.Ajax.request({
			url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/eliminarMovimientoAfEspecial',
			params: post,
			isUpload: false,
			success: function(res,params){
				Phx.CP.loadingHide();
			},
			argument: this.argumentSave,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
		});
	},
	deleteNodeIntPar: function(tree, old, node){
		//Llamada backend
		Phx.CP.loadingShow();
		var post = {
			id_movimiento_af: this.IdMovimientoAf,
			id_movimiento: this.maestro.id_movimiento,
			cod_movimiento: this.maestro.cod_movimiento,
			id_movimiento_af_especial: node.attributes.id_movimiento_af_especial,
			id_activo_fijo_valor: '',
			id_activo_fijo: this.me_activo_fijo.getValue()
		};

		Ext.Ajax.request({
			url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/eliminarMovimientoAfEspecial',
			params: post,
			isUpload: false,
			success: function(res,params){
				old.attributes.monto_incremento -= parseFloat(node.attributes.monto_vigente)
	        	old.setText(this.getNodeTextIntPar(old));
				Phx.CP.loadingHide();
			},
			argument: this.argumentSave,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
		});
	},
	addNodeIntPar: function(tree,old,node,index){
		if(!node.attributes.swBd){
			Phx.CP.loadingShow();
			var post = {
				id_movimiento_af: this.IdMovimientoAf,
				id_movimiento: this.maestro.id_movimiento,
				cod_movimiento: this.maestro.cod_movimiento,
				id_movimiento_af_especial: '',
				id_activo_fijo_valor: node.attributes.id_activo_fijo_valor,
				id_activo_fijo: this.me_activo_fijo.getValue(),
				id_activo_fijo_det: old.attributes.id_activo_fijo,
				importe: node.attributes.monto_vigente
			};

			Ext.Ajax.request({
				url: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/insertarMovimientoAfEspecial',
				params: post,
				isUpload: false,
				success: function(res,params){
					var response = Ext.decode(res.responseText).ROOT.datos;
					old.setText(this.getNodeTextIntPar(old));
					//Carga los valores almacenados
					node.attributes.id_movimiento_af_especial = response.id_movimiento_af_especial;
					node.attributes.id_movimiento_af = response.id_movimiento_af;
					//Carga variable temporal
					this.IdMovimientoAf = response.id_movimiento_af;
					Phx.CP.loadingHide();
				},
				argument: this.argumentSave,
	            failure: this.conexionFailure,
	            timeout: this.timeout,
	            scope: this
			});
		}
	},
	abrirEnlace: function(cell,rowIndex,columnIndex,e){
		if(columnIndex==1){
			var data = this.sm.getSelected().data;
			Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php',
			'Detalle', {
				width:'90%',
				height:'90%'
		    }, {
		    	lnk_id_activo_fijo: data.id_activo_fijo,
		    	link: true
		    },
		    this.idContenedor,
		    'ActivoFijo'
			);
		}
	},
	agregarArgsExtraSubmit: function(){
		//Inicializa el objeto de los argumentos extra
		this.argumentExtraSubmit={};
			//Añade los parámetros extra para mandar por submit
		this.argumentExtraSubmit.importe_ant=this.Cmp.res_monto_compra.getValue();
		this.argumentExtraSubmit.vida_util_ant=this.Cmp.res_vida_util_real.getValue();
	}
})
</script>
