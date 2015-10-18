<?php
/** 
*@package pXP
*@file gen-ActivoFijo.php
*@author  (admin)
*@date 04-09-2015 03:11:50
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
 header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.ActivoFijo=Ext.extend(Phx.baseInterfaz, {

	constructor : function(config) {
		Phx.vista.ActivoFijo.superclass.constructor.call(this, config);
	}
});
