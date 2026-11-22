/* 
Config.h --> Pines, constantes y umbrales de TODA la planta
Esta es una configuracion inicial, la idea es ir mejorando lo que hagamos
*/
#ifndef CONFIG_H // Guardado de la configutacion de pines
#define CONFIG_H 

#include <Arduino.h>  // define A0, A1 y las demas tipos de Arduino

// ------ Pines ------ 
const int PIN_TENSION       = A0;   // punto medio del divisor 10k/10k (tension generada)
const int PIN_VIENTO        = A1;   // cursor del potenciometro (viento simulado)
const int PIN_DHT           = 2;    // DATA del DHT22 (sensor DIGITAL, no analogico)
const int PIN_LED_VERDE     = 8;    // estado GENERANDO
const int PIN_LED_AMARILLO  = 9;    // estado DERIVACION
const int PIN_LED_ROJO      = 10;   // estado PROTECCION

// ------ Sensor de Ambiente ------ 
const int TIPO_DHT = 22;                          // 22 = DHT22 
const unsigned long PERIODO_LECTURA_DHT_MS = 2000UL;  