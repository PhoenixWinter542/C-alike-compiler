#include "variables.cpp"
#include <string>
using namespace std;

class operations{
	private:
		variables global;
		vector<variables*> local;
		int scope;
		string mil;
		int tmpCount;
		string errors;
		vector<int> storeTmpCount;
		vector<string> curFunc;	
		vector<string> allFunc;
		vector<string*> garbageTmp;
		int argPos;
		string* failReturn;

		void semerror(string s);
		void addLine(string line);
		void beginFunc(string name);
		void endFunc();
		string toString(int val);
		string* getTmp();
		bool funcDeclared(string name);
		void assigned(string name);
		void assigned(string name, string index);

		//Semantic handling
		void redeclare(string name){semerror("\""+ name + "\" re-declaration");};//
		void varAsArr(string name){semerror("Variable \""+ name + "\" used as array");};//
		void arrAsVar(string name){semerror("Array \""+ name + "\" used as variable");};//
		void undeclared(string name){semerror("Use of undeclared variable \""+ name + "\"");};//
		void unassigned(string name){semerror("Use of unassigned variable \""+ name + "\"");};//
		void unassigned(string name, string index){semerror("Use of unassigned variable \""+ name + "[" + index + "]\"");};//
		void segfault(string name, string index){semerror("Memory access violation from \""+ name + "[" + index + "]\"");};//
		void noMain(){semerror("No main function found");};//
		void mainArg(){semerror("main function cannot take arguments");};//
		void negArrSize(string name, string index){semerror("Invalid array size \""+ name + "[" + index + "]\"");};

	public:
		string getErrors();
		void newScope();
		void popScope();
		void addVariable(string name){addVariable(name, false, "");};
		void addVariable(string name, string array){addVariable(name, false, array);}
		void addVariable(string name, bool assigned, string array);
		
		void addGlobal(string name){addGlobal(name, false, "");};
		void addGlobal(string name, bool assigned, string array);
		void addFunc(string name);
		void addArg(string name){addArg(name, "");};
		void addArg(string name, string array);

		//Mil Functions
		void addParam(string name);
		string* callFunc(string name);
		void retFunc(string ret);
		void declare(string name);
		void declare(string name, string size);
		void copy(string dst, string src);
		void copy(string dst);
		string* arrToVar(string src, string index);
		void varToArr(string dst, string index, string src);
		void read(string dst);
		void read(string dst, string index);
		void write(string src);
		void write(string src, string index);
		string* combo(string src1, string scr2, string op);
		void combo(string dst, string src1, string src2, string op);
		void label(string label);
		void go(string label);
		void go(string label, string predicate);
		string getMil();

		//Constructors
		operations();

		//Deconstrucor
		~operations();
};

void operations::semerror(string s){
	extern int yylineno;
	errors += "SEMANTIC ERROR: " + s + " on line " + toString(yylineno) + "\n";
}


string operations::getErrors(){
	return errors;
}

void operations::addVariable(string name, bool assigned, string array){
	if("" != array)
		if('-' == array[0]){
			negArrSize(name, array);
			return;
		}
	if( false == local[scope]->addVariable(name, assigned, array))
		redeclare(name);
	if("" == array)
		declare(name);
	else
		declare(name, array);
}

void operations::addFunc(string name){
	newScope();
	curFunc[scope] = name;
	allFunc.push_back(name);
	addLine("func " + name);
	addGlobal(name, true, "");
}

//Converts up to 32 bit ints into strings
string operations::toString(int val){
	char str[12];
	snprintf(str, sizeof(str), "%d", val);
	return str;
}

string* operations::getTmp(){
	string* tmp = new string("_tmp" + toString(tmpCount++));
	garbageTmp.push_back(tmp);
	declare(*tmp);
	return tmp;
}

bool operations::funcDeclared(string name){
	for(unsigned int i = 0; i < allFunc.size(); i++){
		if(name == allFunc[i])
			return true;
	}
	return false;
}

void operations::newScope(){
	variables* tmp = new variables(global.getStruct());
	local.push_back(tmp);
	storeTmpCount.push_back(tmpCount);
	scope++;
	curFunc.push_back("");
}

void operations::popScope(){
	if(0 < local.size()){
		delete local[scope];
		local.pop_back();
		if("" != curFunc[scope]){
			endFunc();
		}
		curFunc.pop_back();
		scope--;
		tmpCount = storeTmpCount.back();
		storeTmpCount.pop_back();
	}
}

operations::operations(){
	scope = -1;
	mil = "";
	tmpCount = 0;
	argPos = 0;
	errors = "";
	failReturn = new string("");
}

operations::~operations(){
	while(false == garbageTmp.empty()){
		delete garbageTmp.back();
		garbageTmp.pop_back();
	}
	while(false == local.empty()){
		delete local.back();
		local.pop_back();
	}
	delete failReturn;
}

void operations::assigned(string name){
	local[scope]->assigned(name);
	if(true == global.assigned(name)){		//Set global to assigned for all scopes
		for(int i = 0; i < scope; i++){
			local[scope]->assigned(name);
		}
	}
}

void operations::assigned(string name, string index){
	local[scope]->assigned(name, index);
	if(true == global.assigned(name, index)){		//Set global to assigned for all scopes
		for(int i = 0; i < scope; i++){
			local[scope]->assigned(name);
		}
	}
}

void operations::addGlobal(string name, bool assigned, string array){
	if(true == global.addVariable(name, assigned, array)){
		for(int i = 0; i <= scope; i++){
			if(false == local[i]->addVariable(name, assigned, array))		//Adds global to all scopes, returns false if global name was already used in a scope
				redeclare(name);
		}
	}
	else
		redeclare(name);
}


	void operations::addArg(string name, string array){
		if("main" == curFunc[scope])
			mainArg();
		addVariable(name, false, array);
		copy(name);
	}



//------------------------------------------------------------------------------------------------------------------------------------------------



void operations::addLine(string line){
	mil += line + "\n";
}

void operations::beginFunc(string name){
	addLine("func " + name);
}
void operations::endFunc(){
	addLine("endfunc\n");
	argPos = 0;
}
void operations::addParam(string name){
	addLine("param " + name);
}
string* operations::callFunc(string name){
	if(true == funcDeclared(name)){
		string* tmp = getTmp();
		addLine("call " + name + ", " + *tmp);
		return tmp;
	}
	else
		semerror("undeclared function \"" + name + "\"");
	return failReturn;
}
void operations::retFunc(string ret){
	addLine("ret " + ret);
}
//Variable declaration
void operations::declare(string name){
	addLine(". " + name);
}
//Array declaration
void operations::declare(string name, string size){
	addLine(".[] " + name + ", " + size);
}
//dst = src
void operations::copy(string dst, string src){
	if(local[scope]->isUsed(dst)){
		if(local[scope]->isArray(dst))
			arrAsVar(dst);
		if(local[scope]->isArray(src))
			arrAsVar(src);
		if('-' == src[0])
			src = *combo("0", src.substr(1), "-");
		if('_' == src[0] || isdigit(src[0]) || true == local[scope]->isAssigned(src)){		//strings starting with _ are assigned when created, strings starting with digit are constants
			addLine("= " + dst + ", " + src);
			assigned(dst);
		}
		else
			unassigned(src);
	}
	else
		undeclared(dst);
}
//Declares parameter values		= dst, $0		 	dst = $0 ($0 is the 1st function parameter) 
void operations::copy(string dst){
	if(local[scope]->isUsed(dst))	//Shouldn't be neccessary considering addArg is the only path here
		addLine("= " + dst + ", " + "$" + toString(argPos++));
	else
		undeclared(dst);
}
//dst = src[index]
string* operations::arrToVar(string src, string index){
	if(local[scope]->isUsed(src)){
		if(true == local[scope]->isArray(src)){
			if(false == local[scope]->outOfBounds(src, index)){
				if(true == local[scope]->isAssigned(src, index)){
					string* tmp = getTmp();
					addLine("=[] " + *tmp + ", " + src + ", " + index);
					return tmp;
				}
				else
					unassigned(src, index);
			}
			else
				segfault(src, index);
		}
		else
			varAsArr(src);
	}
	else
		undeclared(src);
	return failReturn;
}
//dst[index] = src
void operations::varToArr(string dst, string index, string src){
	if(local[scope]->isUsed(dst)){
		if('_' == src[0] || isdigit(src[0]) || local[scope]->isUsed(src)){
			if(true == local[scope]->isArray(dst)){
				if(false == local[scope]->isArray(src)){
					if(false == local[scope]->outOfBounds(dst, index)){
						addLine("[]= " + dst + ", " + index + ", " + src);
						assigned(dst, index);
					}
					else{
						segfault(dst, index);
					}
				}
				else
					arrAsVar(src);
			}
			else
				varAsArr(dst);
		}
		else
			undeclared(src);
	}
	else
		undeclared(dst);
}
//Sets variable to input
void operations::read(string dst){
	addLine(".< " + dst);
}
//Sets array element to input
void operations::read(string dst, string index){
	addLine(".[]< " + dst + ", " + index );
}
//Outputs variable
void operations::write(string src){
	addLine(".> " + src);
}
//Outputs array element
void operations::write(string src, string index){
	addLine(".[]> " + src + ", " + index );
}
string* operations::combo(string src1, string src2, string op){
	string* tmp = getTmp();
	combo(*tmp, src1, src2, op);
	return tmp;
}
//Handles math, comparison, logical operators
void operations::combo(string dst, string src1, string src2, string op){
	addLine(op + " " + dst + ", " + src1 + ", " + src2);
}
//Create label
void operations::label(string label){
	addLine(": " + label);
}
//goto label
void operations::go(string label){
	addLine(":= " + label);
}
//if(predicate == 1) goto label
void operations::go(string label, string predicate){
	addLine("?:= " + label + ", " + predicate);
}
string operations::getMil(){
	for(unsigned int i = 0; i < allFunc.size(); i++){
		if("main" == allFunc[i])
			return mil;
	}
	noMain();
	return "";
}