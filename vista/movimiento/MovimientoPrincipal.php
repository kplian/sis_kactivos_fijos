<?php
/**
*@package pXP
*@file gen-SistemaDist.php
*@author  (rarteaga)
*@date 20-09-2011 10:22:05
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
/***************************************************************************
#ISSUE  SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
 #2     KAF     ETR         22-05-2019  RCM     Se aumenta filtro para la distribución de valores dval
 #23    KAF     ETR         23/08/2019  RCM     Inclusión de botón para Impresión Reporte 8 Comparación AF y Conta. Además se aprovecha de ocultar botón de cbte 4 de entrada
 #35    KAF     ETR         11/10/2019  RCM     Adición de botón para procesar Detalle Depreciación
***************************************************************************/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoPrincipal = {
    bsave:false,
    require:'../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php',
    requireclase:'Phx.vista.Movimiento',
    title:'Movimientos',
    nombreVista: 'MovimientoPrincipal',
    timeout: 3600000,

    gruposBarraTareas:[
        {name:'Todos',title:'<h1 align="center"><i class="fa fa-bars"></i> Todos</h1>',grupo:0,height:0},
        {name:'Altas',title:'<h1 align="center"><i class="fa fa-thumbs-o-up"></i> Altas</h1>',grupo:1,height:0},
        {name:'Bajas/Retiros',title:'<H1 align="center"><i class="fa fa-thumbs-o-down"></i> Bajas y Retiros</h1>',grupo:2,height:0},
        {name:'Revalorizaciones/Mejoras',title:'<H1 align="center"><i class="fa fa-plus-circle"></i> Revaloriz/Ajustes</h1>',grupo:3,height:0},
        {name:'Asignaciones/Devoluciones',title:'<H1 align="center"><i class="fa fa-user-plus"></i> Asig/Devol/Transf</h1>',grupo:4,height:0},
        {name:'Depreciaciones',title:'<H1 align="center"><i class="fa fa-calculator"></i> Depreciaciones</h1>',grupo:5,height:0},
        {name:'Desglose/División',title:'<H1 align="center"><i class="fa fa-calculator"></i> Desglose, división e intercambio de partes</h1>',grupo:6,height:0}
    ],

    actualizarSegunTab: function(name, indice){
        if(indice==0){
            this.filterMov='%';
        } else if(indice==1){
            this.filterMov='alta';
        } else if(indice==2){
            this.filterMov='baja,retiro';
        } else if(indice==3){
            this.filterMov='reval,ajuste,mejora,transito';
        } else if(indice==4){
            this.filterMov='asig,devol,transf,tranfdep';
            this.getBoton('btnReporte').setVisible(false);
        } else if(indice==5){
            this.filterMov='deprec,actua';
        } else if(indice==6){
            this.filterMov='divis,desgl,intpar,dval'; //#2
        }
        this.store.baseParams.cod_movimiento = this.filterMov;
        this.store.baseParams.id_movimiento = this.maestro.lnk_id_movimiento;
        this.store.baseParams.tipo_interfaz = this.nombreVista;
        //this.getBoton('btnReporte').show();
        this.load({params:{start:0, limit:this.tam_pag}});
    },
    bnewGroups: [0,1,2,3,4,5,6],
    beditGroups: [0,1,2,3,4,5,6],
    bdelGroups:  [0,1,2,3,4,5,6],
    bactGroups:  [0,1,2,3,4,5,6],
    btestGroups: [0,1,2,3,4,5,6],
    bexcelGroups: [0,1,2,3,4,5,6],

    constructor: function(config) {

        Phx.vista.MovimientoPrincipal.superclass.constructor.call(this,config);
        this.maestro = config;
        this.init();
        this.load({
            params:{
                start:0,
                limit:this.tam_pag,
                id_movimiento: this.maestro.lnk_id_movimiento,
                tipo_interfaz: this.nombreVista
            }
        });


        //Evento para store de motivos
        this.Cmp.id_movimiento_motivo.getStore().on('load', function(store, records, options){
            if(store.getCount()==1){
                var data = records[0].id;
                this.Cmp.id_movimiento_motivo.setValue(records[0].id);
            }
        },this);

        //Add handler to id_cat_movimiento field
        this.Cmp.id_cat_movimiento.on('select', function(cmp,rec,el){
            //Habilita los campos
            this.habilitarCampos(rec.data.codigo);
            this.Cmp.id_movimiento_motivo.reset();
            this.Cmp.id_movimiento_motivo.modificado=true;
            this.Cmp.id_movimiento_motivo.store.baseParams.id_cat_movimiento=rec.data.id_catalogo;

             //Carga el store del combo de motivos
            this.Cmp.id_movimiento_motivo.getStore().load({
                params:{
                    start:0,
                    limit:this.tam_pag
                }
            });
        }, this);

        //Add handler to id_cat_movimiento field
        this.Cmp.id_depto_dest.on('select', function(cmp,rec,el){
            this.Cmp.id_deposito_dest.reset();
            this.Cmp.id_deposito_dest.modificado=true;
            this.Cmp.id_deposito_dest.store.baseParams.id_depto=rec.data.id_depto;
        }, this);

        this.addButton('ant_estado',{grupo: [0,1,2,3,4,5,6],argument: {estado: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.antEstado,tooltip: '<b>Pasar al Anterior Estado</b>'});
        this.addButton('sig_estado',{text:'Siguiente',iconCls: 'badelante',disabled:true,handler:this.sigEstado,tooltip: '<b>Pasar al Siguiente Estado</b>',grupo: [0,1,2,3,4,5,6],});
        this.addButton('diagrama_gantt',{text:'Gant',iconCls: 'bgantt',disabled:true,handler:diagramGantt,tooltip: '<b>Diagrama Gantt del proceso</b>',grupo: [0,1,2,3,4,5,6],});
        this.addButton('btnChequeoDocumentosWf',
            {
                text: 'Documentos',
                iconCls: 'bchecklist',
                disabled: true,
                handler: this.loadCheckDocumentosPlanWf,
                tooltip: '<b>Documentos de la Solicitud</b><br/>Subir los documentos requeridos en la solicitud seleccionada.',
                grupo: [0,1,2,3,4,5,6],
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

        //Crea los botones para los comprobantes
        this.addButton('btnCbte1',
            {
                text: 'Cbte.1',
                iconCls: 'bpdf', //#23 cambio de icono
                disabled: false,
                handler: this.mostrarCbte,
                tooltip: '<b>Comprobante 1</b><br/>Impresión del comprobante relacionado.',
                grupo: [0,1,2,3,4,5,6],
                cbte: 1
            }
        );

        this.addButton('btnCbte2',
            {
                text: 'Cbte.2',
                iconCls: 'bpdf', //#23 cambio de icono
                disabled: false,
                handler: this.mostrarCbte,
                tooltip: '<b>Comprobante 2</b><br/>Impresión del comprobante relacionado.',
                grupo: [0,1,2,3,4,5,6],
                cbte: 2
            }
        );

        this.addButton('btnCbte3',
            {
                text: 'Cbte.3',
                iconCls: 'bpdf', //#23 cambio de icono
                disabled: false,
                handler: this.mostrarCbte,
                tooltip: '<b>Comprobante 3</b><br/>Impresión del comprobante relacionado.',
                grupo: [0,1,2,3,4,5,6],
                cbte: 3
            }
        );

        this.addButton('btnCbte4',
            {
                text: 'Cbte.4',
                iconCls: 'bpdf', //#23 cambio de icono
                disabled: false,
                handler: this.mostrarCbte,
                tooltip: '<b>Comprobante 4</b><br/>Impresión del comprobante relacionado.',
                grupo: [0,1,2,3,4,5,6],
                cbte: 4
            }
        );

        //Inicio #35
        this.addButton('btnPocDetalleDep',
            {
                text: 'Procesar Reporte',
                iconCls: 'bgear',
                disabled: false,
                handler: this.verificarProcesoReporteDepreciacion,
                tooltip: '<b>Procesar Reporte</b><br/>Procesa el detalle depreciación del mes seleccionado',
                grupo: [0,5]
            }
        );
        //Fin #35

        //Inicio #23
        this.addButton('btnRepCompAfConta',
            {
                text: 'Comparación',
                iconCls: 'bsee',
                disabled: false,
                handler: this.generarReporteCompAfConta,
                tooltip: '<b>Comparación</b><br/>Compara los saldos de depreciación de Activos Fijos con los mayores Contables',
                grupo: [0,5]
            }
        );

        //Fin #23

        //Inicio #39
        this.addButton('btnImportDataDvalAF',
            {
                text: 'Activos Fijos',
                iconCls: 'bchecklist',
                disabled: false,
                handler: this.subirArchivoAF,
                tooltip: '<b>Destino Activos Fijos</b><br/>Importación desde Excel para Distribución de Valores con destino a Activos Fijos'
            }
        );

        this.addButton('btnImportDataDvalAL',
            {
                text: 'Almacén',
                iconCls: 'bchecklist',
                disabled: false,
                handler: this.subirArchivoAL,
                tooltip: '<b>Destino Almacén</b><br/>Importación desde Excel para Distribución de Valores con destino a Almacén'
            }
        );
        //Fin #39

        //Inicio #35
        this.addButton('btnRepDep',
            {
                text: 'Reporte Depreciación',
                iconCls: 'bexcel',
                disabled: false,
                handler: this.imprimirDetalleDep,
                tooltip: '<b>Detalle Depreciación</b><br/>Genera el reporte de Detalle de Depreciación',
                grupo: [0,5]
            }
        );
        //Fin #39


        //Oculta los botones
        this.getBoton('btnCbte1').hide();
        this.getBoton('btnCbte2').hide();
        this.getBoton('btnCbte3').hide();
        this.getBoton('btnCbte4').hide(); //#23
        this.getBoton('btnRepCompAfConta').hide(); //#23
        this.getBoton('btnPocDetalleDep').hide(); //#35

    },

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
        var swDireccion=false,swFechaHasta=false,swFuncionario=false,swOficina=false,swPersona=false,h=130,w=450,swDeptoDest=false,swDepositoDest=false,swFuncionarioDest=false,swCatMovMotivo=false,swPrestamo=false,swTipoAsig=false;

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
            swCatMovMotivo=true;
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
            swCatMovMotivo=true;
            swPrestamo=true;
            h=381;
        } else if(mov=='baja'||mov=='retiro'){
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
            swCatMovMotivo=true;
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
            swCatMovMotivo=true;
            swTipoAsig=true;
            h=298;
        } else if(mov=='ajuste'){
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
        } else if(mov=='reval'||mov=='mejora'){
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
            swCatMovMotivo=true;
            swTipoAsig=true;
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
            swCatMovMotivo=true;
            h=355;
        } else if(mov=='actua'){
            swDireccion=false;
            swFechaHasta=true;
            swFuncionario=false;
            swOficina=false;
            swPersona=false;
            swDeptoDest=false;
            swDepositoDest=false;
            swFuncionarioDest=false;
            swCatMovMotivo=true;
            h=280;
        } else if(mov=='divis'||mov=='desgl'||mov=='intpar'||mov=='dval'){ //#2
            swDireccion=false;
            swFechaHasta=false;
            swFuncionario=false;
            swOficina=false;
            swPersona=false;
            swDeptoDest=false;
            swDepositoDest=false;
            swFuncionarioDest=false;
            swCatMovMotivo=true;
            h=253;
        } else if(mov=='transito'){
            swDireccion=false;
            swFechaHasta=false;
            swFuncionario=false;
            swOficina=false;
            swPersona=false;
            swDeptoDest=false;
            swDepositoDest=false;
            swFuncionarioDest=false;
            swCatMovMotivo=true;
            h=253;
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
        this.Cmp.prestamo.setVisible(swPrestamo);
        this.Cmp.fecha_dev_prestamo.setVisible(swPrestamo);
        this.Cmp.tipo_asig.setVisible(swTipoAsig);

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
        this.Cmp.tipo_asig.allowBlank=!swTipoAsig;

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

    liberaMenu:function(){
        var tb = Phx.vista.Movimiento.superclass.liberaMenu.call(this);
        if(tb){
            this.getBoton('btnReporte').disable();
            this.getBoton('ant_estado').disable();
            this.getBoton('sig_estado').disable();
            this.getBoton('btnChequeoDocumentosWf').disable();
            this.getBoton('diagrama_gantt').disable();
            this.getBoton('btnAsignacion').disable();
            //Inicio #35
            this.getBoton('btnRepCompAfConta').hide();
            this.getBoton('btnPocDetalleDep').hide();
            this.getBoton('btnCbte1').hide();
            this.getBoton('btnCbte2').hide();
            this.getBoton('btnCbte3').hide();
            this.getBoton('btnCbte4').hide();
            //Fin #35
            //Inicio #39
            this.getBoton('btnImportDataDvalAF').hide();
            this.getBoton('btnImportDataDvalAL').hide();
            //fin #39
        }
       return tb
    },

    preparaMenu: function(n) {
        var tb = Phx.vista.Movimiento.superclass.preparaMenu.call(this);
        var data = this.getSelectedData();
        var tb = this.tbar;

        this.getBoton('btnChequeoDocumentosWf').enable();
        this.getBoton('diagrama_gantt').enable();

        //Oculta botones por defecto
        this.getBoton('btnCbte1').hide();
        this.getBoton('btnCbte2').hide();
        this.getBoton('btnCbte3').hide();
        this.getBoton('btnCbte4').hide();
        this.getBoton('btnRepCompAfConta').hide(); //#23
        this.getBoton('btnPocDetalleDep').hide(); //#35
        this.getBoton('btnImportDataDvalAF').hide(); //#39
        this.getBoton('btnImportDataDvalAL').hide(); //#39
        this.getBoton('btnRepDep').hide(); //#35

        if(data.cod_movimiento != 'asig' && data.cod_movimiento != 'transf' && data.cod_movimiento != 'devol'){
            this.getBoton('btnReporte').enable();
        }
        if(data.cod_movimiento == 'asig' || data.cod_movimiento == 'transf' || data.cod_movimiento == 'devol'){
            this.getBoton('btnAsignacion').enable();
        }
        //Inicio #39
        if(data.cod_movimiento == 'dval'){
            this.getBoton('btnImportDataDvalAF').show();
            this.getBoton('btnImportDataDvalAL').show();
        } else if(data.cod_movimiento == 'deprec'){
            //Inicio #23
            //Habilita el botón de comparación sólo para el caso de depreciación
            this.getBoton('btnRepCompAfConta').show();
            this.getBoton('btnPocDetalleDep').show();//#35
            this.getBoton('btnRepDep').show();//#35
            //Fin #23
        }
        //Fin #39

        //Enable/disable WF buttons by status
        this.getBoton('ant_estado').enable();
        this.getBoton('sig_estado').enable();

        if(data.estado == 'borrador'){
            this.getBoton('ant_estado').disable();
        } else if (data.estado == 'cbte'){
            this.getBoton('ant_estado').disable();
            this.getBoton('sig_estado').disable();
        }
        else {
            //Deshabilita el botón siguiente cuando no está en borrador para la vista transaccional, porque las aprobaciones se deben hacer por la interfaz de VoBo
            if(this.nombreVista == 'MovimientoPrincipal'){
                this.getBoton('sig_estado').disable();
            }
        }

        if(data.estado == 'finalizado' || data.estado == 'cancelado'){
            this.getBoton('ant_estado').disable();
            this.getBoton('sig_estado').disable();
        }

        //Verifica si tiene Comprobantes asociados para habilitar los botones
        if(data.id_int_comprobante){
            this.getBoton('btnCbte1').show();
        }
        if(data.id_int_comprobante_aitb){
            this.getBoton('btnCbte2').show();
        }
        if(data.id_int_comprobante_3){
            this.getBoton('btnCbte3').show();
        }
        if(data.id_int_comprobante_4){
            this.getBoton('btnCbte4').show();
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
        this.Cmp.prestamo.hide();
        this.Cmp.fecha_dev_prestamo.hide();
        this.Cmp.tipo_asig.hide();
    }  ,
    arrayDefaultColumHidden:['fecha_reg','usr_reg','fecha_mod','usr_mod','fecha_hasta','id_proceso_wf','id_estado_wf','id_funcionario','estado_reg','id_usuario_ai','usuario_ai','direccion','id_oficina'],
    rowExpander: new Ext.ux.grid.RowExpander({
            tpl : new Ext.Template(
                '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Registro:&nbsp;&nbsp;</b> {usr_reg}</p>',
                '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Registro:&nbsp;&nbsp;</b> {fecha_reg}</p>',
                '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Modificación:&nbsp;&nbsp;</b> {usr_mod}</p>',
                '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Modificación:&nbsp;&nbsp;</b> {fecha_mod}</p>'
            )
    }),

    mostrarCbte: function(args) {
        var rec = this.sm.getSelected(),
            data = rec.data,
            param;

        if(args.cbte == 1){
            param = data.id_proceso_wf_cbte1;
        } else if(args.cbte == 2){
            param = data.id_proceso_wf_cbte2;
        } else if(args.cbte == 3){
            param = data.id_proceso_wf_cbte3;
        } else if(args.cbte == 4){
            param = data.id_proceso_wf_cbte4;
        } else {
            return;
        }

        //Abre el reporte de comprobante
        if (data) {
            Phx.CP.loadingShow();
            Ext.Ajax.request({
                url: '../../sis_contabilidad/control/IntComprobante/reporteCbte',
                params: {
                    id_proceso_wf: param
                },
                success: this.successExport,
                failure: this.conexionFailure,
                timeout: this.timeout,
                scope: this
            });
        }
    },
    //Inicio #23
    generarReporteCompAfConta: function() {
        Phx.CP.loadingShow();

        var rec = this.sm.getSelected(),
            data = rec.data;

        if (data) {
            var fecha = new Date(data.fecha_mov);

            Ext.Ajax.request({
                url:'../../sis_kactivos_fijos/control/Reportes/ReporteComparacionAfContaXls',
                params:{
                    fecha: fecha.format('d-m-Y'),
                    id_movimiento: data.id_movimiento
                },
                success: this.successExport,
                failure: this.conexionFailure,
                timeout:this.timeout,
                scope:this
            });
        }

    },
    //Fin #23

    //Inicio #35
    procesarReporteDepreciacion: function() {
        var data = this.sm.getSelected().data;
        Phx.CP.loadingShow();
        Ext.Ajax.request({
            url: '../../sis_kactivos_fijos/control/MovimientoAfDep/procesarDetalleDepreciacion',
            params: { id_movimiento: data.id_movimiento },
            success: function(resp){
                Ext.MessageBox.alert('Respuesta', 'Información procesada con éxito');
                Phx.CP.loadingHide();
            },
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
    },

    verificarProcesoReporteDepreciacion: function() {
        var data = this.sm.getSelected().data;
        Phx.CP.loadingShow();

        Ext.Ajax.request({
            url: '../../sis_kactivos_fijos/control/MovimientoAfDep/verificarProcesarDetalleDepreciacion',
            params: { id_movimiento: data.id_movimiento },
            success: function(resp) {
                Phx.CP.loadingHide();

                var rec = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText)).ROOT;
                //Verifica si ya existen datos procesados para la fecha del movimiento
                if(rec.datos.existe == 'si'){
                    let v_mensaje = `Ya se encuentra procesada la información a la fecha del movimiento seleccionado ${new Date(data.fecha_hasta).format("d/m/Y")}. La fecha de procesamiento fue el ${rec.datos.fecha_proc}.<br><br> ¿Desea reprocesar los datos?<br><br>Este proceso tomará varios minutos.`;
                    Ext.MessageBox.confirm('Confirmación', v_mensaje, function(resp) {
                        if(resp == 'yes') {
                            //Reprocesa la información
                            this.procesarReporteDepreciacion();
                        }
                    }, this);
                } else if(rec.datos.existe == 'no'){
                    //Procesa la información
                    this.procesarReporteDepreciacion();
                } else {
                    Ext.MessageBox.alert('Información', 'Se ha producido un error. Vuelva a intentarlo más tarde');
                }
            },
            failure: this.conexionFailure,
            timeout: this.timeout,
            scope: this
        });
    },
    //Fin #35

    //Inicio #39
    subirArchivoAF: function(rec) {
        var record = this.sm.getSelected();
        Phx.CP.loadWindows
        (
            '../../../sis_kactivos_fijos/vista/movimiento/ImportarDvalAF.php',
            '´Destino Activos Fijos',
            {
                modal: true,
                width: 450,
                height: 150
            },
            record.data,
            this.idContenedor,
            'ImportarDvalAF'
        );
    },

    subirArchivoAL: function(rec) {
        var record = this.sm.getSelected();
        Phx.CP.loadWindows
        (
            '../../../sis_kactivos_fijos/vista/movimiento/ImportarDvalAL.php',
            'Destino Almacenes',
            {
                modal: true,
                width: 450,
                height: 150
            },
            record.data,
            this.idContenedor,
            'ImportarDvalAL'
        );
    },
    //Fin #39

    //Inicio #35
    imprimirDetalleDep: function(){
        //Verifica si ya existen datos procesados para la fecha del movimiento
        let v_mensaje = `¿Desea generar a Excel el reporte Detalle de Depreciación? <br><br>Este proceso tomará varios minutos.`;
        let data = this.sm.getSelected().data;
        Ext.MessageBox.confirm('Confirmación', v_mensaje, function(resp) {
            if(resp == 'yes') {
                Phx.CP.loadingShow();
                //Obtención de la moneda dep
                Ext.Ajax.request({
                    url:'../../sis_kactivos_fijos/control/MonedaDep/obtenerMonedaDep',
                    params: {
                        id_moneda: data.id_moneda
                    },
                    success: function(resp) {
                        let rec = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText)).ROOT;
                        //Genera el reporte
                        Ext.Ajax.request({
                            url:'../../sis_kactivos_fijos/control/Reportes/generarReporteDetalleDepreciacion',
                            params: {
                                tipo_salida: 'grid',
                                fecha_hasta: data.fecha_hasta,
                                id_moneda_dep: rec.datos.id_moneda_dep,
                                id_moneda: rec.datos.id_moneda
                            },
                            success: this.successExport,
                            failure: this.conexionFailure,
                            timeout: this.timeout,
                            scope: this
                        });
                    },
                    failure: this.conexionFailure,
                    timeout: this.timeout,
                    scope: this
                });
            }
        }, this);
    }
    //Fin #35


};
</script>
