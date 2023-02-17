/* Mini Calculator */
/* calc.y */

%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
void printpos(string tokens, bool nonterm);
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int equalCount = 0;
string prev = "";
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

%%

start:    function                                              { printpos("start -> function", true); }
    ;

function: type VARIABLE L_PAREN declare R_PAREN code            { printpos("function -> type VARIABLE L_PAREN declare R_PAREN code", true); }
    ;

combo:    math                                                  { printpos("combo -> math", true); }
    | call                                                      { printpos("combo -> call", true); }
    ;

call:   VARIABLE L_PAREN combo multarg R_PAREN                  { printpos("call -> VARIABLE L_PAREN combo multarg R_PAREN", true); }
    ;

type:   INTEGER                                                 { printpos("type -> INTEGER", false); }
    ;

varcnst:  VARIABLE                                              { printpos("varcnst -> VARIABLE", false); }
    | DIGIT                                                     { printpos("varcnst -> DIGIT", false); }
    | VARIABLE  array                                           { printpos("varcnst -> VARIABLE array", true); }
    ;

math:   add                                                     { printpos("math -> add", true); }
    ;

add:    add ADD sub                                             { printpos("add -> add ADD sub", true); }
    | sub                                                       { printpos("add -> sub", true); }
	;

sub:    sub SUBTRACT mult                                       { printpos("sub -> sub SUBTRACT mult", true); }
    | mult                                                      { printpos("sub -> mult", true); }
    ;

mult:   mult MULTIPLY div                                       { printpos("mult -> mult MULTIPLY div", true); }
    | div                                                       { printpos("mult -> div", true); }
    ;

div:    div DIVIDE paren                                        { printpos("div -> div DIVIDE paren", true); }
    | paren                                                     { printpos("div -> paren", true); }
    ;

paren:  L_PAREN add R_PAREN                                     { printpos("paren -> L_PAREN add R_PAREN", true); }
    | varcnst                                                   { printpos("paren -> varcnst", true); }


array:    L_BRACK combo R_BRACK                                 { printpos("array -> L_BRACK combo R_BRACK", true); }
    ;

arraydec: VARIABLE array                                        { printpos("arraydec -> VARIABLE array", true); }     /* type gives the reduce/reduce warning */
    ;

assign:   VARIABLE  EQUAL  combo                                { printpos("assign ->  VARIABLE  EQUAL  combo", true); }
    ;

multarg:  /* empty */                                           { printpos("multarg -> epsilon", true); }
    | SEPARATOR combo multarg                                   { printpos("multarg -> SEPARATOR combo multarg", true); }
    ;

compare:  L_PAREN combo relate combo R_PAREN                    { printpos("compare -> L_PAREN combo relate combo R_PAREN", true); }
    ;

declare:  /* empty */                                           { printpos("declare -> epsilon", true); }
    | type varcnst multdec                                     { printpos("declare -> type varcnst multdec", true); }
    ;

multdec:  /* empty */                                           { printpos("multdec -> epsilon", true); }
    | SEPARATOR varcnst multdec                                 { printpos("multdec -> SEPARATOR varcnst multdec", true); }
    ;

loop:     WHILE compare code                                    { printpos("loop -> WHILE compare code", true); }
    | DO code WHILE compare                                     { printpos("loop -> DO code WHILE compare", true); }
    ;

case:     IF compare code elcase                                { printpos("case -> IF compare code elcase", true); }
    ;

elcase:   /* empty */                                           { printpos("elcase -> epsilon", false); }
    | ELSE code                                                 { printpos("elcase -> ELSE code", true); }
    ;

relate:   LESS                                                  { printpos("relate -> LESS", false); }
    | GREATER                                                   { printpos("relate -> GREATER", false); }
    | LTE                                                       { printpos("relate -> LTE", false); }
    | GTE                                                       { printpos("relate -> GTE", false); }
    | COMPEQUAL                                                 { printpos("relate -> COMPEQUAL", false); }
    | NOT COMPEQUAL                                             { printpos("relate -> NOT COMPEQUAL", false); }
    ;
/*
balbrace: L_BRACE balCode R_BRACE
    ;

balparen: L_PAREN balCode R_PAREN
    ;

balbrack: L_BRACK balCode R_BRACK
    ;

balCode:     balbrace
    | balparen
    | balbrack
    | math
    | call
    ;

balMiddle:   /* empty 
    | balCode balMiddle
    ;
*/

code:     L_BRACE middle R_BRACE                                { printpos("code -> L_BRACE middle R_BRACE", true); }
    ;

middle:   /* empty */                                           { printpos("middle -> epsilon", true); }
    |   assign END middle                                       { printpos("middle -> assign END middle", true); }
    |   declare END middle                                      { printpos("middle -> declare END middle", true); }
    |   loop END middle                                         { printpos("middle -> loop END middle", true); }
    |   case middle                                             { printpos("middle -> read END middle", true); }
    |   read END middle                                         { printpos("middle -> read END middle", true); }
    |   write END middle                                        { printpos("middle -> write END middle", true); }
    |   arraydec END middle                                     { printpos("middle -> arraydec END middle", true); }
    |   RETURN combo END middle                                 { printpos("middle -> RETURN combo END middle", true); }
    ;

read:   /* empty */                                             { printpos("read -> epsilon", false); }
    READ VARIABLE                                               { printpos("read -> READ VARIABLE", false); }
    ;

write:  /* empty */                                             { printpos("write -> epsilon", false); }
    WRITE VARIABLE                                              { printpos("write -> WRITE VARIABLE", false); }
    ;

%%

void printpos(string tokens, bool nonterm)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  cout << tokens;
  if(!nonterm)
    cout << " " << yytext;
  cout << endl;

  return;
}

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


