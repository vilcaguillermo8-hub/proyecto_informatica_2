/**
 * Logica.pde
 * Aca se hace el trabajo de la simulacion
 * No dibuja, solo actualiza datos y decide cuando avisar de un cambio
 */

/**
 * Actualiza todas las variables en un paso de tiempo
 * Lo llamo desde draw(), pero solo hace algo cada CUADROS_POR_LECTURA cuadros
 */
void logicaActualizarSimulacion(EstadoSistema estado,
                                ListaEnlazadaEventos bitacora) {
  // Si me pasan datos nulos, salgo para no cortar el dibujo a mitad
  if (estado == null || bitacora == null) {
    println("ERROR: estado o bitacora nulos");
    return;
  }

  // El resto de los cuadros solo dibuja, no genera lecturas nuevas
  if (frameCount % CUADROS_POR_LECTURA != 0) {
    return;
  }

  for (int i = 0; i < estado.variables.length; i++) {
    VariableMonitorizada variable = estado.variables[i];
    variable.simularLectura();

    // Comparo el nivel nuevo contra el anterior
    // Solo escribo en la bitacora cuando hay un cambio, no en cada lectura
    int nivelActual = variable.obtenerNivel();
    if (nivelActual != estado.nivelAnterior[i]) {
      registrarCambioDeNivel(variable, nivelActual, bitacora);
      estado.nivelAnterior[i] = nivelActual;
    }
  }

  estado.nivelGeneral = logicaCalcularNivelGeneral(estado);
}

/**
 * El estado general toma el peor nivel de las cuatro variables
 * Asi, si una sola esta en critico, el panel general tambien lo marca
 */
int logicaCalcularNivelGeneral(EstadoSistema estado) {
  int nivel = NIVEL_NORMAL;
  for (int i = 0; i < estado.variables.length; i++) {
    int nivelVariable = estado.variables[i].obtenerNivel();
    if (nivelVariable > nivel) {
      nivel = nivelVariable;
    }
  }
  return nivel;
}

/**
 * Arma el mensaje cuando una variable cambia de nivel
 * Incluye el nombre, el nivel nuevo y el valor con su unidad
 */
void registrarCambioDeNivel(VariableMonitorizada variable, int nivelNuevo,
                            ListaEnlazadaEventos bitacora) {
  String mensaje = variable.nombre + " -> " + textoNivel(nivelNuevo)
                 + " (" + variable.formatearValor() + " " + variable.unidad + ")";
  bitacora.agregar(new RegistroEvento(nivelNuevo, mensaje));
}

/**
 * Guarda un evento en la bitacora y lo muestra en la consola
 * Lo uso tanto para cambios de nivel como para acciones del operador
 */
void registrarEvento(int nivel, String texto) {
  println("[" + textoNivel(nivel) + "] " + texto);
  if (bitacoraEventos != null) {
    bitacoraEventos.agregar(new RegistroEvento(nivel, texto));
  }
}

/**
 * Traduce los numeros de nivel a texto para poder mostrarlos
 */
String textoNivel(int nivel) {
  if (nivel == NIVEL_CRITICO) {
    return "CRITICO";
  }
  if (nivel == NIVEL_BAJO) {
    return "BAJO";
  }
  return "NORMAL";
}
