<?php
/**
*@package pXP
*@file ActivoFijoUsuario.php
*@author  RCM
*@date 08/08/2017
*@description Interfaz para visualizar los activos fijos asignados al usuario logueado
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoUsuario = Ext.extend(Phx.gridInterfaz, {
	constructor: function(config){
		this.maestro = config.maestro;
		Phx.vista.ActivoFijoUsuario.superclass.constructor.call(this,config);
		this.init();
		this.load({
			params: {
				start: 0,
				limit: this.tam_pag,
				por_usuario: 'si'
			}
		});

		console.log('ana',Phx.CP.getPagina(config.idContenedor+'-east'));
	},
	Atributos: [{
			config:{
					labelSeparator:'',
					inputType:'hidden',
					name: 'id_deposito'
			},
			type:'Field',
			form:true 
		}, {
			config:{
				name: 'codigo',
				fieldLabel: 'Codigo',
				gwidth: 100
			},
			type:'TextField',
			filters:{pfiltro:'afij.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		}, {
			config:{
				name: 'denominacion',
				fieldLabel: 'Denominación',
				gwidth: 100
			},
			type: 'TextField',
			filters: {pfiltro:'afij.denominacion',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'descripcion',
				fieldLabel: 'Descripción',
				gwidth: 100
			},
			type: 'TextField',
			filters: {pfiltro:'afij.denominacion',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'id_clasificacion',
				fieldLabel: 'Clasificación',
				gwidth: 100,
				renderer:function (value, p, record){return String.format('{0}', record.data['clasificacion']);}
			},
			type: 'TextField',
			filters: {pfiltro:'afij.denominacion',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'nro_serie',
				fieldLabel: 'Nro.Serie',
				gwidth: 100
			},
			type: 'TextField',
			filters: {pfiltro:'afij.nro_serie',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'marca',
				fieldLabel: 'Marca',
				gwidth: 100
			},
			type: 'TextField',
			filters: {pfiltro:'afij.marca',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'cantidad',
				fieldLabel: 'Cantidad',
				gwidth: 100
			},
			type: 'TextField',
			filters: {pfiltro:'afij.cantidad',type:'numeric'},
			id_grupo: 1,
			grid: true,
			form: false
		}, {
			config:{
				name: 'id_unidad_medida',
				fieldLabel: 'Unidad de Medida',
				gwidth: 100,
				renderer:function (value, p, record){return String.format('{0}', record.data['descripcion_unmed']);}
			},
			type: 'TextField',
			filters: {pfiltro:'afij.denominacion',type:'string'},
			id_grupo: 1,
			grid: true,
			form: false
		}
		
	],
	bnew: false,
	bedit: false,
	bsave: false,
	bdel: false,
	ActList: '../../sis_kactivos_fijos/control/ActivoFijo/listarActivoFijo',
	id_store: 'id_activo_fijo',
    fields: [{name: 'id_activo_fijo',type: 'numeric'}, 
             {name: 'id_persona',type: 'numeric'}, 
             {name: 'cantidad_revaloriz',type: 'numeric'}, 
             {name: 'foto',type: 'string'}, 
             {name: 'id_proveedor',type: 'numeric'}, 
             {name: 'estado_reg',type: 'string'}, 
             {name: 'fecha_compra',type: 'date',dateFormat: 'Y-m-d'}, 
             {name: 'monto_vigente',type: 'numeric'}, 
             {name: 'id_cat_estado_fun',type: 'numeric'}, 
             {name: 'ubicacion',type: 'string'}, 
             {name: 'vida_util',type: 'numeric'}, 
             {name: 'documento',type: 'string'}, 
             {name: 'observaciones',type: 'string'}, 
             {name: 'fecha_ult_dep',type: 'date',dateFormat: 'Y-m-d'}, 
             {name: 'monto_rescate',type: 'numeric'}, 
             {name: 'denominacion',type: 'string'}, 
             {name: 'id_funcionario',type: 'numeric'}, 
             {name: 'id_deposito',type: 'numeric'},
             {name: 'monto_compra',type: 'numeric'}, 
             {name: 'id_moneda',type: 'numeric'}, 
             {name: 'depreciacion_mes',type: 'numeric'}, 
             {name: 'codigo',type: 'string'}, 
             {name: 'descripcion',type: 'string'}, 
             {name: 'id_moneda_orig',type: 'numeric'}, 
             {name: 'fecha_ini_dep',type: 'date',dateFormat: 'Y-m-d'}, 
             {name: 'id_cat_estado_compra',type: 'numeric'}, 
             {name: 'depreciacion_per',type: 'numeric'}, 
             {name: 'vida_util_original',type: 'numeric'}, 
             {name: 'depreciacion_acum',type: 'numeric'}, 
             {name: 'estado',type: 'string'}, 
             {name: 'id_clasificacion',type: 'numeric'}, 
             {name: 'id_centro_costo',type: 'numeric'}, 
             {name: 'id_oficina',type: 'numeric'}, 
             {name: 'id_depto',type: 'numeric'}, 
             {name: 'id_usuario_reg',type: 'numeric'}, 
             {name: 'fecha_reg',type: 'date',dateFormat: 'Y-m-d H:i:s.u'}, {name: 'usuario_ai',type: 'string'}, 
             {name: 'id_usuario_ai',type: 'numeric'}, {name: 'id_usuario_mod',type: 'numeric'}, {name: 'fecha_mod',type: 'date',dateFormat: 'Y-m-d H:i:s.u'}, {name: 'usr_reg',type: 'string'}, 
             {name: 'usr_mod',type: 'string'}, {name: 'persona',type: 'string'}, 
             {name: 'desc_proveedor',type: 'string'}, 
             {name: 'estado_fun',type: 'string'}, 
             {name: 'estado_compra',type: 'string'}, {name: 'clasificacion',type: 'string'}, 
             {name: 'centro_costo',type: 'string'}, 
             {name: 'oficina',type: 'string'}, 
             {name: 'depto',type: 'string'}, 
             {name: 'funcionario',type: 'string'}, 
             {name: 'deposito',type: 'string'}, {name: 'deposito_cod',type: 'string'}, 
             {name: 'desc_moneda_orig',type: 'string'},
             {name: 'en_deposito',type: 'string'},{name: 'extension',type: 'string'},
             {name: 'codigo_ant',type: 'string'},{name: 'marca',type: 'string'},
             {name: 'nro_serie',type: 'string'},
             {name: 'caracteristicas',type: 'string'},
             'monto_compra_orig','desc_proyecto','id_proyecto',
             'monto_vigente_real_af','vida_util_real_af','fecha_ult_dep_real_af','depreciacion_acum_real_af','depreciacion_per_real_af','tipo_activo','depreciable','cantidad_af','id_unidad_medida','codigo_unmed',
             {name:'descripcion_unmed',type:'string'},
             {name:'monto_compra_orig_100',type:'numeric'},
             {name:'nro_cbte_asociado',type:'string'},
             {name:'fecha_cbte_asociado',type:'date',dateFormat: 'Y-m-d'},
             {name:'vida_util_original_anios',type:'numeric'},
    ],
    east: {
        url: '../../../sis_kactivos_fijos/vista/movimiento/MovimientoPorActivo.php',
        title: 'Movimientos',
        cls: 'MovimientoPorActivo',
        width: '300'
    }
});
</script>>