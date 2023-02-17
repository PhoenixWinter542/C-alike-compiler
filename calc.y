/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int equalCount = 0;
%}

%union{
  int		int_val;
  string*	op_val;
}

%start	start

/* Comparisons */
%left	LESS
%left	GREATER
%left	LTE
%left	GTE
%left   COMPEQUAL
%left	NOT

/* Math */
%left	ADD
%left	SUBTRACT
%left	MULTIPLY
%left	DIVIDE
%left	DIGIT

/* () {} [] */
%left	L_PAREN
%left	R_PAREN
%left	L_BRACK
%left	R_BRACK
%left	L_BRACE
%left	R_BRACE

/* Symbols */
%left	END
%left	SEPARATOR
%left	EQUAL
%left	RETURN
%left   ARNIE

/* Conditionals */
%left	IF
%left	ELSE

/* Loops */
%left	WHILE
%left   DO

/* Storage */
%left	VARIABLE
%left	READ
%left	WRITE

/* Types */
%left	INTEGER

/* Whitespace */
%left	SPACE
%left   OPTSPACE


%%

start:    function
    ;

function: type SPACE VARIABLE OPTSPACE L_PAREN declare R_PAREN code
    ;

call:   /* empty */   
    |   VARIABLE arg
    ;

type:     INTEGER
    ;

varcnst:  VARIABLE
    | DIGIT
    | VARIABLE SPACE array
    ;

math:   varcnst multmath
    ;

multmath:   /* empty */
    |   arith multmath varcnst
    ;

combo:  math
    |   call
    ;

array:    L_BRACK combo R_BRACK
    ;

arraydec:  /* empty */
    | type SPACE VARIABLE OPTSPACE array END
    ;

assign:   VARIABLE OPTSPACE EQUAL OPTSPACE combo OPTSPACE END
    ;

arith:    ADD
    | SUBTRACT
    | MULTIPLY
    | DIVIDE
    ;

arg:      /* empty */
    | L_PAREN combo multarg R_PAREN
    ;

multarg:  /* empty */
    | SEPARATOR combo multarg
    ;

compare:  L_PAREN combo relate combo R_PAREN
    ;

declare:  /* empty */
    | type SPACE varcnst multdec
    ;

multdec:  /* empty */
    | SEPARATOR varcnst multdec
    ;

loop:     WHILE compare code
    | DO code WHILE compare
    ;

case:     IF compare code elcase
    ;

elcase:   /* empty */
    | ELSE code
    ;

comment:  
    ;

relate:   LESS
    | GREATER
    | LTE
    | GTE
    | COMPEQUAL
    ;

balbrace: L_BRACE balMiddle R_BRACE
    ;

balparen: L_PAREN balMiddle R_PAREN
    ;

balbrack: L_BRACK balMiddle R_BRACK
    ;

balCode:     balbrace
    | balparen
    | balbrack
    | ARNIE
    ;

balMiddle:   /* empty */
    | balCode balMiddle
    ;


code:     L_BRACE middle R_BRACE;
    ;

read:   /* empty */
    READ VARIABLE
    ;

write:  /* empty */
    WRITE VARIABLE
    ;

middle:   /* empty */
    |   assign
    |   declare
    |   loop
    |   case
    |   comment
    |   code
    |   read
    |   write
    |   arraydec
    |   RETURN combo END
    ;

%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "ERROR: " << s << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


