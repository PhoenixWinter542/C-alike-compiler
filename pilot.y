%{
#include "heading.h"
int yyerror(char *s);
int yylex(void);
void printpos(string tokens, bool nonterm);
string expect = "start";
string txt = "";
string store = "";
extern char *yytext;	// defined and maintained in lex.c
%}

%union{
	int		int_val;
	string*	op_val;
}

%start	start

/* Comparisons */
%left	LESS
%left	GREATER
%left	LTE
%left	GTE
%left  	COMPEQUAL
%left	NOT

/* Math */
%left	ADD
%left	SUBTRACT
%left	MULTIPLY
%left	DIVIDE
%left	DIGIT

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
%left	VARIABLE
%left	READ
%left	WRITE

/* Types */
%left	INTEGER

%%

/* Allows one or more functions */
start:		function multfunc																																				{ printpos("start -> function", true); }
	;

/* Handles multiple functions */
multfunc:	/* empty */
	|	function multfunc
	;

/* Function with body */
function:	type { expect = "VARIABLE";} VARIABLE { store = yytext; expect = "(";} L_PAREN { expect = "declare";} declare { expect = ")";} R_PAREN { expect = "code";} code	{ txt = store; printpos("function -> type VARIABLE L_PAREN declare R_PAREN code", false); }
	;

/* call to a function */
call:		VARIABLE { expect = "(";} L_PAREN { expect = "add";} add { expect = "multarg";} multarg { expect = ")";} R_PAREN												{ printpos("call -> VARIABLE L_PAREN add multarg R_PAREN", true); }
	;

/* List of accepted types */
type:		INTEGER																																							{ printpos("type -> INTEGER", true); }
	;

/* Needed to avoid missing some yytext updates */
varcnst:	{ txt = yytext; } updatetxt
	;

/* Variables, constants, and things that return constants */
updatetxt:		VARIABLE																																					{ printpos("varcnst -> VARIABLE", false); }
	|	DIGIT																																								{ printpos("varcnst -> DIGIT", false); }
	|	VARIABLE { txt = yytext; expect = "array";}  array																													{ printpos("varcnst -> VARIABLE array", true); }
	|	call																																								{ printpos("varcnst -> call", true); }
	;

/*------------------- Beginning of math handling, can reduce to just varcnst ------------------------------*/

add:		add { expect = "+";} ADD { expect = "sub";} sub																													{ printpos("add -> add ADD sub", true); }
	|	sub																																									{ printpos("add -> sub", true); }
	;

sub:		sub { expect = "-";} SUBTRACT { expect = "mult";} mult																											{ printpos("sub -> sub SUBTRACT mult", true); }
	|	mult																																								{ printpos("sub -> mult", true); }
	;

mult:		mult { expect = "*";} MULTIPLY { expect = "div";} div																											{ printpos("mult -> mult MULTIPLY div", true); }
	|	div																																									{ printpos("mult -> div", true); }
	;

div:		div { expect = "/";} DIVIDE { expect = "paren";} paren																											{ printpos("div -> div DIVIDE paren", true); }
	|	paren																																								{ printpos("div -> paren", true); }
	;

paren:		L_PAREN { expect = "add";} add { expect = ")";} R_PAREN																											{ printpos("paren -> L_PAREN add R_PAREN", true); }
	|	varcnst																																								{ txt = yytext; printpos("paren -> varcnst", true); }
	;

/*------------------------------------------- End of math handling -----------------------------------------*/

/* Definition of allowed array brackets */
array:		L_BRACK { expect = "add";} add { expect = "]";} R_BRACK																											{ printpos("array -> L_BRACK add R_BRACK", true); }
	;

/* Array declaration */
arraydec:	VARIABLE { expect = "array";} array																																{ txt = yytext; printpos("arraydec -> VARIABLE array", true); }     /* type gives the reduce/reduce warning */
	;

/* Assigns a value to a variable */
assign:		VARIABLE { expect = "=";} EQUAL { expect = "add";} add																											{ txt = yytext; printpos("assign ->  VARIABLE  EQUAL  add", true); }
	;

/* Handles having more than one argument */
multarg:	/* empty */																																						{ printpos("multarg -> epsilon", true); }
	|	SEPARATOR { expect = "add";} add { expect = "multarg";} multarg																										{ printpos("multarg -> SEPARATOR add multarg", true); }
	;

/* Conditional statements (Includes parentheses) */
compare:	L_PAREN { expect = "add";} add { expect = "relate";} relate { expect = "add";} add { expect = ")";} R_PAREN														{ printpos("compare -> L_PAREN add relate add R_PAREN", true); }
	;

/* Variable declarations for function calls and definitions */
declare:	/* empty */																																						{ printpos("declare -> epsilon", true); }
	|	type { expect = "varcnst";} varcnst { expect = "multdec";} multdec																									{ printpos("declare -> type varcnst multdec", true); }
	;

/* Handles multiple declarations */
multdec:	/* empty */																																						{ printpos("multdec -> epsilon", true); }
	|	SEPARATOR { expect = "varcnst";} varcnst { txt = yytext; expect = "multdec";} multdec																				{ printpos("multdec -> SEPARATOR varcnst multdec", true); }
	;

/* Declaration of local variables */
init:		type { expect = "VARIABLE"; } VARIABLE { txt = yytext; expect = "initassign"; } initassign																		{ printpos("init -> type VARIABLE initassign", true); }
	;

initassign:	/* empty */																																						{ printpos("initassign -> epsilon", true); }
	|	EQUAL { expect = "add"; } add																																		{ printpos("initassign ->  EQUAL add", true); }
	;

/* Currently handles "do while" and "while" loops */
loop:		WHILE { expect = "compare";} compare { expect = "code";} code																									{ printpos("loop -> WHILE compare code", true); }
	|	DO { expect = "code";} code { expect = "while";} WHILE { expect = "compare";} compare { expect = ";";} END															{ printpos("loop -> DO code WHILE compare", true); }
	;

/* If or If else */
case:	IF { expect = "compare";} compare { expect = "code";} code { expect = "elcase";} elcase																				{ printpos("case -> IF compare code elcase", true); }
	;

/* handles any else that may occur */
elcase:		/* empty */																																						{ printpos("elcase -> epsilon", true); }
	|	ELSE { expect = "code";} code																																		{ printpos("elcase -> ELSE code", true); }
	;

/* List of accepted comparison operators */
relate:		LESS																																							{ txt = yytext; printpos("relate -> LESS", true); }
	|	GREATER																																								{ txt = yytext; printpos("relate -> GREATER", true); }
	|	LTE																																									{ txt = yytext; printpos("relate -> LTE", true); }
	|	GTE																																									{ txt = yytext; printpos("relate -> GTE", true); }
	|	COMPEQUAL																																							{ txt = yytext; printpos("relate -> COMPEQUAL", true); }
	|	NOT EQUAL																																							{ txt = yytext; printpos("relate -> NOT EQUAL", true); }
	;

/* Enforces the braces around a code block */
code:	L_BRACE { expect = "middle";} middle { expect = "}";} R_BRACE																										{ printpos("code -> L_BRACE middle R_BRACE", true); }
	;

/* List of all things that can be in a code block */
middle:		/* empty */																																						{ printpos("middle -> epsilon", true); }
	|	assign { expect = ";";} END { expect = "middle";} middle																											{ printpos("middle -> assign END middle", true); }
	|	init { expect = ";";} END { expect = "middle";} middle																												{ printpos("middle -> declare END middle", true); }
	|	loop { expect = "middle";} middle																												{ printpos("middle -> loop END middle", true); }
	|	case { expect = "middle";} middle																																	{ printpos("middle -> read END middle", true); }
	|	read { expect = ";";} END { expect = "middle";} middle																												{ printpos("middle -> read END middle", true); }
	|	write { expect = ";";} END { expect = "middle";} middle																												{ printpos("middle -> write END middle", true); }
	|	arraydec { expect = ";";} END { expect = "middle";} middle																											{ printpos("middle -> arraydec END middle", true); }
	|	RETURN { expect = "add";} add { expect = ";";} END { expect = "middle";} middle																						{ printpos("middle -> RETURN add END middle", true); }
	;

/* Read user input */
read:	READ { expect = "VARIABLE"; } VARIABLE																																{ txt = yytext; printpos("read -> READ VARIABLE", false); }
	;

/* Output to console */
write:	WRITE { expect = "VARIABLE"; } VARIABLE																																{ txt = yytext; printpos("write -> WRITE VARIABLE", false); }
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

void printpos(string tokens, bool nonterm)
{
	cout << tokens;
	if(!nonterm)
		cout << "   \t\t" << txt;
	cout << endl;

	return;
}

int yyerror(string s)
{
	extern int yylineno;	// defined and maintained in lex.c

	cerr << "ERROR: "  << " at symbol \"" << yytext;
	cerr << "\" on line " << yylineno << endl;
	cout << "EXPECTED: " << "\"" + choosenext(expect) + "\"" << endl;
	exit(1);
}

int yyerror(char *s)
{
	return yyerror(string(s));
}


