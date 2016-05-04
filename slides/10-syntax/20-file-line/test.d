import std.stdio;

void a(int line = __LINE__)
	{ writeln(line); }
void b(int line = __LINE__)()
	{ writeln(line); }

void main() {
	a();
	b();
}
