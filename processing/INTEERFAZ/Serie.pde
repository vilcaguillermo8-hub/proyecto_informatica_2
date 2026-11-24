/**
 * Serie.pde
 * Aca conecto Processing con el Arduino de la carpeta arduino/planta_eolica
 * El Arduino manda una trama por segundo con ocho datos
 * De momento solo uso cuatro: HUM, VTO, POT y TMP
 * Los otros datos (V, I, EST y ENE) se descartan hasta que los necesitemos
 * Si dejan de llegar tramas, la simulacion sigue funcionando como respaldo
 */

import processing.serial.*;

// Puerto abierto. Queda en null si no hay placa conectada
Serial puertoSerie = null;

// Los cuatro valores que llegan del Arduino, ya en las unidades de Processing
float humedadSerie = 0.0;
float vientoSerie = 0.0;
float potenciaSerieMw = 0.0;
float temperaturaSerie = 0.0;

// Guardo el momento de la ultima trama valida para saber si el Arduino sigue vivo
long ultimaTramaMs = 0L;
boolean tramaRecibida = false;
boolean modoRealAnterior = false;

/**
 * Busco un puerto serie libre y lo abro a la misma velocidad que Config.h
 * Pruebo los puertos en orden y me quedo con el primero que se abre
 * Si no hay ninguno, no pasa nada: la simulacion sigue sola
 */
void inicializarSerie() {
  String[] puertos = new String[0];

  try {
    puertos = Serial.list();
  } catch (Exception error) {
    println("ERROR: no se pudieron listar los puertos serie");
    return;
  }

  println("Puertos serie disponibles: " + join(puertos, ", "));

  if (puertos.length == 0) {
    println("Aviso: no hay puertos serie, se usa la simulacion");
    return;
  }

  // Si eligieron un puerto a mano, solo pruebo ese
  if (PUERTO_SERIE_FORZADO.length() > 0) {
    serieAbrirPuerto(PUERTO_SERIE_FORZADO);
    return;
  }

  for (int i = 0; i < puertos.length; i++) {
    if (serieAbrirPuerto(puertos[i])) {
      return;
    }
  }

  println("Aviso: ningun puerto se pudo abrir, se usa la simulacion");
}

/**
 * Intenta abrir un puerto y devuelve true si lo logro
 * bufferUntil espera al salto de linea para entregar la trama completa
 */
boolean serieAbrirPuerto(String nombre) {
  try {
    puertoSerie = new Serial(this, nombre, BAUDIOS_SERIE);
    puertoSerie.bufferUntil('\n');
    println("Puerto serie abierto: " + nombre
            + " a " + BAUDIOS_SERIE + " baudios");
    return true;
  } catch (Exception error) {
    println("No se pudo abrir " + nombre);
    return false;
  }
}

/**
 * Processing llama sola a esta funcion cuando llegan datos del puerto
 * Leo la linea completa y la mando a parsear
 */
void serialEvent(Serial puerto) {
  if (puerto == null) {
    return;
  }

  String trama = puerto.readString();
  if (trama != null) {
    serieProcesarTrama(trim(trama));
  }
}

/**
 * Separo la trama por punto y coma, por ejemplo
 * HUM:48;VTO:8.5;POT:250;TMP:24;V:5.0;I:50;EST:1;ENE:4.17
 * Reconozco solo las cuatro claves que usa Processing
 * Las demas claves se ignoran
 * Devuelvo false si falta alguna de las cuatro o si algun numero no sirve
 */
boolean serieProcesarTrama(String trama) {
  if (trama == null || trama.length() == 0) {
    return false;
  }

  String[] pares = split(trama, ';');
  if (pares == null || pares.length == 0) {
    return false;
  }

  float hum = 0.0;
  float vien = 0.0;
  float potMw = 0.0;
  float tem = 0.0;
  boolean llegoHum = false;
  boolean llegoVien = false;
  boolean llegoPot = false;
  boolean llegoTem = false;

  for (int i = 0; i < pares.length; i++) {
    String[] partes = split(trim(pares[i]), ':');
    if (partes.length != 2) {
      continue;
    }

    String clave = trim(partes[0]);
    float numero = parseFloat(trim(partes[1]));

    // NaN es el unico valor que no es igual a si mismo
    if (numero != numero) {
      continue;
    }

    if (clave.equals("HUM")) {
      hum = numero;
      llegoHum = true;
    } else if (clave.equals("VTO")) {
      vien = numero;
      llegoVien = true;
    } else if (clave.equals("POT")) {
      potMw = numero;
      llegoPot = true;
    } else if (clave.equals("TMP")) {
      tem = numero;
      llegoTem = true;
    }
    // V, I, EST y ENE se descartan por ahora
  }

  if (!llegoHum || !llegoVien || !llegoPot || !llegoTem) {
    return false;
  }

  humedadSerie = hum;
  vientoSerie = vien;

  // Arduino mide la potencia en mW y Processing la muestra en mW
  potenciaSerieMw = potMw;

  temperaturaSerie = tem;
  ultimaTramaMs = millis();
  tramaRecibida = true;
  return true;
}

/**
 * Los datos reales se aceptan solo si la ultima trama es reciente
 * Con un segundo de envio, tres segundos dan margen para perder alguna trama
 */
boolean serieHayDatosRecientes() {
  return tramaRecibida && (millis() - ultimaTramaMs) <= TIEMPO_ESPERA_SERIE_MS;
}

/**
 * Copio los cuatro valores al estado para que la interfaz y la logica
 * sigan leyendo siempre los mismos objetos de antes
 */
void serieAplicarMedicion(EstadoSistema estado) {
  if (estado == null) {
    return;
  }
  estado.humedad.establecerValor(humedadSerie);
  estado.viento.establecerValor(vientoSerie);
  estado.potencia.establecerValor(potenciaSerieMw);
  estado.temperatura.establecerValor(temperaturaSerie);
}

/**
 * Escribo en la bitacora solo cuando cambio de origen de datos
 * Asi se ve si la placa conecto o si se quedo sin datos
 */
void serieAvisarCambioDeModo(boolean modoReal) {
  if (modoReal == modoRealAnterior) {
    return;
  }
  modoRealAnterior = modoReal;

  if (modoReal) {
    registrarEvento(NIVEL_NORMAL, "Datos en vivo desde Arduino");
  } else if (tramaRecibida) {
    registrarEvento(NIVEL_BAJO, "Arduino sin datos, vuelvo a la simulacion");
  }
}
