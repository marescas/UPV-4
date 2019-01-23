/*****************************************************************************/
/**   Ejemplo de un posible fichero de cabeceras ("header.h") donde situar  **/
/** las definiciones de constantes, variables y estructuras para MenosC.18  **/
/** Los alumos deberan adaptarlo al desarrollo de su propio compilador.     **/
/*****************************************************************************/
#ifndef _HEADER_H
#define _HEADER_H

/****************************************************** Constantes generales */
#define TRUE  1
#define FALSE 0
#define TALLA_TIPO_SIMPLE 1
/****************************************************** Constantes propias*/
#define NOT 19
#define AND 20
#define OR 21
/************************************* Variables externas definidas en el AL */
extern int yylex();
extern int yyparse();

extern FILE *yyin;
extern int   yylineno;
extern char *yytext;

typedef struct exp /****** Estructura para las expresiones */
{              
  int tipo;        
  int pos;         
}EXP;

typedef struct for_inst /****** Estructura para los for */
{
  int ini;            
  int lv;        
  int lf; 
  int aux;        
}FOR_INST;

/********************* Variables externas definidas en el Programa Principal */
extern void yyerror(const char * msg) ;   /* Tratamiento de errores          */

extern int verbosidad;              /* Flag para saber si se desea una traza */
extern int numErrores;              /* Contador del numero de errores        */
extern int verTDS;
extern int dvar;
extern int si;

#endif  /* _HEADER_H */
/*****************************************************************************/
