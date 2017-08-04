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
    	
    	
    	this.campo_fecha = new Ext.form.DateField({
	            name: 'fecha_reg',
	           fieldLabel: 'Fecha',
				allowBlank: false,
				anchor: '80%',
				gwidth: 100,
				format: 'd/m/Y'
	    });
	    
		this.tbar.addField(this.campo_fecha);
		this.campo_fecha.setValue(new Date());
    	 
    	 
    	 
    	 var dataPadre = Phx.CP.getPagina(this.idContenedorPadre).getSelectedData()
    	 
    	
    	 
        if(dataPadre){
            this.onEnablePanel(this, dataPadre);
        }
        else
        {
           this.bloquearMenus();
        }
        
        
        this.campo_fecha.on('select',function(value){
    		if( this.validarFiltros() ){
	                  this.capturaFiltros();
	       }
    	},this);	
			
       
	   
	},
	
	capturaFiltros : function(combo, record, index) {
		
			this.desbloquearOrdenamientoGrid();
			this.store.baseParams.id_moneda_dep = this.cmbMonedaDep.getValue();	
			this.store.baseParams.fecha_hasta = this.campo_fecha.getValue().dateFormat('d/m/Y');		
			this.load();
			
	},

	validarFiltros : function() {
		
		if ( this.cmbMonedaDep.validate()  && this.campo_fecha.validate()) {
			
			return true;
		} else {
			return false;
		}
		
	},
	onButtonAct : function() {
		
			if (!this.validarFiltros()) {
				alert('Especifique los filtros antes')
			}
			else{
				 this.capturaFiltros();
			}
			
	},
	
	 onReloadPage:function(m){
	 	
		this.maestro=m;
		this.store.baseParams={'id_activo_fijo':this.maestro.id_activo_fijo, 
		                       'id_moneda_dep': this.cmbMonedaDep.getValue(), 
		                       'fecha_hasta' : this.campo_fecha.getValue().dateFormat('d/m/Y')};
		                       		
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
