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
const int TIPO_DHT = 22;                          // 22 = DHT22 o 11 si = DHT11
const unsigned long PERIODO_LECTURA_DHT_MS = 2000UL;  //El DHT11 admite 1s
const unsigned long PERIODO_ENERGIA_MS = 1000UL;  //Periodo de 1s entre cada medicion de energia

// ------ Comunicacion serie ------ 
const long BAUDIOS_SERIE = 9600L; //Como en processing
const unsigned long PERIODO_ENVIO_MS = 1000UL; //Una trama por segundo

// ------ Distribucion Electrica ------ 
const float REFERENCIA_ADC_V     = 5.0;           // tension de referencia del conversor
const float RESISTENCIA_ALTA_OHM = 10000.0;       // R1 del divisor (hacia el positivo)
const float RESISTENCIA_BAJA_OHM = 10000.0;       // R2 del divisor (hacia GND)
// Factor para volver de la tension del pin a la tension real: (R1 + R2) / R2 = 2.
const float FACTOR_DIVISOR =
    (RESISTENCIA_ALTA_OHM + RESISTENCIA_BAJA_OHM) / RESISTENCIA_BAJA_OHM;
const float RESISTENCIA_CARGA_OHM = 100.0;        // carga conocida: la corriente se CALCULA

// ------ Viento simulado ------
const float VIENTO_MAX_MS = 28.0;                 // el potenciometro va de 0 a este valor

// ------ Datos del rotor (provisorios) ------
// Se usan solo para la potencia teorica. Valores del TFG de referencia: ajustar
// cuando se conozcan las medidas reales del rotor.
const float RADIO_ROTOR_M       = 0.25;
const float COEFICIENTE_BETZ    = 0.59;
const float DENSIDAD_AIRE_KGM3  = 1.225;          // aire a 15 grados y nivel del mar

// ------ Umbrales de la maquina de estados ------
// PROVISORIOS: se calibran con el circuito armado.
const float TENSION_MINIMA_V      = 0.5;    // por debajo: ESPERA
const float TENSION_DERIVACION_V  = 4.0;    // desde aca: DERIVACION (sobra energia)
const float TENSION_MAXIMA_V      = 8.0;    // desde aca: PROTECCION (A0 llega hasta 10 V)
const float TEMPERATURA_CRITICA_C = 50.0;   // desde aca: PROTECCION
const float HISTERESIS_V          = 0.2;    // margen para que el estado no parpadee
const float HISTERESIS_TEMP_C = 2.0;   // margen en grados para salir de PROTECCION por temperatura

#endif