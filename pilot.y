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
start:		function multfunc																																				{ $start = $function; cout << "102" << endl; cout << vars->getMil(); WriteToMil(vars->getMil()); delete vars;}
	;

/* Handles multiple functions */
multfunc:	/* empty */		{ cout << "\t\tHERE" << endl;}
	|	function { WriteToMil(vars->getMil()); } multfunc	{ cout << "107" << endl; $$ = $function;}
	;

/* Function with body */
function:	type { expect = "VARIABLE";} VARIABLE { addFunc(*$VARIABLE); expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code	{ cout << "111\t" << *$VARIABLE << endl; vars->popScope(); WriteToMil(vars->getMil()); $function = $type; }
	;

/* Variable declarations for function definitions */
declare:	/* empty */																																							{ cout << "115" << endl;  }
	|	type { expect = "VARIABLE";} VARIABLE { expect = "multdec"; addArg(*$VARIABLE); } multdec																				{ cout << "116" << endl;  }
	;

/* Handles multiple declarations */
multdec:	/* empty */																																						{ cout << "120" << endl;  }
	|	SEPARATOR { expect = "type"; } type { expect = "VARIABLE";} VARIABLE {  addArg(*$VARIABLE); expect = "multdec";} multdec																		{ cout << "121" << endl;  }
	;

/* call to a function */
call:		VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { vars->addParam(*$add); expect = "multarg";} multarg { expect = ")";} R_PAREN					{ cout << "125" << "\t"; $call = callFunc(*$VARIABLE); }
	;

/* Handles having more than one argument */
multarg:	/* empty */																																						{ cout << "129" << endl;  }
	|	SEPARATOR { expect = "add";} add { expect = "multarg";} multarg																										{ cout << "130" << "\t"; vars->addParam(*$add); }
	;

/* List of accepted types */
type:		INTEGER																																							{ cout << "134" << endl; }
	;

/* Variables, constants, and things that return constants */
varcnst:		VARIABLE																																					{ $varcnst = $VARIABLE; cout << "138" << endl; }
	|	DIGIT																																								{ cout << "139" << endl; $varcnst = $DIGIT; }
	|	VARIABLE { expect = "array";}  array																																{ cout << "140" << endl; $varcnst = vars->arrToVar(*$VARIABLE, *$array); }
	|	call																																								{ cout << "141" << endl; $varcnst = $call; }
	;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:		add { expect = "+"; } ADD { expect = "sub"; } sub																												{ cout << "146\t"; $$ = vars->combo( *$1, *$sub, "+"); }
	|	sub																																									{ cout << "147\t" << *$1 << endl; $$ = $sub; }
	;

sub:		sub { expect = "-"; } SUBTRACT { expect = "mult";} mult																											{ cout << "150\t"; $$ = vars->combo(*$1, *$mult, "-"); }
	|	mult																																								{ cout << "151\t" << *$1 << endl; $$ = $mult; }
	;

mult:		mult { expect = "*"; } MULTIPLY { expect = "div"; } div																											{ cout << "154\t"; $$ = vars->combo(*$1, *$div, "*"); }
	|	div																																									{ cout << "155\t" << *$1 << endl; $$ = $div; }
	;

div:		div { expect = "/"; } DIVIDE { expect = "paren"; } paren																										{ cout << "158\t"; $$ = vars->combo(*$1, *$paren, "/"); }
	|	paren																																								{ cout << "159\t" << *$paren << endl; $$ = $paren; }
	;

paren:		L_PAREN { expect = "add"; } add { expect = ")"; } R_PAREN																										{ cout << "162\t" << *$add << endl; $paren = $add; }
	|	varcnst																																								{ cout << "163\t" << *$varcnst << endl; $paren = $varcnst; }
	;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:		L_BRACK { expect = "add";} add { expect = "]";} R_BRACK																											{ cout << "169" << endl; $array = $add; }
	;

/* Array declaration */
arraydec:	type array VARIABLE { expect = "array";}																														{ cout << "173" << "\t"; vars->declare(*$VARIABLE, *$array); $arraydec = $VARIABLE; }     /* adding type gives reduce/reduce warning */
	;

/* Assigns a value to a variable */
assign:		VARIABLE {  expect = "=";} EQUAL { expect = "add";} add																											{ cout << "177" << "\t"; vars->copy(*$VARIABLE, *$add); }
	|	VARIABLE { expect = "array"; } array {expect = "="; } EQUAL { expect = "add"; } add																					{ cout << "178" << "\t"; vars->varToArr(*$VARIABLE, *$array, *$add); }
	;

/* Conditional statements (Includes parentheses) */
compare:	L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN														{ cout << "182" << endl;  }
	;

/* Declaration of local variables */
init:		type { expect = "VARIABLE"; } VARIABLE {  addVariable(*$VARIABLE); expect = "initassign"; } initassign															{ cout << "186" << "\t"; if($initassign){vars->copy(*$VARIABLE, *$initassign);}; $init = $VARIABLE; }
	;

initassign:	/* empty */																																						{ cout << "189" << endl; $initassign = NULL; }
	|	EQUAL { expect = "add"; } add																																		{ cout << "190" << endl; $initassign = $add; }
	;

/* Currently handles "do while" and "while" loops */
loop:		WHILE { expect = "compare";} compare { expect = "code";} code																									{ cout << "194" << endl;  }
	|	DO { expect = "code";} code { expect = "while";} WHILE { expect = "compare";} compare { expect = ";";} END															{ cout << "195" << endl;  }
	;

/* If or If else */
case:	IF { expect = "compare";} compare { expect = "code";} code { expect = "elcase";} elcase																				{ cout << "199" << endl;  }
	;

/* handles any else that may occur */
elcase:		/* empty */																																						{ cout << "203" << endl;  }
	|	ELSE { expect = "code";} code																																		{ cout << "204" << endl;  }
	;

/* List of accepted comparison operators */
relate:		LESS																																							{ cout << "208" << endl; $relate = $LESS; }
	|	GREATER																																								{ cout << "209" << endl; $relate = $GREATER; }
	|	LTE																																									{ cout << "210" << endl; $relate = $LTE; }
	|	GTE																																									{ cout << "211" << endl; $relate = $GTE; }
	|	COMPEQUAL																																							{ cout << "212" << endl; $relate = $COMPEQUAL; }
	|	NOT EQUAL																																							{ cout << "213" << endl; $relate = new string("!="); }
	;

/* Enforces the braces around a code block */
code:	L_BRACE { expect = "middle";} middle { expect = "}";} R_BRACE																										{ cout << "217" << endl;  }
	;

/* List of all things that can be in a code block */
middle:		/* empty */																																						{ cout << "221" << endl;  }
	|	assign { expect = ";";} END { expect = "middle";} middle																											{ cout << "222" << endl;  }
	|	init { expect = ";";} END { expect = "middle";} middle																												{ cout << "223" << endl;  }
	|	loop { expect = "middle";} middle																																	{ cout << "224" << endl;  }
	|	case { expect = "middle";} middle																																	{ cout << "225" << endl;  }
	|	read { expect = ";";} END { expect = "middle";} middle																												{ cout << "226" << endl;  }
	|	write { expect = ";";} END { expect = "middle";} middle																												{ cout << "227" << endl;  }
	|	arraydec { expect = ";";} END { expect = "middle";} middle																											{ cout << "228" << endl;  }
	|	RETURN { expect = "add";} add { cout << "228\t"; vars->retFunc(*$add); expect = ";";} END { expect = "middle";} middle																{ cout << "228" << endl;  }
	;

/* Read user input */
read:	READ { expect = "VARIABLE"; } varcnst																																{ cout << "233" << "\t"; vars->read(*$varcnst); }
	;

/* Output to console */
write:	WRITE { expect = "VARIABLE"; } varcnst																																{ cout << "237" << "\t"; vars->write(*$varcnst); }
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
	cout << endl << vars->getMil() << endl;
	WriteToMil(vars->getMil());
	delete vars;
	exit(1);
}

int yyerror(string s)
{
	extern int yylineno;	// defined and maintained in lex.c

	cerr << "ERROR: "  << " at symbol \"" << yytext;
	cerr << "\" on line " << yylineno << endl;
	cout << "EXPECTED: " << "\"" + choosenext(expect) + "\"" << endl;
	WriteToMil(vars->getMil());
	delete vars;
	exit(1);
}

int yyerror(char *s)
{
	WriteToMil(vars->getMil());
	delete vars;
	return yyerror(string(s));
}


