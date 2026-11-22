/*

 Implementacion de SensorTension y SensorViento (declaradas en Sensores.h).
 La clase SensorAmbiente (DHT22/DHT11) esta en SensorAmbiente.cpp.
 
 Cada sensor SOLO lee un pin y devuelve un numero: no imprime, no decide, no
 espera. Los pines y constantes los recibe de Config.h a traves del .ino.
 */

#include <Arduino.h>
#include "Sensores.h"
#include "Config.h"       // REFERENCIA_ADC_V

// Cuantas lecturas se promedian. El conversor analogico tiene algo de ruido: una
// sola lectura puede saltar unas unidades, el promedio de varias queda estable.
// Las diez lecturas llevan ~1 ms en total, asi que no hace falta ningun delay().
static const int MUESTRAS_PROMEDIO = 10;

// Valor maximo del conversor analogico del UNO: 10 bits, de 0 a 1023.
static const float ADC_MAXIMO = 1023.0;

/*
  Lee un pin analogico varias veces y devuelve el promedio.
  param pin  pin analogico (A0, A1...).
  return valor promedio del conversor, de 0 a 1023.
 */
static float leerPromedio(int pin) {
  long suma = 0;   // long: la suma de 10 lecturas (hasta 10230) no entra en un int de 16 bits con signo

  for (int i = 0; i < MUESTRAS_PROMEDIO; i++) {
    suma += analogRead(pin);
  }

  return (float) suma / MUESTRAS_PROMEDIO;
}

// SensorTension
SensorTension::SensorTension(int pin, float factorDivisor) {
  _pin = pin;
  _factorDivisor = factorDivisor;
}

// El pin ve una fraccion de la tension real (la del divisor); se la multiplica
// por el factor para recuperar la tension verdadera del generador:
//     tension real = (lectura / 1023 * 5 V) * factorDivisor
float SensorTension::leerVoltios() {
  float tensionEnPin = leerPromedio(_pin) / ADC_MAXIMO * REFERENCIA_ADC_V;

  return tensionEnPin * _factorDivisor;
}

// SensorViento (simulado con un potenciometro)
SensorViento::SensorViento(int pin, float maximoMs) {
  _pin = pin;
  _maximoMs = maximoMs;
}

// El potenciometro entrega de 0 a 1023: se lo escala al rango 0 .. maximoMs.
float SensorViento::leerMetrosPorSegundo() {
  return leerPromedio(_pin) / ADC_MAXIMO * _maximoMs;
}
