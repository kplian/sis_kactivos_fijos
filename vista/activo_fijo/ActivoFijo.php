<?php
/**
*@package pXP
*@file gen-ActivoFijo.php
*@author  (admin)
*@date 29-10-2015 03:18:45
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijo = Ext.extend(Phx.gridInterfaz, {
    constructor: function(config) {
        this.maestro = config.maestro;
        //llama al constructor de la clase padre
        Phx.vista.ActivoFijo.superclass.constructor.call(this, config);
        this.init();
        this.load({
            params: {
                start: 0,
                limit: this.tam_pag
            }
        });

        this.detailsTemplate = new Ext.XTemplate(
        	'<div class="details">',
				'<tpl for=".">',
					'<img src="../../../sis_kactivos_fijos/upload/{foto}" height="100" width="150"><div class="details-info">',
					'<b>Código: </b>',
					'<span>{codigo}</span>',
					'<br><b>Estado: </b>',
					'<span>{estado}</span>',
                    '<br><b>Denominación: </b>',
                    '<span>{denominacion}</span>',
                    '<br><b>Fecha Compra: </b>',
                    '<span>{fecha_compra}</span>',
                    '<br><b>Proveedor: </b>',
                    '<span>{proveedor}</span>',
                    '<br><b>Responsable: </b>',
                    '<span>{funcionario}</span>',
                    '<br><b>Oficina: </b>',
                    '<span>{oficina}</span>',
                    '<br><b>Monto compra: </b>',
                    '<span>{monto_compra}</span>',
                    '<br><b>Monto Vigente: </b>',
                    '<span>{monto_vigente}</span>',
                    '<br><b>Depreciación Acum.: </b>',
                    '<span>{depreciacion_acum}</span>',
                    '<br><b>Depreciación Periodo: </b>',
                    '<span>{depreciacion_per}</span>',
                    '<br><b>Vida útil: </b>',
                    '<span>{vida_util}</span>',
					'</div>',
				'</tpl>',
			'</div>'
		);

		this.detailsTemplate.compile();
    },
    Atributos: [{
        //configuracion del componente
        config: {
            labelSeparator: '',
            inputType: 'hidden',
            name: 'id_activo_fijo'
        },
        type: 'Field',
        form: true
    }, {
        config: {
            name: 'codigo',
            fieldLabel: 'Código',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 50
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.codigo',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'estado',
            fieldLabel: 'Estado',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 15
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.estado',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
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
                fields: ['id_clasificacion', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'cla.nombre#cla.codigo'
                }
            }),
            valueField: 'id_clasificacion',
            displayField: 'nombre',
            gdisplayField: 'clasificacion',
            hiddenName: 'id_clasificacion',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['clasificacion']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'cla.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'cantidad_revaloriz',
            fieldLabel: '#Reval.',
            allowBlank: true,
            anchor: '80%',
            gwidth: 50,
            maxLength: 4
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.cantidad_revaloriz',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'denominacion',
            fieldLabel: 'Denominación',
            allowBlank: true,
            anchor: '80%',
            gwidth: 250,
            maxLength: 100
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.denominacion',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'vida_util',
            fieldLabel: 'Vida Útil',
            allowBlank: true,
            anchor: '80%',
            gwidth: 50,
            maxLength: 4
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.vida_util',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'depreciacion_per',
            fieldLabel: 'Dep.Periodo',
            allowBlank: true,
            anchor: '80%',
            gwidth: 80,
            maxLength: -5
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.depreciacion_per',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'depreciacion_acum',
            fieldLabel: 'Dep.Acum.',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: -5
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.depreciacion_acum',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'monto_vigente',
            fieldLabel: 'Monto Vigente',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: -5
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.monto_vigente',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'fecha_ult_dep',
            fieldLabel: 'Ultima Dep.',
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
            pfiltro: 'afij.fecha_ult_dep',
            type: 'date'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_funcionario',
            fieldLabel: 'Responsable',
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['funcionario']);
            }
        },
        type: 'Field',
        filters: {
            pfiltro: 'per.nombre_completo2',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_persona',
            fieldLabel: 'Custodio',
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['persona']);
            }
        },
        type: 'Field',
        filters: {
            pfiltro: 'per.nombre_completo2',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'foto',
            fieldLabel: 'foto',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 100
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.foto',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_proveedor',
            fieldLabel: 'id_proveedor',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_proveedor',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'estado_reg',
            fieldLabel: 'Estado Reg.',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 10
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.estado_reg',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }, {
        config: {
            name: 'fecha_compra',
            fieldLabel: 'fecha_compra',
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
            pfiltro: 'afij.fecha_compra',
            type: 'date'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_cat_estado_fun',
            fieldLabel: 'id_cat_estado_fun',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_cat_estado_fun',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'ubicacion',
            fieldLabel: 'ubicacion',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 1000
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.ubicacion',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'documento',
            fieldLabel: 'documento',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 100
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.documento',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'observaciones',
            fieldLabel: 'observaciones',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 5000
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.observaciones',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'monto_rescate',
            fieldLabel: 'monto_rescate',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 1179650
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.monto_rescate',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_deposito',
            fieldLabel: 'id_deposito',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_deposito',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'monto_compra',
            fieldLabel: 'monto_compra',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: -5
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.monto_compra',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_moneda',
            fieldLabel: 'id_moneda',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_moneda',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'depreciacion_mes',
            fieldLabel: 'depreciacion_mes',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: -5
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.depreciacion_mes',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'descripcion',
            fieldLabel: 'descripcion',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 5000
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.descripcion',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_moneda_orig',
            fieldLabel: 'id_moneda_orig',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_moneda_orig',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'fecha_ini_dep',
            fieldLabel: 'fecha_ini_dep',
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
            pfiltro: 'afij.fecha_ini_dep',
            type: 'date'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_cat_estado_compra',
            fieldLabel: 'id_cat_estado_compra',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_cat_estado_compra',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'vida_util_original',
            fieldLabel: 'vida_util_original',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 4
        },
        type: 'NumberField',
        filters: {
            pfiltro: 'afij.vida_util_original',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_centro_costo',
            fieldLabel: 'id_centro_costo',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_centro_costo',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_oficina',
            fieldLabel: 'id_oficina',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_oficina',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'id_depto',
            fieldLabel: 'id_depto',
            allowBlank: true,
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_/control/Clase/Metodo',
                id: 'id_',
                root: 'datos',
                sortInfo: {
                    field: 'nombre',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_', 'nombre', 'codigo'],
                remoteSort: true,
                baseParams: {
                    par_filtro: 'movtip.nombre#movtip.codigo'
                }
            }),
            valueField: 'id_',
            displayField: 'nombre',
            gdisplayField: 'desc_',
            hiddenName: 'id_depto',
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
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['desc_']);
            }
        },
        type: 'ComboBox',
        id_grupo: 0,
        filters: {
            pfiltro: 'movtip.nombre',
            type: 'string'
        },
        grid: true,
        form: true
    }, {
        config: {
            name: 'usr_reg',
            fieldLabel: 'Creado por',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 4
        },
        type: 'Field',
        filters: {
            pfiltro: 'usu1.cuenta',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }, {
        config: {
            name: 'fecha_reg',
            fieldLabel: 'Fecha creación',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            format: 'd/m/Y',
            renderer: function(value, p, record) {
                return value ? value.dateFormat('d/m/Y H:i:s') : ''
            }
        },
        type: 'DateField',
        filters: {
            pfiltro: 'afij.fecha_reg',
            type: 'date'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }, {
        config: {
            name: 'usuario_ai',
            fieldLabel: 'Funcionaro AI',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 300
        },
        type: 'TextField',
        filters: {
            pfiltro: 'afij.usuario_ai',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }, {
        config: {
            name: 'id_usuario_ai',
            fieldLabel: 'Funcionaro AI',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 4
        },
        type: 'Field',
        filters: {
            pfiltro: 'afij.id_usuario_ai',
            type: 'numeric'
        },
        id_grupo: 1,
        grid: false,
        form: false
    }, {
        config: {
            name: 'usr_mod',
            fieldLabel: 'Modificado por',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            maxLength: 4
        },
        type: 'Field',
        filters: {
            pfiltro: 'usu2.cuenta',
            type: 'string'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }, {
        config: {
            name: 'fecha_mod',
            fieldLabel: 'Fecha Modif.',
            allowBlank: true,
            anchor: '80%',
            gwidth: 100,
            format: 'd/m/Y',
            renderer: function(value, p, record) {
                return value ? value.dateFormat('d/m/Y H:i:s') : ''
            }
        },
        type: 'DateField',
        filters: {
            pfiltro: 'afij.fecha_mod',
            type: 'date'
        },
        id_grupo: 1,
        grid: true,
        form: false
    }],
    tam_pag: 50,
    title: 'Activos Fijos',
    ActSave: '../../sis_kactivos_fijos/control/ActivoFijo/insertarActivoFijo',
    ActDel: '../../sis_kactivos_fijos/control/ActivoFijo/eliminarActivoFijo',
    ActList: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijo',
    id_store: 'id_activo_fijo',
    fields: [{
        name: 'id_activo_fijo',
        type: 'numeric'
    }, {
        name: 'id_persona',
        type: 'numeric'
    }, {
        name: 'cantidad_revaloriz',
        type: 'numeric'
    }, {
        name: 'foto',
        type: 'string'
    }, {
        name: 'id_proveedor',
        type: 'numeric'
    }, {
        name: 'estado_reg',
        type: 'string'
    }, {
        name: 'fecha_compra',
        type: 'date',
        dateFormat: 'Y-m-d'
    }, {
        name: 'monto_vigente',
        type: 'numeric'
    }, {
        name: 'id_cat_estado_fun',
        type: 'numeric'
    }, {
        name: 'ubicacion',
        type: 'string'
    }, {
        name: 'vida_util',
        type: 'numeric'
    }, {
        name: 'documento',
        type: 'string'
    }, {
        name: 'observaciones',
        type: 'string'
    }, {
        name: 'fecha_ult_dep',
        type: 'date',
        dateFormat: 'Y-m-d'
    }, {
        name: 'monto_rescate',
        type: 'numeric'
    }, {
        name: 'denominacion',
        type: 'string'
    }, {
        name: 'id_funcionario',
        type: 'numeric'
    }, {
        name: 'id_deposito',
        type: 'numeric'
    }, {
        name: 'monto_compra',
        type: 'numeric'
    }, {
        name: 'id_moneda',
        type: 'numeric'
    }, {
        name: 'depreciacion_mes',
        type: 'numeric'
    }, {
        name: 'codigo',
        type: 'string'
    }, {
        name: 'descripcion',
        type: 'string'
    }, {
        name: 'id_moneda_orig',
        type: 'numeric'
    }, {
        name: 'fecha_ini_dep',
        type: 'date',
        dateFormat: 'Y-m-d'
    }, {
        name: 'id_cat_estado_compra',
        type: 'numeric'
    }, {
        name: 'depreciacion_per',
        type: 'numeric'
    }, {
        name: 'vida_util_original',
        type: 'numeric'
    }, {
        name: 'depreciacion_acum',
        type: 'numeric'
    }, {
        name: 'estado',
        type: 'string'
    }, {
        name: 'id_clasificacion',
        type: 'numeric'
    }, {
        name: 'id_centro_costo',
        type: 'numeric'
    }, {
        name: 'id_oficina',
        type: 'numeric'
    }, {
        name: 'id_depto',
        type: 'numeric'
    }, {
        name: 'id_usuario_reg',
        type: 'numeric'
    }, {
        name: 'fecha_reg',
        type: 'date',
        dateFormat: 'Y-m-d H:i:s.u'
    }, {
        name: 'usuario_ai',
        type: 'string'
    }, {
        name: 'id_usuario_ai',
        type: 'numeric'
    }, {
        name: 'id_usuario_mod',
        type: 'numeric'
    }, {
        name: 'fecha_mod',
        type: 'date',
        dateFormat: 'Y-m-d H:i:s.u'
    }, {
        name: 'usr_reg',
        type: 'string'
    }, {
        name: 'usr_mod',
        type: 'string'
    }, {
        name: 'persona',
        type: 'string'
    }, {
        name: 'desc_proveedor',
        type: 'string'
    }, {
        name: 'estado_fun',
        type: 'string'
    }, {
        name: 'estado_compra',
        type: 'string'
    }, {
        name: 'clasificacion',
        type: 'string'
    }, {
        name: 'centro_costo',
        type: 'string'
    }, {
        name: 'oficina',
        type: 'string'
    }, {
        name: 'depto',
        type: 'string'
    }, {
        name: 'funcionario',
        type: 'string'
    }],
    arrayDefaultColumHidden: ['fecha_reg', 'usr_reg', 'fecha_mod', 'usr_mod', 'estado_reg', 'id_usuario_ai', 'usuario_ai', 'id_persona', 'foto', 'id_proveedor', 'fecha_compra', 'id_cat_estado_fun', 'ubicacion', 'documento', 'observaciones', 'monto_rescate', 'id_deposito', 'monto_compra', 'id_moneda', 'depreciacion_mes', 'descripcion', 'id_moneda_orig', 'fecha_ini_dep', 'id_cat_estado_compra', 'vida_util_original', 'id_centro_costo', 'id_oficina', 'id_depto'],
    sortInfo: {
        field: 'id_activo_fijo',
        direction: 'ASC'
    },
    bdel: true,
    //'<img src="../../../sis_kactivos_fijos/upload/{foto}" height="100" width="150">',
    bsave: true,
    rowExpander: new Ext.ux.grid.RowExpander({
        tpl: new Ext.Template('<br>', '<table><tr><td rowspan="5"><img src="../../../sis_kactivos_fijos/upload/{foto}" height="100" width="150"></td></tr><tr><td colspan ="2"><b>Descripción:</b> {descripcion}</td></tr><tr><td><b>Responsable:</b> {funcionario}</td><td><b>Fecha Ini. Dep.:</b> {fecha_ini_dep}</td></tr><tr><td><b>Ubicación:</b> {ubicacion}</td><td><b>Documento:</b> {documento}</td></tr><tr><td><b>Oficina:</b> {oficina}</td><td><b>Estado funcional:</b> {estado_fun}</td></tr></table>')
    }),
    bodyStyleForm: 'padding:5px;', 
    borderForm: true,
    frameForm: false, 
    paddingForm: '5 5 5 5',
    onButtonNew: function() {
        this.crearVentana();
        this.abrirVentana('new');
    },
    onButtonEdit: function() {
        this.crearVentana();
        this.abrirVentana('edit');
    },
    crearVentana: function() {
        if(!this.afWindow){
            this.form = new Ext.form.FormPanel({
                id: this.idContenedor + '_af_form',
                items: [{
                    region: 'center',
                    layout: 'column',
                    border: false,
                    items: [{
                        xtype: 'tabpanel',
                        plain: true,
                        activeTab: 0,
                        height: 380,
                        deferredRender: false,
                        defaults: {
                            bodyStyle: 'padding:10px'
                        },
                        items: [{
                            title: 'Principal',
                            layout: 'form',
                            defaults: {
                                width: 400
                            },
                            defaultType: 'textfield',
                            items: [{
                                fieldLabel: 'Código',
                                name: 'codigo',
                                disabled: true,
                                id: this.idContenedor+'_codigo'
                            }, {
                                fieldLabel: 'Estado',
                                name: 'estado',
                                disabled: true,
                                id: this.idContenedor+'_estado'
                            }, {
                                xtype: 'compositefield',
                                fieldLabel: 'Revalorizado',
                                msgTarget: 'side',
                                anchor: '-20',
                                disabled: true,
                                defaults: {
                                    flex: 1
                                },
                                items: [{
                                    xtype: 'checkbox',
                                    name: 'reval',
                                    width: 10,
                                    disabled: true,
                                    id: this.idContenedor+'_reval'
                                }, {
                                    xtype: 'numberfield',
                                    name: 'cantidad_revaloriz',
                                    width: 30,
                                    disabled: true,
                                    id: this.idContenedor+'_cantidad_revaloriz'
                                }]
                            }, {
                                xtype: 'combo',
                                fieldLabel: 'Depto.',
                                name: 'id_depto',
                                allowBlank: false,
                                id: this.idContenedor+'_id_depto'
                            }, {
                                xtype: 'combo',
                                fieldLabel: 'Clasificación',
                                name: 'id_clasificacion',
                                allowBlank: false,
                                id: this.idContenedor+'_id_clasificacion'
                            }, {
                                fieldLabel: 'Vida útil inicial',
                                name: 'vida_util_original',
                                allowBlank: false,
                                id: this.idContenedor+'_vida_util_original'
                            }, {
                                fieldLabel: 'Denominación',
                                name: 'denominacion',
                                allowBlank: false,
                                id: this.idContenedor+'_denominacion'
                            }, {
                                xtype: 'textarea',
                                fieldLabel: 'Descripción',
                                name: 'descripcion',
                                allowBlank: false,
                                id: this.idContenedor+'_descripcion'
                            }, {
                                xtype: 'textarea',
                                fieldLabel: 'Observaciones',
                                name: 'observaciones',
                                id: this.idContenedor+'_observaciones'
                            }]
                        }, {
                            title: 'Ubicación Física',
                            layout: 'form',
                            defaults: {
                                width: 400
                            },
                            defaultType: 'textfield',
                            items: [{
                                xtype: 'datefield',
                                fieldLabel: 'Fecha Asignación',
                                name: 'fecha_asignacion',
                                disabled: true,
                                id: this.idContenedor+'_fecha_asignacion'
                            }, {
                                xtype: 'combo',
                                fieldLabel: 'Depósito',
                                name: 'id_deposito',
                                allowBlank: false,
                                id: this.idContenedor+'_id_deposito'
                            }, {
                                fieldLabel: 'Oficina',
                                name: 'id_oficina',
                                allowBlank: false,
                                disabled: true,
                                id: this.idContenedor+'_id_oficina'
                            }, {
                                fieldLabel: 'Responsable',
                                name: 'id_funcionario',
                                allowBlank: false,
                                disabled: true,
                                id: this.idContenedor+'_id_funcionario'
                            }, {
                                fieldLabel: 'Custodio',
                                name: 'id_persona',
                                disabled: true,
                                id: this.idContenedor+'_id_persona'
                            }, {
                                xtype: 'textarea',
                                fieldLabel: 'Ubicación',
                                name: 'ubicacion',
                                id: this.idContenedor+'_ubicacion'
                            }]
                        }, {
                            title: 'Datos Compra',
                            layout: 'form',
                            defaults: {
                                width: 400
                            },
                            defaultType: 'textfield',
                            items: [{
                                xtype: 'combo',
                                fieldLabel: 'Proveedor',
                                name: 'id_proveedor',
                                allowBlank: false,
                                id: this.idContenedor+'_id_proveedor'
                            }, {
                                xtype: 'datefield',
                                fieldLabel: 'Fecha Compra',
                                name: 'fecha_compra',
                                allowBlank: false,
                                id: this.idContenedor+'_fecha_compra'
                            }, {
                                fieldLabel: 'Documento',
                                name: 'documento',
                                id: this.idContenedor+'_documento'
                            }, {
                                fieldLabel: 'Monto compra',
                                name: 'monto_compra',
                                allowBlank: false,
                                id: this.idContenedor+'_monto_compra'
                            }]
                        }, {
                            title: 'Datos Depreciación',
                            layout: 'form',
                            defaults: {
                                width: 400
                            },
                            defaultType: 'textfield',
                            items: [{
                                xtype: 'datefield',
                                fieldLabel: 'Fecha inicio Depreciación',
                                name: 'fecha_ini_dep',
                                allowBlank: false,
                                id: this.idContenedor+'_fecha_ini_dep'
                            }, {
                                fieldLabel: 'Monto Vigente',
                                name: 'monto_vigente',
                                disabled: true,
                                id: this.idContenedor+'_monto_vigente'
                            }, {
                                fieldLabel: 'Depreciación Acumulada',
                                name: 'depreciacion_acum',
                                disabled: true,
                                id: this.idContenedor+'_depreciacion_acum'
                            }, {
                                fieldLabel: 'Depreciación Periodo',
                                name: 'depreciacion_per',
                                disabled: true,
                                id: this.idContenedor+'_depreciacion_per'
                            }, {
                                fieldLabel: 'Depreciación Mes',
                                name: 'depreciacion_per',
                                disabled: true,
                                id: this.idContenedor+'_depreciacion_per'
                            }, {
                                xtype: 'datefield',
                                fieldLabel: 'Fecha última Depreciación',
                                name: 'fecha_ult_dep',
                                disabled: true,
                                id: this.idContenedor+'_fecha_ult_dep'
                            }]
                        }]
                    }]
                }],
                //fileUpload: me.fileUpload,
                padding: this.paddingForm,
                bodyStyle: this.bodyStyleForm,
                border: this.borderForm,
                frame: this.frameForm, 
                autoScroll: false,
                autoDestroy: true,
                autoScroll: true,
                region: 'center'
            });

            this.afWindow = new Ext.Window({
                width: 800,
                height: 450,
                modal: true,
                closeAction: 'hide',
                labelAlign: 'top',
                title: 'Activos Fijos',
                bodyStyle: 'padding:5px',
                layout: 'border',
                items: [{
                    region: 'west',
                    split: true,
                    width: 200,
                    minWidth: 150,
                    maxWidth: 250,
                    items: [{
                        id: 'img-detail-panel'
                    }]
                },this.form],
                buttons: [{
                    text: 'Guardar',
                    disabled: true
                }, {
                    text: 'Declinar',
                    handler: function() {
                        this.afWindow.hide();
                    },
                    scope: this
                }]
            });
        }
    },
    abrirVentana: function(tipo){
        var data;
        if(tipo=='edit'){
            //Carga datos
            this.cargaFormulario(this.sm.getSelected().data);            
            data = this.sm.getSelected().data;
        } else{
            //Inicializa el formulario
            this.form.getForm().reset;
            data = {foto:'default.jpg'}
        }
        //Renderea la imagen, abre la ventana
        this.afWindow.show();
        this.renderFoto(data);
    },
    cargaFormulario: function(data){
        Ext.getCmp(this.idContenedor+'_codigo').setValue(data.codigo);
        Ext.getCmp(this.idContenedor+'_estado').setValue(data.estado);
    },
    renderFoto: function(data){
        var detailEl = Ext.getCmp('img-detail-panel').body;
        /*var data = {
            foto:'af_2_001.jpg', 
            codigo:'CD-SD-AS-0001',
            estado:'alta',
            denominacion:'Escritorio para computadora de 3 cajones',
            fecha_compra: '10-12-2014',
            proveedor: 'Las 3 carapelas SRL',
            funcionario: 'Carlos Julian Gutierrez Villazón',
            oficina: 'Aeropuerto Cochabamba',
            monto_compra: '2.564',
            monto_vigente: '1.982.23'
        };*/
        this.detailsTemplate.overwrite(detailEl, data);
        detailEl.slideIn('l', {stopFx:true,duration:.3});
    },

})
</script>
		
		