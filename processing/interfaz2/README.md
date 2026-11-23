# Interfaz Processing - Generador Eolico

Monitor del generador eolico
Muestra humedad, viento, potencia y temperatura con datos simulados
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
- Persistencia.pde: lectura y escritura de archivos
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

La simulacion corre sola, no hay pausa ni reinicio
