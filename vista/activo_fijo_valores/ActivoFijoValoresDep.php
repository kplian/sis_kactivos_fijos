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
Phx.vista.ActivoFijoValoresDep = {
    bedit:false,
    bnew:false,
    bsave:false,
    bdel:false,
	require:'../../../sis_kactivos_fijos/vista/activo_fijo_valores/ActivoFijoValores.php',
	requireclase:'Phx.vista.ActivoFijoValores',
	title:'Resumen Depreciacion',
	nombreVista: 'ActivoFijoValoresDep',
	
	constructor: function(config) {  
	    this.maestro=config.maestro;
    	Phx.vista.ActivoFijoValoresDep.superclass.constructor.call(this,config);
	    //this.load({params:{start:0, limit:this.tam_pag}});
	},

	ActList:'../../sis_kactivos_fijos/control/MovimientoAfDep/listarMovimientoAfDepResCab',

    south: { 
        url:'../../../sis_kactivos_fijos/vista/movimiento_af_dep/MovimientoAfDepRes.php',
        title:'Detalle', 
        height:'60%',
        cls:'MovimientoAfDepRes'
	}

};
</script>
