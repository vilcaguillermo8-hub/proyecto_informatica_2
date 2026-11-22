/*
  Programa principal del Arduino UNO (equivale al main() de un programa en C).
 
  Responsabilidad UNICA: crear los objetos de cada modulo y coordinar el ciclo
      medir -> calcular -> decidir -> comunicar.
  No hace cuentas, no toca pines directamente ni arma texto: todo eso esta en
  los modulos (Sensores, Aerogenerador, MaquinaEstados, ComunicacionSerie).
 
  Archivos del proyecto (todos en esta misma carpeta):
    Config.h                    pines, constantes y umbrales
    Sensores.h / .cpp           lectura de tension, viento y ambiente
    Aerogenerador.h / .cpp      corriente y potencia
    MaquinaEstados.h / .cpp     estados y LEDs
    ComunicacionSerie.h / .cpp  trama hacia Processing y ordenes de vuelta
 */

// Las comillas indican "archivo de este proyecto" (los <...> son librerias instaladas).
#include "Config.h"
#include "Sensores.h"
#include "Aerogenerador.h"
#include "MaquinaEstados.h"
#include "ComunicacionSerie.h"

// Objetos globales: uno por modulo. Reciben sus pines y constantes de Config.h.
// los objetos globales se construyen ANTES de que Arduino se inicialice,
// por eso sus constructores solo guardan datos. Lo que toca hardware (pinMode,
// Serial, sensores) se hace en iniciar(), que se llama desde setup().

SensorTension     sensorTension(PIN_TENSION, FACTOR_DIVISOR);
SensorViento      sensorViento(PIN_VIENTO, VIENTO_MAX_MS);
SensorAmbiente    sensorAmbiente(PIN_DHT, TIPO_DHT);
Aerogenerador     aerogenerador(RESISTENCIA_CARGA_OHM);
MaquinaEstados    maquina(PIN_LED_VERDE, PIN_LED_AMARILLO, PIN_LED_ROJO);
ComunicacionSerie comunicacion(BAUDIOS_SERIE);

unsigned long ultimoEnvioMs = 0UL;   // instante de la ultima trama enviada

// Prototipos de las funciones de este archivo 
void actualizarPlanta();
void atenderOrdenes();
Medicion armarMedicion();

/*
  Prepara cada modulo. Se ejecuta una sola vez al encender o resetear el Arduino.
 */
void setup() {
  comunicacion.iniciar();
  sensorAmbiente.iniciar();
  maquina.iniciar();
}

/*
  Ciclo principal. Se repite sin parar y NUNCA se bloquea (no hay delay()):
  asi las ordenes de Processing y el estado se atienden en todo momento.
 */
void loop() {
  unsigned long ahora = millis();     // milisegundos desde que encendio

  sensorAmbiente.actualizar();        // lee el DHT22 solo si ya pasaron 2 s
  atenderOrdenes();                   // revisa si Processing mando algo
  actualizarPlanta();                 // mide, calcula y decide

  // Cada PERIODO_ENVIO_MS se manda una trama. Se compara contra la diferencia
  // (ahora - ultimo) y no contra un instante fijo: asi funciona aunque millis()
  // se reinicie al llegar a su maximo (~49 dias).
  if (ahora - ultimoEnvioMs >= PERIODO_ENVIO_MS) {
    ultimoEnvioMs = ahora;
    comunicacion.enviarTrama(armarMedicion());
  }
}

/*
  Lee tension y viento, calcula con el aerogenerador y deja que la maquina de
  estados decida. Entrada: ninguna. Salida: ninguna (actualiza los objetos globales).
 */
void actualizarPlanta() {
  float tensionV = sensorTension.leerVoltios();
  float vientoMs = sensorViento.leerMetrosPorSegundo();

  aerogenerador.actualizar(tensionV, vientoMs);
  maquina.actualizar(aerogenerador.obtenerTension(),
                     sensorAmbiente.obtenerTemperatura());
}

/*
  Atiende las ordenes que llegaron desde Processing.
  CMD:UMBRAL=<V> cambia el umbral de derivacion; CMD:RESET devuelve la planta a ESPERA.
 */
void atenderOrdenes() {
  Orden orden;   // se completa dentro de leerOrden (paso por referencia)

  while (comunicacion.leerOrden(orden)) {
    if (orden.tipo == ORDEN_UMBRAL) {
      maquina.establecerUmbralDerivacion(orden.valor);
    } else if (orden.tipo == ORDEN_RESET) {
      maquina.reiniciar();
    }
  }
}

/*
  Junta todos los valores actuales en una Medicion lista para enviar.
  return medicion con humedad, viento, potencia, temperatura, tension, corriente y estado.
 */
Medicion armarMedicion() {
  Medicion medicion;

  medicion.humedad     = sensorAmbiente.obtenerHumedad();
  medicion.viento      = aerogenerador.obtenerViento();
  medicion.potenciaMw  = aerogenerador.obtenerPotencia();
  medicion.temperatura = sensorAmbiente.obtenerTemperatura();
  medicion.tensionV    = aerogenerador.obtenerTension();
  medicion.corrienteMa = aerogenerador.obtenerCorriente();
  medicion.estado      = (int) maquina.obtenerEstado();

  return medicion;
}
