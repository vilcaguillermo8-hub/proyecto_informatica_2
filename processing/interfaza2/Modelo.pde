/**
 * Modelo.pde
 * Aca defino las clases que guardan los datos del programa
 * Solo guardan informacion y la entregan a quien la pide
 */

/**
 * VariableMonitorizada
 * Sirve para representar una medicion: humedad, viento, potencia o temperatura
 * Guarda el valor actual, los limites para clasificarlo y la funcion que simula lecturas
 */
class VariableMonitorizada {
  // Datos fijos que sirven para mostrar la variable en pantalla
  String identificador = "";
  String nombre = "";
  String unidad = "";
  String descripcion = "";

  // valorAnterior queda guardado por si despues quiero mostrar la tendencia
  float valor = 0.0;
  float valorAnterior = 0.0;

  // Rango de la simulacion y tamaño del paso al azar
  float minimoSimulado = 0.0;
  float maximoSimulado = 100.0;
  float pasoSimulacion = 1.0;

  // Los cuatro limites que deciden si el valor es NORMAL, BAJO o CRITICO
  float limiteBajo = 30.0;
  float limiteNormalAlto = 70.0;
  float limiteCriticoBajo = 10.0;
  float limiteCriticoAlto = 90.0;

  int decimales = 1;

  VariableMonitorizada(String id, String nom, String uni, String desc) {
    identificador = id;
    nombre = nom;
    unidad = uni;
    descripcion = desc;
  }

  // Devuelve false si los datos no tienen sentido, para no dejar limites raros
  boolean configurarSimulacion(float minimo, float maximo, float paso, float inicial) {
    if (minimo >= maximo || paso <= 0.0) {
      println("ERROR: simulacion invalida para " + identificador);
      return false;
    }
    minimoSimulado = minimo;
    maximoSimulado = maximo;
    pasoSimulacion = paso;
    valor = constrain(inicial, minimo, maximo);
    valorAnterior = valor;
    return true;
  }

  // Chequeo que los limites esten ordenados, si no la clasificacion saldria mal
  boolean configurarUmbrales(float bajo, float normalAlto,
                             float criticoBajo, float criticoAlto) {
    if (!(criticoBajo <= bajo && bajo < normalAlto && normalAlto <= criticoAlto)) {
      println("ERROR: umbrales inconsistentes en " + identificador);
      return false;
    }
    limiteBajo = bajo;
    limiteNormalAlto = normalAlto;
    limiteCriticoBajo = criticoBajo;
    limiteCriticoAlto = criticoAlto;
    return true;
  }

  // El archivo de configuracion manda el nombre del umbral como texto
  // Aca decido cual de los cuatro limites hay que cambiar
  boolean establecerUmbral(String nombreUmbral, float valorNuevo) {
    float bajo = limiteBajo;
    float normalAlto = limiteNormalAlto;
    float criticoBajo = limiteCriticoBajo;
    float criticoAlto = limiteCriticoAlto;

    if (nombreUmbral.equals("bajo")) {
      bajo = valorNuevo;
    } else if (nombreUmbral.equals("normalAlto")) {
      normalAlto = valorNuevo;
    } else if (nombreUmbral.equals("criticoBajo")) {
      criticoBajo = valorNuevo;
    } else if (nombreUmbral.equals("criticoAlto")) {
      criticoAlto = valorNuevo;
    } else {
      println("ERROR: umbral desconocido " + nombreUmbral);
      return false;
    }

    return configurarUmbrales(bajo, normalAlto, criticoBajo, criticoAlto);
  }

  void establecerDecimales(int cantidad) {
    if (cantidad < 0) {
      println("ERROR: decimales invalidos en " + identificador);
      return;
    }
    decimales = cantidad;
  }

  // Este metodo lo usa la lectura del Arduino
  // En vez de inventar un numero, pongo el que vino en la trama serie
  void establecerValor(float valorNuevo) {
    if (valorNuevo != valorNuevo) {
      println("ERROR: valor no numerico en " + identificador);
      return;
    }
    valorAnterior = valor;
    valor = constrain(valorNuevo, minimoSimulado, maximoSimulado);
  }

  // Cada lectura camina un paso al azar desde el valor anterior
  void simularLectura() {
    float delta = random(-pasoSimulacion, pasoSimulacion);
    float candidato = valor + delta;

    if (random(1.0) < PROBABILIDAD_EVENTO_ALEATORIO) {
      candidato = random(minimoSimulado, maximoSimulado);
    }

    valorAnterior = valor;
    valor = constrain(candidato, minimoSimulado, maximoSimulado);
  }

  // Primero miro los extremos criticos, despues los de bajo
  // Si no cumple ninguno, el valor queda como normal
  int obtenerNivel() {
    if (valor <= limiteCriticoBajo || valor >= limiteCriticoAlto) {
      return NIVEL_CRITICO;
    }
    if (valor < limiteBajo || valor > limiteNormalAlto) {
      return NIVEL_BAJO;
    }
    return NIVEL_NORMAL;
  }

  // Sirve para la flechita que aparece al lado del valor
  int obtenerDireccion() {
    if (valor < limiteBajo) {
      return -1;
    }
    if (valor > limiteNormalAlto) {
      return 1;
    }
    return 0;
  }

  // El medidor y la barra esperan un numero entre 0 y 1
  float obtenerFraccion() {
    float rango = maximoSimulado - minimoSimulado;
    if (rango <= 0.0) {
      return 0.0;
    }
    return constrain((valor - minimoSimulado) / rango, 0.0, 1.0);
  }

  // nf() me da el numero con la cantidad de decimales de cada variable
  String formatearValor() {
    return nf(valor, 0, decimales);
  }

  // Armo el texto del rango normal para mostrarlo en la tarjeta
  String formatearRango() {
    return nf(limiteBajo, 0, decimales) + " - "
         + nf(limiteNormalAlto, 0, decimales) + " " + unidad;
  }
}

/**
 * RegistroEvento
 * Sirve para guardar un evento de la bitacora
 * Acumula mensajes con su hora y su nivel
 */
class RegistroEvento {
  long marcaTiempoMs = 0L;
  int nivel = NIVEL_NORMAL;
  String mensaje = "";
  String selloTiempo = "";

  RegistroEvento(int nivelEvento, String texto) {
    marcaTiempoMs = millis();
    nivel = nivelEvento;
    mensaje = texto;
    selloTiempo = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  }

  String formatearLinea() {
    return "[" + selloTiempo + "] " + mensaje;
  }
}

/**
 * Rect
 * Sirve para guardar un rectangulo con posicion y tamaño
 * Los botones necesitan saber donde estan y responder si el mouse esta adentro
 */
class Rect {
  float x = 0.0;
  float y = 0.0;
  float ancho = 0.0;
  float alto = 0.0;

  Rect(float px, float py, float pancho, float palto) {
    x = px;
    y = py;
    ancho = pancho;
    alto = palto;
  }

  boolean contiene(float px, float py) {
    return px >= x && px <= x + ancho && py >= y && py <= y + alto;
  }
}

/**
 * EstadoSistema
 * Sirve para juntar todo el estado del generador en un solo objeto
 * Porque la logica y la interfaz necesitan ver las cuatro variables
   y el nivel general
 */
class EstadoSistema {
  String identificador = "";

  VariableMonitorizada humedad = null;
  VariableMonitorizada viento = null;
  VariableMonitorizada potencia = null;
  VariableMonitorizada temperatura = null;

  VariableMonitorizada[] variables = null;

  // Guardo el nivel anterior de cada variable para detectar cambios
  int[] nivelAnterior = null;
  int nivelGeneral = NIVEL_NORMAL;

  EstadoSistema(String id) {
    identificador = id;

    // El prefijo se usa para encontrar la variable en el archivo de configuracion
    humedad = new VariableMonitorizada("HUM", "Humedad relativa", "%",
                                       "Humedad del aire en la sala");
    humedad.establecerDecimales(0);
    // El rango llega a 100 para no cortar valores reales del DHT
    humedad.configurarSimulacion(0.0, 100.0, 1.2, 48.0);
    humedad.configurarUmbrales(35.0, 65.0, 20.0, 80.0);

    viento = new VariableMonitorizada("VTO", "Velocidad del viento", "m/s",
                                      "Anemometro en la punta del mastil");
    viento.configurarSimulacion(0.0, 28.0, 0.9, 8.0);
    viento.configurarUmbrales(4.0, 15.0, 1.0, 25.0);

    potencia = new VariableMonitorizada("POT", "Potencia generada", "kW",
                                        "Salida del generador");
    // Arduino manda mW y aca guardo kW, por eso los numeros son tan chicos
    // La maqueta da como maximo unos 640 mW, que son 0.00064 kW
    potencia.establecerDecimales(6);
    potencia.configurarSimulacion(0.0, 0.0008, 0.000022, 0.00042);
    potencia.configurarUmbrales(0.00015, 0.00060, 0.00005, 0.00075);

    temperatura = new VariableMonitorizada("TMP", "Temperatura", "°C",
                                           "Temperatura del gabinete electronico");
    temperatura.configurarSimulacion(-10.0, 55.0, 0.8, 24.0);
    temperatura.configurarUmbrales(10.0, 35.0, -5.0, 50.0);

    // El arreglo me permite recorrer las cuatro variables con un for
    variables = new VariableMonitorizada[] {
      humedad, viento, potencia, temperatura
    };

    nivelAnterior = new int[variables.length];
    for (int i = 0; i < nivelAnterior.length; i++) {
      nivelAnterior[i] = NIVEL_NORMAL;
    }

    nivelGeneral = NIVEL_NORMAL;
  }

  // El archivo usa claves como HUM.bajo, por eso busco por prefijo
  VariableMonitorizada obtenerVariablePorPrefijo(String prefijo) {
    for (int i = 0; i < variables.length; i++) {
      if (variables[i].identificador.equalsIgnoreCase(prefijo)) {
        return variables[i];
      }
    }
    return null;
  }
}
