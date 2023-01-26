%{
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int eqCount = 0;
int failed = 0;
int lineCount = 1;
int positionCount = 1;
%}

/* BASIC */
/* "+"|"-"|"*"|"/"   {printf( "An operator: %s\n", yytext ); ++opCount;} */
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
"<"               {printf("LESS \n", yytext); positionCount += yyleng;}
">"               {printf("GREATER \n", yytext); positionCount += yyleng;}
"<="              {printf("LTE \n", yytext); positionCount += yyleng;}
">="              {printf("GTE \n", yytext); positionCount += yyleng;}
"!="              {printf("NOTEQUAL \n", yytext); positionCount += yyleng;}
"=="              {printf("EQUAL \n", yytext); positionCount += yyleng;}
"="               {printf("ASSIGN \n", yytext); positionCount += yyleng;}
"+"               {printf("ADD \n", yytext); positionCount += yyleng;}
"-"               {printf("SUBTRACT \n", yytext); positionCount += yyleng;}
"*"               {printf("MULTIPLY \n", yytext); positionCount += yyleng;}
"/"               {printf("DIVIDE \n", yytext); positionCount += yyleng;}
"("               {printf("LPARENTH \n", yytext); positionCount += yyleng;}
")"               {printf("RPARENTH \n", yytext); positionCount += yyleng;}
"["               {printf("LBRACK \n", yytext); positionCount += yyleng;}
"]"               {printf("RBRACK \n", yytext); positionCount += yyleng;}
"{"               {printf("LBRACE \n", yytext); positionCount += yyleng;}
"}"               {printf("RBRACE \n", yytext); positionCount += yyleng;}
";"               {printf("END \n", yytext); positionCount += yyleng;}
"if"              {printf("IF \n", yytext); positionCount += yyleng;}
"else"            {printf("ELSE \n", yytext); positionCount += yyleng;}
"while"           {printf("WHILE \n", yytext); positionCount += yyleng;}
","               {printf("SEPARATOR \n", yytext); positionCount += yyleng;}
{NEWLINE}         {printf("NEWLINE \n", yytext); lineCount++;}
{RETURN}          {printf("RETURN \n", yytext);}


{DIGIT}           {printf( "DIGIT \n", yytext ); positionCount += yyleng; ++intCount;}

{TYPE}            {printf("TYPE \n", yytext); positionCount += yyleng;}

{VARIABLE}        {printf("VARIABLE \n", yytext); positionCount += yyleng;}

"{"[^}\n]*"}"     /* eat up one-line comments */

[ \t]+            /* eat up whitespace */

.                 {printf( "Unrecognized character: %s at line %d, position %d\n", yytext, lineCount, positionCount); failed = 1; return 0;}

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