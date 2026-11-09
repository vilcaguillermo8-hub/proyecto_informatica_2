#include <iostream>
using namespace std;

class Aerogenerador
{
private:
	float velocidadViento;     // m/s
	float direccionViento;     // grados
	float direccionTurbina;    // grados 
	float potenciaGenerada;    // W
	float tensionSalida;       // V
	float corrienteSalida;     // A
	float radioRotor;          // m (dato fijo del aero)
	int estado;                // 0 = apagado, 1 = encendido
	
public:
	Aerogenerador();                          // constructor por defecto
	Aerogenerador(float radio, float tension); // constructor parametrizado
	
	void medirViento(float vel, float dir);
	void orientarTurbina();
	float calcularPotencia();
	void encendido();
	void apagado();
	void mostrar();
};

Aerogenerador::Aerogenerador()
{
	velocidadViento = 0;
	direccionViento = 0;
	direccionTurbina = 0;
	potenciaGenerada = 0;
	tensionSalida = 12;   // valor nominal por defecto (esto lo vamos a ir viendo)
	corrienteSalida = 0;
	radioRotor = 1;
	estado = 0;
}

Aerogenerador::Aerogenerador(float radio, float tension)
{
	velocidadViento = 0;
	direccionViento = 0;
	direccionTurbina = 0;
	potenciaGenerada = 0;
	tensionSalida = tension;
	corrienteSalida = 0;
	radioRotor = radio;
	estado = 0;
}

void Aerogenerador::medirViento(float vel, float dir)
{

	// Con Arduino, acá iría la lectura del sensor.
	velocidadViento = vel;
	direccionViento = dir;
}

void Aerogenerador::orientarTurbina()
{
	direccionTurbina = direccionViento;
}

float Aerogenerador::calcularPotencia()
{
	if (estado == 0) {
		potenciaGenerada = 0;
		corrienteSalida = 0;
		return 0;
	}
	const float rho = 1.225;   // densidad del aire (kg/m3)
	const float cp = 0.4;      // coeficiente de potencia
	const float PI_ = 3.14159;
	float area = PI_ * radioRotor * radioRotor;
	
	potenciaGenerada = 0.5 * rho * area * velocidadViento * velocidadViento * velocidadViento * cp;
	corrienteSalida = potenciaGenerada / tensionSalida;
	return potenciaGenerada;
}
/*
void Aerogenerador::encendido() { 
	estado = 1; 
}
void Aerogenerador::apagado() { 
	estado = 0; 
}
*/
void Aerogenerador::mostrar()
{
	if (estado == 1) {
		cout << "Estado: ON" << endl;
	}
	else {
		cout << "Estado: OFF" << endl;
	}
	
	cout << "Viento: " << velocidadViento << " m/s a " << direccionViento << " grados" << endl;
	cout << "Turbina orientada a: " << direccionTurbina << " grados" << endl;
	cout << "Potencia: " << potenciaGenerada << " W" << endl;
	cout << "Tension: " << tensionSalida << " V, Corriente: " << corrienteSalida << " A" << endl;
	cout << "-----------------------" << endl;
}

int main()
{
	Aerogenerador a1;                  // constructor por defecto
	Aerogenerador a2(1.5, 24);         // radio 1.5 m, 24 V
	
	a1.encendido();
	a1.medirViento(8.0, 90);
	a1.orientarTurbina();
	a1.calcularPotencia();
	a1.mostrar();
	
	a2.medirViento(12.0, 180);
	a2.orientarTurbina();
	a2.calcularPotencia();   // apagado: da 0
	a2.mostrar();
	
	a2.encendido();
	a2.calcularPotencia();
	a2.mostrar();
	
	return 0;
}
