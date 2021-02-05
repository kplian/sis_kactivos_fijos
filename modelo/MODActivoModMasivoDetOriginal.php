<?php
/****************************************************************************************
*@package pXP
*@file gen-MODActivoModMasivoDetOriginal.php
*@author  (rchumacero)
*@date 10-12-2020 03:43:46
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas

 HISTORIAL DE MODIFICACIONES:
 #ISSUE                FECHA                AUTOR                DESCRIPCION
 #0                10-12-2020 03:43:46    rchumacero             Creacion
 #ETR-2778  KAF       ETR           02/02/2021  RCM         Adición de campos para modificación de AFVs
*****************************************************************************************/
class MODActivoModMasivoDetOriginal extends MODbase{

    function __construct(CTParametro $pParam){
        parent::__construct($pParam);
    }

    function listarActivoModMasivoDetOriginal(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_original_sel';
        $this->transaccion='SKA_MADOR_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
		$this->captura('id_activo_mod_masivo_det_original','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_activo_mod_masivo_det','int4');
		$this->captura('id_activo_fijo','int4');
		$this->captura('codigo','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('marca','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('id_unidad_medida','integer');
		$this->captura('observaciones','varchar');
		$this->captura('ubicacion','varchar');
		$this->captura('id_ubicacion','int4');
		$this->captura('id_funcionario','int4');
		$this->captura('id_proveedor','int4');
		$this->captura('fecha_compra','date');
		$this->captura('documento','varchar');
		$this->captura('cbte_asociado','varchar');
		$this->captura('fecha_cbte_asociado','date');
		$this->captura('id_grupo','int4');
		$this->captura('id_grupo_clasif','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');

        $this->captura('desc_unidad_medida', 'VARCHAR');
        $this->captura('desc_ubicacion', 'VARCHAR');
        $this->captura('desc_funcionario', 'TEXT');
        $this->captura('desc_proveedor', 'VARCHAR');
        $this->captura('desc_grupo', 'TEXT');
        $this->captura('desc_grupo_clasif', 'TEXT');
        $this->captura('desc_centro_costo', 'VARCHAR');

        //Inicio #ETR-2778
        $this->captura('id_activo_fijo_valor', 'INTEGER');
		$this->captura('valor_compra', 'NUMERIC');
		$this->captura('valor_inicial', 'NUMERIC');
		$this->captura('fecha_ini_dep', 'DATE');
		$this->captura('vutil_orig', 'INTEGER');
		$this->captura('vutil', 'INTEGER');
		$this->captura('fult_dep', 'DATE');
		$this->captura('fecha_fin', 'DATE');
		$this->captura('val_resc', 'NUMERIC');
		$this->captura('vact_ini', 'NUMERIC');
		$this->captura('dacum_ini', 'NUMERIC');
		$this->captura('dper_ini', 'NUMERIC');
		$this->captura('inc', 'NUMERIC');
		$this->captura('inc_sact', 'NUMERIC');
		$this->captura('fechaufv_ini', 'DATE');
		$this->captura('usd_id_activo_fijo_valor', 'INTEGER');
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
		$this->captura('usd_fechaufv_ini', 'DATE');
		$this->captura('ufv_id_activo_fijo_valor', 'INTEGER');
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
		$this->captura('ufv_fechaufv_ini', 'DATE');
        //Fin #ETR-2778

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarActivoModMasivoDetOriginal(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_original_ime';
        $this->transaccion='SKA_MADOR_INS';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_activo_mod_masivo_det','id_activo_mod_masivo_det','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_unidad_medida','id_unidad_medida','integer');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('id_ubicacion','id_ubicacion','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('cbte_asociado','cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('id_grupo','id_grupo','int4');
		$this->setParametro('id_grupo_clasif','id_grupo_clasif','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarActivoModMasivoDetOriginal(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_original_ime';
        $this->transaccion='SKA_MADOR_MOD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo_det_original','id_activo_mod_masivo_det_original','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_activo_mod_masivo_det','id_activo_mod_masivo_det','int4');
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_unidad_medida','id_unidad_medida','integer');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('id_ubicacion','id_ubicacion','int4');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('cbte_asociado','cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('id_grupo','id_grupo','int4');
		$this->setParametro('id_grupo_clasif','id_grupo_clasif','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function eliminarActivoModMasivoDetOriginal(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_det_original_ime';
        $this->transaccion='SKA_MADOR_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo_det_original','id_activo_mod_masivo_det_original','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

}
?>