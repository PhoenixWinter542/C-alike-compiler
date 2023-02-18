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
string expect = "";
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

start:    { expect = "function"; } function                                              { printpos("start -> function", true); }
    ;

function: { expect = "INTEGER"; } type { expect = "VARIABLE"; } VARIABLE { expect = "L_PAREN"; } L_PAREN { expect = "declare"; } declare { expect = "R_PAREN"; } R_PAREN { expect = "code"; } code           { printpos("function -> type VARIABLE L_PAREN declare R_PAREN code", true); }
    ;

combo:   math                                                  { expect = "add or sub"; printpos("combo -> math", true); }
    | call                                                      { expect = "VARIABLE"; printpos("combo -> call", true); }
    ;

call:   VARIABLE { expect = "L_PAREN"; } L_PAREN { expect = "add or VARIABLE"; } combo { expect = "multarg"; } multarg { expect = "R_PAREN"; } R_PAREN                  { printpos("call -> VARIABLE L_PAREN combo multarg R_PAREN", true); }
    ;

type:   INTEGER                                                 { printpos("type -> INTEGER", false); }
    ;

varcnst:  VARIABLE                                              { printpos("varcnst -> VARIABLE", false); }
    | DIGIT                                                     { printpos("varcnst -> DIGIT", false); }
    | VARIABLE { expect = "array"; }  array                                           { expect = "L_BRACK"; printpos("varcnst -> VARIABLE array", true); }
    ;

math:   add                                                     { printpos("math -> add", true); }
    ;

add:    add { expect = "ADD"; } ADD { expect = "varcnst or L_PAREN"; } sub                                             { expect = "varcnst or L_PAREN"; printpos("add -> add ADD sub", true); }
    | sub                                                       { expect = "varcnst or L_PAREN"; printpos("add -> sub", true); }
	;

sub:    sub { expect = "SUBTRACT"; } SUBTRACT { expect = "varcnst or L_PAREN"; } mult                                       { expect = "varcnst or L_PAREN"; printpos("sub -> sub SUBTRACT mult", true); }
    | mult                                                      { expect = "varcnst or L_PAREN"; printpos("sub -> mult", true); }
    ;

mult:   mult { expect = "MULT"; } MULTIPLY { expect = "varcnst or L_PAREN"; } div                                       { expect = "varcnst or L_PAREN"; printpos("mult -> mult MULTIPLY div", true); }
    | div                                                       { expect = "varcnst or L_PAREN"; printpos("mult -> div", true); }
    ;

div:    div { expect = "DIVIDE"; } DIVIDE { expect = "varcnst or L_PAREN"; } paren                                        { expect = "L_PAREN or varcnst"; printpos("div -> div DIVIDE paren", true); }
    | paren                                                     { expect = "L_PAREN or varcnst"; printpos("div -> paren", true); }
    ;

paren:  L_PAREN { expect = "varcnst or L_PAREN"; } add { expect = "R_PAREN"; } R_PAREN                                     { printpos("paren -> L_PAREN add R_PAREN", true); }
    | varcnst                                                   { printpos("paren -> varcnst", true); }
    ;


array:    L_BRACK { expect = "add or VARIABLE"; } combo { expect = "R_BRACK"; } R_BRACK                                 { printpos("array -> L_BRACK combo R_BRACK", true); }
    ;

arraydec: VARIABLE { expect = "array"; } array                                        { printpos("arraydec -> VARIABLE array", true); }     /* type gives the reduce/reduce warning */
    ;

assign:   VARIABLE  { expect = "EQUAL"; } EQUAL  { expect = "add or VARIABLE"; } combo                                { printpos("assign ->  VARIABLE  EQUAL  combo", true); }
    ;

multarg:  /* empty */                                           { printpos("multarg -> epsilon", true); }
    | SEPARATOR { expect = "add or VARIABLE"; } combo { expect = "multarg"; } multarg                                   { printpos("multarg -> SEPARATOR combo multarg", true); }
    ;

compare:  { expect = "L_PAREN"; } L_PAREN { expect = "add or VARIABLE"; } combo { expect = "relate"; } relate { expect = "add or VARIABLE"; } combo { expect = "R_PAREN"; } R_PAREN                    { printpos("compare -> L_PAREN combo relate combo R_PAREN", true); }
    ;

declare:  /* empty */                                           { printpos("declare -> epsilon", true); }
    | type { expect = "VARIABLE or DIGIT"; } varcnst { expect = "multdec"; } multdec                                     { printpos("declare -> type varcnst multdec", true); }
    ;

multdec:  /* empty */                                           { printpos("multdec -> epsilon", true); }
    | SEPARATOR { expect = "VARIABLE or DIGIT"; } varcnst { expect = "multdec"; } multdec                                 { printpos("multdec -> SEPARATOR varcnst multdec", true); }
    ;

loop:     WHILE { expect = "compare"; } compare { expect = "code"; } code                                    { printpos("loop -> WHILE compare code", true); }
    | DO { expect = "code"; } code { expect = "while"; } WHILE { expect = "compare"; } compare                                     { printpos("loop -> DO code WHILE compare", true); }
    ;

case:     { expect = "IF"; } IF { expect = "compare"; } compare { expect = "code"; } code { expect = "elcase"; } elcase                                { printpos("case -> IF compare code elcase", true); }
    ;

elcase:   /* empty */                                           { printpos("elcase -> epsilon", false); }
    | ELSE { expect = "code"; } code                                                 { printpos("elcase -> ELSE code", true); }
    ;

relate:   LESS                                                  { printpos("relate -> LESS", false); }
    | GREATER                                                   { printpos("relate -> GREATER", false); }
    | LTE                                                       { printpos("relate -> LTE", false); }
    | GTE                                                       { printpos("relate -> GTE", false); }
    | COMPEQUAL                                                 { printpos("relate -> COMPEQUAL", false); }
    | NOT COMPEQUAL                                             { printpos("relate -> NOT COMPEQUAL", false); }
    ;

code:     { expect = "L_BRACE"; }L_BRACE { expect = "middle"; } middle { expect = "R_BRACE"; } R_BRACE                                { printpos("code -> L_BRACE middle R_BRACE", true); }
    ;

middle:   /* empty */                                           { printpos("middle -> epsilon", true); }
    |   assign { expect = "END"; } END { expect = "middle"; } middle                                       { printpos("middle -> assign END middle", true); }
    |   declare { expect = "END"; } END { expect = "middle"; } middle                                      { printpos("middle -> declare END middle", true); }
    |   loop { expect = "END"; } END { expect = "middle"; } middle                                         { printpos("middle -> loop END middle", true); }
    |   case { expect = "middle"; } middle                                             { printpos("middle -> read END middle", true); }
    |   read { expect = "END"; } END { expect = "middle"; } middle                                         { printpos("middle -> read END middle", true); }
    |   write { expect = "END"; } END { expect = "middle"; } middle                                        { printpos("middle -> write END middle", true); }
    |   arraydec { expect = "END"; } END { expect = "middle"; } middle                                     { printpos("middle -> arraydec END middle", true); }
    |   RETURN { expect = "END"; } combo { expect = "END"; } END { expect = "middle"; } middle                                 { printpos("middle -> RETURN combo END middle", true); }
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
  
  cerr << "ERROR: "  << " at symbol \"" << yytext;
  cerr << "\" on line " << yylineno << endl;
  cout << "EXPECTED: " << expect << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


