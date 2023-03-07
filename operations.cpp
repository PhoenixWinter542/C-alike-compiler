#include "variables.cpp"
#include <string>
using namespace std;

class operations{
	private:
		struct labelStruct{
			string ifLbl;
			string elseLbl;
			string assignCond;
		};

		variables global;
		vector<variables*> local;
		int scope;
		string mil;
		int tmpCount;
		int lblCount;
		string errors;
		vector<int> storeTmpCount;
		vector<string> curFunc;	
		vector<string> allFunc;
		vector<labelStruct> labels;
		vector<string*> garbageTmp;
		bool trackCondition;
		int argPos;

		void semerror(string s);
		void addLine(string line);
		void beginFunc(string name);
		void endFunc();
		string toString(int val);
		string* getTmp();
		string getLbl();
		bool funcDeclared(string name);
		void assigned(string name);
		void assigned(string name, string index);
		bool testVar(string name);
		bool testArr(string name, string index);
		bool isAssigned(string name);
		bool isAssigned(string name, string index);

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
		void invalidBreak(){semerror("Invalid break");};

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
		void startIf(string compare);
		void endIf();
		void startElse();
		void startLoop();
		void startLoop(string condition);
		void endLoop();
		void endLoop(string condition);
		void startCondition(){trackCondition = true;};
		void endCondition(){trackCondition = false;};
		void escape();

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
		string* flip(string src);
		void flip(string dst, string src);
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

string operations::getLbl(){
	return "_lbl" + toString(lblCount++);
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

	if(-1 < scope)
		local[scope + 1]->addStruct(local[scope]->getStruct());		//Variables can be accessed by nested scopes
	scope++;
	curFunc.push_back("");
	labelStruct tmpLbl;
	tmpLbl.ifLbl = "";
	tmpLbl.elseLbl = "";
	tmpLbl.assignCond = "";
	labels.push_back(tmpLbl);
}

void operations::popScope(){
	if(0 < local.size()){
		delete local[scope];
		local.pop_back();
		if("" != curFunc[scope]){
			endFunc();
		}
		curFunc.pop_back();
		labels.pop_back();
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
	trackCondition = false;
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
}

void operations::assigned(string name){
	local[scope]->assigned(name);
	bool write = global.isAssigned(name);
	for(int i = 0; i < scope; i++){
		if(true == write)
			local[i]->assigned(name);
		else if(local[i]->isUsed(name)){
			write = true;
			local[i]->assigned(name);
		}
	}
}

void operations::assigned(string name, string index){
	local[scope]->assigned(name, index);
	bool write = global.isAssigned(name, index);
	for(int i = 0; i < scope; i++){
		if(true == write)
			local[i]->assigned(name, index);
		else if(local[i]->isUsed(name)){
			write = true;
			local[i]->assigned(name, index);
		}
	}
}

bool operations::testVar(string name){
	if('_' != name[0] && false == isdigit(name[0]) && false == local[scope]->isUsed(name)){
		unassigned(name);
		return false;
	}
	else if(true == local[scope]->isArray(name)){
		arrAsVar(name);
		return false;
	}
	return true;

}

bool operations::testArr(string name, string index){
	if(false == local[scope]->isUsed(name)){
		unassigned(name);
		return false;
	}
	else if(false == local[scope]->isArray(name)){
		varAsArr(name);
		return false;
	}
	else if(true == local[scope]->outOfBounds(name, index)){
		segfault(name, index);
		return false;
	}
	return true;
}

bool operations::isAssigned(string name){
	if('_' != name[0] && false == isdigit(name[0]) && false == local[scope]->isAssigned(name)){
		unassigned(name);
		return false;
	}
	return true;
}

bool operations::isAssigned(string name, string index){
	if('_' != name[0] && false == isdigit(name[0]) && false == local[scope]->isAssigned(name, index)){
		unassigned(name, index);
		return false;
	}
	return true;
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
		addVariable(name, true, array);
		copy(name);
	}

	void operations::startIf(string condition){
		newScope();
		labels[scope].elseLbl = getLbl();
		labels[scope].ifLbl = getLbl();
		flip(condition, condition);		//condition = !condition
		go(labels[scope].elseLbl, condition);
	}

	void operations::endIf(){
		label(labels[scope].ifLbl);
		popScope();
	}

	void operations::startElse(){
		go(labels[scope].ifLbl);
		label(labels[scope].elseLbl);
	}

	void operations::startLoop(){
		newScope();
		labels[scope].ifLbl = getLbl();
		labels[scope].elseLbl = getLbl();
		label(labels[scope].ifLbl);
	}

	void operations::startLoop(string condition){
		labels[scope].ifLbl = getLbl();
		labels[scope].elseLbl = getLbl();
		label(labels[scope].ifLbl);
		mil += labels[scope].assignCond;
		flip(condition, condition);
		go(labels[scope].elseLbl, condition);
	}

	void operations::endLoop(){
		go(labels[scope].ifLbl);
		label(labels[scope].elseLbl);
		popScope();
	}

	void operations::endLoop(string condition){
		mil += labels[scope].assignCond;
		go(labels[scope].ifLbl, condition);
		label(labels[scope].elseLbl);
		popScope();
	}

	void operations::escape(){
		if(false == trackCondition){
			if(1 < scope){
				if("" != labels[scope - 1].elseLbl){
					go(labels[scope - 1].elseLbl);
					return;
				}
			}
		}
		invalidBreak();
	}


//------------------------------------------------------------------------------------------------------------------------------------------------



void operations::addLine(string line){
	if(true == trackCondition)
		labels[scope].assignCond += line + "\n";
	else
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
		semerror("Use of undeclared function \"" + name + "\"");
	string* tmp = new string(name);
	garbageTmp.push_back(tmp);
	return tmp;
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
	if('-' == src[0])
		src = *combo("0", src.substr(1), "-");
	if(testVar(dst) && testVar(src)){
		if(true == isAssigned(src)){		//strings starting with _ are assigned when created, strings starting with digit are constants
			addLine("= " + dst + ", " + src);
			assigned(dst);
		}
	}
}
//Declares parameter values		= dst, $0		 	dst = $0 ($0 is the 1st function parameter) 
void operations::copy(string dst){
	if(true == testVar(dst))	//Shouldn't be neccessary considering addArg is the only path here
		addLine("= " + dst + ", " + "$" + toString(argPos++));
}
//dst = src[index]
string* operations::arrToVar(string src, string index){
	if(true == testArr(src, index)){
		if(true == isAssigned(src, index)){
			string* tmp = getTmp();
			addLine("=[] " + *tmp + ", " + src + ", " + index);
			return tmp;
		}
	}
	string* tmp = new string(src);
	garbageTmp.push_back(tmp);
	return tmp;
}
//dst[index] = src
void operations::varToArr(string dst, string index, string src){
	if(true == testArr(dst, index) && true == testVar(src)){
		if(true == isAssigned(src)){
			addLine("[]= " + dst + ", " + index + ", " + src);
			assigned(dst, index);
		}
	}
}
//Sets variable to input
void operations::read(string dst){
	if(true == testVar(dst))
		addLine(".< " + dst);
	else
		arrAsVar(dst);
}
//Sets array element to input
void operations::read(string dst, string index){
	if(true == testArr(dst, index)){
		addLine(".[]< " + dst + ", " + index );
	}
}
//Outputs variable
void operations::write(string src){
	if(true == testVar(src)){
		if('_' == src[0] || true == local[scope]->isAssigned(src)){		//strings starting with _ are assigned when created
			addLine(".> " + src);
		}
		else
			unassigned(src);
	}
}
//Outputs array element
void operations::write(string src, string index){
	if(true == testArr(src, index)){
		if(true == local[scope]->isAssigned(src))
			addLine(".[]> " + src + ", " + index );
		else
			unassigned(src, index);
	}
}
string* operations::combo(string src1, string src2, string op){
	string* tmp = getTmp();
	combo(*tmp, src1, src2, op);
	return tmp;
}
//Handles math, comparison, logical operators
void operations::combo(string dst, string src1, string src2, string op){
	if(true == testVar(dst) && true == testVar(src1) && true == testVar(src2)){
		if(true == isAssigned(src1)){
			if(true == isAssigned(src2)){
				addLine(op + " " + dst + ", " + src1 + ", " + src2);
			}
		}
	}
}
//dst = !src
string* operations::flip(string src){
	string* dst = getTmp();
	flip(*dst, src);
	return dst;
}
//dst = !src
void operations::flip(string dst, string src){
	if(true == testVar(dst) && true == testVar(src)){
		if(true == isAssigned(src))
			addLine("! " + dst + ", " + src);
	}
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