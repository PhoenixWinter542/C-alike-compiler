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
start:		function multfunc																																				{ cout << "102" << endl; vars->clean(); WriteToMil(vars->getMil()); delete vars;}
	;

/* Handles multiple functions */
multfunc:	/* empty */
	|	function multfunc
	;

/* Function with body */
function:	type { expect = "VARIABLE";} VARIABLE { addFunc(*yylval); expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code	{ vars->popScope(); }
	;

/* Variable declarations for function definitions */
declare:	/* empty */																																							{ cout << "115" << endl;  }
	|	type { expect = "varcnst";} varcnst { cout << $2 << endl; expect = "multdec"; addVariable(*$2); } multdec																			{ cout << "116" << endl;  }
	;

/* Handles multiple declarations */
multdec:	/* empty */																																						{ cout << "120" << endl;  }
	|	SEPARATOR { expect = "varcnst";} varcnst {  addVariable(*$2); expect = "multdec";} multdec																		{ cout << "121" << endl;  }
	;

/* call to a function */
call:		VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { vars->addParam(*$3); expect = "multarg";} multarg { expect = ")";} R_PAREN					{ cout << "125" << "\t"; $$ = callFunc(*$1); }
	;

/* Handles having more than one argument */
multarg:	/* empty */																																						{ cout << "129" << endl;  }
	|	SEPARATOR { expect = "add";} add { expect = "multarg";} multarg																										{ cout << "130" << "\t"; vars->addParam(*$2); }
	;

/* List of accepted types */
type:		INTEGER																																							{ cout << "134" << endl; }
	;

/* Variables, constants, and things that return constants */
varcnst:		VARIABLE																																					{ $$ = std::string; cout << "138" << endl; }
	|	DIGIT																																								{ cout << "139" << endl; $$ = $1; }
	|	VARIABLE { expect = "array";}  array																																{ cout << "140" << endl; $$ = $1; }
	|	call																																								{ cout << "141" << endl; $$ = $1; }
	;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:		add { expect = "+"; } ADD { expect = "sub"; } sub																												{ cout << "146" << "\t"; $$ = vars->combo("+", *$1, *$3); }
	|	sub																																									{ cout << "147" << endl; $$ = $1; }
	;

sub:		sub { expect = "-"; } SUBTRACT { expect = "mult";} mult																											{ cout << "150" << "\t"; $$ = vars->combo("-", *$1, *$3); }
	|	mult																																								{ cout << "151" << endl; $$ = $1; }
	;

mult:		mult { expect = "*"; } MULTIPLY { expect = "div"; } div																											{ cout << "154" << "\t"; $$ = vars->combo("*", *$1, *$3); }
	|	div																																									{ cout << "155" << endl; $$ = $1; }
	;

div:		div { expect = "/"; } DIVIDE { expect = "paren"; } paren																										{ cout << "158" << endl; $$ = vars->combo("/", *$1, *$3); }
	|	paren																																								{ cout << "159" << endl; $$ = $1; }
	;

paren:		L_PAREN { expect = "add"; } add { expect = ")"; } R_PAREN																										{ cout << "162" << endl; $$ = $2; }
	|	varcnst																																								{ cout << "163" << endl; $$ = $1; }
	;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:		L_BRACK { expect = "add";} add { expect = "]";} R_BRACK																											{ cout << "169" << endl; $$ = $2; }
	;

/* Array declaration */
arraydec:	VARIABLE { addVariable(*$1); expect = "array";} array																											{ cout << "173" << "\t"; vars->declare(*$1, *$2); $$ = $1; }     /* adding type gives reduce/reduce warning */
	;

/* Assigns a value to a variable */
assign:		VARIABLE {  expect = "=";} EQUAL { expect = "add";} add																											{ cout << "177" << "\t"; vars->copy(*$1, *$3); }
	;

/* Conditional statements (Includes parentheses) */
compare:	L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN														{ cout << "181" << endl;  }
	;

/* Declaration of local variables */
init:		type { expect = "VARIABLE"; } VARIABLE {  addVariable(*$2); expect = "initassign"; } initassign															{ cout << "185" << "\t"; if($3){vars->copy(*$2, *$3);}; $$ = $2; }
	;

initassign:	/* empty */																																						{ cout << "188" << endl; $$ = NULL; }
	|	EQUAL { expect = "add"; } add																																		{ cout << "189" << endl; $$ = $2; }
	;

/* Currently handles "do while" and "while" loops */
loop:		WHILE { expect = "compare";} compare { expect = "code";} code																									{ cout << "193" << endl;  }
	|	DO { expect = "code";} code { expect = "while";} WHILE { expect = "compare";} compare { expect = ";";} END															{ cout << "194" << endl;  }
	;

/* If or If else */
case:	IF { expect = "compare";} compare { expect = "code";} code { expect = "elcase";} elcase																				{ cout << "198" << endl;  }
	;

/* handles any else that may occur */
elcase:		/* empty */																																						{ cout << "202" << endl;  }
	|	ELSE { expect = "code";} code																																		{ cout << "203" << endl;  }
	;

/* List of accepted comparison operators */
relate:		LESS																																							{ cout << "207" << endl; $$ = $1; }
	|	GREATER																																								{ cout << "208" << endl; $$ = $1; }
	|	LTE																																									{ cout << "209" << endl; $$ = $1; }
	|	GTE																																									{ cout << "210" << endl; $$ = $1; }
	|	COMPEQUAL																																							{ cout << "211" << endl; $$ = $1; }
	|	NOT EQUAL																																							{ cout << "212" << endl; $$ = $1; }
	;

/* Enforces the braces around a code block */
code:	L_BRACE { expect = "middle";} middle { expect = "}";} R_BRACE																										{ cout << "216" << endl;  }
	;

/* List of all things that can be in a code block */
middle:		/* empty */																																						{ cout << "220" << endl;  }
	|	assign { expect = ";";} END { expect = "middle";} middle																											{ cout << "221" << endl;  }
	|	init { expect = ";";} END { expect = "middle";} middle																												{ cout << "222" << endl;  }
	|	loop { expect = "middle";} middle																																	{ cout << "223" << endl;  }
	|	case { expect = "middle";} middle																																	{ cout << "224" << endl;  }
	|	read { expect = ";";} END { expect = "middle";} middle																												{ cout << "225" << endl;  }
	|	write { expect = ";";} END { expect = "middle";} middle																												{ cout << "226" << endl;  }
	|	arraydec { expect = ";";} END { expect = "middle";} middle																											{ cout << "227" << endl;  }
	|	RETURN { expect = "add";} add { vars->retFunc(yytext); expect = ";";} END { expect = "middle";} middle																{ cout << "228" << endl;  }
	;

/* Read user input */
read:	READ { expect = "VARIABLE"; } VARIABLE																																{ cout << "232" << "\t"; vars->read(*$2); }
	;

/* Output to console */
write:	WRITE { expect = "VARIABLE"; } VARIABLE																																{ cout << "236" << "\t"; vars->write(*$2); }
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
	cout << "addFunc " << name << endl;
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


