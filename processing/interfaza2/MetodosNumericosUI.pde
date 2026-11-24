/**
 * MetodosNumericosUI.pde
 * Aca dibujo solo el grafico del estado general con el resultado de Euler
 * Escribo el titulo y las etiquetas de nivel, pero no formula ni numeros
 */

/**
 * Dibujo el panel del grafico con su titulo
 * Ocupa todo el lugar que dejo la bitacora reducida y el cuadro de estado quitado
 */
void dibujarPanelEstadoEuler(float x, float y, float ancho, float alto,
                             GraficoEstadoEuler grafico) {
  if (grafico == null || alto < 60.0) {
    return;
  }

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
  text("ESTADO GENERAL POR EULER", x + 18.0, y + 14.0);

  dibujarGraficoEstado(x + 10.0, y + 40.0, ancho - 20.0, alto - 50.0,
                       grafico);
  popStyle();
}

/**
 * Dibujo tres franjas horizontales para reconocer cada nivel de un vistazo
 * Arriba queda CRITICO, en el medio NORMAL y abajo BAJO
 * La linea se pinta con el color del nivel guardado en cada muestra
 */
void dibujarGraficoEstado(float x, float y, float ancho, float alto,
                          GraficoEstadoEuler grafico) {
  pushStyle();
  noStroke();
  fill(red(COLOR_FONDO), green(COLOR_FONDO), blue(COLOR_FONDO), 170);
  rect(x, y, ancho, alto, 10);

  float tercio = alto / 3.0;

  noStroke();
  fill(red(COLOR_CRITICO), green(COLOR_CRITICO), blue(COLOR_CRITICO), 26);
  rect(x + 1.0, y + 1.0, ancho - 2.0, tercio - 1.0);
  fill(red(COLOR_NORMAL), green(COLOR_NORMAL), blue(COLOR_NORMAL), 26);
  rect(x + 1.0, y + tercio, ancho - 2.0, tercio);
  fill(red(COLOR_BAJO), green(COLOR_BAJO), blue(COLOR_BAJO), 26);
  rect(x + 1.0, y + 2.0 * tercio, ancho - 2.0, tercio - 1.0);

  stroke(red(COLOR_BORDE), green(COLOR_BORDE), blue(COLOR_BORDE), 80);
  strokeWeight(1);
  line(x, y + tercio, x + ancho, y + tercio);
  line(x, y + 2.0 * tercio, x + ancho, y + 2.0 * tercio);
  for (int i = 1; i < 4; i++) {
    float lineaX = x + ancho * i / 4.0;
    line(lineaX, y, lineaX, y + alto);
  }

  aplicarFuente(fuenteCuerpo);
  textSize(9);
  textAlign(LEFT, CENTER);
  noStroke();
  fill(red(COLOR_CRITICO), green(COLOR_CRITICO), blue(COLOR_CRITICO), 220);
  text("CRITICO", x + 8.0, y + tercio * 0.5);
  fill(red(COLOR_NORMAL), green(COLOR_NORMAL), blue(COLOR_NORMAL), 230);
  text("NORMAL", x + 8.0, y + tercio * 1.5);
  fill(red(COLOR_BAJO), green(COLOR_BAJO), blue(COLOR_BAJO), 220);
  text("BAJO", x + 8.0, y + tercio * 2.5);

  if (grafico.cantidad < 2) {
    popStyle();
    return;
  }

  float pasoX = ancho / (float) max(1, grafico.valores.length - 1);
  for (int i = 1; i < grafico.cantidad; i++) {
    color tono = colorNivel(grafico.niveles[i]);
    stroke(red(tono), green(tono), blue(tono), 225);
    strokeWeight(2);
    line(x + (i - 1) * pasoX, mapearYEstado(grafico.valores[i - 1], y, alto),
         x + i * pasoX, mapearYEstado(grafico.valores[i], y, alto));
  }

  int ultimo = grafico.cantidad - 1;
  float ultimoX = x + ultimo * pasoX;
  float ultimoY = mapearYEstado(grafico.valores[ultimo], y, alto);
  noStroke();
  fill(colorNivel(grafico.niveles[ultimo]));
  ellipse(ultimoX, ultimoY, 8, 8);
  popStyle();
}

/**
 * Pasa un valor de 0 a 2 a una altura del grafico
 * El 0 queda abajo y el 2 arriba del todo
 */
float mapearYEstado(float valor, float y, float alto) {
  float v = constrain(valor, 0.0, 2.0);
  return y + alto - v * 0.5 * alto;
}
