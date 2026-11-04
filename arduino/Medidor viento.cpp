const int PIN_SENSOR_VIENTO = A0; // pin para potenciometro para variar la velocidad del viento
const int PIN_SENSOR_DIRECCION = A1; // pin para potenciometro para la direccion del viento

class Aerogenerador
{
private:
float velocidadViento; // m/s
float direccionViento; // grados (0 a 360)
float direccionTurbina; // grados
float radioRotor; // m (dato fisico de diseno)
int estado; // 0 = apagado, 1 = encendido

public:
Aerogenerador(float radio);

void leerSensoresFisicos();
void orientarTurbina();
void encender();
void apagar();
void mostrarEnMonitorSerial();
};

// Constructor parametrizado
Aerogenerador::Aerogenerador(float radio)
{
velocidadViento = 0.0;
direccionViento = 0.0;
direccionTurbina = 0.0;
radioRotor = radio;
estado = 1; // Arranca encendido por defecto para las pruebas
}

void Aerogenerador::encender() {
estado = 1;
}

void Aerogenerador::apagar() {
estado = 0;
}

// Lee los valores de los potenciometros y los mapea a magnitudes del viento
void Aerogenerador::leerSensoresFisicos()
{
int lecturaViento = analogRead(PIN_SENSOR_VIENTO);
int lecturaDireccion = analogRead(PIN_SENSOR_DIRECCION);

// Mapeamos el valor analogico (0 a 1023) a velocidad de viento (0 a 20 m/s)
velocidadViento = (lecturaViento / 1023.0) * 20.0;

// Mapeamos el valor analogico a grados de direccion (0 a 360 grados)
direccionViento = (lecturaDireccion / 1023.0) * 360.0;
}

void Aerogenerador::orientarTurbina()
{
// El sistema orienta la turbina hacia donde apunta la direccion del viento leida
direccionTurbina = direccionViento;
}

void Aerogenerador::mostrarEnMonitorSerial()
{
if (estado == 1) {
Serial.println("Estado del Sistema: ON");
}
else {
Serial.println("Estado del Sistema: OFF");
}

Serial.print("Velocidad del Viento : ");
Serial.print(velocidadViento);
Serial.println(" m/s");

Serial.print("Direccion del Viento : ");
Serial.print(direccionViento);
Serial.println(" grados");

Serial.print("Turbina orientada a : ");
Serial.print(direccionTurbina);
Serial.println(" grados");

Serial.println("-----------------------------------");
}

// Instancia global del aerogenerador para Arduino (Radio del rotor = 1.5)
Aerogenerador miAerogenerador(1.5);

void setup() {
Serial.begin(9600);
Serial.println("Sistema de Monitoreo Eolico Iniciado.");
}

void loop() {
// 1 Tomar lecturas de los sensores fisicos (pines A0 y A1)
miAerogenerador.leerSensoresFisicos();

// 2 Procesar la orientacion de la turbina frente al viento
miAerogenerador.orientarTurbina();

// 3 Mostrar los datos recopilados por el Monitor Serial
miAerogenerador.mostrarEnMonitorSerial();

// 4 Pausa cada 5 segundos
delay(5000);
}
