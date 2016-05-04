import std.stdio; // SKIP

void print(alias x)() {
	writeln(x);
}

struct S {
	int f = 1;
	@property int p() { return 2; }

	alias printF = print!f; // OK
	alias printP = print!p; // Error
	// need 'this' for 'p'
}
