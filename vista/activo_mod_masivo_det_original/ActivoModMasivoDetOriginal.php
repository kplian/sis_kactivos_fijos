<?php
/****************************************************************************************
*@package pXP
*@file gen-ActivoModMasivoDetOriginal.php
*@author  (rchumacero)
*@date 10-12-2020 03:43:46
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema

HISTORIAL DE MODIFICACIONES:
#ISSUE                FECHA                AUTOR                DESCRIPCION
 #0                10-12-2020 03:43:46    rchumacero            Creacion
 #ETR-2778  KAF       ETR           02/02/2021  RCM         Adición de campos para modificación de AFVs
*******************************************************************************************/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoModMasivoDetOriginal=Ext.extend(Phx.gridInterfaz,{

    constructor:function(config){
        this.maestro=config.maestro;
        //llama al constructor de la clase padre
        Phx.vista.ActivoModMasivoDetOriginal.superclass.constructor.call(this,config);
        this.init();

        var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData();

        if (dataPadre) {
            this.onEnablePanel(this, dataPadre);
        } else {
            this.bloquearMenus();
        }
    },

    Atributos:[
        {
            //configuracion del componente
            config:{
                    labelSeparator:'',
                    inputType:'hidden',
                    name: 'id_activo_mod_masivo_det_original'
            },
            type:'Field',
            form:true
        },
        {
            //configuracion del componente
            config:{
                    labelSeparator:'',
                    inputType:'hidden',
                    name: 'id_activo_mod_masivo_det'
            },
            type:'Field',
            form:true
        },
        {
            //configuracion del componente
            config:{
                    labelSeparator:'',
                    inputType:'hidden',
                    name: 'id_activo_fijo'
            },
            type:'Field',
            form:true
        },
        {
            config:{
                name: 'codigo',
                fieldLabel: 'Código',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:50
            },
                type:'TextField',
                filters:{pfiltro:'mador.codigo',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'nro_serie',
                fieldLabel: 'Nro.Serie',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:50
            },
                type:'TextField',
                filters:{pfiltro:'mador.nro_serie',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'marca',
                fieldLabel: 'Marca',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:200
            },
                type:'TextField',
                filters:{pfiltro:'mador.marca',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'denominacion',
                fieldLabel: 'Denominación',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:500
            },
                type:'TextField',
                filters:{pfiltro:'mador.denominacion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'descripcion',
                fieldLabel: 'Descripción',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:5000
            },
                type:'TextField',
                filters:{pfiltro:'mador.descripcion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'desc_unidad_medida',
                fieldLabel: 'Unidad Medida',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'observaciones',
                fieldLabel: 'Observaciones',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:5000
            },
                type:'TextField',
                filters:{pfiltro:'mador.observaciones',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'ubicacion',
                fieldLabel: 'Ubicación',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:1000
            },
                type:'TextField',
                filters:{pfiltro:'mador.ubicacion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'desc_ubicacion',
                fieldLabel: 'Local',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        {
            config:{
                name: 'desc_funcionario',
                fieldLabel: 'Responsable',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        {
            config:{
                name: 'desc_proveedor',
                fieldLabel: 'Proveedor',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        {
            config:{
                name: 'fecha_compra',
                fieldLabel: 'Fecha Compra',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type:'DateField',
                filters:{pfiltro:'mador.fecha_compra',type:'date'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'documento',
                fieldLabel: 'Documento',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'mador.documento',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'cbte_asociado',
                fieldLabel: 'Cbte.Asociado',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:50
            },
                type:'TextField',
                filters:{pfiltro:'mador.cbte_asociado',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'fecha_cbte_asociado',
                fieldLabel: 'Fecha Cbte.Asociado',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type:'DateField',
                filters:{pfiltro:'mador.fecha_cbte_asociado',type:'date'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'desc_grupo',
                fieldLabel: 'Grupo AE',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        {
            config:{
                name: 'desc_grupo_clasif',
                fieldLabel: 'Clasificación AE',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        {
            config:{
                name: 'desc_centro_costo',
                fieldLabel: 'Centro Costo',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:1000
            },
                type:'TextField',
                id_grupo:1,
                grid:true,
                form:true
        },
        //Inicio #ETR-2778
        {
            config:{
                name: 'id_activo_fijo_valor',
                fieldLabel: 'id_activo_fijo_valor',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.id_activo_fijo_valor',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'valor_compra',
                fieldLabel: 'Bs.Valor Compra',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.valor_compra',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'valor_inicial',
                fieldLabel: 'Bs.Valor Inicial',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.valor_inicial',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'fecha_ini_dep',
                fieldLabel: 'Bs.Fecha Ini.dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'DateField',
                filters: {pfiltro:'mador.fecha_ini_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'vutil_orig',
                fieldLabel: 'Bs.Vida Útil Orig.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.vutil_orig',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'vutil',
                fieldLabel: 'Bs.Vida Útil',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.vutil',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'fult_dep',
                fieldLabel: 'Bs.Fecha Últ.Dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.fult_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'fecha_fin',
                fieldLabel: 'Bs.Fecha Fin',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.fecha_fin',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'val_resc',
                fieldLabel: 'Bs.Valor Rescate',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.val_resc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'vact_ini',
                fieldLabel: 'Bs. Valor Actualiz.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.vact_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'dacum_ini',
                fieldLabel: 'Bs.Dep.Acum.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.dacum_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'dper_ini',
                fieldLabel: 'Bs.Dep.Per.Ini',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.dper_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'inc',
                fieldLabel: 'Bs.Incremento',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.inc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'inc_sact',
                fieldLabel: 'Inc.Sin.Actualiz.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.inc_sact',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'fechaufv_ini',
                fieldLabel: 'Bs.Fecha UFV Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.fechaufv_ini',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_id_activo_fijo_valor',
                fieldLabel: 'usd_id_activo_fijo_valor',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_id_activo_fijo_valor',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_valor_compra',
                fieldLabel: 'USD Valor Compra',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_valor_compra',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_valor_inicial',
                fieldLabel: 'USD Valor Inicial',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_valor_inicial',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_fecha_ini_dep',
                fieldLabel: 'USD Fecha Ini.Dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_fecha_ini_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_vutil_orig',
                fieldLabel: 'USD Vida Útil Orig.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_vutil_orig',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_vutil',
                fieldLabel: 'USD Vida Útil',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_vutil',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_fult_dep',
                fieldLabel: 'USD Fecha Ult.Dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_fult_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_fecha_fin',
                fieldLabel: 'USD Fecha Fin',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_fecha_fin',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_val_resc',
                fieldLabel: 'USD Valor Rescate',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_val_resc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_vact_ini',
                fieldLabel: 'USD Valor Actualiz.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_vact_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_dacum_ini',
                fieldLabel: 'USD Dep.Acum.Ini',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_dacum_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_dper_ini',
                fieldLabel: 'USD Dep.Per.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_dper_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_inc',
                fieldLabel: 'USD Incremento',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_inc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_inc_sact',
                fieldLabel: 'USD Inc.Sin Actualiz.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_inc_sact',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'usd_fechaufv_ini',
                fieldLabel: 'USD Fecha UFV Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.usd_fechaufv_ini',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_id_activo_fijo_valor',
                fieldLabel: 'ufv_id_activo_fijo_valor',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_id_activo_fijo_valor',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_valor_compra',
                fieldLabel: 'UFV Valor Compra',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_valor_compra',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_valor_inicial',
                fieldLabel: 'UFV Valor Inicial',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_valor_inicial',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_fecha_ini_dep',
                fieldLabel: 'UFV Fecha Ini.Dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_fecha_ini_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_vutil_orig',
                fieldLabel: 'UFV Vida Útil Orig.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_vutil_orig',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_vutil',
                fieldLabel: 'UFV Vida Útil',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_vutil',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_fult_dep',
                fieldLabel: 'UFV Fecha Ult.Dep.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_fult_dep',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_fecha_fin',
                fieldLabel: 'UFV Fecha Fin',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_fecha_fin',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_val_resc',
                fieldLabel: 'UFV Valor Rescate',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_val_resc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_vact_ini',
                fieldLabel: 'UFV Valor Actualiz.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_vact_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_dacum_ini',
                fieldLabel: 'UFV Dep.Acum.Ini.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_dacum_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_dper_ini',
                fieldLabel: 'UFV Dep.Per.Ini',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_dper_ini',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_inc',
                fieldLabel: 'UFV Incremento',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_inc',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_inc_sact',
                fieldLabel: 'UFV Incremento Sin Actualiz.',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_inc_sact',type:'numeric'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        {
            config:{
                name: 'ufv_fechaufv_ini',
                fieldLabel: 'UFV Fecha UFV Ini',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
                type: 'TextField',
                filters: {pfiltro:'mador.ufv_fechaufv_ini',type:'date'},
                id_grupo: 1,
                grid: true,
                form: true
        },
        //Fin #ETR-2778
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
                filters:{pfiltro:'mador.fecha_reg',type:'date'},
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
                gwidth: 100,
                maxLength:10
            },
                type:'TextField',
                filters:{pfiltro:'mador.estado_reg',type:'string'},
                id_grupo:1,
                grid:true,
                form:false
        },
        {
            config:{
                name: 'id_usuario_ai',
                fieldLabel: 'Fecha creación',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:4
            },
                type:'Field',
                filters:{pfiltro:'mador.id_usuario_ai',type:'numeric'},
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
                filters:{pfiltro:'mador.usuario_ai',type:'string'},
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
                filters:{pfiltro:'mador.fecha_mod',type:'date'},
                id_grupo:1,
                grid:true,
                form:false
		}
    ],
    tam_pag:50,
    title:'Original',
    ActSave:'../../sis_kactivos_fijos/control/ActivoModMasivoDetOriginal/insertarActivoModMasivoDetOriginal',
    ActDel:'../../sis_kactivos_fijos/control/ActivoModMasivoDetOriginal/eliminarActivoModMasivoDetOriginal',
    ActList:'../../sis_kactivos_fijos/control/ActivoModMasivoDetOriginal/listarActivoModMasivoDetOriginal',
    id_store:'id_activo_mod_masivo_det_original',
    fields: [
		{name:'id_activo_mod_masivo_det_original', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_activo_mod_masivo_det', type: 'numeric'},
		{name:'id_activo_fijo', type: 'numeric'},
		{name:'codigo', type: 'string'},
		{name:'nro_serie', type: 'string'},
		{name:'marca', type: 'string'},
		{name:'denominacion', type: 'string'},
		{name:'descripcion', type: 'string'},
		{name:'id_unidad_medida', type: 'numeric'},
		{name:'observaciones', type: 'string'},
		{name:'ubicacion', type: 'string'},
		{name:'id_ubicacion', type: 'numeric'},
		{name:'id_funcionario', type: 'numeric'},
		{name:'id_proveedor', type: 'numeric'},
		{name:'fecha_compra', type: 'date',dateFormat:'Y-m-d'},
		{name:'documento', type: 'string'},
		{name:'cbte_asociado', type: 'string'},
		{name:'fecha_cbte_asociado', type: 'date',dateFormat:'Y-m-d'},
		{name:'id_grupo', type: 'numeric'},
		{name:'id_grupo_clasif', type: 'numeric'},
		{name:'id_centro_costo', type: 'numeric'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
        {name:'desc_unidad_medida', type: 'string'},
        {name:'desc_ubicacion', type: 'string'},
        {name:'desc_funcionario', type: 'string'},
        {name:'desc_proveedor', type: 'string'},
        {name:'desc_grupo', type: 'string'},
        {name:'desc_grupo_clasif', type: 'string'},
        {name:'desc_centro_costo', type: 'string'},
        //Inicio #ETR-2778
        {name:'id_activo_fijo_valor', type: 'numeric'},
        {name:'valor_compra', type: 'numeric'},
        {name:'valor_inicial', type: 'numeric'},
        {name:'fecha_ini_dep', type: 'date'},
        {name:'vutil_orig', type: 'numeric'},
        {name:'vutil', type: 'numeric'},
        {name:'fult_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'fecha_fin', type: 'date', dateFormat:'Y-m-d'},
        {name:'val_resc', type: 'numeric'},
        {name:'vact_ini', type: 'numeric'},
        {name:'dacum_ini', type: 'numeric'},
        {name:'dper_ini', type: 'numeric'},
        {name:'inc', type: 'numeric'},
        {name:'inc_sact', type: 'numeric'},
        {name:'fechaufv_ini', type: 'date', dateFormat:'Y-m-d'},
        {name:'usd_id_activo_fijo_valor', type: 'numeric'},
        {name:'usd_valor_compra', type: 'numeric'},
        {name:'usd_valor_inicial', type: 'numeric'},
        {name:'usd_fecha_ini_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'usd_vutil_orig', type: 'numeric'},
        {name:'usd_vutil', type: 'numeric'},
        {name:'usd_fult_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'usd_fecha_fin', type: 'date', dateFormat:'Y-m-d'},
        {name:'usd_val_resc', type: 'numeric'},
        {name:'usd_vact_ini', type: 'numeric'},
        {name:'usd_dacum_ini', type: 'numeric'},
        {name:'usd_dper_ini', type: 'numeric'},
        {name:'usd_inc', type: 'numeric'},
        {name:'usd_inc_sact', type: 'numeric'},
        {name:'usd_fechaufv_ini', type: 'date', dateFormat:'Y-m-d'},
        {name:'ufv_id_activo_fijo_valor', type: 'numeric'},
        {name:'ufv_valor_compra', type: 'numeric'},
        {name:'ufv_valor_inicial', type: 'numeric'},
        {name:'ufv_fecha_ini_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'ufv_vutil_orig', type: 'numeric'},
        {name:'ufv_vutil', type: 'numeric'},
        {name:'ufv_fult_dep', type: 'date', dateFormat:'Y-m-d'},
        {name:'ufv_fecha_fin', type: 'date', dateFormat:'Y-m-d'},
        {name:'ufv_val_resc', type: 'numeric'},
        {name:'ufv_vact_ini', type: 'numeric'},
        {name:'ufv_dacum_ini', type: 'numeric'},
        {name:'ufv_dper_ini', type: 'numeric'},
        {name:'ufv_inc', type: 'numeric'},
        {name:'ufv_inc_sact', type: 'numeric'},
        {name:'ufv_fechaufv_ini', type: 'date', dateFormat:'Y-m-d'}
        //Fin #ETR-2778
    ],
    sortInfo:{
        field: 'id_activo_mod_masivo_det_original',
        direction: 'ASC'
    },
    bdel: false,
    bsave: false,
    bnew: false,
    bedit: false,

    onReloadPage: function(m) {
        this.maestro = m;
        this.Atributos[1].valorInicial = this.maestro.id_activo_mod_masivo_det;

        //Define the filter to apply for activos fijod drop down
        this.store.baseParams = {
            id_activo_mod_masivo_det: this.maestro.id_activo_mod_masivo_det
        };
        this.load({
            params: {
                start: 0,
                limit: 50
            }
        });
    }
})
</script>

