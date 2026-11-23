/**
 * GeneradorEolicoUI.pde
 * Archivo principal del sketch
 * Aca estan las variables globales y las funciones que Processing llama solo
 */

import processing.serial.*;   // para hablar con el Arduino por USB

// Guardo el estado de los cuatro sensores en una sola variable
// Asi todas las funciones miran los mismos datos
EstadoSistema estadoSistema = null;

// Historial de eventos, guardado como lista enlazada
ListaEnlazadaEventos bitacoraEventos = null;

// Areas de los dos botones del pie
// se crean vacias y les doy su posicion real cuando dibujo el pie
Rect botonGuardar = null;
Rect botonLimpiar = null;

void setup() {
  size(1280, 800);
  surface.setResizable(true);
  smooth();
  frameRate(CUADROS_POR_SEGUNDO);

  // Preparamos fuentes y botones antes de usarlos
  inicializarFuentes();
  inicializarBotones();

  // Creo el estado y la bitacora con new
  // Son objetos distintos, pero se pasan por referencia a las demas funciones
  estadoSistema = new EstadoSistema(IDENTIFICADOR_SISTEMA);
  bitacoraEventos = new ListaEnlazadaEventos(CAPACIDAD_MAXIMA_BITACORA);

  // Con esto se leen umbrales del archivo y deja constancia de que arranque
  persistenciaCargarConfiguracion(estadoSistema);
  registrarEvento(NIVEL_NORMAL, "Interfaz iniciada");

  // Intenta conectar con el Arduino; si no puede, queda en SIMULACION
  iniciarComunicacionSerie();

}

// En cada cuadro se actualizan los datos y despues dibuja
void draw() {
  if (modoArduino) {
    leerPuertoSerie();
    logicaRevisarNiveles(estadoSistema, bitacoraEventos);
  } else {
    logicaActualizarSimulacion(estadoSistema, bitacoraEventos);
  }
  interfazDibujarPantalla(estadoSistema, bitacoraEventos);
}

// El teclado sirve para las mismas acciones que los botones
void keyPressed() {
  char tecla = Character.toLowerCase(key);

  if (tecla == 'g') {
    persistenciaGuardarBitacora(bitacoraEventos);
  } else if (tecla == 'c') {
    bitacoraEventos.limpiar();
    registrarEvento(NIVEL_NORMAL, "Bitacora limpiada por el operador");
  } else if (tecla == 'm') {
    alternarModo();                      // Arduino <-> simulacion
  } else if (tecla == 'r') {
    reiniciarPlanta();                   // CMD:RESET
  } else if (tecla == '+') {
    ajustarUmbral(PASO_UMBRAL_V);        // CMD:UMBRAL=<V>
  } else if (tecla == '-') {
    ajustarUmbral(-PASO_UMBRAL_V);
  }
}

// El mouse sirve pa los botones
void mousePressed() {
  // Primero averigua si el clic fue dentro de algun boton
  int boton = interfazObtenerBotonEn(mouseX, mouseY);

  if (boton == BOTON_GUARDAR) {
    persistenciaGuardarBitacora(bitacoraEventos);
  } else if (boton == BOTON_LIMPIAR) {
    bitacoraEventos.limpiar();
    registrarEvento(NIVEL_NORMAL, "Bitacora limpiada por el operador");
  }
}
