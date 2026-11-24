# Interfaz Processing - Generador Eolico con grafico de Euler

Este proyecto es una copia separada de GeneradorEolicoUI
Mantiene el monitor del generador eolico y agrega un grafico del estado general
La bitacora se hizo mas chica para dejar espacio al grafico
No se modificaron GeneradorEolicoUI ni GeneradorEolicoSimple

## Como ejecutarlo

1. Abrir Processing 4
2. Archivo > Abrir y elegir la carpeta GeneradorEolicoMetodosNumericos
3. Si va a usar Arduino, cerrar antes el Monitor Serie del IDE de Arduino
4. Presionar Run

## Grafico del estado general

El panel inferior derecho muestra solo la evolucion del estado general
Tiene titulo y las etiquetas BAJO, NORMAL y CRITICO
No tiene formula ni numeros escritos adentro
El cuadro que antes indicaba Estado general se quito
Solo quedan la bitacora y el grafico en la columna derecha

El grafico tiene tres franjas horizontales

    Arriba CRITICO, en rojo
    En el medio NORMAL, en verde
    Abajo BAJO, en amarillo

La linea muestra como cambia el estado con el tiempo
El ultimo punto se pinta con el color del nivel suavizado

## Metodo de Euler aplicado

Trabajo sobre la ecuacion

    ds/dt = k(objetivo - s)

La formula que aplico en cada lectura es

    s(t+dt) = s(t) + k(objetivo - s(t))dt

donde

    s es el estado general suavizado
    objetivo es el numero que viene del nivel general medido
    k es la ganancia, define que tan rapido se acerca al objetivo
    dt es el tiempo entre lecturas, sale de CUADROS_POR_LECTURA

El estado deja de ser solo una etiqueta y pasa a ser un valor continuo
Ese valor va de 0 a 2 y se dibuja en las tres franjas

    0 = BAJO, franja amarilla abajo
    1 = NORMAL, franja verde en el medio
    2 = CRITICO, franja roja arriba

El objetivo de cada lectura sale del peor nivel de las cuatro variables
Si una sola variable esta en critico, el objetivo sube a 2
Si baja a bajo, el objetivo baja a 0

Con este esquema el estado no salta de golpe
La linea del grafico muestra como el sistema se acerca a la condicion medida

## Espacio de la bitacora

En este proyecto MAX_EVENTOS_VISIBLES vale 6
En GeneradorEolicoUI vale 14
La diferencia se usa para el panel del grafico
El espacio del cuadro de Estado general tambien se suma al grafico

## Conexion con Arduino

El codigo de la placa esta en la carpeta arduino/planta_eolica
El Arduino envia una trama por segundo a 9600 baudios con este formato

    HUM:48;VTO:8.5;POT:250;TMP:24;V:5.0;I:50;EST:1;ENE:4.17

De momento solo uso HUM, VTO, POT y TMP porque son las cuatro variables del programa
Los datos V, I, EST y ENE se descartan hasta que los necesitemos

POT llega en mW y lo divido por 1000000 para mostrarlo en kW
Por eso los umbrales de potencia son numeros tan chicos
La maqueta da como maximo unos 640 mW, que son 0.00064 kW

Si no hay placa, el programa sigue simulando como antes
Si llega una trama, uso los datos reales
Si dejan de llegar datos durante tres segundos, vuelvo a la simulacion
En la bitacora se escribe cada cambio de origen de datos
En la consola de Processing se ven los puertos serie y cual se abrio
Si se abre un puerto equivocado, poner su nombre en PUERTO_SERIE_FORZADO
Por ejemplo COM3 en Configuracion.pde

## Si dice que no hay puertos serie

Casi siempre es un problema del controlador, no del sketch
En el Administrador de dispositivos buscar FT232R USB UART, CH340 o USB Serial Port
Si aparece con un signo de exclamacion, instalar su controlador VCP
Para FT232R bajarlo de ftdichip.com/drivers/vcp-drivers
Para CH340 buscar el controlador CH340 de WCH
Despues desconectar y volver a conectar el cable USB
Debe aparecer un puerto COM en Ports (COM & LPT)
Si no aparece ningun puerto, la interfaz sigue funcionando con la simulacion

## Archivos

- GeneradorEolicoMetodosNumericos.pde: arranca el sketch y atiende teclado y mouse
- Configuracion.pde: valores fijos, colores y constantes del puerto serie
- Modelo.pde: las clases con los datos de los sensores
- Logica.pde: elige entre datos reales y simulacion y alimenta el grafico
- ListaEnlazada.pde: bitacora con nodos enlazados
- Persistencia.pde: lectura y escritura de archivos
- Serie.pde: lectura del puerto serie y parseo de la trama
- Interfaz.pde: cabecera, variables, bitacora y pie
- MetodosNumericos.pde: GraficoEstadoEuler con el paso de Euler y el historial
- MetodosNumericosUI.pde: dibuja el grafico sin texto
- data/configuracion.txt: umbrales que se pueden cambiar sin tocar el codigo

## Clases del tema nuevo

- GraficoEstadoEuler: guarda el valor integrado y las muestras del historial
- objetivoDesdeNivel: convierte BAJO, NORMAL o CRITICO en 0, 1 o 2
- actualizar: aplica un paso de Euler con la lectura del estado general
- registrarMuestra: guarda cada muestra y descarta la mas vieja cuando se llena
- obtenerNivel: traduce el valor suavizado a una etiqueta de nivel

## Temas del proyecto

- Cadenas: nombres, unidades, mensajes y trama serie
- Punteros: las referencias a objetos permiten modificar el mismo estado
- Estructuras: clases simples con los datos de cada variable
- Arreglos: el historial se guarda en dos arreglos paralelos
- Archivos: loadStrings y saveStrings, con chequeo de errores
- Listas enlazadas: ListaEnlazadaEventos con NodoEvento
- Memoria dinamica: new para cada nodo y cada objeto del grafico
- Metodos numericos: integracion de Euler sobre el estado general

## Controles

- G: guarda data/bitacora.txt
- C: limpia la bitacora

El programa corre solo, no hay pausa ni reinicio
