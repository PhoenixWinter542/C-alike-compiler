//Test file

//int fibonacci(int k){
//	if (k <= 1 ) {
//		return 1;
//	}
//	return k * fibonacci( k - 1 );
//}

int newFunc() {
//	int[10] a;
//	int x; 
//	x = -10;
//	a[0] = x;
//	a[1] = a[0];
int n = 11;
    while (n != 10 && n < 100 || n == 100) {
		write n;
        n = n + 1;
    }

    do {
        n = n + 1;
    }
    while (n <= 10);
	return n;
}

int main(){
    int n = 9;
    //int fib_n = fibonacci( n );
	int fib_n = newFunc();
    write fib_n;
}
