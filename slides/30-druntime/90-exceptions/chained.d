import std.stdio; // SKIP

void main() {
	try {
		scope (failure)
			throw new Exception("b");
		throw new Exception("a");
	} catch (Throwable e) {
		for (; e; e=e.next)
			writeln(e.msg);
	}
}
