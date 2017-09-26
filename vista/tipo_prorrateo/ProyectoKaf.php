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
Phx.vista.ProyectoKaf = {
    bedit:false,
    bnew:false,
    bsave:false,
    bdel:false,
	require:'../../../sis_parametros/vista/proyecto/Proyecto.php',
	requireclase:'Phx.vista.Proyecto',
	title:'Resumen Proyecto',
	nombreVista: 'ProyectoKaf',
	
	constructor: function(config) {  
	    this.maestro=config.maestro;
    	Phx.vista.ProyectoKaf.superclass.constructor.call(this,config);
	    this.load();
	},
	


    east: { 
        url:'../../../sis_kactivos_fijos/vista/tipo_prorrateo/TipoProrrateo.php',
        title:'Detalle', 
        width:'60%',
        cls:'TipoProrrateo'
	}

};
</script>
