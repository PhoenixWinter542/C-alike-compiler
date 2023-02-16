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

%left	DIGIT
%left	SPACE
%left	VARIABLE
%left	INTEGER
%left	LESS
%left	GREATER
%left	LTE
%left	GTE
%left	EQUAL
%left	NOT
%left	ADD
%left	SUBTRACT
%left	MULTIPLY
%left	DIVIDE
%left	WHILE
%left	L_PAREN
%left	R_PAREN
%left	L_BRACK
%left	R_BRACK
%left	L_BRACE
%left	R_BRACE
%left	IF
%left	ELSE
%left	READ
%left	WRITE
%left	END
%left	SEPARATOR
%left	RETURN
%left	NEWLINE
%left COMPEQUAL
%left DO

%%

start:    function
    ;

function: type SPACE VARIABLE SPACE L_PAREN declare R_PAREN code
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
    | type SPACE VARIABLE SPACE array END
    ;

assign:   VARIABLE SPACE EQUAL SPACE combo SPACE END
    ;

arith:    ADD
    | SUBTRACT
    | MULTIPLY
    | DIVIDE
    ;

arnie:    SPACE
    | SEPARATOR
    | END
    | R_BRACE
    | R_BRACK
    | R_PAREN
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
    | arnie
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


