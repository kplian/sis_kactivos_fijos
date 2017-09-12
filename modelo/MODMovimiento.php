<?php
/**
*@package pXP
*@file gen-MODMovimiento.php
*@author  (admin)
*@date 22-10-2015 20:42:41
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODMovimiento extends MODbase{
	
	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}
			
	function listarMovimiento(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_sel';
		$this->transaccion='SKA_MOV_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setParametro('por_usuario','por_usuario','varchar');
				
		//Definicion de la lista del resultado del query
		$this->captura('id_movimiento','int4');
		$this->captura('direccion','varchar');
		$this->captura('fecha_hasta','date');
		$this->captura('id_cat_movimiento','int4');
		$this->captura('fecha_mov','date');
		$this->captura('id_depto','int4');
		$this->captura('id_proceso_wf','int4');
		$this->captura('id_estado_wf','int4');
		$this->captura('glosa','varchar');
		$this->captura('id_funcionario','int4');
		$this->captura('estado','varchar');
		$this->captura('id_oficina','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('num_tramite','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('fecha_mod','timestamp');
		$this->captura('id_usuario_mod','int4');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('movimiento','varchar');
		$this->captura('cod_movimiento','varchar');
		$this->captura('icono','varchar');
		$this->captura('depto','varchar');
		$this->captura('cod_depto','varchar');
		$this->captura('desc_funcionario2','text');
		$this->captura('oficina','varchar');
		$this->captura('id_responsable_depto','int4');
		$this->captura('id_persona','int4');
		$this->captura('responsable_depto','text');
		$this->captura('custodio','text');
		$this->captura('icono_estado','varchar');

		$this->captura('codigo','varchar');
		$this->captura('id_deposito','int4');
		$this->captura('id_depto_dest','int4');
		$this->captura('id_deposito_dest','int4');
		$this->captura('id_funcionario_dest','int4');
		$this->captura('id_movimiento_motivo','int4');
		$this->captura('deposito','varchar');
		$this->captura('depto_dest','varchar');
		$this->captura('deposito_dest','varchar');
		$this->captura('funcionario_dest','text');
		$this->captura('motivo','varchar');
		$this->captura('id_int_comprobante','int4');
		$this->captura('id_int_comprobante_aitb','int4');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function insertarMovimiento(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_ime';
		$this->transaccion='SKA_MOV_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('direccion','direccion','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_cat_movimiento','id_cat_movimiento','int4');
		$this->setParametro('fecha_mov','fecha_mov','date');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('id_proceso_wf','id_proceso_wf','int4');
		$this->setParametro('id_estado_wf','id_estado_wf','int4');
		$this->setParametro('glosa','glosa','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('num_tramite','num_tramite','varchar');
		$this->setParametro('id_persona','id_persona','int4');

		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('id_depto_dest','id_depto_dest','int4');
		$this->setParametro('id_deposito_dest','id_deposito_dest','int4');
		$this->setParametro('id_funcionario_dest','id_funcionario_dest','int4');
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function modificarMovimiento(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_ime';
		$this->transaccion='SKA_MOV_MOD';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('direccion','direccion','varchar');
		$this->setParametro('fecha_hasta','fecha_hasta','date');
		$this->setParametro('id_cat_movimiento','id_cat_movimiento','int4');
		$this->setParametro('fecha_mov','fecha_mov','date');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('id_proceso_wf','id_proceso_wf','int4');
		$this->setParametro('id_estado_wf','id_estado_wf','int4');
		$this->setParametro('glosa','glosa','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('num_tramite','num_tramite','varchar');
		$this->setParametro('id_persona','id_persona','int4');

		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('id_depto_dest','id_depto_dest','int4');
		$this->setParametro('id_deposito_dest','id_deposito_dest','int4');
		$this->setParametro('id_funcionario_dest','id_funcionario_dest','int4');
		$this->setParametro('id_movimiento_motivo','id_movimiento_motivo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
	function eliminarMovimiento(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_ime';
		$this->transaccion='SKA_MOV_ELI';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento','id_movimiento','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function generarDetMovimiento(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_ime';
		$this->transaccion='SKA_MOVREL_DAT';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->setParametro('ids','ids','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

   function listarReporteMovimientoMaestro(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_sel';
		$this->transaccion='SKA_MOV_REP';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		$this->setParametro('id_movimiento','id_movimiento','int4');
				
		//Definicion de la lista del resultado del query
		$this->captura('movimiento','varchar');
		$this->captura('cod_movimiento','varchar');
		$this->captura('formulario','varchar');
		$this->captura('num_tramite','varchar');
		$this->captura('fecha_mov','date');
		$this->captura('fecha_hasta','date');
		$this->captura('glosa','varchar');
		$this->captura('estado','varchar');
		$this->captura('depto','varchar');
		$this->captura('responsable','text');
		$this->captura('nombre_cargo','varchar');
		$this->captura('ci','varchar');
		$this->captura('oficina','varchar');
		$this->captura('direccion','varchar');
		$this->captura('responsable_depto','text');
		$this->captura('custodio','text');
		$this->captura('ci_custodio','varchar');
		$this->captura('responsable_dest','text');
		$this->captura('nombre_cargo_dest','varchar');
		$this->captura('ci_dest','varchar');
			
		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarReporteMovimientoDetalle(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_sel';
		$this->transaccion='SKA_MOVDET_REP';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		$this->setParametro('id_movimiento','id_movimiento','int4');
				
		//Definicion de la lista del resultado del query		
		$this->captura('codigo','varchar');
		$this->captura('denominacion','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('estado_fun','varchar');
		$this->captura('vida_util','int4');
		$this->captura('importe','numeric');
		$this->captura('motivo','varchar');
		$this->captura('marca','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('monto_compra','numeric');
		$this->captura('tipo_activo','varchar');
		
		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function siguienteEstadoMovimiento(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_movimiento_ime';
        $this->transaccion='KAF_SIGEMOV_IME';
        $this->tipo_procedimiento='IME';
        
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

    function anteriorEstadoMovimiento(){
        //Definicion de variables para ejecucion del procedimiento
        $this->procedimiento='kaf.ft_movimiento_ime';
        $this->transaccion='KAF_ANTEMOV_IME';
        $this->tipo_procedimiento='IME';
                
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
	
	function listarDatalleDepreciaconReporte(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_movimiento_sel';
		$this->transaccion='SKA_REPDETDE_REP';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);
		
		$this->setParametro('id_movimiento','id_movimiento','int4');
		$this->captura('id_moneda_dep','INTEGER');
		$this->captura('desc_moneda','VARCHAR');		
		$this->captura('gestion_final','INTEGER');
        $this->captura('tipo','varchar');
        $this->captura('nombre_raiz','varchar');
        $this->captura('fecha_ini_dep','DATE');
        $this->captura('id_movimiento','INTEGER');
        $this->captura('id_movimiento_af','INTEGER');
        $this->captura('id_activo_fijo_valor','INTEGER');
        $this->captura('id_activo_fijo','INTEGER');
        $this->captura('codigo','varchar');
        $this->captura('id_clasificacion','INTEGER');
        $this->captura('descripcion','varchar');
        $this->captura('monto_vigente_orig','NUMERIC');
        $this->captura('monto_vigente_inicial','NUMERIC');
        $this->captura('monto_vigente_final','NUMERIC');
        $this->captura('monto_actualiz_inicial','NUMERIC');
        $this->captura('monto_actualiz_final','NUMERIC');
        $this->captura('depreciacion_acum_inicial','NUMERIC');
        $this->captura('depreciacion_acum_final','NUMERIC'); 
        $this->captura('aitb_activo','NUMERIC');
        $this->captura('aitb_depreciacion_acumulada','NUMERIC');
        $this->captura('vida_util_orig','INTEGER');
        $this->captura('vida_util_inicial','INTEGER');
        $this->captura('vida_util_final','INTEGER');
        $this->captura('vida_util_trans','INTEGER');  
        $this->captura('codigo_raiz','varchar');
        $this->captura('id_clasificacion_raiz','INTEGER');
		$this->captura('depreciacion_per_final','NUMERIC'); 
        $this->captura('depreciacion_per_actualiz_final','NUMERIC'); 
				
		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();
		
		//Devuelve la respuesta
		return $this->respuesta;
	}

	function generarMovimientoRapido(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_movimiento_ime';
		$this->transaccion='SKA_MOVRAP_INS';
		$this->tipo_procedimiento='IME';
				
		//Define los parametros para la funcion
		$this->setParametro('tipo_movimiento','tipo_movimiento','varchar');
		$this->setParametro('fecha_mov','fecha_mov','date');
		$this->setParametro('glosa','glosa','varchar');
		$this->setParametro('id_funcionario','id_funcionario','integer');
		$this->setParametro('id_funcionario_dest','id_funcionario_dest','integer');
		$this->setParametro('direccion','direccion','varchar');
		$this->setParametro('id_oficina','id_oficina','integer');
		$this->setParametro('ids_af','ids_af','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}
			
}
?>