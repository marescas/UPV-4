/*****************************************************************************/
/**  Analizador lexico                                         Grupo 8 LPyPL**/
/**  V. 18.1                                                                **/
/*****************************************************************************/
%{
#include <stdio.h>
#include <string.h>
#include "header.h"
#include "asin.h"

%}
/*----------------------------------------------------------------------
  Dado que las funciones "input()" y "unput(c)" son costosas y no las
  utilizaremos, evitaremos que se generen automaticamente sus rutinas
  correspondientes desactivandolas mediante las siguientes opciones:
----------------------------------------------------------------------*/
%option noinput
%option nounput
/*----------------------------------------------------------------------
  Para mantener el numero de linea actual en la variable global yylineno
----------------------------------------------------------------------*/
%option yylineno

letra           [a-zA-Z]
delimitador     [ \t\n]+
digito          [0-9]
entero          {digito}+
constante       {entero}|("."){entero}|{entero}(".")|{entero}("."){entero}
identificador   {letra}({letra}|{digito}|_)*
comentario      \/\/.*


%%
{comentario}    { if (verbosidad) ECHO; }
{delimitador}   { if (verbosidad) ECHO; }
"true"          { if (verbosidad) ECHO; return(TRUE_); }
"false"         { if (verbosidad) ECHO; return(FALSE_); }
"int"           { if (verbosidad) ECHO; return(INT_); }
"bool"          { if (verbosidad) ECHO; return(BOOL_); }
"read"          { if (verbosidad) ECHO; return(READ_); }
"print"         { if (verbosidad) ECHO; return(PRINT_); }
"for"           { if (verbosidad) ECHO; return(FOR_); }
"if"            { if (verbosidad) ECHO; return(IF_); }
"else"          { if (verbosidad) ECHO; return(ELSE_); }


"+"             { if (verbosidad) ECHO; return(OPMAS_); }
"="             { if (verbosidad) ECHO; return(OPIGU_);  }
"+="            { if (verbosidad) ECHO; return(OPMASIGU_); }
"-="            { if (verbosidad) ECHO; return(OPMENOSIGU_); }
"*="            { if (verbosidad) ECHO; return(OPPORIGU_); }
"/="            { if (verbosidad) ECHO; return(OPDIVIGU_); }
"&&"            { if (verbosidad) ECHO; return(OPAND_); }
"||"            { if (verbosidad) ECHO; return(OPOR_); }
"=="            { if (verbosidad) ECHO; return(OPIGUALDAD_); }
"!="            { if (verbosidad) ECHO; return(OPDISTINTOIGUAL_); }
"-"             { if (verbosidad) ECHO; return(OPMENOS_); }
"*"             { if (verbosidad) ECHO; return(OPPOR_); }
"%"             { if (verbosidad) ECHO; return(OPMODULO_); }
"/"             { if (verbosidad) ECHO; return(OPDIV_); }
"("             { if (verbosidad) ECHO; return(PARA_); }
")"             { if (verbosidad) ECHO; return(PARC_); }
">"             { if (verbosidad) ECHO; return(OPMAYOR_); }
">="            { if (verbosidad) ECHO; return(OPMAYIGU_); }
"<"             { if (verbosidad) ECHO; return(OPMENOR_); }
"<="            { if (verbosidad) ECHO; return(OPMENIGU_);  }
"!"             { if (verbosidad) ECHO; return(OPDISTINTO_);  }
"++"            { if (verbosidad) ECHO; return(OPINCREMENTO_);  }
"--"            { if (verbosidad) ECHO; return(OPDECREMENTO_);  }
";"             { if (verbosidad) ECHO; return(PUNTOCOMA_); }
"{"             { if (verbosidad) ECHO; return(LLAVEA_); }
"}"             { if (verbosidad) ECHO; return(LLAVEC_); }
"]"             { if (verbosidad) ECHO; return(CORCHC_); }
"["             { if (verbosidad) ECHO; return(CORCHA_); }
{identificador} { if (verbosidad) ECHO; yylval.ident = strdup(yytext); return(IDENTIFICADOR_); }
{constante}     { if (verbosidad) ECHO; yylval.cent = atoi(yytext); return(CTE_); }
.               {yyerror("Caracter desconocido");}
%%
