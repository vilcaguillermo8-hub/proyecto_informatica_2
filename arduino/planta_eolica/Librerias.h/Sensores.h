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

// ---- SensorTension ----
// Mide la tension generada a traves del divisor de tension.
class SensorTension {
  public:
  /*
  param pin                 pin analogico donde llega el punto medio del divisor
  param factorDivisor       (R1 + R2) / R2, para volver a la tension real.
  */
  SensorTension(int pin, float factorDivisor);

    /*
      Lee el pin y devuelve la tension real del generador.
      return tension en voltios (0 a 10 V con el divisor 10k/10k).
     */
    float leerVoltios();

  private:
    int _pin;              // el guion bajo marca los datos internos de la clase
    float _factorDivisor;
};
// ---- SensorViento ----
// Viento SIMULADO con un potenciometro (leugo puede ser un modulo de anemometro real)
class SensorViento {
  public:
    /*
     param pin        pin analogico del cursor del potenciometro.
     param maximoMs   viento que corresponde al tope del potenciometro (m/s).
     */
    SensorViento(int pin, float maximoMs);

    /*
     return velocidad del viento en m/s, de 0 a `maximoMs`.
     */
    float leerMetrosPorSegundo();

  private:
    int _pin;
    float _maximoMs;
};
#endif