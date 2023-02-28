#include <vector>
using std::vector;
	
struct varStruct{
	string name;
	bool assigned;	//Tracks if the variable has been assigned
};


class variables{
	private:
		vector<varStruct> varNames;

		void push(string newName);
		void push(string newName, bool assigned);
		int findPos(string name);
		bool isUsed(string name);

	public:
		bool addVariable(string name, bool assigned);
		void assigned(string name);
		vector<varStruct> getStruct();
		
		//Constructors
		variables(){};
		variables(vector<varStruct> global);

};


//--------------------------------------Private---------------------------------------------------

void variables::push(string newName){
	push(newName, false);
}

void variables::push(string newName, bool assigned){
	varStruct tmp = {newName, assigned};
	varNames.push_back(tmp);
}

int variables::findPos(string name){
	for(unsigned int i = 0; i < varNames.size(); i++){
		if(varNames[i].name == name){
			return i;
		}
	}
	return -1;
}

bool variables::isUsed(string name){
	if(-1 != findPos(name))
		return true;
	else
		return false;
}

//--------------------------------------Public-------------------------------------------------

variables::variables(vector<varStruct> global){
	for(unsigned int i = 0; i < global.size(); i++){
		varNames.push_back(global[i]);
	}
}

//Returns true if variable was added
bool variables::addVariable(string name, bool assigned){
	if(true == isUsed(name))
		return false;
	else{
		push(name, assigned);
		return true;
	}
}

void variables::assigned(string name){
	int pos = findPos(name);
	varNames[pos].assigned = true;
}

vector<varStruct> variables::getStruct(){
	return varNames;
}
