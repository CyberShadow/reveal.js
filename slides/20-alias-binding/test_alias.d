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
		ret!f(); // OK
		ret!m(); // Error
	}
}
