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

function: type  VARIABLE  L_PAREN declare R_PAREN code          { printpos("function -> type VARIABLE L_PAREN declare R_PAREN code", true); }
    ;

combo:  math                                                    { printpos("combo -> math", true); }
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

arraydec:  /* empty */                                          { printpos("arraydec -> epsilon", true); }
    | type VARIABLE array                                       { printpos("arraydec -> type VARIABLE array", true); }
    ;

assign:   VARIABLE  EQUAL  combo                                { printpos("assign ->  VARIABLE  EQUAL  combo", true); }
    ;

multarg:  /* empty */                                           { printpos("multarg -> epsilon", true); }
    | SEPARATOR combo multarg                                   { printpos("multarg -> SEPARATOR combo multarg", true); }
    ;

compare:  L_PAREN combo relate combo R_PAREN                    { printpos("compare", true); }
    ;

declare:  /* empty */                                           { printpos("declare", true); }
    | type  varcnst multdec                                     { printpos("declare", true); }
    ;

multdec:  /* empty */                                           { printpos("multdec", true); }
    | SEPARATOR varcnst multdec                                 { printpos("multdec", true); }
    ;

loop:     WHILE compare code                                    { printpos("loop", true); }
    | DO code WHILE compare                                     { printpos("loop", true); }
    ;

case:     IF compare code elcase                                { printpos("case", true); }
    ;

elcase:   /* empty */                                           { printpos("elcase", false); }
    | ELSE code                                                 { printpos("elcase", true); }
    ;

relate:   LESS                                                  { printpos("relate", false); }
    | GREATER                                                   { printpos("relate", false); }
    | LTE                                                       { printpos("relate", false); }
    | GTE                                                       { printpos("relate", false); }
    | COMPEQUAL                                                 { printpos("relate", false); }
    | NOT COMPEQUAL                                             { printpos("relate", false); }
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

code:     L_BRACE middle R_BRACE                                { printpos("code", true); }
    ;

read:   /* empty */                                             { printpos("read", false); }
    READ VARIABLE                                               { printpos("read", false); }
    ;

write:  /* empty */                                             { printpos("write", false); }
    WRITE VARIABLE                                              { printpos("write", false); }
    ;

middle:   /* empty */                                           { printpos("middle", true); }
    |   assign END middle                                       { printpos("middle", true); }
    |   declare END middle                                      { printpos("middle", true); }
    |   loop END middle                                         { printpos("middle", true); }
    |   case middle                                             { printpos("middle", true); }
    |   read END middle                                         { printpos("middle", true); }
    |   write END middle                                        { printpos("middle", true); }
    |   arraydec END middle                                     { printpos("middle", true); }
    |   RETURN combo END middle                                 { printpos("middle", true); }
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


