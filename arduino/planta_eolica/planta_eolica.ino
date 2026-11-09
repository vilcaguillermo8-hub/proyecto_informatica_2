#include "Sensor_h"

SensorTension sTension(A0);
SensorCorriente sCorriente(A1);
float energiaWh = 0;

  void setup() {
    Serial.begin(9600);
    Serial.println("Monitor del aerogenerador");
  }

  void loop() {
    sTension.leerMedicion();
    sCorriente.leerMedicion();

    float p = sTension.valor * sCorriente.valor; //Potencia en W
    energiaWh = energiaWh + p / 3600.0;

    sTension.mostrar();
    sCorriente.mostrar();
    Serial.print("Potencia: ");
    Serial.print(p, 2);
    Serial.println(" W");
    Serial.print("Energia acumulada: ");
    Serial.print(energiaWh, 3);
    Serial.println(" Wh");

    if (sTension.valor < 3.0) {
      Serial.println("Estado: viento insuficiente, no carga");
    } else if (sTension.valor > 20.0) {
      Serial.println("Estado: sobretension, proteger sistema");
    } else {
      Serial.println("Estado: generando y cargando");
    }
    Serial.println("--------------------");

    delay(1000);
  }