#define Proyecto "Reloj 3D"
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <utilidades.h>
#include "Source.h"
#include <time.h>
using namespace std;
static GLuint triangulo;
static GLuint  estrella3D;
static GLfloat giro = 0;
static double x = 0.5, y =0.5, z = 3;
time_t  thetime = time(NULL);
struct tm *aTime = localtime(&thetime);
//inicializamos el reloj
static float alphaSegundo = aTime ->tm_sec, alphaHora = (360 / 12) * aTime->tm_hour, alphaMinuto = 360 / (60) * aTime->tm_min;

void timerSegundos(int valor) {
	//Timer para actualizar el segundero
	alphaSegundo += 360 / 60;//(12 * 2* PI);
	glutPostRedisplay();
	glutTimerFunc(valor, timerSegundos, valor);
}
void timerHoras(int valor) {
	alphaHora += (360 / 12);
	glutPostRedisplay();
	glutTimerFunc(valor, timerHoras, valor);
}
void timerMinutos(int valor) {
	int minutos = aTime->tm_min;
	alphaMinuto += (360 / 60);
	glutPostRedisplay();
	glutTimerFunc(valor, timerMinutos, valor);
}
void update() {
	//actualizamos el giro del interior del reloj
	giro += 0.25;
	glutPostRedisplay();
}
void init() {
	triangulo = glGenLists(1); //triangulo vacio
	glNewList(triangulo, GL_COMPILE);
	glBegin(GL_TRIANGLE_STRIP);
	for (int i = 0; i < 4; i++) {
		glVertex3f(1.0*sin( i * 2 * PI / 3), 1.0*cos( i * 2 * PI / 3), 0);
		glVertex3f(0.7*sin( i * 2 * PI / 3), 0.7*cos( i * 2 * PI / 3), 0);
	}
	glEnd();
	glEndList();
	estrella3D = glGenLists(1); //corazón del reloj
	glNewList(estrella3D, GL_COMPILE);
	int red[] = { 1,0,1,0,1,0 };
	int green[] = { 0,1,0,1,0,1 };
	int blue[] = { 1,0,1,0,1,0 };
	for (int i = 0; i < 6; i++) {
		glPushMatrix();
		glRotatef(30 * i, 0, 1, 0);
		glColor3f(red[i], green[i], blue[i]);
		glCallList(triangulo);
		glPopMatrix();
	}
	glEndList();
	glEnable(GL_DEPTH_TEST);

	

}
void display(){
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	gluLookAt(x, y, z, 0, 0, 0, 0, 1, 0);
	glPushMatrix();
	glScalef(0.25,0.25,0.25);
	glRotatef(giro,0,1,0);
	glCallList(estrella3D);
	glPopMatrix();
	for (int i = 0; i < 12; i++) {
		glPushMatrix();
		glRotatef(360 / 12 * i, 0,0 ,1 );
		glTranslatef(0, 1, 0);
		if (i == 0) {
			glColor3f(0, 1, 1);
		}
		else {
			glColor3f(0, 1, 0);
		}
		glScalef(0.15, 0.15, 0.15);
		glCallList(triangulo);
		glPopMatrix();
	}
	//Segundero
	glPushMatrix();
	glRotatef(-alphaSegundo, 0, 0, 1);
	glTranslatef(0, 1, 0);
	glColor3f(0, 0, 1);
	glutSolidSphere(0.03,20,20);
	glPopMatrix();
	//Horas
	glPushMatrix();
	glRotatef(-alphaHora, 0, 0, 1);
	glRotatef(15*alphaSegundo, 0, 1, 0);
	glColor3f(1,0,0);
	glTranslatef(0, 1, 0);
	glutSolidTeapot(0.05);
	glPopMatrix();
	//Minutos
	glPushMatrix();
	glRotatef(-alphaMinuto, 0, 0, 1);
	glRotatef(15 * alphaSegundo, 0, 1, 0);
	glColor3f(1, 1, 0);
	glTranslatef(0, 1, 0);
	glutSolidTeapot(0.05);
	glPopMatrix();	
	//glutWireSphere(1, 20, 20);
	glutSwapBuffers(); // Cambiamos los buffers
	


}
void reshape(GLint w, GLint h) {
	glViewport(0, 0, w, h);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	float razon = (float)w / h;
	static float d = sqrt(x*x + y * y + z * z);
	static float tangente = 1 / d;
	static float angulo = 2 * atan(tangente) * 180 / PI;
	gluPerspective(45, razon, 1, 100);
}

void main(int argc, char** argv) {
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
	glutInitWindowSize(700, 500);
	glutInitWindowPosition(50, 200);
	
	glutCreateWindow(Proyecto);
	init();
	glutDisplayFunc(display);
	glutReshapeFunc(reshape);
	glutIdleFunc(update);
	glutTimerFunc(1000- aTime->tm_sec*1000, timerSegundos, 1000);
	glutTimerFunc(60*60*1000 - aTime->tm_min*60*1000, timerHoras, 60 * 60 * 1000);
	glutTimerFunc( 60 * 1000 - aTime->tm_sec*1000, timerMinutos,  60 * 1000);
	cout << Proyecto << " en marcha" << endl;
	//cin >> x >> y >> z;
	glutMainLoop();
}