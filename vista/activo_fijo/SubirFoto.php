<?php
/**
*@package pXP
*@file    SubirFoto.php
*@author  RCM
*@date    07/04/2016
*@description permites subir foto de los activos fijos
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.SubirFoto=Ext.extend(Phx.frmInterfaz,{
    ActSave:'../../sis_kactivos_fijos/control/ActivoFijo/subirFoto',

    constructor:function(config){   
        Phx.vista.SubirFoto.superclass.constructor.call(this,config);
        this.init();    
        this.loadValoresIniciales();
    },
    
    loadValoresIniciales:function(){        
        Phx.vista.SubirFoto.superclass.loadValoresIniciales.call(this);
        this.getComponente('id_activo_fijo').setValue(this.id_activo_fijo); 
    },
    
    successSave:function(resp){
        Phx.CP.loadingHide();
        Phx.CP.getPagina(this.idContenedorPadre).reload();
        this.panel.close();
    },
                
    
    Atributos:[
        {
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
                fieldLabel: "Foto",
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
    title:'Subir Foto',    
    fileUpload:true
    
}
)    
</script>
