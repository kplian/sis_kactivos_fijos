<?php
/**
*@package pXP
*@file MovimientoVb.php
*@author  RCM
*@date 28/09/2017
*@description Archivo con la interfaz de usuario que permite 
*dar el visto a los movimientos de activos fijos
*
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoVb = {
	require: '../../../sis_kactivos_fijos/vista/movimiento/MovimientoPrincipal.php',
	requireclase: 'Phx.vista.MovimientoPrincipal',
	nombreVista: 'MovimientoVb',
	constructor: function(config){
		this.maestro = config.maestro;
		//Configuración de la interfaz
		this.bnew=false;
		this.bedit=false;
		this.bdel=false;
		Phx.vista.MovimientoVb.superclass.constructor.call(this,config);
		this.init();
	}
}
</script>