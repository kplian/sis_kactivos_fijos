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
    	Phx.vista.MovimientoAlm.superclass.constructor.call(this,config);
    	this.addButton('ini_estado',{argument: {operacion: 'inicio'},text:'Dev. a Borrador',iconCls: 'batras',disabled:true,handler:this.retroceder,tooltip: '<b>Retorna Movimiento al estado borrador</b>'});
	    this.addButton('ant_estado',{argument: {operacion: 'anterior'},text:'Anterior',iconCls: 'batras',disabled:true,handler:this.retroceder,tooltip: '<b>Pasar al Anterior Estado</b>'});
    	this.addButton('sig_estado',{text:'Finalizar',iconCls: 'badelante',disabled:true,handler:this.fin_requerimiento,tooltip: '<b>Finalizar Registro</b>'});
		this.getBoton('btnRevertir').hide();
	    this.getBoton('btnCancelar').hide();
	    this.store.baseParams={tipo_interfaz:this.nombreVista};
	    this.load({params:{start:0, limit:this.tam_pag}});
	    
	    //Creación de ventana para workflow
		this.crearVentanaWF();
	},

    south:
          { 
          url:'../../../sis_almacenes/vista/movimiento_af_dep/MovimientoAfDepRes.php',
          title:'Detalle', 
          height:'70%',
          cls:'MovimientoAfDepRes'
	}

};
</script>
