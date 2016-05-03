template fun(T) {
	void fun(T x) {
		pragma(msg, T);
	}
}

void main() {
	fun(42);
}
