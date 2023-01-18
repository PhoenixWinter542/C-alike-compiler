%{
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int eqCount = 0;
int failed = 0;
%}

DIGIT     [0-9]*
ALNUM     [a-zA-Z0-9]+
INTEGER   "int "[a-zA-Z]+
ARRAY     "[]"|"["[:DIGIT:]"]"|"["([:DIGIT:],)*[:DIGIT:]"]"|"["[:INTEGER:]"]"|"["([:INTEGER:],)*[:INTEGER:]"]"|"["([:DIGIT:],)*[:INTEGER:]"]"|"["([:INTEGER:],)*[:DIGIT:]"]"
ASSIGN    [=]
ARITH     "+"|"-"|"*"|"/"

DECLARE   [[:INTEGER:]]=[[:VAR:][:DIGIT:]]
ARG       []
CONDITION []

RELATE    "<"|"=="|">"|"!="
LOOP      "while" | "do while"
CASE    "if" | "else"
FILE      "read" | "write"
COMMENT   "//"

%%

{DIGIT}+    {
            printf( "An integer: %s \n", yytext );
            ++intCount;
            }

"+"|"-"|"*"|"/"   {printf( "An operator: %s\n", yytext ); ++opCount;}

"("|")"           {printf( "A parentheses: %s\n", yytext); ++parenCount;}

"="               {printf( "An equal sign: %s\n", yytext); ++eqCount;}

"{"[^}\n]*"}"     /* eat up one-line comments */

[ \t\n]+          /* eat up whitespace */

.           {printf( "Unrecognized character: %s\n", yytext ); failed = 1; return 0;}

%%

int main( void )
{
  printf("STRING: %s\n", "[Your String]");
  printf("NUMBER: %d\n", 100);
  printf("Ctrl+D to quit.\n");
  yylex();
  if(0 == failed){
    printf("# of numbers: %d\n", intCount);
    printf("# of operators: %d\n", opCount);
    printf("# of parentheses: %d\n", parenCount);
    printf("# of equations: %d\n", eqCount);
  }
  printf("Quiting...\n");
}