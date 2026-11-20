# Interfaz - Planta Eólica Inteligente (Processing)
Carpeta `interfaz/`: abrir `interfaz.pde` con Processing 4 (modo Java). Cada pestaña es un módulo.
Funciona sin hardware (modo **simulado**) y está lista para conectarse al Arduino por puerto serie.
## Cómo usarla
- Al abrir aparece la **pantalla de inicio**: **INGRESAR AL SISTEMA** (modo simulado), **CONECTAR ARDUINO** (modo serie; si no hay puerto avisa y se queda ahí) o **SALIR**. Dentro del sistema, el botón **INICIO** de la barra superior (o la tecla `H`) vuelve a esa pantalla.
- **Simulado:** mové los deslizadores de viento, carga y temperatura ambiente; todo se recalcula.
- **Clic** en una tarjeta de la izquierda o en un sensor de la turbina (anemómetro, rotor, generador, controlador, baterías) abre el **detalle**, donde se pueden editar los límites de advertencia y alarma.
- El **interruptor** de cada tarjeta activa o desactiva la señal.
- Pestañas del gráfico: una señal, o **TODAS** superpuestas (en % de su escala).
- **TIEMPO x10 / x60** acelera la energía acumulada y la carga de la batería (para demostrar).
- Teclas: `ESPACIO` pausa, `D` diagnóstico, `M` simulado/serie, `L` registro CSV, `R` reiniciar, `1..9` pestaña del gráfico.
- Ventana en vez de pantalla completa: `PANTALLA_COMPLETA = false` al inicio de `interfaz.pde`.

## Conexión con el Arduino
1. En `interfaz.pde` ajustar `BAUDIOS` (igual que `Serial.begin`) e `INDICE_PUERTO` (posición del puerto en `Serial.list()`).
2. Pulsar **MODO: SIMULADO** (o `M`) para pasar a **SERIE**.
3. El Arduino manda una línea por muestra:

```
T:45.2;V:12.5;I:4.1;P:51.3;E:1.2;W:8.0;R:164;B:70
```

| Clave | Variable | Unidad |
|---|---|---|
| T | Temperatura del generador | °C |
| V | Tensión | V |
| I | Corriente | A |
| P | Potencia (si falta, se calcula V x I) | W |
| E | Energía acumulada (si falta, se integra en la PC) | Wh |
| W | Velocidad del viento | m/s |
| R | RPM del rotor | rpm |
| B | Carga de la batería | % |

Los campos son opcionales y pueden ir en cualquier orden. Las líneas inválidas se ignoran.

Ejemplo del lado Arduino:

```cpp
Serial.print("V:");  Serial.print(tension, 1);
Serial.print(";I:"); Serial.print(corriente, 2);
Serial.print(";P:"); Serial.println(tension * corriente, 1);
```

## Registro
Con **REGISTRO CSV** se guarda un archivo en `interfaz/datos/` con una fila cada 0,5 s.

## Pestañas
`interfaz` (setup/draw, eventos) · `Medicion` (Señal) · `Simulador` · `Serie` · `Grafico` · `Controles` (Boton, Deslizador) · `Panel` (Panel, TarjetaSenal, Gauge, BarraProgreso) · `Inicio` (pantalla de bienvenida) · `Turbina` · `Ventanas` (detalle, diagnóstico, eventos) · `Registro`