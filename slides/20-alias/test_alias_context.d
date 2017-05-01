import std.stdio; // SKIP

void printIt(alias var)()
{
	writeln(var);
}

void main()
{
	int n = 42;
	printIt!n();
}
