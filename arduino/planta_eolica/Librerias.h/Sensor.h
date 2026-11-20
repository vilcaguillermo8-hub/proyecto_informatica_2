#ifndef SENSOR_H
#define SENSOR_H
#include <Arduino.h>

// ===== Clase base =====
class Sensor {
  public:
    float valor;
    String magnitud;
    String unidad;
    int pin;

    Sensor();
    float generarMedicion();
    void mostrar();
};

// ===== Hija: sensor de tensión =====
class SensorTension : public Sensor {
  public:
    SensorTension(int p);
    float leerMedicion();
};

// ===== Hija: sensor de corriente =====
class SensorCorriente : public Sensor {
  public:
    SensorCorriente(int p);
    float leerMedicion();
};

#endif