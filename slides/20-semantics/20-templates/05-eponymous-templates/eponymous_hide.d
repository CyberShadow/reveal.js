template foo(int n)
{
	enum foo = n;
	enum bar = "secret";
}

pragma(msg, foo!3.bar);
// Error: no property
// 'bar' for type 'int'
