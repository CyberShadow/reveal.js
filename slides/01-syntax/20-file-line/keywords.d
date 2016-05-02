module keywords;

import std.stdio;

void main()
{
	writeln(__FILE__);
	writeln(__LINE__);
	writeln(__MODULE__);
	writeln(__FUNCTION__);
	writeln(__PRETTY_FUNCTION__);
}
