/* Mini Calculator */
/* calc.lex */

%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);

%}

/* Comparisons */
LESS        <
GREATER     >
LTE         <=
GTE         >=
COMPEQUAL   ==
NOT         !

/* Math */
ADD         "+"
SUBTRACT    "-"
MULTIPLY    "\*"
DIVIDE      "/"
DIGIT     [0-9]+{ARNIE}

/* () {} [] */
L_PAREN     \(
R_PAREN     \)
L_BRACK     \[
R_BRACK     \]
L_BRACE     \{
R_BRACE     \}

/* Symbols */
END         ;
SEPARATOR   ,
EQUAL       =
RETURN      return

/* Conditionals */
IF          if
ELSE        else

/* Loops */
WHILE       while
DO          do

/* Storage */
READ        read
WRITE       write
VARIABLE    {ALPHA}(_?{ALNUM})*

/* Types */
INTEGER     "int"


/*-------------------------------------------------------------------------------*/

/* Utility */
SPACE       [ \t\n]+
ARNIE       {SPACE}|{SEPARATOR}|{END}|{R_BRACE}|{R_BRACK}|{R_PAREN}
ALPHA       [a-zA-Z]
ALNUM       [a-zA-Z0-9]+


%%
 /* ignore Comments */
"//".*\n    { yylineno++;   }
 /* ignore whitespace */
[ \t]*		{}
[\n]		{ yylineno++;	}

 /* Comparisons */
{LESS}		{ yylval.op_val = new std::string(yytext); return LESS; }
{GREATER}	{ yylval.op_val = new std::string(yytext); return GREATER; }
{LTE}       { yylval.op_val = new std::string(yytext); return LTE; }
{GTE}   	{ yylval.op_val = new std::string(yytext); return GTE; }
{COMPEQUAL}	{ yylval.op_val = new std::string(yytext); return COMPEQUAL; }
{NOT}   	{ yylval.op_val = new std::string(yytext); return NOT; }
 /* Math */
{ADD}		{ yylval.op_val = new std::string(yytext); return ADD; }
{SUBTRACT}	{ yylval.op_val = new std::string(yytext); return SUBTRACT; }
{MULTIPLY}	{ yylval.op_val = new std::string(yytext); return MULTIPLY; }
{DIVIDE}	{ yylval.op_val = new std::string(yytext); return DIVIDE; }
{DIGIT} 	{ yylval.op_val = new std::string(yytext); return DIGIT; }
 /* () {} [] */
{L_PAREN}	{ yylval.op_val = new std::string(yytext); return L_PAREN; }
{R_PAREN}	{ yylval.op_val = new std::string(yytext); return R_PAREN; }
{L_BRACK}	{ yylval.op_val = new std::string(yytext); return L_BRACK; }
{R_BRACK}	{ yylval.op_val = new std::string(yytext); return R_BRACK; }
{L_BRACE}	{ yylval.op_val = new std::string(yytext); return L_BRACE; }
{R_BRACE}	{ yylval.op_val = new std::string(yytext); return R_BRACE; }
 /* Symbols */
{END}		{ yylval.op_val = new std::string(yytext); return END; }
{SEPARATOR} { yylval.op_val = new std::string(yytext); return SEPARATOR; }
{EQUAL}	    { yylval.op_val = new std::string(yytext); return EQUAL; }
{RETURN}	{ yylval.op_val = new std::string(yytext); return RETURN; }
{ARNIE}   	{ yylval.op_val = new std::string(yytext); return ARNIE; }
 /* Conditionals */
{IF}    	{ yylval.op_val = new std::string(yytext); return IF; }
{ELSE}	    { yylval.op_val = new std::string(yytext); return ELSE; }
 /* Loops */
{WHILE}	    { yylval.op_val = new std::string(yytext); return WHILE; }
{DO}	    { yylval.op_val = new std::string(yytext); return DO; }
 /* Types */
{INTEGER}	{ yylval.op_val = new std::string(yytext); return INTEGER; }
 /* Storage */
{READ}  	{ yylval.op_val = new std::string(yytext); return READ; }
{WRITE}	    { yylval.op_val = new std::string(yytext); return WRITE; }
{VARIABLE}	{ yylval.op_val = new std::string(yytext); return VARIABLE; }


<<EOF>> { exit(1); }

.		{ std::cerr << "SCANNER "; yyerror("Unrecognized character"); exit(1);	}

