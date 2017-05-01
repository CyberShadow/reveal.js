import std.stdio; // SKIP

int n = 42;

void printIt(alias var)()
{
	writeln(var);
}

void main()
{
	printIt!n();
}
