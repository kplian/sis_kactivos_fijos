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
 #ETR-2778  KAF       ETR           02/02/2021  RCM         Adición de campos para modificación de AFVs
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

        //Inicio #ETR-2778
        $this->captura('bs_valor_compra', 'NUMERIC');
		$this->captura('bs_valor_inicial', 'NUMERIC');
		$this->captura('bs_fecha_ini_dep', 'DATE');
		$this->captura('bs_vutil_orig', 'INTEGER');
		$this->captura('bs_vutil', 'INTEGER');
		$this->captura('bs_fult_dep', 'DATE');
		$this->captura('bs_fecha_fin', 'DATE');
		$this->captura('bs_val_resc', 'NUMERIC');
		$this->captura('bs_vact_ini', 'NUMERIC');
		$this->captura('bs_dacum_ini', 'NUMERIC');
		$this->captura('bs_dper_ini', 'NUMERIC');
		$this->captura('bs_inc', 'NUMERIC');
		$this->captura('bs_inc_sact', 'NUMERIC');
		$this->captura('bs_fechaufv_ini', 'DATE');
		$this->captura('usd_valor_compra', 'NUMERIC');
		$this->captura('usd_valor_inicial', 'NUMERIC');
		$this->captura('usd_fecha_ini_dep', 'DATE');
		$this->captura('usd_vutil_orig', 'INTEGER');
		$this->captura('usd_vutil', 'INTEGER');
		$this->captura('usd_fult_dep', 'DATE');
		$this->captura('usd_fecha_fin', 'DATE');
		$this->captura('usd_val_resc', 'NUMERIC');
		$this->captura('usd_vact_ini', 'NUMERIC');
		$this->captura('usd_dacum_ini', 'NUMERIC');
		$this->captura('usd_dper_ini', 'NUMERIC');
		$this->captura('usd_inc', 'NUMERIC');
		$this->captura('usd_inc_sact', 'NUMERIC');
		$this->captura('usd_fecha_ufv_ini', 'DATE');
		$this->captura('ufv_valor_compra', 'NUMERIC');
		$this->captura('ufv_valor_inicial', 'NUMERIC');
		$this->captura('ufv_fecha_ini_dep', 'DATE');
		$this->captura('ufv_vutil_orig', 'INTEGER');
		$this->captura('ufv_vutil', 'INTEGER');
		$this->captura('ufv_fult_dep', 'DATE');
		$this->captura('ufv_fecha_fin', 'DATE');
		$this->captura('ufv_val_resc', 'NUMERIC');
		$this->captura('ufv_vact_ini', 'NUMERIC');
		$this->captura('ufv_dacum_ini', 'NUMERIC');
		$this->captura('ufv_dper_ini', 'NUMERIC');
		$this->captura('ufv_inc', 'NUMERIC');
		$this->captura('ufv_inc_sact', 'NUMERIC');
		$this->captura('ufv_fecha_ufv_ini', 'DATE');
        //Fin #ETR-2778

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

		//Inicio #ETR-2778
		$this->setParametro('bs_valor_compra', 'bs_valor_compra', 'NUMERIC');
		$this->setParametro('bs_valor_inicial', 'bs_valor_inicial', 'NUMERIC');
		$this->setParametro('bs_fecha_ini_dep', 'bs_fecha_ini_dep', 'DATE');
		$this->setParametro('bs_vutil_orig', 'bs_vutil_orig', 'INTEGER');
		$this->setParametro('bs_vutil', 'bs_vutil', 'INTEGER');
		$this->setParametro('bs_fult_dep', 'bs_fult_dep', 'DATE');
		$this->setParametro('bs_fecha_fin', 'bs_fecha_fin', 'DATE');
		$this->setParametro('bs_val_resc', 'bs_val_resc', 'NUMERIC');
		$this->setParametro('bs_vact_ini', 'bs_vact_ini', 'NUMERIC');
		$this->setParametro('bs_dacum_ini', 'bs_dacum_ini', 'NUMERIC');
		$this->setParametro('bs_dper_ini', 'bs_dper_ini', 'NUMERIC');
		$this->setParametro('bs_inc', 'bs_inc', 'NUMERIC');
		$this->setParametro('bs_inc_sact', 'bs_inc_sact', 'NUMERIC');
		$this->setParametro('bs_fechaufv_ini', 'bs_fechaufv_ini', 'DATE');
		$this->setParametro('usd_valor_compra', 'usd_valor_compra', 'NUMERIC');
		$this->setParametro('usd_valor_inicial', 'usd_valor_inicial', 'NUMERIC');
		$this->setParametro('usd_fecha_ini_dep', 'usd_fecha_ini_dep', 'DATE');
		$this->setParametro('usd_vutil_orig', 'usd_vutil_orig', 'INTEGER');
		$this->setParametro('usd_vutil', 'usd_vutil', 'INTEGER');
		$this->setParametro('usd_fult_dep', 'usd_fult_dep', 'DATE');
		$this->setParametro('usd_fecha_fin', 'usd_fecha_fin', 'DATE');
		$this->setParametro('usd_val_resc', 'usd_val_resc', 'NUMERIC');
		$this->setParametro('usd_vact_ini', 'usd_vact_ini', 'NUMERIC');
		$this->setParametro('usd_dacum_ini', 'usd_dacum_ini', 'NUMERIC');
		$this->setParametro('usd_dper_ini', 'usd_dper_ini', 'NUMERIC');
		$this->setParametro('usd_inc', 'usd_inc', 'NUMERIC');
		$this->setParametro('usd_inc_sact', 'usd_inc_sact', 'NUMERIC');
		$this->setParametro('usd_fecha_ufv_ini', 'usd_fecha_ufv_ini', 'DATE');
		$this->setParametro('ufv_valor_compra', 'ufv_valor_compra', 'NUMERIC');
		$this->setParametro('ufv_valor_inicial', 'ufv_valor_inicial', 'NUMERIC');
		$this->setParametro('ufv_fecha_ini_dep', 'ufv_fecha_ini_dep', 'DATE');
		$this->setParametro('ufv_vutil_orig', 'ufv_vutil_orig', 'INTEGER');
		$this->setParametro('ufv_vutil', 'ufv_vutil', 'INTEGER');
		$this->setParametro('ufv_fult_dep', 'ufv_fult_dep', 'DATE');
		$this->setParametro('ufv_fecha_fin', 'ufv_fecha_fin', 'DATE');
		$this->setParametro('ufv_val_resc', 'ufv_val_resc', 'NUMERIC');
		$this->setParametro('ufv_vact_ini', 'ufv_vact_ini', 'NUMERIC');
		$this->setParametro('ufv_dacum_ini', 'ufv_dacum_ini', 'NUMERIC');
		$this->setParametro('ufv_dper_ini', 'ufv_dper_ini', 'NUMERIC');
		$this->setParametro('ufv_inc', 'ufv_inc', 'NUMERIC');
		$this->setParametro('ufv_inc_sact', 'ufv_inc_sact', 'NUMERIC');
		$this->setParametro('ufv_fecha_ufv_ini', 'ufv_fecha_ufv_ini', 'DATE');
		//Fin #ETR-2778

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

		//Inicio #ETR-2778
		$this->setParametro('bs_valor_compra', 'bs_valor_compra', 'NUMERIC');
		$this->setParametro('bs_valor_inicial', 'bs_valor_inicial', 'NUMERIC');
		$this->setParametro('bs_fecha_ini_dep', 'bs_fecha_ini_dep', 'DATE');
		$this->setParametro('bs_vutil_orig', 'bs_vutil_orig', 'INTEGER');
		$this->setParametro('bs_vutil', 'bs_vutil', 'INTEGER');
		$this->setParametro('bs_fult_dep', 'bs_fult_dep', 'DATE');
		$this->setParametro('bs_fecha_fin', 'bs_fecha_fin', 'DATE');
		$this->setParametro('bs_val_resc', 'bs_val_resc', 'NUMERIC');
		$this->setParametro('bs_vact_ini', 'bs_vact_ini', 'NUMERIC');
		$this->setParametro('bs_dacum_ini', 'bs_dacum_ini', 'NUMERIC');
		$this->setParametro('bs_dper_ini', 'bs_dper_ini', 'NUMERIC');
		$this->setParametro('bs_inc', 'bs_inc', 'NUMERIC');
		$this->setParametro('bs_inc_sact', 'bs_inc_sact', 'NUMERIC');
		$this->setParametro('bs_fechaufv_ini', 'bs_fechaufv_ini', 'DATE');
		$this->setParametro('usd_valor_compra', 'usd_valor_compra', 'NUMERIC');
		$this->setParametro('usd_valor_inicial', 'usd_valor_inicial', 'NUMERIC');
		$this->setParametro('usd_fecha_ini_dep', 'usd_fecha_ini_dep', 'DATE');
		$this->setParametro('usd_vutil_orig', 'usd_vutil_orig', 'INTEGER');
		$this->setParametro('usd_vutil', 'usd_vutil', 'INTEGER');
		$this->setParametro('usd_fult_dep', 'usd_fult_dep', 'DATE');
		$this->setParametro('usd_fecha_fin', 'usd_fecha_fin', 'DATE');
		$this->setParametro('usd_val_resc', 'usd_val_resc', 'NUMERIC');
		$this->setParametro('usd_vact_ini', 'usd_vact_ini', 'NUMERIC');
		$this->setParametro('usd_dacum_ini', 'usd_dacum_ini', 'NUMERIC');
		$this->setParametro('usd_dper_ini', 'usd_dper_ini', 'NUMERIC');
		$this->setParametro('usd_inc', 'usd_inc', 'NUMERIC');
		$this->setParametro('usd_inc_sact', 'usd_inc_sact', 'NUMERIC');
		$this->setParametro('usd_fecha_ufv_ini', 'usd_fecha_ufv_ini', 'DATE');
		$this->setParametro('ufv_valor_compra', 'ufv_valor_compra', 'NUMERIC');
		$this->setParametro('ufv_valor_inicial', 'ufv_valor_inicial', 'NUMERIC');
		$this->setParametro('ufv_fecha_ini_dep', 'ufv_fecha_ini_dep', 'DATE');
		$this->setParametro('ufv_vutil_orig', 'ufv_vutil_orig', 'INTEGER');
		$this->setParametro('ufv_vutil', 'ufv_vutil', 'INTEGER');
		$this->setParametro('ufv_fult_dep', 'ufv_fult_dep', 'DATE');
		$this->setParametro('ufv_fecha_fin', 'ufv_fecha_fin', 'DATE');
		$this->setParametro('ufv_val_resc', 'ufv_val_resc', 'NUMERIC');
		$this->setParametro('ufv_vact_ini', 'ufv_vact_ini', 'NUMERIC');
		$this->setParametro('ufv_dacum_ini', 'ufv_dacum_ini', 'NUMERIC');
		$this->setParametro('ufv_dper_ini', 'ufv_dper_ini', 'NUMERIC');
		$this->setParametro('ufv_inc', 'ufv_inc', 'NUMERIC');
		$this->setParametro('ufv_inc_sact', 'ufv_inc_sact', 'NUMERIC');
		$this->setParametro('ufv_fecha_ufv_ini', 'ufv_fecha_ufv_ini', 'DATE');
		//Fin #ETR-2778

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