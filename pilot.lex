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
OR			"||"
AND			"&&"

/* Math */
ADD         "+"
SUBTRACT    "-"
MULTIPLY    "\*"
DIVIDE      "/"
MOD         "%"
DIGIT     "-"?[0-9]+

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
BREAK		break

/* Storage */
READ        read
WRITE       write
VARIABLE    {ALPHA}(_?{ALNUM})*

/* Types */
INTEGER     "int"


/*-------------------------------------------------------------------------------*/

/* Utility */
ALPHA       [a-zA-Z]
ALNUM       [a-zA-Z0-9]+


%%
 /* ignore Comments */
"//".*\n    { yylineno++;   }
 /* ignore whitespace */
[ \t]*		{}
[\n]		{ yylineno++;	}

 /* Comparisons */
{LESS}		{ yylval = new std::string(yytext); return LESS; }
{GREATER}	{ yylval = new std::string(yytext); return GREATER; }
{LTE}       { yylval = new std::string(yytext); return LTE; }
{GTE}   	{ yylval = new std::string(yytext); return GTE; }
{COMPEQUAL}	{ yylval = new std::string(yytext); return COMPEQUAL; }
{NOT}   	{ yylval = new std::string(yytext); return NOT; }
{OR}		{ yylval = new std::string(yytext); return OR; }
{AND}		{ yylval = new std::string(yytext); return AND; }
 /* Math */
{ADD}		{ yylval = new std::string(yytext); return ADD; }
{SUBTRACT}	{ yylval = new std::string(yytext); return SUBTRACT; }
{MULTIPLY}	{ yylval = new std::string(yytext); return MULTIPLY; }
{DIVIDE}	{ yylval = new std::string(yytext); return DIVIDE; }
{MOD}	    { yylval = new std::string(yytext); return MOD; }
{DIGIT} 	{ yylval = new std::string(yytext); return DIGIT; }
 /* () {} [] */
{L_PAREN}	{ yylval = new std::string(yytext); return L_PAREN; }
{R_PAREN}	{ yylval = new std::string(yytext); return R_PAREN; }
{L_BRACK}	{ yylval = new std::string(yytext); return L_BRACK; }
{R_BRACK}	{ yylval = new std::string(yytext); return R_BRACK; }
{L_BRACE}	{ yylval = new std::string(yytext); return L_BRACE; }
{R_BRACE}	{ yylval = new std::string(yytext); return R_BRACE; }
 /* Symbols */
{END}		{ yylval = new std::string(yytext); return END; }
{SEPARATOR} { yylval = new std::string(yytext); return SEPARATOR; }
{EQUAL}	    { yylval = new std::string(yytext); return EQUAL; }
{RETURN}	{ yylval = new std::string(yytext); return RETURN; }
 /* Conditionals */
{IF}    	{ yylval = new std::string(yytext); return IF; }
{ELSE}	    { yylval = new std::string(yytext); return ELSE; }
 /* Loops */
{WHILE}	    { yylval = new std::string(yytext); return WHILE; }
{DO}	    { yylval = new std::string(yytext); return DO; }
{BREAK}		{ yylval = new std::string(yytext); return BREAK; }
 /* Types */
{INTEGER}	{ yylval = new std::string(yytext); return INTEGER; }
 /* Storage */
{READ}  	{ yylval = new std::string(yytext); return READ; }
{WRITE}	    { yylval = new std::string(yytext); return WRITE; }
{VARIABLE}	{ yylval = new std::string(yytext); return VARIABLE; }


<<EOF>> { return FILEEND; }

.		{ std::cerr << "SCANNER "; yyerror("Unrecognized character"); exit(1);	}

