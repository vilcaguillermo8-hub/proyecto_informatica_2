/**
 * Persistencia.pde
 * Aca se leen y escriben archivos de texto
 * Los archivos van dentro de la carpeta data de Processing
 * Si no encuentro la configuracion, creo una con los valores que ya tenia cargados
 */

/**
 * Lee configuracion.txt y aplica los umbrales al estado
 * Cada linea tiene la forma prefijo.umbral=valor
 * Las lineas vacias y las que empiezan con # se ignoran
 * Devuelve true si pudo aplicar al menos un parametro
 */
boolean persistenciaCargarConfiguracion(EstadoSistema estado) {
  if (estado == null) {
    println("ERROR: estado nulo al cargar configuracion");
    return false;
  }

  // loadStrings devuelve null cuando el archivo no existe
  String[] lineas = loadStrings(dataPath(RUTA_CONFIGURACION));

  if (lineas == null) {
    persistenciaCrearConfiguracionPorDefecto(estado);
    registrarEvento(NIVEL_BAJO,
      "No se encontro configuracion; se genero un archivo con valores por defecto");
    return false;
  }

  int parametrosAplicados = 0;

  for (int i = 0; i < lineas.length; i++) {
    String linea = trim(lineas[i]);

    if (linea.length() == 0 || linea.startsWith("#")) {
      continue;
    }

    // El signo = separa la clave del valor
    String[] partes = split(linea, '=');
    if (partes.length != 2) {
      println("ERROR: linea " + (i + 1) + " invalida: " + linea);
      continue;
    }

    String clave = trim(partes[0]);
    String textoValor = trim(partes[1]);
    float numero = parseFloat(textoValor);

    // NaN es el unico valor que no es igual a si mismo
    if (numero != numero) {
      println("ERROR: valor no numerico en " + clave + ": " + textoValor);
      continue;
    }

    if (aplicarClaveConfiguracion(estado, clave, numero)) {
      parametrosAplicados++;
    } else {
      println("ERROR: clave desconocida o umbral invalido: " + clave);
    }
  }

  registrarEvento(NIVEL_NORMAL,
    "Configuracion cargada: " + parametrosAplicados + " parametros");
  return parametrosAplicados > 0;
}

/**
 * Separa la clave en dos partes con el punto
 * La primera es el prefijo de la variable y la segunda el nombre del umbral
 */
boolean aplicarClaveConfiguracion(EstadoSistema estado, String clave, float valor) {
  String[] segmentos = split(clave, '.');

  if (segmentos.length != 2) {
    return false;
  }

  VariableMonitorizada variable = estado.obtenerVariablePorPrefijo(segmentos[0]);
  if (variable == null) {
    return false;
  }

  return variable.establecerUmbral(segmentos[1], valor);
}

/**
 * Escribe un archivo nuevo con los limites que ya tenia el estado
 * Lo hago cuando no existe el archivo, asi la proxima vez se lee de ahi
 */
void persistenciaCrearConfiguracionPorDefecto(EstadoSistema estado) {
  String[] lineas = {
    "# Generador eolico - umbrales de alerta",
    "# Formato: prefijo.umbral=valor",
    "# prefijos: HUM, VTO, POT, TMP",
    "# umbrales: bajo, normalAlto, criticoBajo, criticoAlto",
    "HUM.bajo=" + str(estado.humedad.limiteBajo),
    "HUM.normalAlto=" + str(estado.humedad.limiteNormalAlto),
    "HUM.criticoBajo=" + str(estado.humedad.limiteCriticoBajo),
    "HUM.criticoAlto=" + str(estado.humedad.limiteCriticoAlto),
    "VTO.bajo=" + str(estado.viento.limiteBajo),
    "VTO.normalAlto=" + str(estado.viento.limiteNormalAlto),
    "VTO.criticoBajo=" + str(estado.viento.limiteCriticoBajo),
    "VTO.criticoAlto=" + str(estado.viento.limiteCriticoAlto),
    "POT.bajo=" + str(estado.potencia.limiteBajo),
    "POT.normalAlto=" + str(estado.potencia.limiteNormalAlto),
    "POT.criticoBajo=" + str(estado.potencia.limiteCriticoBajo),
    "POT.criticoAlto=" + str(estado.potencia.limiteCriticoAlto),
    "TMP.bajo=" + str(estado.temperatura.limiteBajo),
    "TMP.normalAlto=" + str(estado.temperatura.limiteNormalAlto),
    "TMP.criticoBajo=" + str(estado.temperatura.limiteCriticoBajo),
    "TMP.criticoAlto=" + str(estado.temperatura.limiteCriticoAlto)
  };

  try {
    saveStrings(dataPath(RUTA_CONFIGURACION), lineas);
    println("Configuracion por defecto escrita en " + RUTA_CONFIGURACION);
  } catch (Exception error) {
    println("ERROR al crear configuracion: " + error.getMessage());
  }
}

/**
 * Guarda la bitacora en bitacora.txt
 * Primero paso la lista enlazada a un arreglo de lineas y luego escribo
 */
boolean persistenciaGuardarBitacora(ListaEnlazadaEventos bitacora) {
  if (bitacora == null) {
    println("ERROR: bitacora nula; no se guarda nada");
    return false;
  }

  String[] lineas = bitacora.aArregloDeLineas();

  try {
    PrintWriter salida = createWriter(dataPath(RUTA_BITACORA));

    if (salida == null) {
      println("ERROR: no se pudo abrir " + RUTA_BITACORA + " para escritura");
      return false;
    }

    for (int i = 0; i < lineas.length; i++) {
      salida.println(lineas[i]);
    }

    // flush() obliga a escribir y close() libera el archivo
    salida.flush();
    salida.close();
    registrarEvento(NIVEL_NORMAL,
      "Bitacora guardada: " + lineas.length + " eventos en " + RUTA_BITACORA);
    return true;
  } catch (Exception error) {
    println("ERROR al guardar bitacora: " + error.getMessage());
    return false;
  }
}

