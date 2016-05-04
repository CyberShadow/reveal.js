struct S {
	const void foo(this T)() {
	    pragma(msg, T);
	    // S                      ⁣
    }
}

void main() {
    S s;
    s.foo();
}