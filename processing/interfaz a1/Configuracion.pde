/**
 * Configuracion.pde
 * Aca junto los valores que se usan en mas de un archivo
 */

// Nombre del sistema que se muestra en la cabecera
final String IDENTIFICADOR_SISTEMA = "AERO-01";

// Tamaño de la ventana
final int ANCHO_VENTANA = 1280;
final int ALTO_VENTANA = 800;

// Cuantos cuadros por segundo dibuja Processing
final int CUADROS_POR_SEGUNDO = 30;

// Cada cuantos cuadros tomo una lectura nueva
final int CUADROS_POR_LECTURA = 12;

// Probabilidad de que una lectura de un salto grande en vez de caminar un paso
final float PROBABILIDAD_EVENTO_ALEATORIO = 0.045;

// Velocidad del puerto serie, tiene que coincidir con Config.h de Arduino
final int BAUDIOS_SERIE = 9600;

// Dejalo vacio para probar los puertos en orden
// Si quieres elegir uno a mano, escribe su nombre, por ejemplo COM3
<<<<<<< HEAD
final String PUERTO_SERIE_FORZADO = "COM3";
=======
final String PUERTO_SERIE_FORZADO = "COM2";
>>>>>>> 797fb3cf09e745d5bc3b4bdce4571b21e1e2d953

// Arduino envia una trama por segundo
// Si pasan tres segundos sin datos, vuelvo a la simulacion
final long TIEMPO_ESPERA_SERIE_MS = 3000L;

// Los archivos que leo y escribo estan dentro de la carpeta data
final String RUTA_CONFIGURACION = "configuracion.txt";
final String RUTA_BITACORA = "bitacora.txt";

// Cuantos eventos puedo guardar como maximo
// Cuando se llena, la lista descarta el evento mas viejo
final int CAPACIDAD_MAXIMA_BITACORA = 60;

// Cuantas lineas del log se ven en la bitacora reducida
// Este proyecto deja espacio abajo para el grafico del estado general
final int MAX_EVENTOS_VISIBLES = 6;

// Cuantas muestras del estado general guarda el grafico de Euler
// Con 0.4 s por lectura se ven unos 19 segundos de historia
final int CANTIDAD_MUESTRAS_ESTADO = 48;

// Los tres estados que puede tener una variable
final int NIVEL_BAJO = 0;
final int NIVEL_NORMAL = 1;
final int NIVEL_CRITICO = 2;

// Codigos que devuelve la funcion que detecta el boton presionado
final int BOTON_NINGUNO = 0;
final int BOTON_GUARDAR = 1;
final int BOTON_LIMPIAR = 2;

// Paleta de colores del tema oscuro
final color COLOR_FONDO = color(9, 15, 28);
final color COLOR_FONDO_CLARO = color(17, 28, 48);
final color COLOR_PANEL = color(20, 32, 54);
final color COLOR_BORDE = color(62, 84, 118);
final color COLOR_TEXTO = color(232, 241, 255);
final color COLOR_TEXTO_SUAVE = color(145, 165, 197);
final color COLOR_NORMAL = color(45, 212, 167);
final color COLOR_BAJO = color(245, 185, 66);
final color COLOR_CRITICO = color(255, 92, 108);
final color COLOR_ACENTO = color(76, 141, 255);
