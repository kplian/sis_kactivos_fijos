<?php
/**
*@package pXP
*@file MovimientoTipoCat.php
*@author  RCM
*@date 15/08/2017
*@description Archivo con la interfaz de usuario que permite la ejecucion de todas las funcionalidades del sistema
*/
header("content-type: text/javascript; charset=UTF-8");
?>
<script>
Phx.vista.MovimientoTipoCat = {    
    bsave: false,
    bnew: false,
    bedit: false,
    bdel: false,
    require: '../../../sis_parametros/vista/catalogo/Catalogo.php',
    requireclase: 'Phx.vista.Catalogo',
    
    constructor: function(config) {
        this.Atributos[2].grid=false;
        this.Atributos[3].grid=false;
        Phx.vista.MovimientoTipoCat.superclass.constructor.call(this,config);
        this.maestro = config;

        this.init();
        this.load({
            params:{
                start: 0,
                limit: this.tam_pag,
                catalogoTipo: 'tmovimiento__id_cat_movimiento'
            }
        });

    },

    east: {
        url: '../../../sis_kactivos_fijos/vista/movimiento_motivo/MovimientoMotivo.php',
        title: 'Motivos',
        width: '30%',
        cls: 'MovimientoMotivo'
    },

    
};
</script>
