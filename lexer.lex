%{
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int eqCount = 0;
int failed = 0;
%}

/* BASIC */
/* "+"|"-"|"*"|"/"   {printf( "An operator: %s\n", yytext ); ++opCount;} */
DIGIT     [0-9]
ALPHA     [a-zA-Z]
ALNUM     [a-zA-Z0-9]+
VARIABLE  {ALPHA}{ALNUM}*
SPACE     [ \t\n]*

INTEGER   "int"{SPACE}
OPEN      [
CLOSE     ]
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
R_PARENTH )
L_BRACK   [
R_BRACK   ]
L_BRACE   {
R_BRACE   }
IF        if
ELSE      else
READ      read
WRITE     write
END       ;
SEPERATOR ,


BALBRACE  "{"[^{}]*"}"|"{"[^{}]*[:BALBRACE:][^{}]*"}"  /* Should allow for using braces inside of braces (balanced only)*/
BALPAREN  "("[^()]*")"|"("[^()]*[:BALPAREN:][^()]*")"
BALBRACK  "["[^\[\]]*"]"|"["[^\[\]]*[:BALBRACK:][^)]*"]"

/* Compound */
TYPE      {INTEGER}
VARCNST   [[:INTEGER:][:DIGIT:]]
ARRAY     "["[:DIGIT:]"]"
ASSIGN    [:TYPE:][:SPACE:]"="[:SPACE:][:VARCNST:][:SPACE:]";"
ARITH     "+"|"-"|"*"|"/"

ARG       ""|"["[:VARCNST:]"]"|"["([:VARCNST:],)*[:VARCNST:]"]"
COMPARE   [[:VARCNST:][:RELATE:][:VARCNST:]]
DECLARE   ""|[:TYPE:][:SPACE:][:VARCNST:]|([:TYPE:][:SPACE:][:VARCNST:],)*[:TYPE:][:SPACE:][:VARCNST:]

LOOP      "while" | "do while"
CASE      "if" | "else"
FILE      "read" | "write"
COMMENT   "//"[.]*\n|["/*"[.]*"*/"]
FUNC      [:TYPE:][:SPACE:][:VARIABLE:][:SPACE:]"("[:DECLARE:]")"[:SPACE:][:BALBRACE:]

%%

"<"               {printf("LESS \n", yytext);}
">"               {printf("GREATER \n", yytext);}
"<="              {printf("LTE \n", yytext);}
">="              {printf("GTE \n", yytext);}
"!="              {printf("NOTEQUAL \n", yytext);}
"=="              {printf("EQUAL \n", yytext);}
"="               {printf("ASSIGN \n", yytext);}
"+"               {printf("ADD \n", yytext);}
"-"               {printf("SUBTRACT \n", yytext);}
"*"               {printf("MULTIPLY \n", yytext);}
"/"               {printf("DIVIDE \n", yytext);}
"("               {printf("LPARENTH \n", yytext);}
")"               {printf("RPARENTH \n", yytext);}
"["               {printf("LBRACK \n", yytext);}
"]"               {printf("RBRACK \n", yytext);}
"{"               {printf("LBRACE \n", yytext);}
"}"               {printf("RBRACE \n", yytext);}
";"               {printf("END \n", yytext);}
"if"              {printf("IF \n", yytext);}
"else"            {printf("ELSE \n", yytext);}
"while"           {printf("WHILE \n", yytext);}
","               {printf("SEPERATOR \n", yytext);}

{DIGIT}+          {printf( "INTEGER \n", yytext ); ++intCount;}

{ALPHA}           {printf("ALPHA \n", yytext);}

{VARIABLE}        {printf("VARIABLE \n", yytext);}

{TYPE}            {printf("TYPE \n", yytext);}

{FUNC}            {printf("FUNC \n", yytext);}

"{"[^}\n]*"}"     /* eat up one-line comments */

[ \t\n]+          /* eat up whitespace */

.           {printf( "Unrecognized character: %s\n", yytext ); failed = 1; return 0;}

%%

int main( void )
{
  /* printf("STRING: %s\n", "[Your String]");
  printf("NUMBER: %d\n", 100);
  printf("Ctrl+D to quit.\n"); */
  yylex();
  /*
  if(0 == failed){
    printf("# of numbers: %d\n", intCount);
    printf("# of operators: %d\n", opCount);
    printf("# of parentheses: %d\n", parenCount);
    printf("# of equations: %d\n", eqCount);
  }
  */
  printf("Quiting...\n");
}
