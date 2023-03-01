//Test file

int fibonacci(int k){
    if (k <= 1 ) {
        return 1;
    }
    return k * fibonacci( k - 1 );
}

int newFunc(int n) {
	int[-10] a;
    int x; 
    x = -10;
	a[0] = x;
	a[1] = a[0];
    while (n != 10) {
        n = n + 1;
    }

    do {
        n = n + 1;
    }
    while (n != 10);
}

int main(){
    int n;

    read n;
    int fib_n = fibonacci( n );
    write fib_n;
}
