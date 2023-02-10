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

type:     INTEGER
    ;

varcnst:  VARIABLE
    | DIGIT
    ;

array:    L_BRACK DIGIT R_BRACK
    ;

assign:   VARIABLE SPACE EQUAL SPACE varcnst SPACE END
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
    | L_BRACK varcnst multarg R_BRACK
    ;

multarg:  /* empty */
    | SEPARATOR varcnst multarg
    ;

COMPARE:  L_BRACK varcnst relate varcnst R_BRACK
    ;

declare:  /* empty */
    | type SPACE varcnst multdec
    ;

multdec:  /* empty */
    | SEPARATOR varcnst multdec
    ;

loop:     WHILE code
    | DO code WHILE
    ;

case:     IF code elcase
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

balbrace: /* todo */
    ;


code:     L_BRACE middle R_BRACE;
    ;

middle:   /* todo */
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


