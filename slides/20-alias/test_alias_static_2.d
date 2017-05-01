import std.stdio; // SKIP

struct S
{
	int i;
	
	static template test(alias s)
	{
		void test()
		{
			writeln(s);
		}
	}
}	

void main()
{
	int i = 42;
	S s;
	s.test!i();
	//printProps!i();
}
