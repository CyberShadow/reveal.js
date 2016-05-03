void fun(T)(T x) {
	pragma(msg, T);
}

void main() {
	fun(5);
	fun(4.2);     // float
	fun("hello"); // string
}
