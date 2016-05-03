import std.stdio;

void runfun(int line = __LINE__)   { writeln(line); }
void tplfun(int line = __LINE__)() { writeln(line); }

void main()
{
	runfun();
	tplfun();
}
