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

%start	input 

%token	<int_val>	NUMBER

%type	<int_val>	add
%type	<int_val>	sub
%type	<int_val>	mult
%type	<int_val>	div
%type <int_val> paren
%type <int_val> term

%left	PLUS
%left	MULT
%left MINUS
%left DIV
%left L_PAREN
%left R_PAREN
%left EQUAL

%%

input:		/* empty */
		| add EQUAL	{ cout << "Result: " << $1 << "\nIntegers: " << intCount << "\nOperators: " << opCount << "\nParentheses: " << parenCount  << "\nEqual Signs: " << ++equalCount << endl; YYACCEPT; }
    | MINUS add EQUAL	{ cout << "Result: " << 0 - $2 << "\nIntegers: " << intCount << "\nOperators: " << opCount << "\nParentheses: " << parenCount  << "\nEqual Signs: " << ++equalCount << endl; YYACCEPT; }
		| add { yyerror("EXPECTED '='"); }
    ;

add:    add PLUS sub	{ $$ = $1 + $3; cout << "PLUS" << endl; ++opCount; }
    | sub
    | add PLUS { yyerror("EXPECTED number"); }
		;

sub:    sub MINUS mult { $$ = $1 - $3; cout << "MINUS" << endl; ++opCount; }
    | mult
    | sub MINUS { yyerror("EXPECTED number"); }
    ;

mult:   mult MULT div { $$ = $1 * $3; cout << "MULT" << endl; ++opCount; }
    | div
    | mult MULT { yyerror("EXPECTED number"); }
    ;

div:    div DIV term { $$ = $1 / $3; cout << "DIV" << endl; ++opCount; }
    | paren
    | div DIV { yyerror("EXPECTED number"); }
    ;

paren:  L_PAREN add R_PAREN { $$ = $2; cout << "PAREN " << endl; ++ parenCount; }
    | term
    | add R_PAREN { yyerror("EXPECTED '('"); }
    ;

term:   NUMBER { $$ = $1; ++intCount; }
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


