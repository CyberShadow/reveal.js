import std.format, std.stdio;

void main()
{
	string name = "Mary"; int apples = 4;
	format("This is %1$s. " ~
		"%1$s has %2$d apples.",
		name, apples).writeln();
}
