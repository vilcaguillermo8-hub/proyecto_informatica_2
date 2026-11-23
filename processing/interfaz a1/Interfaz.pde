/**
 * Interfaz.pde
 * Todo lo que se ve en pantalla
 * Las funciones de aca solo leen el estado y dibujan
 */

// Las fuentes se cargan una sola vez al arrancar
PFont fuenteTitulo = null;
PFont fuenteCuerpo = null;
PFont fuenteDatos = null;

/**
 * Elijo las tres fuentes
 */
void inicializarFuentes() {
  fuenteTitulo = crearFuenteSegura("Segoe UI Semibold", 26);
  fuenteCuerpo = crearFuenteSegura("Segoe UI", 14);
  fuenteDatos = crearFuenteSegura("Consolas", 26);

  if (fuenteTitulo == null) {
    fuenteTitulo = crearFuenteSegura("Arial", 26);
  }
  if (fuenteCuerpo == null) {
    fuenteCuerpo = crearFuenteSegura("Arial", 14);
  }
  if (fuenteDatos == null) {
    fuenteDatos = crearFuenteSegura("Arial", 24);
  }
}

/**
 */
PFont crearFuenteSegura(String nombre, int tamaño) {
  try {
    return createFont(nombre, tamaño, true);
  } catch (Exception error) {
    println("Fuente no disponible " + nombre + ": " + error.getMessage());
    return null;
  }
}

// Si la fuente quedo en null, dejo la que tenia puesta antes
void aplicarFuente(PFont fuente) {
  if (fuente != null) {
    textFont(fuente);
  }
}

/**
 * Creo los dos objetos Rect al arrancar
 * Sus coordenadas reales se calculan en dibujarPie() porque dependen del ancho de la ventana
 */
void inicializarBotones() {
  botonGuardar = new Rect(0.0, 0.0, 1.0, 1.0);
  botonLimpiar = new Rect(0.0, 0.0, 1.0, 1.0);
}

/**
 * Uso width para que los botones queden alineados a la derecha
 * Asi se acomodan aunque la ventana cambie de tamaño
 */
void actualizarGeometriaBotones(float y) {
  botonGuardar.x = width - 278.0;
  botonGuardar.y = y + 18.0;
  botonGuardar.ancho = 120.0;
  botonGuardar.alto = 34.0;

  botonLimpiar.x = width - 148.0;
  botonLimpiar.y = y + 18.0;
  botonLimpiar.ancho = 120.0;
  botonLimpiar.alto = 34.0;
}

/**
 * Le pregunto a cada Rect si el mouse esta adentro
 * Devuelvo un codigo distinto para saber que accion tomar
 */
int interfazObtenerBotonEn(float px, float py) {
  if (botonGuardar != null && botonGuardar.contiene(px, py)) {
    return BOTON_GUARDAR;
  }
  if (botonLimpiar != null && botonLimpiar.contiene(px, py)) {
    return BOTON_LIMPIAR;
  }
  return BOTON_NINGUNO;
}

/**
 * Dibujo de la pantalla completa
 */
void interfazDibujarPantalla(EstadoSistema estado,
                             ListaEnlazadaEventos bitacora) {
  dibujarFondo();
  dibujarCabecera(estado);
  dibujarAreaVariables(estado);
  dibujarPanelLateral(estado, bitacora);
  dibujarPie();
}

/**
 * Pinto todo el fondo 
 */
void dibujarFondo() {
  pushStyle();
  noStroke();
  for (int y = 0; y < height; y += 6) {
    float factor = y / (float) max(height, 1);
    fill(lerpColor(COLOR_FONDO, COLOR_FONDO_CLARO, factor));
    rect(0, y, width, 6);
  }

  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 16);
  strokeWeight(1);
  for (int x = 0; x < width; x += 40) {
    line(x, 0, x, height);
  }
  for (int y = 0; y < height; y += 40) {
    line(0, y, width, y);
  }
  popStyle();
}

/**
 * Muestro el titulo y el nombre del sistema en la franja superior
 */
void dibujarCabecera(EstadoSistema estado) {
  pushStyle();
  noStroke();
  fill(COLOR_ACENTO);
  rect(0, 0, width, 4);

  aplicarFuente(fuenteTitulo);
  textSize(26);
  textAlign(LEFT, TOP);
  fill(COLOR_TEXTO);
  text("MONITOREO · GENERADOR EOLICO", 28, 20);

  aplicarFuente(fuenteCuerpo);
  textSize(13);
  fill(COLOR_TEXTO_SUAVE);
  text("Sistema " + estado.identificador
       + "  ·  telemetria simulada (integracion Arduino en desarrollo)", 28, 58);
  popStyle();
}

/**
 * Acomodo las cuatro tarjetas en una grilla de dos columnas y dos filas
 */
void dibujarAreaVariables(EstadoSistema estado) {
  float margen = 28.0;
  float anchoIzquierdo = width * 0.62;
  float separacion = 16.0;
  float xInicial = margen;
  float yInicial = 104.0;
  float anchoTarjeta = (anchoIzquierdo - separacion) / 2.0;
  float altoDisponible = height - yInicial - 86.0;
  float altoTarjeta = (altoDisponible - separacion) / 2.0;

  for (int i = 0; i < estado.variables.length; i++) {
    int fila = i / 2;
    int columna = i % 2;
    float x = xInicial + columna * (anchoTarjeta + separacion);
    float y = yInicial + fila * (altoTarjeta + separacion);
    dibujarTarjetaVariable(estado.variables[i], x, y,
                           anchoTarjeta, altoTarjeta);
  }
}

/**
 * Cada tarjeta muestra nombre, descripcion, valor, medidor circular y barra de rangos
 * El color del borde cambia segun el nivel de la variable
 */
void dibujarTarjetaVariable(VariableMonitorizada variable,
                            float x, float y, float ancho, float alto) {
  int nivel = variable.obtenerNivel();
  color tono = colorNivel(nivel);

  pushStyle();
  noStroke();
  fill(0, 90);
  rect(x + 5, y + 7, ancho, alto, 16);

  fill(COLOR_PANEL);
  stroke(red(tono), green(tono), blue(tono), 120);
  strokeWeight(1.4);
  rect(x, y, ancho, alto, 16);

  noStroke();
  fill(tono);
  rect(x, y + 16, 5, alto - 32, 3);

  aplicarFuente(fuenteCuerpo);
  textSize(14);
  textAlign(LEFT, TOP);
  fill(COLOR_TEXTO);
  text(variable.nombre, x + 22, y + 20);

  textSize(11);
  fill(COLOR_TEXTO_SUAVE);
  text(variable.descripcion, x + 22, y + 42);

  dibujarInsigniaNivel(nivel, x + ancho - 118.0, y + 18.0);

  float centroX = x + 74.0;
  float centroY = y + 130.0;
  dibujarMedidor(centroX, centroY, 94.0, variable.obtenerFraccion(), tono);

  aplicarFuente(fuenteDatos);
  textSize(29);
  textAlign(LEFT, CENTER);
  fill(COLOR_TEXTO);
  text(variable.formatearValor() + simboloDireccion(variable.obtenerDireccion()),
       x + 138, centroY - 10);

  aplicarFuente(fuenteCuerpo);
  textSize(13);
  textAlign(LEFT, TOP);
  fill(COLOR_TEXTO_SUAVE);
  text(variable.unidad, x + 140, centroY + 12);

  textSize(11);
  fill(COLOR_TEXTO_SUAVE);
  text("Rango normal: " + variable.formatearRango(), x + 22, y + alto - 76);

  dibujarBarraRango(x + 22, y + alto - 44, ancho - 44, variable, tono);
  popStyle();
}

/**
 * La etiqueta con NORMAL, BAJO o CRITICO y el color que le corresponde
 */
void dibujarInsigniaNivel(int nivel, float x, float y) {
  color tono = colorNivel(nivel);
  pushStyle();
  noStroke();
  fill(red(tono), green(tono), blue(tono), 48);
  rect(x, y, 100, 26, 13);
  fill(tono);
  aplicarFuente(fuenteCuerpo);
  textSize(11);
  textAlign(CENTER, CENTER);
  text(textoNivel(nivel), x + 50, y + 13);
  popStyle();
}

/**
 * El arco gris marca el rango completo
 * El arco de color muestra la parte que ya se lleno con el valor actual
 */
void dibujarMedidor(float cx, float cy, float diametro,
                    float fraccion, color tono) {
  float inicio = PI * 0.75;
  float barrido = PI * 1.5;

  pushStyle();
  noFill();
  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 170);
  strokeWeight(9);
  arc(cx, cy, diametro, diametro, inicio, inicio + barrido);

  stroke(tono);
  strokeWeight(9);
  arc(cx, cy, diametro, diametro, inicio,
      inicio + barrido * constrain(fraccion, 0.0, 1.0));

  noStroke();
  fill(COLOR_TEXTO_SUAVE);
  aplicarFuente(fuenteCuerpo);
  textSize(11);
  textAlign(CENTER, CENTER);
  text(round(fraccion * 100.0) + "%", cx, cy);
  popStyle();
}

/**
 * Pinto la zona normal en verde y los extremos en rojo
 * Despues pongo una marca fina en el lugar donde cae el valor actual
 */
void dibujarBarraRango(float x, float y, float ancho,
                       VariableMonitorizada variable, color tono) {
  float minimo = variable.minimoSimulado;
  // El minimo es chiquito porque potencia se mide en kW
  float rango = max(0.000001, variable.maximoSimulado - minimo);
  float inicioNormal = constrain((variable.limiteBajo - minimo) / rango, 0.0, 1.0);
  float finNormal = constrain((variable.limiteNormalAlto - minimo) / rango, 0.0, 1.0);
  float critIzq = constrain((variable.limiteCriticoBajo - minimo) / rango, 0.0, 1.0);
  float critDer = constrain((variable.limiteCriticoAlto - minimo) / rango, 0.0, 1.0);
  float posicion = variable.obtenerFraccion();

  pushStyle();
  noStroke();
  fill(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 90);
  rect(x, y, ancho, 8, 4);

  fill(red(COLOR_NORMAL), green(COLOR_NORMAL), blue(COLOR_NORMAL), 75);
  rect(x + ancho * inicioNormal, y, ancho * (finNormal - inicioNormal), 8, 4);

  fill(red(COLOR_CRITICO), green(COLOR_CRITICO), blue(COLOR_CRITICO), 65);
  rect(x, y, ancho * critIzq, 8, 4);
  rect(x + ancho * critDer, y, ancho * (1.0 - critDer), 8, 4);

  fill(tono);
  rect(x + ancho * posicion - 2, y - 5, 4, 18, 2);
  popStyle();
}

/**
 * Dejo el panel de estado arriba y la bitacora se lleva todo lo que sobra
 */
void dibujarPanelLateral(EstadoSistema estado, ListaEnlazadaEventos bitacora) {
  float margen = 28.0;
  float anchoIzquierdo = width * 0.62;
  float x = margen + anchoIzquierdo + 16.0;
  float ancho = width - x - margen;
  float y = 104.0;
  float separacion = 16.0;

  float altoEstado = 96.0;
  dibujarPanelEstado(x, y, ancho, altoEstado, estado);

  float yBitacora = y + altoEstado + separacion;
  float altoBitacora = height - yBitacora - 86.0;
  dibujarPanelBitacora(x, yBitacora, ancho, altoBitacora, bitacora);
}

/**
 * Resumo el estado general con su etiqueta y su color
 */
void dibujarPanelEstado(float x, float y, float ancho, float alto,
                        EstadoSistema estado) {
  pushStyle();
  fill(COLOR_PANEL);
  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 120);
  strokeWeight(1);
  rect(x, y, ancho, alto, 16);

  noStroke();
  aplicarFuente(fuenteCuerpo);
  textSize(12);
  fill(COLOR_TEXTO_SUAVE);
  textAlign(LEFT, TOP);
  text("ESTADO GENERAL", x + 18, y + 16);

  dibujarInsigniaNivel(estado.nivelGeneral, x + 18, y + 42);

  aplicarFuente(fuenteDatos);
  textSize(22);
  fill(colorNivel(estado.nivelGeneral));
  textAlign(RIGHT, TOP);
  text(textoNivel(estado.nivelGeneral), x + ancho - 18, y + 42);
  popStyle();
}

/**
 * Muestro los ultimos eventos, del mas reciente al mas viejo
 * Por eso recorro la lista desde el final hacia atras
 */
void dibujarPanelBitacora(float x, float y, float ancho, float alto,
                          ListaEnlazadaEventos bitacora) {
  pushStyle();
  fill(COLOR_PANEL);
  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 120);
  strokeWeight(1);
  rect(x, y, ancho, alto, 16);

  noStroke();
  aplicarFuente(fuenteCuerpo);
  textSize(12);
  fill(COLOR_TEXTO_SUAVE);
  textAlign(LEFT, TOP);
  text("BITACORA DE EVENTOS", x + 18, y + 16);

  int cantidad = min(MAX_EVENTOS_VISIBLES, bitacora.tamaño());
  float altoFila = (alto - 52.0) / (float) max(1, MAX_EVENTOS_VISIBLES);

  for (int i = 0; i < cantidad; i++) {
    RegistroEvento evento = bitacora.obtener(bitacora.tamaño() - 1 - i);
    if (evento == null) {
      continue;
    }

    float filaY = y + 48 + i * altoFila;
    color tono = colorNivel(evento.nivel);

    noStroke();
    fill(tono);
    ellipse(x + 24, filaY + 9, 7, 7);

    fill(COLOR_TEXTO);
    aplicarFuente(fuenteCuerpo);
    textSize(10.5);
    textAlign(LEFT, TOP);
    text(evento.formatearLinea(), x + 36, filaY, ancho - 54, altoFila);
  }
  popStyle();
}

/**
 * La franja de abajo con los atajos de teclado y los botones
 */
void dibujarPie() {
  float y = height - 70.0;

  actualizarGeometriaBotones(y);

  pushStyle();
  noStroke();
  fill(red(COLOR_FONDO_CLARO), green(COLOR_FONDO_CLARO), blue(COLOR_FONDO_CLARO), 235);
  rect(0, y, width, 70);
  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 100);
  strokeWeight(1);
  line(0, y, width, y);

  noStroke();
  aplicarFuente(fuenteCuerpo);
  textSize(11);
  fill(COLOR_TEXTO_SUAVE);
  textAlign(LEFT, TOP);
  text("G guardar · C limpiar", 28, y + 16);

  dibujarBoton(botonGuardar, "GUARDAR LOG", COLOR_NORMAL);
  dibujarBoton(botonLimpiar, "LIMPIAR LOG", COLOR_BAJO);
  popStyle();
}

/**
 * Dibujo un boton usando el Rect del modelo
 * Si el mouse esta encima subo la transparencia para dar sensacion de resaltado
 */
void dibujarBoton(Rect area, String etiqueta, color tono) {
  boolean sobre = area.contiene(mouseX, mouseY);
  int alfa = sobre ? 85 : 42;

  pushStyle();
  noStroke();
  fill(red(tono), green(tono), blue(tono), alfa);
  rect(area.x, area.y, area.ancho, area.alto, 8);
  stroke(red(tono), green(tono), blue(tono), 165);
  strokeWeight(1);
  noFill();
  rect(area.x, area.y, area.ancho, area.alto, 8);

  noStroke();
  fill(COLOR_TEXTO);
  aplicarFuente(fuenteCuerpo);
  textSize(11);
  textAlign(CENTER, CENTER);
  text(etiqueta, area.x + area.ancho / 2.0, area.y + area.alto / 2.0);
  popStyle();
}

/**
 * Cada estado tiene un color distinto para reconocerlo de un vistazo
 */
color colorNivel(int nivel) {
  if (nivel == NIVEL_CRITICO) {
    return COLOR_CRITICO;
  }
  if (nivel == NIVEL_BAJO) {
    return COLOR_BAJO;
  }
  return COLOR_NORMAL;
}

/**
 * Devuelvo una flecha segun el valor este debajo o encima del rango normal
 * Si esta bien, devuelvo un texto vacio para que no se vea nada
 */
String simboloDireccion(int direccion) {
  if (direccion < 0) {
    return " ↓";
  }
  if (direccion > 0) {
    return " ↑";
  }
  return "";
}

// Creo un color con otro valor alfa, util para sombras y bordes suaves
color conTransparencia(color tono, int alfa) {
  return color(red(tono), green(tono), blue(tono), alfa);
}
