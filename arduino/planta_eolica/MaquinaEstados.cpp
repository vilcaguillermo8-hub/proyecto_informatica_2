/*
 
  Implementacion de la maquina de estados (declarada en MaquinaEstados.h).
 
  Idea central: el estado nuevo depende de DOS cosas, las entradas (tension y
  temperatura) y el estado en que ya estaba. Para que el estado no parpadee
  cuando la tension oscila justo en un limite, se usa HISTERESIS: para SUBIR a
  un estado se pide llegar al umbral, pero para BAJAR se pide pasarse un margen.
 
      Ejemplo con umbral de derivacion = 4.0 V y margen = 0.2 V:
          sube a DERIVACION al llegar a 4.0 V
          vuelve a GENERANDO recien por debajo de 3.8 V
      Una tension que fluctua entre 3.9 y 4.1 V ya no hace saltar el LED.
 */

#include <Arduino.h>
#include "MaquinaEstados.h"
#include "Config.h"

// Funciones auxiliares internas. `static` = solo se pueden usar dentro de este
// archivo (no forman parte del contrato publico de la clase).

/*
  Estado que corresponde a una tension SIN mirar el estado anterior (sin
  histeresis). Se usa cuando se SALE de PROTECCION o se SUBE desde ESPERA.
 */
static EstadoPlanta estadoSegunTension(float tensionV, float umbralDerivacionV) {
  if (tensionV >= umbralDerivacionV) {
    return ESTADO_DERIVACION;
  }
  if (tensionV >= TENSION_MINIMA_V) {
    return ESTADO_GENERANDO;
  }
  return ESTADO_ESPERA;
}

/*
  Enciende el LED del estado actual y apaga los otros dos.
  ESPERA no tiene LED : quedan los tres apagados.
 */
static void mostrarEstado(EstadoPlanta estado, int pinVerde, int pinAmarillo, int pinRojo) {
  digitalWrite(pinVerde,    estado == ESTADO_GENERANDO  ? HIGH : LOW); //El ? forma parte del operador ternario, que es una forma corta de escribir un if-else.
  digitalWrite(pinAmarillo, estado == ESTADO_DERIVACION ? HIGH : LOW);
  digitalWrite(pinRojo,     estado == ESTADO_PROTECCION ? HIGH : LOW);
}

// Constructor: solo guarda datos (no toca el hardware, ver iniciar()).
MaquinaEstados::MaquinaEstados(int pinVerde, int pinAmarillo, int pinRojo) {
  _pinVerde = pinVerde;
  _pinAmarillo = pinAmarillo;
  _pinRojo = pinRojo;
  _estado = ESTADO_ESPERA;
  _umbralDerivacionV = TENSION_DERIVACION_V;
}

// iniciar(): se llama UNA vez desde setup().
void MaquinaEstados::iniciar() {
  pinMode(_pinVerde, OUTPUT);
  pinMode(_pinAmarillo, OUTPUT);
  pinMode(_pinRojo, OUTPUT);

  _estado = ESTADO_ESPERA;
  mostrarEstado(_estado, _pinVerde, _pinAmarillo, _pinRojo);   // todos apagados
}

// actualizar(): decide el estado. Se llama en cada vuelta de loop().
void MaquinaEstados::actualizar(float tensionV, float temperaturaC) {
  // Condicion de peligro: tiene prioridad sobre todo lo demas, desde cualquier estado.
  bool hayPeligro = (tensionV >= TENSION_MAXIMA_V) || (temperaturaC >= TEMPERATURA_CRITICA_C);

  if (_estado == ESTADO_PROTECCION) {
    // Para SALIR de PROTECCION no alcanza con bajar del limite: hay que bajar
    // un margen (histeresis) en la tension Y en la temperatura.
    bool tensionSegura     = tensionV < (TENSION_MAXIMA_V - HISTERESIS_V);
    bool temperaturaSegura = temperaturaC < (TEMPERATURA_CRITICA_C - HISTERESIS_TEMP_C);

    if (tensionSegura && temperaturaSegura) {
      _estado = estadoSegunTension(tensionV, _umbralDerivacionV);
    }
  } else if (hayPeligro) {
    _estado = ESTADO_PROTECCION;
  } else {
    // Funcionamiento normal: segun el estado actual, se mira que condicion lo cambia.
    switch (_estado) {
      case ESTADO_ESPERA:
        // Para subir se usan los umbrales directos (puede saltar hasta DERIVACION).
        _estado = estadoSegunTension(tensionV, _umbralDerivacionV);
        break;

      case ESTADO_GENERANDO:
        if (tensionV >= _umbralDerivacionV) {
          _estado = ESTADO_DERIVACION;
        } else if (tensionV < (TENSION_MINIMA_V - HISTERESIS_V)) {
          _estado = ESTADO_ESPERA;
        }
        break;

      case ESTADO_DERIVACION:
        if (tensionV < (_umbralDerivacionV - HISTERESIS_V)) {
          // Si ademas cayo por debajo del minimo, se va directo a ESPERA.
          _estado = (tensionV < (TENSION_MINIMA_V - HISTERESIS_V)) ? ESTADO_ESPERA
                                                                   : ESTADO_GENERANDO;
        }
        break;

      case ESTADO_PROTECCION:
        break;   // ya tratado arriba; el caso se lista para que el switch cubra todos los estados
    }
  }

  mostrarEstado(_estado, _pinVerde, _pinAmarillo, _pinRojo);
}

EstadoPlanta MaquinaEstados::obtenerEstado() {
  return _estado;
}

// establecerUmbralDerivacion(): atiende CMD:UMBRAL desde Processing.
bool MaquinaEstados::establecerUmbralDerivacion(float tensionV) {
  // Se escribe como "!(esta dentro)" y no como "esta fuera" para que tambien
  // rechace un NaN (cualquier comparacion con NaN da falso).
  if (!(tensionV > TENSION_MINIMA_V && tensionV < TENSION_MAXIMA_V)) {
    return false;
  }

  _umbralDerivacionV = tensionV;
  return true;
}

// reiniciar(): atiende CMD:RESET desde Processing.
void MaquinaEstados::reiniciar() {
  _estado = ESTADO_ESPERA;
  _umbralDerivacionV = TENSION_DERIVACION_V;
  mostrarEstado(_estado, _pinVerde, _pinAmarillo, _pinRojo);
}
