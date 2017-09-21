<?php
/**
*@package pXP
*@file MovimientoAfDepRes.php
*@author  RCM
*@date 05/05/2016
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoAfDepPrin = {
    bedit:false,
    bnew:false,
    bsave:false,
    bdel:false,
	require:'../../../sis_kactivos_fijos/vista/movimiento_af_dep/MovimientoAfDep.php',
	requireclase:'Phx.vista.MovimientoAfDep',
	title:'Resumen Depreciacion',
	nombreVista: 'ActivoFijoValoresDepPrin',
	ActList:'../../sis_kactivos_fijos/control/MovimientoAfDep/listarMovimientoAfDepRes',
	id_store:'id_movimiento_af_dep',	
	constructor: function(config) {  
	    this.maestro=config.maestro;
    	Phx.vista.MovimientoAfDepPrin.superclass.constructor.call(this,config);
    	 
       
	   
	},
	
	onReloadPage : function(m) {
		this.maestro = m;
		console.log('TRES',this.maestro);
		this.store.baseParams = {			
			id_activo_fijo_valor: this.maestro.id_activo_fijo_valor
		};
		
		//si el padre tiene limite de fecha
		var campo_fecha = Phx.CP.getPagina(this.idContenedorPadre).campo_fecha		
		if(campo_fecha){		    
		   Ext.apply(this.store.baseParams, { fecha_hasta: campo_fecha.getValue().dateFormat('d/m/Y')})
		
		}
		
		
	
		console.log('........datos...',this.store.baseParams, campo_fecha )
		
		this.load({
			params : {
				start : 0, 
				limit : 50
			}
		});
	},
	bdel:false,
	bsave:false,
	bedit:false,
	bnew:false,
	
	 
	


};
</script>
