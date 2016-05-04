import std.stdio; // SKIP
int foo() { writeln("called!"); return 42; }

mixin template T() {
	auto x = foo();
}

void main() {
	mixin T;
	writeln(x);
}

/*
int a() { return 1; }
void b() { }

void main()
{
	1?a:b;
}
*/