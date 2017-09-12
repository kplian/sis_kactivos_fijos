<?php
/**
*@package pXP
*@file gen-SistemaDist.php
*@author  RCM
*@date 08/08/2017
*@description Interfaz para listar todas las asignaciones, transferencias y devoluciones del usuario logueado
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoUsuario = {    
    bsave:false,    
    require:'../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php',
    requireclase:'Phx.vista.Movimiento',
    nombreVista: 'MovimientoUsuario',
    bdel:false,
	bsave:false,
	bnew:false,
	bedit:false,
    
    constructor: function(config) {
        Phx.vista.MovimientoUsuario.superclass.constructor.call(this,config);
        this.init();
        
        var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData()
        if(dataPadre){
            this.onEnablePanel(this, dataPadre);
        } else {
           this.bloquearMenus();
        }

        //Grid
       	this.grid.on('cellclick', this.abrirEnlace, this);
    }, 
    onReloadPage:function(m){
		this.maestro=m;
		this.store.baseParams={por_usuario: 'si'};		
		this.load({params:{start:0, limit:50}})
		
	},
	loadValoresIniciales:function(){
		Phx.vista.MovimientoUsuario.superclass.loadValoresIniciales.call(this);
			
	}, 
	
	arrayDefaultColumHidden:['fecha_reg','usr_reg','fecha_mod','usr_mod','fecha_hasta','id_proceso_wf','id_estado_wf','id_funcionario','estado_reg','id_usuario_ai','usuario_ai','direccion','id_oficina','glosa'],
	rowExpander: new Ext.ux.grid.RowExpander({
	        tpl : new Ext.Template(
	        	 '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Glosa:&nbsp;&nbsp;</b> {glosa}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Registro:&nbsp;&nbsp;</b> {usr_reg}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Registro:&nbsp;&nbsp;</b> {fecha_reg}</p>',	       
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Usuario Modificación:&nbsp;&nbsp;</b> {usr_mod}</p>',
	            '<p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Fecha Modificación:&nbsp;&nbsp;</b> {fecha_mod}</p>'
	        )
    })

};
</script>