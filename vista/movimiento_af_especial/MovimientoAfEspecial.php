<?php
/**
*@package pXP
*@file gen-MovimientoAfEspecial.php
*@author  (rchumacero)
*@date 22-05-2019 21:34:37
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

***************************************************************************
#ISSUE	SIS 	EMPRESA		FECHA 		AUTOR	DESCRIPCION
 #2		KAF		ETR 		22-05-2019	RCM		Opción para traspasar valores de un activo fijo a otro
 #36	KAF		ETR 		21/10/2019	RCM		Modificación de proceso de División de Valores
 #39    KAF     ETR     	29-11-2019  RCM     Importación masiva Distribución de valores
 #45    KAF     ETR         21-02-2020  MZM     Adicion de columna costo_orig
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoAfEspecial = Ext.extend(Phx.gridInterfaz, {

	constructor: function(config) {
		this.maestro = config;

    	//Llama al constructor de la clase padre
		Phx.vista.MovimientoAfEspecial.superclass.constructor.call(this, config);
		this.init();
		this.store.baseParams.id_movimiento_af = this.maestro.id_movimiento_af; //correccion 29/01/2020
		this.load({params: {start: 0, limit: this.tam_pag }});

		//Seteo del ID del padre
		this.Atributos[2].valorInicial = this.maestro.id_movimiento_af;
		this.Atributos[4].valorInicial = Ext.util.Format.usMoney(this.maestro.importe); //#36 adicion de formato

		//Eventos
		this.Cmp.tipo.on('select', this.onSelectTipo, this);
		this.Cmp.importe.on('blur', this.onBlurImporte, this);
		this.Cmp.porcentaje.on('blur', this.onBlurPorcentaje, this);
		this.Cmp.opcion.on('select', this.onSelectOpcion, this);

		//Ocultar campos
		this.Cmp.id_activo_fijo.hide();
		this.Cmp.id_clasificacion.hide();
		this.Cmp.denominacion.hide();
		this.Cmp.vida_util.hide();
		this.Cmp.fecha_ini_dep.hide();
		this.Cmp.id_centro_costo.hide();
		this.Cmp.id_almacen.hide();
		//Inicio #39
		this.Cmp.nro_serie.hide();
		this.Cmp.marca.hide();
		this.Cmp.descripcion.hide();
		this.Cmp.cantidad_det.hide();
		this.Cmp.id_unidad_medida.hide();
		this.Cmp.ubicacion.hide();
		this.Cmp.id_ubicacion.hide();
		this.Cmp.id_funcionario.hide();
		this.Cmp.fecha_compra.hide();
		this.Cmp.id_moneda.hide();
		this.Cmp.id_grupo.hide();
		this.Cmp.id_grupo_clasif.hide();
		this.Cmp.observaciones.hide();
		//Fin #39

		//Seteo de fecha para gestión del combo de centro de costo
		var fecha = this.maestro.fecha_mov.format("d/m/Y");
		Ext.apply(this.Cmp.id_centro_costo.store.baseParams, { fecha: fecha });
		this.Cmp.id_centro_costo.modificado = true;

		//Grid
       	this.grid.on('cellclick', this.abrirEnlace, this);
	},

	Atributos:[
		{
			//configuracion del componente
			config: {
				labelSeparator:'',
				inputType:'hidden',
				name: 'id_movimiento_af_especial'
			},
			type:'Field',
			form: true
		},
		{
			//configuracion del componente
			config: {
				labelSeparator:'',
				inputType:'hidden',
				name: 'id_activo_fijo_valor'
			},
			type:'Field',
			form: true
		},
		{
			//configuracion del componente
			config: {
				labelSeparator:'',
				inputType:'hidden',
				name: 'id_movimiento_af'
			},
			type:'Field',
			form: true
		},
		{
			//configuracion del componente
			config: {
				labelSeparator:'',
				inputType:'hidden',
				name: 'id_activo_fijo_creado'
			},
			type:'Field',
			form: true
		},
		{
			config: {
				name: 'importe_orig',
				fieldLabel: 'Valor original',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 3,
				maxValue: 100,
				disabled: true
			},
			type: 'TextField', //#36 cambio de Number a Textfield
			id_grupo: 1,
			grid: false,
			form: true
		},
		{
			config: {
				name: 'saldo_ant',
				fieldLabel: 'Saldo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 1179650,
				disabled: true
			},
			type: 'TextField', //#36 cambio de NumberField a textField
			filters: {pfiltro: 'moafes.importe', type: 'numeric'},
			id_grupo: 1,
			grid: false,
			form: true
		},
		{
			config: {
				name: 'tipo',
				fieldLabel: 'Tipo',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'tipo',
				hiddenName: 'tipo',
				gwidth: 80,
				baseParams:{
					cod_subsistema: 'KAF',
					catalogo_tipo: 'tmovimiento_af_especial__tipo'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 0,
			filters: {pfiltro: 'moafes.tipo', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'opcion',
				fieldLabel: 'Opción',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'opcion',
				hiddenName: 'opcion',
				gwidth: 80,
				baseParams:{
					cod_subsistema: 'KAF',
					catalogo_tipo: 'tmovimiento_af_especial__forma'
				},
				valueField: 'codigo'
			},
			type: 'ComboRec',
			id_grupo: 0,
			filters: {pfiltro: 'moafes.codigo', type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'porcentaje',
				fieldLabel: 'Porcentaje (0 - 100)',
				allowBlank: true,
				anchor: '80%',
				gwidth: 125,
				maxLength: 6, //#36 aumento de tamaño de 3 a 6
				maxValue: 100
			},
			type: 'NumberField',
			filters: {pfiltro: 'moafes.porcentaje', type:'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'importe',
				fieldLabel: 'Importe', //#36 cambio de etiqueta de Bs por UFV
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 1179650,
				//Inicio #36
				renderer: function(value, metadata, rec, index){
		            return String.format('{0}', Ext.util.Format.number(value, '0,000.00'));
		        }
		        //Fin #36
			},
			type: 'NumberField',
			filters: {pfiltro: 'moafes.importe', type: 'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		//Inicio RCM 03/02/2020
		{
			config: {
				name: 'costo_orig',
				fieldLabel: 'Costo Original', //#45
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 1179650,
				//Inicio #36
				renderer: function(value, metadata, rec, index){
		            return String.format('{0}', Ext.util.Format.number(value, '0,000.00'));
		        }
		        //Fin #36
			},
			type: 'NumberField',
			filters: {pfiltro: 'moafes.costo_orig', type: 'numeric'}, //#45
			id_grupo: 1,
			grid: true,
			form: true
		},
		//Fin RCM
		{
			config: {
				name: 'id_activo_fijo',
				fieldLabel: 'Activo Fijo',
				allowBlank: true,
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
					baseParams: {par_filtro: 'afij.denominacion#afij.codigo#afij.descripcion#afij.codigo_ant'}
				}),
				valueField: 'id_activo_fijo',
				displayField: 'denominacion',
				gdisplayField: 'codigo', //'denominacion_af', //#45
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
				//Inicio #45
				/*renderer: function(value,p,record){
					return '<tpl for="."><div class="x-combo-list-item"><i class="fa fa-reply-all" aria-hidden="true"></i><p><b>Código: </b> ' + record.data['codigo'] + '</p><p><b>Denominación: </b> ' + record.data['denominacion'] + '</p></div></tpl>';

				},*/
				//Fin #45
				tpl: '<tpl for="."><div class="x-combo-list-item"><p><b>Codigo:</b> {codigo}</p><p><b>Activo Fijo:</b> {denominacion}</p><p><b>Código SAP:</b> {codigo_ant}</p></div></tpl>'
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'af.denominacion#af.codigo#af.codigo_ant#af.descripcion', type: 'string'},
			grid: true,
			form: true,
			bottom_filter: true
		},
		{
			config: {
				name: 'id_clasificacion',
				fieldLabel: 'Clasificación',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_kactivos_fijos/control/Clasificacion/ListarClasificacionTree',
                    id: 'id_clasificacion',
                    root: 'datos',
                    sortInfo: {
                        field: 'orden',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_clasificacion','clasificacion', 'id_clasificacion_fk','tipo_activo','depreciable','vida_util','clasificacion_n1', 'clasificacion_n2'],
                    remoteSort: true,
                    baseParams: {
                        par_filtro: 'claf.clasificacion'
                    }
				}),
				valueField: 'id_clasificacion',
				displayField: 'clasificacion',
				gdisplayField: 'clasificacion',
				hiddenName: 'id_clasificacion',
				mode: 'remote',
                triggerAction: 'all',
                typeAhead: false,
                lazyRender: true,
                pageSize: 15,
                queryDelay: 1000,
                minChars: 2,
                tpl: '<tpl for="."><div class="x-combo-list-item"><p><b>{clasificacion}</b><br>&nbsp&nbsp&nbsp&nbsp&nbsp<small><i>{clasificacion_n1}</i></small><br>&nbsp&nbsp&nbsp&nbsp&nbsp<small><i>{clasificacion_n2}</i></small></p></div></tpl>',
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['clasificacion']);
				}
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'movtip.nombre',type: 'string'},
			grid: true,
			form: true
		},
		{
			config: {
				name: 'denominacion',
				fieldLabel: 'Denominación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:500
			},
			type:'TextField',
			filters: {pfiltro:'moafes.denominacion', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'vida_util',
				fieldLabel: 'Vida Útil',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'NumberField',
			filters: {pfiltro:'moafes.vida_util', type:'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'fecha_ini_dep',
				fieldLabel: 'Fecha Ini.Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record){return value ? value.dateFormat('d/m/Y') : ''}
			},
			type: 'DateField',
			filters: {pfiltro:'moafes.fecha_ini_dep', type:'date'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
            config:{
                name: 'id_centro_costo',
                fieldLabel: 'Centro Costo',
                allowBlank: true,
                tinit: false,
                resizable: true,
                origen: 'CENTROCOSTO',
                gdisplayField: 'codigo_cc',
                anchor: '80%',
                gwidth: 300
            },
            type: 'ComboRec',
            filters: {pfiltro:'cc.codigo_cc', type:'string'},
            bottom_filter : true,
            id_grupo: 1,
            grid: true,
            form: true
        },
        {
			config: {
				name: 'id_almacen',
				fieldLabel: 'Almacén',
				allowBlank: true,
				emptyText: 'Elija una opción...',
				store: new Ext.data.JsonStore({
					url: '../../sis_almacenes/control/Almacen/ListarAlmacen',
                    id: 'id_almacen',
                    root: 'datos',
                    sortInfo: {
                        field: 'nombre',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_almacen','nombre', 'codigo'],
                    remoteSort: true,
                    baseParams: {
                        par_filtro: 'alm.nombre'
                    }
				}),
				valueField: 'id_almacen',
				displayField: 'nombre',
				gdisplayField: 'desc_almacen',
				hiddenName: 'id_almacen',
				mode: 'remote',
                triggerAction: 'all',
                typeAhead: false,
                lazyRender: true,
                pageSize: 15,
                queryDelay: 1000,
                minChars: 2,
                tpl: '<tpl for="."><div class="x-combo-list-item"><p><b>{codigo}</b><br></p>{nombre}<p></div></tpl>',
				renderer : function(value, p, record) {
					return String.format('{0}', record.data['desc_almacen']);
				},
				gwidth: 150
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters: {pfiltro: 'alm.nombre',type: 'string'},
			grid: true,
			form: true
		},
		//Inicio #39
		{
			config: {
				name: 'nro_serie',
				fieldLabel: 'Nro.Serie',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 50
			},
			type:'TextField',
			filters: {pfiltro:'moafes.nro_serie', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'marca',
				fieldLabel: 'Marca',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 200
			},
			type:'TextField',
			filters: {pfiltro:'moafes.marca', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'descripcion',
				fieldLabel: 'Descripción',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 5000
			},
			type:'TextArea',
			filters: {pfiltro:'moafes.descripcion', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
			config: {
				name: 'cantidad_det',
				fieldLabel: 'Cantidad',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 6
			},
			type:'NumberField',
			filters: {pfiltro:'moafes.cantidad_det', type:'numeric'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
   			config:{
   				name:'id_unidad_medida',
   				tipo: 'All',
   				origen:'UNIDADMEDIDA',
   				allowBlank:true,
   				fieldLabel:'Unidad',
   				gdisplayField:'desc_unmed',
   				gwidth:200,
   				width: 350,
   				listWidth: 350,
   				//anchor: '80%',
	   			renderer:function (value, p, record){return String.format('{0}', record.data['desc_unmed']);}
       	     },
   			type:'ComboRec',
   			id_grupo:2,
   			filters:{
		        pfiltro:'um.codigo#um.descripcion',
				type:'string'
			},

   			grid:true,
   			form:true
	   	},
	   	{
			config: {
				name: 'ubicacion',
				fieldLabel: 'Ubicación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 5000
			},
			type:'TextArea',
			filters: {pfiltro:'moafes.ubicacion', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		{
            config: {
                name: 'id_ubicacion',
                fieldLabel: 'Local',
                allowBlank: false,
                emptyText: 'Local...',
                store: new Ext.data.JsonStore({
                    url: '../../sis_kactivos_fijos/control/Ubicacion/listarUbicacion',
                    id: 'id_ubicacion',
                    root: 'datos',
                    fields: ['id_ubicacion','codigo','nombre'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    baseParams: {
                        start: 0,
                        limit: 10,
                        sort: 'codigo',
                        dir: 'ASC',
                        par_filtro: 'ubic.codigo#ubic.nombre'
                    }
                }),
                valueField: 'id_ubicacion',
                displayField: 'codigo',
                gdisplayField: 'desc_ubicacion',
                mode: 'remote',
                triggerAction: 'all',
                lazyRender: true,
                pageSize: 15,
                //valueNotFoundText: 'Proveedor no encontrado',
                pageSize: 15,
                minChars: 2
            },
            type: 'ComboBox',
            id_grupo: 2,
            filters: {pfiltro: 'ubic.codigo#ubic.nombre', type:'string'},
            form: true,
            grid: true
        },
        {
            config: {
                name: 'id_funcionario',
                fieldLabel: 'Responsable',
                allowBlank: false,
                emptyText: 'Responsable...',
                store: new Ext.data.JsonStore({
                    url: '../../sis_organigrama/control/Funcionario/listarFuncionario',
                    root: 'datos',
                    sortInfo:{
                        field: 'desc_person',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_funcionario','codigo','desc_person','ci','documento','telefono','celular','correo'],
                    remoteSort: true,
                    baseParams: {
                        start: 0,
                        limit: 10,
                        sort: 'codigo',
                        dir: 'ASC',
                        par_filtro:'funcio.codigo#nombre_completo1'
                    }
                }),
                tpl:'<tpl for="."><div class="x-combo-list-item"><p>{codigo}</p><p>{desc_person}</p><p>CI:{ci}</p> </div></tpl>',
                valueField: 'id_funcionario',
                displayField: 'desc_person',
                hiddenName: 'id_funcionario',
                forceSelection: true,
                typeAhead: false,
                triggerAction: 'all',
                lazyRender: true,
                mode: 'remote',
                pageSize: 10,
                queryDelay: 1000,
                listWidth: '280',
                width: 250,
                minChars: 2
            },
            type: 'ComboBox',
            id_grupo: 2,
            filters: {pfiltro: 'fun.desc_funcionario1', type:'string'},
            form: true,
            grid: true
        },
        {
        	config: {
	            name: 'fecha_compra',
	            fieldLabel: 'Fecha Compra',
	            allowBlank: true,
	            anchor: '80%',
	            gwidth: 100,
	            format: 'd/m/Y',
	            renderer: function(value, p, record) {
	                return value ? value.dateFormat('d/m/Y') : ''
	            }
	        },
	        type: 'DateField',
	        filters: {
	            pfiltro: 'moafes.fecha_compra',
	            type: 'date'
	        },
	        id_grupo: 1,
	        grid: true,
	        form: true
	    },
	    {
            config: {
                name: 'id_moneda',
                origen: 'MONEDA',
                allowBlank: false,
                fieldLabel: 'Moneda',
                gdisplayField: 'desc_moneda',
                gwidth: 50,
                 renderer: function (value, p, record){ return String.format('{0}', record.data['moneda']);}
             },
            type: 'ComboRec',
            id_grupo: 0,
            filters: {
                pfiltro: 'mon.codigo',
                type: 'string'
            },
            grid: true,
            form: true
        },
        {
            config: {
                name: 'id_grupo',
                fieldLabel: 'Grupo AE',
                allowBlank: false,
                emptyText: 'Grupo AE...',
                store: new Ext.data.JsonStore({
                    url: '../../sis_kactivos_fijos/control/Grupo/ListarGrupo',
                    id: 'id_grupo',
                    root: 'datos',
                    sortInfo:{
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_grupo','codigo','nombre'],
                    // turn on remote sorting
                    remoteSort: true,
                    baseParams: {par_filtro: 'codigo#nombre', tipo: 'grupo'}
                }),
                valueField: 'id_grupo',
                displayField: 'nombre',
                gdisplayField: 'desc_grupo_ae',//mapea al store del grid
                tpl: '<tpl for="."><div class="x-combo-list-item"><p>{codigo} - {nombre}</p> </div></tpl>',
                hiddenName: 'id_grupo',
                forceSelection: true,
                typeAhead: true,
                triggerAction: 'all',
                lazyRender: true,
                mode: 'remote',
                pageSize: 10,
                queryDelay: 1000,
                minChars: 2
            },
            type: 'ComboBox',
            id_grupo: 2,
            filters: {pfiltro: 'gru.codigo#gru.nombre', type:'string'},
            form: true,
            grid: true
        },
        {
            config: {
                name: 'id_grupo_clasif',
                fieldLabel: 'Clasificación AE',
                allowBlank: false,
                emptyText: 'Clasificación AE...',
                store: new Ext.data.JsonStore({
                    url: '../../sis_kactivos_fijos/control/Grupo/ListarGrupo',
                    id: 'id_grupo',
                    root: 'datos',
                    sortInfo:{
                        field: 'codigo',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_grupo','codigo','nombre'],
                    // turn on remote sorting
                    remoteSort: true,
                    baseParams: {par_filtro: 'codigo#nombre', tipo: 'clasificacion'}
                }),
                valueField: 'id_grupo',
                displayField: 'nombre',
                gdisplayField: 'desc_clasif_ae',//mapea al store del grid
                tpl: '<tpl for="."><div class="x-combo-list-item"><p>{codigo} - {nombre}</p> </div></tpl>',
                hiddenName: 'id_grupo_clasif',
                forceSelection: true,
                typeAhead: true,
                triggerAction: 'all',
                lazyRender: true,
                mode: 'remote',
                pageSize: 10,
                queryDelay: 1000,
                minChars: 2
            },
            type: 'ComboBox',
            id_grupo: 2,
            filters: {pfiltro: 'gru1.codigo#gru1.nombre', type:'string'},
            form: true,
            grid: true
        },
        {
			config: {
				name: 'observaciones',
				fieldLabel: 'Observaciones',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 5000
			},
			type:'TextArea',
			filters: {pfiltro:'moafes.observaciones', type:'string'},
			id_grupo: 1,
			grid: true,
			form: true
		},
		//Fin #39
		{
			config: {
				name: 'estado_reg',
				fieldLabel: 'Estado Reg.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 10
			},
			type: 'TextField',
			filters: {pfiltro: 'moafes.estado_reg', type:'string'},
			id_grupo: 1,
			grid: true,
			form:false
		},
		{
			config: {
				name: 'id_usuario_ai',
				fieldLabel: '',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'moafes.id_usuario_ai', type: 'numeric'},
			id_grupo: 1,
			grid:false,
			form:false
		},
		{
			config: {
				name: 'usr_reg',
				fieldLabel: 'Creado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'usu1.cuenta', type: 'string'},
			id_grupo: 1,
			grid: true,
			form:false
		},
		{
			config: {
				name: 'fecha_reg',
				fieldLabel: 'Fecha creación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record) { return value ? value.dateFormat('d/m/Y H:i:s') : ''}
			},
			type: 'DateField',
			filters: {pfiltro: 'moafes.fecha_reg', type: 'date'},
			id_grupo: 1,
			grid: true,
			form:false
		},
		{
			config: {
				name: 'usuario_ai',
				fieldLabel: 'Funcionaro AI',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength:300
			},
			type: 'TextField',
			filters: {pfiltro: 'moafes.usuario_ai', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'usr_mod',
				fieldLabel: 'Modificado por',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				maxLength: 4
			},
			type: 'Field',
			filters: {pfiltro: 'usu2.cuenta', type: 'string'},
			id_grupo: 1,
			grid: true,
			form: false
		},
		{
			config: {
				name: 'fecha_mod',
				fieldLabel: 'Fecha Modif.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y',
				renderer: function (value, p, record){return value ? value.dateFormat('d/m/Y H:i:s') : ''}
			},
			type: 'DateField',
			filters: {pfiltro: 'moafes.fecha_mod', type: 'date'},
			id_grupo: 1,
			grid: true,
			form: false
		}
	],
	tam_pag: 50,
	title: 'Movimiento Especial',
	ActSave: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/insertarMovimientoAfEspecial',
	ActDel: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/eliminarMovimientoAfEspecial',
	ActList: '../../sis_kactivos_fijos/control/MovimientoAfEspecial/listarMovimientoAfEspecial',
	id_store: 'id_movimiento_af_especial',
	fields: [
		{name:'id_movimiento_af_especial', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'id_activo_fijo_valor', type: 'numeric'},
		{name:'id_movimiento_af', type: 'numeric'},
		{name:'fecha_ini_dep', type: 'date',dateFormat:'Y-m-d'},
		{name:'importe', type: 'numeric'},
		{name:'vida_util', type: 'numeric'},
		{name:'id_clasificacion', type: 'numeric'},
		{name:'id_activo_fijo_creado', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_centro_costo', type: 'numeric'},
		{name:'denominacion', type: 'string'},
		{name:'porcentaje', type: 'numeric'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
		{name:'codigo', type: 'string'},
		{name:'clasificacion', type: 'string'},
		{name:'codigo_cc', type: 'string'},
		{name:'tipo', type: 'string'},
		{name:'denominacion_af', type: 'string'},
		{name:'opcion', type: 'string'},
		{name:'desc_almacen', type: 'string'},
		{name:'id_almacen', type: 'numeric'}, //#36 adicion
		//Inicio #39
		{name:'nro_serie', type: 'string'},
		{name:'marca', type: 'string'},
		{name:'descripcion', type: 'string'},
		{name:'cantidad_det', type: 'numeric'},
		{name:'id_unidad_medida', type: 'numeric'},
		{name:'ubicacion', type: 'string'},
		{name:'id_ubicacion', type: 'numeric'},
		{name:'id_funcionario', type: 'numeric'},
		{name:'fecha_compra', type: 'date'},
		{name:'id_moneda', type: 'numeric'},
		{name:'id_grupo', type: 'numeric'},
		{name:'id_grupo_clasif', type: 'numeric'},
		{name:'observaciones', type: 'string'},
		{name:'desc_unmed', type: 'string'},
		{name:'desc_ubicacion', type: 'string'},
		{name:'responsable', type: 'string'},
		{name:'moneda', type: 'string'},
		{name:'desc_grupo_ae', type: 'string'},
		{name:'desc_clasif_ae', type: 'string'},
		{name:'costo_orig', type: 'numeric'} //#45
		//Fin #39
	],
	sortInfo: {
		field: 'id_movimiento_af_especial',
		direction: 'ASC'
	},
	bdel: true,
	bsave: true,

	desplegarComponentes: function(pTipo, pEdit = false) {
		//Oculta todos los componentes por defecto
		this.Cmp.id_activo_fijo.hide();
		this.Cmp.id_clasificacion.hide();
		this.Cmp.denominacion.hide();
		this.Cmp.vida_util.hide();
		this.Cmp.fecha_ini_dep.hide();
		this.Cmp.id_centro_costo.hide();
		this.Cmp.id_almacen.hide();
		//Inicio #39
		this.Cmp.nro_serie.hide();
		this.Cmp.marca.hide();
		this.Cmp.descripcion.hide();
		this.Cmp.cantidad_det.hide();
		this.Cmp.id_unidad_medida.hide();
		this.Cmp.ubicacion.hide();
		this.Cmp.id_ubicacion.hide();
		this.Cmp.id_funcionario.hide();
		this.Cmp.fecha_compra.hide();
		this.Cmp.id_moneda.hide();
		this.Cmp.id_grupo.hide();
		this.Cmp.id_grupo_clasif.hide();
		this.Cmp.observaciones.hide();
		//Fin #39

		//Setea a todos como no obligatorios
		this.Cmp.id_activo_fijo.allowBlank = true;
		this.Cmp.id_clasificacion.allowBlank = true;
		this.Cmp.denominacion.allowBlank = true;
		this.Cmp.vida_util.allowBlank = true;
		this.Cmp.fecha_ini_dep.allowBlank = true;
		this.Cmp.id_centro_costo.allowBlank = true;
		this.Cmp.id_almacen.allowBlank = true;
		//Inicio #39
		this.Cmp.nro_serie.allowBlank = true;
		this.Cmp.marca.allowBlank = true;
		this.Cmp.descripcion.allowBlank = true;
		this.Cmp.cantidad_det.allowBlank = true;
		this.Cmp.id_unidad_medida.allowBlank = true;
		this.Cmp.ubicacion.allowBlank = true;
		this.Cmp.id_ubicacion.allowBlank = true;
		this.Cmp.id_funcionario.allowBlank = true;
		this.Cmp.fecha_compra.allowBlank = true;
		this.Cmp.id_moneda.allowBlank = true;
		this.Cmp.id_grupo.allowBlank = true;
		this.Cmp.id_grupo_clasif.allowBlank = true;
		this.Cmp.observaciones.allowBlank = true;
		//Fin #39

		//Limpia todos los componentes por defecto, menos cuando es una edición
		if(!pEdit) {

			this.Cmp.id_activo_fijo.setValue('');
			this.Cmp.id_clasificacion.setValue('');
			this.Cmp.denominacion.setValue('');
			this.Cmp.vida_util.setValue('');
			this.Cmp.fecha_ini_dep.setValue('');
			this.Cmp.id_centro_costo.setValue('');
			this.Cmp.id_almacen.setValue('');
			//Inicio #39
			this.Cmp.nro_serie.setValue('');
			this.Cmp.marca.setValue('');
			this.Cmp.descripcion.setValue('');
			this.Cmp.id_unidad_medida.setValue('');
			this.Cmp.ubicacion.setValue('');
			this.Cmp.id_ubicacion.setValue('');
			this.Cmp.id_funcionario.setValue('');
			this.Cmp.fecha_compra.setValue('');
			this.Cmp.id_moneda.setValue('');
			this.Cmp.id_grupo.setValue('');
			this.Cmp.id_grupo_clasif.setValue('');
			this.Cmp.observaciones.setValue('');
			//Fin #39
		}

		//Muestra los componentes que corresponden al tipo
		if(pTipo == 'af_exist') {

			this.Cmp.id_activo_fijo.show();
			this.Cmp.id_activo_fijo.allowBlank = false;

		} else if(pTipo == 'af_nuevo') {

			this.Cmp.id_clasificacion.allowBlank = false;
			this.Cmp.denominacion.allowBlank = false;
			this.Cmp.vida_util.allowBlank = false;
			this.Cmp.fecha_ini_dep.allowBlank = false;
			this.Cmp.id_centro_costo.allowBlank = false;
			//Inicio #39
			this.Cmp.nro_serie.allowBlank = true;
			this.Cmp.marca.allowBlank = true;
			this.Cmp.descripcion.allowBlank = false;
			this.Cmp.cantidad_det.allowBlank = false;
			this.Cmp.id_unidad_medida.allowBlank = false;
			this.Cmp.ubicacion.allowBlank = false;
			this.Cmp.id_ubicacion.allowBlank = false;
			this.Cmp.id_funcionario.allowBlank = false;
			this.Cmp.fecha_compra.allowBlank = false;
			this.Cmp.id_moneda.allowBlank = false;
			this.Cmp.id_grupo.allowBlank = false;
			this.Cmp.id_grupo_clasif.allowBlank = false;
			this.Cmp.observaciones.allowBlank = false;
			//Fin #39

			this.Cmp.id_clasificacion.show();
			this.Cmp.denominacion.show();
			this.Cmp.vida_util.show();
			this.Cmp.fecha_ini_dep.show();
			this.Cmp.id_centro_costo.show();
			//Inicio #39
			this.Cmp.nro_serie.show();
			this.Cmp.marca.show();
			this.Cmp.descripcion.show();
			this.Cmp.cantidad_det.show();
			this.Cmp.id_unidad_medida.show();
			this.Cmp.ubicacion.show();
			this.Cmp.id_ubicacion.show();
			this.Cmp.id_funcionario.show();
			this.Cmp.fecha_compra.show();
			this.Cmp.id_moneda.show();
			this.Cmp.id_grupo.show();
			this.Cmp.id_grupo_clasif.show();
			this.Cmp.observaciones.show();
			//Fin #39

		} else if(pTipo == 'af_almacen') {
			this.Cmp.id_almacen.show();
			this.Cmp.id_almacen.allowBlank = false;
		}

	},

	onSelectTipo: function(combo, record, index) {
		this.desplegarComponentes(record.data.codigo);
	},

	onButtonEdit: function() {
		Phx.vista.MovimientoAfEspecial.superclass.onButtonEdit.call(this);
		var rec = this.sm.getSelected();
		this.desplegarComponentes(rec.data.tipo, true);
		this.cargarSaldo(this.maestro.id_movimiento_af);
    	this.Cmp.importe_orig.setValue(Ext.util.Format.usMoney(this.maestro.importe)); //#36 adicion formato
    },

    onButtonNew: function() {
		Phx.vista.MovimientoAfEspecial.superclass.onButtonNew.call(this);
		this.desplegarComponentes('');
		this.cargarSaldo(this.maestro.id_movimiento_af);
    },

    onBlurImporte: function(val) {
    	if(this.isNumeric(val.value) && val.value > 0) {
    		this.Cmp.porcentaje.setValue(0);
    	}
    },

    onBlurPorcentaje: function(val) {
    	if(this.isNumeric(val.value) && val.value > 0) {
    		this.Cmp.importe.setValue(0);
    	}
    },

    isNumeric: function (obj) {
	    return !isNaN(obj - parseFloat(obj));
	},

	onSubmit: function(o, x, force) {
		//Valida que se envíe importe o porcentaje pero no ambos
		if(!this.Cmp.importe.getValue() && !this.Cmp.porcentaje.getValue()) {
			Ext.MessageBox.alert('Validación', 'Debe especificar el Importe o el Porcentaje');
			return;
		}

		//Submit
		Phx.vista.MovimientoAfEspecial.superclass.onSubmit.call(this, o, x, force);
    },

    cargarSaldo: function(idMovimientoAf) {
    	Ext.Ajax.request({
	        url: '../../sis_kactivos_fijos/control/MovimientoAf/obtenerSaldoDistribucion',
	        params: { id_movimiento_af: idMovimientoAf },
	        success: function(res, params) {
	        	var response = Ext.decode(res.responseText).ROOT;
	        	this.Cmp.saldo_ant.setValue(Ext.util.Format.usMoney(response.datos.saldo)); //#36 adición de formato
	        },
	        argument: this.argumentSave,
	        failure: this.conexionFailure,
	        timeout: this.timeout,
	        scope: this
	    });
    },

    onSelectOpcion: function(combo, record, index) {
    	if(record.data.codigo == 'porcentaje') {
    		this.Cmp.porcentaje.enable();
    		this.Cmp.importe.disable();
    		this.Cmp.importe.setValue(0);
    	}

    	if(record.data.codigo == 'importe') {
    		this.Cmp.importe.enable();
    		this.Cmp.porcentaje.disable();
    		this.Cmp.porcentaje.setValue(0);
    	}
    },

    abrirEnlace: function(cell,rowIndex,columnIndex,e){
		if(cell.colModel.getColumnHeader(columnIndex) == 'Activo Fijo'){
			var data = this.sm.getSelected().data;
			Phx.CP.loadWindows(
				'../../../sis_kactivos_fijos/vista/activo_fijo/ActivoFijo.php',
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
	}

})
</script>