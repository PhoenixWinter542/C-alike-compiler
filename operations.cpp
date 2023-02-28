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
		vector<int> storeTmpCount;
		vector<string> curFunc;	
		vector<string> allFunc;
		vector<string*> garbageTmp;
		int argPos;

		void assigned(string name);
		void addLine(string line);
		void beginFunc(string name);
		void endFunc();
		string toString(int val);
		string* getTmp();
		bool funcDeclared(string name);

	public:
		void newScope();
		void popScope();
		bool addVariable(string name, bool assigned){return local[scope]->addVariable(name, assigned);};
		
		bool addGlobal(string name);
		bool addGlobal(string name, bool assigned);
		bool addFunc(string name);

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

bool operations::addFunc(string name){
	newScope();
	curFunc[scope] = name;
	allFunc.push_back(name);
	addLine("func " + name);
	return addGlobal(name, true);
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
	global.assigned(name);
	local[scope]->assigned(name);
}

bool operations::addGlobal(string name, bool assigned){
	if(true == global.addVariable(name, assigned)){
		for(int i = 0; i <= scope; i++){
			if(false == local[i]->addVariable(name, assigned))		//Adds global to all scopes, returns false if global name was already used in a scope
				return false;
		}
	}
	return true;
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
		return NULL;
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
	addLine("= " + dst + ", " + src);
}
//Declares parameter values		= dst, $0		 	dst = $0 ($0 is the 1st function parameter) 
void operations::copy(string dst){
	addLine("= " + dst + ", " + "$" + toString(argPos++));
}
//dst = src[index]
string* operations::arrToVar(string src, string index){
	string* tmp = getTmp();
	addLine("=[] " + *tmp + ", " + src + ", " + index);
	return tmp;
}
//dst[index] = src
void operations::varToArr(string dst, string index, string src){
	addLine("[]= " + dst + ", " + index + ", " + src);
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
	return mil;
}