# Simulación en Wokwi - Planta Eólica Inteligente

Simulación del programa Arduino de la planta eólica: mide **viento, RPM del rotor, tensión, corriente, potencia, energía, temperatura y humedad**, los muestra en una pantalla OLED y los envía por Serial a la interfaz de Processing.

## Enlace al proyecto

**▶ [Abrir la simulación en Wokwi]https://wokwi.com/projects/481244204799568897)**

## Archivos

| Archivo | Descripción |
|---|---|
| `sketch.ino` | Programa principal de Arduino |
| `diagram.json` | Circuito (placa, sensores simulados, pantalla) |
| `libraries.txt` | Librerías que Wokwi instala automáticamente |

## Componentes

| Componente | Función | Pin |
|---|---|---|
| Arduino Uno | Placa principal | - |
| Potenciómetro `potV` | Simula el módulo de tensión FZ0430 (0-25 V) | A0 |
| Potenciómetro `potI` | Simula el sensor de corriente ACS712-5A | A1 |
| Potenciómetro `potW` | Fija la frecuencia de pulsos del anemómetro (viento) | A2 |
| Potenciómetro `potR` | Fija la frecuencia de pulsos del rotor (RPM) | A3 |
| DHT22 | Temperatura y humedad | D7 |
| LED rojo + resistencia 220 Ω | Indica si hay viento suficiente | D4 |
| Pantalla OLED SSD1306 (I2C) | Muestra todos los valores | A4 (SDA), A5 (SCL) |

### Interrupciones y pulsos simulados

En el prototipo real, un **sensor Hall** (anemómetro) y un **fotointerruptor** (rotor) generan pulsos que cuentan las interrupciones. Wokwi no tiene esos sensores, así que el programa los imita:

| Sensor real | Pin de entrada | Pin que genera los pulsos (simulación) |
|---|---|---|
| Fotointerruptor (rotor) | D2 | D6 |
| Sensor Hall (anemómetro) | D3 | D5 |

Dos cables unen **D5 → D3** y **D6 → D2**. La frecuencia de cada tren de pulsos la fijan los potenciómetros `potW` y `potR`.

## Cómo usarlo

1. Abrir el enlace de arriba (o crear un proyecto **Arduino Uno** en [wokwi.com](https://wokwi.com) y pegar los tres archivos).
2. Presionar **Play**.
3. Mover los potenciómetros:
   - `potW`: velocidad del viento (0-20 m/s).
   - `potR`: RPM del rotor (0-900 rpm).
   - `potV` / `potI`: tensión (0-25 V) y corriente generadas.
4. Hacer clic sobre el **DHT22** para cambiar temperatura y humedad.
5. Abrir el **Monitor Serie** para ver los datos.

El LED se enciende cuando el viento llega a **2,5 m/s** o más.

## Qué hace el programa

Una vez por segundo:

1. Copia y reinicia los contadores de pulsos (las interrupciones solo cuentan).
2. Calcula las **RPM** del rotor y la **velocidad del viento**.
3. Calcula la **potencia del viento** con el límite de Betz.
4. Lee **tensión** y **corriente**, y calcula `P = V × I` y la **energía** acumulada (Wh).
5. Lee **temperatura** y **humedad** del DHT22.
6. Envía los datos por Serial y actualiza la OLED.

### Fórmulas

| Magnitud | Fórmula |
|---|---|
| RPM | `vueltas × 60000 / 1000` |
| Viento (m/s) | `rpm_anemómetro × 0,16 × π / 60` |
| Potencia del viento (mW) | `0,5 × 0,59 × 1,225 × π × 0,25² × v³ × 1000` |
| Tensión (V) | `ADC × Vref / 1023 × 5` |
| Corriente (A) | `(Vout − 2,5) / 0,185` |
| Potencia eléctrica (W) | `V × I` |
| Energía (Wh) | `Σ P × Δt / 3600` |

## Salida por Serial

Una línea por segundo, a **9600 baudios**, con el formato que lee la interfaz de Processing:

```
V:12.5;I:4.10;P:51.3;E:1.20;W:8.0;R:164;T:25.0;H:50
```

| Clave | Variable | Unidad |
|---|---|---|
| V | Tensión | V |
| I | Corriente | A |
| P | Potencia eléctrica | W |
| E | Energía acumulada | Wh |
| W | Velocidad del viento | m/s |
| R | RPM del rotor | rpm |
| T | Temperatura | °C |
| H | Humedad | % |

## Pasar al hardware real

En `sketch.ino` cambiar:

```cpp
#define SIMULACION 0
```

Con eso:
- Se usa la referencia analógica interna de **1,1 V** (como en el TFG).
- Se dejan de generar pulsos simulados: hay que conectar el Hall a **D3** y el fotointerruptor a **D2**.
- Los potenciómetros se reemplazan por el **FZ0430** (A0) y el **ACS712** (A1).

## Librerías

- Adafruit GFX Library
- Adafruit SSD1306
- DHT sensor library
- Adafruit Unified Sensor

## Referencia

Basado en el TFG *Diseño y construcción de un aerogenerador de laboratorio y control mediante Arduino* (Universidad de Jaén, 2023), al que se le agregó el sensado de tensión, corriente, temperatura y humedad.
