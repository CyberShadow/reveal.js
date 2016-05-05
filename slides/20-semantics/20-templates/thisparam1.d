struct S {
	const void foo() {
	    pragma(msg, typeof(this));
	    // const(S)
    }
}

void main() {
    S s;
    s.foo();
}