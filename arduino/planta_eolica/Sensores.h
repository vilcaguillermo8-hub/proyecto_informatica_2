/*
  CONTRATO de la libreria de sensores (solo declaraciones; la logica va en
  Sensores.cpp). Cada sensor es una clase que SOLO lee y devuelve numeros:
  no sabe nada de estados, LEDs ni comunicacion.
 
  Reparto: SensorTension y SensorViento (A0 y A1) y SensorAmbiente (DHT22).
  Mientras se respeten las firmas de abajo, el resto del programa no cambia.
 */

#ifndef SENSORES_H
#define SENSORES_H

class DHT;   // Declaracion adelantada: la libreria <DHT.h> se incluye SOLO en
             // Sensores.cpp, asi el .ino y los demas modulos no la necesitan.

// SensorTension: mide la tension generada a traves del divisor de tension.
class SensorTension {
  public:
    /*
     param pin            pin analogico donde llega el punto medio del divisor.
     param factorDivisor  (R1 + R2) / R2, para volver a la tension real.
     */
    SensorTension(int pin, float factorDivisor);

    /*
     Lee el pin y devuelve la tension real del generador.
     return tension en voltios (0 a 10 V con el divisor 10k/10k).
     */
    float leerVoltios();

  private:
    int _pin;              // el guion bajo marca los datos internos de la clase
    float _factorDivisor;
};

// SensorViento: viento SIMULADO con un potenciometro (luego puede ser un
// anemometro real sin cambiar las firmas).
class SensorViento {
  public:
    /*
     param pin        pin analogico del cursor del potenciometro.
     param maximoMs   viento que corresponde al tope del potenciometro (m/s).
     */
    SensorViento(int pin, float maximoMs);

    /*
     return velocidad del viento en m/s, de 0 a `maximoMs`.
     */
    float leerMetrosPorSegundo();

  private:
    int _pin;
    float _maximoMs;
};


// SensorAmbiente: temperatura y humedad (DHT22); presion opcional (BMP180).
// Esta clase la escribe el companero encargado del DHT22.
// Reglas: NO usar delay(); el sensor se lee cada PERIODO_LECTURA_DHT_MS como
// minimo; si una lectura falla (NaN) se conserva el ultimo valor valido.

  public:
    /*
     param pin   pin digital del DATA del DHT22.
      param tipo  tipo de sensor (22 = DHT22).
     */
    SensorAmbiente(int pin, int tipo);

    /*
      Prepara el sensor. Se llama UNA vez desde setup(). Todo lo que toque el
      hardware (pinMode, begin, new DHT) va aca y no en el constructor, porque
      los objetos globales se construyen antes de que Arduino se inicialice.
     */
    void iniciar();

    /*
      Se llama en CADA vuelta de loop(). Si ya pasaron 2 s desde la ultima
      lectura, lee el sensor; si no, vuelve de inmediato (no bloquea).
     */
    void actualizar();

    /*return humedad relativa en %, de 0 a 100 (ultimo valor valido). */
    float obtenerHumedad();

    /*return temperatura en grados Celsius, de -40 a 80 (ultimo valor valido). */
    float obtenerTemperatura();

    /*return presion en hPa (solo si se usa el BMP180; si no, 0). */
    float obtenerPresion();

    /*return false si la ultima lectura fallo (el dato devuelto es el anterior). */
    bool datoValido();

  private:
    // Detalles internos: el companero puede cambiarlos si lo necesita.
    // Solo la parte `public` es el contrato con el resto del programa.
    int _pin;
    int _tipo;
    float _humedad;
    float _temperatura;
    float _presion;
    bool _valido;
    unsigned long _ultimaLecturaMs;
    DHT *_dht;     // puntero al objeto de la libreria (se crea en iniciar())
};

#endif
