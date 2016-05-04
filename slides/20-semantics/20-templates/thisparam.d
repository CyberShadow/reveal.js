struct S {
	const void foo(this T)() {
	    pragma(msg, typeof(this));
	    pragma(msg, T);
    }
}

void main() {
    S s;
    s.foo();
}