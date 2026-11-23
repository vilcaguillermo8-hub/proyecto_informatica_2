/**
 * Aerogenerador.cpp
 * ------------------------------------------------------------------------------
 * Implementacion de la clase Aerogenerador (declarada en Aerogenerador.h).
 *
 * No lee pines ni usa millis(): recibe tensiones y tiempos ya medidos y hace
 * cuentas. Por eso se puede probar en cualquier computadora sin el Arduino.
 */

#include <Arduino.h>      // para la constante PI
#include "Aerogenerador.h"
#include "Config.h"       // RADIO_ROTOR_M y COEFICIENTE_BETZ

// Milisegundos que tiene una hora: sirve para pasar (mW x ms) a mWh.
static const float MS_POR_HORA = 3600000.0;

// ------------------------------------------------------------------------------
// Constructor: guarda la carga y deja todas las magnitudes en cero.
// ------------------------------------------------------------------------------
Aerogenerador::Aerogenerador(float resistenciaCargaOhm) {
  // Una resistencia de 0 o negativa no tiene sentido fisico y dividiria por cero.
  // Se usa 1 ohm para que el programa no falle; el valor correcto va en Config.h.
  _resistenciaCargaOhm = (resistenciaCargaOhm > 0.0) ? resistenciaCargaOhm : 1.0;

  _tensionV = 0.0;
  _vientoMs = 0.0;
  _corrienteMa = 0.0;
  _potenciaMw = 0.0;
  _energiaMwh = 0.0;
}

// ------------------------------------------------------------------------------
// actualizar(): guarda lo medido y recalcula corriente y potencia.
// ------------------------------------------------------------------------------
void Aerogenerador::actualizar(float tensionV, float vientoMs) {
  _tensionV = tensionV;
  _vientoMs = vientoMs;

  // Ley de Ohm sobre la carga conocida: I = V / R  (se multiplica por 1000: A -> mA)
  _corrienteMa = tensionV / _resistenciaCargaOhm * 1000.0;

  // P = V^2 / R  (se multiplica por 1000: W -> mW)
  _potenciaMw = tensionV * tensionV / _resistenciaCargaOhm * 1000.0;
}

// ------------------------------------------------------------------------------
// Getters: solo devuelven lo guardado.
// ------------------------------------------------------------------------------
float Aerogenerador::obtenerTension()   { return _tensionV; }
float Aerogenerador::obtenerCorriente() { return _corrienteMa; }
float Aerogenerador::obtenerPotencia()  { return _potenciaMw; }
float Aerogenerador::obtenerViento()    { return _vientoMs; }

// ------------------------------------------------------------------------------
// potenciaTeoricaMw(): lo maximo que el viento podria dar (limite de Betz).
//     P = 0.5 * Cp * densidad * area * viento^3
// ------------------------------------------------------------------------------
float Aerogenerador::potenciaTeoricaMw(float densidadAireKgm3) {
  float area = PI * RADIO_ROTOR_M * RADIO_ROTOR_M;                 // area barrida por las palas (m2)
  float viento3 = _vientoMs * _vientoMs * _vientoMs;               // viento^3
  float potenciaW = 0.5 * COEFICIENTE_BETZ * densidadAireKgm3 * area * viento3;

  return potenciaW * 1000.0;                                       // W -> mW
}

// ------------------------------------------------------------------------------
// acumularEnergia(): energia = potencia x tiempo, sumada en cada intervalo.
// ------------------------------------------------------------------------------
void Aerogenerador::acumularEnergia(unsigned long intervaloMs) {
  // mW x ms / (ms en una hora) = mWh
  _energiaMwh += _potenciaMw * (float) intervaloMs / MS_POR_HORA;
}

float Aerogenerador::obtenerEnergia() {
  return _energiaMwh;
}

void Aerogenerador::reiniciarEnergia() {
  _energiaMwh = 0.0;
}
