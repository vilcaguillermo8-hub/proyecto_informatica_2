# Interfaz Processing - Generador Eolico

Monitor del generador eolico
Muestra humedad, viento, potencia y temperatura, mas el estado, la tension, la corriente y la energia de la planta
Los datos vienen del Arduino por USB; si no hay Arduino conectado, usa datos simulados
Cada lectura se marca como NORMAL, BAJO o CRITICO segun sus umbrales

## Como ejecutarlo

1. Abrir Processing (3.5 o superior)
2. Archivo > Abrir... y elegir la carpeta GeneradorEolicoUI
3. Presionar Run

## Archivos

- GeneradorEolicoUI.pde: arranca el sketch y atiende teclado y mouse
- Configuracion.pde: valores fijos y colores compartidos
- Modelo.pde: las clases con los datos
- Logica.pde: simulacion y cambios de estado
- ListaEnlazada.pde: bitacora con nodos enlazados
- Persistencia.pde: lectura y escritura de archivos y parseo de la trama del Arduino
- ComunicacionSerie.pde: puerto serie, modo Arduino/simulacion y ordenes al Arduino
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

- Cadenas: nombres, unidades, mensajes y parseo del archivo de configuracion
- Punteros: las referencias a objetos permiten modificar el mismo estado
- Estructuras: clases simples con los datos de cada variable
- Archivos: loadStrings y saveStrings, con chequeo de errores
- Listas enlazadas: ListaEnlazadaEventos con NodoEvento
- Memoria dinamica: new para cada nodo y limpieza de referencias

## Controles

- G: guarda data/bitacora.txt
- C: limpia la bitacora
- M: cambia entre datos del Arduino y simulacion
- R: manda CMD:RESET al Arduino (vuelve a ESPERA y pone la energia en cero)
- + / -: sube o baja 0,5 V el umbral de derivacion (CMD:UMBRAL)

## Conexion con el Arduino

1. Cargar el sketch del Arduino y cerrar el Monitor Serie del IDE (solo un programa puede usar el puerto)
2. Abrir este sketch y presionar Run: elige el ultimo puerto de la lista
3. Si no es el Arduino, mirar la consola y poner el numero correcto en INDICE_PUERTO_SERIE (Configuracion.pde)
4. Cada lectura se agrega a data/lecturas.csv (fecha_hora,hum,vto,pot,tmp,v,i,est,ene)
