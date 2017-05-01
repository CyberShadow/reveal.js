import std.stdio; // SKIP

struct S { string a, b, c; }

void main()
{
	printField!(S.b)();
}

static void printField(alias field)()
{
	S s = getS();
	writeln(__traits(child, s, field));
}
