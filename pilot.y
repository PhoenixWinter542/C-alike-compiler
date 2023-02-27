%{
#include "heading.h"
#include "operations.cpp"
int yyerror(char *s);
int yylex(void);
int semerror(string s);
void WriteToMil(string text);
void addVariable(string name);
void addVariable(string name, bool assign);
void addGlobal(string name);
void addGlobal(string name, bool assign);
void addFunc(string name);
string* callFunc(string name);
string expect = "start";
extern char *yytext;    // defined and maintained in lex.c
FILE *fp = fopen("basic.mil", "w+");
operations* vars = new operations();
%}

%union{
	int		int_val;
	string*	op_val;
}

%start	start

/* Comparisons */
%left <op_val>	LESS
%left <op_val>	GREATER
%left <op_val>	LTE
%left <op_val>	GTE
%left <op_val>	COMPEQUAL
%left <op_val>	NOT

/* Math */
%left <op_val>	ADD
%left <op_val>	SUBTRACT
%left <op_val>	MULTIPLY
%left <op_val>	DIVIDE
%left <op_val>	DIGIT

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
%left  	DO

/* Storage */
%left <op_val>	VARIABLE
%left	READ
%left	WRITE

/* Types */
%left	INTEGER

%type <op_val> function
%type <op_val> call
%type <op_val> type
%type <op_val> varcnst
%type <op_val> add
%type <op_val> sub
%type <op_val> mult
%type <op_val> div
%type <op_val> paren
%type <op_val> array
%type <op_val> arraydec
%type <op_val> assign
%type <op_val> multarg
%type <op_val> compare
%type <op_val> declare
%type <op_val> multdec
%type <op_val> init
%type <op_val> initassign
%type <op_val> loop
%type <op_val> case
%type <op_val> elcase
%type <op_val> relate
%type <op_val> code
%type <op_val> middle
%type <op_val> read
%type <op_val> write

%%

/* Allows one or more functions */
start:		function multfunc																																				{ vars->clean(); WriteToMil(vars->getMil()); delete vars;}
	;

/* Handles multiple functions */
multfunc:	/* empty */
	|	function multfunc
	;

/* Function with body */
function:	type { expect = "VARIABLE";} VARIABLE { addFunc(*$<op_val>2); expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code	{ vars->popScope(); }
	;

/* Variable declarations for function definitions */
declare:	/* empty */																																						{  }
	|	type { expect = "varcnst";} varcnst { expect = "multdec"; addVariable(yytext); } multdec																			{  }
	;

/* Handles multiple declarations */
multdec:	/* empty */																																						{  }
	|	SEPARATOR { expect = "varcnst";} varcnst {  addVariable(yytext); expect = "multdec";} multdec																		{  }
	;

/* call to a function */
call:		VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { vars->addParam(*$<op_val>3); expect = "multarg";} multarg { expect = ")";} R_PAREN					{ $$ = callFunc(*$1); }
	;

/* Handles having more than one argument */
multarg:	/* empty */																																						{  }
	|	SEPARATOR { expect = "add";} add { expect = "multarg";} multarg																										{ vars->addParam(*$<op_val>2); }
	;

/* List of accepted types */
type:		INTEGER																																							{  }
	;

/* Variables, constants, and things that return constants */
varcnst:		VARIABLE																																					{ addVariable(*$1); $$ = $1; }
	|	DIGIT																																								{ $$ = $1; }
	|	VARIABLE { expect = "array";}  array																																{ addVariable(*$1); $$ = $1; }
	|	call																																								{ $$ = $1; }
	;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:		add { expect = "+"; } ADD { expect = "sub"; } sub																												{ $$ = vars->combo("+", *$1, *$3); }
	|	sub																																									{ $$ = $1; }
	;

sub:		sub { expect = "-"; } SUBTRACT { expect = "mult";} mult																											{ $$ = vars->combo("-", *$1, *$3); }
	|	mult																																								{ $$ = $1; }
	;

mult:		mult { expect = "*"; } MULTIPLY { expect = "div"; } div																											{ $$ = vars->combo("*", *$1, *$3); }
	|	div																																									{ $$ = $1; }
	;

div:		div { expect = "/"; } DIVIDE { expect = "paren"; } paren																										{ $$ = vars->combo("/", *$1, *$3); }
	|	paren																																								{ $$ = $1; }
	;

paren:		L_PAREN { expect = "add"; } add { expect = ")"; } R_PAREN																										{ $$ = $<op_val>2; }
	|	varcnst																																								{ $$ = $1; }
	;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:		L_BRACK { expect = "add";} add { expect = "]";} R_BRACK																											{ $$ = $<op_val>2; }
	;

/* Array declaration */
arraydec:	VARIABLE { addVariable(*$1); expect = "array";} array																											{ vars->declare(*$1, *$<op_val>2); $$ = $1; }     /* adding type gives reduce/reduce warning */
	;

/* Assigns a value to a variable */
assign:		VARIABLE {  expect = "=";} EQUAL { expect = "add";} add																											{ vars->copy(*$1, *$<op_val>3); }
	;

/* Conditional statements (Includes parentheses) */
compare:	L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN														{  }
	;

/* Declaration of local variables */
init:		type { expect = "VARIABLE"; } VARIABLE {  addVariable(*$<op_val>2); expect = "initassign"; } initassign															{ if($<op_val>3){vars->copy(*$<op_val>2, *$<op_val>3);}; $$ = $<op_val>2; }
	;

initassign:	/* empty */																																						{ $$ = NULL; }
	|	EQUAL { expect = "add"; } add																																		{ $$ = $<op_val>2; }
	;

/* Currently handles "do while" and "while" loops */
loop:		WHILE { expect = "compare";} compare { expect = "code";} code																									{  }
	|	DO { expect = "code";} code { expect = "while";} WHILE { expect = "compare";} compare { expect = ";";} END															{  }
	;

/* If or If else */
case:	IF { expect = "compare";} compare { expect = "code";} code { expect = "elcase";} elcase																				{  }
	;

/* handles any else that may occur */
elcase:		/* empty */																																						{  }
	|	ELSE { expect = "code";} code																																		{  }
	;

/* List of accepted comparison operators */
relate:		LESS																																							{ $$ = $1; }
	|	GREATER																																								{ $$ = $1; }
	|	LTE																																									{ $$ = $1; }
	|	GTE																																									{ $$ = $1; }
	|	COMPEQUAL																																							{ $$ = $1; }
	|	NOT EQUAL																																							{ $$ = $1; }
	;

/* Enforces the braces around a code block */
code:	L_BRACE { expect = "middle";} middle { expect = "}";} R_BRACE																										{  }
	;

/* List of all things that can be in a code block */
middle:		/* empty */																																						{  }
	|	assign { expect = ";";} END { expect = "middle";} middle																											{  }
	|	init { expect = ";";} END { expect = "middle";} middle																												{  }
	|	loop { expect = "middle";} middle																																	{  }
	|	case { expect = "middle";} middle																																	{  }
	|	read { expect = ";";} END { expect = "middle";} middle																												{  }
	|	write { expect = ";";} END { expect = "middle";} middle																												{  }
	|	arraydec { expect = ";";} END { expect = "middle";} middle																											{  }
	|	RETURN { expect = "add";} add { vars->retFunc(yytext); expect = ";";} END { expect = "middle";} middle																{  }
	;

/* Read user input */
read:	READ { expect = "VARIABLE"; } VARIABLE																																{ vars->read(*$<op_val>2); }
	;

/* Output to console */
write:	WRITE { expect = "VARIABLE"; } VARIABLE																																{ vars->write(*$<op_val>2); }
	;

%%

string choosenext(string next){
    if("start" == next)
        return "INTEGER";
    else if("multfunc" == next)
        return "INTEGER";
    else if("function" == next)
        return "INTEGER";
    else if("call" == next)
        return "VARIABLE";
    else if("type" == next)
        return "INTEGER";
    else if("varcnst" == next)
        return "VARIABLE, DIGIT";
    else if("add" == next)
        return "VARIABLE, DIGIT, (";
    else if("sub" == next)
        return "VARIABLE, DIGIT, (";
    else if("mult" == next)
        return "VARIABLE, DIGIT, (";
    else if("div" == next)
        return "VARIABLE, DIGIT, (";
    else if("paren" == next)
        return "VARIABLE, DIGIT, (";
    else if("array" == next)
        return "[";
    else if("arraydec" == next)
        return "VARIABLE";
    else if("assign" == next)
        return "VARIABLE";
    else if("multarg" == next)
        return "), ','";
    else if("compare" == next)
        return "(";
    else if("declare" == next)
        return "INTEGER, )";
    else if("multdec" == next)
        return "), ','";
    else if("init" == next)
        return "INTEGER";
	else if ("initassign" == next)
		return "=, ;";
    else if("loop" == next)
        return "WHILE, DO";
    else if("case" == next)
        return "IF";
    else if("elcase" == next)
        return "ELSE";
    else if("relate" == next)
        return "<, >, <=, >=, ==, !=";
    else if("code" == next)
        return "{";
    else if("middle" == next)
        return "VARIABLE, INTEGER, WHILE, DO, IF, READ, WRITE, RETURN, }";
    else if("read" == next)
        return "READ";
    else if("write" == next)
        return "WRITE";
    else //Terminal is next
        return next;
}

void WriteToMil(string text)
{
    FILE *fp;
    fp = fopen("basic.mil", "r+");
    fputs(text.c_str(), fp);
    fclose(fp);
}

void addVariable(string name){
	addVariable(name, false);
}

void addVariable(string name, bool assign){
	if(false == vars->addVariable(name, assign)){
		semerror("\"" + name + "\" re-declaration");
	}
	vars->declare(name);
}

void addGlobal(string name){
	addGlobal(name, false);
}

void addGlobal(string name, bool assign){
	if(false == vars->addGlobal(name, assign)){
		semerror("\"" + name + "\" re-declaration");
	}
}

void addFunc(string name){
	if(false == vars->addFunc(name)){
		semerror("\"" + name + "\" re-declaration");
	}
}

string* callFunc(string name){
	string* tmp = vars->callFunc(name);
	if(!tmp){
		semerror("undeclared function \"" + name + "\"");
	}
	return tmp;
}

int semerror(string s){
	extern int yylineno;

	cerr << "SEMANTIC ERROR: \"" << s << "\" on line " << yylineno << endl;
	delete vars;
	exit(1);
}

int yyerror(string s)
{
	extern int yylineno;	// defined and maintained in lex.c

	cerr << "ERROR: "  << " at symbol \"" << yytext;
	cerr << "\" on line " << yylineno << endl;
	cout << "EXPECTED: " << "\"" + choosenext(expect) + "\"" << endl;
	delete vars;
	exit(1);
}

int yyerror(char *s)
{
	delete vars;
	return yyerror(string(s));
}


