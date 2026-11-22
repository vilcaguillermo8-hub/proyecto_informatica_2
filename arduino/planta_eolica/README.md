# Planta Generadora Eólica Inteligente — Parte Arduino

Prototipo de micro planta eólica: un motor paso a paso usado como generador alimenta una carga resistiva. Un Arduino UNO mide la tensión generada, el viento, la temperatura y la humedad, calcula corriente, potencia y energia, decide el estado de la planta (con una máquina de estados) y envía los datos por USB a la interfaz de Processing.

> **Alcance del prototipo:** se muestra el comportamiento de la planta hacia una carga (no la planta completa). El viento se simula con un potenciómetro; la corriente se calcula, no se mide.

**Integrantes:** Salinas Francisco · Spinoza Lucas · Vilca Javier — UTN FRM, Informática II.

---

## 1. Qué hace

Una vez por segundo el Arduino:

1. Lee la tensión del generador (A0) y el viento simulado (A1).
2. Lee temperatura y humedad del DHT22 (cada 2 s como mínimo; entre lecturas conserva el último valor válido).
3. Calcula corriente y potencia sobre la carga, y va sumando la energía entregada.
4. Actualiza la máquina de estados y los LEDs.
5. Envía una trama de texto por serie a la PC.

Además atiende órdenes que llegan desde Processing (cambiar umbral, reiniciar).

---

## 2. Componentes

| Componente | Función | Pin |
|---|---|---|
| Arduino UNO | Controlador | — |
| Motor paso a paso (como generador) | Genera tensión al girar el eje | 1 bobina → puente |
| 4 diodos (1N5819 o 1N4148) | Puente rectificador | — |
| Capacitor 100 µF | Alisa la tensión rectificada | — |
| Resistencia 100 Ω / ½ W | Carga | — |
| 2 resistencias 10 kΩ | Divisor de tensión (÷2) | A0 |
| Potenciómetro | Simula el viento (0–28 m/s) | A1 |
| DHT22 | Temperatura y humedad | D2 |
| BMP180 (opcional) | Presión (I2C, 5 V) | A4 / A5 |
| 3 LEDs + 3 × 220 Ω | Verde, amarillo, rojo | D8 / D9 / D10 |

## 3. Armado del circuito (resumen)

1. **Motor:** usar una sola bobina. Con un óhmetro, encontrar los dos extremos de una bobina (en motores de 5 o 6 cables, el cable común queda sin conectar).
2. **Rectificación:** los dos extremos de la bobina van a un puente de 4 diodos.
3. **Salida del puente:** capacitor de 100 µF en paralelo con la carga de 100 Ω.
4. **Medición:** divisor 10 kΩ / 10 kΩ en paralelo con la carga; el punto medio va a **A0**. Mide hasta 10 V.
5. **Viento:** potenciómetro con extremos a 5 V y GND, cursor a **A1**.
6. **DHT22:** alimentación 5 V, GND y dato a **D2** (el módulo de 3 pines ya trae la resistencia pull-up).
7. **LEDs:** cada uno con su resistencia de 220 Ω a GND.
8. **GND común** para todo.

⚠️ **Precaución a tener en cuenta:** la carga de 100 Ω / ½ W disipa 0,5 W a 7,07 V. A los 8 V de protección serían 0,64 W, por encima de su capacidad. Se debe girar el eje con cuidado, o usar una resistencia de 1 W.

---

## 4. Estados de la planta

| Estado | Valor | LED | Significado |
|---|---|---|---|
| ESPERA | 0 | ninguno | Tensión por debajo del mínimo |
| GENERANDO | 1 | verde (D8) | Generación normal |
| DERIVACION | 2 | amarillo (D9) | Tensión sobre el umbral de derivación |
| PROTECCION | 3 | rojo (D10) | Tensión máxima o temperatura crítica superadas |

Los umbrales están en `Config.h` y son **provisorios** (se ajustan en las pruebas): `TENSION_MINIMA_V = 0.5`, `TENSION_DERIVACION_V = 4.0`, `TENSION_MAXIMA_V = 8.0`, `TEMPERATURA_CRITICA_C = 50.0`, `HISTERESIS_V = 0.2`. La histéresis evita que el estado parpadee cuando la tensión oscila cerca de un umbral.

---

## 5. Comunicación serie (9600 baudios)

### Arduino → PC (una línea por segundo)

```
HUM:48;VTO:8.5;POT:250;TMP:24;V:5.0;I:50;EST:1;ENE:4.17
```

| Clave | Variable | Unidad |
|---|---|---|
| HUM | Humedad | % |
| VTO | Velocidad del viento | m/s |
| POT | Potencia sobre la carga | mW |
| TMP | Temperatura | °C |
| V | Tensión en la carga | V |
| I | Corriente en la carga | mA |
| EST | Estado de la planta | 0 a 3 |
| ENE | Energía acumulada entregada a la carga | mWh |

### PC → Arduino (órdenes)

| Orden | Efecto |
|---|---|
| `CMD:UMBRAL=<V>` | Cambia el umbral de derivación (en voltios) |
| `CMD:RESET` | Devuelve la planta a ESPERA y restaura el umbral de derivación y pone la energía en cero |

> Solo puede haber un programa usando el puerto COM a la vez: cerrar el Monitor Serie del IDE antes de abrir Processing.

---

## 6. Fórmulas

| Magnitud | Fórmula |
|---|---|
| Tensión (V) | `ADC × 5,0 / 1023 × 2` (el 2 es el divisor) |
| Corriente (mA) | `V / R × 1000`, con R = 100 Ω |
| Potencia (mW) | `V² / R × 1000` |
| Viento (m/s) | `ADC / 1023 × 28` (potenciómetro) |
| Potencia teórica del viento (mW) | `0,5 × 0,59 × 1,225 × π × 0,25² × v³ × 1000` (límite de Betz, radio de rotor 0,25 m) |

---

## 7. Estructura del código

```
arduino/planta_eolica/
├── planta_eolica.ino      Programa principal: solo setup() y loop()
├── Config.h               Pines, constantes y umbrales
├── Sensores.h / .cpp      SensorTension, SensorViento 
├── SensorAmbiente.cpp     SensorAmbiente: temperatura y humedad (DHT22 o DHT11)
├── Aerogenerador.h / .cpp Cálculo de corriente, potencia, energia y potencia teórica
├── MaquinaEstados.h / .cpp Estados, umbrales con histéresis y LEDs
└── ComunicacionSerie.h / .cpp Envío de la trama y lectura de órdenes
```

Cada módulo es una clase con su declaración en el `.h` (el "contrato") y su lógica en el `.cpp`. El `.ino` solo une las piezas.

---

## 8. Cómo compilar y cargar

1. Abrir `planta_eolica.ino` con el IDE de Arduino (los demás archivos se cargan solos si están en la misma carpeta).
2. Si se usa el DHT11 en lugar del DHT22, cambiar `TIPO_DHT` a 11 en `Config.h`.
3. Instalar desde el Gestor de Bibliotecas: **DHT sensor library** y **Adafruit Unified Sensor**.
4. Seleccionar placa **Arduino Uno** y el puerto correcto.
5. Cargar el sketch.
6. Cerrar el Monitor Serie y abrir la interfaz de Processing.

---

## 9. Limitaciones y mejoras futuras

- La corriente se calcula (I = V/R); con un sensor de corriente (por ejemplo ACS712) se mediría de verdad.
- El viento es un potenciómetro; con un anemómetro real se mediría el viento verdadero.
- No se miden las RPM del rotor (haría falta un sensor en el eje, por ejemplo Hall o fotointerruptor).
- No se calcula la energía acumulada (Wh) ni se miden las RPM del rotor.
- Los umbrales deben calibrarse con el motor real.
- La planta completa alimentaría una batería con un sistema de carga controlado.
- Se planea el armado de una maqueta para un prototipo mas completo.

---

## Referencias

Basado en el TFG *Diseño y construcción de un aerogenerador de laboratorio y control mediante Arduino* (Universidad de Jaén, 2023).
