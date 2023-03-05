#include <vector>
#include <sstream>
using std::vector;

struct varStruct{
	string name;
	bool assigned;	//Tracks if the variable has been assigned
	vector<bool> array;
};


class variables{
	private:
		vector<varStruct> varNames;

		int atoi(string str);
		void push(string newName, bool assigned, vector<bool> array);
		int findPos(string name);
		vector<bool> createArray(string strSize);

	public:
		bool isUsed(string name);
		bool addVariable(string name, bool assigned, string array);
		bool assigned(string name);
		bool assigned(string name, string index);
		bool isAssigned(string name);
		bool isAssigned(string name, string index);
		bool isArray(string strSize);
		bool outOfBounds(string name, string index);
		vector<varStruct> getStruct();
		void addStruct(vector<varStruct> toAdd);
		
		//Constructors
		variables(){};
		variables(vector<varStruct> global);

};


//--------------------------------------Private---------------------------------------------------

int variables::atoi(string str)
{
    int num;
    stringstream ss(str);
    ss >> num;
    return num;
}

void variables::push(string newName, bool assigned, vector<bool> array){
	varStruct tmp = {newName, assigned, array};
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

vector<bool> variables::createArray(string strSize){
	int size = atoi(strSize);
	vector<bool> array;
	for(int i = 0; i < size; i++){
		array.push_back(false);
	}
	return array;
}

//--------------------------------------Public-------------------------------------------------

variables::variables(vector<varStruct> global){
	for(unsigned int i = 0; i < global.size(); i++){
		varNames.push_back(global[i]);
	}
}

//Returns true if variable was added
bool variables::addVariable(string name, bool assigned, string array){
	if(true == isUsed(name))
		return false;
	else{
		push(name, assigned, createArray(array));
		return true;
	}
}

bool variables::assigned(string name){
	int pos = findPos(name);
	if(-1 != pos){
		varNames[pos].assigned = true;
		return true;
	}
	return false;
}

bool variables::assigned(string name, string index){
	int pos = findPos(name);
	if(-1 != pos){
		varNames[pos].array[atoi(index)] = true;
		return true;
	}
	return false;
}

bool variables::isAssigned(string name){
	int pos = findPos(name);
	if(-1 != pos)
		return varNames[pos].assigned;
	else
		return false;
}

bool variables::isAssigned(string name, string index){
	int pos = findPos(name);
	if(-1 != pos){
		return varNames[pos].array[atoi(index)];
	}
	return false;
}

bool variables::isArray(string name){
	int pos = findPos(name);
	if(-1 != pos){
		return !varNames[pos].array.empty();
	}
	return false;
}

bool variables::outOfBounds(string name, string index){
	int pos = findPos(name);
	unsigned int tmp = atoi(index);
	if(-1 != pos){
		if('-' == index[0] || varNames[pos].array.size() <= tmp)
			return true;
		else
			return false;
	}
	return true;
}

vector<varStruct> variables::getStruct(){
	return varNames;
}

void variables::addStruct(vector<varStruct> toAdd){
	for(unsigned int i = 0; i < toAdd.size(); i++){
		if(false == isUsed(toAdd[i].name))
			push(toAdd[i].name, toAdd[i].assigned, toAdd[i].array);
	}
}
