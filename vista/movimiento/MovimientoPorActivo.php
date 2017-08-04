<?php
/**
*@package pXP
*@file gen-SistemaDist.php
*@author  (rarteaga)
*@date 20-09-2011 10:22:05
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoPorActivo = {    
    bsave:false,    
    require:'../../../sis_kactivos_fijos/vista/movimiento/Movimiento.php',
    requireclase:'Phx.vista.Movimiento',
    title:'Venta',
    nombreVista: 'MovimientoPorActivo',
    bdel:false,
	bsave:false,
	bnew:false,
	bedit:false,
    
    constructor: function(config) {
        this.modificarAtributo();
        Phx.vista.MovimientoPorActivo.superclass.constructor.call(this,config);
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
		this.store.baseParams={id_activo_fijo:this.maestro.id_activo_fijo};		
		this.load({params:{start:0, limit:50}})
		
	},
	loadValoresIniciales:function(){
		Phx.vista.MovimientoPorActivo.superclass.loadValoresIniciales.call(this);
			
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
    }),
    modificarAtributo: function(){
    	this.Atributos[2] = {
			config: {
				name: 'id_cat_movimiento',
				fieldLabel: 'Proceso',
				anchor: '95%',
				tinit: false,
				allowBlank: false,
				origen: 'CATALOGO',
				gdisplayField: 'movimiento',
				hiddenName: 'id_cat_movimiento',
				gwidth: 55,
				baseParams:{
						cod_subsistema:'KAF',
						catalogo_tipo:'tmovimiento__id_cat_movimiento'
				},
				renderer: function (value,p,record) {
					var result;
					result = "<div style='text-align:center'><i class='fa fa-reply-all' aria-hidden='true'></i>&nbsp<img src = '../../../lib/imagenes/" + record.data.icono +"'align='center' width='24' height='24' title='"+record.data.movimiento+"'/></div>";
					return result;
				},
				valueField: 'id_catalogo'
			},
			type: 'ComboRec',
			id_grupo: 0,
			filters:{pfiltro:'cat.descripcion',type:'string'},
			grid: true,
			form: true
		};
    },
    abrirEnlace: function(cell,rowIndex,columnIndex,e){
    	if(columnIndex==1){
			var data = this.sm.getSelected().data;
			Phx.CP.loadWindows('../../../sis_kactivos_fijos/vista/movimiento/MovimientoPrincipal.php',
			'Detalle', {
				width:'90%',
				height:'90%'
		    }, {
		    	lnk_id_movimiento: data.id_movimiento,
		    	link: true
		    },
		    this.idContenedor,
		    'MovimientoPrincipal'
			);
		}
    }
    
};
</script>