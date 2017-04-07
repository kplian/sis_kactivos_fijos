<?php
/**
*@package pXP
*@file gen-SistemaDist.php
*@author  (rarteaga)
*@date 20-09-2011 10:22:05
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoPrincipal = {    
    bsave:false,    
    require:'../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php',
    requireclase:'Phx.vista.Movimiento',
    title:'Venta',
    nombreVista: 'MovimientoPrincipal',
    
    gruposBarraTareas:[
		{name:'Todos',title:'<h1 align="center"><i class="fa fa-bars"></i> Todos</h1>',grupo:0,height:0},
	   	{name:'Altas',title:'<h1 align="center"><i class="fa fa-thumbs-o-up"></i> Altas</h1>',grupo:1,height:0},
       	{name:'Bajas',title:'<H1 align="center"><i class="fa fa-thumbs-o-down"></i> Bajas</h1>',grupo:2,height:0},
       	{name:'Revalorizaciones/Mejoras',title:'<H1 align="center"><i class="fa fa-plus-circle"></i> Revaloriz/Incrementos</h1>',grupo:3,height:0},
       	{name:'Asignaciones/Devoluciones',title:'<H1 align="center"><i class="fa fa-user-plus"></i> Asig/Devol/Transf</h1>',grupo:4,height:0},
       	{name:'Depreciaciones',title:'<H1 align="center"><i class="fa fa-calculator"></i> Depreciaciones</h1>',grupo:5,height:0}
    ],

    actualizarSegunTab: function(name, indice){
    	if(indice==0){
    		this.filterMov='%';
    	} else if(indice==1){
    		this.filterMov='alta';
    	} else if(indice==2){
    		this.filterMov='baja';
    	} else if(indice==3){
    		this.filterMov='reval,incdec';
    	} else if(indice==4){
    		this.filterMov='asig,devol,transf,tranfdep';
    	} else if(indice==5){
    		this.filterMov='deprec,actua';
    	}
    	this.store.baseParams.cod_movimiento = this.filterMov;
    	//this.getBoton('btnReporte').show();
    	this.load({params:{start:0, limit:this.tam_pag}});
    },
    bnewGroups: [0,1,2,3,4,5],
    beditGroups: [0,1,2,3,4,5],
    bdelGroups:  [0,1,2,3,4,5],
    bactGroups:  [0,1,2,3,4,5],
    btestGroups: [0,1,2,3,4,5],
    bexcelGroups: [0,1,2,3,4,5],
    
    
    
    constructor: function(config) {
       
        Phx.vista.MovimientoPrincipal.superclass.constructor.call(this,config);
        
        this.init();
        
        this.load({params:{start:0, limit:this.tam_pag}})

		/*this.addButton('btnMovGral',
            {
                text: 'Movimientos',
                iconCls: 'bchecklist',
                disabled: false,
                handler: this.openMovimientos
            }
        );*/
        //Add handler to id_cat_movimiento field
        this.Cmp.id_cat_movimiento.on('select', function(cmp,rec,el){
        	this.habilitarCampos(rec.data.codigo);
        	this.Cmp.id_movimiento_motivo.reset();
            this.Cmp.id_movimiento_motivo.modificado=true;
            this.Cmp.id_movimiento_motivo.store.baseParams.id_cat_movimiento=rec.data.id_catalogo;
        }, this);
        
        //Add handler to id_cat_movimiento field
        this.Cmp.id_depto_dest.on('select', function(cmp,rec,el){
        	this.Cmp.id_deposito_dest.reset();
            this.Cmp.id_deposito_dest.modificado=true;
            this.Cmp.id_deposito_dest.store.baseParams.id_depto=rec.data.id_depto;
        }, this);

        this.addButton('ant_estado',{argument: {estado: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.antEstado,tooltip: '<b>Pasar al Anterior Estado</b>'});
        this.addButton('sig_estado',{text:'Siguiente',iconCls: 'badelante',disabled:true,handler:this.sigEstado,tooltip: '<b>Pasar al Siguiente Estado</b>'});
		this.addButton('diagrama_gantt',{text:'Gant',iconCls: 'bgantt',disabled:true,handler:diagramGantt,tooltip: '<b>Diagrama Gantt del proceso</b>'});
		this.addButton('btnChequeoDocumentosWf',
            {
                text: 'Documentos',
                iconCls: 'bchecklist',
                disabled: true,
                handler: this.loadCheckDocumentosPlanWf,
                tooltip: '<b>Documentos de la Solicitud</b><br/>Subir los documetos requeridos en la solicitud seleccionada.'
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
        
        
    } ,  
    
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
    	var swDireccion=false,swFechaHasta=false,swFuncionario=false,swOficina=false,swPersona=false,h=130,w=450,swDeptoDest=false,swDepositoDest=false,swFuncionarioDest=false,swCatMovMotivo=false;

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
    		swCatMovMotivo=false;
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
    		swCatMovMotivo=false;
    		h=381;
    	} else if(mov=='baja'){
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
    		swCatMovMotivo=false;
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
    		swCatMovMotivo=false;
    		h=298;
    	} else if(mov=='incdec'){
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
    	} else if(mov=='reval'){
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
    		swCatMovMotivo=false;
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
    		swCatMovMotivo=false;
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
    		swCatMovMotivo=false;
    		h=280;
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
        }
       return tb
    },
    preparaMenu:function(n){
    	var tb = Phx.vista.Movimiento.superclass.preparaMenu.call(this);
      	var data = this.getSelectedData();
      	var tb = this.tbar;

        this.getBoton('btnReporte').enable(); 
        this.getBoton('btnChequeoDocumentosWf').enable();
        this.getBoton('diagrama_gantt').enable();

        //Enable/disable WF buttons by status
        this.getBoton('ant_estado').enable();
        this.getBoton('sig_estado').enable();
        if(data.estado=='borrador'){
        	this.getBoton('ant_estado').disable();
        }
        if(data.estado=='finalizado'||data.estado=='cancelado'){
        	//this.getBoton('ant_estado').disable();
        	//this.getBoton('sig_estado').disable();
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
    }  ,
    arrayDefaultColumHidden:['fecha_reg','usr_reg','fecha_mod','usr_mod','fecha_hasta','id_proceso_wf','id_estado_wf','id_funcionario','estado_reg','id_usuario_ai','usuario_ai','direccion','id_oficina'],
	rowExpander: new Ext.ux.grid.RowExpander({
	        tpl : new Ext.Template(
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Registro:&nbsp;&nbsp;</b> {usr_reg}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Registro:&nbsp;&nbsp;</b> {fecha_reg}</p>',	       
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Modificación:&nbsp;&nbsp;</b> {usr_mod}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Modificación:&nbsp;&nbsp;</b> {fecha_mod}</p>'
	        )
    })    
    
    
};
</script>
