struct S {
	void foo(this T)() {
		pragma(msg, typeof(this));
    }
}

void main() {
	          S m; m.foo();
	    const S c; c.foo();
	immutable S i; i.foo();
}
