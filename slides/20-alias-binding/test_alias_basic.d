import std.stdio; // SKIP

void printIt(alias var)()
{
	writeln(var);
}

void main()
{
	int var = 42;
	printIt!var();
}
