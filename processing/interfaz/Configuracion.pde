/**
 * Configuracion.pde
 * Aca junto los valores que se usan en mas de un archivo
 * Asi si quiero cambiar un numero o un color, lo hago una sola vez
 * Por ejemplo el color de CRITICO aparece en las tarjetas, en la bitacora y en los botones
 */

// Nombre del sistema que se muestra en la cabecera
final String IDENTIFICADOR_SISTEMA = "AERO-01";

// Tamaño de referencia de la ventana
// Ojo: Processing no deja pasar variables dentro de size()
// Por eso el sketch principal escribe los numeros directamente
final int ANCHO_VENTANA = 1280;
final int ALTO_VENTANA = 800;

// Cuantos cuadros por segundo dibuja Processing
final int CUADROS_POR_SEGUNDO = 30;

// Cada cuantos cuadros tomo una lectura nueva
// Si actualizara en cada cuadro, los valores cambiarian demasiado rapido para leerlos
final int CUADROS_POR_LECTURA = 12;

// Probabilidad de que una lectura de un salto grande en vez de caminar un paso
// Con esto simulo una perturbacion de vez en cuando
final float PROBABILIDAD_EVENTO_ALEATORIO = 0.045;

// Los archivos que leo y escribo estan dentro de la carpeta data
final String RUTA_CONFIGURACION = "configuracion.txt";
final String RUTA_BITACORA = "bitacora.txt";

// Cuantos eventos puedo guardar como maximo
// Cuando se llena, la lista descarta el evento mas viejo
final int CAPACIDAD_MAXIMA_BITACORA = 60;

// Cuantas lineas del log se ven ahora en la bitacora ampliada
final int MAX_EVENTOS_VISIBLES = 14;

// Los tres estados que puede tener una variable
// Uso numeros porque es mas facil compararlos que comparar textos
final int NIVEL_BAJO = 0;
final int NIVEL_NORMAL = 1;
final int NIVEL_CRITICO = 2;

// Codigos que devuelve la funcion que detecta el boton presionado
final int BOTON_NINGUNO = 0;
final int BOTON_PAUSA = 1;
final int BOTON_GUARDAR = 2;
final int BOTON_LIMPIAR = 3;

// Paleta de colores del tema oscuro
// Los uno aca para que toda la interfaz use siempre los mismos
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
