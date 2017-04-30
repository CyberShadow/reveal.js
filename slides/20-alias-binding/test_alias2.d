int ret(alias x)()
{
	return x;
}

struct S
{
	int f;
	int m() { return f; }

	void test()
	{
		pragma(msg, "Fields "  ~ ( __traits(compiles,  ret!f) ? "BIND" : "DO NOT bind" ) ~ " context");
		pragma(msg, "Methods " ~ ( __traits(compiles,  ret!m) ? "BIND" : "DO NOT bind" ) ~ " context");
	}
}
