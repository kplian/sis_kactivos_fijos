<?php
/**
*@package pXP
*@file gen-MODActivoFijo.php
*@author  (admin)
*@date 29-10-2015 03:18:45
*@description Clase que envia los parametros requeridos a la Base de datos para la ejecucion de las funciones, y que recibe la respuesta del resultado de la ejecucion de las mismas
*/

class MODActivoFijo extends MODbase{

	function __construct(CTParametro $pParam){
		parent::__construct($pParam);
	}

	function listarActivoFijo(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_AFIJ_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setParametro('por_usuario','por_usuario','varchar');

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_persona','int4');
		$this->captura('cantidad_revaloriz','int4');
		$this->captura('foto','varchar');
		$this->captura('id_proveedor','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('monto_vigente','numeric');
		$this->captura('id_cat_estado_fun','int4');
		$this->captura('ubicacion','varchar');
		$this->captura('vida_util','int4');
		$this->captura('documento','varchar');
		$this->captura('observaciones','varchar');
		$this->captura('fecha_ult_dep','date');
		$this->captura('monto_rescate','numeric');
		$this->captura('denominacion','varchar');
		$this->captura('id_funcionario','int4');
		$this->captura('id_deposito','int4');
		$this->captura('monto_compra','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('codigo','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('id_moneda_orig','int4');
		$this->captura('fecha_ini_dep','date');
		$this->captura('id_cat_estado_compra','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('vida_util_original','int4');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('estado','varchar');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('id_oficina','int4');
		$this->captura('id_depto','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('persona','text');
		$this->captura('desc_proveedor','varchar');
		$this->captura('estado_fun','varchar');
		$this->captura('estado_compra','varchar');
		$this->captura('clasificacion','text');
		$this->captura('centro_costo','varchar');
		$this->captura('oficina','text');
		$this->captura('depto','text');
		$this->captura('funcionario','text');
		$this->captura('deposito','varchar');
		$this->captura('deposito_cod','varchar');
		$this->captura('desc_moneda_orig','varchar');
		$this->captura('en_deposito','varchar');
		$this->captura('extension','varchar');
		$this->captura('codigo_ant','varchar');
		$this->captura('marca','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('caracteristicas','text');
		$this->captura('monto_vigente_real_af','numeric');
		$this->captura('vida_util_real_af','int4');
		$this->captura('fecha_ult_dep_real_af','date');
        $this->captura('depreciacion_acum_real_af','numeric');
        $this->captura('depreciacion_per_real_af','numeric');
		$this->captura('tipo_activo','varchar');
        $this->captura('depreciable','varchar');
		$this->captura('monto_compra_orig','numeric');
		$this->captura('id_proyecto','int4');
		$this->captura('desc_proyecto','varchar');
		$this->captura('cantidad_af','integer');
		$this->captura('id_unidad_medida','integer');
		$this->captura('codigo_unmed','varchar');
		$this->captura('descripcion_unmed','varchar');
		$this->captura('monto_compra_orig_100','numeric');
		$this->captura('nro_cbte_asociado','varchar');
		$this->captura('fecha_cbte_asociado','date');
		$this->captura('vida_util_original_anios','numeric');
		$this->captura('nombre_cargo','varchar');
		$this->captura('fecha_asignacion','date');
		$this->captura('prestamo','varchar');
		$this->captura('fecha_dev_prestamo','date');
		$this->captura('id_grupo','int4');
		$this->captura('desc_grupo','varchar');
		$this->captura('id_ubicacion','int4');
		$this->captura('desc_ubicacion','varchar');
		$this->captura('id_grupo_clasif','int4');
		$this->captura('desc_grupo_clasif','varchar');
		//$this->captura('cuenta_activo','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function insertarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_INS';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('cantidad_revaloriz','cantidad_revaloriz','int4');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('id_cat_estado_compra','id_cat_estado_compra','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('vida_util_original','vida_util_original','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('codigo_ant','codigo_ant','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		//$this->setParametro('caracteristicas','caracteristicas','text');
		$this->setParametro('monto_compra_orig','monto_compra_orig','numeric');

		$this->setParametro('id_proyecto','id_proyecto','int4');
		$this->setParametro('cantidad_af','cantidad_af','int4');
		$this->setParametro('id_unidad_medida','id_unidad_medida','int4');
		$this->setParametro('monto_compra_orig_100','monto_compra_orig_100','numeric');
		$this->setParametro('nro_cbte_asociado','nro_cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('id_grupo','id_grupo','int4');
		$this->setParametro('id_ubicacion','id_ubicacion','int4');
		$this->setParametro('id_grupo_clasif','id_grupo_clasif','int4');


		//Ejecuta la instruccion
		$this->armarConsulta();

		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function modificarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('id_persona','id_persona','int4');
		$this->setParametro('cantidad_revaloriz','cantidad_revaloriz','int4');
		$this->setParametro('foto','foto','varchar');
		$this->setParametro('id_proveedor','id_proveedor','int4');
		$this->setParametro('estado_reg','estado_reg','varchar');
		$this->setParametro('fecha_compra','fecha_compra','date');
		$this->setParametro('monto_vigente','monto_vigente','numeric');
		$this->setParametro('id_cat_estado_fun','id_cat_estado_fun','int4');
		$this->setParametro('ubicacion','ubicacion','varchar');
		$this->setParametro('vida_util','vida_util','int4');
		$this->setParametro('documento','documento','varchar');
		$this->setParametro('observaciones','observaciones','varchar');
		$this->setParametro('fecha_ult_dep','fecha_ult_dep','date');
		$this->setParametro('monto_rescate','monto_rescate','numeric');
		$this->setParametro('denominacion','denominacion','varchar');
		$this->setParametro('id_funcionario','id_funcionario','int4');
		$this->setParametro('id_deposito','id_deposito','int4');
		$this->setParametro('monto_compra','monto_compra','numeric');
		$this->setParametro('id_moneda','id_moneda','int4');
		$this->setParametro('depreciacion_mes','depreciacion_mes','numeric');
		$this->setParametro('codigo','codigo','varchar');
		$this->setParametro('descripcion','descripcion','varchar');
		$this->setParametro('id_moneda_orig','id_moneda_orig','int4');
		$this->setParametro('fecha_ini_dep','fecha_ini_dep','date');
		$this->setParametro('id_cat_estado_compra','id_cat_estado_compra','int4');
		$this->setParametro('depreciacion_per','depreciacion_per','numeric');
		$this->setParametro('vida_util_original','vida_util_original','int4');
		$this->setParametro('depreciacion_acum','depreciacion_acum','numeric');
		$this->setParametro('estado','estado','varchar');
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('id_centro_costo','id_centro_costo','int4');
		$this->setParametro('id_oficina','id_oficina','int4');
		$this->setParametro('id_depto','id_depto','int4');
		$this->setParametro('codigo_ant','codigo_ant','varchar');
		$this->setParametro('marca','marca','varchar');
		$this->setParametro('nro_serie','nro_serie','varchar');
		//$this->setParametro('caracteristicas','caracteristicas','text');
		$this->setParametro('monto_compra_orig','monto_compra_orig','numeric');
		$this->setParametro('id_proyecto','id_proyecto','int4');
		$this->setParametro('cantidad_af','cantidad_af','int4');
		$this->setParametro('id_unidad_medida','id_unidad_medida','int4');
		$this->setParametro('monto_compra_orig_100','monto_compra_orig_100','numeric');
		$this->setParametro('nro_cbte_asociado','nro_cbte_asociado','varchar');
		$this->setParametro('fecha_cbte_asociado','fecha_cbte_asociado','date');
		$this->setParametro('id_grupo','id_grupo','int4');
		$this->setParametro('id_ubicacion','id_ubicacion','int4');
		$this->setParametro('id_funcionario_asig','id_funcionario_asig','int4');
		$this->setParametro('id_grupo_clasif','id_grupo_clasif','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function eliminarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_ELI';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function codificarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFCOD_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function seleccionarActivosFijos(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_IDAF_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Definicion de la lista del resultado del query
		$this->captura('ids','text');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}



	function recuperarCodigoQR(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_GETQR_MOD';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function recuperarListadoCodigosQR(){
		//Definicion de variables para ejecucion del procedimiento
		$this -> procedimiento='kaf.ft_activo_fijo_sel';
		$this -> transaccion='SKA_GEVARTQR_SEL';
		$this -> tipo_procedimiento='SEL';
		$this -> setCount(false);

		//Define los parametros para la funcion
		$this->setParametro('id_clasificacion','id_clasificacion','int4');
		$this->setParametro('desde','desde','date');
		$this->setParametro('hasta','hasta','date');

		$this->captura('id_activo_fijo','int4');
	    $this->captura('codigo','varchar');
	    $this->captura('codigo_ant','varchar');
	    $this->captura('denominacion','varchar');
	    $this->captura('nombre_depto','varchar');
	    $this->captura('nombre_entidad','varchar');




		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}




	function subirFoto(){

        $cone = new conexion();
		$link = $cone->conectarpdo();
		$copiado = false;
		try {

			$link->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
	  	    $link->beginTransaction();

			if ($this->arregloFiles['archivo']['name'] == "") {
				throw new Exception("El archivo no puede estar vacio");
			}

            $this->procedimiento='kaf.ft_activo_fijo_ime';
            $this->transaccion='SKA_PHOTO_UPL';
            $this->tipo_procedimiento='IME';

            $ext = pathinfo($this->arregloFiles['archivo']['name']);
            $this->arreglo['extension'] = $ext['extension'];

			//validar que no sea un arhvio en blanco
			$file_name = $this->getFileName2('archivo', 'id_activo_fijo', '', false);

            //Define los parametros para la funcion
            $this->setParametro('id_activo_fijo','id_activo_fijo','integer');
            $this->setParametro('extension','extension','varchar');

            //manda como parametro la url completa del archivo
            $this->aParam->addParametro('file_name', $file_name[2]);
            $this->arreglo['file_name'] = $file_name[2];
            $this->setParametro('file_name','file_name','varchar');

			//manda como parametro el folder del arhivo
            $this->aParam->addParametro('folder', $file_name[1]);
            $this->arreglo['folder'] = $file_name[1];
            $this->setParametro('folder','folder','varchar');

			//manda como parametro el solo el nombre del arhivo  sin extencion
            $this->aParam->addParametro('only_file', $file_name[0]);
            $this->arreglo['only_file'] = $file_name[0];
            $this->setParametro('only_file','only_file','varchar');


            //Ejecuta la instruccion
            $this->armarConsulta();
			$stmt = $link->prepare($this->consulta);
		  	$stmt->execute();
			$result = $stmt->fetch(PDO::FETCH_ASSOC);
			$resp_procedimiento = $this->divRespuesta($result['f_intermediario_ime']);

			if ($resp_procedimiento['tipo_respuesta']=='ERROR') {
				throw new Exception("Error al ejecutar en la bd", 3);
			}


			 if($resp_procedimiento['tipo_respuesta'] == 'EXITO'){

			   //revisamos si ya existe el archivo la verison anterior sera mayor a cero
			   $respuesta = $resp_procedimiento['datos'];
			   //var_dump($respuesta);
			   if($respuesta['max_version'] != '0' && $respuesta['url_destino'] != ''){

                      $this->copyFile($respuesta['url_origen'], $respuesta['url_destino'],  $folder = 'historico');
			   	      $copiado = true;
			   }

			   //cipiamos el nuevo archivo
               $this->setFile('archivo','id_activo_fijo', false,100000 ,array('jpg','jpeg','bmp','gif','png'));
            }

			$link->commit();
			$this->respuesta=new Mensaje();
			$this->respuesta->setMensaje($resp_procedimiento['tipo_respuesta'],$this->nombre_archivo,$resp_procedimiento['mensaje'],$resp_procedimiento['mensaje_tec'],'base',$this->procedimiento,$this->transaccion,$this->tipo_procedimiento,$this->consulta);
			$this->respuesta->setDatos($respuesta);
        }

        catch (Exception $e) {
	    	$link->rollBack();

			if($copiado){
			   	 $this->copyFile($respuesta['url_origen'], $respuesta['url_destino'],  $folder = 'historico', true);
			}
	    	$this->respuesta=new Mensaje();
			if ($e->getCode() == 3) {//es un error de un procedimiento almacenado de pxp
				$this->respuesta->setMensaje($resp_procedimiento['tipo_respuesta'],$this->nombre_archivo,$resp_procedimiento['mensaje'],$resp_procedimiento['mensaje_tec'],'base',$this->procedimiento,$this->transaccion,$this->tipo_procedimiento,$this->consulta);
			} else if ($e->getCode() == 2) {//es un error en bd de una consulta
				$this->respuesta->setMensaje('ERROR',$this->nombre_archivo,$e->getMessage(),$e->getMessage(),'modelo','','','','');
			} else {//es un error lanzado con throw exception
				throw new Exception($e->getMessage(), 2);
			}
		}

	    return $this->respuesta;

    }

    function clonarActivoFijo(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFIJ_CLO';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');
		$this->setParametro('cantidad_clon','cantidad_clon','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarActivoFijoFecha(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_AFFECH_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion

		$this->setParametro('fecha_mov','fecha_mov','date');

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','int4');
		$this->captura('id_persona','int4');
		$this->captura('cantidad_revaloriz','int4');
		$this->captura('foto','varchar');
		$this->captura('id_proveedor','int4');
		$this->captura('estado_reg','varchar');
		$this->captura('fecha_compra','date');
		$this->captura('monto_vigente','numeric');
		$this->captura('id_cat_estado_fun','int4');
		$this->captura('ubicacion','varchar');
		$this->captura('vida_util','int4');
		$this->captura('documento','varchar');
		$this->captura('observaciones','varchar');
		$this->captura('fecha_ult_dep','date');
		$this->captura('monto_rescate','numeric');
		$this->captura('denominacion','varchar');
		$this->captura('id_funcionario','int4');
		$this->captura('id_deposito','int4');
		$this->captura('monto_compra','numeric');
		$this->captura('id_moneda','int4');
		$this->captura('depreciacion_mes','numeric');
		$this->captura('codigo','varchar');
		$this->captura('descripcion','varchar');
		$this->captura('id_moneda_orig','int4');
		$this->captura('fecha_ini_dep','date');
		$this->captura('id_cat_estado_compra','int4');
		$this->captura('depreciacion_per','numeric');
		$this->captura('vida_util_original','int4');
		$this->captura('depreciacion_acum','numeric');
		$this->captura('estado','varchar');
		$this->captura('id_clasificacion','int4');
		$this->captura('id_centro_costo','int4');
		$this->captura('id_oficina','int4');
		$this->captura('id_depto','int4');
		$this->captura('id_usuario_reg','int4');
		$this->captura('fecha_reg','timestamp');
		$this->captura('usuario_ai','varchar');
		$this->captura('id_usuario_ai','int4');
		$this->captura('id_usuario_mod','int4');
		$this->captura('fecha_mod','timestamp');
		$this->captura('usr_reg','varchar');
		$this->captura('usr_mod','varchar');
		$this->captura('persona','text');
		$this->captura('desc_proveedor','varchar');
		$this->captura('estado_fun','varchar');
		$this->captura('estado_compra','varchar');
		$this->captura('clasificacion','text');
		$this->captura('centro_costo','text');
		$this->captura('oficina','text');
		$this->captura('depto','text');
		$this->captura('funcionario','text');
		$this->captura('deposito','varchar');
		$this->captura('deposito_cod','varchar');
		$this->captura('desc_moneda_orig','varchar');
		$this->captura('en_deposito','varchar');
		$this->captura('extension','varchar');
		$this->captura('codigo_ant','varchar');
		$this->captura('marca','varchar');
		$this->captura('nro_serie','varchar');
		$this->captura('caracteristicas','text');
		$this->captura('monto_vigente_real_af','numeric');
		$this->captura('vida_util_real_af','int4');
		$this->captura('fecha_ult_dep_real_af','date');
        $this->captura('depreciacion_acum_real_af','numeric');
        $this->captura('depreciacion_per_real_af','numeric');
		$this->captura('tipo_activo','varchar');
        $this->captura('depreciable','varchar');
		$this->captura('monto_compra_orig','numeric');
		$this->captura('id_proyecto','int4');
		$this->captura('desc_proyecto','varchar');
		$this->captura('cantidad_af','integer');
		$this->captura('id_unidad_medida','integer');
		$this->captura('codigo_unmed','varchar');
		$this->captura('descripcion_unmed','varchar');
		$this->captura('monto_compra_orig_100','numeric');
		$this->captura('nro_cbte_asociado','varchar');
		$this->captura('fecha_cbte_asociado','date');
		$this->captura('nombre_cargo','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function consultaQR(){
		//Definicion de variables para ejecucion del procedimiento
		$this->procedimiento='kaf.ft_activo_fijo_ime';
		$this->transaccion='SKA_AFQR_DAT';
		$this->tipo_procedimiento='IME';

		//Define los parametros para la funcion
		$this->setParametro('id_activo_fijo','id_activo_fijo','int4');

		//Ejecuta la instruccion
		$this->armarConsulta();
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

	function listarCodigoQRVarios(){
		//Definicion de variables para ejecucion del procedimientp
		$this->procedimiento='kaf.ft_activo_fijo_sel';
		$this->transaccion='SKA_QRVARIOS_SEL';
		$this->tipo_procedimiento='SEL';//tipo de transaccion
		$this->setCount(false);

		//Definicion de la lista del resultado del query
		$this->captura('id_activo_fijo','int4');
        $this->captura('codigo','varchar');
        $this->captura('codigo_ant','varchar');
        $this->captura('denominacion','varchar');
        $this->captura('nombre_depto','varchar');
        $this->captura('nombre_entidad','varchar');
        $this->captura('descripcion','varchar');
        $this->captura('clase_rep','varchar');

		//Ejecuta la instruccion
		$this->armarConsulta();
		//echo $this->consulta;exit;
		$this->ejecutarConsulta();

		//Devuelve la respuesta
		return $this->respuesta;
	}

}
?>