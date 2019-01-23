/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_ASIN_H_INCLUDED
# define YY_YY_ASIN_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TRUE_ = 258,
    FALSE_ = 259,
    INT_ = 260,
    BOOL_ = 261,
    READ_ = 262,
    PRINT_ = 263,
    FOR_ = 264,
    IF_ = 265,
    ELSE_ = 266,
    OPMAS_ = 267,
    OPIGU_ = 268,
    OPMASIGU_ = 269,
    OPMENOSIGU_ = 270,
    OPPORIGU_ = 271,
    OPDIVIGU_ = 272,
    OPMENOS_ = 273,
    OPPOR_ = 274,
    OPMODULO_ = 275,
    OPDIV_ = 276,
    OPINCREMENTO_ = 277,
    OPDECREMENTO_ = 278,
    OPAND_ = 279,
    OPOR_ = 280,
    OPIGUALDAD_ = 281,
    OPDISTINTOIGUAL_ = 282,
    OPMAYOR_ = 283,
    OPMAYIGU_ = 284,
    OPMENOR_ = 285,
    OPMENIGU_ = 286,
    OPDISTINTO_ = 287,
    PARA_ = 288,
    PARC_ = 289,
    PUNTOCOMA_ = 290,
    LLAVEA_ = 291,
    LLAVEC_ = 292,
    CORCHC_ = 293,
    CORCHA_ = 294,
    CTE_ = 295,
    IDENTIFICADOR_ = 296
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 14 "src/asin.y" /* yacc.c:1909  */

  int cent ; /* Valor de la cte numerica entera para el terminal "cte" */
  char *ident ; /* Nombre del identificador */
  EXP expr; /*for expresions*/
  FOR_INST instfor;

#line 103 "asin.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_ASIN_H_INCLUDED  */
