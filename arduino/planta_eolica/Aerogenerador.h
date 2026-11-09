#ifndef AEROGENERADOR_H
#define AEROGENERADOR_H
#include <Arduino.h>

class Aerogenerador {
  private:
    float velocidadViento;     // m/s
    float direccionViento;     // grados
    float direccionTurbina;    // grados 
    float potenciaGenerada;    // W (o mW)
    float tensionSalida;       // V
    float corrienteSalida;     // A
    float radioRotor;          // m (dato fijo del aero)
    int estado;                // 0 = apagado, 1 = encendido
    
  public:
    Aerogenerador();                                  // constructor por defecto
    Aerogenerador(float radio, float tension);        // constructor parametrizado
    
    void medirViento(float vel, float dir);
    void orientarTurbina();
    float calcularPotencia();
    void encendido();
    void apagado();
    void mostrar();
};

#endif