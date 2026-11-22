/*
Aca van solo las declaracion de los sensores, la logica va en Sensores.cpp donde cada 
Sensor es una clase que SOLO lee y devuelve numeros, es decir, no sabe nada de estados, LEDs ni 
comunicacion

Distribucion: SensorTension y SensorViento (A0 y A1) y SensorAmbiente (DHT22).
*/
#ifndef SENSORES_H
#define SENSORES_H

class DHT;   // Declaracion adelantada: la libreria <DHT.h> se incluye SOLO en
             // Sensores.cpp, asi el .ino y los demas modulos no la necesitan.

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