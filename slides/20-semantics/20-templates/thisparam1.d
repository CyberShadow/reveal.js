struct S {
	const void foo(this T)() {
	    pragma(msg, typeof(this));
	    // const(S)
    }
}

void main() {
    S s;
    s.foo();
}