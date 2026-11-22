/*
 Implementacion de la comunicacion con Processing (declarada en
 ComunicacionSerie.h): envia la trama de datos y lee las ordenes.

 Todo el texto se arma con un arreglo fijo de caracteres y Serial.print, sin
 la clase String (en el UNO fragmenta los 2 KB de RAM).
 */

#include <Arduino.h>
#include <stdlib.h>       // strtod: convierte texto a numero y avisa si no pudo
#include <string.h>       // strncmp, strcmp
#include "ComunicacionSerie.h"

// Interpretacion de una linea recibida (funcion interna de este archivo).

// Textos de las ordenes. `static const` = constantes que solo usa este archivo.
static const char TEXTO_UMBRAL[] = "CMD:UMBRAL=";
static const char TEXTO_RESET[]  = "CMD:RESET";

/*
Traduce una linea de texto a una Orden.
param linea  texto terminado en '\0' (sin el salto de linea).
param orden  se completa si la linea es una orden valida.
return true si la linea era una orden valida; false si no (se ignora).
 */
static bool interpretarLinea(const char *linea, Orden &orden) {
  // "CMD:UMBRAL=<voltios>"
  size_t largoTexto = strlen(TEXTO_UMBRAL);
  if (strncmp(linea, TEXTO_UMBRAL, largoTexto) == 0) {
    const char *inicioNumero = linea + largoTexto;   // aritmetica de punteros: salta el texto
    char *finNumero;                                 // strtod deja aca donde dejo de leer

    float valor = (float) strtod(inicioNumero, &finNumero);

    // Si no leyo ningun caracter (por ejemplo "CMD:UMBRAL=abc") el numero no es valido.
    if (finNumero == inicioNumero) {
      return false;
    }

    orden.tipo = ORDEN_UMBRAL;
    orden.valor = valor;
    return true;
  }

  // "CMD:RESET" (debe coincidir exactamente)
  if (strcmp(linea, TEXTO_RESET) == 0) {
    orden.tipo = ORDEN_RESET;
    orden.valor = 0.0;
    return true;
  }

  return false;   // cualquier otra cosa se descarta
}

// Constructor: solo guarda datos.
ComunicacionSerie::ComunicacionSerie(long baudios) {
  _baudios = baudios;
  _largo = 0;
  _linea[0] = '\0';
}

// iniciar(): abre el puerto. Se llama UNA vez desde setup().
void ComunicacionSerie::iniciar() {
  Serial.begin(_baudios);
}

// enviarTrama(): escribe la linea de datos, por ejemplo
//     HUM:48;VTO:8.5;POT:250;TMP:24;V:5.0;I:50;EST:1;ENE:4.17
// Serial.print(valor, n) imprime el numero con n decimales.
// F("...") deja el texto en la memoria de programa (flash) y no en la RAM.
void ComunicacionSerie::enviarTrama(const Medicion &medicion) {
  Serial.print(F("HUM:"));
  Serial.print(medicion.humedad, 0);
  Serial.print(F(";VTO:"));
  Serial.print(medicion.viento, 1);
  Serial.print(F(";POT:"));
  Serial.print(medicion.potenciaMw, 0);
  Serial.print(F(";TMP:"));
  Serial.print(medicion.temperatura, 0);
  Serial.print(F(";V:"));
  Serial.print(medicion.tensionV, 1);
  Serial.print(F(";I:"));
  Serial.print(medicion.corrienteMa, 0);
  Serial.print(F(";EST:"));
  Serial.print(medicion.estado);
  Serial.print(F(";ENE:"));
  Serial.print(medicion.energiaMwh, 2);
  Serial.println();                       // el salto de linea marca el fin de la trama
}

// leerOrden(): lee caracter por caracter lo que haya llegado y, al completarse
// una linea, la interpreta. Nunca espera: si no hay nada, devuelve false.
bool ComunicacionSerie::leerOrden(Orden &orden) {
  while (Serial.available() > 0) {
    char c = (char) Serial.read();

    if (c == '\r') {
      continue;                           // Windows agrega '\r' antes del '\n': se ignora
    }

    if (c == '\n') {                      // fin de linea: ya se puede interpretar
      int largoRecibido = _largo;
      _largo = 0;                         // se deja listo para la proxima linea

      // Una linea vacia (0) o demasiado larga (TAMANO_LINEA) no sirve y se descarta.
      if (largoRecibido > 0 && largoRecibido < TAMANO_LINEA) {
        _linea[largoRecibido] = '\0';     // cierra el texto, como exige el lenguaje C
        if (interpretarLinea(_linea, orden)) {
          return true;                    // orden valida; lo que falte queda para la proxima llamada
        }
      }
      continue;                           // linea invalida: se sigue leyendo
    }

    if (_largo < TAMANO_LINEA - 1) {
      _linea[_largo] = c;                 // se guarda el caracter
      _largo++;
    } else {
      _largo = TAMANO_LINEA;              // no entra: se marca "linea demasiado larga" y se descarta entera
    }
  }

  return false;
}
