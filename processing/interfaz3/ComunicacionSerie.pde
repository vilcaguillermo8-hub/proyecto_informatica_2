/**
 * ComunicacionSerie.pde
 * Aca se maneja el puerto serie con el Arduino
 * Abre el puerto, lee las lineas que llegan y manda las ordenes (reset y umbral)
 * El parseo de cada linea esta en Persistencia.pde (procesarTramaArduino)
 */

// El puerto serie; queda en null si no se pudo abrir
Serial puerto = null;

// true = los datos vienen del Arduino; false = datos simulados
boolean modoArduino = false;

String estadoConexion = "sin conexion";

// Instante (en milisegundos) de la ultima trama valida y si ya se aviso que se perdio la senal
int ultimaTramaMs = 0;
boolean sinSenalAnterior = false;

// Datos de la planta que no son una VariableMonitorizada
float tensionV = 0.0;
float corrienteMa = 0.0;
float energiaMwh = 0.0;
int estadoPlanta = 0;          // 0 ESPERA, 1 GENERANDO, 2 DERIVACION, 3 PROTECCION
boolean hayDatosPlanta = false;

// Ultimo umbral de derivacion que se mando al Arduino (para sumarle o restarle con + y -)
float umbralDerivacionV = 4.0;

/**
 * Busca el Arduino y abre el puerto
 * Si no hay puertos o no se puede abrir, deja el modo SIMULACION y lo avisa en la bitacora
 * Los valores que dependen de Configuracion.pde se asignan aca y no al declarar las variables
 */
void iniciarComunicacionSerie() {
  ultimaTramaMs = millis();
  umbralDerivacionV = UMBRAL_DERIVACION_INICIAL_V;

  String[] lista = Serial.list();
  println("Puertos serie disponibles:");
  printArray(lista);

  if (lista.length == 0) {
    estadoConexion = "no se encontro ningun puerto serie";
    registrarEvento(NIVEL_BAJO, "No hay puertos serie; origen de datos: SIMULACION");
    return;
  }

  // Si el indice configurado no sirve, se usa el ultimo puerto de la lista
  int indice = INDICE_PUERTO_SERIE;
  if (indice < 0 || indice >= lista.length) {
    indice = lista.length - 1;
  }

  try {
    puerto = new Serial(this, lista[indice], BAUDIOS_SERIE);
    puerto.clear();
    modoArduino = true;
    estadoConexion = lista[indice];
    registrarEvento(NIVEL_NORMAL, "Origen de datos: ARDUINO en " + lista[indice]);
  } catch (Exception error) {
    puerto = null;
    modoArduino = false;
    estadoConexion = "no se pudo abrir " + lista[indice];
    registrarEvento(NIVEL_BAJO, "No se pudo abrir " + lista[indice]
      + " (esta abierto el Monitor Serie?); origen de datos: SIMULACION");
  }
}

/**
 * Lee todas las lineas que llegaron desde la ultima vez y las manda a procesarTramaArduino
 * readStringUntil devuelve null cuando todavia no llego una linea completa
 */
void leerPuertoSerie() {
  if (puerto == null) {
    return;
  }

  String linea = puerto.readStringUntil('\n');
  while (linea != null) {
    procesarTramaArduino(trim(linea));
    linea = puerto.readStringUntil('\n');
  }

  // Avisa una sola vez cuando se pierde la senal y otra cuando vuelve
  boolean sinSenalAhora = sinSenal();
  if (sinSenalAhora != sinSenalAnterior) {
    if (sinSenalAhora) {
      registrarEvento(NIVEL_CRITICO, "Sin senal del Arduino");
    } else {
      registrarEvento(NIVEL_NORMAL, "Senal del Arduino recuperada");
    }
    sinSenalAnterior = sinSenalAhora;
  }
}

/**
 * true si estamos en modo Arduino y hace mas de MS_SIN_SENAL que no llega nada
 */
boolean sinSenal() {
  return modoArduino && (millis() - ultimaTramaMs > MS_SIN_SENAL);
}

/**
 * El texto de la cabecera: de donde salen los datos que se estan viendo
 */
String textoOrigenDatos() {
  if (!modoArduino) {
    return "telemetria simulada (tecla M para pasar al Arduino)";
  }
  if (sinSenal()) {
    return "SIN SENAL del Arduino (" + estadoConexion + ")";
  }
  return "datos reales del Arduino (" + estadoConexion + ")";
}

/**
 * Tecla M: cambia entre datos del Arduino y datos simulados
 * Sirve de respaldo si el Arduino falla durante la presentacion
 */
void alternarModo() {
  if (modoArduino) {
    modoArduino = false;
    registrarEvento(NIVEL_NORMAL, "Origen de datos: SIMULACION");
  } else if (puerto != null) {
    modoArduino = true;
    ultimaTramaMs = millis();
    registrarEvento(NIVEL_NORMAL, "Origen de datos: ARDUINO en " + estadoConexion);
  } else {
    registrarEvento(NIVEL_BAJO, "No hay Arduino conectado: se queda en SIMULACION");
  }
}

/**
 * Manda una orden al Arduino. Cada orden es una linea de texto terminada en salto de linea
 */
void enviarOrden(String orden) {
  if (puerto == null) {
    registrarEvento(NIVEL_BAJO, "No hay Arduino conectado: no se envio " + orden);
    return;
  }
  puerto.write(orden + "\n");
  registrarEvento(NIVEL_NORMAL, "Orden enviada: " + orden);
}

/**
 * Tecla R: la planta vuelve a ESPERA, se restaura el umbral y la energia vuelve a cero
 */
void reiniciarPlanta() {
  enviarOrden("CMD:RESET");
  umbralDerivacionV = UMBRAL_DERIVACION_INICIAL_V;
}

/**
 * Teclas + y -: cambia el umbral de derivacion
 * str() escribe el numero con punto decimal, que es lo que entiende el Arduino
 */
void ajustarUmbral(float cambio) {
  umbralDerivacionV = constrain(umbralDerivacionV + cambio, UMBRAL_MIN_V, UMBRAL_MAX_V);
  enviarOrden("CMD:UMBRAL=" + str(umbralDerivacionV));
}
