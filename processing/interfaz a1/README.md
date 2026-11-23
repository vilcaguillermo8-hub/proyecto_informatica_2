# Interfaz Processing - Generador Eolico

Monitor del generador eolico
Muestra humedad, viento, potencia y temperatura
Cada lectura se marca como NORMAL, BAJO o CRITICO segun sus umbrales
Usa datos del Arduino si hay una placa conectada, si no sigue con la simulacion

## Como ejecutarlo

1. Abrir Processing (3.5 o superior)
2. Archivo > Abrir... y elegir la carpeta GeneradorEolicoUI
3. Si va a usar Arduino, cerrar antes el Monitor Serie del IDE de Arduino
4. Presionar Run

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

- GeneradorEolicoUI.pde: arranca el sketch y atiende teclado y mouse
- Configuracion.pde: valores fijos, colores y constantes del puerto serie
- Modelo.pde: las clases con los datos
- Logica.pde: elige entre datos reales y simulacion, y avisa de cambios
- ListaEnlazada.pde: bitacora con nodos enlazados
- Persistencia.pde: lectura y escritura de archivos
- Serie.pde: lectura del puerto serie y parseo de la trama
- Interfaz.pde: todo lo que se dibuja
- data/configuracion.txt: umbrales que se pueden cambiar sin tocar el codigo

## Clases de este proyecto

- VariableMonitorizada: guarda una medicion, sus limites y como simular una lectura
- RegistroEvento: guarda un mensaje con hora y nivel para la bitacora
- Rect: guarda un area y permite saber si el mouse esta adentro
- EstadoSistema: junta las cuatro variables en un solo objeto
- NodoEvento: una celda de la lista enlazada, apunta al siguiente nodo
- ListaEnlazadaEventos: administra la bitacora y descarta el evento mas viejo

## Temas del proyecto

- Cadenas: nombres, unidades, mensajes, trama serie y parseo del archivo de configuracion
- Punteros: las referencias a objetos permiten modificar el mismo estado
- Estructuras: clases simples con los datos de cada variable
- Archivos: loadStrings y saveStrings, con chequeo de errores
- Listas enlazadas: ListaEnlazadaEventos con NodoEvento
- Memoria dinamica: new para cada nodo y limpieza de referencias

## Controles

- G: guarda data/bitacora.txt
- C: limpia la bitacora

El programa corre solo, no hay pausa ni reinicio
