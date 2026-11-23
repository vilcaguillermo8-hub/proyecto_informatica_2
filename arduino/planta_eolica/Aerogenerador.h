/*
 * CONTRATO de la clase Aerogenerador (la logica va en Aerogenerador.cpp).
 *
 * Responsabilidad: guardar las mediciones del generador y CALCULAR a partir de
 * ellas. No lee pines: recibe los valores ya medidos. Asi se puede probar sin
 * hardware, pasandole numeros de ejemplo.
 *
 * Formulas (la corriente no se mide, se calcula con la carga conocida):
 *     corriente [mA] = tension / resistenciaCarga * 1000
 *     potencia  [mW] = tension^2 / resistenciaCarga * 1000
 *
 * La ENERGIA es la potencia acumulada en el tiempo (el area bajo la curva de
 * potencia). Cada vez que pasa un intervalo corto se suma:
 *     energia [mWh] += potencia [mW] * intervalo [ms] / 3 600 000
 * (3 600 000 = milisegundos que tiene una hora).
 */

#ifndef AEROGENERADOR_H
#define AEROGENERADOR_H

class Aerogenerador {
  public:
    /*
     param resistenciaCargaOhm  valor de la carga conectada al generador (ohm).
                                  Precondicion: mayor que 0.
     */
    Aerogenerador(float resistenciaCargaOhm);

    /**
     * Guarda las nuevas mediciones y recalcula corriente y potencia.
     * @param tensionV  tension generada, en voltios.
     * @param vientoMs  velocidad del viento, en m/s.
     */
    void actualizar(float tensionV, float vientoMs);

    /** @return ultima tension guardada, en V. */
    float obtenerTension();

    /** @return corriente calculada (V / R), en mA. */
    float obtenerCorriente();

    /** @return potencia entregada a la carga (V^2 / R), en mW. */
    float obtenerPotencia();

    /*return ultimo viento guardado, en m/s. */
    float obtenerViento();

    /*
      Potencia que el viento podria entregar como maximo (limite de Betz):
          P = 0.5 * Betz * densidad * area * viento^3
     param densidadAireKgm3  densidad del aire en kg/m3 (1.225 si no hay BMP180).
     return potencia teorica en mW.
     */
    float potenciaTeoricaMw(float densidadAireKgm3);

    /*
      Suma a la energia acumulada lo entregado en el ultimo intervalo, usando
      la potencia calculada en la ultima llamada a actualizar().
      Hay que llamarla a intervalos regulares (ver PERIODO_ENERGIA_MS).
     param intervaloMs  milisegundos transcurridos desde la llamada anterior.
     */
    void acumularEnergia(unsigned long intervaloMs);

    /*return energia total entregada a la carga desde el inicio (o el ultimo reset), en mWh. */
    float obtenerEnergia();

    /* Pone la energia acumulada en cero (la usa CMD:RESET). */
    void reiniciarEnergia();

  private:
    float _resistenciaCargaOhm;
    float _tensionV;
    float _vientoMs;
    float _corrienteMa;
    float _potenciaMw;
    float _energiaMwh;   // acumulada: crece con el tiempo, no se recalcula
};

#endif
