<?php
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoRapido = Ext.define('Phx.vista.MovimientoRapido', {
    extend: 'Ext.util.Observable',
    constructor: function(config) {
    	Ext.apply(this, config);
        Phx.vista.MovimientoRapido.superclass.constructor.call(this);
        this.panel = Ext.getCmp(this.idContenedor);
        this.crearComponentesCabecera();
        this.crearComponentesPanel();
        this.crearVentana();
        this.personalizarCabecera();
        this.cargarDatosCabecera();
        this.cargarDatosPaneles();
    },
    cargarDatosCabecera: function(){
        var tipoMov = this.tipoMov,
            fecha = new Date(),
            glosa='';

        //Generales
        this.cmpFecha.setValue(fecha);

        //Específicos
        if(tipoMov=='asig'){
            glosa = 'Asignación rápida de activos fijos';
            this.cmpGlosa.setValue(glosa);

        } else if(tipoMov=='transf'){
            glosa = 'Transferencia rápida de activos fijos';
            //Funcionario
            var func = this.obtenerDescripcionFuncionario(this.dataAf),
                rec = new Ext.data.Record({desc_person: func.funcionario, id_funcionario: func.id_funcionario },func.id_funcionario);
            this.cmpFuncionario.store.add(rec);
            this.cmpFuncionario.store.commitChanges();
            this.cmpFuncionario.modificado = true;
            this.cmpFuncionario.setValue(func.id_funcionario);

            this.cmpGlosa.setValue(glosa);
            this.cmpFuncionario.setDisabled(true);

        } else if(tipoMov=='devol'){
            glosa = 'Devolución rápida de activos fijos';
            //Funcionario
            var func = this.obtenerDescripcionFuncionario(this.dataAf),
                rec = new Ext.data.Record({desc_person: func.funcionario, id_funcionario: func.id_funcionario },func.id_funcionario);
            this.cmpFuncionario.store.add(rec);
            this.cmpFuncionario.store.commitChanges();
            this.cmpFuncionario.modificado = true;
            this.cmpFuncionario.setValue(func.id_funcionario);

            this.cmpGlosa.setValue(glosa);
            this.cmpFuncionario.setDisabled(true);
        }
    },
    cargarDatosPaneles: function(){
        var error='';
        this.MovRecord = Ext.data.Record.create([
            {name: 'id_activo_fijo', mapping: 'id_activo_fijo', type: 'int'},
            {name: 'codigo', mapping: 'codigo'},
            {name: 'denominacion', mapping: 'denominacion'},
            {name: 'funcionario', mapping: 'funcionario'},
            {name: 'estado', mapping: 'estado'},
            {name: 'en_deposito', mapping: 'en_deposito'}
        ]);
        Ext.each(this.dataAf, function(el,index){
            var newRecord = new this.MovRecord({
                id_activo_fijo: el.data.id_activo_fijo,
                codigo: el.data.codigo,
                denominacion: el.data.denominacion,
                funcionario:  el.data.funcionario,
                estado: el.data.estado,
                en_deposito: el.data.en_deposito
            },el.data.id_activo_fijo);

            if(this.validacionRegistro(newRecord)){
                this.storeDest.add(newRecord);
            } else {
                error = 'Algún(os) activos no cumplen regla para ser incluido(s)';
                this.storeOrig.add(newRecord);
            }
        },this);

        this.actualizarMensajeBBar(error);
    },
    crearComponentesCabecera: function(){
        this.cmpFecha = new Ext.form.DateField({
            fieldLabel: '* Fecha',
            allowBlank: false
        });
        this.cmpGlosa = new Ext.form.TextArea({
            fieldLabel: '* Glosa',
            maxLength: 1500,
            width:'100%',
            allowBlank: false
        });
        this.cmpFuncionario = new Ext.form.ComboBox({
            fieldLabel:'* Responsable actual',
            emptyText:'Seleccione un registro...',
            store: new Ext.data.JsonStore({
                url : '../../sis_organigrama/control/Funcionario/listarFuncionario',
                id: 'id_funcionario',
                root: 'datos',
                sortInfo:{
                    field: 'desc_person',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_funcionario','codigo','desc_person','ci','documento','telefono','celular','correo'],
                // turn on remote sorting
                remoteSort: true,
                baseParams:{par_filtro:'funcio.codigo#nombre_completo1'}
            }),
            tpl:'<tpl for="."><div class="x-combo-list-item"><p>{codigo} - Sis: {codigo_sub} </p><p>{desc_person}</p><p>CI:{ci}</p> </div></tpl>',
            valueField: 'id_funcionario',
            displayField: 'desc_person',
            forceSelection:false,
            typeAhead: false,
            triggerAction: 'all',
            lazyRender: true,
            mode: 'remote',
            pageSize: 10,
            queryDelay: 1000,
            minChars: 2,
            width: 250,
            listWidth: 280,
            allowBlank: false
        });
        this.cmpDireccion = new Ext.form.TextArea({
            fieldLabel: '* Nueva Dirección',
            maxLength: 500,
            width:'100%',
            allowBlank: false
        });
        this.cmpFuncionarioDest = new Ext.form.ComboBox({
            fieldLabel:'* Nuevo responsable',
            emptyText:'Seleccione un registro...',
            store: new Ext.data.JsonStore({
                url : '../../sis_organigrama/control/Funcionario/listarFuncionario',
                id: 'id_funcionario',
                root: 'datos',
                sortInfo:{
                    field: 'desc_person',
                    direction: 'ASC'
                },
                totalProperty: 'total',
                fields: ['id_funcionario','codigo','desc_person','ci','documento','telefono','celular','correo'],
                // turn on remote sorting
                remoteSort: true,
                baseParams:{par_filtro:'funcio.codigo#nombre_completo1'}
            }),
            tpl:'<tpl for="."><div class="x-combo-list-item"><p>{codigo} - Sis: {codigo_sub} </p><p>{desc_person}</p><p>CI:{ci}</p> </div></tpl>',
            valueField: 'id_funcionario',
            displayField: 'desc_person',
            forceSelection: false,
            typeAhead: false,
            triggerAction: 'all',
            lazyRender: true,
            mode: 'remote',
            pageSize: 10,
            queryDelay: 1000,
            minChars: 2,
            width: 250,
            listWidth: 280,
            allowBlank: false
        });
        this.cmpOficina = new Ext.form.ComboBox({
            fieldLabel: '* Nueva Oficina',
            emptyText: 'Elija una opción...',
            store: new Ext.data.JsonStore({
                url: '../../sis_organigrama/control/Oficina/listarOficina',
                id: 'id_oficina',
                root: 'datos',
                fields: ['id_oficina','codigo','nombre'],
                totalProperty: 'total',
                sortInfo: {
                    field: 'codigo',
                    direction: 'ASC'
                },
                baseParams:{par_filtro:'ofi.codigo#ofi.nombre'}
            }),
            valueField: 'id_oficina',
            displayField: 'nombre',
            gdisplayField: 'oficina',
            hiddenName: 'id_oficina',
            forceSelection: false,
            typeAhead: false,
            triggerAction: 'all',
            lazyRender: true,
            mode: 'remote',
            pageSize: 15,
            queryDelay: 1000,
            width: 250,
            gwidth: 150,
            minChars: 2,
            renderer: function(value, p, record) {
                return String.format('{0}', record.data['oficina']);
            },
            allowBlank: false
        });
    },
    crearComponentesPanel: function(){
        this.storeOrig = new Ext.data.JsonStore({});
        this.storeDest = new Ext.data.JsonStore({});
        
        this.listViewOrig = new Ext.list.ListView({
            store: this.storeOrig,
            multiSelect: true,
            reserveScrollOffset: true,
            columnSort: false,
            columns: [{
                header: 'Código',
                width: .2,
                dataIndex: 'codigo'
            },{
                header: 'Denominación',
                width: .4,
                dataIndex: 'denominacion'
            },{
                header: 'Responsable actual',
                dataIndex: 'funcionario',
                width: .4
            }],
            height: 270,
            width: 400
        });
        
        this.listViewDest = new Ext.list.ListView({
            store: this.storeDest,
            multiSelect: true,
            reserveScrollOffset: true,
            columnSort: false,
            columns: [{
                header: 'Código',
                width: .2,
                dataIndex: 'codigo'
            },{
                header: 'Denominación',
                width: .4,
                dataIndex: 'denominacion'
            },{
                header: 'Responsable actual',
                dataIndex: 'funcionario',
                width: .4
            }],
            height: 270,
            width: 400
        });

        this.btnQuitarTodos = new Ext.Button({
            text:'<i class="fa fa-backward" aria-hidden="true"></i>',
            handler: function(){
                this.removeAllElem();
            },
            width:30,
            scope: this
        });
        this.btnQuitar = new Ext.Button({
            text:'<i class="fa fa-caret-left" aria-hidden="true"></i>',
            handler: function(){
               this.removeElem();
            },
            width:30,
            scope: this
        });
        this.btnAgregarTodos = new Ext.Button({
            text:'<i class="fa fa-forward" aria-hidden="true"></i>',
            handler: function(){
                this.addAllElem();
            },
            width:30,
            scope: this
        });
        this.btnAgregar = new Ext.Button({
            text:'<i class="fa fa-caret-right" aria-hidden="true"></i>',
            handler: function(){
                this.addElem();
            },
            width:30,
            scope: this
        });

    },

    crearVentana: function(){

        this.formMovRap = new Ext.form.FormPanel({
            items: [{
                layout: 'table',
                bodyBorder: false,
                border: false,
                layoutConfig: {
                    columns: 3
                },
                region: 'center',
                items: [{
                    xtype: 'fieldset',
                    autoHeight: true,
                    width: 840,
                    items: [
                        this.cmpFecha,
                        this.cmpGlosa,
                        this.cmpFuncionario,
                        this.cmpFuncionarioDest,
                        this.cmpDireccion,
                        this.cmpOficina
                    ],
                    colspan:3
                },{
                    xtype: 'panel',
                    bodyBorder: true,
                    border: true,
                    items: [this.listViewOrig]
                }, {
                    xtype: 'panel',
                    bodyBorder: false,
                    border: false,
                    items: [{
                        xtype: 'panel',
                        layout: 'vbox',
                        height: 270,
                        align: 'center',
                        bodyBorder: false,
                        border: false,
                        items: [
                            { xtype: 'tbspacer', flex: 1},
                            this.btnQuitarTodos,
                            this.btnQuitar,
                            this.btnAgregar,
                            this.btnAgregarTodos,
                            { xtype: 'tbspacer', flex: 1}
                        ]
                    }
                    ]
                }, {
                    xtype: 'panel',
                    bodyBorder: true,
                    border: true,
                    items: [this.listViewDest]
                }],
            }],
            padding: this.paddingForm,
            bodyStyle: this.bodyStyleForm,
            border: this.borderForm,
            frame: this.frameForm, 
            autoScroll: false,
            autoDestroy: true,
            autoScroll: true,
            region: 'center'
        });
        
        this.panel.add(this.formMovRap)
        this.panel.doLayout();

        //Agrega botones submit y cancel
        this.agregarBotonesVentana();
    },
    removeAllElem: function(){
        var items = this.listViewDest.getRecords(this.listViewDest.getNodes());
        //Add elements to origin store
        Ext.each(items, function(el, index){
            var newRecord = new this.MovRecord({
                id_activo_fijo: el.data.id_activo_fijo,
                codigo: el.data.codigo,
                denominacion: el.data.denominacion,
                funcionario:  el.data.funcionario,
                estado: el.data.estado,
                en_deposito: el.data.en_deposito
            },el.data.id_activo_fijo);
            this.storeOrig.add(newRecord);
        }, this);
        //Remove elements of destiny store
        this.storeDest.removeAll();
        //Cambiar estado bbar
        this.actualizarMensajeBBar('');
    },
    removeElem: function(){
        var items = this.listViewDest.getSelectedRecords();

        Ext.each(items, function(el, index){
            var newRecord = new this.MovRecord({
                id_activo_fijo: el.data.id_activo_fijo,
                codigo: el.data.codigo,
                denominacion: el.data.denominacion,
                funcionario:  el.data.funcionario,
                estado: el.data.estado,
                en_deposito: el.data.en_deposito
            },el.data.id_activo_fijo);

            this.storeOrig.add(newRecord);
            this.storeDest.remove(el)
        }, this);

        this.actualizarMensajeBBar('');
    },
    addElem: function(){
        var items = this.listViewOrig.getSelectedRecords(),
            error='';

        Ext.each(items, function(el, index){
            var newRecord = new this.MovRecord({
                id_activo_fijo: el.data.id_activo_fijo,
                codigo: el.data.codigo,
                denominacion: el.data.denominacion,
                funcionario:  el.data.funcionario,
                estado: el.data.estado,
                en_deposito: el.data.en_deposito
            },el.data.id_activo_fijo);
            if(this.validacionRegistro(newRecord)){
                this.storeDest.add(newRecord);
                this.storeOrig.remove(el)
            } else {
                error = 'Algún(os) activos no cumplen regla para ser incluido(s)';
            }
        }, this);

        this.actualizarMensajeBBar(error);
    },
    addAllElem: function(){
        var items = this.listViewOrig.getRecords(this.listViewOrig.getNodes()),
            error='';
        //Add elements to origin store
        Ext.each(items, function(el, index){
            var newRecord = new this.MovRecord({
                id_activo_fijo: el.data.id_activo_fijo,
                codigo: el.data.codigo,
                denominacion: el.data.denominacion,
                funcionario:  el.data.funcionario,
                estado: el.data.estado,
                en_deposito: el.data.en_deposito
            },el.data.id_activo_fijo);

            if(this.validacionRegistro(newRecord)){
                this.storeDest.add(newRecord);
                this.storeOrig.remove(el)
            } else {
                error = 'Algún(os) activos no cumplen regla para ser incluido(s)';
            }
        }, this);

        this.actualizarMensajeBBar(error);
    },
    agregarBotonesVentana: function(){
        //Creación botones
        this.btnSubmit = new Ext.Button({
            text: 'Guardar',
            scope: this
        });
        this.btnCancel = new Ext.Button({
            text: 'Declinar',
            scope: this
        });
        //Creación label para bbar
        this.lblEstado = new Ext.form.Label({
            text: 'Listo'
        });

        //Agregar botones
        this.winForm = Ext.getCmp(this.idContenedor);
        this.winForm.addButton(this.btnSubmit,this.submit,this);
        this.winForm.addButton(this.btnCancel,this.cancel,this);

        //Agregar bbar
        this.winForm.getBottomToolbar().add(this.lblEstado);

        //Render
        this.winForm.doLayout();
    },
    submit: function(){
        if(this.formMovRap.getForm().isValid()){
            if(this.listViewDest.getRecords(this.listViewDest.getNodes()).length>0){
                Phx.CP.loadingShow();
                var params = this.getFormParams();
                Ext.Ajax.request({
                    url: '../../sis_kactivos_fijos/control/Movimiento/generarMovimientoRapido',
                    params: params,
                    isUpload: false,
                    success: function(a,b,c){
                        this.reload();
                        Phx.CP.loadingHide();
                        this.winForm.close();
                        Ext.MessageBox.alert('Información','EL movimiento ha sido generado satisfactoriamente.');
                    },
                    argument: Phx.CP.argumentSave,
                    failure: Phx.CP.conexionFailure,
                    timeout: Phx.CP.timeout,
                    scope: this
                });
            } else {
                Ext.MessageBox.alert('Información','Seleccione al menos un activo fijo para generar el movimiento.');
            }
        }
    },
    cancel: function(){
        this.winForm.close();
    },
    personalizarCabecera: function(){
        var tipoMov = this.tipoMov,
            size = {
                height: 630,
                width: 870
            };

        if(tipoMov=='asig') {
            this.cmpFuncionario.hide();
            this.cmpFuncionario.allowBlank=true;
            size.height = 595;
        } else if(tipoMov=='transf'){

        } else if(tipoMov=='devol'){
            this.cmpFuncionarioDest.hide();
            this.cmpOficina.hide();
            this.cmpDireccion.hide();

            this.cmpFuncionarioDest.allowBlank=true;
            this.cmpOficina.allowBlank=true;
            this.cmpDireccion.allowBlank=true;

            size.height = 500;
        }

        //Seteo del tamaño de la ventana
        this.winForm.setSize(size.width,size.height);
    },
    obtenerDescripcionFuncionario: function(data){
        var idFuncionario=0,
            funcionario='',
            cont=0,
            res={};

        Ext.each(data, function(el,index){
            if(idFuncionario!=el.data.id_funcionario){
                idFuncionario=el.data.id_funcionario;
                funcionario = el.data.funcionario;
                cont++;
            }
        }, this);

        //Verifica si hay más de un funcionario (si cont> 1 entonces existe más de un funcionario)
        res.total = cont;
        res.funcionario = funcionario;
        res.id_funcionario =  idFuncionario;

        if(cont>1){
            res.funcionario = 'Existen '+cont+' funcionarios diferentes';
            res.id_funcionario = -1;
        }

        return res;

    },
    getFormParams: function(){
        return {
            tipo_movimiento: this.tipoMov,
            fecha: this.cmpFecha.getValue(),
            glosa: this.cmpGlosa.getValue(),
            id_funcionario: this.cmpFuncionarioDest.getValue(),
            direccion: this.cmpDireccion.getValue(),
            id_oficina: this.cmpOficina.getValue(),
            ids_af: this.getIdsFromList()
        }
    },
    getIdsFromList: function(){
        var items = this.listViewDest.getRecords(this.listViewDest.getNodes()),
            ids='';
        //Add elements to origin store
        Ext.each(items, function(el, index){
            ids+=el.data.id_activo_fijo+',';
        }, this);
        ids=ids.substring(0,ids.length-1);

        return ids;
    },
    validacionRegistro: function(rec){
        var tipoMov = this.tipoMov,
            rules = {
            asig: {
                estado: ['alta'],
                enDeposito: 'si'
            },
            transf: {
                estado: ['alta'],
                enDeposito: 'no'
            },
            devol: {
                estado: ['alta'],
                enDeposito: 'no'
            }
        };

        if(rules[tipoMov].estado.indexOf(rec.data.estado)>-1&&rules[tipoMov].enDeposito==rec.data.en_deposito){
            return true;
        }
        return false;
    },
    actualizarMensajeBBar: function(error){
        if(error!=''){
            this.lblEstado.setText(error);
        } else {
            this.lblEstado.setText('Listo');
        }
    }

});
</script>