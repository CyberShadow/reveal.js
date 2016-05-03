int foo() { return 42; }

mixin template T()
{
	auto x = foo();
}

void main()
{
	mixin T;
}
