<?php
/**
*@package pXP
*@file    SubirActualizacionDatos.php
*@author  RCM
*@date    09/12/2020
*@description permite subir archivo excel para la actualización de datos de activos fijos
***************************************************************************
 ISSUE        SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029    KAF       ETR           09/12/2020  RCM         Creación del archivo
***************************************************************************
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.SubirActualizacionDatos = Ext.extend(Phx.frmInterfaz, {
    ActSave: '../../sis_kactivos_fijos/control/ActivoModMasivo/ImportarDatosActualizacion',

    constructor: function(config) {
        Phx.vista.SubirActualizacionDatos.superclass.constructor.call(this,config);
        this.init();
        this.loadValoresIniciales();
    },

    loadValoresIniciales:function(){
        Phx.vista.SubirActualizacionDatos.superclass.loadValoresIniciales.call(this);
        this.getComponente('id_activo_mod_masivo').setValue(this.id_activo_mod_masivo);
    },

    successSave:function(resp){
        Phx.CP.loadingHide();
        Phx.CP.getPagina(this.idContenedorPadre).reload();
        this.panel.close();
    },

    Atributos: [
        {
            config: {
                labelSeparator: '',
                inputType: 'hidden',
                name: 'id_activo_mod_masivo'
            },
            type: 'Field',
            form: true
        },
        {
            config: {
                fieldLabel: 'Archivo',
                gwidth: 130,
                inputType: 'file',
                name: 'archivo',
                allowBlank: false,
                buttonText: '',
                maxLength: 150,
                anchor: '100%'
            },
            type: 'Field',
            form: true
        }
    ],
    title: 'Importar Archivo',
    fileUpload: true
})
</script>