<?php
/****************************************************************************************
*@package pXP
*@file MODActivoModMasivo.php
*@author  (rchumacero)
*@date 09-12-2020 20:34:43
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*****************************************************************************************
 ISSUE      SIS       EMPRESA       FECHA       AUTOR       DESCRIPCION
 #ETR-2029  KAF       ETR           09/12/2020  RCM         Creación del archivo
*****************************************************************************************/
class MODActivoModMasivo extends MODbase{

    function __construct(CTParametro $pParam){
        parent::__construct($pParam);
    }

    function listarActivoModMasivo(){
        //Definicion de variables para ejecucion del procedimientp
        $this->procedimiento='kaf.ft_activo_mod_masivo_sel';
        $this->transaccion='SKA_AFM_SEL';
        $this->tipo_procedimiento='SEL';//tipo de transaccion

        //Definicion de la lista del resultado del query
		$this->captura('id_activo_mod_masivo','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('id_proceso_wf','int4');
		$this->captura('id_estado_wf','int4');
		$this->captura('fecha','date');
		$this->captura('motivo','varchar');
		$this->captura('estado','varchar');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('id_usuario_ai','int4');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
        $this->captura('usr_mod','varchar');
        $this->captura('num_tramite','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function insertarActivoModMasivo(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_ime';
        $this->transaccion='SKA_AFM_INS';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_proceso_wf','id_proceso_wf','int4');
		$this->setParametro('id_estado_wf','id_estado_wf','int4');
		$this->setParametro('fecha','fecha','date');
		$this->setParametro('motivo','motivo','varchar');
		$this->setParametro('estado','estado','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function modificarActivoModMasivo(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_ime';
        $this->transaccion='SKA_AFM_MOD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('id_proceso_wf','id_proceso_wf','int4');
		$this->setParametro('id_estado_wf','id_estado_wf','int4');
		$this->setParametro('fecha','fecha','date');
		$this->setParametro('motivo','motivo','varchar');
		$this->setParametro('estado','estado','varchar');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function eliminarActivoModMasivo(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_ime';
        $this->transaccion='SKA_AFM_ELI';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
		$this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function EjecutarActualizacionDatos(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_activo_mod_masivo_ime';
        $this->transaccion='SKA_AFMDATOS_UPD';
        $this->tipo_procedimiento='IME';

        //Define los parametros para la funcion
        $this->setParametro('id_activo_mod_masivo','id_activo_mod_masivo','int4');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function anteriorEstado(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento = 'kaf.ft_activo_mod_masivo_ime';
        $this->transaccion = 'SKA_ANTMODAF_INS';
        $this->tipo_procedimiento = 'IME';

        //Define los parametros para la funcion
        $this->setParametro('id_proceso_wf','id_proceso_wf','int4');
        $this->setParametro('id_funcionario_usu','id_funcionario_usu','int4');
        $this->setParametro('operacion','operacion','varchar');
        $this->setParametro('id_funcionario','id_funcionario','int4');
        $this->setParametro('id_tipo_estado','id_tipo_estado','int4');
        $this->setParametro('id_estado_wf','id_estado_wf','int4');
        $this->setParametro('obs','obs','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

    function siguienteEstado(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento = 'kaf.ft_activo_mod_masivo_ime';
        $this->transaccion = 'SKA_SIGMODAF_INS';
        $this->tipo_procedimiento = 'IME';

        //Define los parametros para la funcion
        $this->setParametro('id_proceso_wf_act','id_proceso_wf_act','int4');
        $this->setParametro('id_estado_wf_act','id_estado_wf_act','int4');
        $this->setParametro('id_funcionario_usu','id_funcionario_usu','int4');
        $this->setParametro('id_tipo_estado','id_tipo_estado','int4');
        $this->setParametro('id_funcionario_wf','id_funcionario_wf','int4');
        $this->setParametro('id_depto_wf','id_depto_wf','int4');
        $this->setParametro('obs','obs','text');
        $this->setParametro('json_procesos','json_procesos','text');

        //Ejecuta la instruccion
        $this->armarConsulta();
        $this->ejecutarConsulta();

        //Devuelve la respuesta
        return $this->respuesta;
    }

}
?>