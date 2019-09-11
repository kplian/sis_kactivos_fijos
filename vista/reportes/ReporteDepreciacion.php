<?php
/**
*@package pXP
*@file ReporteDetalleDep.php
*@author RCM
*@date 18/10/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

***************************************************************************
 ISSUE  SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #0     KAF                     18/10/2017  RCM         Creación del archivo
 #25    KAF       ETR           07/08/2019  RCM         Corrección nombre parámetro. Antes id_moneda, ahora id_moneda_dep. Se agrega tamién el parámetro id_moneda. Corrección timeout
***************************************************************************

*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
var COLOR1='#c2f0cc',
	COLOR2= '#EAA8A8',
    COLOR3= '#fafbd9';
Phx.vista.ReporteDepreciacion=Ext.extend(Phx.gridInterfaz,{
	bnew: false,
	bedit: false,
	bdel: false,
	bsave: false,
	metodoList: 'listarRepDepreciacion',
	col1: '#c2f0cc',
    col2: '#EAA8A8',
    col3: '#fafbd9',
    timeout: 1200000, //#25 seteo timeout a 20 minutos

	constructor:function(config){
		this.maestro=config;

    	//llama al constructor de la clase padre
		Phx.vista.ReporteDepreciacion.superclass.constructor.call(this,config);
		this.init();
		this.store.baseParams = {
			start: 0,
			limit: this.tam_pag,
			titulo_reporte: this.maestro.paramsRep.titleReporte,
			reporte: this.maestro.paramsRep.reporte,
			fecha_desde: this.maestro.paramsRep.fecha_desde,
			fecha_hasta: this.maestro.paramsRep.fecha_hasta,
			id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
			id_clasificacion: this.maestro.paramsRep.id_clasificacion,
			denominacion: this.maestro.paramsRep.denominacion,
			fecha_compra: this.maestro.paramsRep.fecha_compra,
			fecha_ini_dep: this.maestro.paramsRep.fecha_ini_dep,
			estado: this.maestro.paramsRep.estado,
			id_centro_costo: this.maestro.paramsRep.id_centro_costo,
			ubicacion: this.maestro.paramsRep.ubicacion,
			id_oficina: this.maestro.paramsRep.id_oficina,
			id_funcionario: this.maestro.paramsRep.id_funcionario,
			id_uo: this.maestro.paramsRep.id_uo,
			id_funcionario_compra: this.maestro.paramsRep.id_funcionario_compra,
			id_lugar: this.maestro.paramsRep.id_lugar,
			af_transito: this.maestro.paramsRep.af_transito,
			af_tangible: this.maestro.paramsRep.af_tangible,
			af_estado_mov: this.maestro.paramsRep.af_estado_mov,
			id_depto: this.maestro.paramsRep.id_depto,
			id_deposito: this.maestro.paramsRep.id_deposito,
			id_moneda_dep: this.maestro.paramsRep.id_moneda_dep, //#25
			id_moneda: this.maestro.paramsRep.id_moneda, //#25
			desc_moneda: this.maestro.paramsRep.desc_moneda,
			tipo_salida: 'grid',
			rep_metodo_list: this.metodoList,
			monto_inf: this.maestro.paramsRep.monto_inf,
			monto_sup: this.maestro.paramsRep.monto_sup,
			fecha_compra_max: this.maestro.paramsRep.fecha_compra_max,
			af_deprec: this.maestro.paramsRep.af_deprec,
			nro_cbte_asociado: this.maestro.paramsRep.nro_cbte_asociado
		};
		this.load();

		this.definirReporteCabecera();

		this.addButton('btnSelect', {
            text: 'Reporte',
            iconCls: 'bpdf32',
            disabled: false,
            handler: this.imprimirReporte,
            tooltip: '<b>Imprimir reporte</b><br/>Genera el reporte en el formato para impresión.'
         });

		this.addButton('btnReport', {
            text: 'Test',
            disabled: false,
            handler: this.imprimirReporte2,
            tooltip: '<b>Imprimir reporte 2</b><br/>Genera el reporte en el formato para impresión.'
         });
	},

	Atributos:[
		{
			config:{
				name:'codigo',
				fieldLabel: 'Código',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'codigo_ant',
				fieldLabel: 'Código SAP',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'denominacion',
				fieldLabel: 'Descripción',
				allowBlank: true,
				anchor: '80%',
				gwidth: 250,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'denominacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'fecha_ini_dep',
				fieldLabel: 'Inicio Dep.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value.dateFormat('m/Y')):'';
		        }
			},
			type:'DateField',
			filters:{pfiltro:'fecha_ini_dep',type:'date'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'monto_vigente_orig_100',
				fieldLabel: 'Valor Compra',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'monto_vigente_orig_100',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'monto_vigente_orig',
				fieldLabel: 'Valor Inicial',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';

		        }
			},
			type:'TextField',
			filters:{pfiltro:'monto_vigente_orig',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'af_altas',
				fieldLabel: 'Altas',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';

		        }
			},
			type:'TextField',
			filters:{pfiltro:'af_altas',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'af_bajas',
				fieldLabel: 'Bajas',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';

		        }
			},
			type:'TextField',
			filters:{pfiltro:'af_bajas',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'af_traspasos',
				fieldLabel: 'Traspasos',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';

		        }
			},
			type:'TextField',
			filters:{pfiltro:'af_traspasos',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'inc_actualiz',
				fieldLabel: 'Inc.x Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'inc_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'monto_actualiz',
				fieldLabel: 'Valor Actualiz.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'monto_actualiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name: 'vida_util_orig',
				fieldLabel: 'VU. Orig.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'vida_util_orig',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'vida_util_usada',
				fieldLabel: 'VU. Transcurrida',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'vida_util_usada',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'vida_util',
				fieldLabel: 'VU. Residual',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'vida_util',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'depreciacion_acum_gest_ant',
				fieldLabel: 'Dep.Acum.Gest.Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_acum_gest_ant',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'depreciacion_acum_actualiz_gest_ant',
				fieldLabel: 'Act.Deprec.Gest.Ant.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_acum_actualiz_gest_ant',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'depreciacion_per',
				fieldLabel: 'Dep. Gestión',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_per',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'depreciacion_acum_bajas',
				fieldLabel: 'Dep. Acum. Bajas',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_acum_bajas',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'depreciacion_acum_traspasos',
				fieldLabel: 'Dep. Acum.Traspasos',
				allowBlank: true,
				anchor: '80%',
				gwidth: 120,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_acum_traspasos',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		 {
			config:{
				name:'depreciacion_acum',
				fieldLabel: 'Dep. Acum.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion_acum',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'depreciacion',
				fieldLabel: 'Depreciación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'depreciacion',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
        {
			config:{
				name:'monto_vigente',
				fieldLabel: 'Valor Neto',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, Ext.util.Format.number(value,'0,000.00')):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'monto_vigente',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'codigo_tcc',
				fieldLabel: 'Centro Costo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'codigo_tcc',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		/*{
			config:{
				name:'cod_raiz',
				fieldLabel: 'Cod.Raíz',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'cod_raiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cod_grupo',
				fieldLabel: 'Cod.Grupo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'cod_grupo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cod_clase',
				fieldLabel: 'Cod.Clase',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'cod_clase',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cod_subgrupo',
				fieldLabel: 'Cod.Subgrupo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'cod_subgrupo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_raiz',
				fieldLabel: 'Raíz',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'desc_raiz',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_grupo',
				fieldLabel: 'Grupo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'desc_grupo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_clase',
				fieldLabel: 'Clase',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'desc_clase',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_subgrupo',
				fieldLabel: 'Subgrupo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'desc_subgrupo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},*/
		/*{
			config:{
				name:'afecta_concesion',
				fieldLabel: 'Afecta Concesión',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'afecta_concesion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},*/
		{
			config:{
				name:'desc_ubicacion',
				fieldLabel: 'Local',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'ubi.codigo',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'ubicacion',
				fieldLabel: 'Ubicación',
				allowBlank: true,
				anchor: '80%',
				gwidth: 150,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'af.ubicacion',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'nro_serie',
				fieldLabel: 'Nro.Serie',
				allowBlank: true,
				anchor: '80%',
				gwidth: 100,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'af.nro_serie',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'responsable',
				fieldLabel: 'Responsable',
				allowBlank: true,
				anchor: '80%',
				gwidth: 200,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'fun.desc_funcionario2',type:'string'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cuenta_activo',
				fieldLabel: 'Cuenta Activo',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cuenta_dep_acum',
				fieldLabel: 'Cuenta Dep.Acum.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'cuenta_deprec',
				fieldLabel: 'Cuenta Deprec.',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_grupo',
				fieldLabel: 'Agrupador AE',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'gr.nombre',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		},
		{
			config:{
				name:'desc_grupo_clasif',
				fieldLabel: 'Clasificador AE',
				allowBlank: true,
				anchor: '80%',
				gwidth: 300,
				renderer: function(value,metadata,rec,index){
					var mask='{0}';
		            if(rec.data.tipo=='total'){
		                metadata.style="background-color:"+COLOR1;
		                mask = '<u><b>{0}</b></u>';
		            } else if(rec.data.tipo=='clasif'){
		            	metadata.style="background-color:"+COLOR2;
		            	mask = '<b>{0}</b>';
		            }
		            return value?String.format(mask, value):'';
		        }
			},
			type:'TextField',
			filters:{pfiltro:'gr1.nombre',type:'numeric'},
			id_grupo:1,
			grid:true,
			form:true
		}
	],
	tam_pag:50,
	title:'Reporte',
	ActList:'../../sis_kactivos_fijos/control/Reportes/listarRepDepreciacion',
	fields: [
		{name:'codigo', type: 'string'},
        {name:'denominacion', type: 'string'},
        {name:'fecha_ini_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'monto_vigente_orig_100', type: 'numeric'},
        {name:'monto_vigente_orig', type: 'numeric'},
        {name:'inc_actualiz', type: 'numeric'},
        {name:'monto_actualiz', type: 'numeric'},
        {name:'vida_util_orig', type: 'numeric'},
        {name:'vida_util', type: 'numeric'},
        {name:'depreciacion_acum_gest_ant', type: 'numeric'},
        {name:'depreciacion_acum_actualiz_gest_ant', type: 'numeric'},
        {name:'depreciacion_per', type: 'numeric'},
        {name:'depreciacion_acum', type: 'numeric'},
        {name:'monto_vigente', type: 'numeric'},
        {name:'nivel', type: 'numeric'},
        {name:'orden', type: 'numeric'},
        {name:'tipo', type: 'string'},
        {name:'codigo_ant', type: 'string'},
        {name:'codigo_tcc', type: 'string'},
        /*{name:'cod_raiz', type: 'string'},
        {name:'cod_grupo', type: 'string'},
        {name:'cod_clase', type: 'string'},
        {name:'cod_subgrupo', type: 'string'},
        {name:'desc_raiz', type: 'string'},
        {name:'desc_grupo', type: 'string'},
        {name:'desc_clase', type: 'string'},
        {name:'desc_subgrupo', type: 'string'},*/
        {name:'afecta_concesion', type: 'string'},
        {name:'cuenta_activo', type: 'string'},
        {name:'cuenta_dep_acum', type: 'string'},
        {name:'cuenta_deprec', type: 'string'},
        {name:'depreciacion', type: 'numeric'},

        {name:'desc_ubicacion', type: 'string'},
        {name:'ubicacion', type: 'string'},
        {name:'nro_serie', type: 'string'},
        {name:'responsable', type: 'string'},
        {name:'vida_util_usada', type: 'numeric'},
        {name:'af_altas', type: 'numeric'},
        {name:'af_bajas', type: 'numeric'},
        {name:'af_traspasos', type: 'numeric'},
        {name:'depreciacion_acum_bajas', type: 'numeric'},
        {name:'depreciacion_acum_traspasos', type: 'numeric'},
        {name:'desc_grupo', type: 'string'},
        {name:'desc_grupo_clasif', type: 'string'}
	],
	sortInfo:{
		field: 'codigo',
		direction: 'ASC'
	},
	title2: 'DETALLE DEPRECIACIÓN',
	desplegarMaestro: 'si',
	repFilaInicioEtiquetas: 10,
	repFilaInicioDatos: 7,
	pdfOrientacion: 'L',
	definirReporteCabecera: function(){
		/*this.colMaestro= [{
			label: 'RESPONSABLE',
			value: this.maestro.paramsRep.repResponsable
		}, {
			label: 'OFICINA',
			value: this.maestro.paramsRep.repOficina
		}, {
			label: 'CARGO',
			value: this.maestro.paramsRep.repCargo
		}, {
			label: 'DEPTO.',
			value: this.maestro.paramsRep.repDepto
		}]*/
	},
	imprimirReporte: function(){
	    Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Reportes/generarReporteDetalleDepreciacion',//ReporteDetalleDepreciacion',
            params:{
            	titulo_reporte: this.maestro.paramsRep.titleReporte,
				reporte: this.maestro.paramsRep.reporte,
				fecha_desde: this.maestro.paramsRep.fecha_desde,
				fecha_hasta: this.maestro.paramsRep.fecha_hasta,
				id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
				id_clasificacion: this.maestro.paramsRep.id_clasificacion,
				denominacion: this.maestro.paramsRep.denominacion,
				fecha_compra: this.maestro.paramsRep.fecha_compra,
				fecha_ini_dep: this.maestro.paramsRep.fecha_ini_dep,
				estado: this.maestro.paramsRep.estado,
				id_centro_costo: this.maestro.paramsRep.id_centro_costo,
				ubicacion: this.maestro.paramsRep.ubicacion,
				id_oficina: this.maestro.paramsRep.id_oficina,
				id_funcionario: this.maestro.paramsRep.id_funcionario,
				id_uo: this.maestro.paramsRep.id_uo,
				id_funcionario_compra: this.maestro.paramsRep.id_funcionario_compra,
				id_lugar: this.maestro.paramsRep.id_lugar,
				af_transito: this.maestro.paramsRep.af_transito,
				af_tangible: this.maestro.paramsRep.af_tangible,
				af_estado_mov: this.maestro.paramsRep.af_estado_mov,
				id_depto: this.maestro.paramsRep.id_depto,
				id_deposito: this.maestro.paramsRep.id_deposito,
				id_moneda_dep: this.maestro.paramsRep.id_moneda_dep, //#25
				id_moneda: this.maestro.paramsRep.id_moneda, //#25
				desc_moneda: this.maestro.paramsRep.desc_moneda,
				tipo_salida: 'grid',
				rep_metodo_list: this.metodoList,
				monto_inf: this.maestro.paramsRep.monto_inf,
				monto_sup: this.maestro.paramsRep.monto_sup,
				fecha_compra_max: this.maestro.paramsRep.fecha_compra_max,
				af_deprec: this.maestro.paramsRep.af_deprec,
				nro_cbte_asociado: this.maestro.paramsRep.nro_cbte_asociado
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });
	},
	imprimirReporte2: function(){
	    Phx.CP.loadingShow();
        Ext.Ajax.request({
            url:'../../sis_kactivos_fijos/control/Reportes/generarReporteDetalleDepreciacion2',//ReporteDetalleDepreciacion',
            params:{
            	titulo_reporte: this.maestro.paramsRep.titleReporte,
				reporte: this.maestro.paramsRep.reporte,
				fecha_desde: this.maestro.paramsRep.fecha_desde,
				fecha_hasta: this.maestro.paramsRep.fecha_hasta,
				id_activo_fijo: this.maestro.paramsRep.id_activo_fijo,
				id_clasificacion: this.maestro.paramsRep.id_clasificacion,
				denominacion: this.maestro.paramsRep.denominacion,
				fecha_compra: this.maestro.paramsRep.fecha_compra,
				fecha_ini_dep: this.maestro.paramsRep.fecha_ini_dep,
				estado: this.maestro.paramsRep.estado,
				id_centro_costo: this.maestro.paramsRep.id_centro_costo,
				ubicacion: this.maestro.paramsRep.ubicacion,
				id_oficina: this.maestro.paramsRep.id_oficina,
				id_funcionario: this.maestro.paramsRep.id_funcionario,
				id_uo: this.maestro.paramsRep.id_uo,
				id_funcionario_compra: this.maestro.paramsRep.id_funcionario_compra,
				id_lugar: this.maestro.paramsRep.id_lugar,
				af_transito: this.maestro.paramsRep.af_transito,
				af_tangible: this.maestro.paramsRep.af_tangible,
				af_estado_mov: this.maestro.paramsRep.af_estado_mov,
				id_depto: this.maestro.paramsRep.id_depto,
				id_deposito: this.maestro.paramsRep.id_deposito,
				id_moneda_dep: this.maestro.paramsRep.id_moneda_dep, //#25
				id_moneda: this.maestro.paramsRep.id_moneda, //#25
				desc_moneda: this.maestro.paramsRep.desc_moneda,
				tipo_salida: 'grid',
				rep_metodo_list: this.metodoList,
				monto_inf: this.maestro.paramsRep.monto_inf,
				monto_sup: this.maestro.paramsRep.monto_sup,
				fecha_compra_max: this.maestro.paramsRep.fecha_compra_max,
				af_deprec: this.maestro.paramsRep.af_deprec,
				nro_cbte_asociado: this.maestro.paramsRep.nro_cbte_asociado
            },
            success: this.successExport,
            failure: this.conexionFailure,
            timeout:this.timeout,
            scope:this
        });
	}
})
</script>