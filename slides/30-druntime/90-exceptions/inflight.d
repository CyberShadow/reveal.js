Throwable inFlight()
{
	try
		throw new Exception("test");
	catch (Exception e)
		return e.next;
}

void main()
{
	import std.stdio;
	try
		throw new Exception("test");
	finally
		writeln(!!inFlight);
}
