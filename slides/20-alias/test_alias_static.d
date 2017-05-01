import std.stdio; // SKIP

void printProps(alias a)()
{
	writefln(
		"%s is a %s and is nested in %s",
		__traits(identifier, a),
		typeof(a).stringof,
		__traits(identifier,
			__traits(parent, a)),
	);
}

void main()
{
	int i = 42;
	printProps!i();
}
