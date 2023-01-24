%{
int intCount = 0;
int opCount = 0;
int parenCount = 0;
int eqCount = 0;
int failed = 0;
%}

/* BASIC */
DIGIT     [0-9]
ALPHA     [a-zA-Z]
ALNUM     [a-zA-Z0-9]+
VARIABLE  {ALPHA}{ALNUM}*

INTEGER   "int "{VARIABLE}
OPEN      [
CLOSE     ]
LESS      <
GREATER   >
EQUAL     =
NOT       !
ADD       +
SUBTRACT  -
MULTIPLY  *
DIVIDE    /
WHILE     while
L_PARENTH (
R_PARENTH )
IF        if
ELSE      else
READ      read
WRITE     write
END       ;

OBJECT    [[:INTEGER:]]
VARCNST   [[:INTEGER:][:DIGIT:]]
ARRAY     "[""]"|"["[:DIGIT:]"]"
ASSIGN    [:OBJECT:]"="[:VARCNST:];
ARITH     "+"|"-"|"*"|"/"

ARG       ""|"["[:VARCNST:]"]"|"["([:VARCNST:],)*[:VARCNST:]"]"
COMPARE   []

LOOP      "while" | "do while"
CASE    "if" | "else"
FILE      "read" | "write"
COMMENT   "//"[.]*\n

%%

{DIGIT}+    {
            printf( "An integer: %s \n", yytext );
            ++intCount;
            }

{VARIABLE}    {printf("a ");}

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