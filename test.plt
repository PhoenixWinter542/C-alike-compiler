//Test file

int fibonacci(int k){
    if (k <= 1 ) {
        return 1;
    }
    return k * fibonacci( k - 1 );
}

int newFunc(int n) {
	int[10] a;
	write a;
    int x; 
    x = -10;
	write x;
	a[0] = x;
	write a[0];
	a[1] = a[0];
	write a[1];
    while (n != 10) {
		write n;
        n = n + 1;
    }

    do {
        n = n + 1;
    }
    while (n != 10);
}

int main(){
    int n = 10;
    //int fib_n = fibonacci( n );
	int fib_n = newFunc(n);
    write fib_n;
}
