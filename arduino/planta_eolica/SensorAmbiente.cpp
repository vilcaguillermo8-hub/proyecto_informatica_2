/**
 * SensorAmbiente.cpp
 * ------------------------------------------------------------------------------
 * Implementacion de SensorAmbiente (declarada en Sensores.h): temperatura y
 * humedad con un sensor DHT22 o DHT11 (el tipo se elige en Config.h).
 *
 * Hace UNA sola cosa: leer el sensor y guardar el ultimo valor valido. No
 * imprime nada por serie y no decide nada: de eso se encargan otros modulos.
 *
 * Libreria necesaria: "DHT sensor library" (Adafruit) + "Adafruit Unified Sensor".
 */

#include <Arduino.h>
#include <DHT.h>          // se incluye SOLO aca (en Sensores.h hay una declaracion adelantada)
#include "Sensores.h"
#include "Config.h"       // PERIODO_LECTURA_DHT_MS

// ---------- Rangos para dar por buena una lectura ----------
// Son los limites del DHT22 (el DHT11 mide menos rango, pero entra en estos).
// Una lectura fuera de rango se descarta como si hubiera fallado.
static const float TEMP_MIN_VALIDA_C = -40.0;
static const float TEMP_MAX_VALIDA_C = 80.0;
static const float HUM_MIN_VALIDA_PCT = 0.0;
static const float HUM_MAX_VALIDA_PCT = 100.0;

// ------------------------------------------------------------------------------
// Constructor: SOLO guarda datos. No toca el hardware (ver iniciar()).
// ------------------------------------------------------------------------------
SensorAmbiente::SensorAmbiente(int pin, int tipo) {
  _pin = pin;
  _tipo = tipo;
  _humedad = 0.0;
  _temperatura = 0.0;
  _presion = 0.0;            // no usamos BMP180: la presion queda siempre en 0
  _valido = false;           // todavia no hubo ninguna lectura
  _ultimaLecturaMs = 0;
  _dht = NULL;               // el objeto de la libreria se crea en iniciar()
}

// ------------------------------------------------------------------------------
// iniciar(): se llama UNA vez desde setup().
// ------------------------------------------------------------------------------
void SensorAmbiente::iniciar() {
  if (_dht == NULL) {                              // evita crearlo dos veces
    _dht = new DHT((uint8_t)_pin, (uint8_t)_tipo);
  }
  _dht->begin();

  // El DHT necesita ~2 s despues de energizarse antes de la primera lectura.
  // Marcamos "ahora" como la ultima lectura: la primera real ocurre 2 s despues.
  _ultimaLecturaMs = millis();
}

// ------------------------------------------------------------------------------
// actualizar(): se llama en CADA vuelta de loop(). No bloquea.
// ------------------------------------------------------------------------------
void SensorAmbiente::actualizar() {
  if (_dht == NULL) return;                        // por si se olvidaron de iniciar()

  // Restar los dos millis() funciona bien aunque millis() desborde (a los ~50 dias).
  unsigned long ahora = millis();
  if (ahora - _ultimaLecturaMs < PERIODO_LECTURA_DHT_MS) return;
  _ultimaLecturaMs = ahora;

  // Las dos llamadas hacen UNA sola lectura fisica: la libreria guarda el
  // resultado y la segunda llamada reutiliza el de la primera.
  float h = _dht->readHumidity();
  float t = _dht->readTemperature();               // en grados Celsius

  bool humedadOk = !isnan(h) && h >= HUM_MIN_VALIDA_PCT && h <= HUM_MAX_VALIDA_PCT;
  bool temperaturaOk = !isnan(t) && t >= TEMP_MIN_VALIDA_C && t <= TEMP_MAX_VALIDA_C;

  _valido = humedadOk && temperaturaOk;

  // Solo se pisan los valores guardados si la lectura completa fue buena.
  // Si fallo, se conservan los anteriores (asi nunca se envia un "nan").
  if (_valido) {
    _humedad = h;
    _temperatura = t;
  }
}

// ------------------------------------------------------------------------------
// Getters: solo devuelven lo guardado, no leen el sensor.
// ------------------------------------------------------------------------------
float SensorAmbiente::obtenerHumedad()     { return _humedad; }
float SensorAmbiente::obtenerTemperatura() { return _temperatura; }
float SensorAmbiente::obtenerPresion()     { return _presion; }
bool  SensorAmbiente::datoValido()         { return _valido; }
