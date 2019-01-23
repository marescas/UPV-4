#define PROYECTO "Proyecto Conducción"
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <sstream>

#include <Utilidades.h>
#include "Source.h"
#include <ctime>

using namespace std;
double widtha = 0;
double x = 0, z = 0;
static int y = 1;
float A = 8, T = 100;
float giro = 0.0, velocidad = 0;
GLuint texturas[7];
bool arriba = false, abajo = false, izquierda = false, derecha = false;
bool MODO_ALAMBRICO = false, MODO_LUZ = false, MODO_NIEBLA = false, MODO_HARD = false, MODO_SOLIDARIO = false;
float incrementovelocidad = 0.05;
float incrementoGiro = PI / 90;
float rozamiento = 0.01;
GLfloat farolas[] = { GL_LIGHT2, GL_LIGHT3,GL_LIGHT4,GL_LIGHT5 };
GLint anchuraCarretera = 4; // anchura de la carretera
GLint distanciaFarolas = 40;
int monedas = 1;
bool monedarecogida = false;
bool camaraArriba = false;

GLfloat v0[3] = { 0,0,0 }, v1[3] = { 0,0,0 }, v2[3] = { 0,0,0 }, v4[3] = { 0,0,0 }; // vertices para la carretera

GLfloat carreteradifuso[] = { 0.8,0.8,0.8 };
GLfloat carreteraespecular[] = { 0.3,0.3,0.3 };
float anterior = 4, anterior2 = 4; // anterior punto en el que se empezaban a dibujar las farolas

void actualizarMonedas(int seg) {
	static int antes = 0;
	int ahora, tiempo;
	ahora = glutGet(GLUT_ELAPSED_TIME); //Tiempo transcurrido desde el inicio
	time_t rawtime = time(&rawtime);
	struct tm * timeinfo = localtime(&rawtime);
	tiempo = ahora - antes;

	if (tiempo > 1000) {
		monedarecogida = false;
		antes = ahora;
	}
	

	glutTimerFunc(1500, actualizarMonedas, 1500);
	glutPostRedisplay();
	
}
void dibujaVehiculo() {
	glPushMatrix();
	glTranslatef(0, -0.75, -2);
	glColor3f(1, 0, 0);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, BRONCE);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, ROJO);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 3);
	glRotatef(100 * x, 0, 1, 0);
	//Si recoge teera tamaño incrementa... hasta un max
	float tamaño = 0.3*log(monedas + 1)*0.5;
	if (tamaño > 0.4) {
		tamaño = 0.4;
		glBindTexture(GL_TEXTURE_2D, texturas[5]);
	}
	else {
		glBindTexture(GL_TEXTURE_2D, texturas[3]);
	}
	//2b. Definir como se aplicará la textura en ese objeto
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	if (MODO_ALAMBRICO) glutWireSphere(tamaño, 30, 30); else glutSolidSphere(tamaño, 30, 30);
	glPopMatrix();


}
float fseno(float x) {
	return A * sin(x * ((2 * PI) / T));
}
float dfseno(float x) {
	return ((2 * PI * A) / T) * cos(x*(2 * PI / T));
}
void onTimer(int valor) {
	static int antes = 0;
	int ahora, tiempo;
	ahora = glutGet(GLUT_ELAPSED_TIME); //Tiempo transcurrido desde el inicio
	time_t rawtime = time(&rawtime);
	struct tm * timeinfo = localtime(&rawtime);
	tiempo = ahora - antes; 
	x += velocidad *sin(giro) * tiempo / 1000.0;
	z += velocidad * cos(giro) * tiempo / 1000.0;
	if (arriba) velocidad += incrementovelocidad;
	if (abajo && velocidad > 0.0001) velocidad -= incrementovelocidad;
	if (izquierda) giro += incrementoGiro;
	if (derecha) giro -= incrementoGiro;
	if (velocidad > 15) { //velocidad max
		velocidad = 15;
	}
	stringstream titulo;
	titulo << "Proyecto conducción. Velocidad en m/s: " << velocidad; 
	glutSetWindowTitle(titulo.str().c_str());
	//cout << velocidad << endl;
	arriba = abajo = izquierda = derecha = false;
	antes = ahora;
	glutTimerFunc(25, onTimer, 25);
	glutPostRedisplay();
}
void init()
{
	//configuraciones

	glClearColor(0, 0, 0, 1);
	glEnable(GL_LIGHTING); //Activamos la iluminacion
	glEnable(GL_DEPTH_TEST); //profundidad
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHT1);
	glEnable(GL_LIGHT2);
	glEnable(GL_LIGHT3);
	glEnable(GL_LIGHT4);
	glEnable(GL_LIGHT5);
	glEnable(GL_TEXTURE_2D); // Activamos texturas
	glShadeModel(GL_SMOOTH); //Sombras

	//Luz luna
	GLfloat LunaAmbienteDifusa[] = { 0.5,0.5,0.5,1.0 };
	GLfloat LunaEspecular[] = { 0.0,0.0,0.0,1.0 };
	glLightfv(GL_LIGHT0, GL_AMBIENT, LunaAmbienteDifusa);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, LunaAmbienteDifusa);
	glLightfv(GL_LIGHT0, GL_SPECULAR, LunaEspecular);

	//Luz faros coche
	/*GLfloat farosAmbiente[] = { 0.2,0.2,0.2,1.0 };
	GLfloat farosDifusa[] = { 1.0,1.0,1.0,1.0 };
	GLfloat farosEspecular[] = { 0.3,0.3,0.3,1.0 };
	*/
	glLightfv(GL_LIGHT1, GL_AMBIENT, BLANCO);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, BLANCO);
	glLightfv(GL_LIGHT1, GL_SPECULAR, BLANCO);
	glLightf(GL_LIGHT1, GL_SPOT_CUTOFF, 30.0);
	glLightf(GL_LIGHT1, GL_SPOT_EXPONENT, 3.0);

	//Farolas
	GLfloat farolaAmbienteEspecular[] = { 0.0,0.0,0.0,1.0 };
	GLfloat farolasDifusa[] = { 0.5,0.5,0.2,1.0 };
	GLfloat posemision[] = { 0.0,-1.0,0.0 }; //posicion de emision
	glLightfv(GL_LIGHT2, GL_AMBIENT, BLANCO);
	glLightfv(GL_LIGHT2, GL_DIFFUSE, BLANCO);
	glLightfv(GL_LIGHT2, GL_SPECULAR, BLANCO);
	glLightfv(GL_LIGHT2, GL_SPOT_DIRECTION,posemision );
	glLightf(GL_LIGHT2, GL_SPOT_CUTOFF, 45.0);
	glLightf(GL_LIGHT2, GL_SPOT_EXPONENT, 10.0);

	glLightfv(GL_LIGHT3, GL_AMBIENT, BLANCO);
	glLightfv(GL_LIGHT3, GL_DIFFUSE, BLANCO);
	glLightfv(GL_LIGHT3, GL_SPECULAR, BLANCO);
	glLightfv(GL_LIGHT3, GL_SPOT_DIRECTION, posemision);
	glLightf(GL_LIGHT3, GL_SPOT_CUTOFF, 45.0);
	glLightf(GL_LIGHT3, GL_SPOT_EXPONENT, 10.0);

	glLightfv(GL_LIGHT4, GL_AMBIENT, BLANCO);
	glLightfv(GL_LIGHT4, GL_DIFFUSE, BLANCO);
	glLightfv(GL_LIGHT4, GL_SPECULAR, BLANCO);
	glLightfv(GL_LIGHT4, GL_SPOT_DIRECTION, posemision);
	glLightf(GL_LIGHT4, GL_SPOT_CUTOFF, 45.0);
	glLightf(GL_LIGHT4, GL_SPOT_EXPONENT, 10.0);

	glLightfv(GL_LIGHT5, GL_AMBIENT, BLANCO);
	glLightfv(GL_LIGHT5, GL_DIFFUSE, BLANCO);
	glLightfv(GL_LIGHT5, GL_SPECULAR, BLANCO);
	glLightfv(GL_LIGHT5, GL_SPOT_DIRECTION, posemision);
	glLightf(GL_LIGHT5, GL_SPOT_CUTOFF, 45.0);
	glLightf(GL_LIGHT5, GL_SPOT_EXPONENT, 10.0);

	//Texturas
	//Coche
	/*glGenTextures(1, &texturas[0]);
	glBindTexture(GL_TEXTURE_2D, texturas[0]);
	loadImageFile((char *)"Ferrari.png"); 
	*/
	//carretera
	glGenTextures(1, &texturas[1]);
	glBindTexture(GL_TEXTURE_2D, texturas[1]);
	loadImageFile((char *)"desertroad.png");
	//desierto
	glGenTextures(1, &texturas[2]);
	glBindTexture(GL_TEXTURE_2D, texturas[2]);
	loadImageFile((char *)"desierto.jpg");
	//cielo
	glGenTextures(1, &texturas[3]);
	glBindTexture(GL_TEXTURE_2D, texturas[3]);
	loadImageFile((char *)"cielo.jpg");

	glGenTextures(1, &texturas[4]);
	glBindTexture(GL_TEXTURE_2D, texturas[4]);
	loadImageFile((char *)"cocacola.jpg");
	glGenTextures(1, &texturas[5]);
	glBindTexture(GL_TEXTURE_2D, texturas[5]);
	loadImageFile((char *)"arcoiris.jpg");

	glGenTextures(1, &texturas[6]);
	glBindTexture(GL_TEXTURE_2D, texturas[6]);
	loadImageFile((char *)"cielo_noche.jpg");
	
}
void onKey(unsigned char letra, int xp, int yp) {
	switch (letra) {
	case 's':
		if (MODO_ALAMBRICO) MODO_ALAMBRICO = false; else MODO_ALAMBRICO = true;
		break;
	case 'l':
		if (MODO_LUZ) MODO_LUZ = false; else MODO_LUZ = true;
		break;
	case 'n':
		if (MODO_NIEBLA) MODO_NIEBLA = false; else MODO_NIEBLA = true;
		break;
	case 27:
		exit(0);
	case 'h': // modo hard
		if (!MODO_HARD) { 
			A = 12, T = 70;
			MODO_HARD = true;
		}
		else {
			A = 8, T = 100; 
			MODO_HARD = false;
		}
		break;
	case 'c':
		if (MODO_SOLIDARIO) MODO_SOLIDARIO = false; else MODO_SOLIDARIO = true;
		break;
	case 'a':
		if (camaraArriba) camaraArriba = false; else camaraArriba = true;
		break;
	case 'p':
		saveScreenshot((char*)"photo.jpg",600,600);
		break;

	}
	glutPostRedisplay();

}
void onSpecialKey(int tecla, int xp, int yp) {
	switch (tecla) {
	case GLUT_KEY_UP:
		arriba = true;
		break;
	case GLUT_KEY_DOWN:
		abajo = true;
		break;
	case GLUT_KEY_LEFT:
		izquierda = true;
		break;
	case GLUT_KEY_RIGHT:
		derecha = true;
		break;
	}
	//cout << tecla;
	glutPostRedisplay();

}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	/*glPushMatrix();
	if (MODO_LUZ) {
		glBindTexture(GL_TEXTURE_2D, texturas[3]);
	}
	else {
		glBindTexture(GL_TEXTURE_2D, texturas[6]);
	}

	//2b. Definir como se aplicará la textura en ese objeto
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	texturarFondo();
	glPopMatrix();
	*/
	
	//MODO Alambrico --> activa modo sin luces ni texturas

	if (MODO_ALAMBRICO) {
		glDisable(GL_LIGHTING); //desactivamos las luces
		glDisable(GL_TEXTURE_2D); // desactivamos las texturas
	}
	else {
		glEnable(GL_LIGHTING); //activamos las luces
		glEnable(GL_TEXTURE_2D); // activamos las texturas
	}
	if (MODO_NIEBLA) {
		glEnable(GL_FOG);
		glFogfv(GL_FOG_COLOR, BLANCO);
		glFogf(GL_FOG_DENSITY, 0.05);
	}
	else {
		glDisable(GL_FOG);
	}
	
	glMatrixMode(GL_MODELVIEW);
	//Colocamos la luna
	GLfloat posicionLuna[] = { 0.0, 10.0, 0.0, 0.0 };
	glLightfv(GL_LIGHT0, GL_POSITION, posicionLuna);
	//Dibujo farolas y monedas
	GLfloat inicio = anterior;
	for (int i = 0; i < 4; i++) {
		inicio += distanciaFarolas; // distancia entre las farolas
		float xfarola = inicio;
		float zfarola = fseno(xfarola);
		GLfloat posicionFarola[] = { xfarola,4,zfarola,1.0 };
		
		glLightfv(farolas[i], GL_POSITION, posicionFarola);
		
		glPushMatrix();
		glBindTexture(GL_TEXTURE_2D, texturas[5]);

		//2b. Definir como se aplicará la textura en ese objeto
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		
		glTranslatef(xfarola, 0.3, zfarola);
		if (abs(xfarola - x) < 0.5 && abs(zfarola-  z)< 0.5 && !monedarecogida) {
			monedas++;
			cout << "Teteras recogidas: " <<monedas-1 <<endl;
			monedarecogida = true;
		}
		glRotatef(10*x, 0, 1, 0);
		if (MODO_ALAMBRICO) glutWireTeapot(0.1); else glutSolidTeapot(0.1);
		glPopMatrix();
		
		
	}

	GLfloat inicio2 = anterior2;
	for (int i = 0; i < 4; i++) {
		inicio2 += 150; // distancia entre las señales
		float xfarola = inicio2;
		float zfarola = fseno(xfarola);
		glPushMatrix();
		glBindTexture(GL_TEXTURE_2D, texturas[4]);

		//2b. Definir como se aplicará la textura en ese objeto
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		if (MODO_ALAMBRICO) {
			glPolygonMode(GL_BACK, GL_LINE);
			glPolygonMode(GL_FRONT, GL_LINE);
		}
		else {
			glPolygonMode(GL_BACK, GL_FILL);
			glPolygonMode(GL_FRONT, GL_FILL);
		}
		glTranslatef(xfarola, 1, zfarola);
		GLfloat g0[3] = { 1 , 1,-4 }, g1[3] = { 1, 1, +4 }, g2[3] = { 1, 6, +4 }, g3[3] = { 1, 6, -4 };
		//quad(g1, g0, g3, g2, 1, 1);
		quadtex(g0, g1, g2, g3, 0, 1, 0, 1, 50, 50);
		glPopMatrix();


	}
	if (x > inicio) {
		anterior = inicio;
	}
	if (x > inicio2) {
		anterior2 = inicio2;
	}
	glLoadIdentity(); // Todo lo escrito anteriormente se queda fijo en la posición determinada
	if(!camaraArriba) dibujaVehiculo(); // Como esta antes del lookat va pegado a la camara
	//Posición faro vehiculo
	GLfloat posl1[] = { 0.5, 0.9, -5, 2.0 };
	GLfloat dir_centrall1[] = { 0.0, -1.0, -1.0 };
	glLightfv(GL_LIGHT1, GL_POSITION, posl1);
	glLightfv(GL_LIGHT1, GL_SPOT_DIRECTION, dir_centrall1);

	if (MODO_SOLIDARIO) {
		if (MODO_ALAMBRICO) {
			glPushMatrix();
			glTranslatef(-0.75, -0.75, -2);
			glScalef(0.25, 0.2*velocidad, 0);
			glColor3f(1, 0, 0);
			glutWireCube(1);
			glPopMatrix();
		}
		else {
			glPushMatrix();
			glTranslatef(-0.75, -0.75, -2);
			glColor3f(1, 0, 0);
			glScalef(0.25, 0.2*velocidad, 0);
			glutSolidCube(1);
			glPopMatrix();
		}

	}

	if(!camaraArriba)
		gluLookAt(x, y, z, 10 * sin(giro) + x, 0, 10 * cos(giro) + z, 0, 1, 0); // Situo la camara
	else
		gluLookAt(x, 100, z, 10 * sin(giro) + x, 0, 10 * cos(giro) + z, 0, 1, 0); // Situo la camara

	//Dibujo Carretera dinamica 
	float comienzo_carretera = x-10, vfseno = fseno(comienzo_carretera);
	float derivada = dfseno(comienzo_carretera);
	GLfloat precalculo[3] = { comienzo_carretera,0,vfseno };
	GLfloat tz[3] = { -derivada,0,1 };
	GLfloat normales[3] = { (1 / sqrt(1 + derivada * derivada))*tz[0] , 0 ,(1 / sqrt(1 + derivada * derivada))*tz[2] };
	for (int i = 0; i < 3; i++) {
		v0[i] = precalculo[i] - (normales[i] * anchuraCarretera);
		v4[i] = precalculo[i] + (normales[i] * anchuraCarretera);	
	}
	for (int i = 1; i < 100; i++) {
		float aux = comienzo_carretera + i;
		vfseno = fseno(aux);
		float derivada = dfseno(aux);
		GLfloat precalculo2[3] = { aux,0,vfseno };
		GLfloat tz[3] = { -derivada,0,1 };
		GLfloat normales2[3] = { (1 / sqrt(1 + derivada * derivada))*tz[0] , 0 ,(1 / sqrt(1 + derivada * derivada))*tz[2] };
		for (int i = 0; i < 3; i++) {
			v1[i] = precalculo2[i] - (normales2[i] * anchuraCarretera);
			v2[i] = precalculo2[i] + (normales2[i] * anchuraCarretera);
			//cout << v1[i] << v2[i] << v4[i]  << v0[i] << endl;
		}
		glPushMatrix();
		if (MODO_ALAMBRICO) {
			glPolygonMode(GL_BACK, GL_LINE);
			glPolygonMode(GL_FRONT, GL_LINE);
		}
		else {
			glPolygonMode(GL_BACK, GL_FILL);
			glPolygonMode(GL_FRONT, GL_FILL);
		}
		
		//Aplicamos la textura
		glBindTexture(GL_TEXTURE_2D, texturas[1]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);


		glColor3f(0, 1, 0);
		//Material para la carretera
		glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, carreteradifuso);
		glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, carreteraespecular);
		glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 3);

		quadtex(v4, v0, v1, v2,0,1,0,1,50,50);
		glPopMatrix();
		for (int i = 0; i < 3; i++) {
			v0[i] = v1[i];
			v4[i] = v2[i];
		}
	}
	//Fin dibujo carretera
	
	//Desierto
	glPushMatrix();
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, BLANCO);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, BLANCO);
	glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 4);
	glBindTexture(GL_TEXTURE_2D, texturas[2]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	glColor3f(0, 0, 1);

	GLfloat p0[3] = { 100 + x, -0.1, -100 - z }, p1[3] = { 100 + x, -0.1, 100 - z }, p2[3] = { -100 - x, -0.1, 100 + z }, p4[3] = { -100 - x, -0.1, -100 - z };
	quadtex(p0, p1, p2, p4, 0, 10, 0, 10, 10 * 10, 5 * 10);
	glPopMatrix();
	
	//Cilindro
	glPushMatrix();
	if (MODO_LUZ) {
		glBindTexture(GL_TEXTURE_2D, texturas[3]);
	}
	else {
		glBindTexture(GL_TEXTURE_2D, texturas[6]);
	}
	float alpha = 2 * PI / 50;
	GLfloat cil0[3] = { 200 * cos(0) + x,100,200 * -sin(0) + z };
	GLfloat cil1[3] = { 200 * cos(0) + x,-55,200 * -sin(0) + z };
	GLfloat cil2[3];
	GLfloat cil3[3];
	for (int i = 1; i <= 50; i++) {
		cil2[0] = 200 * cos(i*alpha) + x;
		cil2[1] = 100;
		cil2[2] = 200 * -sin(i*alpha) + z;
		cil3[0] = 200 * cos(i*alpha) + x;
		cil3[1] = -55;
		cil3[2] = 200 * -sin(i*alpha) + z;
		//2b. Definir como se aplicará la textura en ese objeto
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		quadtex(cil3, cil1, cil0, cil2, (i) / 50.0 + 0.5, (i - 1) / 50.0 + 0.5, 0, 1);
		for (int j = 0; j < 3; j++) {
			cil0[j] = cil2[j];
			cil1[j] = cil3[j];
		}

	}
	glPopMatrix();
	
	if(MODO_LUZ) glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE); 
	else glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	
	glutSwapBuffers();

}

void reshape(GLint w, GLint h)

{

	// Toda el area como marco
	glViewport(0, 0, w, h);


	widtha = w;
	// Razon de aspecto

	float ra = float(w) / float(h);



	// Matriz de la proyeccion



	glMatrixMode(GL_PROJECTION);

	glLoadIdentity();



	// Camara ortografica con isometria

	//if(ra>1) glOrtho(-2*ra, 2*ra, -2, 2, -2, 2);

	//else glOrtho(-2, 2, -2 / ra, 2 / ra, -2, 2);



	// Camara perspectiva

	gluPerspective(45, ra, 1, 200);

}

void main(int argc, char** argv)

{
	FreeImage_Initialise(); //Inicializar Freeimagen --> texturas
	// Initializations

	glutInit(&argc, argv);

	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);

	glutInitWindowSize(600, 600);
	widtha = 600;

	glutCreateWindow(PROYECTO);

	init();



	// Callbacks

	glutDisplayFunc(display);

	glutReshapeFunc(reshape);
	glutKeyboardFunc(onKey);
	glutSpecialFunc(onSpecialKey); // teclas de arriba abajo izquierda y derecha para moverse
	glutTimerFunc(25, onTimer, 25);
	glutTimerFunc(1000, actualizarMonedas, 1000);


	cout << "arriba / abajo --> acelerar / decelerar " << endl << "izquierda / derecha --> girar"
		<< endl << "s --> activa / desactiva modo alambrico" << endl << "l --> diurno / nocturno "
		<< endl << "n--> activa / desactiva niebla" << endl <<
		"h --> activa / desactiva modo hard (dificil) " << endl <<
		"c --> activa objeto solidario a la camara" << endl <<
		"a --> situa la camara arriba" << endl<<
		"p --> genera una fotografía del estado actual del programa"<<endl;


	// Event loop

	glutMainLoop();

	//Liberar Freeimage
	FreeImage_DeInitialise();



}