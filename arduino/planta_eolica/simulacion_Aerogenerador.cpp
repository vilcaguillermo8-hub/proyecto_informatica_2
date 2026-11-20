//  Planta eolica inteligente - simulacion en Wokwi
//
//  Pines:  D2  fotointerruptor (rotor)     D3  Hall (anemometro)
//          D4  LED de estado               D7  DHT22 (temp + humedad)
//          A0  tension (FZ0430)            A1  corriente (ACS712)
//          A4/A5  OLED por I2C
//  SIMULACION: D5/D6 generan pulsos que vuelven por D3/D2 (con cable),
//              A2/A3 son los potenciometros que fijan su frecuencia.

#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include <DHT.h>

#define SIMULACION 1          // 1 = Wokwi/Tinkercad, 0 = hardware real

// ---------------- CONSTANTES ----------------
const unsigned long TIEMPO_CALCULO_MS = 1000;   // cada cuanto se calcula
const unsigned long MS_POR_MINUTO = 60000;
const float RADIO_PALAS = 0.25;                 // m
const float DENSIDAD_AIRE = 1.225;              // kg/m3
const float LIMITE_BETZ = 0.59;
const float DIAMETRO_ANEMOMETRO = 0.16;         // m
const float VIENTO_ARRANQUE = 2.5;              // m/s: LED prende desde aca

// ---------------- PINES ----------------
const int PIN_FOTO = 2;          // rotor      (interrupcion 0)
const int PIN_HALL = 3;          // anemometro (interrupcion 1)
const int PIN_LED = 4;
const int PIN_GEN_ANEMO = 5;     // solo simulacion -> puente a D3
const int PIN_GEN_ROTOR = 6;     // solo simulacion -> puente a D2
const int PIN_DHT = 7;
const int PIN_TENSION = A0;
const int PIN_CORRIENTE = A1;
const int PIN_POT_VIENTO = A2;   // solo simulacion
const int PIN_POT_ROTOR = A3;    // solo simulacion

// ---------------- OBJETOS ----------------
Adafruit_SSD1306 oled(128, 64, &Wire, -1);
DHT dht(PIN_DHT, DHT22);

// ---------------- DATOS DE LA PLANTA ----------------
// Todo junto en un solo struct. Solo los dos contadores son volatile
// porque los modifica la interrupcion.
struct Medicion {
  volatile unsigned int vueltasRotor;   // pulsos del rotor
  volatile unsigned int vueltasAnemo;   // pulsos del anemometro
  unsigned long tiempoAnterior;         // ultimo calculo (millis)
  unsigned long rpmRotor;
  float velocidadMS;                    // viento
  float potenciaViento;                 // mW (teorica, con Betz)
  float tension;                        // V
  float corriente;                      // A
  float potencia;                       // W (V x I)
  float energiaWh;                      // Wh acumulados
  float temperatura;                    // C
  float humedad;                        // % HR
};
Medicion med = {};                      // todo en cero al arrancar

// ---------------- GENERADOR DE PULSOS (solo simulacion) ----------------
unsigned long tGenAnemo = 0, tGenRotor = 0;
bool estAnemo = false, estRotor = false;

// ---------------- INTERRUPCIONES ----------------
void contarRotor() { med.vueltasRotor++; }
void contarAnemo() { med.vueltasAnemo++; }

void setup() {
  Serial.begin(9600);
  if (!SIMULACION) {
    analogReference(INTERNAL);   // 1,1 V como en el TFG (solo real)
  }
  oled.begin(SSD1306_SWITCHCAPVCC, 0x3C);
  dht.begin();

  pinMode(PIN_LED, OUTPUT);
  pinMode(PIN_FOTO, INPUT);
  pinMode(PIN_HALL, INPUT);
  pinMode(PIN_GEN_ANEMO, OUTPUT);
  pinMode(PIN_GEN_ROTOR, OUTPUT);

  attachInterrupt(digitalPinToInterrupt(PIN_FOTO), contarRotor, RISING);
  attachInterrupt(digitalPinToInterrupt(PIN_HALL), contarAnemo, RISING);
}

//  Imita al Hall y al fotointerruptor: pulsos cuya frecuencia fija el pot
void generarPulsos() {
  float fAnemo = analogRead(PIN_POT_VIENTO) * 40.0 / 1023.0;  // 0-40 Hz  (0-20 m/s)
  float fRotor = analogRead(PIN_POT_ROTOR) * 15.0 / 1023.0;   // 0-15 Hz  (0-900 rpm)

  if (fAnemo > 0.5 && micros() - tGenAnemo >= 500000UL / fAnemo) {
    tGenAnemo = micros();
    estAnemo = !estAnemo;
    digitalWrite(PIN_GEN_ANEMO, estAnemo);
  }
  if (fRotor > 0.5 && micros() - tGenRotor >= 500000UL / fRotor) {
    tGenRotor = micros();
    estRotor = !estRotor;
    digitalWrite(PIN_GEN_ROTOR, estRotor);
  }
}

//  Sensores electricos

float leerTension() {                      // modulo FZ0430 (divisor 5:1)
  float adc = analogRead(PIN_TENSION);
  float vRef;
  if (SIMULACION) {
    vRef = 5.0;
  }
  else {
    vRef = 1.1;
  }
  return (adc * vRef / 1023.0) * 5.0;      // en simulacion: 0-25 V
}

float leerCorriente() {                    // ACS712-5A: 2.5 V = 0 A, 185 mV/A
  float vOut = analogRead(PIN_CORRIENTE) * 5.0 / 1023.0;
  float i = (vOut - 2.5) / 0.185;
  if (i < 0) i = -i;
  if (i < 0.05) i = 0;                     // ruido
  return i;
}

//  Pantalla OLED (8 lineas de 8 px)
void mostrarOLED() {
  oled.clearDisplay();
  oled.setTextColor(SSD1306_WHITE);
  oled.setTextSize(1);

  oled.setCursor(0, 0);  oled.print("ROTOR: ");  oled.print(med.rpmRotor);       oled.print(" rpm");
  oled.setCursor(0, 8);  oled.print("VIENTO: "); oled.print(med.velocidadMS, 1); oled.print(" m/s");
  oled.setCursor(0, 16); oled.print("P.viento: "); oled.print(med.potenciaViento, 0); oled.print(" mW");
  oled.setCursor(0, 24); oled.print("V: ");      oled.print(med.tension, 1);      oled.print(" V");
  oled.setCursor(0, 32); oled.print("I: ");      oled.print(med.corriente, 2);    oled.print(" A");
  oled.setCursor(0, 40); oled.print("P: ");      oled.print(med.potencia, 1);     oled.print(" W");
  oled.setCursor(0, 48); oled.print("TEMP: ");   oled.print(med.temperatura, 1);  oled.print(" C");
  oled.setCursor(0, 56); oled.print("HUM: ");    oled.print(med.humedad, 0);      oled.print(" %");

  oled.display();
}

//  Linea para la interfaz Processing
void enviarSerie() {
  Serial.print("V:");   Serial.print(med.tension, 1);
  Serial.print(";I:");  Serial.print(med.corriente, 2);
  Serial.print(";P:");  Serial.print(med.potencia, 1);
  Serial.print(";E:");  Serial.print(med.energiaWh, 2);
  Serial.print(";W:");  Serial.print(med.velocidadMS, 1);
  Serial.print(";R:");  Serial.print(med.rpmRotor);
  Serial.print(";T:");  Serial.print(med.temperatura, 1);
  Serial.print(";H:");  Serial.println(med.humedad, 0);
}

// ============================================================
void loop() {
  if (SIMULACION) generarPulsos();

  unsigned long ahora = millis();
  if (ahora - med.tiempoAnterior >= TIEMPO_CALCULO_MS) {

    // 1) copiar y reiniciar los contadores sin que la interrupcion interfiera
    noInterrupts();
    unsigned int vr = med.vueltasRotor;
    unsigned int va = med.vueltasAnemo;
    med.vueltasRotor = 0;
    med.vueltasAnemo = 0;
    interrupts();

    // 2) rpm y viento
    med.rpmRotor = (vr * MS_POR_MINUTO) / TIEMPO_CALCULO_MS;
    unsigned long rpmAnemo = (va * MS_POR_MINUTO) / TIEMPO_CALCULO_MS;
    med.velocidadMS = (rpmAnemo * DIAMETRO_ANEMOMETRO * PI) / 60.0;

    // 3) potencia del viento (mW), formula del TFG con limite de Betz
    float area = PI * RADIO_PALAS * RADIO_PALAS;
    med.potenciaViento = 0.5 * LIMITE_BETZ * DENSIDAD_AIRE * area *
                         med.velocidadMS * med.velocidadMS * med.velocidadMS * 1000.0;

    // 4) potencia electrica real y energia
    med.tension = leerTension();
    med.corriente = leerCorriente();
    med.potencia = med.tension * med.corriente;
    med.energiaWh += med.potencia * (TIEMPO_CALCULO_MS / 3600000.0);

    // 5) temperatura y humedad (el DHT22 entrega datos nuevos cada 2 s)
    float t = dht.readTemperature();
    float h = dht.readHumidity();
    if (!isnan(t)) med.temperatura = t;     // si falla, queda el ultimo valor
    if (!isnan(h)) med.humedad = h;

    // 6) LED: prendido si el viento alcanza para arrancar
    digitalWrite(PIN_LED, med.velocidadMS >= VIENTO_ARRANQUE);

    // 7) salidas
    enviarSerie();
    mostrarOLED();

    med.tiempoAnterior = ahora;
  }
}
