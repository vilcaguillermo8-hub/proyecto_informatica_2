/**
 * MetodosNumericos.pde
 * Aca aplico el metodo de Euler al estado general del aerogenerador
 * El estado se vuelve un numero continuo para poder graficar su evolucion
 * El objetivo sale del peor nivel de las cuatro variables del generador
 */

/**
 * GraficoEstadoEuler
 * Guarda un valor continuo que representa el estado general
 * Ese valor va de 0 a 2 y se actualiza con Euler en cada lectura nueva
 * BAJO vale 0, NORMAL vale 1 y CRITICO vale 2
 * Asi el grafico queda con BAJO abajo, NORMAL en el medio y CRITICO arriba
 * Al graficarlo se ve como el sistema se acerca al estado medido
 */
class GraficoEstadoEuler {
  // Valor ya integrado, empieza en el medio porque el arranque es NORMAL
  float estadoSuavizado = 1.0;

  // Paso de tiempo entre lecturas, sale de la configuracion del sketch
  float paso = 0.4;

  // Ganancia de la ecuacion, define que tan rapido se acerca al objetivo
  float ganancia = 1.6;

  // Tiempo acumulado para saber cuantos segundos cubre el historial
  float tiempo = 0.0;

  // Historial en orden cronologico, la primera muestra es la mas vieja
  float[] valores = null;
  int[] niveles = null;
  int cantidad = 0;

  GraficoEstadoEuler() {
    paso = CUADROS_POR_LECTURA / (float) CUADROS_POR_SEGUNDO;
    valores = new float[CANTIDAD_MUESTRAS_ESTADO];
    niveles = new int[CANTIDAD_MUESTRAS_ESTADO];
    registrarMuestra(NIVEL_NORMAL, estadoSuavizado);
  }

  /**
   * Convierte el nivel general en el numero que quiere alcanzar Euler
   * Cuanto peor el estado, mas arriba queda el objetivo
   */
  float objetivoDesdeNivel(int nivel) {
    if (nivel == NIVEL_CRITICO) {
      return 2.0;
    }
    if (nivel == NIVEL_NORMAL) {
      return 1.0;
    }
    return 0.0;
  }

  /**
   * Un paso de Euler sobre la ecuacion ds/dt = k(objetivo - s)
   * La formula que aplico es s(t+dt) = s(t) + k(objetivo - s(t))dt
   * La derivada es la diferencia entre el objetivo y el valor actual
   * Asi el estado no salta de golpe y la transicion se ve en el grafico
   */
  void actualizar(int nivelGeneral) {
    float objetivo = objetivoDesdeNivel(nivelGeneral);
    float derivada = ganancia * (objetivo - estadoSuavizado);

    estadoSuavizado = estadoSuavizado + derivada * paso;
    estadoSuavizado = constrain(estadoSuavizado, 0.0, 2.0);

    tiempo = tiempo + paso;
    // Guardo el nivel del valor suavizado para que el color coincida con la franja
    registrarMuestra(obtenerNivel(), estadoSuavizado);
  }

  /**
   * Guarda la muestra nueva al final del historial
   * Cuando se llena, corro todo una posicion y descarto la mas vieja
   */
  void registrarMuestra(int nivel, float valor) {
    if (cantidad < valores.length) {
      valores[cantidad] = valor;
      niveles[cantidad] = nivel;
      cantidad++;
      return;
    }

    for (int i = 0; i < valores.length - 1; i++) {
      valores[i] = valores[i + 1];
      niveles[i] = niveles[i + 1];
    }

    valores[valores.length - 1] = valor;
    niveles[niveles.length - 1] = nivel;
  }

  /**
   * Devuelve el nivel que corresponde al valor ya integrado
   * Los cortes estan en un tercio y dos tercios para coincidir con las franjas
   */
  int obtenerNivel() {
    if (estadoSuavizado >= 4.0 / 3.0) {
      return NIVEL_CRITICO;
    }
    if (estadoSuavizado >= 2.0 / 3.0) {
      return NIVEL_NORMAL;
    }
    return NIVEL_BAJO;
  }
}
