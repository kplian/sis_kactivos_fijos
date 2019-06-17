<?php
/**
*@package pXP
*@file    ImportarCentroCosto.php
*@author  MZM
*@date    13/05/2019
*@description permites subir archivos a la tabla de documento_sol
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ImportarCentroCosto=Ext.extend(Phx.frmInterfaz,{
    ActSave:'../../sis_kactivos_fijos/control/ActivoFijoCc/ImportarCentroCosto',

    constructor:function(config){
        Phx.vista.ImportarCentroCosto.superclass.constructor.call(this,config);
        this.init();
        this.loadValoresIniciales();
    },

    loadValoresIniciales:function(){
        Phx.vista.ImportarCentroCosto.superclass.loadValoresIniciales.call(this);
        this.getComponente('id_activo_fijo').setValue(this.id_activo_fijo);
    },

    successSave:function(resp){
        //alert('sssssssss'+resp.responseText);
        Ext.Ajax.request({
					url : '../../sis_kactivos_fijos/control/ActivoFijoCc/listarLogActivoFijoCc',
					params : {
						'nombre_archivo' : data.id_uni_cons
					},
					success : this.successExportCC,
					failure : this.conexionFailure,
					timeout : this.timeout,
					scope : this
				});
        
        
        Phx.CP.loadingHide();
        Phx.CP.getPagina(this.idContenedorPadre).reload();
        this.panel.close();
       
       
      
       
    },

	successExportCC:function(resp){  
		var reg1 = Ext.util.JSON.decode(Ext.util.Format.trim(resp.responseText));
		if (reg1['total']!=undefined && reg1['total']!=0){
			Ext.Msg.alert('Notificación','Importación realizada. Revise el log con las observaciones',function(btn){
							
			   Ext.Ajax.request({
				url:'../../sis_kactivos_fijos/control/ActivoFijoCc/RLogAFCCXls',
				params:
				{		
					'tipoReporte':'excel_grid',
					'fecha_ini':'15/05/2018',			
					'fecha_fin':'15/05/2019'			
				},
				success: this.successExport,		
				failure: this.conexionFailure,
				timeout:this.timeout,
				scope:this
			});
				
				
		}, this)
			
		}else{
			
			Ext.Msg.alert('Notificación','Importación realizada');
		}
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

}
)
</script>
