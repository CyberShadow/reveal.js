import std.stdio;
void main()
{
	creal a = 5 + 0i;
	ireal b = 7i;       
	auto c = a + b + 7i;
	writeln(c); // 5+14i
}
