/* Mini Calculator */
/* calc.lex */

%{
#include "heading.h"
#include "tok.h"
int yyerror(char *s);

%}

/*
digit		[0-9]
int_const	{digit}+
*/

DIGIT     [0-9]+{ARNIE}
ALPHA     [a-zA-Z]
ALNUM     [a-zA-Z0-9]+
SPACE     [ \t\n]+
VARIABLE  {ALPHA}(_?{ALNUM})*
INTEGER   "int"
LESS      <
GREATER   >
LTE       <=
GTE       >=
EQUAL     =
NOT       !
ADD       +
SUBTRACT  -
MULTIPLY  *
DIVIDE    /
WHILE     while
L_PAREN (
R_PAREN \)
L_BRACK   [
R_BRACK   ]
L_BRACE   {
R_BRACE   \}
IF        if
ELSE      else
READ      read
WRITE     write
END       ;
SEPARATOR ,
RETURN    return
NEWLINE   "\n"

BALBRACE  "{"[^{}]*"}"|"{"[^{}]*{BALBRACE}[^{}]*"}"  /* Should allow for using braces inside of braces (balanced only)*/
BALPAREN  "("[^()]*")"|"("[^()]*{BALPAREN}[^()]*")"
BALBRACK  "["[^\[\]]*"]"|"["[^\[\]]*{BALBRACK}[^)]*"]"

/* Compound */
TYPE      {INTEGER}
VARCNST   [{VARIABLE}{DIGIT}]
ARRAY     "["{DIGIT}"]"
ASSIGN    {VARIABLE}{SPACE}?"="{SPACE}?{VARCNST}{SPACE}?";"
ARITH     "+"|"-"|"*"|"/"
ARNIE      {SPACE}|{SEPARATOR}|{END}|{R_BRACE}|{R_BRACK}|{R_PAREN}

ARG       ""|"["{VARCNST}"]"|"["({VARCNST},)*{VARCNST}"]"
COMPARE   [{VARCNST}{RELATE}{VARCNST}]
DECLARE   ""|{TYPE}{SPACE}{VARCNST}|({TYPE}{SPACE}{VARCNST},)*{TYPE}{SPACE}{VARCNST}

LOOP      "while" | "do while"
CASE      "if" | "else"
FILE      "read" | "write"
COMMENT   "//"[.]*\n|["/*"[.]*"*/"]
FUNC      /*{TYPE}{SPACE}{VARIABLE}{SPACE}?"("{DECLARE}")"{SPACE}?{BALBRACE}*/

%%
 
"<"		{ yylval.op_val = new std::string(yytext); return LESS; }
">"		{ yylval.op_val = new std::string(yytext); return GREATER; }
"<="    { yylval.op_val = new std::string(yytext); return LTE; }
">="	{ yylval.op_val = new std::string(yytext); return GTE; }
"=="	{ yylval.op_val = new std::string(yytext); return COMPEQUAL; }
"="	    { yylval.op_val = new std::string(yytext); return EQUAL; }
"+"		{ yylval.op_val = new std::string(yytext); return ADD; }
"-"		{ yylval.op_val = new std::string(yytext); return SUBTRACT; }
"*"		{ yylval.op_val = new std::string(yytext); return MULTIPLY; }
"/"		{ yylval.op_val = new std::string(yytext); return DIVIDE; }
"("		{ yylval.op_val = new std::string(yytext); return L_PAREN; }
")"		{ yylval.op_val = new std::string(yytext); return R_PAREN; }
"["		{ yylval.op_val = new std::string(yytext); return L_BRACK; }
"]"		{ yylval.op_val = new std::string(yytext); return R_BRACK; }
"{"		{ yylval.op_val = new std::string(yytext); return L_BRACE; }
"}"		{ yylval.op_val = new std::string(yytext); return R_BRACE; }
";"		{ yylval.op_val = new std::string(yytext); return END; }
"if"	{ yylval.op_val = new std::string(yytext); return IF; }
"else"	{ yylval.op_val = new std::string(yytext); return ELSE; }
"while"	{ yylval.op_val = new std::string(yytext); return WHILE; }
","		{ yylval.op_val = new std::string(yytext); return SEPARATOR; }

[ \t]*		{}
[\n]		{ yylineno++;	}

<<EOF>> { exit(1); }

.		{ std::cerr << "SCANNER "; yyerror("Unrecognized character"); exit(1);	}

