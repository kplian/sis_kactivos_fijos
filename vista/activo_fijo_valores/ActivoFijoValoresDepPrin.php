<?php
/**
*@package pXP
*@file ActivoFijoValoresDep.php
*@author  RCM
*@date 05/05/2016
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijoValoresDepPrin = {
    bedit:false,
    bnew:false,
    bsave:false,
    bdel:false,
	require:'../../../sis_kactivos_fijos/vista/activo_fijo_valores/ActivoFijoValores.php',
	requireclase:'Phx.vista.ActivoFijoValores',
	title:'Resumen Depreciacion',
	nombreVista: 'ActivoFijoValoresDepPrin',
	
	constructor: function(config) {  
	    this.maestro=config.maestro;
    	Phx.vista.ActivoFijoValoresDepPrin.superclass.constructor.call(this,config);
    	 var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData()
        if(dataPadre){
            this.onEnablePanel(this, dataPadre);
        }
        else
        {
           this.bloquearMenus();
        }
       
	   
	},
	
	 onReloadPage:function(m){
	 	
		this.maestro=m;
		this.store.baseParams={id_activo_fijo:this.maestro.id_activo_fijo};	
		console.log('datos maestro', m, this.store.baseParams)	
		this.load({params:{start:0, limit:50}})
		
	},
	
	
	loadValoresIniciales:function(){
		Phx.vista.ActivoFijoValoresDepPrin.superclass.loadValoresIniciales.call(this);
			
	}, 


	ActList:'../../sis_kactivos_fijos/control/MovimientoAfDep/listarMovimientoAfDepResCabPr',

    south: { 
        url:'../../../sis_kactivos_fijos/vista/movimiento_af_dep/MovimientoAfDepPrin.php',
        title:'Detalle', 
        height:'60%',
        cls:'MovimientoAfDepPrin'
	}

};
</script>
