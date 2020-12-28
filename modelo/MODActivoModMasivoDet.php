<?php
/****************************************************************************************
*@package pXP
*@file MODActivoModMasivoDet.php
*@author  (rchumacero)
*@date 09-12-2020 20:36:35
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*****************************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
*****************************************************************************************/
class MODActivoModMasivoDet extends MODbase{

    function __construct(CTParametro $pParam){
        parent::__construct($pParam);
    }

    function listarActivoModMasivoDet(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_sel';
        $this->transaccion='SKA_AMD_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
		$this->captura('id_activo_mod_masivo_det','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_activo_mod_masivo','int4');
		$this->captura('codigo','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('marca','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('unidad_medida','varchar');
		$this->captura('observaciones','varchar');
		$this->captura('ubicacion','varchar');
		$this->captura('local','varchar');
		$this->captura('responsable','varchar');
		$this->captura('proveedor','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('documento','varchar');
		$this->captura('cbte_asociado','varchar');
		$this->captura('fecha_cbte_asociado','date');
		$this->captura('grupo_ae','varchar');
		$this->captura('clasificador_ae','varchar');
		$this->captura('centro_costo','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarActivoModMasivoDet(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_ime';
        $this->transaccion='SKA_AMD_INS';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('unidad_medida','unidad_medida','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('local','local','varchar');
		$this->setParametro('responsable','responsable','varchar');
		$this->setParametro('proveedor','proveedor','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('cbte_asociado','cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('grupo_ae','grupo_ae','varchar');
		$this->setParametro('clasificador_ae','clasificador_ae','varchar');
		$this->setParametro('centro_costo','centro_costo','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarActivoModMasivoDet(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_ime';
        $this->transaccion='SKA_AMD_MOD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo_det','id_activo_mod_masivo_det','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('unidad_medida','unidad_medida','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('local','local','varchar');
		$this->setParametro('responsable','responsable','varchar');
		$this->setParametro('proveedor','proveedor','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('cbte_asociado','cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('grupo_ae','grupo_ae','varchar');
		$this->setParametro('clasificador_ae','clasificador_ae','varchar');
		$this->setParametro('centro_costo','centro_costo','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function eliminarActivoModMasivoDet(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_ime';
        $this->transaccion='SKA_AMD_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo_det','id_activo_mod_masivo_det','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

     function eliminarRegistrosExistentes() {
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_ime';
        $this->transaccion='SKA_AMDALL_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

}
?>