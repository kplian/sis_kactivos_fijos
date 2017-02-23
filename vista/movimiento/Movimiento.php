<?php
/**
*@package pXP
*@file gen-Movimiento.php
*@author  (admin)
*@date 22-10-2015 20:42:41
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.Movimiento=Ext.extend(Phx.gridInterfaz,{

	gruposBarraTareas:[
		{name:'Todos',title:'<h1 align="center"><i class="fa fa-bars"></i> Todos</h1>',grupo:0,height:0},
	   	{name:'Altas',title:'<h1 align="center"><i class="fa fa-thumbs-o-up"></i> Altas</h1>',grupo:1,height:0},
       	{name:'Bajas',title:'<H1 align="center"><i class="fa fa-thumbs-o-down"></i> Bajas</h1>',grupo:2,height:0},
       	{name:'Revalorizaciones/Mejoras',title:'<H1 align="center"><i class="fa fa-plus-circle"></i> Revaloriz/Incrementos</h1>',grupo:3,height:0},
       	{name:'Asignaciones/Devoluciones',title:'<H1 align="center"><i class="fa fa-user-plus"></i> Asig/Devol/Transf</h1>',grupo:4,height:0},
       	{name:'Depreciaciones',title:'<H1 align="center"><i class="fa fa-calculator"></i> Depreciaciones</h1>',grupo:5,height:0}
    ],

    actualizarSegunTab: function(name, indice){
    	if(indice==0){
    		this.filterMov='%';
    	} else if(indice==1){
    		this.filterMov='alta';
    	} else if(indice==2){
    		this.filterMov='baja';
    	} else if(indice==3){
    		this.filterMov='reval,incdec';
    	} else if(indice==4){
    		this.filterMov='asig,devol,transf,tranfdep';
    	} else if(indice==5){
    		this.filterMov='deprec';
    	}
    	this.store.baseParams.cod_movimiento = this.filterMov;
    	//this.getBoton('btnReporte').show();
    	this.load({params:{start:0, limit:this.tam_pag}});
    },
    bnewGroups: [0,1,2,3,4,5],
    beditGroups: [0,1,2,3,4,5],
    bdelGroups:  [0,1,2,3,4,5],
    bactGroups:  [0,1,2,3,4,5],
    btestGroups: [0,1,2,3,4,5],
    bexcelGroups: [0,1,2,3,4,5],

	constructor:function(config){
		this.maestro=config.maestro;
    	//llama al constructor de la clase padre
		Phx.vista.Movimiento.superclass.constructor.call(this,config);
		this.init();
		this.load({params:{start:0, limit:this.tam_pag}})

		/*this.addButton('btnMovGral',
            {
                text: 'Movimientos',
                iconCls: 'bchecklist',
                disabled: false,
                handler: this.openMovimientos
            }
        );*/
        //Add handler to id_cat_movimiento field
        this.Cmp.id_cat_movimiento.on('select', function(cmp,rec,el){
        	this.habilitarCampos(rec.data.codigo);
        	this.Cmp.id_movimiento_motivo.reset();
            this.Cmp.id_movimiento_motivo.modificado=true;
            this.Cmp.id_movimiento_motivo.store.baseParams.id_cat_movimiento=rec.data.id_catalogo;
        }, this);
        //Add report button
        this.addButton('btnReporte',{
            text :'Reporte',
            iconCls : 'bpdf32',
            disabled: true,
            handler : this.onButtonReport,
            tooltip : '<b>Reporte Ingreso/Salida</b><br/><b>Solicitud del ingreso o salida</b>'
        });
        //Add handler to id_cat_movimiento field
        this.Cmp.id_depto_dest.on('select', function(cmp,rec,el){
        	this.Cmp.id_deposito_dest.reset();
            this.Cmp.id_deposito_dest.modificado=true;
            this.Cmp.id_deposito_dest.store.baseParams.id_depto=rec.data.id_depto;
        }, this);

        this.addButton('ant_estado',{argument: {estado: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.antEstado,tooltip: '<b>Pasar al Anterior Estado</b>'});
        this.addButton('sig_estado',{text:'Siguiente',iconCls: 'badelante',disabled:true,handler:this.sigEstado,tooltip: '<b>Pasar al Siguiente Estado</b>'});
		this.addButton('diagrama_gantt',{text:'Gant',iconCls: 'bgantt',disabled:true,handler:diagramGantt,tooltip: '<b>Diagrama Gantt del proceso</b>'});
		this.addButton('btnChequeoDocumentosWf',
            {
                text: 'Documentos',
                iconCls: 'bchecklist',
                disabled: true,
                handler: this.loadCheckDocumentosPlanWf,
                tooltip: '<b>Documentos de la Solicitud</b><br/>Subir los documetos requeridos en la solicitud seleccionada.'
            }
        );

        function diagramGantt(){
            var data=this.sm.getSelected().data.id_proceso_wf;
            Phx.CP.loadingShow();
            Ext.Ajax.request({
                url:'../../sis_workflow/control/ProcesoWf/diagramaGanttTramite',
                params:{'id_proceso_wf':data},
                success:this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });         
        } 
	},
			
	Atributos:[
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
			//configuracion del componente
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'cod_movimiento'
			},
			type:'Field',
			form:true 
		},
		{
			config: {
				name: 'id_cat_movimiento',
				fieldLabel: 'Proceso',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'movimiento',
				hiddenName: 'id_cat_movimiento',
				gwidth: 95,
				baseParams:{
						cod_subsistema:'KAF',
						catalogo_tipo:'tmovimiento__id_cat_movimiento'
				},
				renderer: function (value,p,record) {
					var result;
					result = "<div style='text-align:center'><img src = '../../../lib/imagenes/" + record.data.icono +"'align='center' width='18' height='18' title='"+record.data.movimiento+"'/><br> <u>"+record.data.movimiento+"</u></div>";
					return result;
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
			config:{
				name: 'num_tramite',
				fieldLabel: 'Fecha',
				allowBlank: true,
				anchor: '80%',
				gwidth: 210,
				maxLength:200,
				disabled: true,
				renderer: function(value,p,record){
					/*var fecha = new Date(record.data['fecha_mov'].dateFormat('d/m/Y'));
					console.log('xxxxxxx',fecha.toString());*/
					return '<tpl for="."><div class="x-combo-list-item"><p><b>Fecha: </b> '+record.data['fecha_mov'].dateFormat('d/m/Y')+'</p><p><b>Tramite: </b> <font color="blue">'+record.data['num_tramite']+'</font></p><p><b>Estado: </b>'+record.data['estado']+'</p></div></tpl>';

				}
			},
			type:'TextField',
			filters:{pfiltro:'mov.num_tramite',type:'string'},
			id_grupo:1,
			grid:true,
			form:false,
			bottom_filter:true
		},
		{
			config:{
				name: 'estado',
				fieldLabel: 'Estado',
				allowBlank: true,
				anchor: '80%',
				gwidth: 90,
				maxLength:15,
				disabled: true,
				renderer: function (value,p,record) {
					var result;
					//if(value == "Borrador") {
						result = "<div style='text-align:center'><img src = '../../../lib/imagenes/"+record.data.icono_estado+"' align='center' width='18' height='18' title='"+record.data.estado+"'/><br><u>"+record.data.estado+"</u></div>";
					//}
					return result;
				}
			},
			type:'TextField',
			filters:{pfiltro:'mov.estado',type:'string'},
			id_grupo:1,
			grid:false,
			form:true,
			bottom_filter:true
		},
		{
			config:{
				name: 'fecha_mov',
				fieldLabel: 'Fecha',
				allowBlank: false,
				anchor: '80%',
				gwidth: 70,
				format: 'd/m/Y', 
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'mov.fecha_mov',type:'date'},
				id_grupo:1,
				grid:false,
				form:true
		},
		{
			config : {
				name : 'id_depto',
				fieldLabel : 'Dpto.',
				allowBlank : false,
				emptyText : 'Departamento...',
				store : new Ext.data.JsonStore({
					url : '../../sis_parametros/control/Depto/listarDepto',
					id : 'id_depto',
					root : 'datos',
					sortInfo : {
						field : 'nombre',
						direction : 'ASC'
					},
					totalProperty : 'total',
					fields : ['id_depto', 'nombre', 'codigo'],
					remoteSort : true,
					baseParams : {
						par_filtro : 'DEPPTO.nombre#DEPPTO.codigo',
						modulo: 'KAF'
					}
				}),
				valueField : 'id_depto',
				displayField : 'nombre',
				gdisplayField : 'depto',
				tpl : '<tpl for="."><div class="x-combo-list-item"><p>Nombre: {nombre}</p><p>Código: {codigo}</p></div></tpl>',
				hiddenName : 'id_depto',
				forceSelection : true,
				typeAhead : false,
				triggerAction : 'all',
				lazyRender : true,
				mode : 'remote',
				pageSize : 10,
				queryDelay : 1000,
				anchor : '95%',
				gwidth : 250,
				minChars : 2,
				renderer : function(value, p, record) {
					//return String.format('{0}', record.data['depto']);
					var desc;
					if(record.data['cod_movimiento']=='transf'){
						desc='<tpl for="."><div class="x-combo-list-item"><p><b>Dpto.:</b> '+record.data['depto']+'</p><p><b>De:</b> <font color="blue">'+record.data['desc_funcionario2']+'</font></p><p><b>A:</b> <u><font color="green">'+record.data['funcionario_dest']+'</u></font></p></div></tpl>';
					} else if(record.data['cod_movimiento']=='asig'){
						desc='<tpl for="."><div class="x-combo-list-item"><p><b>Dpto.:</b> '+record.data['depto']+'</p><p><b>A:</b> <u><font color="green">'+record.data['desc_funcionario2']+'</u></font></p></div></tpl>';
					} else {
						desc='<tpl for="."><div class="x-combo-list-item"><p><b>Dpto.:</b> '+record.data['depto']+'</p></div></tpl>';
					}
					return desc; 
				}
			},
			type : 'ComboBox',
			id_grupo : 0,
			filters : {
				pfiltro : 'dep.nombre',
				type : 'string'
			},
			grid : true,
			form : true
		},
		{
			config:{
				name: 'glosa',
				fieldLabel: 'Glosa',
				allowBlank: false,
				anchor: '95%',
				gwidth: 350,
				maxLength:200
			},
			type:'TextArea',
			filters:{pfiltro:'mov.glosa',type:'string'},
			id_grupo:1,
			grid:true,
			form:true,
			bottom_filter:true
		},
		{
			config:{
				name: 'fecha_hasta',
				fieldLabel: 'Fecha Hasta',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y', 
				hidden: true,
				renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
			},
				type:'DateField',
				filters:{pfiltro:'mov.fecha_hasta',type:'date'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_proceso_wf'
			},
			type:'Field',
			form:true 
		},
		{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_estado_wf'
			},
			type:'Field',
			form:true 
		},
		{
   			config:{
       		    name:'id_funcionario',
       		    hiddenName: 'id_funcionario',
   				origen:'FUNCIONARIO',
   				fieldLabel:'Funcionario',
   				allowBlank:true,
                gwidth:200,
   				valueField: 'id_funcionario',
   			    gdisplayField: 'desc_funcionario2',
   			    baseParams: { fecha: new Date()},
   			    hidden: true,
      			renderer:function(value, p, record){return String.format('{0}', record.data['desc_funcionario2']);},
       	     },
   			type:'ComboRec',//ComboRec
   			id_grupo:0,
   			filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
   		    grid:true,
   			form:true,
   			bottom_filter:true
		},
		{
   			config:{
       		    name:'id_persona',
       		    hiddenName: 'id_persona',
   				origen:'PERSONA',
   				fieldLabel:'Custodio?',
   				allowBlank:true,
                gwidth:200,
   				valueField: 'id_persona',
   			    gdisplayField: 'custodio',
   			    hidden: true,
      			renderer:function(value, p, record){return String.format('{0}', record.data['custodio']);},
       	     },
   			type:'ComboRec',//ComboRec
   			id_grupo:0,
   			filters:{pfiltro:'per.nombre_completo2',type:'string'},
   		    grid:true,
   			form:true
		},
		{
			config: {
				name: 'id_oficina',
				fieldLabel: 'Oficina',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				hidden: true,
				store: new Ext.data.JsonStore({
                    url: '../../sis_organigrama/control/Oficina/listarOficina',
                    id: 'id_oficina',
                    root: 'datos',
                    fields: ['id_oficina','codigo','nombre'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    baseParams:{
                        start: 0,
                        limit: 10,
                        sort: 'codigo',
                        dir: 'ASC'
                    }
                }),
				valueField: 'id_oficina',
				displayField: 'nombre',
				gdisplayField: 'oficina',
				hiddenName: 'id_oficina',
				forceSelection: false,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '95%',
				gwidth: 150,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['oficina']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'ofi.nombre',type: 'string'},
			grid: true,
			form: true
		},
		{
			config:{
				name: 'direccion',
				fieldLabel: 'Direccion',
				allowBlank: true,
				anchor: '95%',
				gwidth: 100,
				maxLength:500,
				hidden: true
			},
				type:'TextArea',
				filters:{pfiltro:'mov.direccion',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config:{
				name: 'codigo',
				fieldLabel: 'Codigo',
				allowBlank: true,
				gwidth: 100,
				hidden: true
			},
				type:'TextField',
				filters:{pfiltro:'mov.codigo',type:'string'},
				id_grupo:1,
				grid:true,
				form:true
		},
		{
			config: {
				name: 'id_deposito',
				fieldLabel: 'Deposito',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				hidden: true,
				store: new Ext.data.JsonStore({
                    url: '../../sis_kactivos_fijos/control/Deposito/listarDeposito',
                    id: 'id_deposito',
                    root: 'datos',
                    fields: ['id_deposito','codigo','nombre'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    baseParams:{
                        start: 0,
                        limit: 10,
                        sort: 'codigo',
                        dir: 'ASC'
                    }
                }),
				valueField: 'id_deposito',
				displayField: 'nombre',
				gdisplayField: 'deposito',
				hiddenName: 'id_deposito',
				forceSelection: false,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '95%',
				gwidth: 150,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['deposito']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'depo.nombre',type: 'string'},
			grid: true,
			form: true
		},
		{
			config : {
				name : 'id_depto_dest',
				fieldLabel : 'Depto. Destino',
				allowBlank : true,
				emptyText : 'Departamento...',
				store : new Ext.data.JsonStore({
					url : '../../sis_parametros/control/Depto/listarDepto',
					id : 'id_depto',
					root : 'datos',
					sortInfo : {
						field : 'nombre',
						direction : 'ASC'
					},
					totalProperty : 'total',
					fields : ['id_depto', 'nombre', 'codigo'],
					remoteSort : true,
					baseParams : {
						par_filtro : 'DEPPTO.nombre#DEPPTO.codigo',
						modulo: 'KAF'
					}
				}),
				valueField : 'id_depto',
				displayField : 'nombre',
				gdisplayField : 'depto_dest',
				tpl : '<tpl for="."><div class="x-combo-list-item"><p>Nombre: {nombre}</p><p>Código: {codigo}</p></div></tpl>',
				hiddenName : 'id_depto_dest',
				forceSelection : true,
				typeAhead : false,
				triggerAction : 'all',
				lazyRender : true,
				mode : 'remote',
				pageSize : 10,
				queryDelay : 1000,
				anchor : '95%',
				gwidth : 200,
				minChars : 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['depto_dest']);
				},
				hidden: true
			},
			type : 'ComboBox',
			id_grupo : 0,
			filters : {
				pfiltro : 'depdest.nombre',
				type : 'string'
			},
			grid : true,
			form : true
		},
		{
			config: {
				name: 'id_deposito_dest',
				fieldLabel: 'Deposito Destino',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				hidden: true,
				store: new Ext.data.JsonStore({
                    url: '../../sis_kactivos_fijos/control/Deposito/listarDeposito',
                    id: 'id_deposito',
                    root: 'datos',
                    fields: ['id_deposito','codigo','nombre'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    baseParams:{
                        start: 0,
                        limit: 10,
                        sort: 'codigo',
                        dir: 'ASC',
                        id_depto: 0
                    }
                }),
				valueField: 'id_deposito',
				displayField: 'nombre',
				gdisplayField: 'deposito_dest',
				hiddenName: 'id_deposito_dest',
				forceSelection: false,
				typeAhead: false,
				triggerAction: 'all',
				lazyRender: true,
				mode: 'remote',
				pageSize: 15,
				queryDelay: 1000,
				anchor: '95%',
				gwidth: 150,
				minChars: 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['deposito_dest']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'depo.nombre',type: 'string'},
			grid: true,
			form: true
		},
		{
   			config:{
       		    name:'id_funcionario_dest',
       		    hiddenName: 'id_funcionario_dest',
   				origen:'FUNCIONARIO',
   				fieldLabel:'Funcionario Dest.',
   				allowBlank:true,
                gwidth:200,
   				valueField: 'id_funcionario',
   			    gdisplayField: 'funcionario_dest',
   			    baseParams: { fecha: new Date()},
   			    hidden: true,
      			renderer:function(value, p, record){return String.format('{0}', record.data['desc_funcionario2']);},
       	     },
   			type:'ComboRec',//ComboRec
   			id_grupo:0,
   			filters:{pfiltro:'fundest.desc_funcionario2',type:'string'},
   		    grid:true,
   			form:true,
   			bottom_filter:true
		},
		{
			config : {
				name : 'id_movimiento_motivo',
				fieldLabel : 'Motivo',
				allowBlank : true,
				emptyText : 'Motivo...',
				store : new Ext.data.JsonStore({
					url : '../../sis_kactivos_fijos/control/MovimientoMotivo/listarMovimientoMotivo',
					id : 'id_movimiento_motivo',
					root : 'datos',
					sortInfo : {
						field : 'motivo',
						direction : 'ASC'
					},
					totalProperty : 'total',
					fields : ['id_movimiento_motivo', 'motivo'],
					remoteSort : true,
					baseParams : {
						par_filtro : 'motivo',
						modulo: 'KAF'
					}
				}),
				valueField : 'id_movimiento_motivo',
				displayField : 'motivo',
				gdisplayField : 'motivo',
				//tpl : '<tpl for="."><div class="x-combo-list-item"><p>Nombre: {motivo}</p></div></tpl>',
				hiddenName : 'id_movimiento_motivo',
				forceSelection : true,
				typeAhead : false,
				triggerAction : 'all',
				lazyRender : true,
				mode : 'remote',
				pageSize : 10,
				queryDelay : 1000,
				anchor : '95%',
				gwidth : 200,
				minChars : 2,
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['movimiento_motivo']);
				},
				hidden: true
			},
			type : 'ComboBox',
			id_grupo : 0,
			filters : {
				pfiltro : 'mmov.motivo',
				type : 'string'
			},
			grid : true,
			form : true
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
				filters:{pfiltro:'mov.estado_reg',type:'string'},
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
				filters:{pfiltro:'mov.id_usuario_ai',type:'numeric'},
				id_grupo:1,
				grid:false,
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
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
							format: 'd/m/Y', 
							renderer:function (value,p,record){return value?value.dateFormat('d/m/Y H:i:s'):''}
			},
				type:'DateField',
				filters:{pfiltro:'mov.fecha_reg',type:'date'},
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
				filters:{pfiltro:'mov.usuario_ai',type:'string'},
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
				filters:{pfiltro:'mov.fecha_mod',type:'date'},
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
		}
	],
	arrayDefaultColumHidden:['fecha_reg','usr_reg','fecha_mod','usr_mod','fecha_hasta',
	'id_proceso_wf','id_estado_wf','id_funcionario','estado_reg','id_usuario_ai','usuario_ai','direccion','id_oficina'],
	tam_pag:50,	
	title:'Movimiento de Activos Fijos',
	ActSave:'../../sis_kactivos_fijos/control/Movimiento/insertarMovimiento',
	ActDel:'../../sis_kactivos_fijos/control/Movimiento/eliminarMovimiento',
	ActList:'../../sis_kactivos_fijos/control/Movimiento/listarMovimiento',
	id_store:'id_movimiento',
	fields: [
		{name:'id_movimiento', type: 'numeric'},
		{name:'direccion', type: 'string'},
		{name:'fecha_hasta', type: 'date',dateFormat:'Y-m-d'},
		{name:'id_cat_movimiento', type: 'numeric'},
		{name:'fecha_mov', type: 'date',dateFormat:'Y-m-d'},
		{name:'id_depto', type: 'numeric'},
		{name:'id_proceso_wf', type: 'numeric'},
		{name:'id_estado_wf', type: 'numeric'},
		{name:'glosa', type: 'string'},
		{name:'id_funcionario', type: 'numeric'},
		{name:'estado', type: 'string'},
		{name:'id_oficina', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'num_tramite', type: 'string'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usuario_ai', type: 'string'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'movimiento', type: 'string'},
		{name:'cod_movimiento', type: 'string'},
		{name:'icono', type: 'string'},
		{name:'depto', type: 'string'},
		{name:'cod_depto', type: 'string'},
		{name:'id_responsable_depto', type: 'numeric'},
		{name:'id_persona', type: 'numeric'},
		{name:'responsable_depto', type: 'string'},
		{name:'custodio', type: 'string'},
		{name:'icono_estado', type: 'string'},
		{name:'codigo', type: 'string'},
		{name:'id_deposito', type: 'numeric'},
		{name:'id_depto_dest', type: 'numeric'},
		{name:'id_deposito_dest', type: 'numeric'},
		{name:'id_funcionario_dest', type: 'numeric'},
		{name:'id_movimiento_motivo', type: 'numeric'},
		{name:'deposito', type: 'string'},
		{name:'depto_dest', type: 'string'},
		{name:'deposito_dest', type: 'string'},
		{name:'funcionario_dest', type: 'string'},
		{name:'motivo', type: 'string'},
		{name:'desc_funcionario2', type: 'string'}
	],
	sortInfo:{
		field: 'id_movimiento',
		direction: 'DESC'
	},
	bdel:true,
	bsave:true,
	rowExpander: new Ext.ux.grid.RowExpander({
	        tpl : new Ext.Template(
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Registro:&nbsp;&nbsp;</b> {usr_reg}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Registro:&nbsp;&nbsp;</b> {fecha_reg}</p>',	       
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Modificación:&nbsp;&nbsp;</b> {usr_mod}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Modificación:&nbsp;&nbsp;</b> {fecha_mod}</p>'
	        )
    }),
    openMovimientos: function(){
    	Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/movimiento/MovimientoGral.php',
            'Movimientos',
            {
                width:'50%',
                height:'85%'
            },
            {},
            this.idContenedor,
            'MovimientoGral'
        )
    },

    habilitarCampos: function(mov){
    	var swDireccion=false,swFechaHasta=false,swFuncionario=false,swOficina=false,swPersona=false,h=130,w=450,swDeptoDest=false,swDepositoDest=false,swFuncionarioDest=false,swCatMovMotivo=false;

    	//Muesta y habilita los campos basicos
    	this.Cmp.fecha_mov.setVisible(true);
    	this.Cmp.glosa.setVisible(true);
    	this.Cmp.id_depto.setVisible(true);

    	this.form.getForm().clearInvalid();

    	//Muestra y habilita los campos especificos por tipo de movimiento
    	if(mov=='alta'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=false;
    		h=253;
    	} else if(mov=='asig'){
    		swDireccion=true;
    		swFechaHasta=false;
    		swFuncionario=true;
    		swOficina=true;
    		swPersona=true;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=false;
    		h=381;
    	} else if(mov=='baja'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=true;
    		h=275;
    	} else if(mov=='deprec'){
    		swDireccion=false;
    		swFechaHasta=true;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=false;
    		h=280;
    	} else if(mov=='desuso'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=true;
    		h=275;
    	} else if(mov=='devol'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=true;
    		swOficina=false;
    		swPersona=true;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=false;
    		h=298;
    	} else if(mov=='incdec'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=true;
    		h=275;
    	} else if(mov=='reval'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=false;
    		swPersona=false;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=false;
    		swCatMovMotivo=true;
    		h=275;
    	} else if(mov=='transf'){
    		swDireccion=true;
    		swFechaHasta=false;
    		swFuncionario=true;
    		swOficina=true;
    		swPersona=true;
    		swDeptoDest=false;
    		swDepositoDest=false;
    		swFuncionarioDest=true;
    		swCatMovMotivo=false;
    		h=415;
    	} else if(mov=='tranfdep'){
    		swDireccion=false;
    		swFechaHasta=false;
    		swFuncionario=false;
    		swOficina=true;
    		swPersona=false;
    		swDeptoDest=true;
    		swDepositoDest=true;
    		swFuncionarioDest=false;
    		swCatMovMotivo=false;
    		h=355;
    	} 

    	//Enable/disable user controls based on mov type
    	this.Cmp.direccion.setVisible(swDireccion);
    	this.Cmp.fecha_hasta.setVisible(swFechaHasta);
    	this.Cmp.id_funcionario.setVisible(swFuncionario);
    	this.Cmp.id_oficina.setVisible(swOficina);
    	this.Cmp.id_persona.setVisible(swPersona);
    	this.Cmp.id_depto_dest.setVisible(swDeptoDest);
    	this.Cmp.id_deposito_dest.setVisible(swDepositoDest);
    	this.Cmp.id_funcionario_dest.setVisible(swFuncionarioDest);
    	this.Cmp.id_movimiento_motivo.setVisible(swCatMovMotivo);

    	//Set required or not
    	this.Cmp.direccion.allowBlank=!swDireccion;
    	this.Cmp.fecha_hasta.allowBlank=!swFechaHasta;
    	this.Cmp.id_funcionario.allowBlank=!swFuncionario;
    	this.Cmp.id_oficina.allowBlank=!swOficina;
    	//this.Cmp.id_persona.allowBlank=!swPersona;
    	this.Cmp.id_depto_dest.allowBlank=!swDeptoDest;
    	this.Cmp.id_deposito_dest.allowBlank=!swDepositoDest;
    	this.Cmp.id_funcionario_dest.allowBlank=!swFuncionarioDest;
    	this.Cmp.id_movimiento_motivo.allowBlank=!swCatMovMotivo;

    	//Resize window
    	this.window.setSize(w,h);
    },

    onButtonEdit: function() {
    	Phx.vista.Movimiento.superclass.onButtonEdit.call(this);
    	var data = this.getSelectedData();
    	this.habilitarCampos(data.cod_movimiento);
    },

    south: {
		url: '../../../sis_kactivos_fijos/vista/movimiento_af/MovimientoAf.php',
		title: 'Detalle de Movimiento',
		height: '50%',
		cls: 'MovimientoAf'
	},
	onButtonReport:function(){
	    var rec=this.sm.getSelected();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Movimiento/generarReporteMovimiento',
            params:{'id_movimiento':rec.data.id_movimiento},
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });  
	},
	liberaMenu:function(){
        var tb = Phx.vista.Movimiento.superclass.liberaMenu.call(this);
        if(tb){
            this.getBoton('btnReporte').disable();
            this.getBoton('ant_estado').disable();
	        this.getBoton('sig_estado').disable();
	        this.getBoton('btnChequeoDocumentosWf').disable();
	        this.getBoton('diagrama_gantt').disable();
        }
       return tb
    },
    preparaMenu:function(n){
    	var tb = Phx.vista.Movimiento.superclass.preparaMenu.call(this);
      	var data = this.getSelectedData();
      	var tb = this.tbar;

        this.getBoton('btnReporte').enable(); 
        this.getBoton('btnChequeoDocumentosWf').enable();
        this.getBoton('diagrama_gantt').enable();

        //Enable/disable WF buttons by status
        this.getBoton('ant_estado').enable();
        this.getBoton('sig_estado').enable();
        if(data.estado=='borrador'){
        	this.getBoton('ant_estado').disable();
        }
        if(data.estado=='finalizado'||data.estado=='cancelado'){
        	//this.getBoton('ant_estado').disable();
        	//this.getBoton('sig_estado').disable();
        }
        

        return tb;
    },
    antEstado:function(){
        var rec=this.sm.getSelected();
            Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/AntFormEstadoWf.php',
            'Estado de Wf',
            {
                modal:true,
                width:450,
                height:250
            }, {data:rec.data}, this.idContenedor,'AntFormEstadoWf',
            {
                config:[{
                  event:'beforesave',
                  delegate: this.onAntEstado,
                }
            ],
            scope:this
        })
    },
    onAntEstado:function(wizard,resp){
        Phx.CP.loadingShow(); 
        Ext.Ajax.request({ 
            url:'../../sis_kactivos_fijos/control/Movimiento/anteriorEstadoMovimiento',
            params:{
                    id_proceso_wf:resp.id_proceso_wf,
                    id_estado_wf:resp.id_estado_wf,  
                    obs:resp.obs
             },
            argument:{wizard:wizard},  
            success:this.successWizard,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });
    },
    sigEstado:function(){
		var rec=this.sm.getSelected();

		this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
	        'Estado de Wf',
	        {
	            modal:true,
	            width:700,
	            height:450
	        }, {data:{
	               id_estado_wf:rec.data.id_estado_wf,
	               id_proceso_wf:rec.data.id_proceso_wf,
	               fecha_ini:rec.data.fecha_mov,
	            }}, this.idContenedor,'FormEstadoWf',
	        {
	            config:[{
                  event:'beforesave',
                  delegate: this.onSaveWizard,
                  
                }],
	            scope:this
	        });        
    },
    onSaveWizard:function(wizard,resp){
        Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Movimiento/siguienteEstadoMovimiento',
            params:{
                id_proceso_wf_act:  resp.id_proceso_wf_act,
                id_estado_wf_act:   resp.id_estado_wf_act,
                id_tipo_estado:     resp.id_tipo_estado,
                id_funcionario_wf:  resp.id_funcionario_wf,
                id_depto_wf:        resp.id_depto_wf,
                obs:                resp.obs,
                json_procesos:      Ext.util.JSON.encode(resp.procesos)
                },
            success:this.successWizard,
            failure: this.conexionFailure,
            argument:{wizard:wizard},
            timeout:this.timeout,
            scope:this
        });
    },
    successWizard:function(resp){
        Phx.CP.loadingHide();
        resp.argument.wizard.panel.destroy()
        this.reload();
    },
    loadCheckDocumentosPlanWf:function() {
        var rec=this.sm.getSelected();
        rec.data.nombreVista = this.nombreVista;
        Phx.CP.loadWindows('../../../sis_workflow/vista/documento_wf/DocumentoWf.php',
            'Chequear documento del WF',
            {
                width:'90%',
                height:500
            },
            rec.data,
            this.idContenedor,
            'DocumentoWf'
    	)
    },

    onButtonNew: function() {
    	this.hideFields();
    	this.window.setSize(450,130);
    	Phx.vista.Movimiento.superclass.onButtonNew.call(this);
    },

    hideFields: function() {
    	this.Cmp.estado.hide();
    	this.Cmp.codigo.hide();
    	this.Cmp.fecha_mov.hide();
    	this.Cmp.glosa.hide();
    	this.Cmp.id_depto.hide();
    	this.Cmp.id_oficina.hide();
    	this.Cmp.direccion.hide();
    	this.Cmp.fecha_hasta.hide();
    	this.Cmp.id_funcionario.hide();
    	this.Cmp.id_persona.hide();
    	this.Cmp.id_depto_dest.hide();
    	this.Cmp.id_deposito_dest.hide();
    	this.Cmp.id_funcionario_dest.hide();
    	this.Cmp.id_movimiento_motivo.hide();
    }

})
</script>
		
		