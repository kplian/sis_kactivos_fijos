<?php
/**
*@package pXP
*@file    ImportarDvalAL.php
*@author  RCM
*@date    22/11/2018
*@description permite importar datos para distribución de valores a Activos Fijos

/***************************************************************************
#ISSUE   SIS     EMPRESA     FECHA       AUTOR   DESCRIPCION
 #39     KAF     ETR         22-11-2019  RCM     Creación del archivo
**************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ImportarDvalAL = Ext.extend(Phx.frmInterfaz, {
    ActSave:'../../sis_kactivos_fijos/control/Movimiento/ImportarDvalAL',

    constructor: function(config) {
        Phx.vista.ImportarDvalAL.superclass.constructor.call(this,config);
        this.init();
        this.loadValoresIniciales();
    },

    loadValoresIniciales: function() {
        Phx.vista.ImportarDvalAL.superclass.loadValoresIniciales.call(this);
        this.getComponente('id_movimiento').setValue(this.id_movimiento);
    },

    successSave: function(resp) {
        Phx.CP.loadingHide();
        Phx.CP.getPagina(this.idContenedorPadre).reload();
        this.panel.close();
    },


    Atributos:[
        {
            config:{
                labelSeparator:'',
                inputType:'hidden',
                name: 'id_movimiento'
            },
            type:'Field',
            form:true
        },
        {
            config:{
                fieldLabel: 'Archivo',
                gwidth: 130,
                inputType: 'file',
                name: 'archivo',
                allowBlank: false,
                buttonText: '',
                maxLength: 150,
                anchor:'100%'
            },
            type:'Field',
            form:true
        }
    ],
    title:'Subir Archivo',
    fileUpload:true

})
</script>