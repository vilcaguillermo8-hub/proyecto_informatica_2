#include "Aerogenerador.h"

Aerogenerador::Aerogenerador() {
    velocidadViento = 0;
    direccionViento = 0;
    direccionTurbina = 0;
    potenciaGenerada = 0;
    tensionSalida = 12;   // valor nominal por defecto
    corrienteSalida = 0;
    radioRotor = 0.25;    // Radio por defecto ajustado a 0.25m[cite: 7]
    estado = 0;
}

Aerogenerador::Aerogenerador(float radio, float tension) {
    velocidadViento = 0;
    direccionViento = 0;
    direccionTurbina = 0;
    potenciaGenerada = 0;
    tensionSalida = tension;
    corrienteSalida = 0;
    radioRotor = radio;
    estado = 0;
}

void Aerogenerador::medirViento(float vel, float dir) {
    velocidadViento = vel;
    direccionViento = dir;
}

void Aerogenerador::orientarTurbina() {
    direccionTurbina = direccionViento;
}

float Aerogenerador::calcularPotencia() {
    if (estado == 0) {
        potenciaGenerada = 0;
        corrienteSalida = 0;
        return 0;
    }
    
    const float DENSIDAD_AIRE = 1.225; // Densidad del aire en kg/m3[cite: 7]
    const float LIMITE_BETZ = 0.59;    // Límite de máxima eficiencia teórica[cite: 7]
    const float PI_ = 3.14159;
    
    // Área barrida por las palas[cite: 7]
    float area = PI_ * radioRotor * radioRotor; 
    
    // Potencia máxima extraída (en Watts)[cite: 7]
    potenciaGenerada = 0.5 * LIMITE_BETZ * DENSIDAD_AIRE * area * (velocidadViento * velocidadViento * velocidadViento);
    
    corrienteSalida = potenciaGenerada / tensionSalida;
    return potenciaGenerada;
}

void Aerogenerador::encendido() { 
    estado = 1; 
}

void Aerogenerador::apagado() { 
    estado = 0; 
}

void Aerogenerador::mostrar() {
    if (estado == 1) {
        Serial.println("Estado: ON");
    } else {
        Serial.println("Estado: OFF");
    }
    
    Serial.print("Viento: "); Serial.print(velocidadViento); Serial.print(" m/s a "); Serial.print(direccionViento); Serial.println(" grados");
    Serial.print("Turbina orientada a: "); Serial.print(direccionTurbina); Serial.println(" grados");
    Serial.print("Potencia: "); Serial.print(potenciaGenerada); Serial.println(" W");
    Serial.print("Tension: "); Serial.print(tensionSalida); Serial.print(" V, Corriente: "); Serial.print(corrienteSalida); Serial.println(" A");
    Serial.println("-----------------------");
}