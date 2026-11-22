#include "Sensor.h"

// --- Implementación Sensor Base ---
Sensor::Sensor() {
  valor = 0;
}

float Sensor::generarMedicion() {
  valor = random(0, 100);
  return valor;
}

void Sensor::mostrar() {
  Serial.print(magnitud);
  Serial.print(": ");
  Serial.print(valor, 2);
  Serial.print(" ");
  Serial.println(unidad);
}

// --- Implementación SensorTension ---
SensorTension::SensorTension(int p) {
  pin = p;
  magnitud = "Tension";
  unidad = "V";
}

float SensorTension::leerMedicion() {
  long suma = 0;
  for (int i = 0; i < 10; i++) {
    suma = suma + analogRead(pin);
    delay(2);
  }
  float adc = suma / 10.0;
  valor = (adc * 5.0 / 1023.0) * 5.0;   // módulo FZ0430: divide por 5
  return valor;
}

// --- Implementación SensorCorriente ---
SensorCorriente::SensorCorriente(int p) {
  pin = p;
  magnitud = "Corriente";
  unidad = "A";
}

float SensorCorriente::leerMedicion() {
  long suma = 0;
  for (int i = 0; i < 10; i++) {
    suma = suma + analogRead(pin);
    delay(2);
  }
  float vOut = (suma / 10.0) * 5.0 / 1023.0;
  valor = (vOut - 2.5) / 0.185;          // ACS712-5A: 2.5 V = 0 A, 185 mV/A
  if (valor < 0) valor = -valor;
  if (valor < 0.05) valor = 0;
  return valor;
}