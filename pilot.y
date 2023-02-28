%{
#include "heading.h"
#include "operations.cpp"
int yyerror(char *s);
int yylex(void);
int semerror(string s);
void WriteToMil(string text);
void addArg(string name);
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
%define api.value.type {string*}

%start	start

/* Comparisons */
%token	LESS
%token	GREATER
%token	LTE
%token	GTE
%token	COMPEQUAL
%token	NOT

/* Math */
%token	ADD
%token	SUBTRACT
%token	MULTIPLY
%token	DIVIDE
%token	DIGIT

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
%left VARIABLE
%left	READ
%left	WRITE

/* Types */
%left	INTEGER


%%

/* Allows one or more functions */
start:		function multfunc																																				{ $start = $function; WriteToMil(vars->getMil()); delete vars;}
	;

/* Handles multiple functions */
multfunc:	/* empty */		{ }
	|	function { WriteToMil(vars->getMil()); } multfunc	{ $$ = $function;}
	;

/* Function with body */
function:	type { expect = "VARIABLE";} VARIABLE { addFunc(*$VARIABLE); expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code	{ vars->popScope(); WriteToMil(vars->getMil()); $function = $type; }
	;

/* Variable declarations for function definitions */
declare:	/* empty */																																							{  }
	|	type { expect = "VARIABLE";} VARIABLE { expect = "multdec"; addArg(*$VARIABLE); } multdec																				{  }
	;

/* Handles multiple declarations */
multdec:	/* empty */																																						{  }
	|	SEPARATOR { expect = "type"; } type { expect = "VARIABLE";} VARIABLE {  addArg(*$VARIABLE); expect = "multdec";} multdec																		{  }
	;

/* call to a function */
call:		VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { vars->addParam(*$add); expect = "multarg";} multarg { expect = ")";} R_PAREN					{ $call = callFunc(*$VARIABLE); }
	;

/* Handles having more than one argument */
multarg:	/* empty */																																						{  }
	|	SEPARATOR { expect = "add";} add { expect = "multarg";} multarg																										{ vars->addParam(*$add); }
	;

/* List of accepted types */
type:		INTEGER																																							{ }
	;

/* Variables, constants, and things that return constants */
varcnst:		VARIABLE																																					{ $varcnst = $VARIABLE; }
	|	DIGIT																																								{ $varcnst = $DIGIT; }
	|	VARIABLE { expect = "array";}  array																																{ $varcnst = vars->arrToVar(*$VARIABLE, *$array); }
	|	call																																								{ $varcnst = $call; }
	;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:		add { expect = "+"; } ADD { expect = "sub"; } sub																												{ $$ = vars->combo( *$1, *$sub, "+"); }
	|	sub																																									{ $$ = $sub; }
	;

sub:		sub { expect = "-"; } SUBTRACT { expect = "mult";} mult																											{ $$ = vars->combo(*$1, *$mult, "-"); }
	|	mult																																								{ $$ = $mult; }
	;

mult:		mult { expect = "*"; } MULTIPLY { expect = "div"; } div																											{ $$ = vars->combo(*$1, *$div, "*"); }
	|	div																																									{ $$ = $div; }
	;

div:		div { expect = "/"; } DIVIDE { expect = "paren"; } paren																										{ $$ = vars->combo(*$1, *$paren, "/"); }
	|	paren																																								{ $$ = $paren; }
	;

paren:		L_PAREN { expect = "add"; } add { expect = ")"; } R_PAREN																										{ $paren = $add; }
	|	varcnst																																								{ $paren = $varcnst; }
	;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:		L_BRACK { expect = "add";} add { expect = "]";} R_BRACK																											{ $array = $add; }
	;

/* Array declaration */
arraydec:	type array VARIABLE { expect = "array";}																														{ vars->declare(*$VARIABLE, *$array); $arraydec = $VARIABLE; }     /* adding type gives reduce/reduce warning */
	;

/* Assigns a value to a variable */
assign:		VARIABLE {  expect = "=";} EQUAL { expect = "add";} add																											{ vars->copy(*$VARIABLE, *$add); }
	|	VARIABLE { expect = "array"; } array {expect = "="; } EQUAL { expect = "add"; } add																					{ vars->varToArr(*$VARIABLE, *$array, *$add); }
	;

/* Conditional statements (Includes parentheses) */
compare:	L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN														{  }
	;

/* Declaration of local variables */
init:		type { expect = "VARIABLE"; } VARIABLE {  addVariable(*$VARIABLE); expect = "initassign"; } initassign															{ if($initassign){vars->copy(*$VARIABLE, *$initassign);}; $init = $VARIABLE; }
	;

initassign:	/* empty */																																						{ $initassign = NULL; }
	|	EQUAL { expect = "add"; } add																																		{ $initassign = $add; }
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
relate:		LESS																																							{ $relate = $LESS; }
	|	GREATER																																								{ $relate = $GREATER; }
	|	LTE																																									{ $relate = $LTE; }
	|	GTE																																									{ $relate = $GTE; }
	|	COMPEQUAL																																							{ $relate = $COMPEQUAL; }
	|	NOT EQUAL																																							{ $relate = new string("!="); }
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
	|	RETURN { expect = "add";} add { vars->retFunc(*$add); expect = ";";} END { expect = "middle";} middle																{  }
	;

/* Read user input */
read:	READ { expect = "VARIABLE"; } varcnst																																{ vars->read(*$varcnst); }
	;

/* Output to console */
write:	WRITE { expect = "VARIABLE"; } varcnst																																{ vars->write(*$varcnst); }
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
        return "INTEGER";
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

void addArg(string name){
	addVariable(name);
	vars->copy(name);
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

	cerr << "SEMANTIC ERROR: " << s << " on line " << yylineno << endl;
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


