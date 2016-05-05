void exceptionContext(lazy string msg,
	void delegate() fun)
{
	try
		fun();
	catch (Exception e) {
		e.msg = msg ~ ":\n" ~ e.msg;
		throw e;
	}
}
