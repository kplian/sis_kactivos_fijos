<?php
/**
*@package pXP
*@file gen-Clasificacion.php
*@author  (admin)
*@date 09-11-2015 01:22:17
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
	Phx.vista.ClasificacionAF = Ext.extend(Phx.arbInterfaz, {
		constructor : function(config) {
			this.maestro = config.maestro;
			Phx.vista.ClasificacionAF.superclass.constructor.call(this, config);
			this.init();
		},
		Atributos : [{
			config : {
				labelSeparator : '',
				inputType : 'hidden',
				name : 'id_clasificacion'
			},
			type : 'Field',
			form : true
		}, {
			config : {
				labelSeparator : '',
				inputType : 'hidden',
				name : 'id_clasificacion_fk'
			},
			type : 'Field',
			form : true
		}, {
			config : {
				name : 'codigo',
				fieldLabel : 'Codigo',
				allowBlank : false,
				anchor : '100%',
				maxLength : 20
			},
			type : 'TextField',
			filters : {
				pfiltro : 'claf.codigo',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
		}, {
			config : {
				name : 'nombre',
				fieldLabel : 'Nombre',
				allowBlank : false,
				anchor : '100%',
				gwidth : 100,
				maxLength : 100
			},
			type : 'TextField',
			filters : {
				pfiltro : 'claf.nombre',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
		}, {
			config : {
				name : 'descripcion',
				fieldLabel : 'Descripcion',
				allowBlank : true,
				anchor : '100%',
				gwidth : 100,
				maxLength : 100
			},
			type : 'TextField',
			filters : {
				pfiltro : 'claf.descripcion',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
		}, {
			config : {
				name : 'vida_util',
				fieldLabel : 'Vida Útil',
				allowBlank : true,
				anchor : '100%',
				gwidth : 100,
				maxLength : 1000
			},
			type : 'NumberField',
			filters : {
				pfiltro : 'claf.vida_util',
				type : 'numeric'
			},
			id_grupo : 1,
			grid : true,
			form : true
		},{
			config : {
				name : 'monto_residual',
				fieldLabel : 'Monto Residual',
				allowBlank : true,
				anchor : '100%',
				gwidth : 100,
				maxLength : 1000
			},
			type : 'NumberField',
			filters : {
				pfiltro : 'claf.monto_residual',
				type : 'numeric'
			},
			id_grupo : 1,
			grid : true,
			form : true
		},{
			config : {
				name : 'icono',
				fieldLabel : 'Icono',
				allowBlank : true,
				anchor : '100%',
				gwidth : 100,
				maxLength : 1000
			},
			type : 'TextField',
			filters : {
				pfiltro : 'claf.icono',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
		},{
			config : {
				name : 'correlativo_act',
				fieldLabel : 'Correlativo Actual',
				allowBlank : true,
				anchor : '100%',
				gwidth : 100,
				maxLength : 1000,
				disabled: true
			},
			type : 'NumberField',
			filters : {
				pfiltro : 'claf.correlativo_act',
				type : 'numeric'
			},
			id_grupo : 1,
			grid : true,
			form : true
		},{
			config: {
                fieldLabel: 'Método de Depreciación',
                name: 'id_cat_metodo_dep',
                hiddenName: 'id_cat_metodo_dep',
                allowBlank: true,
                emptyText: 'Elija una opción',
                store: new Ext.data.JsonStore({
                    url: '../../sis_parametros/control/Catalogo/listarCatalogoCombo',
                    id: 'id_catalogo',
                    root: 'datos',
                    fields: ['id_catalogo','codigo','descripcion'],
                    totalProperty: 'total',
                    sortInfo: {
                        field: 'descripcion',
                        direction: 'ASC'
                    },
                    baseParams:{
                        start: 0,
                        limit: 10,
                        sort: 'descripcion',
                        dir: 'ASC',
                        par_filtro:'cat.descripcion',
                        cod_subsistema:'KAF',
                        catalogo_tipo:'tclasificacion__id_cat_metodo_dep'
                    }
                }),
                valueField: 'id_catalogo',
                displayField: 'descripcion',
                gdisplayField: 'estado_fun',
                mode: 'remote',
                triggerAction: 'all',
                lazyRender: true
			},
			type: 'ComboBox',
			id_grupo: 0,
			filters:{pfiltro:'cat.descripcion',type:'string'},
			grid: true,
			form: true
		},{
            config:{
                name: 'id_concepto_ingas',
                fieldLabel: 'Concepto',
                allowBlank: true,
                emptyText : 'Concepto...',
                store : new Ext.data.JsonStore({
                    url:'../../sis_parametros/control/ConceptoIngas/listarConceptoIngasMasPartida',
                    id : 'id_concepto_ingas',
                    root: 'datos',
                    sortInfo:{
                        field: 'desc_ingas',
                        direction: 'ASC'
                    },
                    totalProperty: 'total',
                    fields: ['id_concepto_ingas','tipo','desc_ingas','movimiento','desc_partida','id_grupo_ots','filtro_ot','requiere_ot'],
                    remoteSort: true,
                    baseParams:{par_filtro:'desc_ingas#par.codigo',movimiento:'gasto', autorizacion: 'adquisiciones'}
                }),
                valueField: 'id_concepto_ingas',
                displayField: 'desc_ingas',
                gdisplayField: 'desc_concepto_ingas',
                hiddenName: 'id_concepto_ingas',
                forceSelection:true,
                typeAhead: false,
                triggerAction: 'all',
                listWidth:500,
                resizable:true,
                lazyRender:true,
                mode:'remote',
                pageSize:10,
                queryDelay:1000,
                width:'100%',
                gwidth:200,
                minChars:2,
                qtip:'Si el conceto de gasto que necesita no existe por favor  comuniquese con el área de presupuestos para solictar la creación',
                tpl: '<tpl for="."><div class="x-combo-list-item"><p><b>{desc_ingas}</b></p><strong>{tipo}</strong><p>PARTIDA: {desc_partida}</p></div></tpl>',
                renderer:function(value, p, record){return String.format('{0}', record.data['desc_ingas']);}
            },
            type:'ComboBox',
            filters:{pfiltro:'cig.desc_ingas',type:'string'},
            id_grupo:1,
            grid:true,
            form:true
        }, {
        	config: {
        		name: 'tipo',
        		fieldLabel: 'Tipo',
        		hidden: true
        	},
        	type : 'TextField',
			filters : {
				pfiltro : 'claf.tipo',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
        }, {
        	config: {
        		name: 'final',
        		fieldLabel: 'Final'	,
        		hidden: true
        	},
        	type : 'TextField',
			filters : {
				pfiltro : 'claf.final',
				type : 'string'
			},
			id_grupo : 1,
			grid : true,
			form : true
        }],
		title : 'Clasificación',
		ActSave : '../../sis_kactivos_fijos/control/Clasificacion/insertarClasificacion',
		ActDel : '../../sis_kactivos_fijos/control/Clasificacion/eliminarClasificacion',
		ActList : '../../sis_kactivos_fijos/control/Clasificacion/listarClasificacionArb',
		ActDragDrop:'../../sis_kactivos_fijos/control/Clasificacion/guardarDragDrop',
		id_store : 'id_clasificacion',
		textRoot : 'Clasificaciones',
		id_nodo : 'id_clasificacion',
		id_nodo_p : 'id_clasificacion_fk',
		idNodoDD : 'id_clasificacion',
		idOldParentDD : 'id_clasificacion_fk',
		idTargetDD : 'id_clasificacion',
		enableDD : true,

		fields : [
		{
			name: 'id_clasificacion',
			type : 'numeric'
		}, 
		{
			name: 'codigo',
			type : 'string'
		}, 
		{
			name: 'nombre',
			type : 'string'
		}, 
		{
			name: 'final',
			type : 'string'
		}, 
		{
			name: 'estado_reg',
			type : 'string'
		}, 
		{
			name: 'id_cat_metodo_dep',
			type : 'numeric'
		}, 
		{
			name: 'tipo',
			type : 'string'
		}, 
		{
			name: 'id_concepto_ingas',
			type : 'numeric'
		}, 
		{
			name: 'monto_residual',
			type : 'numeric'
		}, 
		{
			name: 'icono',
			type : 'string'
		}, 
		{
			name: 'id_clasificacion_fk',
			type : 'numeric'
		}, 
		{
			name: 'vida_util',
			type : 'numeric'
		}, 
		{
			name: 'correlativo_act',
			type : 'numeric'
		}, 
		{
			name: 'usuario_ai',
			type : 'string'
		}, 
		{
			name: 'fecha_reg',
			type : 'date',
			dateFormat:'Y-m-d H:i:s.u'
		}, 
		{
			name: 'id_usuario_reg',
			type : 'numeric'
		}, 
		{
			name: 'id_usuario_ai',
			type : 'numeric'
		}, 
		{
			name: 'id_usuario_mod',
			type : 'numeric'
		}, 
		{
			name: 'fecha_mod',
			type : 'date',
			dateFormat:'Y-m-d H:i:s.u'
		}, 
		{
			name: 'usr_reg',
			type : 'string'
		}, 
		{
			name: 'usr_mod',
			type : 'string'
		}, 
		{
			name: 'codigo_met_dep',
			type : 'string'
		}, 
		{
			name: 'met_dep',
			type : 'string'
		}, 
		{
			name: 'desc_ingas',
			type : 'string'
		}],
		sortInfo : {
			field : 'id_clasificacion',
			direction : 'ASC'
		},
		bdel : true,
		bsave : false,
		bexcel : false,
		rootVisible : true,
		fwidth : 420,
		fheight : 300,
		onNodeDrop : function(o) {
		    this.ddParams = {
		        tipo_nodo : o.dropNode.attributes.tipo_nodo
		    };
		    this.idTargetDD = 'id_clasificacion';
		    if (o.dropNode.attributes.tipo_nodo == 'raiz' || o.dropNode.attributes.tipo_nodo == 'hijo') {
		        this.idNodoDD = 'id_clasificacion';
		        this.idOldParentDD = 'id_clasificacion_fk';
		    } else if(o.dropNode.attributes.tipo_nodo == 'item') {
		        this.idNodoDD = 'id_item';
                this.idOldParentDD = 'id_p';
		    }
		    Phx.vista.ClasificacionAF.superclass.onNodeDrop.call(this, o);
		},

		getNombrePadre : function(n) {
			var direc;
			var padre = n.parentNode;
			if (padre) {
				if (padre.attributes.id != 'id') {
					direc = n.attributes.nombre + ' - ' + this.getNombrePadre(padre);
					return direc;
				} else {
					return n.attributes.nombre;
				}
			} else {
				return undefined;
			}
		},
		successSave : function(resp) {
			Phx.vista.ClasificacionAF.superclass.successSave.call(this, resp);
			var selectedNode = this.sm.getSelectedNode();
			selectedNode.attributes.estado = 'restringido';
		},
		successBU : function(resp) {
			Phx.CP.loadingHide();
			var reg = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
			if (!reg.ROOT.error) {
				alert(reg.ROOT.detalle.mensaje)
			} else {

				alert('ocurrio un error durante el proceso')
			}
			resp.argument.node.reload();

		},
	}); 
</script>
