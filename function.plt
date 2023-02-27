int add(int a, int b){
	return a + b;
}

int mult(int a, int b){
	return a * b;
}

int main(){
	int a = 100;
	int b = 50;
	int c = add(a, b);
	write c;	//shoud print 150

	int d = mult(c, a+b);
	write d;	//should print "22500", since 22500 = 150 * 150
}