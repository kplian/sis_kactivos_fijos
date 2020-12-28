<?php
/****************************************************************************************
*@package pXP
*@file ActivoModMasivo.php
*@author  (rchumacero)
*@date 09-12-2020 20:34:43
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
***************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
*******************************************************************************************/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoModMasivo=Ext.extend(Phx.gridInterfaz,{

    constructor:function(config){
        this.maestro=config.maestro;
        //llama al constructor de la clase padre
        Phx.vista.ActivoModMasivo.superclass.constructor.call(this,config);
        this.init();
        this.load({params:{start:0, limit:this.tam_pag}});

        this.addButton('btnActualizMasivo',{
            text :'Importa Excel',
            iconCls : 'bchecklist',


            disabled: false,
            handler: this.onButtonActualizarMasivo,
            tooltip : '<b>Importar desde archivo excel'
        });

        /*this.addButton('btnEjecutar',{
            text :'Ejecutar Actualización',
            iconCls : 'bgear',
            disabled: false,
            handler: this.onButtonEjecutar,
            tooltip : '<b>Ejecuta la actualización de los datos a partir de los datos cargados'
        });*/

        this.addButton('ant_estado',{argument: {estado: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.antEstado,tooltip: '<b>Pasar al Anterior Estado</b>'});
        this.addButton('sig_estado',{text:'Siguiente',iconCls: 'badelante',disabled:true,handler:this.sigEstado,tooltip: '<b>Pasar al Siguiente Estado</b>'});
        this.addButton('diagrama_gantt',{text: 'Gant', iconCls: 'bgantt', disabled: true, handler: this.diagramGantt, tooltip: '<b>Diagrama Gantt del proceso</b>'});
    },

    Atributos:[
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
                name: 'fecha',
                fieldLabel: 'Fecha',
                allowBlank: true,
                anchor: '80%',
                gwidth: 80,
                format: 'd/m/Y',
                renderer:function (value,p,record){return value?value.dateFormat('d/m/Y'):''}
            },
            type:'DateField',
            filters:{pfiltro:'afm.fecha',type:'date'},
            id_grupo:1,
            grid:true,
            form:true
		},
        {
            config: {
                name: 'num_tramite',
                fieldLabel: 'Nro.Trámite',
                allowBlank: true,
                anchor: '80%',
                gwidth: 130,
                maxLength: 5000
            },
            type:'TextField',
            filters: {pfilto: 'afm.num_tramite', type: 'string'},
            id_grupo: 1,
            grid: true,
            form: false
        },
        {
            config: {
                name: 'motivo',
                fieldLabel: 'Motivo',
                allowBlank: true,
                anchor: '80%',
                gwidth: 350,
            	maxLength:5000
            },
            type:'TextArea',
            filters:{pfiltro:'afm.motivo',type:'string'},
            id_grupo:1,
            grid:true,
            form:true
		},
        {
            config:{
                name: 'estado',
                fieldLabel: 'Estado',
                allowBlank: true,
                anchor: '80%',
                gwidth: 100,
            	maxLength:30
            },
            type:'TextField',
            filters:{pfiltro:'afm.estado',type:'string'},
            id_grupo:1,
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
                filters:{pfiltro:'afm.fecha_reg',type:'date'},
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
                filters:{pfiltro:'afm.estado_reg',type:'string'},
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
                filters:{pfiltro:'afm.id_usuario_ai',type:'numeric'},
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
                filters:{pfiltro:'afm.usuario_ai',type:'string'},
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
                filters:{pfiltro:'afm.fecha_mod',type:'date'},
                id_grupo:1,
                grid:true,
                form:false
		}
    ],
    tam_pag:50,
    title:'Actualización Masiva',
    ActSave:'../../sis_kactivos_fijos/control/ActivoModMasivo/insertarActivoModMasivo',
    ActDel:'../../sis_kactivos_fijos/control/ActivoModMasivo/eliminarActivoModMasivo',
    ActList:'../../sis_kactivos_fijos/control/ActivoModMasivo/listarActivoModMasivo',
    id_store:'id_activo_mod_masivo',
    fields: [
		{name:'id_activo_mod_masivo', type: 'numeric'},
		{name:'estado_reg', type: 'string'},
		{name:'id_proceso_wf', type: 'numeric'},
		{name:'id_estado_wf', type: 'numeric'},
		{name:'fecha', type: 'date',dateFormat:'Y-m-d'},
		{name:'motivo', type: 'string'},
		{name:'estado', type: 'string'},
		{name:'id_usuario_reg', type: 'numeric'},
		{name:'fecha_reg', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'id_usuario_ai', type: 'numeric'},
		{name:'usuario_ai', type: 'string'},
		{name:'id_usuario_mod', type: 'numeric'},
		{name:'fecha_mod', type: 'date',dateFormat:'Y-m-d H:i:s.u'},
		{name:'usr_reg', type: 'string'},
		{name:'usr_mod', type: 'string'},
        {name:'num_tramite', type: 'string'}
    ],
    sortInfo:{
        field: 'id_activo_mod_masivo',
        direction: 'ASC'
    },
    bdel:true,
    bsave:true,

    onButtonActualizarMasivo: function() {
        var record = this.sm.getSelected();
        Phx.CP.loadWindows
        (
            '../../../sis_kactivos_fijos/vista/activo_mod_masivo/SubirActualizacionDatos.php',
            'Importar Datos para Actualización',
            {
                modal: true,
                width: 450,
                height: 150
            },
            record.data,
            this.idContenedor,
            'SubirActualizacionDatos'
        );
    },

    onButtonEjecutar: function() {
        var rec = this.sm.getSelected();

        Ext.MessageBox.confirm('Confirmación', '¿Está seguro de realizar la Actualización Masiva de los datos?', function(resp) {
            if(resp == 'yes') {
                Phx.CP.loadingShow();
                Ext.Ajax.request({
                    url:'../../sis_kactivos_fijos/control/ActivoModMasivo/EjecutarActualizacionDatos',
                    params: {
                        id_activo_mod_masivo: rec.data.id_activo_mod_masivo
                    },
                    success: function(resp){
                        Ext.MessageBox.alert('Respuesta', 'Actualización realizada con éxito');
                        Phx.CP.loadingHide();
                    },
                    failure: this.conexionFailure,
                    timeout: this.timeout,
                    scope: this
                });
            }

        }, this);
    },

    preparaMenu: function(n) {
        var data = this.getSelectedData();

        //Enable/disable WF buttons by status
        this.getBoton('ant_estado').enable();
        this.getBoton('sig_estado').enable();
        this.getBoton('diagrama_gantt').enable();
        this.getBoton('edit').disable();
        this.getBoton('del').disable();
        this.getBoton('btnActualizMasivo').disable();

        if(data.estado == 'borrador'){
            this.getBoton('ant_estado').disable();
            this.getBoton('edit').enable();
            this.getBoton('del').enable();
            this.getBoton('btnActualizMasivo').enable();
        } else if (data.estado == 'procesado'){
            this.getBoton('ant_estado').disable();
        } else if(data.estado == 'finalizado') {
            this.getBoton('ant_estado').disable();
            this.getBoton('sig_estado').disable();
        }

    },

    liberaMenu: function(){
        var tb = Phx.vista.ActivoModMasivo.superclass.liberaMenu.call(this);
        if(tb){
            this.getBoton('ant_estado').disable();
            this.getBoton('sig_estado').disable();
            this.getBoton('diagrama_gantt').disable();
            this.getBoton('edit').disable();
            this.getBoton('del').disable();
            this.getBoton('btnActualizMasivo').disable();
        }
       return tb
    },

    diagramGantt: function(){
        var data = this.sm.getSelected().data.id_proceso_wf;
        Phx.CP.loadingShow();
        Ext.Ajax.request({
            url: '../../sis_workflow/control/ProcesoWf/diagramaGanttTramite',
            params: {'id_proceso_wf': data},
            success: this.successExport,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
    },

    sigEstado: function(){
        var rec = this.sm.getSelected();

        this.objWizard = Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/FormEstadoWf.php',
            'Estado de Wf',
            {
                modal: true,
                width: 700,
                height: 450
            }, {
                data:{
                   id_estado_wf: rec.data.id_estado_wf,
                   id_proceso_wf: rec.data.id_proceso_wf,
                   fecha_ini: rec.data.fecha_mov,
                }
            }, this.idContenedor,'FormEstadoWf',
            {
                config:[{
                  event:'beforesave',
                  delegate: this.onSaveWizard,

                }],
                scope:this
            });
    },

    antEstado: function(){
        var rec = this.sm.getSelected();
        Phx.CP.loadWindows('../../../sis_workflow/vista/estado_wf/AntFormEstadoWf.php',
            'Estado de Wf',
            {
                modal: true,
                width: 450,
                height: 250
            }, {
                data: rec.data
            }, this.idContenedor,'AntFormEstadoWf', {
                config:[{
                  event:'beforesave',
                  delegate: this.onAntEstado,
                }],
            scope:this
        })
    },

    onAntEstado: function(wizard, resp) {
        Phx.CP.loadingShow();
        Ext.Ajax.request({
            url: '../../sis_kactivos_fijos/control/ActivoModMasivo/anteriorEstado',
            params: {
                id_proceso_wf: resp.id_proceso_wf,
                id_estado_wf: resp.id_estado_wf,
                obs: resp.obs
            },
            argument: {wizard: wizard},
            success: this.successWizard,
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
    },

    onSaveWizard: function(wizard, resp) {
        Phx.CP.loadingShow();
        Ext.Ajax.request({
            url: '../../sis_kactivos_fijos/control/ActivoModMasivo/siguienteEstado',
            params: {
                id_proceso_wf_act:  resp.id_proceso_wf_act,
                id_estado_wf_act:   resp.id_estado_wf_act,
                id_tipo_estado:     resp.id_tipo_estado,
                id_funcionario_wf:  resp.id_funcionario_wf,
                id_depto_wf:        resp.id_depto_wf,
                obs:                resp.obs,
                json_procesos:      Ext.util.JSON.encode(resp.procesos)
            },
            success: this.successWizard,
            failure: this.conexionFailure,
            argument: {wizard: wizard},
            timeout: this.timeout,
            scope: this
        });
    },

    successWizard: function(resp) {
        Phx.CP.loadingHide();
        resp.argument.wizard.panel.destroy()
        this.reload();
    },

    south: {
        url: '../../../sis_kactivos_fijos/vista/activo_mod_masivo_det/ActivoModMasivoDet.php',
        title: 'Detalle',
        height: '50%',
        cls: 'ActivoModMasivoDet'
    }
})
</script>

