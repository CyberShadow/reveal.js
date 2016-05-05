import std.stdio; // SKIP

void main() {
	try {
		try {
			throw new Exception("a");
		} finally {
			throw new Exception("b");
		}
	} catch (Throwable e) {
		for (; e; e=e.next)
			writeln(e.msg);
	}
}
