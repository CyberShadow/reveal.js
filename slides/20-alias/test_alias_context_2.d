import std.stdio; // SKIP

struct S
{
	int i;

	void print(alias b)()
	{
		writeln(i, " ", b);
	}
}

void main()
{
	S s;
	int i = 13;
	s.print!i();
}
