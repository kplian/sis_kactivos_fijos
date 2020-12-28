<?php
/****************************************************************************************
*@package pXP
*@file ActivoModMasivoDet.php
*@author  (rchumacero)
*@date 09-12-2020 20:36:35
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*****************************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
*******************************************************************************************/

header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoModMasivoDet=Ext.extend(Phx.gridInterfaz,{

    constructor:function(config){
        this.maestro=config.maestro;
        //llama al constructor de la clase padre
        Phx.vista.ActivoModMasivoDet.superclass.constructor.call(this,config);
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
                    name: 'id_activo_mod_masivo'
            },
            type:'Field',
            form:true
        },
        {
            config:{
                name: 'codigo',
                fieldLabel: 'Código Activo',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
                maxLength:50
            },
                type:'TextField',
                filters:{pfiltro:'amd.codigo',type:'string'},
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
                filters:{pfiltro:'amd.nro_serie',type:'string'},
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
                filters:{pfiltro:'amd.marca',type:'string'},
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
                type:'TextArea',
                filters:{pfiltro:'amd.denominacion',type:'string'},
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
                type:'TextArea',
                filters:{pfiltro:'amd.descripcion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'unidad_medida',
                fieldLabel: 'Unidad Medida',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.unidad_medida',type:'string'},
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
                filters:{pfiltro:'amd.observaciones',type:'string'},
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
                filters:{pfiltro:'amd.ubicacion',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'local',
                fieldLabel: 'Local',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.local',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'responsable',
                fieldLabel: 'Responsable',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.responsable',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'proveedor',
                fieldLabel: 'Proveedor',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.proveedor',type:'string'},
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
                filters:{pfiltro:'amd.fecha_compra',type:'date'},
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
                filters:{pfiltro:'amd.documento',type:'string'},
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
                filters:{pfiltro:'amd.cbte_asociado',type:'string'},
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
                filters:{pfiltro:'amd.fecha_cbte_asociado',type:'date'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'grupo_ae',
                fieldLabel: 'Grupo AE',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.grupo_ae',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'clasificador_ae',
                fieldLabel: 'Clasificador AE',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.clasificador_ae',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
		},
        {
            config:{
                name: 'centro_costo',
                fieldLabel: 'Centro de Costo',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:100
            },
                type:'TextField',
                filters:{pfiltro:'amd.centro_costo',type:'string'},
                id_grupo:1,
                grid:true,
                form:true
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
                filters:{pfiltro:'amd.fecha_reg',type:'date'},
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
                filters:{pfiltro:'amd.estado_reg',type:'string'},
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
                filters:{pfiltro:'amd.id_usuario_ai',type:'numeric'},
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
                filters:{pfiltro:'amd.usuario_ai',type:'string'},
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
                filters:{pfiltro:'amd.fecha_mod',type:'date'},
                id_grupo:1,
                grid:true,
                form:false
		}
    ],
    tam_pag:50,
    title:'Detale Actualización',
    ActSave:'../../sis_kactivos_fijos/control/ActivoModMasivoDet/insertarActivoModMasivoDet',
    ActDel:'../../sis_kactivos_fijos/control/ActivoModMasivoDet/eliminarActivoModMasivoDet',
    ActList:'../../sis_kactivos_fijos/control/ActivoModMasivoDet/listarActivoModMasivoDet',
    id_store:'id_activo_mod_masivo_det',
    fields: [
		{name:'id_activo_mod_masivo_det', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_activo_mod_masivo', type: 'numeric'},
		{name:'codigo', type: 'string'},
        {name:'nro_serie', type: 'string'},
		{name:'marca', type: 'string'},
		{name:'denominacion', type: 'string'},
		{name:'descripcion', type: 'string'},
		{name:'unidad_medida', type: 'string'},
		{name:'observaciones', type: 'string'},
		{name:'ubicacion', type: 'string'},
		{name:'local', type: 'string'},
		{name:'responsable', type: 'string'},
		{name:'proveedor', type: 'string'},
		{name:'fecha_compra', type: 'date',dateFormat:'Y-m-d'},
		{name:'documento', type: 'string'},
		{name:'cbte_asociado', type: 'string'},
		{name:'fecha_cbte_asociado', type: 'date',dateFormat:'Y-m-d'},
		{name:'grupo_ae', type: 'string'},
		{name:'clasificador_ae', type: 'string'},
		{name:'centro_costo', type: 'string'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},

    ],
    sortInfo:{
        field: 'id_activo_mod_masivo_det',
        direction: 'ASC'
    },
    bdel:true,
    bsave:true,

    onReloadPage : function(m) {
        this.maestro = m;
        this.Atributos[1].valorInicial = this.maestro.id_activo_mod_masivo;

        //Define the filter to apply for activos fijod drop down
        this.store.baseParams = {
            id_activo_mod_masivo: this.maestro.id_activo_mod_masivo
        };
        this.load({
            params: {
                start: 0,
                limit: 50
            }
        });
    },

    east: {
        url: '../../../sis_kactivos_fijos/vista/activo_mod_masivo_det_original/ActivoModMasivoDetOriginal.php',
        title: 'Datos Originales',
        width: '30%',
        cls: 'ActivoModMasivoDetOriginal'
    }
})
</script>

