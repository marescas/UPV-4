/*****************************************************************************/
/**  ANALIZADOR SINTACTICO                                     Grupo 8 LPyPL**/
/**  (º_º)                                                                  **/
/*****************************************************************************/

%{
#include <stdio.h>
#include <string.h>
#include "libtds.h"
#include "header.h"
#include "libgci.h"
%}

%union{
  int cent ; /* Valor de la cte numerica entera para el terminal "cte" */
  char *ident ; /* Nombre del identificador */
  EXP expr; /*for expresions*/
  FOR_INST instfor;
}

%token TRUE_ FALSE_ INT_ BOOL_ READ_ PRINT_ FOR_ IF_ ELSE_
%token OPMAS_ OPIGU_ OPMASIGU_ OPMENOSIGU_ OPPORIGU_ OPDIVIGU_ OPMENOS_ OPPOR_ OPMODULO_ OPDIV_ OPINCREMENTO_ OPDECREMENTO_
%token OPAND_ OPOR_ OPIGUALDAD_ OPDISTINTOIGUAL_ OPMAYOR_ OPMAYIGU_ OPMENOR_ OPMENIGU_ OPDISTINTO_
%token PARA_ PARC_ PUNTOCOMA_ LLAVEA_ LLAVEC_ CORCHC_ CORCHA_

%token<cent> CTE_ 
%token<ident> IDENTIFICADOR_

%type<cent> tipoSimple operadorUnario operadorIncremento operadorMultiplicativo 
%type<cent> operadorAditivo operadorRelacional operadorIgualdad operadorAsignacion 
%type<cent> operadorLogico instruccionSeleccion 

%type<expr> constante expresionOpcional expresion expresionIgualdad expresionRelacional expresionAditiva 
%type<expr> expresionMultiplicativa expresionUnitaria expresionSufija instruccionAsignacion

%type<instfor> instruccionIteracion 

%%

programa    :   { dvar = 0; si = 0;} 
                LLAVEA_ secuenciaSentencias LLAVEC_ 
                { 
                    if (verTDS) mostrarTDS(); 
                    emite(FIN,crArgNul(),crArgNul(),crArgNul());
                }
            ;
secuenciaSentencias     : sentencia 
                        | secuenciaSentencias sentencia  
                        ;
sentencia   : declaracion  
            | instruccion  
            ;
declaracion : tipoSimple IDENTIFICADOR_ PUNTOCOMA_
            {
                if (! insTSimpleTDS($2, $1, dvar) )
                    yyerror ("Identificador repetido");
                else dvar += TALLA_TIPO_SIMPLE;   
            }
            | tipoSimple IDENTIFICADOR_ OPIGU_ constante PUNTOCOMA_
            {   
                if (! insTSimpleTDS($2, $1, dvar)) {
                   yyerror ("Identificador repetido");
                }
                else dvar += TALLA_TIPO_SIMPLE;
                
                SIMB sim = obtenerTDS($2);
                emite(EASIG, crArgEnt($4.pos), crArgNul(), crArgPos(sim.desp));

            }
            | tipoSimple IDENTIFICADOR_ CORCHA_ CTE_ CORCHC_ PUNTOCOMA_ 
            {
                int numelem = $4;
                if ($4 <= 0) {
                    yyerror("Talla inapropiada del array");
                    numelem = 0;
                }
                if ( ! insTVectorTDS($2, T_ARRAY, dvar, $1, numelem) ) {
                    yyerror ("Identificador repetido");
                }
                else dvar += numelem * TALLA_TIPO_SIMPLE;
            }
            ;
tipoSimple  : INT_  {$$ = T_ENTERO;}
            | BOOL_ {$$ = T_LOGICO;}
            ;
instruccion : LLAVEA_ listaInstrucciones LLAVEC_
            | instruccionEntradaSalida
            | instruccionAsignacion
            | instruccionSeleccion
            | instruccionIteracion
            ;
listaInstrucciones  : listaInstrucciones instruccion
                    |  
                    ;

instruccionAsignacion   : IDENTIFICADOR_ operadorAsignacion expresion PUNTOCOMA_
                        {  
                          SIMB sim = obtenerTDS($1);
                          if($3.tipo != T_ERROR){
                            if (sim.tipo == T_ERROR) yyerror("Objeto no declarado");
                            else if (! ((sim.tipo == T_ENTERO && $3.tipo == T_ENTERO) ||
                            (sim.tipo == T_LOGICO && $3.tipo == T_LOGICO)))
                                yyerror("Error de tipos en la instrucción de asignación");
                          }
                          if($2 != EASIG){
                              emite($2, crArgPos(sim.desp), crArgPos($3.pos), crArgPos(sim.desp));
                          } else{
                              emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos(sim.desp));
                          }
                          
                          
                        }
                        | IDENTIFICADOR_ CORCHA_ expresion CORCHC_ operadorAsignacion expresion PUNTOCOMA_
                        {
                            SIMB sim = obtenerTDS($1);
                            if($6.tipo != T_ERROR){
                                if (sim.tipo == T_ERROR ) {yyerror("Objeto no declarado");}
                                else if (!(sim.tipo == T_ARRAY)) { yyerror("Error de tipos, debe ser de tipo Array");}
                                else if (!($3.tipo == T_ENTERO)) { yyerror("El indice del array debe ser entero"); } 
                                else if (!($6.tipo == sim.telem)) { yyerror("Error de compatibilidad de tipos"); }
                            }
                            $$.pos = creaVarTemp();
                            if($5 == EASIG){
                              emite(EVA, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($6.pos)); 
                            } else{
                              emite(EAV, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($$.pos)); 
                              emite($5, crArgPos($$.pos), crArgPos($6.pos), crArgPos($$.pos)); 
                              emite(EVA, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($$.pos)); 
                            }
                                                       
                        }
                        ;
instruccionEntradaSalida    : READ_ PARA_ IDENTIFICADOR_ PARC_ PUNTOCOMA_
                            {
                                SIMB sim = obtenerTDS($3);
                                if (sim.tipo != T_ENTERO) {
                                    yyerror("Identificador no válido para la lectura. Debe ser de tipo entero");
                                }
                                emite(EREAD, crArgNul(), crArgNul(), crArgPos(sim.desp));
                            }
                            | PRINT_ PARA_ expresion PARC_ PUNTOCOMA_
                            {
                                if($3.tipo != T_ERROR){
                                    if ($3.tipo != T_ENTERO) {
                                        yyerror("La expresion a imprimir debe ser de tipo entero");
                                    }
                                }
                                emite(EWRITE, crArgNul(), crArgNul(), crArgPos($3.pos));
                            }
                            ;

/*Ojo, cuando las instrucciones llevan acciones a mitad de regla, estas cuentan como un dolar mas*/
/*Internamente, se le asigna un $27*/
instruccionSeleccion        : IF_ PARA_ expresion PARC_ 
                              {
                                if($3.tipo != T_ERROR){
                                    if ($3.tipo != T_LOGICO){
                                        yyerror("Error, aprende a programar. Debe ser tipo logico.");
                                    }
                                }
                                $<cent>$ = creaLans(si);
                                emite(EIGUAL, crArgPos($3.pos), crArgEnt(0), crArgEtq(-1));
                              } 
                              instruccion
                              {
                                    $<cent>$ = creaLans(si);
                                    emite(GOTOS, crArgNul(), crArgNul(), crArgEtq(-1));
                                    completaLans($<cent>5, crArgEnt(si));                                    
                              }
                              ELSE_ instruccion 
                              {
                                    completaLans($<cent>7, crArgEnt(si));
                              }         
                            
                            ;
                      
instruccionIteracion    : FOR_ PARA_ expresionOpcional PUNTOCOMA_
                            {   
                                $<cent>$ = si;
                            }
                          expresion PUNTOCOMA_
                            {
                                if($6.tipo != T_ERROR){
                                    if ($6.tipo != T_LOGICO){
                                        yyerror("La guarda del bucle no es correcta. Debe ser tipo logico.");
                                    }
                                }
                                $<instfor>$.lv = creaLans(si); emite(EIGUAL, crArgPos($6.pos), crArgEnt(1), crArgEtq(-1));
                                $<instfor>$.lf = creaLans(si); emite(GOTOS, crArgNul(), crArgNul(), crArgEtq(-1));
                                $<instfor>$.aux = si;
                            }
                          expresionOpcional PARC_
                            {
                                emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<cent>5));
                                completaLans($<instfor>8.lv, crArgEnt(si));
                            }
                          instruccion
                            {
                                emite(GOTOS, crArgNul(), crArgNul(), crArgEtq($<instfor>8.aux));
                                completaLans($<instfor>8.lf, crArgEnt(si));
                            }

                        ;
expresionOpcional   : expresion
                    {
                      $$.tipo = $1.tipo;
                      $$.pos = $1.pos;
                    }
                    | IDENTIFICADOR_ OPIGU_ expresion
                    {
                      $$.tipo = T_ERROR;
                      SIMB sim = obtenerTDS($1);
                      if(sim.tipo != T_ERROR && $3.tipo != T_ERROR){
                        if(sim.tipo == $3.tipo){
                            $$.tipo = sim.tipo;
                        }else{
                            yyerror("Tipos no compatibles en la asignacion :P ");
                        }
                      }
                      $$.pos = creaVarTemp();
                      emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos($$.pos));
                      emite(EASIG, crArgPos($3.pos), crArgNul(), crArgPos(sim.desp));
                    }
                    |  { $$.tipo = T_VACIO; }
                    ;                    
expresion : expresionIgualdad
          {
            $$.tipo = $1.tipo;
            $$.pos = $1.pos;
          }
          | expresion operadorLogico expresionIgualdad
          {
            $$.tipo = T_ERROR;
            if($1.tipo != T_ERROR && $3.tipo != T_ERROR){
                if (!($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)){
                    yyerror("Los operandos son incorrectos en la expresion logica");
                } else {
                    $$.tipo = T_LOGICO;
                }
            }
            $$.pos = creaVarTemp();
            if ($2 == AND) {
                emite(EMULT, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
            }else {
                emite(ESUM, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                emite(EMENEQ, crArgPos($$.pos), crArgEnt(1), crArgEtq(si+2));
                emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
            }
          }
          ;
expresionIgualdad : expresionRelacional
                  {
                    $$.tipo = $1.tipo;
                    $$.pos = $1.pos;
                  }
                  | expresionIgualdad operadorIgualdad expresionRelacional
                  {
                    $$.tipo = T_ERROR;
                    if($1.tipo != T_ERROR && $3.tipo != T_ERROR){
                        if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)||($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))){
                        yyerror("Error de tipo en la expresion de igualdad");
                        } else {
                            $$.tipo = T_LOGICO;
                        }
                    }
                    $$.pos = creaVarTemp();
                    emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                    emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
                    emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
                  }
                  ;
expresionRelacional : expresionAditiva
                    {
                        $$.tipo = $1.tipo;
                        $$.pos = $1.pos;
                    }
                    | expresionRelacional operadorRelacional expresionAditiva
                    {
                        $$.tipo = T_ERROR;
                        if($1.tipo != T_ERROR && $3.tipo != T_ERROR){
                            if (!(($1.tipo == T_LOGICO && $3.tipo == T_LOGICO)||($1.tipo == T_ENTERO && $3.tipo == T_ENTERO))){
                                yyerror("Error de tipos en la expresion relacional");
                            } else {
                                $$.tipo = T_LOGICO;
                            }
                        }
                        $$.pos = creaVarTemp();
                        emite(EASIG, crArgEnt(1), crArgNul(), crArgPos($$.pos));
                        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgEtq(si+2));
                        emite(EASIG, crArgEnt(0), crArgNul(), crArgPos($$.pos));
                    }
                    ;
expresionAditiva    : expresionMultiplicativa
                    {
                        $$.tipo = $1.tipo;
                        $$.pos = $1.pos;
                    }
                    | expresionAditiva operadorAditivo expresionMultiplicativa
                    { 
                        $$.tipo = T_ERROR;
                        if($1.tipo != T_ERROR && $3.tipo != T_ERROR){
                            if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)){
                                yyerror("Error de tipos en la expresion aditiva");
                            } else {
                                $$.tipo = $1.tipo;
                            }
                        }
                        $$.pos = creaVarTemp();
                        emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));

                    }
                    ;
expresionMultiplicativa : expresionUnitaria { 
                            $$.tipo = $1.tipo;
                            $$.pos = $1.pos;
                        }
                        | expresionMultiplicativa operadorMultiplicativo expresionUnitaria
                        { 
                            $$.tipo = T_ERROR;
                            if($3.tipo != T_ERROR && $1.tipo != T_ERROR){
                                if (!($1.tipo == T_ENTERO && $3.tipo == T_ENTERO)){
                                    yyerror("Error de tipos en la expresion multiplicativa");
                                } else {
                                    $$.tipo = $1.tipo;
                                }
                            }
                            $$.pos = creaVarTemp();
                            emite($2, crArgPos($1.pos), crArgPos($3.pos), crArgPos($$.pos));
                        }
                        ;
expresionUnitaria : expresionSufija
                  {
                    $$.tipo = $1.tipo;
                    $$.pos = $1.pos;
                  }
                  | operadorUnario expresionUnitaria
                  {
                    $$.tipo = T_ERROR;
                    if($2.tipo != T_ERROR){
                        if (($1 == ESUM || $1 == EDIF) && $2.tipo == T_ENTERO) {
                            $$.tipo = $2.tipo;
                        } else if ($1 == NOT && $2.tipo == T_LOGICO) {
                            $$.tipo = $2.tipo;
                        } else {
                            yyerror("Error de tipos en la expresion unaria.");
                        }
                    }
                    $$.pos = creaVarTemp();
                    if ($1 == NOT) {
                        emite(EDIF, crArgEnt(1), crArgPos($2.pos), crArgPos($$.pos));    
                    } else {
                        emite($1, crArgEnt(0), crArgPos($2.pos), crArgPos($$.pos));
                    }
                    
                  }
                  | operadorIncremento IDENTIFICADOR_
                  {
                    $$.tipo = T_ERROR;
                    SIMB simb = obtenerTDS($2);
                    if (simb.tipo != T_ERROR) {
                      if (simb.tipo == T_ENTERO) {
                        $$.tipo = simb.tipo;
                      } else {
                        yyerror("No se puede incrementar algo que no sea de tipo entero");
                      }
                    }
                    //Incrementa el valor de la variable y después propaga su valor.
                    $$.pos = creaVarTemp();
                    emite($1, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp));
                    emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($$.pos));
                  }
                  ;
expresionSufija : PARA_ expresion PARC_
                {
                  $$.tipo = $2.tipo;
                  $$.pos = $2.pos;
                }
                | IDENTIFICADOR_ operadorIncremento
                {
                  $$.tipo = T_ERROR;
                  SIMB simb = obtenerTDS($1);
                  if (simb.tipo != T_ERROR){
                    if(simb.tipo == T_ENTERO){
                        $$.tipo = simb.tipo;
                    } else {
                        yyerror("Error de tipos en la expresion sufija");
                    }
                  }
                  //Propaga el valor de la variable y después incrementa el valor de ésta
                  $$.pos = creaVarTemp();
                  emite(EASIG, crArgPos(simb.desp), crArgNul(), crArgPos($$.pos)); 
                  emite($2, crArgPos(simb.desp), crArgEnt(1), crArgPos(simb.desp)); 
                }
                | IDENTIFICADOR_ CORCHA_ expresion CORCHC_
                {
                  $$.tipo = T_ERROR;
                  SIMB sim = obtenerTDS($1);
                  if(sim.tipo != T_ERROR && $3.tipo != T_ERROR){
                    if($3.tipo == T_ENTERO && sim.tipo == T_ARRAY){
                        $$.tipo = sim.telem;
                    } else {
                      yyerror("Error a la hora de operar con el array"); 
                    }
                  }     
                  $$.pos = creaVarTemp();
                  emite(EAV, crArgPos(sim.desp), crArgPos($3.pos), crArgPos($$.pos));        
                }
                | IDENTIFICADOR_
                {
                  $$.tipo = T_ERROR;
                  SIMB sim = obtenerTDS($1);
                  if(sim.tipo != T_ERROR){
                    $$.tipo = sim.tipo;
                  }else{
                    yyerror("Identificador no declarado");
                  }
                  $$.pos = creaVarTemp();
                  emite(EASIG, crArgPos(sim.desp), crArgNul(), crArgPos($$.pos)); 
                                 
                }
                | constante 
                { 
                    $$.tipo = $1.tipo; 
                    $$.pos = creaVarTemp();
                    emite(EASIG, crArgEnt($1.pos), crArgNul(), crArgPos($$.pos));
                }
                ;
constante : CTE_    { $$.tipo = T_ENTERO; $$.pos = $1;  }
          | TRUE_   { $$.tipo = T_LOGICO; $$.pos = 1;    }
          | FALSE_  { $$.tipo = T_LOGICO; $$.pos = 0;  }
          ;
operadorAsignacion : OPIGU_ { $$ = EASIG; }        
                   | OPMASIGU_ { $$ = ESUM; }      
                   | OPMENOSIGU_ { $$ = EDIF; }    
                   | OPPORIGU_ { $$ = EMULT; }
                   | OPDIVIGU_ { $$ = EDIVI; }     
                   ;
operadorLogico  : OPAND_ { $$ = AND; } 
                | OPOR_ { $$ = OR; }   
                ;
operadorIgualdad : OPIGUALDAD_ { $$ = EIGUAL; }     
                 | OPDISTINTOIGUAL_ { $$ = EDIST; }
                 ;
operadorRelacional : OPMAYOR_ { $$ = EMAY; }
                   | OPMENOR_ { $$ = EMEN; }   
                   | OPMAYIGU_ { $$ = EMAYEQ; } 
                   | OPMENIGU_ { $$ = EMENEQ; } 
                   ;
operadorAditivo : OPMAS_    { $$ = ESUM; } 
                | OPMENOS_  { $$ = EDIF; }
                ;
operadorMultiplicativo : OPPOR_ { $$ = EMULT; }
                       | OPDIV_ { $$ = EDIVI; }    
                       | OPMODULO_  { $$ = RESTO; }  
                       ;
operadorUnario : OPMAS_         { $$ = ESUM; }
               | OPMENOS_       { $$ = EDIF; }
               | OPDISTINTO_    { $$ = NOT; }
               ;
operadorIncremento : OPINCREMENTO_ { $$ = ESUM; }
                   | OPDECREMENTO_ { $$ = EDIF; }
                   ;
%%
