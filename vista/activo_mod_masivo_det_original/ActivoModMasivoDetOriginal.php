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
 #

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
        {name:'desc_centro_costo', type: 'string'}
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

