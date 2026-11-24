/*
Es la libreria de la maquina de estados de la planta (la logica en MaquinaEstados.cpp)

Una maquina de estados es un modelo donde el sistema esta SIEMPRE en uno de
un conjunto fijo de estados y pasa de uno a otro cuando se cumple una
condicion. Depende de la historia (el estado actual), no solo de las entradas.

   ESPERA      tension < minima                          -> ningun LED
   GENERANDO   tension entre la minima y la de derivacion -> LED verde
   DERIVACION  tension >= derivacion (sobra energia)      -> LED amarillo
   PROTECCION  tension >= maxima o temperatura critica    -> LED rojo

 Los umbrales salen de Config.h. Para evitar que el estado parpadee cuando la
 tension oscila justo en un limite, el .cpp debe usar HISTERESIS_V (margen).
*/

#ifndef MAQUINAESTADOS_H
#define MAQUINAESTADOS_H

// Estados de la planta. Los numeros son los que viajan en la trama (EST:n). 
enum EstadoPlanta {
  ESTADO_ESPERA     = 0,
  ESTADO_GENERANDO  = 1,
  ESTADO_DERIVACION = 2,
  ESTADO_PROTECCION = 3
};

class MaquinaEstados {
  public:
    /*
     param pinVerde, pinAmarillo, pinRojo  pines de los tres LEDs.
    */
    MaquinaEstados(int pinVerde, int pinAmarillo, int pinRojo);

    /*
     Configura los pines de los LEDs como salida y deja el estado en ESPERA.
     Se llama UNA vez desde setup() (no en el constructor: ver SensorAmbiente).
     */
    void iniciar();

    /*
     Evalua las condiciones, cambia de estado si corresponde y actualiza los LEDs.
     Se llama en cada vuelta de loop().
     param tensionV      tension generada, en V.
     param temperaturaC  temperatura del ambiente, en grados Celsius.
    */
    void actualizar(float tensionV, float temperaturaC);

    // return estado actual. 
    EstadoPlanta obtenerEstado();

    /*
      Cambia el umbral de derivacion (orden CMD:UMBRAL=<voltios> desde Processing).
      param tensionV  nuevo umbral en V. Debe estar entre la tension minima y la maxima;
                       si no, se ignora.
      return true si se aplico.
     */
    bool establecerUmbralDerivacion(float tensionV);

    /*
      Devuelve la planta a ESPERA y restaura el umbral de derivacion de Config.h
      (orden CMD:RESET).
     */
    void reiniciar();

  private:
    int _pinVerde;
    int _pinAmarillo;
    int _pinRojo;
    EstadoPlanta _estado;
    float _umbralDerivacionV;   // arranca con TENSION_DERIVACION_V y puede cambiar
};

#endif