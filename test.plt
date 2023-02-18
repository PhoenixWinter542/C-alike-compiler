int fibonacci(int k){
    if (k <= 1 ) {
        return 1;
    }
    int a;
    int b;
    a = fibonacci( k - 1 );
    b = fibonacci( k - 2 );
    return a + b;
}

int main(){
    int n;
    int fib_n;

    read n;
    fib_n = fibonacci( n );
    write fib_n;
}