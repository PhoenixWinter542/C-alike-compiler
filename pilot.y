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
string expect = "start";
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

/* Allows one or more functions */
start:      function multfunc                                             { printpos("start -> function", true); }
    ;

/* Handles multiple functions */
multfunc: /* empty */
    | function multfunc
    ;

/* Function with body */
function:   type { expect = "VARIABLE";} VARIABLE { expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code           { printpos("function -> type VARIABLE L_PAREN declare R_PAREN code", true); }
    ;

/* call to a function */
call:   VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { expect = "multarg";} multarg { expect = ")";} R_PAREN                  { printpos("call -> VARIABLE L_PAREN add multarg R_PAREN", true); }
    ;

/* List of accepted types */
type:   INTEGER                                                 { printpos("type -> INTEGER", false); }
    ;

/* Variables, constants, and things that return constants */
varcnst:  VARIABLE                                              { printpos("varcnst -> VARIABLE", false); }
    | DIGIT                                                     { printpos("varcnst -> DIGIT", false); }
    | VARIABLE { expect = "array";}  array                                           { printpos("varcnst -> VARIABLE array", true); }
    | call
    ;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:    add { expect = "+";} ADD { expect = "sub";} sub                                             { printpos("add -> add ADD sub", true); }
    | sub                                                       { printpos("add -> sub", true); }
	;

sub:    sub { expect = "-";} SUBTRACT { expect = "mult";} mult                                       { printpos("sub -> sub SUBTRACT mult", true); }
    | mult                                                      { printpos("sub -> mult", true); }
    ;

mult:   mult { expect = "*";} MULTIPLY { expect = "div";} div                                       { printpos("mult -> mult MULTIPLY div", true); }
    | div                                                       { printpos("mult -> div", true); }
    ;

div:    div { expect = "/";} DIVIDE { expect = "paren";} paren                                        { printpos("div -> div DIVIDE paren", true); }
    | paren                                                     { printpos("div -> paren", true); }
    ;

paren:  L_PAREN { expect = "add";} add { expect = ")";} R_PAREN                                     { printpos("paren -> L_PAREN add R_PAREN", true); }
    | varcnst                                                   { printpos("paren -> varcnst", true); }
    ;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:    L_BRACK { expect = "add";} add { expect = "]";} R_BRACK                                 { printpos("array -> L_BRACK add R_BRACK", true); }
    ;

/* Array declaration */
arraydec: VARIABLE { expect = "array";} array                                        { printpos("arraydec -> VARIABLE array", true); }     /* type gives the reduce/reduce warning */
    ;

/* Assigns a value to a variable */
assign:   VARIABLE  { expect = "=";} EQUAL  { expect = "add";} add                                { printpos("assign ->  VARIABLE  EQUAL  add", true); }
    ;

/* Handles having more than one argument */
multarg:  /* empty */                                           { printpos("multarg -> epsilon", true); }
    | SEPARATOR { expect = "add";} add { expect = "multarg";} multarg                                   { printpos("multarg -> SEPARATOR add multarg", true); }
    ;

/* Conditional statements (Includes parentheses) */
compare:  { expect = "(";} L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN                    { printpos("compare -> L_PAREN add relate add R_PAREN", true); }
    ;

/* Variable declarations for function calls and definitions */
declare:  /* empty */                                           { printpos("declare -> epsilon", true); }
    | type { expect = "varcnst";} varcnst { expect = "multdec";} multdec                                     { printpos("declare -> type varcnst multdec", true); }
    ;

/* Handles multiple declarations */
multdec:  /* empty */                                           { printpos("multdec -> epsilon", true); }
    | SEPARATOR { expect = "varcnst";} varcnst { expect = "multdec";} multdec                                 { printpos("multdec -> SEPARATOR varcnst multdec", true); }
    ;

/* Declaration of local variables */
init: type assign                                                                                         { printpos("init -> type assign", true); }
    | type VARIABLE                                                                                                       { printpos("init -> type assign", false); }
    ;

/* Currently handles "do while" and "while" loops */
loop:     WHILE { expect = "compare";} compare { expect = "code";} code                                    { printpos("loop -> WHILE compare code", true); }
    | DO { expect = "code";} code { expect = "while";} WHILE { expect = "compare";} compare                                     { printpos("loop -> DO code WHILE compare", true); }
    ;

/* If or If else */
case:     { expect = "if";} IF { expect = "compare";} compare { expect = "code";} code { expect = "elcase";} elcase                                { printpos("else if(-> IF compare code elcase", true); }
    ;

/* handles any else that may occur */
elcase:   /* empty */                                           { printpos("elcase -> epsilon", false); }
    | ELSE { expect = "code";} code                                                 { printpos("elcase -> ELSE code", true); }
    ;

/* List of accepted comparison operators */
relate:   LESS                                                  { printpos("relate -> LESS", false); }
    | GREATER                                                   { printpos("relate -> GREATER", false); }
    | LTE                                                       { printpos("relate -> LTE", false); }
    | GTE                                                       { printpos("relate -> GTE", false); }
    | COMPEQUAL                                                 { printpos("relate -> COMPEQUAL", false); }
    | NOT EQUAL                                             { printpos("relate -> NOT EQUAL", false); }
    ;

/* Enforces the braces around a code block */
code:     { expect = "{";} L_BRACE { expect = "middle";} middle { expect = "}";} R_BRACE                                { printpos("code -> L_BRACE middle R_BRACE", true); }
    ;

/* List of all things that can be in a code block */
middle:   /* empty */                                           { printpos("middle -> epsilon", true); }
    |   assign { expect = ";";} END { expect = "middle";} middle                                       { printpos("middle -> assign END middle", true); }
    |   init { expect = ";";} END { expect = "middle";} middle                                      { printpos("middle -> declare END middle", true); }
    |   loop { expect = ";";} END { expect = "middle";} middle                                         { printpos("middle -> loop END middle", true); }
    |   case { expect = "middle";} middle                                             { printpos("middle -> read END middle", true); }
    |   read { expect = ";";} END { expect = "middle";} middle                                         { printpos("middle -> read END middle", true); }
    |   write { expect = ";";} END { expect = "middle";} middle                                        { printpos("middle -> write END middle", true); }
    |   arraydec { expect = ";";} END { expect = "middle";} middle                                     { printpos("middle -> arraydec END middle", true); }
    |   RETURN { expect = "add";} add { expect = ";";} END { expect = "middle";} middle                                 { printpos("middle -> RETURN add END middle", true); }
    ;

/* Read user input */
read:    READ { expect = "VARIABLE"; } VARIABLE                                               { printpos("read -> READ VARIABLE", false); }
    ;

/* Output to console */
write:    WRITE { expect = "VARIABLE"; } VARIABLE                                              { printpos("write -> WRITE VARIABLE", false); }
    ;

%%

string choosenext(string next){

    if("start")
        return "INTEGER";
    else if("multfunc")
        return "INTEGER";
    else if("function")
        return "INTEGER";
    else if("call")
        return "VARIABLE";
    else if("type")
        return "INTEGER";
    else if("varcnst")
        return "VARIABLE, DIGIT";
    else if("add")
        return "VARIABLE, DIGIT, (";
    else if("sub")
        return "VARIABLE, DIGIT, (";
    else if("mult")
        return "VARIABLE, DIGIT, (";
    else if("div")
        return "VARIABLE, DIGIT, (";
    else if("paren")
        return "VARIABLE, DIGIT, (";
    else if("array")
        return "[";
    else if("arraydec")
        return "VARIABLE";
    else if("assign")
        return "VARIABLE";
    else if("multarg")
        return "), ','";
    else if("compare")
        return "(";
    else if("declare")
        return "INTEGER, )";
    else if("multdec")
        return "), ','";
    else if("init")
        return "INTEGER";
    else if("loop")
        return "WHILE, DO";
    else if("case")
        return "IF";
    else if("elcase")
        return "ELSE";
    else if("relate")
        return "<, >, <=, >=, ==, !=";
    else if("code")
        return "{";
    else if("middle")
        return "VARIABLE, INTEGER, WHILE, DO, IF, READ, WRITE, RETURN, }";
    else if("read")
        return "READ";
    else if("write")
        return "WRITE";
    else //Terminal is next
        return next;
}

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
  cout << "EXPECTED: " << "\"" + choosenext(expect) + "\"" << endl;
  exit(1);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


