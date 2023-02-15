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
INIT      =
NOT       !
ADD       +
SUBTRACT  -
MULTIPLY  *
DIVIDE    /
WHILE     while
L_PARENTH (
R_PARENTH \)
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
ARNIE      {SPACE}|{SEPARATOR}|{END}|{R_BRACE}|{R_BRACK}|{R_PARENTH}

ARG       ""|"["{VARCNST}"]"|"["({VARCNST},)*{VARCNST}"]"
COMPARE   [{VARCNST}{RELATE}{VARCNST}]
DECLARE   ""|{TYPE}{SPACE}{VARCNST}|({TYPE}{SPACE}{VARCNST},)*{TYPE}{SPACE}{VARCNST}

LOOP      "while" | "do while"
CASE      "if" | "else"
FILE      "read" | "write"
COMMENT   "//"[.]*\n|["/*"[.]*"*/"]
FUNC      /*{TYPE}{SPACE}{VARIABLE}{SPACE}?"("{DECLARE}")"{SPACE}?{BALBRACE}*/

%%

/* {int_const}	{ yylval.int_val = atoi(yytext); return NUMBER; } */
"<"		{ yylval.op_val = new std::string(yytext); return LESS; }
">"		{ yylval.op_val = new std::string(yytext); return GREATER; }
"<="    { yylval.op_val = new std::string(yytext); return LTE; }
">="	{ yylval.op_val = new std::string(yytext); return GTE; }
"!="	{ yylval.op_val = new std::string(yytext); return NOTEQUAL; }
"=="	{ yylval.op_val = new std::string(yytext); return EQUAL; }
"="	    { yylval.op_val = new std::string(yytext); return ASSIGN; }
"+"		{ yylval.op_val = new std::string(yytext); return PLUS; }
"-"		{ yylval.op_val = new std::string(yytext); return MINUS; }
"*"		{ yylval.op_val = new std::string(yytext); return MULT; }
"/"		{ yylval.op_val = new std::string(yytext); return DIV; }
"("		{ yylval.op_val = new std::string(yytext); return L_PARENTH; }
")"		{ yylval.op_val = new std::string(yytext); return R_PARENTH; }
"["		{ yylval.op_val = new std::string(yytext); return LBRACK; }
"]"		{ yylval.op_val = new std::string(yytext); return RBRACK; }
"{"		{ yylval.op_val = new std::string(yytext); return LBRACE; }
"}"		{ yylval.op_val = new std::string(yytext); return RBRACE; }
";"		{ yylval.op_val = new std::string(yytext); return END \n; }
"if"	{ yylval.op_val = new std::string(yytext); return IF \n; }
"else"	{ yylval.op_val = new std::string(yytext); return ELSE \n; }
"while"	{ yylval.op_val = new std::string(yytext); return WHILE \n; }
","		{ yylval.op_val = new std::string(yytext); return SEPARATOR \n; }

[ \t]*		{}
[\n]		{ yylineno++;	}

<<EOF>> { exit(1); }

.		{ std::cerr << "SCANNER "; yyerror("Unrecognized character"); exit(1);	}

