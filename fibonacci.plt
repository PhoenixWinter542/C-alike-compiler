int fibonacci(int k){
	if (k <= 1){
		return 1;
	}
	return fibonacci(k - 1) + fibonacci(k - 2);
}

int main(){
	int n;
	read n;
	int fib_n = fibonacci(n);
	write fib_n;
}