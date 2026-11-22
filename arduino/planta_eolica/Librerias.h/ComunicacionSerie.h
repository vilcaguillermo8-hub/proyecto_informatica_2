/*
  CONTRATO de la comunicacion con Processing (logica en ComunicacionSerie.cpp).
 
  Arduino -> PC  (una linea por segundo):
     HUM:48;VTO:8.5;POT:250;TMP:24;V:5.0;I:50;EST:1
 
  PC -> Arduino  (una linea por orden):
      CMD:UMBRAL=3.5      cambia el umbral de derivacion, en voltios
      CMD:RESET           devuelve la planta a ESPERA
 
 */

#ifndef COMUNICACIONSERIE_H
#define COMUNICACIONSERIE_H

/*
  Una medicion completa de la planta: se arma en el .ino y se pasa de una vez,
  en lugar de una funcion con siete parametros sueltos.
 */
struct Medicion {
  float humedad;       // %
  float viento;        // m/s
  float potenciaMw;    // mW
  float temperatura;   // grados Celsius
  float tensionV;      // V
  float corrienteMa;   // mA (calculada)
  int estado;          // 0 a 3, ver EstadoPlanta en MaquinaEstados.h
};

// Tipos de orden que puede mandar Processing. 
enum TipoOrden {
  ORDEN_NINGUNA = 0,
  ORDEN_UMBRAL  = 1,
  ORDEN_RESET   = 2
};

/* Una orden ya interpretada. `valor` solo se usa en ORDEN_UMBRAL. */
struct Orden {
  TipoOrden tipo;
  float valor;
};

class ComunicacionSerie {
  public:
    // param baudios  velocidad del puerto (va coincidir con Processing). */
    ComunicacionSerie(long baudios);

    /* Abre el puerto serie. Se llama UNA vez desde setup(). */
    void iniciar();

    /*
      Arma la linea de texto con la medicion y la envia (termina con salto de linea).
      param medicion  datos a enviar.
     */
    void enviarTrama(const Medicion &medicion);

    /*
      Lee los caracteres que hayan llegado y, si completo una linea valida,
      la interpreta. No bloquea: si no hay nada, vuelve de inmediato.
      
      param orden  se completa con la orden recibida (paso por referencia).
      return true si llego una orden completa y valida; false en otro caso.
     */
    bool leerOrden(Orden &orden);

  private:
    static const int TAMANO_LINEA = 32;   // largo maximo de una orden
    long _baudios;
    char _linea[TAMANO_LINEA];            // caracteres recibidos hasta el salto de linea
    int _largo;                           // cuantos caracteres hay en _linea
};

#endif
