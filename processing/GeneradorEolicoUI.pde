/**
 * GeneradorEolicoUI.pde
 * Archivo principal del sketch
 * Aca estan las variables globales y las funciones que Processing llama solo
 * setup() se ejecuta una vez al abrir el programa
 * draw() se repite en cada cuadro
 * keyPressed() y mousePressed() se llaman cuando el usuario interactua
 */

// Guardo el estado de los cuatro sensores en una sola variable
// Asi todas las funciones miran los mismos datos
EstadoSistema estadoSistema = null;

// Historial de eventos, guardado como lista enlazada
ListaEnlazadaEventos bitacoraEventos = null;

// Momento en que arranco el sketch, para mostrar el tiempo de sesion
long instanteInicioMs = 0L;

// Bandera para congelar la simulacion sin detener el dibujo
// Asi la interfaz sigue respondiendo al mouse aunque este en pausa
boolean simulacionEnPausa = false;

// Areas de los tres botones del pie
// Las creo vacias y les doy su posicion real cuando dibujo el pie
Rect botonPausa = null;
Rect botonGuardar = null;
Rect botonLimpiar = null;

void setup() {
  // Processing quiere los numeros del size() escritos directamente
  size(1280, 800);
  surface.setResizable(true);
  smooth();
  frameRate(CUADROS_POR_SEGUNDO);

  // Preparo fuentes y botones antes de usarlos
  inicializarFuentes();
  inicializarBotones();

  // Creo el estado y la bitacora con new
  // Son objetos distintos, pero se pasan por referencia a las demas funciones
  estadoSistema = new EstadoSistema(IDENTIFICADOR_SISTEMA);
  bitacoraEventos = new ListaEnlazadaEventos(CAPACIDAD_MAXIMA_BITACORA);

  // Leo los umbrales del archivo y dejo constancia de que arranque
  persistenciaCargarConfiguracion(estadoSistema);
  registrarEvento(NIVEL_NORMAL,
    "Interfaz iniciada, origen de datos: SIMULACION (Arduino pendiente)");

  instanteInicioMs = millis();
}

// En cada cuadro actualizo los datos y despues dibujo
// Si esta en pausa salto la actualizacion pero sigo dibujando
void draw() {
  if (!simulacionEnPausa) {
    logicaActualizarSimulacion(estadoSistema, bitacoraEventos);
  }
  interfazDibujarPantalla(estadoSistema, bitacoraEventos,
                          simulacionEnPausa, instanteInicioMs);
}

// El teclado da accesos rapidos a las mismas acciones de los botones
void keyPressed() {
  char tecla = Character.toLowerCase(key);

  if (tecla == ' ') {
    alternarPausa();
  } else if (tecla == 'r') {
    logicaReiniciarSimulacion(estadoSistema, bitacoraEventos);
    simulacionEnPausa = false;
  } else if (tecla == 'g') {
    persistenciaGuardarBitacora(bitacoraEventos);
  } else if (tecla == 'c') {
    bitacoraEventos.limpiar();
    registrarEvento(NIVEL_NORMAL, "Bitacora limpiada por el operador");
  }
}

// El mouse hace lo mismo que el teclado, pero apuntando a un boton
void mousePressed() {
  // Primero averiguo si el clic cayo dentro de algun boton
  int boton = interfazObtenerBotonEn(mouseX, mouseY);

  if (boton == BOTON_PAUSA) {
    alternarPausa();
  } else if (boton == BOTON_GUARDAR) {
    persistenciaGuardarBitacora(bitacoraEventos);
  } else if (boton == BOTON_LIMPIAR) {
    bitacoraEventos.limpiar();
    registrarEvento(NIVEL_NORMAL, "Bitacora limpiada por el operador");
  }
}

// Cambio la bandera de pausa y escribo el mensaje en la bitacora
void alternarPausa() {
  simulacionEnPausa = !simulacionEnPausa;
  String mensaje = simulacionEnPausa ? "Simulacion en pausa"
                                     : "Simulacion reanudada";
  registrarEvento(NIVEL_NORMAL, mensaje);
}
