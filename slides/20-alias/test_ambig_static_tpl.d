import std.stdio; // SKIP

struct S
{
	/*static*/ template Impl(alias x)
	{
		static void fun()
		{
			writeln(x);
		}
	}
}

struct T
{
	int i;
	alias inst = S.Impl!i;
}
